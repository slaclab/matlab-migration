function s_name = E200_Dispersion_Scan(E_range_low, E_range_high, n_step, n_shot, cam_config)
% E200 Dispersion Scan:
%   E_range_low: Energy relative to current set point  (MeV)
%   E_range_high: Energy relative to current set point (MeV)
%   n_step: Number of energy points
%   n_shot: Number of shots per step
%   cam_config: Usually #6

% AIDA-PVA imports
aidapva;

par = E200_Param(); % Load default parameters
if nargin < 4
   par.camera_config = 6;
else
    par.camera_config = cam_config;
end

par.save_facet = 0;
par.save_E200 = 0;
par.aida_daq = 1;
par.bpmd = 'NDRFACET';
par.n_shot = n_shot;
par.knob = 'SCAVENGY.MKB';
par.comt_str = ['E200 dispersion scan, using function "SCAVENGY.MKB",\nfrom ' num2str(E_range_low) ' to ' num2str(E_range_high) '.\n' num2str(n_step) ' steps.'];

% first figure out a scan range
disp('Calculating scan range...');
fast.name = {'EP01:AMPL:171:VDES' 'EP01:AMPL:181:VDES';
             'EP01:AMPL:171:VACT' 'EP01:AMPL:181:VACT'};
klys.name = reshape(model_nameRegion('KLYS', {'LI17' 'LI18'}), 8, 2);
sbst.name = reshape(model_nameRegion('SBST', {'LI17' 'LI18'}), 1, 2);
klys.phas = reshape(control_phaseGet(klys.name), 8, 2);
sbst.phas = reshape(control_phaseGet(sbst.name), 1, 2);
fast.pdes = reshape(lcaGetSmart(fast.name(2,:)), 1, 2);
fast.phas = reshape(lcaGetSmart(fast.name(1,:)), 1, 2);
[act, d, d, d, d, enld] = control_klysStatGet(klys.name);
klys.enld = reshape(enld, 8, 2);
klys.act  = reshape(bitget(act, 1), 8, 2);
emax = zeros(size(klys.phas));
klys.pact = klys.phas + repmat(sbst.phas, 8, 1) + repmat(fast.phas, 8, 1);
klys.pmax = klys.phas + repmat(sbst.phas, 8, 1);
klys.ampl = klys.act .* klys.enld .* cosd(klys.pact);
egain = sum(sum(klys.ampl));
emax  = sum(sum(klys.enld .* klys.act .* cosd(klys.pmax)));
erange = [egain + E_range_low, egain + E_range_high];
prange = -acosd(erange / emax)

% check that phases are reasonable
if ~all(isreal(prange)) || any(isnan(prange)) || any(abs(prange) <= 5)
    errstring = sprintf('Range bad, fast phase shifters = [%.1f %.1f])', prange(1), prange(2));
    return;
end

% store scan range
range = linspace(-diff(prange)/2, diff(prange)/2, n_step);
rangestr = '';
for ix = 1:n_step
    rangestr = [rangestr sprintf('%.1f ', range(ix))];
end

phase_deltas = diff([0 range 0]);

% set up AIDA for knob control
requestBuilder = pvaRequest('MKB:VAL');
requestBuilder.with('MKB', strcat('mkb:', par.knob));

% turn off energy feedbacks
fbpv = {'SIOC:SYS1:ML00:AO060'; 'SIOC:SYS1:ML00:AO084'};
fbstate = lcaGetSmart(fbpv);
lcaPutSmart(fbpv, zeros(size(fbpv)));
disp('Feedbacks off');

scan_info = [];
try
    % iterate over steps
    for ix = 1:n_step

        % set energy here
        disp(['Step ' num2str(ix) '. Setting knob to ' num2str(range(ix))]);
        requestBuilder.set(phase_deltas(ix));
        pause(1.0);
        % calculate energy from phase readback here
        phase(ix, :) = reshape(lcaGetSmart(fast.name), 1, []);  %phase(:, [1:3]) is VDES
        pact = klys.phas + repmat(sbst.phas, 8, 1) + repmat(phase(ix, [1 3]), 8, 1);
        energy(ix) = sum(sum(klys.act .* klys.enld .* cosd(pact))) - egain;
        disp(['Energy is ' num2str(energy(ix),'%0.2f')]);
        % acquire data here
        if ix>1; par.set_print2elog=0; par.increment_save_num=0; par.save_facet=0; par.save_E200=0; par.save_back = 0;end;
        [a, b, c, d, filenames, par_out] = E200_DAQ_2013(par);
        filenames.Control_PV_name = 'SCAVENGY.MKB';  % ***temp
        filenames.Control_PV = energy(ix);
        [filenames.save_path] = deal(par_out.save_path);
        scan_info = [scan_info, filenames];
    end
    % restore energy multiknob
    disp('Scan finished. Restoring knob.');
    requestBuilder.set(phase_deltas(end));

catch err
    % turn feedbacks back on
    display(err);
    disp('Scan failed. Restoring feedbacks.');
    lcaPutSmart(fbpv,fbstate);
end

% turn feedbacks back on
lcaPutSmart(fbpv,fbstate);

disp('Acquisition finished.');
s_name = [par_out.save_path{1} '/' par_out.save_name(1:11) 'scan_info'];
save(s_name, 'scan_info');

disp('Analyzing dispersion at sYAG. . .');
cam_name = par_out.cams{1,1};
DISP_ANA(s_name,0,1,0,cam_name);
