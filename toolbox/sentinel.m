function sentinel()

% Sentinel MPS - soft MPS for FACET.
% N Lipkowitz, SLAC
% modify 8/9 for FACET-II commissioning

%% constants

% set script rate, 0.1 = 10 Hz
delay = 0.05;  

% debug flag turns off the 2-9 dumpering
debug = 0;


%% initialize the script

% determine script name
scr = strcat(mfilename, {'.m'});

% log startup
disp_log(strcat({'Starting '}, scr, {', ver. 2.1 8/9/2018'}));

% start watchdog
watchdog_pv = 'SIOC:SYS1:ML00:AO701';
W = watchdog(watchdog_pv, 1, scr);
switch get_watchdog_error(W)
    case 1
        disp_log(strcat({'Another '}, scr, {' is running - exiting'}));
        return;
    case 2
        disp_log(strcat({'Error reading/writing '}, watchdog_pv, {' - exiting'}));
        return;
    otherwise
        disp_log(strcat({'Watchdog started on '}, watchdog_pv));
end


%% define process controls (read and write)

% status message
pvs.msg =           'SIOC:SYS1:ML00:CA007';
lcaPutSmart([pvs.msg, '.DESC'], scr);
lcaPutSmart('SIOC:SYS1:ML00:CA008.DESC', scr);

% global inputs
pvs.ctrl.disable =      script_setupPV('SIOC:SYS1:ML00:AO702', 'Sentinel Disable', 'bool', 0, scr);
pvs.ctrl.trip =         script_setupPV('SIOC:SYS1:ML00:AO703', 'Trip status', 'bool', 0, scr);
pvs.ctrl.reset =        script_setupPV('SIOC:SYS1:ML00:AO704', 'Reset', 'bool', 0, scr);

% bypass control for each fault condition
pvs.bypass(1) =         script_setupPV('SIOC:SYS1:ML00:AO705', 'IN10 gun pressure bypass', 'bool', 0, scr);
pvs.bypass(2) =         script_setupPV('SIOC:SYS1:ML00:AO708', 'EP01 kicker bypass', 'bool', 0, scr);
pvs.bypass(3) =         script_setupPV('SIOC:SYS1:ML00:AO712', 'FACET beam power bypass', 'bool', 0, scr);
pvs.bypass(4) =         script_setupPV('SIOC:SYS1:ML00:AO720', 'Notch coll rate bypass', 'bool', 0, scr);
pvs.bypass(5) =         script_setupPV('SIOC:SYS1:ML00:AO725', 'Kraken laser mirror bypass', 'bool', 0, scr);
pvs.bypass(6) =         script_setupPV('SIOC:SYS1:ML00:AO716', 'FACET IP location bypass', 'bool', 0, scr);
pvs.bypass(7) =         script_setupPV('SIOC:SYS1:ML00:AO729', 'IPOTR1 moving bypass', 'bool', 0, scr);
pvs.bypass(8) =         script_setupPV('SIOC:SYS1:ML00:AO739', 'Reserved', 'bool', 0, scr);

% threshold (if necessary) for each fault condition
pvs.thresh(1) =         script_setupPV('SIOC:SYS1:ML00:AO706', 'IN10 gun pressure maximum', 'Torr', 2, scr);
pvs.thresh(2) =         script_setupPV('SIOC:SYS1:ML00:AO709', 'EP01 kicker BACT minimum', 'V', 1, scr);
pvs.thresh(3) =         script_setupPV('SIOC:SYS1:ML00:AO713', 'FACET beam power maximum', 'W', 1, scr);
pvs.thresh(4) =         script_setupPV('SIOC:SYS1:ML00:AO721', 'Notch coll max rate', 'Hz', 0, scr);
pvs.thresh(5) =         script_setupPV('SIOC:SYS1:ML00:AO726', 'Kraken mirror max rate', 'Hz', 0, scr);
pvs.thresh(6) =         script_setupPV('SIOC:SYS1:ML00:AO718', 'IP location rate limit', 'Hz', 0, scr);
pvs.thresh(7) =         script_setupPV('SIOC:SYS1:ML00:AO737', 'Max rate when IPOTR1 moving', 'Hz', 0, scr);

