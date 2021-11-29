function [data, ts] = profmon_simulData(pv, props)
%IMGPV
%  IMGPV(PV, PROPS) returns data that simulates an image PV.

% Input arguments:
%    PV: base PV name of camera
%    PROPS: Image property values of camera, optional

% Output arguments:
%    DATA: linear array containing the image data.

% Compatibility: Version 7 and higher
% Called functions: imgPV

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Get beam data.
[bSize,bPos]=model_beamSize(pv);
if strncmp(pv,'YAGS:UND1',9)
    bSize=[1000 100]*1e-6;
    bPos=[-2500 50]'*1e-6;
end

% Flip to rotated image.
if props(17)
    bPos=flipud(-bPos);
    bSize=fliplr(bSize);
end

% Apply mirroring.
bPos=bPos.*(1-2*props(9:10));

% Determine center pixel.
center=props(11:12)-props(5:6);
cal=props(4);if props(18), cal(1,2)=props(18);end
dims=props(7:8)';

off=~lcaGet('PATT:SYS0:1:POCKCTRL') | ~lcaGet('IOC:BSY0:MP01:PCELLCTL') | ~lcaGet('APC:XT01:TM01:SHUT1') | strcmp(lcaGet(strcat(pv,':PNEUMATIC')),'OUT');
charge=lcaGet('BPMS:IN20:221:TMIT')*1.6021e-19; % in Coulomb

% Set options.
opts=struct( ...
    'dims',dims([2 1]), ... % Size of image, [y x]
    'sig_bg',4, ... % RMS of background noise distribution
    'bitdepth',props(3), ... % Bitdepth of image
    'charge',charge, ... % Charge (C)
    'qe',2e-3, ... % Quantum efficiency of detection system, CCD counts/electron
    'sigma',bSize, ... % Beam size [x y] in m
    'position',bPos', ... % Beam position [x y] in m
    'n_part',30000, ... % # of particles
    'x',[], ... % Particle coordinates [x;y], will be calculated from sigma and position if []
    'off',off, ... % Beam off?
    'cal',cal*1e-6, ... % CCD calibration in m/pixel
    'atten',3e1, ... % Light attenuation factor
    'center',center', ... % Coordinate of center pixel, defaults to half of dims if []
    'method','smooth', ... % Method to get distribution, SMOOTH uses function, PARTICLES uses random particles
    'number',[], ... % Display NUMBER in image, omitted if empty
    'salt_pepper',1e-3 ... % Salt & pepper noise ratio of damaged/saturated pixels
    );

%opts.sigma(3)=.5*prod(opts.sigma);
data=profmon_simulCreate(opts);
data(1:10-props(6),:)=0;
data(:,1:50-props(5))=0;
data(:,max(1,center(1)+70):min(end,center(1)+72))=data(:,max(1,center(1)+70):min(end,center(1)+72))+50;

% Simulate BODs
if ~off && strncmp(pv,'YAGS:UND1',9)
    x=((1:dims(1))-center(1))*cal(1);y=((1:dims(2))-center(2))*cal(1);
    w=[-1300 -180 750;-915 640 1050];w=w(2-strcmp(pv,'YAGS:UND1:1005'),:);
    BODV=100*exp(-(x-w(1)).^2/2/30^2)+200*exp(-(x-w(3)).^2/2/50^2)+(x > w(3))*50;
    BODH=500*exp(-(y-w(2)).^2/2/30^2);
    data=data+repmat(uint16(BODV),dims(2),1)+repmat(uint16(BODH)',1,dims(1));
end

data=reshape(data',[],1);
ts=now;
