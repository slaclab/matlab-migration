function FromSCOREtest1()
% tester for FromSCORE with fully specified arguments, gold BSA

arg.region = 'BSA';
arg.fetchGold = 1;
[data,comment,ts,title] = FromSCORE(arg);
DumpDataFromSCORE(data,comment,ts,title);
