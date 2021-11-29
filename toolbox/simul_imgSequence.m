function [parlist, beamlist] = simul_imgSequence(par, nsample, bsize, bsizestd, ...
    bpos, bposstd, opts, fopts, popts)
%IMGSEQUENCE
%  IMGSEQUENCE(PAR, NSAMPLE, BSIZE, BSIZESTD, BPOS, BPOSSTD, OPTS, FOPTS,
%  POPTS) simulates a measurement of taking images and processing them.

% Input arguments:
%    PAR: Device value to change in the measurment, e.g. quad current, TCAV
%         phase, profile monitor position
%    NSAMPLE: number of images at each device setting
%    BSIZE: Array of beam sizes [x y]
%    BSIZESTD: Standard deviations of BSIZE
%    BPOS: Array of beam centroids [x y]
%    BPOSSTD: Standard deviations of BPOS
%    OPTS: Options for createImg()
%    FOPTS: Options for imgProc() and beamParams()
%    POPTS: Options for imgPlot()

% Output arguments:
%    PARLIST: List of device values corresponding to each image
%    BEAMLIST: Structure array NxM of beam parameters with N analysis
%    methods and M images

% Compatibility: Version 7 and higher
% Called functions: createImg, imgPlot, imgProc, beamParams

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
if isempty(bpos), bpos=bsize*0;bposstd=0;end

% Loop through parlist.
parlist=repmat(par(:)',nsample,1);
for k=1:length(par)
    opts.off=1;
    data.back=simul_imgCreate(opts);
    data.bitdepth=opts.bitdepth;
    for j=1:nsample
        opts.off=0;
        opts.sigma=bsize(k,:)+bsizestd*randn(1,2);
        opts.position=bpos(k,:)+bposstd*randn(1,2);
        img=simul_imgCreate(opts);
        data.full=img;
        [img,xsub,ysub,flag,bgs]=beamAnalysis_imgProc(data,fopts);
        beamlist(:,j,k)=beamAnalysis_beamParams(img,xsub,ysub,bgs,fopts);
        beamAnalysis_imgPlot(beamlist(3,j,k),img,data,popts);
    end
end

% Flatten outputs.
parlist=parlist(:);
beamlist=beamlist(:,:);
