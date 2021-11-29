function simul_emittance_multiScreen()

opts=struct( ...
    'dims',[1040 1394], ... % Size of image, [y x]
    'bitdepth',12, ... % Bitdepth of image
    'cal',10e-6, ... % CCD calibration in m/pixel
    'atten',1e1 ... % Light attenuation factor
    );

fopts=struct( ...
    'debug',0);

popts=struct( ...
    'figure',1, ...
    'full',1, ...
    'xlim',[600 800], ...
    'ylim',[400 600]);

pos=1.914*[-1 0 1]';
%sig=[50^2;0;2^2];
%val=cal*amp;m=[val*0+1 2*val val.^2];
%bsize=sqrt(m*sig);
bsize=[120 120;60 60;120 120]*1e-6;
bsizestd=.1*min(bsize(:));

[parlist,beamlist]=simul_imgSequence(pos,2,bsize,bsizestd,[],[],opts,fopts,popts);

emittance_multiScreen(parlist,beamlist(3,:),1,opts.cal,0.135);
