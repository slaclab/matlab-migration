%
% startLCLS_XAL
%
% This is the startup file for the Matlab-based LCLS XAL online model
% application, which requires non-standard initialization (i.e. not via the
% standard MatlabGUI shell script and startLCLS Matlab script).

% insert folders into path:
% - /usr/local/lcls/tools/matlab/src/XAL

pXAL='/usr/local/lcls/tools/matlab/src/XAL:';
p=path;
if (isempty(strfind(p,pXAL)))
  id=strfind(p,'/usr/local/lcls/tools/matlab/src:');
  ic=strfind(p,':');
  ic=ic(find(ic>id));
  ic=ic(1);
  p=strcat(p(1:ic),pXAL,p(ic+1:end));
  path(p)
  clear id ic
end
clear pXAL p
