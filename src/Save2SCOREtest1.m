function Save2SCOREtest1()
% tester for Save2SCORE. Loads gold BSA-All orbit, prompts for comment & save wn=/new ts

arg.region = 'Feedback-All';
arg.fetchGold = 1;
[data,comment,ts,title] = FromSCORE(arg);
DumpDataFromSCORE(data,comment,ts,title);

save.region = arg.region;
save.data = data;
[region,comment,ts] = Save2SCORE(save);
DumpDataFromSCORE(save.data,comment,ts,title);