%% PV inputs (read only)

% beam params (energy, rate, etc)
pvs.in.beamrate =       'EVNT:SYS1:1:INJECTRATE';
pvs.in.scavrate =       'EVNT:SYS1:1:SCAVRATE';
pvs.in.posrate  =       'EVNT:SYS1:1:FACETELECTRONRATE';

% toroid charges
pvs.in.charge   =      {'LI02:TORO:111:DATA';
                        'LI02:TORO:912:DATA';
                        'LI04:TORO:915:DATA';
                        'LI10:TORO:133:DATA';
                        'LI20:TORO:1988:DATA';
                        'LI20:TORO:2040:DATA';
                        'LI20:TORO:2452:DATA';
                        'LI20:TORO:3163:DATA';
                        'LI20:TORO:3255:DATA'};

% EPICS bpm TMITs
pvs.in.tmit =          {'BPMS:LI20:2445:TMIT';
                        'BPMS:LI20:3156:TMIT';
                        'BPMS:LI20:3265:TMIT';
                        'BPMS:LI20:3315:TMIT'};
                        
% Sector 10 gun pressures
pvs.in.gun.p =         {'VGXX:IN10:113:COMBO_P';
                        'VGXX:IN10:165:COMBO_P'};
                    
pvs.in.gun.i_adjust =   'GUN:LI10:1:GUN_I_ADJUST';

pvs.in.gun.bcmx =       'KLYS:LI10:21:BCMX';
                    
% % Sector 20 B5D status
% pvs.in.b5.bdes =        'LI20:LGPS:3330:BDES';
% pvs.in.b5.bact =        'LI20:LGPS:3330:BACT';
% pvs.in.b5.stat =        'LI20:LGPS:3330:STAT';
% 
% % Sector 19 kicker status
% pvs.in.kicker.bdes =    'EP01:LGPS:1:BDES';
% pvs.in.kicker.bact =    'EP01:LGPS:1:BACT';
% pvs.in.kicker.stat =    'EP01:LGPS:1:STAT';

% Sector 20 notch collimator motor positions
% pvs.in.notch.pos =     {'COLL:LI20:2069:MOTR.RBV';
%                         'COLL:LI20:2070:MOTR.RBV';
% %                        'COLL:LI20:2071:MOTR.RBV';
%                         'COLL:LI20:2072:MOTR.RBV';
%                         'COLL:LI20:2073:MOTR.RBV'};

% sector 20 waist locations from waist locator
% pvs.in.waist.xname = 'SIOC:SYS1:ML00:SO0351';
% pvs.in.waist.yname = 'SIOC:SYS1:ML00:SO0351';
pvs.in.waist.betax = 'SIOC:SYS1:ML00:AO352';
pvs.in.waist.betay = 'SIOC:SYS1:ML00:AO354';

% Sector 20 kraken laser mirror switch                   
%pvs.in.mirror =        'MIRR:LI20:3202:TGT_STS';
                    
% Sector 20 notch collimator MPS switch
% pvs.in.notchmps =      'LI20:MPS:15:NOTCHCOL';
                                        
% Sector 20 oven position
% pvs.in.oven.pos =       'OVEN:LI20:3185:LVPOS';

%pvs.in.otrmoving =     'OTRS:LI20:3180:MOTR.MOVN';
% 
% % 1553 NewMPS zero-rate inputs
% % look in "trip" function for corresponding logic
% pvs.in.newmps = {
%     'LI20:MPS:7:EKIC_ENB';
%     'LI20:MPS:6:HLAM_ENB';
%     'LI20:MPS:13:FV1986';
%     'LI20:MPS:13:VALV3068';
%     'LI20:MPS:13:VALV3076';
%     'LI20:MPS:13:VALV3160';
%     'LI20:MPS:13:VALV3250';
%     'LI20:MPS:13:HV_STATS';
%     'LI20:MPS:13:HCOL2072';
%     'LI19:MPS:2:BLM_STAT'; 
%     'LI20:MPS:12:PHOS2042';
%     'LI20:MPS:14:KCHAMBER';
%     'LI20:MPS:15:OTRS3180';
%     'LI20:MPS:14:DUMPSHTR';
%     'LI20:MPS:14:EPS_SUM';
%     'LI20:MPS:15:BEWINDOW';
%     'LI20:MPS:15:BLEN3014';
%     };

