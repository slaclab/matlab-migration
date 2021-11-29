function FromSCOREtest3()
% tester for FromSCORE. Request region and orbit.

[data,comment,ts,title] = FromSCORE();
DumpDataFromSCORE(data,comment,ts,title);