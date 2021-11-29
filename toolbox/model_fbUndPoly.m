function [p11, p12, p33, p34, p12c, p22c, p34c, p44c] = model_fbUndPoly()

[opts.source,opts.online,opts.simul,opts.useBDES]=model_init;
model_init('source','MATLAB','online',0,'simul',1,'useBDES',1);

% QUM1-4
nameQUM={'QUM1' 'QUM2' 'QUM3' 'QUM4'};
bQUM=[17.2902     -10.6252     -18.4706      28.5504; ...
      22.5524     -19.3036     -10.6339      30.7114; ...
      27.7143     -25.4747      -4.27293     32.5982; ...
      33.1088     -31.3292       3.11179     33.3909; ...
      38.7458     -37.0234      11.3001      33.0221; ...
      44.9761     -43.0711      22.3660      29.9391; ...
      50.1529     -47.4432      25.5598      31.5125; ...
      55.1289     -51.4063      26.6987      34.3459; ...
      59.1117     -53.8158      20.6310      41.6068; ...
      63.0432     -55.7168      13.5593      48.7668];

bQUM=[17.2904     -10.6252     -18.4708      28.5506; ...
      22.5524     -19.3036     -10.6339      30.7114; ...
      27.7146     -25.4748      -4.27279     32.5982; ...
      33.1088     -31.3291       3.1114      33.391; ...
      38.7459     -37.0234      11.3004      33.022; ...
      44.976      -43.0709      22.3653      29.9396; ...
      50.153      -47.4433      25.56        31.5123; ...
      55.1288     -51.4063      26.6984      34.3461; ...
      59.1117     -53.8158       20.631      41.6068; ...
      62.3989     -53.9438       9.0739      51.0576];

nameBPMList=strcat({'RFBU'},num2str((1:10)','%02d'));
nameCorrList={'XCE35' 'YCE34' 'XCUM4' 'YCUM3'};

nBPM=numel(nameBPMList); % # of BPMs
nEnergy=10;              % # energy points to calc matrices
nDeg=5;                  % # degree of fit polynomial

energyList=linspace(4.3,13.64,nEnergy);
energyFit=linspace(4.3,13.64,100);
[r11,r12,r33,r34]=deal(zeros(nBPM,nEnergy));
[p11,p12,p33,p34]=deal(zeros(nBPM,nDeg+1));
[r11f,r12f,r33f,r34f]=deal(zeros(nBPM,100));
[r12c,r22c,r34c,r44c]=deal(zeros(2,nEnergy));
[p12c,p22c,p34c,p44c]=deal(zeros(2,nDeg+1));
[r12cf,r22cf,r34cf,r44cf]=deal(zeros(2,100));

r12c=[-9.6685  -10.2543  -12.2172  -14.5165  -16.8302  -19.5195  -20.3532  -20.8961  -20.3245  -19.7705; ...
       7.0636    7.1894    7.2805    7.3673    7.4525    7.5601    7.5832    7.5866    7.5391    7.5000];
r22c=[-0.8923   -1.0244   -0.9072   -0.7666   -0.6413   -0.5040   -0.5041   -0.5131   -0.5741   -0.6218; ...
       0.8707    0.8878    0.9002    0.9120    0.9236    0.9382    0.9414    0.9418    0.9354    0.9301];
r34c=[-4.7216    5.5808   10.8347   15.7710   20.3324   24.2851   28.2301   31.7590   34.9656   37.7522; ...
      18.5125   18.4645   18.2470   17.9466   17.5718   17.0208   16.8484   16.7796   16.9516   17.0557];
r44c=[-4.2728   -2.3054   -1.5386   -0.9621   -0.5162   -0.1919    0.0833    0.3238    0.5318    0.6766; ...
       1.8658    1.8280    1.7804    1.7246    1.6610    1.5721    1.5476    1.5399    1.5726    1.5956];

r12c=[-9.6761  -10.2614  -12.2244  -14.5221  -16.8349  -19.5225  -20.3566  -20.8997  -20.3296  -19.2149; ...
       7.0617    7.1883    7.2800    7.3674    7.4531    7.5613    7.5846    7.5880    7.5403    7.4767];
r22c=[-0.8897   -1.0223   -0.9051   -0.7649   -0.6396   -0.5026   -0.5027   -0.5118   -0.5728   -0.6466; ...
       0.8698    0.8871    0.8995    0.9114    0.9231    0.9378    0.9410    0.9415    0.9350    0.9263];
r34c=[-4.6955    5.6487   10.9231   15.8756   20.4515   24.4152   28.3679   31.9042   35.1172   41.3372; ...
      18.4858   18.1980   17.8596   17.4714   17.0337   16.4264   16.2574   16.2015   16.4185   16.6780];
r44c=[-4.2803   -2.3065   -1.5372   -0.9589   -0.5117   -0.1867    0.0890    0.3300    0.5384    0.9269; ...
       1.8748    1.8133    1.7544    1.6909    1.6224    1.5298    1.5061    1.4997    1.5358    1.5807];

for j=1:nEnergy
    lcaPut('SIOC:SYS0:ML00:AO875',energyList(j));
%    model_energySet(energyList(j));%
%    control_magnetSet(nameQUM,bQUM(j,:));%
    r=model_rMatGet('RFBU00',nameBPMList);
    r11(:,j)=squeeze(r(1,1,:));
    r12(:,j)=squeeze(r(1,2,:));
    r33(:,j)=squeeze(r(3,3,:));
    r34(:,j)=squeeze(r(3,4,:));
%    r=model_rMatGet(nameCorrList,'RFBU00');%
%    r12c(:,j)=squeeze(r(1,2,[1 3]));%
%    r22c(:,j)=squeeze(r(2,2,[1 3]));%
%    r34c(:,j)=squeeze(r(3,4,[2 4]));%
%    r44c(:,j)=squeeze(r(4,4,[2 4]));%
end

%r12c,r22c,r34c,r44c%

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
for j=1:2
    p12c(j,:)=polyfit(energyList,r12c(j,:),nDeg);
    p22c(j,:)=polyfit(energyList,r22c(j,:),nDeg);
    p34c(j,:)=polyfit(energyList,r34c(j,:),nDeg);
    p44c(j,:)=polyfit(energyList,r44c(j,:),nDeg);
    r12cf(j,:)=polyval(p12c(j,:),energyFit);
    r22cf(j,:)=polyval(p22c(j,:),energyFit);
    r34cf(j,:)=polyval(p34c(j,:),energyFit);
    r44cf(j,:)=polyval(p44c(j,:),energyFit);
end
figure(1);
subplot(2,2,1);plot(energyList,r11','x',energyFit,r11f');
subplot(2,2,2);plot(energyList,r12','x',energyFit,r12f');
subplot(2,2,3);plot(energyList,r33','x',energyFit,r33f');
subplot(2,2,4);plot(energyList,r34','x',energyFit,r34f');

figure(2);
subplot(2,2,1);plot(energyList,r12c','x',energyFit,r12cf');
subplot(2,2,2);plot(energyList,r22c','x',energyFit,r22cf');
subplot(2,2,3);plot(energyList,r34c','x',energyFit,r34cf');
subplot(2,2,4);plot(energyList,r44c','x',energyFit,r44cf');

model_init(opts);
