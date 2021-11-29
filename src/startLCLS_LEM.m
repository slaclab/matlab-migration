%
% startLCLS_LEM
%
% This is the startup file for the Matlab-based LCLS Linac Energy Management
% application (LEM), which requires non-standard initialization (i.e. not via
% the standard MatlabGUI shell script and startLCLS Matlab script).

% insert folders into path:
% - /usr/local/lcls/tools/matlab/src/LEM

pLEM='/usr/local/lcls/tools/matlab/src/LEM:';
p=path;
if (isempty(strfind(p,pLEM)))
  id=strfind(p,'/usr/local/lcls/tools/matlab/src:');
  ic=strfind(p,':');
  ic=ic(find(ic>id));
  ic=ic(1);
  p=strcat(p(1:ic),pLEM,p(ic+1:end));
  path(p)
  clear id ic
end
clear pLEM p
