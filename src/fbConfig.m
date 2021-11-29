function fbConfig(varargin)
% 
% fbConfig is the main program for the feedback configuration application
%
% varargin: the filename of the configuration file
%


% initialize the feedback loop structures
filename = char(varargin);
try
   fbInitFbckStructures(filename);

   % start the main feedback gui
   fbMain();
catch
   error(lasterror);
end

