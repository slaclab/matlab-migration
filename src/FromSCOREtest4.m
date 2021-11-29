function FromSCOREtest4()
% tester for FromSCORE. Request region and orbit.

arg.accelerator = 'LCLS2';
[data,comment,ts,title] = FromSCORE(arg);
DumpDataFromSCORE(data,comment,ts,title);