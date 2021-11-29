function simul_tcav_calibration()
%TCAV_CALIBRATION test function

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

phase=(-2:2)';
cal=50; % pixel/degree
bpos(:,2)=cal*phase;
bsize=bpos;bsize(:,2)=100;bsize(:,1)=40;
bsize=bsize*opts.cal;
bpos=-bpos*opts.cal;
bsizestd=.1*min(bsize(:));
bposstd=.1*max(bpos(:));

[parlist,beamlist]=simul_imgSequence(phase,2,bsize,bsizestd,bpos,bposstd,opts,fopts,popts);

[cal,calstd]=tcav_calibration(parlist,beamlist(3,:));
