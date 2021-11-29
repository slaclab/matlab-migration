function Save2SCOREtest2()
% tester for Save2SCORE. Loads gold BSA-All orbit, prompts for comment & save wn=/new ts

arg.region = 'BSA-MIKE';
arg.accelerator = 'LCLS2';
[data,comment,ts,title] = FromSCORE(arg);
DumpDataFromSCORE(data,comment,ts,title);

save.region = arg.region;
save.data = data;
save.accelerator = arg.accelerator;
[region,comment,ts] = Save2SCORE(save);
DumpDataFromSCORE(save.data,comment,ts,title);
