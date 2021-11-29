function fbInitFbckStructures(filename)
% initialize the structures needed for this feedback loop
% nargin  number of input arguments = 1 if there is a config file

%create a loop structure and save it
loop = [];
setappdata(0, 'Loop_structure', loop);

try
   % get the initial configuration from file
   config = fbReadConfigFile(filename);
catch
   dbstack;
   h = errordlg('Could not read config file');
   waitfor(h);
   rethrow(lasterror);
end
   
% read the tolerances and setpoints from softIOC
try
   config.states = fbSoftIOCFcn('GetStatesInfo',config.states);
   config.act = fbSoftIOCFcn('GetActInfo',config.act);
   config.meas = fbSoftIOCFcn('GetMeasInfo',config.meas);
catch
   dbstack;
   h = errordlg('Could not read FB00 PVs');
   waitfor(h);
   rethrow(lasterror);
end

% save the new configuration
setappdata(0, 'Config_structure', config);

% calc matrices if possible, using a temporary Params structure for the
% matrix calculation functions
%setupsetappdata(0, 'tempParams', config.matrix.params);
%do our best to get an f matrix
if isempty(config.matrix.f)
    if ~strcmp(config.matrix.fFcnName,'0')
        calcFmatrix = str2func(config.matrix.fFcnName);
        config.matrix.f = calcFmatrix();
        config.configchanged=1;
    end
end
%do our best to get a g matrix
if isempty(config.matrix.g)
    if ~strcmp(config.matrix.gFcnName,'0')
        calcGmatrix = str2func(config.matrix.gFcnName);
        config.matrix.g = calcGmatrix();
        config.configchanged=1;
    end
end
% save the new configuration
setappdata(0, 'Config_structure', config);

%get actuator energy from aida 
try
   config.act.energy = fbGet_ActEnergy(config.act);
catch
   dbstack;
   config.act.energy = zeros(length(config.act.allactPVs));
   disp([config.feedbackAcro ' could not read energy values from aida; using defaults = 0.']);
   fbLogMsg([config.feedbackAcro ' could not read energy values from aida; using defaults = 0.']);
end

%get dispersion values for specific BPMs
dispersion = config.meas.dispersion;
if (~isempty(dispersion))
   try
      config.meas.dispersion = fbGet_MeasDspr(config.meas);
      % now update the soft IOC
      dsprNames = fbAddToPVNames(config.meas.allstorePVs, 'DSPR');
      lcaPut(dsprNames, config.meas.dispersion);
   catch
      dbstack;
      config.meas.dispersion = dispersion;
      disp([config.feedbackAcro ' could not read dispersion values; using defaults.']);
      fbLogMsg([config.feedbackAcro ' could not read dispersion values; using defaults.']);
   end
end

     
%save this config structure
setappdata(0, 'Config_structure', config);
   



