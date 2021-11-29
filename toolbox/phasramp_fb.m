function phasramp_fb()
% phase ramp stabilization feedback on 2-9 beam phase cavity

%% script initialization

sname = strcat(mfilename, '.m');
disp_log(strcat(sname, {' starting Version 2.0 5/22/13'}));
counter = script_setupPV('SIOC:SYS1:ML00:AO612', 'watchdog', ' ', 0, sname);
W = watchdog(char(counter), 5, sname);
if get_watchdog_error(W)
    disp_log(strcat(sname, {' is already running - exiting!'}));
    return
end

%% script config

debug = 0;
disp_log(sprintf('Debug = %d', debug));

% multiknob name
multiknob = 'MKB:PHSRMP.MKB';

% loop delay
delay = 1;

% phase cavity KLYS 
klys = 'LI02:KLYS:91';
secn = {'ADES' 'AJTN' 'AMPL' 'BVLT' 'ENLD' 'GOLD' 'KPHR' 'PDES' 'PHAS' 'PJTN'};
list = strcat(klys, ':', secn');
pvs = struct();
pvs.klys = cell2struct(list, lower(secn));

% feedback controls
pvs.in.enable       = script_setupPV('SIOC:SYS1:ML00:AO403', ...
                    'FB enable',            'bool', 0, sname);
pvs.in.gain         = script_setupPV('SIOC:SYS1:ML00:AO404', ...
                    'FB gain',              'arb',  3, sname);
pvs.in.setpoint     = script_setupPV('SIOC:SYS1:ML00:AO405', ...
                    'FB setpoint',          'degS', 3, sname);
pvs.in.q_min        = script_setupPV('SIOC:SYS1:ML00:AO406', ...
                    'Charge minimum',  '1e10 e-', 3, sname);
pvs.in.ampl_max     = script_setupPV('SIOC:SYS1:ML00:AO407', ...
                    'KLYS:LI02:91 ampl max',     'arb', 2, sname);
pvs.in.ampl_min     = script_setupPV('SIOC:SYS1:ML00:AO408', ...
                    'KLYS:LI02:91 ampl min',     'arb', 2, sname);
pvs.in.phas_max     = script_setupPV('SIOC:SYS1:ML00:AO409', ...
                    'KLYS:LI02:91 phase max',     'degS', 2, sname);
pvs.in.phas_min     = script_setupPV('SIOC:SYS1:ML00:AO410', ...
                    'KLYS:LI02:91 phase min',     'degS', 2, sname);
pvs.in.ramp_max     = script_setupPV('SIOC:SYS1:ML00:AO411', ...
                    'DR12:PHAS:61 phase max',     'degS', 2, sname);
pvs.in.ramp_min     = script_setupPV('SIOC:SYS1:ML00:AO412', ...
                    'DR12:PHAS:61 phase min',     'degS', 2, sname);
pvs.in.trimtol      = script_setupPV('SIOC:SYS1:ML00:AO413', ...
                    'DR12:PHAS:61 trim tol','degS', 2, sname);                
pvs.in.window       = script_setupPV('SIOC:SYS1:ML00:AO414', ...
                    'OutsideT slope window','min',  1, sname);                

% diagnostic inputs
pvs.charge          = 'LI02:TORO:912:DATA';
pvs.beamrate        = 'EVNT:SYS1:1:BEAMRATE';
pvs.scavrate        = 'EVNT:SYS1:1:SCAVRATE';
pvs.outsidet        = 'MC00:ASTS:OUTSIDET';
pvs.phase.vdes      = 'DR12:PHAS:61:VDES';
pvs.phase.vact      = 'DR12:PHAS:61:VACT';

% diagnostic outputs
pvs.out.phase       = script_setupPV('SIOC:SYS1:ML00:AO415', ...
                    'Desired phase change', 'degS', 2, sname);
pvs.out.total       = script_setupPV('SIOC:SYS1:ML00:AO416', ...
                    'Cumulative phase change', 'degS', 2, sname);
pvs.out.tslope      = script_setupPV('SIOC:SYS1:ML00:AO417', ...
                    'OutsideT slope',       'degF', 3, sname);
pvs.out.enable      = script_setupPV('SIOC:SYS1:ML00:AO418', ...
                    'Feedback active',      'bool', 0, sname);
pvs.msgstring       = 'SIOC:SYS1:ML00:CA003';  lcaPutSmart(strcat(pvs.msgstring, '.DESC'), sname);

%% first iteration stuff

[data, ts] = lcaGetStruct(pvs);
mkbPV = AssignMultiknob(multiknob);
global da_mkb;
total = 0;

%% main loop starts here

disp_log('Main loop starting.');
while 1

%% wait and increment watchdog

    pause(delay);
    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp_log('Some sort of watchdog error - exiting');
        break;  % Exit program
    end

%% get some fresh data    

    old = data;  oldts = ts;
    [data, ts] = lcaGetStruct(pvs);
    
%% check for communication broken and bail out if found

    good = 1;
    if any(structfun(@isnan, data.klys))
        disp_log(strcat({'Error getting data from '}, klys));
        good = good && 0;        
    end
    if any([structfun(@isnan, data.in); structfun(@isnan, data.out)])
        disp_log('Error getting SIOC:SYS1:ML00 PVs');
        good = good && 0;
    end
    if any(structfun(@isnan, data.phase))
        disp_log('Error getting data from DR12:PHAS:61');
        good = good && 0;
    end
    if ~good
        lcaPutSmart(pvs.out.enable, 0);
        continue;
    end

%% check for fresh updated data from phase cavity

    new_phas = (old.klys.phas - data.klys.phas) ~= 0;
    if debug
        cav_ts = lca2matlabTime(ts.klys.phas);
        if new_phas, fprintf(1, '* NEW *'), end
        fprintf(1, 'PHAS = %.2f, ts = %s\n', data.klys.phas, datestr(cav_ts));
    end;
    
%% check everything is within limits

    msg = []; 

    % feedback disabled
    if ~data.in.enable
        good = good && 0; msg = [msg, sprintf('Disabled by user\n')];
    end
    
    % beam charge below limit
    if (data.charge * 1e10 < data.in.q_min)  
        good = good && 0; msg = [msg, sprintf('%s below limit of %.3g\n', pvs.charge, data.in.q_min * 1e10)]; 
    end
 
    % amplitude readback out of limit
    if (data.klys.ampl > data.in.ampl_max) 
        good = good && 0; msg = [msg, sprintf('%s above limit of %.2f\n', pvs.klys.ampl, data.in.ampl_max)];
    end
    if (data.klys.ampl < data.in.ampl_min)
        good = good && 0; msg = [msg, sprintf('%s below limit of %.2f\n', pvs.klys.ampl, data.in.ampl_min)];
    end
    
    % phase readback out of limit
    if (data.klys.phas > data.in.phas_max) 
        good = good && 0; msg = [msg, sprintf('%s above limit of %.2f\n', pvs.klys.phas, data.in.phas_max)];
    end
    if (data.klys.phas < data.in.phas_min)
        good = good && 0; msg = [msg, sprintf('%s below limit of %.2f\n', pvs.klys.phas, data.in.phas_min)];
    end

    % phase ramp out of limit
    if (data.phase.vdes > data.in.ramp_max) 
        good = good && 0; msg = [msg, sprintf('%s above limit of %.2f\n', pvs.phase.vdes, data.in.ramp_max)];
    end
    if (data.phase.vdes < data.in.ramp_min)
        good = good && 0; msg = [msg, sprintf('%s below limit of %.2f\n', pvs.phase.vdes, data.in.ramp_min)];
    end
    
    % phase ramp out-of-tol
    if (abs(data.phase.vdes - data.phase.vact) > data.in.trimtol)
        good = good && 0; msg = [msg, sprintf('%s out of tol, trim within %.2f\n', pvs.phase.vact, data.in.trimtol)];
    end
    
    if good, msg = 'Running, all OK'; end

%% calculate outside temp slope
    
    % do this eventually
    tslope = 0;

%% calculate knob change 

    knob_set = data.in.gain * (data.klys.phas - data.in.setpoint);    

%% output some diagnostic info
    
    out = data.out;
    out.phase = knob_set;
    out.total = total;
    out.tslope = tslope;
    out.enable = good;    
    lcaPutStruct(pvs.out, out);
    disp_msg(pvs.msgstring, msg);

%% actually write the knob output    

    if ~debug && good
        total = total + knob_set;
        da_mkb.setDaValue(mkbPV, knob_set);
    end

end



function disp_msg(strpv, msg)
    marray = zeros(1000,1);
    marray(1:numel(char(msg))) = double(char(msg));
    lcaPutSmart(strpv, double(msg));