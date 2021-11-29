function [p11, p12, p33, p34] = fbUndPolys()

global modelOnline modelSimul modelUseBDES
modelOnline=0;
modelSimul=1;
modelUseBDES=1;

nameBPMList=strcat({'RFBU'},num2str((0:10)','%02d'));

nBPM=numel(nameBPMList); % # of BPMs
nEnergy=10;              % # energy points to calcc matrices
nDeg=5;                  % # degree of fit polynomial

energyList=linspace(4.3,13.64,nEnergy);
energyFit=linspace(4.3,13.64,100);
[r11,r12,r33,r34]=deal(zeros(nBPM,nEnergy));
[p11,p12,p33,p34]=deal(zeros(nBPM,nDeg+1));
[r11f,r12f,r33f,r34f]=deal(zeros(nBPM,100));

for j=1:nEnergy
    lcaPut('SIOC:SYS0:ML00:AO875',energyList(j));
    r=model_rMatGet('RFBU00',nameBPMList);
    r11(:,j)=squeeze(r(1,1,:));
    r12(:,j)=squeeze(r(1,2,:));
    r33(:,j)=squeeze(r(3,3,:));
    r34(:,j)=squeeze(r(3,4,:));
end
for j=1:nBPM
    p11(j,:)=polyfit(energyList,r11(j,:),nDeg);
    p12(j,:)=polyfit(energyList,r12(j,:),nDeg);
    p33(j,:)=polyfit(energyList,r33(j,:),nDeg);
    p34(j,:)=polyfit(energyList,r34(j,:),nDeg);
    r11f(j,:)=polyval(p11(j,:),energyFit);
    r12f(j,:)=polyval(p12(j,:),energyFit);
    r33f(j,:)=polyval(p33(j,:),energyFit);
    r34f(j,:)=polyval(p34(j,:),energyFit);
end
modelUseBDES=0;
