function status = photodiodeStatus()
%
% status = photodiodeStatus()
%
% Returns pv names and current status of parameters related to the
% photodiode. status is a structure with appropriately named fields.


% Special cases
switch lcaGetSmart('DIOD:FEE1:426:SELECT')
    case 1
        status.diodeMode = 'Diode Retracted';
    case 2
        status.diodeMode = 'Canbera';
    case 3
        status.diodeMode = 'Quadrant';
end

switch  lcaGetSmart('XTAL:FEE1:422:SELECT')
    case 1
        status.xtalMode = 'Out';

    case 2
        status.xtalMode = 'In';
end

% transmission
lcaPut('SATT:FEE1:320:EDES',8192); % set so  calc is correct
netAttenuation = lcaGetSmart('GATT:FEE1:310:R_ACT') * lcaGetSmart('SATT:FEE1:320:RACT');
status.netAttenuation = netAttenuation;

% Normal cases
status.photodiode1 = lcaGetSmart('KMON:FEE1:421:ENRC');
status.photodiode2 = lcaGetSmart('KMON:FEE1:422:ENRC');
status.photodiode3 = lcaGetSmart('KMON:FEE1:423:ENRC');
status.photodiode4 = lcaGetSmart('KMON:FEE1:424:ENRC');

% Digitizer and scale parameters
status.BGstart   = lcaGet('KMON:FEE1:421:BSTR');
status.BGstop = lcaGet('KMON:FEE1:421:BSTP');
status.PulseStart  = lcaGet('KMON:FEE1:421:STRT');
status.PulseStop  = lcaGet('KMON:FEE1:421:STOP');
status.Offset  = lcaGet('KMON:FEE1:421:OFFS');
status.CalCoef   = lcaGet('KMON:FEE1:421:CALI');
status.ScaleV   = lcaGet('DIAG:FEE1:202:421:CFullScale');
status.OffsetV  = lcaGet('DIAG:FEE1:202:421:COffset');

% slit
status.slitCenterX = lcaGetSmart('SLIT:FEE1:XTRANS.C'); % center
status.slitWidthX = lcaGetSmart('SLIT:FEE1:XTRANS.D'); % width
status.slitCenterY = lcaGetSmart('SLIT:FEE1:YTRANS.C');
status.slitWidthY = lcaGetSmart('SLIT:FEE1:YTRANS.D' );
