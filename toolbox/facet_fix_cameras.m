% profs = {'SYAG' 'USOTR' 'IPOTR1' 'IPOTR2' 'IP2A' 'IP2B'};
% tic
profs = {...
    'SYAG'  , ...
    'USOTR' , ...
    'IPOTR1', ...
    'IP2A'  , ...
    'IP2B'  , ...
    };
roots = model_nameConvert(profs, 'EPICS')';

tchan = {'0' '1' '2'}';
tevent = {'1' '2' '3' '4' '5'}';

pvs.tdes = strcat('TRIG:LI20:PM21:', tchan, ':TDES');
pvs.tctl = strcat('TRIG:LI20:PM21:', tchan, ':TCTL');

pvs.trig233 = strcat('EVR:LI20:PM21:EVENT1CTRL.OUT', tchan);
pvs.trig213 = strcat('EVR:LI20:PM21:EVENT2CTRL.OUT', tchan);
pvs.trig214 = strcat('EVR:LI20:PM21:EVENT3CTRL.OUT', tchan);
pvs.trig211 = strcat('EVR:LI20:PM21:EVENT4CTRL.OUT', tchan);
pvs.trig53  = strcat('EVR:LI20:PM21:EVENT5CTRL.OUT', tchan);

pvs.irq     = strcat('EVR:LI20:PM21:EVENT', tevent, 'CTRL.VME');

tdes = -30000;
tctl = 1;

datatype = 1; % 1 is Uint16, 0 is Uint8
pvs.datatype = strcat(roots, ':DataType');
old.datatype = lcaGetSmart(pvs.datatype);
lcaPutSmart(pvs.datatype, repmat(datatype, [numel(roots) 1]));

exposure = 50e-6; % nate likes 50 us
pvs.exposure = strcat(roots, ':AcquireTime');
old.exposure = lcaGetSmart(pvs.exposure);
lcaPutSmart(pvs.exposure, repmat(exposure, [numel(roots) 1]));

triggermode = 1; % 1 is "Sync in 1"
pvs.triggermode = strcat(roots, ':TriggerMode');
old.triggermode = lcaGetSmart(pvs.triggermode);
lcaPutSmart(pvs.triggermode, repmat(triggermode, [numel(roots) 1]));

gain = 1; % soft gain = 1
pvs.gain = strcat(roots, ':Gain');
old.gain = lcaGetSmart(pvs.gain);
lcaPutSmart(pvs.gain, repmat(gain, [numel(roots) 1]));
% toc
acquisition = 1; % 1 is "Acquire"
pvs.acquisition = strcat(roots, ':Acquisition');
old.acquisition = lcaGetSmart(pvs.acquisition);
lcaPutSmart(pvs.acquisition, repmat(acquisition, [numel(roots) 1]));
% toc
old.irq = lcaGetSmart(pvs.irq);
lcaPutSmart(pvs.irq, ones(size(pvs.irq)));
% toc
% 
% % make only one of these true
% trig233 = 0;  % positrons
% trig213 = 1;  % FACET PM  <- should be the right thing
% trig214 = 0;
% trig211 = 0;
% trig53  = 0;  % TS5 10 Hz
% 
% trigs = [trig233; trig213; trig214; trig211; trig53];
% 
% old.tdes = lcaGetSmart(pvs.tdes);
% lcaPutSmart(pvs.tdes, repmat(tdes, [numel(pvs.tdes) 1]));
% old.tctl = lcaGetSmart(pvs.tctl);
% lcaPutSmart(pvs.tctl, repmat(tctl, [numel(pvs.tctl) 1]));
% 
% old.trig233 = lcaGetSmart(pvs.trig233);
% lcaPutSmart(pvs.trig233, repmat(trig233, [numel(pvs.trig233) 1]));
% old.trig213 = lcaGetSmart(pvs.trig213);
% lcaPutSmart(pvs.trig213, repmat(trig213, [numel(pvs.trig213) 1]));
% old.trig214 = lcaGetSmart(pvs.trig214);
% lcaPutSmart(pvs.trig214, repmat(trig214, [numel(pvs.trig214) 1]));
% old.trig211 = lcaGetSmart(pvs.trig211);
% lcaPutSmart(pvs.trig211, repmat(trig211, [numel(pvs.trig211) 1]));
% old.trig53 = lcaGetSmart(pvs.trig53);
% lcaPutSmart(pvs.trig53, repmat(trig53, [numel(pvs.trig53) 1]));
% old.irq = lcaGetSmart(pvs.irq);
% lcaPutSmart(pvs.irq, trigs);


!/usr/local/facet/tools/script/set_triggers.sh EBEAM 233
% toc