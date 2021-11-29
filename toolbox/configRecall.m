function config = configRecall(time)
%
%
% Returns machine configuration parameters archived at specified time. If
% time is absent it returns present machine configuration
%
% Example:  [config] = configRecall(now -1) will return a structure
% with a various machine parameters from one day previous to the present time.
%
% About 10 seconds worth of archived data is averaged.
% time can be either, datenum, datestr, or datevec format09-Dec-2014 08:11:21


if nargin==0
    time = now;
end

% convert datenum or datevec to datestr
time = datestr(time);

% set up time interval for archive recall
starttime = datenum(time);
stoptime = starttime + 10/(24*3600); % need a time window to be sure there is an archived point.
stoptime =datestr(stoptime);
starttime = datestr(time); % convert back to datestr format

% Electron Beam
electronData ={...
'beamEnergyH', 'BEND:DMPH:400:BDES' ;...
'beamEnergyS', 'BEND:DMPS:400:BDES' ;...
'vernier',    'SIOC:SYS0:ML00:AO289';...
'BC2peakCurrentSetpoint',    'FBCK:FB04:LG01:S5DES';...
'BC1peakCurrentSetpoint', 'FBCK:FB04:LG01:S3DES';... 
% 'BC2peakCurrentReadback', 'BLEN:LI24:886:BIMAX';...
% 'BC1peakCurrentReadback', 'BLEN:LI21:265:AIMAX';... 
'chargeGun_nC', 'SIOC:SYS0:ML00:AO470';...
'chargeBC1_nC', 'BPMS:SYS0:2:QANN';...
'L0Bphase',  'ACCL:IN20:400:L0B_S_PV';...
'L0Bamplitude',  'ACCL:IN20:400:L0B_S_AV';...
'TCAV0phase', 'TCAV:IN20:490:TC0_S_PV';...
'TCAV0amplitude', 'TCAV:IN20:490:TC0_S_AV';...
'L1Sphase', 'ACCL:LI21:1:L1S_PDES';...
'L1Samplitude', 'ACCL:LI21:1:L1S_ADES';...
'L1Xphase', 'ACCL:LI21:180:L1X_PDES';...
'L1Xamplitude', 'ACCL:LI21:180:L1X_ADES';...
'L1XfeedbackOffsetX', 'FBCK:FB01:TR03:S1DES';...
'xltu250',  'BPMS:LTUH:250:XCUH1H';...
'xltu450',   'BPMS:LTUH:450:XCUH1H';...
'xltu235',  'BPMS:LTUS:235:XCUS1H';...
'xltu370', 'BPMS:LTUS:370:XCUS1H';...
'emittanceOTR2x', 'SIOC:SYS0:ML00:AO493';...
'emittanceOTR2y', 'SIOC:SYS0:ML00:AO494'};

electronPV = electronData(:,2);
[~, v] = history(electronPV, {starttime; stoptime}, 'verbose',0);

for q=1:length(electronPV)
    fn = electronData{q,1};
    value = mean(v{q});
    config.electron.(fn) = value ;
end

laserData = {...
    'LaserHeaterEnergy', 'LASR:IN20:196:PWR1H';...
    'VCC_x', 'CAMR:IN20:186:X';...
    'VCC_xrms', 'CAMR:IN20:186:XRMS';...
    'VCC_y', 'CAMR:IN20:186:Y';...
    'VCC_yrms', 'CAMR:IN20:186:YRMS';...
    'IRIS_x', 'IRIS:LR20:118:MOTR_X';...
    'IRIS_angle', 'IRIS:LR20:118:MOTR_ANGLE';...
    'irisPositionNumber', 'IRIS:LR20:118:CONFG_SEL'};

laserPV = laserData(:,2);
[~, v] = history(laserPV, {starttime; stoptime}, 'verbose',0);

for q=1:length(laserData)
    fn = laserData{q,1};
    value = mean(v{q});
    config.laser.(fn) = value ;
end

% Undulator and Seeding
config.undulator = struct(...
'taper', taperRecall(time),...
'hxrss', HXRSSrecall(time) );


% Get undulator  K values
KSpv = meme_names('name', 'USEG:UNDS%:KAct');
KHpv = meme_names('name', 'USEG:UNDH%:KAct');
config.undulator.KSprofile =  lcaGetSmart(KSpv);
config.undulator.KHprofile =  lcaGetSmart(KHpv);

% Undulator correctors
% for q=1:33
%     pvx{q} = sprintf('XCOR:UND1:%d80:BACT',q);
%     pvy{q} = sprintf('YCOR:UND1:%d80:BACT',q);
% end
% pvx = pvx';
% pvy = pvy';


% Photon
photonData = {...
'photonEnergyH',     'SIOC:SYS0:ML00:AO627';...
'photonEnergyS',     'SIOC:SYS0:ML00:AO628';...
'pulseEnergy1_mJ',   'GDET:FEE1:241:ENRC';...
'pulseEnergy2_mJ',   'GDET:FEE1:242:ENRC';...
'pulseEnergy3_mJ',   'GDET:FEE1:361:ENRC';...
'pulseEnergy4_mJ',   'GDET:FEE1:362:ENRC';...
        'solid', 'SATT:FEE1:320:RACT';...
        'gas',   'GATT:FEE1:310:R_ACT';...
        'position', 'STEP:FEE1:422:MOTR.RBV';...
'angle',  'STEP:FEE1:421:MOTR.RBV'};

photonPV = photonData(:,2);
[~, v] = history(photonPV, {starttime; stoptime}, 'verbose',0);

for q=1:length(photonData)
    fn = photonData{q,1}; %field name
    value = mean(v{q});
    config.photon.(fn) = value ;
end

% Dogleg correctors
xcorDL2SXRdata = {
    'XCDL13',        'XCOR:LTUS:228:BACT';
    'XCDL15',        'XCOR:LTUS:296:BACT';
    'XCDL17',        'XCOR:LTUS:368:BACT';
    'XCDL19',        'XCOR:LTUS:448:BACT'};

xcorDL2SXRPV = xcorDL2SXRdata(:,2);
[~, v] = history(xcorDL2SXRPV, {starttime; stoptime}, 'verbose',0);

config.xcorDL2SXR.BACT=[];
for q=1:length(xcorDL2SXRPV)
%     fn = xcorDL2SXRdata{q,1};
    value = mean(v{q});
    config.xcorDL2SXR.BACT = [config.xcorDL2SXR.BACT value] ;
end

xcorDL2HXRdata = {
    'XCQT12', 'XCOR:LTUH:288:BACT'
    'XCDL2',  'XCOR:LTUH:348:BACT'
    'XCQT22', 'XCOR:LTUH:388:BACT'
    'XCDL3',  'XCOR:LTUH:448:BACT'};

xcorDL2HXRPV = xcorDL2HXRdata(:,2);
[~, v] = history(xcorDL2HXRPV, {starttime; stoptime}, 'verbose',0);

config.xcorDL2HXR.BACT=[];
for q=1:length(xcorDL2HXRPV)
%     fn = xcorDL2HXRdata{q,1};
    value = mean(v{q});
    config.xcorDL2HXR.BACT = [config.xcorDL2HXR.BACT value] ;
end
