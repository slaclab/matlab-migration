%% MAD EPICS Matlab Environment (MEME) Modelling

% This script demonstrates MAD modelling from inside matlab.
memecommon;   % Just some constants. Eg defines TYPE_DESIGN used below

%% Optics
mc.beamline=BEAMLINE_LCLS;

% Model design machine
mc.type=TYPE_DESIGN;
model=madmodel(mc);

% Plot the model
modelplot(model);
modelplot(model,{2,7});   % betax and betay
modelplot(model,{{2,7};{4}});  % betax and betay on y, and etx on yy
modelplot(model,{{'\beta [m]',BETAX,BETAY};{DX}});   % With user defined ylabels
modelplot(model,{{'\beta [m]',BETAX,BETAY};{'\eta_x [m]',DX}});

%% GSPEC. 
mc.beamline=BEAMLINE_GSPEC;
model=madmodel(mc);
modelplot(model,{{'\beta [m]',BETAX,BETAY};{'\eta_x [m]',DX}});

%% 135-Mev Spectrometer
mc.beamline=BEAMLINE_SPEC;
mc.type=TYPE_DESIGN;
model=madmodel(mc);
modelplot(model,{{'\beta [m]',BETAX,BETAY};{'\eta_x [m]',DX}});

%% Compute optics from design and archive data and compare 
% Model design machine
mc.beamline=BEAMLINE_LCLS; 
mc.type=TYPE_DESIGN;
model=madmodel(mc);
mc.reinit=false;         % optional, just reuse files acquired for DESIGN comp
mc.type=TYPE_HISTORY;
% Set beamline unlets already set.
mc.histtime='02/10/2015 11:37:00';
model2=madmodel(mc)
% Plot design and history of LCLS
modelplot(model,{2,7},model2);
modelplot(model,{{'\beta [m]',BETAX,BETAY};{'\eta_x [m]',DX}},model2)

%% Model extant machine
mc.beamline=BEAMLINE_GSPEC;
mc.type=TYPE_EXTANT;
model3=madmodel(mc);

%% Model design from specified files
mc.beamline=BEAMLINE_LCLS;
mc.type=TYPE_DESIGN;
mc.commandfile='/Users/greg/Development/meme/lclscvs/optics/etc/lattice/lcls/LCLS_MAIN.mad8';
mc.xsiffiles={'/Users/greg/Development/meme/lclscvs/optics/etc/lattice/lcls/LCLS_L1.xsif',...
    '/Users/greg/Development/meme/lclscvs/optics/etc/lattice/lcls/LCLS_L2.xsif',...
    '/Users/greg/Development/meme/lclscvs/optics/etc/lattice/lcls/LCLS_L3.xsif'};
% If you want to compute TYPE_HISTORY from given files, rememeber that for
% modelling from archived PV data we also require an exsting tape file of the
% beamline being modelled (for effective lengths), so you may want to override 
% the default for that too.
%mc.tapefiles=...
%    {'/Users/greg/Development/meme/lclscvs/optics/etc/lattice/lcls/LCLS_twiss.tape'};
% Track the design from given files and plot results
mydesignmodel=madmodel(mc);
modelplot(mydesignmodel,{{'\beta [m]',BETAX,BETAY};{'\eta_x [m]',DX}});

%% Retrack using inpt files from previous model run.
% If retrack is true, trackdir MUST contain the input files required to
% satisfy mc.type. That is, the directory named by trackdir must contain 
% AT LEAST the the .mad8 and necessary *.xsif files; and if type ~= TYPE_DESIGN 
% it must additionally contain also a valid patch.mad8 file.

% Eg 1. Using tracking dir of a model just computed (model)
% model=madmodel(mc);
mc.trackdir=model.trackdir
mc.retrack=true;
modelp=madmodel(mc);
% modelplot(model,{{'\beta [m]',BETAX,BETAY};{'\eta_x [m]',DX}},modelp); % Compare them
%
% Eg 2. Giving the tracking directory explicitly. In this case you should
% also set the model config to the same values as were used to run the
% model in that given tracking directory
mc.beamline=BEAMLINE_LCLS;
mc.type=TYPE_HISTORY;
mc.histtime='02/15/2015 11:37:00';
mc.trackdir='/Users/greg/Development/meme/tmp/bigbetaissue/emulate46958';
mc.retrack=true;
model=madmodel(mc);

% Compare a DESIGN model (computed using its own model config request
% structure, to above retracked HISTORY model)
dmc.beamline=BEAMLINE_LCLS;
% Model design machine
dmc.type=TYPE_DESIGN;
dmodel=madmodel(dmc);
modelplot(model,{{'\beta [m]',BETAX};{'\eta_x [m]',DX}},dmodel);


%% Utilites
% quadK           : Calculates K from B or from power supply settings
% magnetPolyPlot  : Plots magnet and power supply polynomials, and checks B
%                   sanity.
