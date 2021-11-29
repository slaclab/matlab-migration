function simul_tcav_bunchLength()
%TCAV_BUNCHLENGTH test function

% Compatibility: Version 7 and higher
% Called functions: 

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

opts=struct( ...
    'dims',[1040 1394], ... % Size of image, [y x]
    'bitdepth',12, ... % Bitdepth of image
    'cal',10e-6, ... % CCD calibration in m/pixel
    'atten',3e0 ... % Light attenuation factor
    );

fopts=struct( ...
    'debug',0,'crop',1);

popts=struct( ...
    'figure',1, ...
    'full',1, ...
    'xlim',[500 900]);

amp=[-1 0 1]';cal=50;calstd=.1*cal; % pixel/degree
sig=[50^2;20;2^2];
val=cal*amp;m=[val*0+1 2*val val.^2];
bsize(:,2)=sqrt(m*sig);bsize(:,1)=40;
bsize=bsize*opts.cal;
bsizestd=.1*min(bsize(:));

[parlist,beamlist]=simul_imgSequence(amp,2,bsize,bsizestd,[],[],opts,fopts,popts);

[sigx,sigt,sigxstd,sigtstd]=tcav_bunchLength(parlist,beamlist(3,:),cal,calstd);

%data=vertcat(beamlist(:,3).stats);data=data(:,4);
%[sigz,dsigz,sigy0,dsigy0,e_e0,de_e0]=my_tcav_bunch_length(parlist,data,data*0+10,25,cal,calstd);