% 
% % 1553 newMPS beam OK states
% newmps.vals.ok = {
%      1  1;  %     'LI20:MPS:7:EKIC_ENB';
%      1  1;  %     'LI20:MPS:6:HLAM_ENB';
%      1  1;  %     'LI20:MPS:13:FV1986';
%      1  1;  %     'LI20:MPS:13:VALV3068';
%      1  1;  %     'LI20:MPS:13:VALV3076';
%      1  1;  %     'LI20:MPS:13:VALV3160';
%      1  1;  %     'LI20:MPS:13:VALV3250';
%      1  1;  %     'LI20:MPS:13:HV_STATS';
%      1  1;  %     'LI20:MPS:13:HCOL2072';
%      1  2;  %     'LI19:MPS:2:BLM_STAT';
%      1  2;  %     'LI20:MPS:12:PHOS2042';
%      1  2;  %     'LI20:MPS:14:KCHAMBER';
%      1  2;  %     'LI20:MPS:15:OTRS3180';
%      1  1;  %     'LI20:MPS:14:DUMPSHTR';
%      1  1;  %     'LI20:MPS:14:EPS_SUM';
%      1  2;  %     'LI20:MPS:15:BEWINDOW';
%      1  2;  %     'LI20:MPS:15:BLEN3014';
% };
    
    




% %% Laser control stuff
% 
% % trigger for laser
% pvs.laser.trig   = 'DO:LA20:10:Bo1';
% pvs.laser.safe   = script_setupPV('SIOC:SYS1:ML00:AO723', 'Safe for laser', 'bool', 0, scr);
% pvs.laser.disable= script_setupPV('SIOC:SYS1:ML00:AO727', 'Disable laser check', 'bool', 0, scr);
% pvs.laser.trip   = script_setupPV('SIOC:SYS1:ML00:AO728', 'Laser trip', 'bool', 0, scr);
% 
% roots = {...
%     'OTRS:LI20:3175'; ...  % ODR/OTR
%     'OTRS:LI20:3180'; ...  % IPOTR1
%     'OTRS:LI20:3206'; ...  % DSOTR
%     'WIRE:LI20:3179'; ...  % WSIP1
%     'OVEN:LI20:3185'; ...  % OVEN
%     'WIRE:LI20:3206'; ...  % WSIP2
%     'WIRE:LI20:3229'; ...  % WSIP3
%     };
% 
% pvs.laser.motr = strcat(roots, ':MOTR.RBV');
% pvs.laser.softlims = strcat(roots, ':MOTR.HLM');
% pvs.laser.hardlims = strcat(roots, ':MOTR.HLS');
% 
% % "safe" status 
% pvs.laser.states =  [...
%     script_setupPV('SIOC:SYS1:ML00:AO730', 'ODROTR safe for laser', 'bool', 0, scr);
%     script_setupPV('SIOC:SYS1:ML00:AO731', 'IPOTR1 safe for laser', 'bool', 0, scr);
%     script_setupPV('SIOC:SYS1:ML00:AO732', 'DSOTR safe for laser',  'bool', 0, scr);
%     script_setupPV('SIOC:SYS1:ML00:AO733', 'WSIP1 safe for laser',  'bool', 0, scr);
%     script_setupPV('SIOC:SYS1:ML00:AO734', 'OVEN safe for laser',   'bool', 0, scr);
%     script_setupPV('SIOC:SYS1:ML00:AO735', 'WSIP2 safe for laser',  'bool', 0, scr);
%     script_setupPV('SIOC:SYS1:ML00:AO736', 'WSIP3 safe for laser',  'bool', 0, scr);
%     ];
% 
% % Bypass controls to disable/enable laser safe devices
% pvs.laser.bypass = [ ...
%     script_setupPV('SIOC:SYS1:ML00:AO740', 'ODROTR laser safe bypass', 'bool', 0, scr);
%     script_setupPV('SIOC:SYS1:ML00:AO741', 'IPOTR1 laser safe bypass', 'bool', 0, scr);
%     script_setupPV('SIOC:SYS1:ML00:AO742', 'DSOTR laser safe bypass',  'bool', 0, scr);
%     script_setupPV('SIOC:SYS1:ML00:AO743', 'WSIP1 laser safe bypass',  'bool', 0, scr);
%     script_setupPV('SIOC:SYS1:ML00:AO744', 'OVEN laser safe bypass',   'bool', 0, scr);
%     script_setupPV('SIOC:SYS1:ML00:AO745', 'WSIP2 laser safe bypass',  'bool', 0, scr);
%     script_setupPV('SIOC:SYS1:ML00:AO746', 'WSIP3 laesr safe bypass',  'bool', 0, scr);
%     ];
% 
%% outputs

