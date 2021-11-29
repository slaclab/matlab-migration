function facet_li20() 
% FACET orbit and energy feedback.
% N Lipkowitz, SLAC

% Deprecated 12/11/13 

% 
% %% basic initialization
% mf = strcat(mfilename, '.m');
% disp_log(strcat(mf, {' starting, ver 1.9 11/27/2013'}));
% debug = 0;
% 
% %% plot setup
% plotfile = '/home/fphysics/nate/fit.png';
% doplot = 0;
% f = figure;
% set(f, 'Visible', 'off');
% 
% %% start watchdog
% 
% pvs.watchdog = {'SIOC:SYS1:ML00:AO100'};
% disp_log(strcat({'Starting watchdog on '}, pvs.watchdog));
% W = watchdog(char(pvs.watchdog), 1, mf);
% switch get_watchdog_error(W)
%     case 1
%         disp_log(strcat({'Another '}, mf, {' is running - exiting'}));
%         return;
%     case 2
%         disp_log(strcat({'Error reading/writing '}, pvs.watchdog, {' - exiting'}));
%         return;
%     otherwise
%         disp_log(strcat({'Watchdog started on '}, pvs.watchdog));
% end
% 
% %% define which devices to be used
% 
% % BPM PV roots here
% conf.bpms = { ...
%     'BPMS:LI19:201'; ...
%     'BPMS:LI19:301'; ...    
%     'BPMS:LI19:401'; ...
%     'BPMS:LI19:501'; ...
%     'BPMS:LI19:601'; ...
%     'BPMS:LI19:701'; ...
%     'BPMS:LI19:801'; ...
%     'BPMS:LI19:901'; ...
%     'BPMS:LI20:2050'; ...
%     'BPMS:LI20:2147'; ...
%     'BPMS:LI20:2223'; ...
%     'BPMS:LI20:2235'; ...
%     'BPMS:LI20:2245'; ...
%     'BPMS:LI20:2261'; ...
%     'BPMS:LI20:2278'; ...
%     'BPMS:LI20:2360'; ...
%     'BPMS:LI20:2445'; ...
%     'BPMS:LI20:3013'; ...
% %     'BPMS:LI20:3036'; ...
% %     'BPMS:LI20:3101'; ...
% %     'BPMS:LI20:3120'; ...
% %     'BPMS:LI20:3156'; ...
% %     'BPMS:LI20:3265'; ...
% %     'BPMS:LI20:3315'; ...
% %     'BPMS:LI20:3340'; ...
%     };
% 
% % correctors
% conf.xcors = { ...
%     'LI19:XCOR:302'; ...
%     'LI19:XCOR:602'; ...
%     };
% 
% conf.ycors = { ...
%     'LI19:YCOR:303'; ...
%     'LI19:YCOR:603'; ...
%     };
% 
% % phase shifters
% conf.paus = { ...
%     'EP01:AMPL:171'; ...
%     'EP01:AMPL:181'; ...
%     };
% 
% % multiknobs
% conf.mkbs = { ...
%     'FACET_LAUNCH_X.MKB'; ...
%     'FACET_LAUNCH_XP.MKB'; ...
%     'FACET_LAUNCH_Y.MKB'; ...
%     'FACET_LAUNCH_YP.MKB'; ...
%     'SCAVENGY.MKB'; ...
%     };
% 
% % limits
% % conf.limits.xcors = [ ...
% %     -0.01   0.01; ...
% %     -0.01   0.01; ...
% %     ];
% % 
% % conf.limits.ycors = [ ...
% %     -0.01   0.01; ...
% %     -0.01   0.01; ...
% %     ];
% 
% % limit correctors to 95% of +/- BMAX
% conf.limits.xcors = control_deviceGet(conf.xcors, 'BMAX') * [-0.95 0.95];
% conf.limits.ycors = control_deviceGet(conf.ycors, 'BMAX') * [-0.95 0.95];
% 
% conf.limits.mkbs = [
%     -0.5      0.5; ...
%     -0.05      0.05; ...
%     -0.5      0.5; ...
%     -0.05      0.05; ...  
%     -175    0; ...
%     ];
% 
% conf.fitpoint = {'BPMS:LI19:901'};
% 
% %% set up PV struct
% pvs.meas.x      = strcat(conf.bpms, ':X57');
% pvs.meas.y      = strcat(conf.bpms, ':Y57');
% pvs.meas.tmit   = strcat(conf.bpms, ':TMIT57');
% pvs.meas.stat   = strcat(conf.bpms, ':STAT57');
% 
% for ix = 1:numel(conf.bpms)
%     pvs.meas.use(ix, 1) = cellstr(script_setupPV(150 + ix, strcat({'Use '}, conf.bpms(ix)),   'bool', 0, mf, 'SYS1', 'ML00'));
% end
% 
% pvs.acts.xcors  = strcat(conf.xcors, ':BACT');
% pvs.acts.ycors  = strcat(conf.ycors, ':BACT');
% pvs.acts.paus   = strcat(conf.paus, ':VACT');
% 
% pvs.ctrl.global.enable          = script_setupPV('SIOC:SYS1:ML00:AO052', 'Global Enable',       'bool', 0, mf);
% pvs.ctrl.global.delay           = script_setupPV('SIOC:SYS1:ML00:AO053', 'Loop wait time',      's',    1, mf);
% pvs.ctrl.global.gain            = script_setupPV('SIOC:SYS1:ML00:AO054', 'Global gain',         'egu',  3, mf);
% pvs.ctrl.global.tmitcut         = script_setupPV('SIOC:SYS1:ML00:AO055', 'Global TMIT cut',     'x 1e9 e-', 3, mf);
% pvs.ctrl.global.restore_acts    = script_setupPV('SIOC:SYS1:ML00:AO056', 'Restore Actuators',   'bool', 0, mf);
% pvs.ctrl.global.update_acts     = script_setupPV('SIOC:SYS1:ML00:AO057', 'Update Act Refs',     'bool', 0, mf);
% pvs.ctrl.global.acquire_gold    = script_setupPV('SIOC:SYS1:ML00:AO171', 'Acquire Gold Orbit',  'bool', 0, mf);
% pvs.ctrl.global.navg            = script_setupPV('SIOC:SYS1:ML00:AO172', 'Avg N pulses',        'num', 0, mf);
% 
% pvs.ctrl.act_ref(1,:)      = script_setupPV('SIOC:SYS1:ML00:AO180', [conf.xcors{1} ' act ref'], 'kG-m', 4, mf);
% pvs.ctrl.act_ref(2,:)      = script_setupPV('SIOC:SYS1:ML00:AO181', [conf.xcors{2} ' act ref'], 'kG-m', 4, mf);
% pvs.ctrl.act_ref(3,:)      = script_setupPV('SIOC:SYS1:ML00:AO182', [conf.ycors{1} ' act ref'], 'kG-m', 4, mf);
% pvs.ctrl.act_ref(4,:)      = script_setupPV('SIOC:SYS1:ML00:AO183', [conf.ycors{2} ' act ref'], 'kG-m', 4, mf);
% pvs.ctrl.act_ref(5,:)      = script_setupPV('SIOC:SYS1:ML00:AO184', 'SCAVENGY act ref',    'degS', 2, mf);
% 
% pvs.diags.beam_energy           = script_setupPV('SIOC:SYS1:ML00:AO069', 'LEMG EEND',           'GeV', 3, mf);
% pvs.diags.status                = script_setupPV('SIOC:SYS1:ML00:AO059', 'Feedback status',     'none', 0, mf);
% pvs.diags.scavengy_gain         = script_setupPV('SIOC:SYS1:ML00:AO058', 'SCAVENGY E gain',     'MeV', 2, mf);
% 
% pvs.state.x     = script_setupPV('SIOC:SYS1:ML00:AO070', 'LI20 X position', 'mm',   3, mf);
% pvs.state.xp    = script_setupPV('SIOC:SYS1:ML00:AO071', 'LI20 X angle',    'mrad', 3, mf);
% pvs.state.y     = script_setupPV('SIOC:SYS1:ML00:AO072', 'LI20 Y position', 'mm',   3, mf);
% pvs.state.yp    = script_setupPV('SIOC:SYS1:ML00:AO073', 'LI20 Y angle',    'mrad', 3, mf);
% pvs.state.e     = script_setupPV('SIOC:SYS1:ML00:AO074', 'LI20 Energy',     'MeV',  3, mf);
% 
% pvs.val.mkbs(1,:) = script_setupPV('SIOC:SYS1:ML00:AO095', strcat(conf.mkbs(1), {' val'}), 'mm', 3, mf);
% pvs.val.mkbs(2,:) = script_setupPV('SIOC:SYS1:ML00:AO096', strcat(conf.mkbs(2), {' val'}), 'mrad', 3, mf);
% pvs.val.mkbs(3,:) = script_setupPV('SIOC:SYS1:ML00:AO097', strcat(conf.mkbs(3), {' val'}), 'mm', 3, mf);
% pvs.val.mkbs(4,:) = script_setupPV('SIOC:SYS1:ML00:AO098', strcat(conf.mkbs(4), {' val'}), 'mrad', 3, mf);
% pvs.val.mkbs(5,:) = script_setupPV('SIOC:SYS1:ML00:AO099', strcat(conf.mkbs(5), {' val'}), 'degS', 3, mf);
% 
% pvs.cmd.mkbs(1,:) = script_setupPV('SIOC:SYS1:ML00:AO090', strcat(conf.mkbs(1), {' cmd'}), 'mm', 3, mf);
% pvs.cmd.mkbs(2,:) = script_setupPV('SIOC:SYS1:ML00:AO091', strcat(conf.mkbs(2), {' cmd'}), 'mrad', 3, mf);
% pvs.cmd.mkbs(3,:) = script_setupPV('SIOC:SYS1:ML00:AO092', strcat(conf.mkbs(3), {' cmd'}), 'mm', 3, mf);
% pvs.cmd.mkbs(4,:) = script_setupPV('SIOC:SYS1:ML00:AO093', strcat(conf.mkbs(4), {' cmd'}), 'mrad', 3, mf);
% pvs.cmd.mkbs(5,:) = script_setupPV('SIOC:SYS1:ML00:AO094', strcat(conf.mkbs(5), {' cmd'}), 'degS', 3, mf);
% 
% pvs.setp.x      = script_setupPV('SIOC:SYS1:ML00:AO075', 'LI20 X setpoint',     'mm',   3, mf);
% pvs.setp.xp     = script_setupPV('SIOC:SYS1:ML00:AO076', 'LI20 XP setpoint',    'mrad', 3, mf);
% pvs.setp.y      = script_setupPV('SIOC:SYS1:ML00:AO077', 'LI20 Y setpoint',     'mm',   3, mf);
% pvs.setp.yp     = script_setupPV('SIOC:SYS1:ML00:AO078', 'LI20 YP setpoint',    'mrad', 3, mf);
% pvs.setp.e      = script_setupPV('SIOC:SYS1:ML00:AO079', 'LI20 E setpoint',     'MeV',  3, mf);
% 
% pvs.ctrl.enable.x   = script_setupPV('SIOC:SYS1:ML00:AO080', 'LI20 X enable',   'bool', 0, mf);
% pvs.ctrl.enable.xp  = script_setupPV('SIOC:SYS1:ML00:AO081', 'LI20 XP enable',  'bool', 0, mf);
% pvs.ctrl.enable.y   = script_setupPV('SIOC:SYS1:ML00:AO082', 'LI20 Y enable',   'bool', 0, mf);
% pvs.ctrl.enable.yp  = script_setupPV('SIOC:SYS1:ML00:AO083', 'LI20 YP enable',  'bool', 0, mf);
% pvs.ctrl.enable.e   = script_setupPV('SIOC:SYS1:ML00:AO084', 'LI20 E enable',   'bool', 0, mf);
% 
% pvs.ctrl.gain.x     = script_setupPV('SIOC:SYS1:ML00:AO085', 'LI20 X gain',     'a.u.', 2, mf);
% pvs.ctrl.gain.xp    = script_setupPV('SIOC:SYS1:ML00:AO086', 'LI20 XP gain',    'a.u.', 2, mf);
% pvs.ctrl.gain.y     = script_setupPV('SIOC:SYS1:ML00:AO087', 'LI20 Y gain',     'a.u.', 2, mf);
% pvs.ctrl.gain.yp    = script_setupPV('SIOC:SYS1:ML00:AO088', 'LI20 YP gain',    'a.u.', 2, mf);
% pvs.ctrl.gain.e     = script_setupPV('SIOC:SYS1:ML00:AO089', 'LI20 E gain',     'a.u.', 2, mf);
% 
% pvs.rate            = 'EVNT:SYS1:1:BEAMRATE';
% 
% %% set up array PV struct
% 
% arraypvs.fmat       = 'SIOC:SYS1:ML00:FWF01';
% arraypvs.gmat       = 'SIOC:SYS1:ML00:FWF02';
% arraypvs.reforbit   = 'SIOC:SYS1:ML00:FWF03';
% 
% %% initialize matrices (from model, matrix PVs will step on this later)
% 
% [model.fmat, model.gmat] = get_model_matrices(conf);
% 
% % save matrices to array PVs
% lcaPutSmart(arraypvs.fmat, reshape(model.fmat, 1, []));
% lcaPutSmart(arraypvs.gmat, reshape(model.gmat, 1, []));
% 
% %% get twiss and Z locations from model
% 
% [d, model.z.fitpoint, d, model.twiss.fitpoint] = model_rMatGet(conf.fitpoint);
% [d, model.z.xcors, d, model.twiss.xcors] = model_rMatGet(conf.xcors);
% [d, model.z.ycors, d, model.twiss.ycors] = model_rMatGet(conf.ycors);
% [d, model.z.bpms, d, model.twiss.bpms] = model_rMatGet(conf.bpms);
% 
% %% initial acquisition
% 
% [data, ts] = lcaGetStruct(pvs);
% [meas.x, meas.y, meas.tmit, meas.pulseid, meas.stat] = control_bpmAidaGet(conf.bpms, 1, '57');
% 
% %% main loop
% while 1
%         
% %% pause and increment watchdog
%     
%     pause(data.ctrl.global.delay);
% 
%     W = watchdog_run(W);
%     switch get_watchdog_error(W)
%         case 0
%             % do nothing, this is OK
%         case 1
%             disp_log(strcat({'Another '}, mf, {' is running - exiting'}));
%             return;
%         case 2
%             disp_log(strcat({'Error reading/writing '}, pvs.watchdog, {' - continuing anyway'}));
%         otherwise
%             disp_log(strcat({'Unexpected watchdog error'}));
%     end    
%     
% %% get data
% 
%     oldts = ts;
%     olddata = data;
%     oldmeas = meas;
%     
%     [data, ts] = lcaGetStruct(pvs);
%     
%     if (data.rate < 1)
%         %disp('no rate');
%         pause(1);
%         continue;
%     end
%     
%     % get BPM data
%     [meas.x, meas.y, meas.tmit, meas.pulseid, meas.stat] = ...
%         control_bpmAidaGet(conf.bpms, data.ctrl.global.navg, '57');
%     avg = structfun(@(x) mean(x, 2), meas, 'UniformOutput', false);
%     outdata = data;
% 
% %% do some error handling    
% 
%     % silly conversion because struct2array doesn't work right for this
%     if any(any(cell2mat(struct2cell(structfun(@(x) isnan(x), meas, 'UniformOutput', false)))))
%         disp_log('Error acquiring BPM measurements');
%         pause(1);
%         continue;
%     end
% 
%     if any(any(cell2mat(struct2cell(structfun(@(x) isnan(x), data.acts, 'UniformOutput', false)))))
%         disp_log('Error acquiring actuators');
%         pause(1);
%         continue;
%     end
% 
%     if any(any(cell2mat(struct2cell(structfun(@(x) isnan(x), data.ctrl.global,  'UniformOutput', false))))) || ...
%        any(any(cell2mat(struct2cell(structfun(@(x) isnan(x), data.ctrl.enable,  'UniformOutput', false))))) || ...
%        any(any(cell2mat(struct2cell(structfun(@(x) isnan(x), data.ctrl.gain,    'UniformOutput', false))))) || ...
%        any(any(cell2mat(struct2cell(structfun(@(x) isnan(x), data.state,        'UniformOutput', false))))) || ...
%        any(any(cell2mat(struct2cell(structfun(@(x) isnan(x), data.setp,         'UniformOutput', false))))) || ...
%        any(any(isnan(data.ctrl.act_ref)))
%         disp_log('Error acquiring control PVs');
%         pause(1);
%         continue;
%     end
%     
% %% update/restore actuators
% 
%     if data.ctrl.global.update_acts
%         [phase, gain] = get_scavengy();
%         refs = [data.acts.xcors; data.acts.ycors; phase];
%         lcaPutSmart(pvs.ctrl.act_ref, refs);    % update reference
%         lcaPutSmart(pvs.ctrl.global.update_acts, 0);    % clear flag
%     end
% 
%     if data.ctrl.global.restore_acts
%         [phase, gain] = get_scavengy();
%         newphase = data.ctrl.act_ref(5) - phase;
%         readback = set_scavengy(newphase);
%         disp_log(strcat({'SCAVENGY restored, readback is: '}, num2str(readback)));
%         cors = set_launch(conf, data.ctrl.act_ref(1:4));
%         disp_log(sprintf('Launch restored, readbacks are %.4f %.4f %.4f %.4f', cors(1), cors(2), cors(3), cors(4)));
%         lcaPutSmart(pvs.ctrl.global.restore_acts, 0);    % clear flag
%         continue
%     end
% 
% 
% %% check for new data
%     
% %     newbpmdata = 
% %     
% %     if ~newbpmdata
% %         continue
% %     else
% %         if debug, disp_log('new data!'); end
% %     end
%     
% %% refresh model and reforbit from PVs
% 
%     if debug, t = datevec(now); end
%     % try getting matrices out of waveform PVs
%     [arraydata, arrayts] = lcaGetSmart(struct2cell(arraypvs));
%     
%     arraydata = arraydata';
%     arrayts = lca2matlabTime(arrayts);
%     
%     if any(any(isnan(arraydata)))
%         disp_log('Error acquiring online matrices and ref orbit');
%     else
%         % only update stored matrices if acquisition was successful
%         model.fmat = reshape(arraydata(1:numel(model.fmat), 1), size(model.fmat));
%         model.gmat = reshape(arraydata(1:numel(model.gmat), 2), size(model.gmat));
%         model.reforbit = reshape(arraydata(1:numel(conf.bpms) * 2, 3), [numel(conf.bpms), 2]);
%     end
% 
%     % get beam energy from LEM group
%     try
%         lemg_eend = aidaget('LEMG:VX00:5//EEND', 'doublea');
%     catch
%         disp_log('Aidaget LEMG EEND failed');
%     end
%     model.energy = 1e3 * lemg_eend{2};  % in MeV
%     outdata.diags.beam_energy = lemg_eend{2};  % in GeV
%     
%     if debug, disp_log(strcat({'Model refresh took '}, num2str(etime(datevec(now), t)), {' seconds.'})); end
% 
% 
% 
% %% flag valid data, bail out if not enough BPMs
% 
%     goodbpms = find(all(meas.tmit >= (data.ctrl.global.tmitcut * 1e9), 2) & all(meas.stat,2))';
%     usebpms = intersect(goodbpms, find(data.meas.use)');
%     %usebpms = intersect(goodbpms, conf.fitbpms);
%     nousebpms = setdiff(goodbpms, usebpms);
%     badbpms = setdiff(1:numel(conf.bpms), goodbpms);
% 
%     if numel(usebpms) < 5
%         if debug
%             disp_log('not enough good BPMs to get a reasonable fit');        
%         end
%         continue
%     end
%     
% %% save reference orbit
% 
%     if data.ctrl.global.acquire_gold
%         disp_log('Acquiring gold orbit...');
%         [x, y, tmit, pulseid, stat] = control_bpmAidaGet(conf.bpms, 30, '57');
%         xmean = mean(x, 2);
%         ymean = mean(y, 2);
%         model.reforbit = [xmean, ymean];
%         lcaPutSmart(arraypvs.reforbit, reshape(model.reforbit, 1, []));
%         setpoint_pvs = struct2array(pvs.setp)';
%         lcaPutSmart(setpoint_pvs, zeros(size(setpoint_pvs)));
%         lcaPutSmart(pvs.ctrl.global.acquire_gold, 0);
%         disp_log(strcat({'Gold orbit acquired'}));
%         continue
%     end
% 
% 
% %% do the actual orbit fitting
%     if debug, t = datevec(now); end
%     r1s = model.fmat(1:numel(conf.bpms),:);
%     r3s = model.fmat((numel(conf.bpms) + 1):end, :);
%     
%     try
%         fitok = 1;
%         [xfit, yfit, p, dp, chisq, q, v] = xy_traj_fit( ...
%             avg.x(usebpms)', 1,                    avg.y(usebpms)', 1, ...                   % orbit to fit
%             model.reforbit(usebpms, 1)',           model.reforbit(usebpms, 2)', ...           % ref orbit
%             r1s(usebpms, :), r3s(usebpms, :));                                                % r's for fitting
%     catch
%         fitok = 0;
%         disp_log('Orbit fit failed :(');
%         %continue
%     end
%     
%     if fitok
%         p(5) = p(5) * 1e-3 * model.energy;  % convert dE/E from fit (parts per thousand to MeV)
%         outdata.state = cell2struct(num2cell(p), {'x', 'xp', 'y', 'yp', 'e'}, 2);         
%     else
%         %continue
%     end 
%     if debug, disp_log(strcat({'Fitting took '}, num2str(etime(datevec(now), t)), {' seconds.'})); end
% 
% %% do plotting if doplot is set
% 
%     if debug, t = datevec(now); end
%     if doplot
%         % plot X
%         subplot(3, 1, 1);
%         cla('reset');  hold all;  
%         if fitok, plot(model.z.fitpoint, outdata.state.x, '*k'), end
%         if ~isempty(usebpms), stem(model.z.bpms(usebpms), meas.x(usebpms) - model.reforbit(usebpms, 1), 'og'), end
%         if ~isempty(nousebpms), stem(model.z.bpms(nousebpms), meas.x(nousebpms) - model.reforbit(nousebpms, 1), 'ok'), end
%         if ~isempty(badbpms), stem(model.z.bpms(badbpms), meas.x(badbpms) - model.reforbit(badbpms, 1), 'or'), end
%         if fitok, plot(model.z.bpms(usebpms), xfit, '--b'), end
%         %ylim(gca, [floor(min([meas.x(usebpms) - model.reforbit(usebpms, 1); xfit'])), ...
%         %           ceil(max([meas.x(usebpms) - model.reforbit(usebpms, 1); xfit']))]);
%         line(repmat(model.z.fitpoint, 1, 2), ylim(gca), 'Color', 'b', 'LineStyle', ':');
%         title(strcat({'LI20 DIFF Orbit fit '}, datestr(now)));
%         ylabel('X orbit [mm]');
% 
%         % plot Y
%         subplot(3, 1, 2);
%         cla('reset');  hold all;
%         if fitok, plot(model.z.fitpoint, outdata.state.y, '*k'), end
%         if ~isempty(usebpms), stem(model.z.bpms(usebpms), meas.y(usebpms) - model.reforbit(usebpms, 2), 'og'), end
%         if ~isempty(nousebpms), stem(model.z.bpms(nousebpms), meas.y(nousebpms) - model.reforbit(nousebpms, 2), 'ok'), end
%         if ~isempty(badbpms), stem(model.z.bpms(badbpms), meas.y(badbpms) - model.reforbit(badbpms, 1), 'or'), end
%         if fitok, plot(model.z.bpms(usebpms), yfit, '--b'), end
%         %ylim(gca, [floor(min([meas.y(usebpms); yfit'])), ceil(max([meas.y(usebpms); yfit']))]);
%         line(repmat(model.z.fitpoint, 1, 2), ylim(gca), 'Color', 'b', 'LineStyle', ':');
%         ylabel('Y orbit [mm]');
% 
%         % plot TMIT
%         subplot(3, 1, 3); 
%         cla('reset'); hold all;
%         if ~isempty(usebpms), stem(model.z.bpms(usebpms), meas.tmit(usebpms), 'og'), end
%         if ~isempty(nousebpms), stem(model.z.bpms(nousebpms), meas.tmit(nousebpms), 'ok'), end
%         if ~isempty(badbpms), stem(model.z.bpms(badbpms), meas.tmit(badbpms), 'or'), end
%         %ylim(gca, [0, max(meas.tmit(usebpms)) * 1.05]);
%         line(repmat(model.z.fitpoint, 1, 2), ylim(gca), 'Color', 'b', 'LineStyle', ':');
%         ylabel('TMIT [e-]');
%         
%         % add reforbit timestamp
%         annotation('textbox', [0 0 1 1], 'String', strcat({'Gold orbit acquired '}, datestr(arrayts(3))), ...
%                    'LineStyle', 'none', 'FitBoxToText', 'off');
%                
%         if debug, disp_log(strcat({'Plotting took '}, num2str(etime(datevec(now), t)), {' seconds.'})); end
%             if debug, t = datevec(now); end
%         print(gcf, '-dpng', '-r75', plotfile);
%          if debug, disp_log(strcat({'Printing took '}, num2str(etime(datevec(now), t)), {' seconds.'})); end
%     end
%     
% %% bail out if fitting failed
%     
%     if ~fitok
%         continue
%     end
%     
% %% calculate corrections
% 
%     d_states = reshape(struct2array(outdata.state) - struct2array(data.setp), [], 1);
% %     d_knobs = (model.gmat' \ d_states);
% %     d_bdes = d_thetas(1:(numel(conf.xcors) + numel(conf.ycors))) * 33.356 * model.energy * 1e-3;  % Bp is 33.356*E in kG*m*GeV
% %     d_E = d_states(numel(conf.xcors) + numel(conf.ycors) + 1);
% %     
%     % get current scavengy
%     if debug, t = datevec(now); end
%     try
%         [scavphase, scavgain, scavtotal] = get_scavengy();
%     catch
%         disp_log('Aidaget SCAVENGY phase failed');
%     end
%     if debug, disp_log(strcat({'SCAVENGY get took '}, num2str(etime(datevec(now), t)), {' seconds.'})); end
%     
%     % find new phase
%     new_egain = (scavgain + d_states(5));
%     new_phase = -1 * acosd(new_egain / scavtotal);
%     d_phase = (scavphase - new_phase) * data.ctrl.global.gain * data.ctrl.gain.e;
%     set_phase = scavphase + d_phase;
%     
%     % output diagnostic scav gain
%     outdata.diags.scavengy_gain = scavgain;
%     
%     % set up command data
%     outdata.cmd.mkbs(1) = -1 * d_states(1) * data.ctrl.global.gain * data.ctrl.gain.x;
%     outdata.cmd.mkbs(2) = -1 * d_states(2) * data.ctrl.global.gain * data.ctrl.gain.xp;
%     outdata.cmd.mkbs(3) = -1 * d_states(3) * data.ctrl.global.gain * data.ctrl.gain.y;
%     outdata.cmd.mkbs(4) = -1 * d_states(4) * data.ctrl.global.gain * data.ctrl.gain.yp;
%     outdata.cmd.mkbs(5) = set_phase;
% 
%     % set up val data
%     outdata.val.mkbs(1:4) = d_states(1:4);
%     outdata.val.mkbs(5) = scavphase;
%     
% %% output state diagnostics
% 
%     if debug, t = datevec(now); end
%     lcaPutStruct(pvs.state, outdata.state);
%     lcaPutStruct(pvs.diags, outdata.diags);
%     lcaPutStruct(pvs.cmd, outdata.cmd);
%     lcaPutStruct(pvs.val, outdata.val);
%     if debug, disp_log(strcat({'lcaPut took '}, num2str(etime(datevec(now), t)), {' seconds.'})); end
%         
% %% implement corrections
% 
%     % flag out-of-limits
%     delta_ok = outdata.cmd.mkbs > conf.limits.mkbs(:,1) & outdata.cmd.mkbs < conf.limits.mkbs(:,2);
%     enables = [data.ctrl.enable.x; ...
%                data.ctrl.enable.xp; ...
%                data.ctrl.enable.y; ...
%                data.ctrl.enable.yp; ...
%                data.ctrl.enable.e; ...
%                ];
%            
%     % do correction
%     if data.ctrl.global.enable
%         try
%             if debug, t = datevec(now); end
%             acts = set_mkbs(conf, [outdata.cmd.mkbs(1:4); d_phase], (delta_ok & logical(enables)));
%             if debug, disp_log(strcat({'Multiknob set took '}, num2str(etime(datevec(now), t)), {' seconds.'})); end
%         catch
%             disp_log('Some problem setting multiknobs');
%         end
%     end
%     
% %% end main loop
% end
% 
% end
% 
% %% function to calculate matrices from online model
% 
% function [fmat, gmat] = get_model_matrices(conf)
% 
% model_init('source', 'SLC');
% 
% % get RMATs from fit location -> BPMs
% rmat_f = model_rMatGet(conf.fitpoint, conf.bpms);     
% fmat = reshape(permute(rmat_f([1 3], [1 2 3 4 6], :), [3 1 2]), [], 5);
% 
% % get RMATs from correctors -> fit location
% rmat_g = model_rMatGet([conf.xcors; conf.ycors], conf.fitpoint);
% gmat = eye(5);
% 
% % gmat = [squeeze(rmat_g([1 2 3 4 6], 2, 1:numel(conf.xcors)))';          % XCORs
% %         squeeze(rmat_g([1 2 3 4 6], 4, (numel(conf.xcors) + 1):end))';  % YCORs
% %         0 0 0 0 1];                                                     % Energy knob
%     
% end
% 
% %% get SCAVENGY parameters
% 
% function [phase, gain, total] = get_scavengy()
% 
%     % figure out how strong 17/18 are
%     k17 = strcat({'17-'}, {'1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'});
%     k18 = strcat({'18-'}, {'1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'});
%     
%     p17 = aidaget('AMPL:EP01:171//VDES');
%     p18 = aidaget('AMPL:EP01:181//VDES');
%     
%     phas = control_phaseGet([k17; k18]);
%     fphas = [(phas(1:8) + p17); (phas(9:16) + p18)];
%     
%     [acts, stat, swrd, d, d, enld] = control_klysStatGet([k17; k18], 10);
%     accl = bitget(acts, 1) .* ~bitget(swrd, 4);
%     ampl = enld .* accl .* cosd(fphas);
%     
%     total = sum(enld .* accl .* cosd(phas));
% 
%     phase = mean([-p17; p18]);
%     
%     gain = sum(ampl);
% 
% end
% 
% function new_phase = set_scavengy(phase)
% 
%     persistent d;
%     if isempty(d)
%         aidainit;
%         d = DaObject();
%         d.setParam('MKB', 'MKB:SCAVENGY.MKB');        
%     end
%     
%     try
%         answer = d.setDaValue('MKB//VAL', ...
%         edu.stanford.slac.aida.lib.util.common.DaValue(java.lang.Float(phase)));
%         ansstr = answer.getAsStrings();
%         new_phase = eval(ansstr(2,:));
%     catch
%         disp_log('AIDA error when setting SCAVENGY');
%     end
% 
% end
% 
% %% set LAUNCH parameters
% 
% function bact = set_launch(conf, vals)
%     corlist = [conf.xcors; conf.ycors];
%     bact = control_magnetSet(corlist, vals, 'action', 'TRIM', 'wait', 0);
% end
% 
% function acts = set_mkbs(conf, vals, flags)
% persistent das;
% if isempty(das)    
%     aidainit;
%     for ix = 1:numel(conf.mkbs)
%         das.(strcat('da', num2str(ix))) = DaObject();
%         das.(strcat('da', num2str(ix))).setParam('MKB', strcat('MKB:', conf.mkbs(ix)));
%     end
% end
% 
% acts = zeros(numel(conf.mkbs),2);
% 
% try
%     for ix = 1:numel(conf.mkbs)
%         if flags(ix)
%             
%             answer(ix) = das.(strcat('da', num2str(ix))).setDaValue('MKB//VAL', ...
%                 edu.stanford.slac.aida.lib.util.common.DaValue(java.lang.Float(vals(ix))));
%             ansstr = answer(ix).getAsStrings();
%             acts(ix,:) = eval(ansstr(2,:));
%         end
%     end
% catch
%      disp_log(strcat({'AIDA error when setting '}, conf.mkbs(ix)));
% end
% 
% end