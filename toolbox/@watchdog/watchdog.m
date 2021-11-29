% W = watchdog(PV, modulo, name)
% creates a watchdog timer
%
% W is the returned class
% modulo is the number of watchdog cycles before reading / writing PVs
% Used to reduce PV writing / reading data rate 
%
% PV is the PV name to use as a counter
% name is the name of the routine that will be using the watchdog
% W.error
% error = 0. No errors
% error = 1  Someone else is using PV
% error = 2  Cannot read / write PV





function W = watchdog(PV, modulo, name)
W = struct;
delay = 5;               % how long we wait to check updates
W.name = name;
W.count = 1;
W.name = name;
W.count = 1;
W.inc = 1; % the counting incrementor
W.modulo = modulo;
W.PV = PV;
W.error = 0;
W.relative_count = 0; % 1 means our count is higher - errors only
try
  initial = lcaGet(W.PV);
  pause(delay);
  final = lcaGet(W.PV);
  if final ~= initial    % someone is using this PV
    W.error = 1;
  else
    W.error = 0;
    lcaPut(W.PV,W.inc);
    lcaPut([W.PV, '.DESC'], W.name);
    lcaPut([W.PV,'.EGU'], 'watchdog');
    lcaPut([W.PV, '.PREC'], 0);
  end
catch
  W.error = 2; % problem writing / reading PV
end
W = class(W, 'watchdog');
end