% beam power calculation
pvs.out.facetpower  =       script_setupPV('SIOC:SYS1:ML00:AO711', 'FACET dump beam power', 'W', 1, scr);
pvs.out.scavpower   =       script_setupPV('SIOC:SYS1:ML00:AO715', 'e+ target beam power', 'W', 1, scr);

% trip states
pvs.out.trip(1)   =         script_setupPV('SIOC:SYS1:ML00:AO707', 'IN10 gun pressure  trip', 'bool', 0, scr);
pvs.out.trip(2)   =         script_setupPV('SIOC:SYS1:ML00:AO710', 'EP01 kicker trip', 'bool', 0, scr);
pvs.out.trip(3)   =         script_setupPV('SIOC:SYS1:ML00:AO714', 'FACET beam power trip', 'bool', 0, scr);
pvs.out.trip(4)   =         script_setupPV('SIOC:SYS1:ML00:AO722', 'Notch coll. rate trip', 'bool', 0, scr);
pvs.out.trip(5)   =         script_setupPV('SIOC:SYS1:ML00:AO724', 'Kraken mirror rate trip', 'bool', 0, scr);
pvs.out.trip(6)   =         script_setupPV('SIOC:SYS1:ML00:AO717', 'FACET IP location trip', 'bool', 0, scr);
pvs.out.trip(7)   =         script_setupPV('SIOC:SYS1:ML00:AO738', 'IPOTR1 moving rate trip', 'bool', 0, scr);
pvs.out.trip(8)   =         script_setupPV('SIOC:SYS1:ML00:AO747', 'NewMPS AP20 zerorate trip', 'bool', 0, scr);


%% first iteration stuff

disp_msg(pvs.msg, 'Sentinel OK');

% start out no trip
tripped = 0;

% clear the trip and reset PVs
lcaPutSmart(pvs.ctrl.trip, 0);
lcaPutSmart(pvs.ctrl.reset, 0);
pause(0.1);

% get a data set
data = get_data(pvs);

% no strikes for bad data
strikes = 0;
max_strikes = 3;

%% main loop

while 1
    
    % pause and increment watchdog
    pause(delay);
    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp_log('Some sort of watchdog error');
        break;  % exit program
    end
    
    % store last iteration's trip state
    was_tripped = data.ctrl.trip;
    
    % store last iteration's data
    old = data;
    
    % get a data set
    data = get_data(pvs);
    
    
    % check for NaNs in input
    %            any(isnan(struct2array(data.in.b5))) || ...
    %            any(isnan(struct2array(data.in.kicker))) || ...
