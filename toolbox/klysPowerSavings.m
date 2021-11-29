%%Calculate Klystron Power Savings
kk=777;
watchCount = 1;

while(kk==777)

 
L2ContStat = 2;
L3ContStat = 4;
onBVthresh = 100;
KlysPower = 0.06; %power per klystron in MW
PowerCost = 52; % Dollar cost per MWh


all_L2klystrons = {'KLYS:LI21:31' 'KLYS:LI21:41' 'KLYS:LI21:51' 'KLYS:LI21:61' 'KLYS:LI21:71' 'KLYS:LI21:81'...     
'KLYS:LI22:11' 'KLYS:LI22:21' 'KLYS:LI22:31' 'KLYS:LI22:41' 'KLYS:LI22:51' 'KLYS:LI22:61' 'KLYS:LI22:71' 'KLYS:LI22:81'... 
'KLYS:LI23:11' 'KLYS:LI23:21' 'KLYS:LI23:31' 'KLYS:LI23:41' 'KLYS:LI23:51' 'KLYS:LI23:61' 'KLYS:LI23:71' 'KLYS:LI23:81'...
'KLYS:LI24:11' 'KLYS:LI24:21' 'KLYS:LI24:31' 'KLYS:LI24:41' 'KLYS:LI24:51' 'KLYS:LI24:61'}';


all_L3klystrons = {'KLYS:LI25:11' 'KLYS:LI25:21' 'KLYS:LI25:31' 'KLYS:LI25:41' 'KLYS:LI25:51' 'KLYS:LI25:61' 'KLYS:LI25:71' 'KLYS:LI25:81'...
'KLYS:LI26:11' 'KLYS:LI26:21' 'KLYS:LI26:31' 'KLYS:LI26:41' 'KLYS:LI26:51' 'KLYS:LI26:61' 'KLYS:LI26:71' 'KLYS:LI26:81'...
'KLYS:LI27:11' 'KLYS:LI27:21' 'KLYS:LI27:31' 'KLYS:LI27:41' 'KLYS:LI27:51' 'KLYS:LI27:61' 'KLYS:LI27:71' 'KLYS:LI27:81'...
'KLYS:LI28:11' 'KLYS:LI28:21' 'KLYS:LI28:31' 'KLYS:LI28:41' 'KLYS:LI28:51' 'KLYS:LI28:61' 'KLYS:LI28:71' 'KLYS:LI28:81'...
'KLYS:LI29:11' 'KLYS:LI29:21' 'KLYS:LI29:31' 'KLYS:LI29:41' 'KLYS:LI29:51' 'KLYS:LI29:61' 'KLYS:LI29:71' 'KLYS:LI29:81'...
'KLYS:LI30:11' 'KLYS:LI30:21' 'KLYS:LI30:31' 'KLYS:LI30:41' 'KLYS:LI30:51' 'KLYS:LI30:61' 'KLYS:LI30:71' 'KLYS:LI30:81'...
}';


L2klysEnld = strcat(all_L2klystrons,':ENLD');
L3klysEnld = strcat(all_L3klystrons,':ENLD');

L2klysBV = strcat(all_L2klystrons,':BVLT');
L3klysBV = strcat(all_L3klystrons,':BVLT');

L2klysAcStat = strcat(all_L2klystrons,':BEAMCODE1_TSTAT');
L3klysAcStat = strcat(all_L3klystrons,':BEAMCODE1_TSTAT');

L1endEn = lcaGet('REFS:LI21:231:EDES');
L2endEn = lcaGet('REFS:LI24:790:EDES');
L3endEn = lcaGet('REFS:DMP1:400:EDES');

L2Fudge = lcaGet('ACCL:LI22:1:FUDGE');
L3Fudge = lcaGet('ACCL:LI25:1:FUDGE');

L2Phase = lcaGet('ACCL:LI22:1:P_SUM');
L3Phase = lcaGet('ACCL:LI25:1:P_SUM');


AllL2klysEnld = lcaGet(L2klysEnld);
AllL3klysEnld = lcaGet(L3klysEnld);
AllL2KlysBV = lcaGet(L2klysBV);
AllL3KlysBV = lcaGet(L3klysBV);
AllL2klysAcStat = lcaGet(L2klysAcStat);
AllL3klysAcStat = lcaGet(L3klysAcStat);

L2ActInd = find(strcmp(AllL2klysAcStat,'Activated'));
L3ActInd = find(strcmp(AllL3klysAcStat,'Activated'));
L2OnKlysInd = find(AllL2KlysBV > onBVthresh);
L3OnKlysInd = find(AllL3KlysBV > onBVthresh);

L2ActK = size(L2ActInd,1);
L3ActK = size(L3ActInd,1);
L2OnKlys = size(L2OnKlysInd,1);
L3OnKlys = size(L3OnKlysInd,1);
L2Off = size(all_L2klystrons,1) - L2OnKlys;
L3Off = size(all_L3klystrons,1) - L3OnKlys;


L2extEn = L1endEn + L2Fudge*cos(pi*L2Phase/180)*sum(AllL2klysEnld(L2ActInd))/1000 - L2endEn;

l2extKly = floor(L2OnKlys - L2ContStat - L2ActK + L2extEn/(L2Fudge*mean(AllL2klysEnld)/1000));

L3extEn = L2endEn + L3Fudge*cos(pi*L3Phase/180)*sum(AllL3klysEnld(L3ActInd))/1000 - L3endEn;

l3extKly = floor(L3OnKlys - L3ContStat - L3ActK + L3extEn/(L3Fudge*mean(AllL3klysEnld)/1000));

if(l2extKly < 0) 
 l2extKly = 0;
end
if(l3extKly < 0) 
 l3extKly = 0;
end

currentKlysPowerSavings = KlysPower*PowerCost*(L2Off+L3Off);
potentialKlysPowerSavings = KlysPower*PowerCost*(l2extKly+l3extKly);
powerSavingsPercentage = 100*(L2Off+L3Off)/(l2extKly+l3extKly+L2Off+L3Off);

lcaPut('SIOC:SYS0:ML02:AO088',currentKlysPowerSavings);
lcaPut('SIOC:SYS0:ML02:AO089',potentialKlysPowerSavings);
lcaPut('SIOC:SYS0:ML02:AO090',powerSavingsPercentage);
lcaPut('SIOC:SYS0:ML02:AO091',watchCount);

pause(10);
watchCount = watchCount+1;

end
