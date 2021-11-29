function FromSCOREtest2()
% tester for FromSCORE. Request region, load gold orbit.

arg.fetchGold = 1;
[data,comment,ts,title] = FromSCORE(arg);
DumpDataFromSCORE(data,comment,ts,title);