%                 any(isnan([data.laser.trig data.laser.safe data.laser.disable data.laser.trip])) || ...
%             any(isnan(data.laser.motr)) || ...
%             any(isnan(data.laser.softlims)) || ...
%             any(isnan(data.laser.hardlims)) || ...
%             any(isnan(data.laser.states)) || ...
%             any(isnan(data.laser.bypass));
%            any(isnan(data.in.notch.pos)) || ...
    nans =  any(isnan(data.bypass)) || ...
            any(isnan(data.thresh)) || ...
            any(isnan(struct2array(data.ctrl))) || ...
            any(isnan(data.in.charge)) || ...
            any(isnan(data.in.tmit)) || ... 
            any(isnan([data.in.beamrate data.in.scavrate data.in.dump]));
    % try to acquire again if there are nan's in input
    % but only twice
    %            disp(data.in.newmps);
    %            disp(data.in.b5);
    %            disp(data.in.kicker);
    if nans
        strikes = strikes + 1;
        if (strikes <= max_strikes)
            disp_log(sprintf('NaNs on input, acquiring again (%d/%d)', strikes, max_strikes));
            disp(data.in);
            disp(data.in.charge);
            disp(data.in.tmit);
%             disp(data.in.notch);
%             disp(data.in.waist);
%             disp(data.in.oven);
%             disp(data.ctrl);
%             disp(data.laser);
%             disp(data.laser.motr);
%             disp(data.laser.softlims);
%             disp(data.laser.hardlims);
            continue;
        else
            % do nothing and let the trip happen
        end        
    else
        % if no NaNs, reset the strike counter
        strikes = 0;
    end
        
%     % do laser check
%     lasersafe = check_laser(pvs, data);
%     lcaPutSmart(pvs.laser.safe, lasersafe);
% 
%     if ~data.laser.disable
%         % if any not out, trip laser
%         if ~lasersafe
%             %disp_log('I AM TRIPPING HTE LASER');
%             lcaPutSmart(pvs.laser.trip, 1);
%             lcaPutSmart(pvs.laser.trig, 1); % 1 = HIGH = shutter closed
%         else 
%             lcaPutSmart(pvs.laser.trip, 0);
%         end        
%     end
    
    % decide whether to trip
    [tripped, message, out] = trip(data, old, pvs);
    data.out = out;
    
    % output the outputs
    stat = lcaPutStruct(pvs.out, data.out);
    
    % trip the beam
    if ~data.ctrl.disable && (tripped || data.ctrl.trip)
        
%         % dump 2-9
%         if ~debug, 
%             if ~data.in.dump
%                 set_2_9(1); 
%             end;
%         end
%         

%         if ~debug
%             if abs(data.in.gun.i_adjust > 0)
%                 lcaPutSmart(pvs.in.gun.i_adjust, 0)
%             end
%         end

        if ~debug
            lcaPutSmart(pvs.in.gun.bcmx, 1);
        end
        
        
        % set trip flag
        data.ctrl.trip = 1;

        if ~was_tripped
            
%            % store the former PAC state
%            old_pac_state = data.in.gun.i_adjust;

          % store the former BCMX
           old_bcmx = data.in.gun.bcmx;
           
           % set trip message
           disp_msg(pvs.msg, message);
           
        end
        
    end

    % clear trip if reset pressed
    if (data.ctrl.reset && ~tripped) || (data.ctrl.reset && data.ctrl.disable)
        
        %only touch 2-9 if there was a trip set
        if was_tripped
            
            disp_msg(pvs.msg, sprintf('Reset pressed, setting KLYS BCMX to %d', old_bcmx));

            % restore 2-9 to old state
            if ~debug, lcaPutSmart(pvs.in.gun.bcmx, old_bcmx); end

        end
        
        % clear trip flag
        data.ctrl.trip = 0;
        
        % set OK message
        disp_msg(pvs.msg, 'Sentinel OK');
    end
    
    % clear reset flag
    data.ctrl.reset = 0;

    % output trip/reset
    lcaPutSmart(pvs.ctrl.trip, data.ctrl.trip);
    lcaPutSmart(pvs.ctrl.reset, data.ctrl.reset);
end

end

%% helper functions

function data = get_data(pvs)
    % this function wraps up all the input stuff and does some intermediate
    % processing

    % get all PVS in the PV struct
    data = lcaGetStruct(pvs, 0, 'double');

    % get the waist location strings
    data.in.waist.xname = lcaGetSmart('SIOC:SYS1:ML00:SO0351');
    data.in.waist.yname = lcaGetSmart('SIOC:SYS1:ML00:SO0353');
    data.in.waist.exclude = char(lcaGetSmart('SIOC:SYS1:ML00:CA008'));

    % get the beam energy
    lem_e = model_energySetPoints();
    data.in.energy = lem_e(end) * 1e9;
    
    % get the 2-9 state
    data.in.dump = get_2_9;
    
    % calculate FACET beam power
    q_e = 1.60218e-19;

    rate = data.in.beamrate;
%    rate = data.in.posrate;
    data.out.facetpower = rate * data.in.energy * mean(data.in.tmit) * q_e;
    data.out.scavpower = data.in.scavrate * data.in.energy * data.in.charge(4) * q_e;
   
%     % query the laser safe mode
%     [data.out.lasersafe data.out.laserdevs] = facet_laser_safe();

end


function [tripped, message, out] = trip(data, old, pvs)

    % trip logic goes here

    % consider magnet STAT unacceptable IF:
    % "In trouble" or "Is Turned OFF" or "Out of Range" or "Out of Tolerance"
    bitmask = hex2dec('1818'); 
    
    out = data.out;
    out.trip(:) = 0;
    tripped = 0;
    message = 'Sentinel OK';
    
    rate = data.in.posrate;
    
    % trip if Gun vacuum pressure is too high    
    if any(isnan(data.in.gun.p)) || any((data.in.gun.p) > data.thresh(1))
        out.trip(1) = 1;
        if ~data.bypass(1)
            if ~tripped
                tripped = 1;
                message = sprintf('Gun pressure above %.2f nTorr', 1e9 * data.thresh(1));
            end
        end
    end
% 
%     % trip if B5D has bad STAT
%     if isnan(data.in.b5.stat) || bitand(uint16(bitmask), uint16(data.in.b5.stat))
%         out.trip(1) = 1;
%         if ~data.bypass(1)
%             if ~tripped
%                 tripped = 1;
%                 message = sprintf('Dump BEND B5D36 has bad STAT: %s', dec2hex(data.in.b5.stat));
%             end
%         end
%     end

%     % trip if EP01 extraction kicker BACT is too loow
%         if isnan(data.in.kicker.bact) || (data.in.kicker.bact < data.thresh(2))
%         out.trip(2) = 1;
%         if ~data.bypass(2)
%             if ~tripped
%                 tripped = 1;
%                 message = sprintf('EP01 ext kicker BACT below threshold of %.1f', data.thresh(2));
%             end
%         end
%     end

%     % trip if EP01 extraction kicker has bad STAT
%     if isnan(data.in.kicker.stat) || bitand(uint16(bitmask), uint16(data.in.kicker.stat))
%         out.trip(2) = 1;
%         if ~data.bypass(2)
%             if ~tripped
%                 tripped = 1;
%                 message = sprintf('EP01 ext kicker has bad STAT: %s', dec2hex(data.in.kicker.stat));
%             end
%         end
%     end

    % trip if beam power too high
    if isnan(data.out.facetpower) || (data.out.facetpower > data.thresh(3))
        out.trip(3) = 1;
        if ~data.bypass(3)
            if ~tripped
                tripped = 1;
                message = sprintf('FACET beam power above threshold of %.1f', data.thresh(3));
            end
        end
    end
    
%     % trip if notch collimator IN and rate too high
%     if (rate > data.thresh(4)) && (data.in.notch.mps ~= 1) % 1 is OUT, 2 is IN
%         out.trip(4) = 1;
%         if ~data.bypass(4)
%             if ~tripped
%                 tripped = 1;
%                 message = sprintf('Notch collimator in and FACET rate > %.1d', data.thresh(4));
%             end
%         end
%     end

%     % trip if Kraken mirror is not OUT 
%     if ~(data.in.mirror == 1) && (rate > data.thresh(5))
%         out.trip(5) = 1;
%         if ~data.bypass(5)
%             if ~tripped
%                 tripped = 1;
%                 message = 'Kraken Laser mirror is not OUT';
%             end
%         end
%     end

    % trip if rate with waist at a forbidden location
    if ~isnan(data.in.waist.exclude)
        % get forbidden location list
        t = textscan(data.in.waist.exclude, '%s');
        exclude = t{1};        
        if ~isempty(exclude)
            
            % match excluded locations against current waist
            matchx = ~cellfun(@isempty, regexpi(data.in.waist.xname, regexptranslate('wildcard', exclude)));
            matchy = ~cellfun(@isempty, regexpi(data.in.waist.xname, regexptranslate('wildcard', exclude)));

            if any(matchx) || any(matchy)
                if rate > data.thresh(6)
                    out.trip(6) = 1;
                    if ~data.bypass(6)
                        if ~tripped
                            tripped = 1;
                            message = 'X or Y waist at forbidden location';
                        end
                    end
                end
            end
            
        end
    end
%     % trip if IPOTR1 is moving & not 2-9
%     if ~(data.in.otrmoving == 0) && ~(data.in.dump) && (rate > data.thresh(7))
%         out.trip(7) = 1;
%         if ~data.bypass(7)
%             if ~tripped
%                 tripped = 1;
%                 message = 'IPOTR1 is moving with beam in Sec 20';
%             end
%         end
%     end

    
    % 1553 newMPS beam OK states
    newmps.flag = [
     1  1;  %     'LI20:MPS:7:EKIC_ENB';
     1  1;  %     'LI20:MPS:6:HLAM_ENB';
     1  1;  %     'LI20:MPS:13:FV1986';
     1  1;  %     'LI20:MPS:13:VALV3068';
     1  1;  %     'LI20:MPS:13:VALV3076';
     1  1;  %     'LI20:MPS:13:VALV3160';
     1  1;  %     'LI20:MPS:13:VALV3250';
     1  1;  %     'LI20:MPS:13:HV_STATS';
     1  1;  %     'LI20:MPS:13:HCOL2072';
     1  2;  %     'LI19:MPS:2:BLM_STAT';
     1  2;  %     'LI20:MPS:12:PHOS2042';
     1  2;  %     'LI20:MPS:14:KCHAMBER';
     1  2;  %     'LI20:MPS:15:OTRS3180';
     1  1;  %     'LI20:MPS:14:DUMPSHTR';
     1  1;  %     'LI20:MPS:14:EPS_SUM';
     1  2;  %     'LI20:MPS:15:BEWINDOW';
     1  2;  %     'LI20:MPS:15:BLEN3014';
    ];
    nstates = size(newmps.flag, 2);
% 
%     % trip if any AP20 "should be out" items are NOT out
%     newmps.stat = repmat(data.in.newmps, 1, nstates);
%     newmps.ok = any(newmps.stat == newmps.flag, 2);
%     if ~all(newmps.ok)
%         out.trip(8) = 1;
%         if ~data.bypass(8)
%             if ~tripped
%                 tripped = 1;                
%                 message = char(strcat({'NewMPS AP20:  '}, pvs.in.newmps(~newmps.ok)));
%             end
%         end
%     end
%     
    
end
    
function disp_msg(strpv, msg)
    % stupid function to copy log messages to PV
    disp_log(msg);
    lcaPutSmart(strpv, double(int8(msg)));    
end

function lasersafe = check_laser(pvs, data)

tols = 1e3 * [ ...
    1;
    1;
    1;
    1;
    .001;
    1;
    1;
    ];      % 1 mm tolerance for "out", oven ctrl is mm

if ~any(isnan(data.laser.motr)) % trip if can't talk to motors
    issoft = abs(data.laser.motr - data.laser.softlims) < tols;
    ishard = data.laser.hardlims;
    isout = issoft | ishard;
else
    % trip if can't talk to motors
    %disp_log('Some IP area motor returned NaN');
    isout = false(size(data.laser.motr));
end

lcaPutSmart(pvs.laser.states, double(isout));

use = ~logical(data.laser.bypass);
if ~all(isout(use))
    lasersafe = 0;
else
    lasersafe = 1;
end

end