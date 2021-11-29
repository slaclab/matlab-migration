%load
%/u1/lcls/matlab/data/2009/2009-02/2009-02-14/Day_Night-1-2009-02-14-143253.mat   
%load /u1/lcls/matlab/data/2009/2009-02/2009-02-16/Day_Night-1-2009-02-16-055645.mat     % 4.3GeV
%load /u1/lcls/matlab/data/2009/2009-05/2009-05-30/Day_Night-1-2009-05-30-003519.mat      % night
%load /u1/lcls/matlab/data/2009/2009-12/2009-12-04/Day_Night-1-2009-12-04-205448.mat      % night
load /u1/lcls/matlab/data/2009/2009-12/2009-12-14/Day_Night-1-2009-12-14-173248.mat    

data0=data;
%load
%/u1/lcls/matlab/data/2009/2009-02/2009-02-14/Day_Night-1-2009-02-14-175231.mat  
%load /u1/lcls/matlab/data/2009/2009-02/2009-02-16/Day_Night-1-2009-02-16-134853.mat     % 4.3 GeV
%load /u1/lcls/matlab/data/2009/2009-05/2009-05-28/Day_Night-1-2009-05-28-145147.mat %085642.mat  % 4.3 GeV
%load /u1/lcls/matlab/data/2009/2009-05/2009-05-29/Day_Night-1-2009-05-29-155816.mat      % day
load /u1/lcls/matlab/data/2009/2009-08/2009-08-13/Day_Night-1-2009-08-13-145515.mat      % day

path(path,'/home/physics/decker/matlab/matlab_slcmar2008')
load /home/physics/decker/matlab/toolbox/BPM_pvs_all2


figure(4)
plot(data0(:,7*1+1)-data0(:,1))
hold on
plot(data(:,7*1+1)-data(:,1),'r')
xlabel('BPM #')
ylabel('X [mm]')
title('LCLS Difference Orbits (XC04) at Day (r) and Night (b)')
plot16
grid on
axis([0 180 -1 1])

figure(5)
plot(data0(:,7*2+1)-data0(:,1))
hold on
plot(data(:,7*2+1)-data(:,1),'r')
xlabel('BPM #')
ylabel('X [mm]')
title('LCLS Difference Orbits (XC07) at Day (r) and Night (b)')
plot16
grid on
axis([0 180 -1.0001 1.0001])

figure(6)
plot(data0(:,7*3+2)-data0(:,2))
hold on
plot(data(:,7*3+2)-data(:,2),'r')
xlabel('BPM #')
ylabel('Y [mm]')
title('LCLS Difference Orbits (YC04) at Day (r) and Night (b)')
plot16
grid on
axis([0 180 -1.00001 1.00001])

figure(7)
plot(data0(:,7*4+2)-data0(:,2))
hold on
plot(data(:,7*4+2)-data(:,2),'r')
xlabel('BPM #')
ylabel('Y [mm]')
title('LCLS Difference Orbits (YC07) at Day (r) and Night (b)')
plot16
grid on
axis([0 180 -1.00001 1.00001])

%data0=data;


i136=112;
fitpointE =  BPM_pvs(i136);
 global modelSource
  modelSource='EPICS';
[r,zn]=model_rMatGet(fitpointE,BPM_pvs, 'TYPE=EXTANT');
[rd,zn]=model_rMatGet(BPM_pvs);
R1s=permute(r(1,[1 2 3 4 6],:),[3 2 1]);
R3s=permute(r(3,[1 2 3 4 6],:),[3 2 1]);        
fitI = [1 1 1 1 1 1 1];
fitI2 = [1 1 1 1 0 0 0];
z0 = zn(i136);


Xs=data0(:,7*1+1)-data0(:,1);
Ys=data0(:,7*1+2)-data0(:,2);
Xs(100)=Xs(99);
Ys(100)=Ys(99);
R1s(100,:)=R1s(99,:);
R3s(100,:)=R3s(99,:);
R1s(i136,:)=R1s(i136-1,:);
R3s(i136,:)=R3s(i136-1,:);

%i=1:size(Xs);
fitStart = 39;
fitEnd =   49;
fitRange = fitStart:fitEnd;
dXs = ones(size(Xs))*10;
dYs = ones(size(Xs))*10;
dXs(fitRange) = ones(1,fitEnd - fitStart + 1) * .01;
dYs(fitRange) = ones(1,fitEnd - fitStart + 1) * .01;
%dXs(112) = 10; dXs(116) = 10;

fitStart2 = 39;
fitEnd2 =   49;
fitRange2 = fitStart2:fitEnd2;
dXs2 = ones(size(Xs))*10;
dYs2 = ones(size(Xs))*10;
dXs2(fitRange2) = ones(1,fitEnd2 - fitStart2 + 1) * 0.01;
dYs2(fitRange2) = ones(1,fitEnd2 - fitStart2 + 1) * 0.01;
dXs2(112) = 10; dXs2(116) = 10;

[Xsf,Ysf,p,dp,chisq,Q] = ...
          xy_traj_fit_kick(Xs',dXs',Ys',dYs',0*Xs',0*Ys',R1s(:,:),R3s(:,:),zn,z0,fitI);
      p, [Xs(i136),  Xsf(i136),Ys(i136) , Ysf(i136)]
[Xsf2,Ysf2,p2,dp2,chisq2,Q] = ...
          xy_traj_fit_kick(Xs',dXs2',Ys',dYs2',0*Xs',0*Ys',R1s(:,:),R3s(:,:),zn,z0,fitI2);
      p2, [Xs(i136),  Xsf2(i136),Ys(i136) , Ysf2(i136)]
      
      
[dd,zx]=size(Xs');    

figure(9)
%clf
subplot(3,1,1:2)
plot_bar(1:zx,Xs,'g')
plot(1:zx,Xsf,'c',fitRange,Xsf(fitRange),'b')
plot(1:zx,Xsf2,'m',fitRange2,Xsf2(fitRange2),'r')
%xlabel('BPM #')     % xlabel('BPM #:  BSY 8      LTU 39      Undulator 73   Dump 78')
ylabel('x [mm]')
plot16
grid on
axis([0 180 -1.0001 1.0001])
title('Difference of Diff-Orbits (XC04) of Night')


subplot(313)
plot_bar(1:zx,Ys,'g')
plot(1:zx,Ysf,'c',fitRange,Ysf(fitRange),'b')
plot(1:zx,Ysf2,'m',fitRange2,Ysf2(fitRange2),'r')
xlabel('BPM #')     % xlabel('BPM #:  BSY 8      LTU 39      Undulator 73   Dump 78')
ylabel('y [mm]')
plot16
grid on
axis([0 180 -.20001 .20001])
 
Xs=data0(:,7*4+1)-data0(:,1);
Ys=data0(:,7*4+2)-data0(:,2);
Xs(100)=Xs(99);
Ys(100)=Ys(99);
R1s(100,:)=R1s(99,:);
R3s(100,:)=R3s(99,:);
%i=1:size(Xs);
%fitStart = 50;
%fitEnd =   99;
%fitRange = fitStart:fitEnd;
%dXs(i) = ones(size(dXs))*10;
%dYs(i) = ones(size(dXs))*10;
%dXs(fitRange) = ones(1,fitEnd - fitStart + 1) * 0.01;
%dYs(fitRange) = ones(1,fitEnd - fitStart + 1) * 0.01;

[Xsf,Ysf,p,dp,chisq,Q] = ...
          xy_traj_fit_kick(Xs',dXs',Ys',dYs',0*Xs',0*Ys',R1s(:,:),R3s(:,:),zn,z0,fitI);
      p, [Xs(i136),  Xsf(i136),Ys(i136) , Ysf(i136)]
[Xsf2,Ysf2,p2,dp2,chisq2,Q] = ...
          xy_traj_fit_kick(Xs',dXs2',Ys',dYs2',0*Xs',0*Ys',R1s(:,:),R3s(:,:),zn,z0,fitI2);
      p2, [Xs(i136),  Xsf2(i136),Ys(i136) , Ysf2(i136)]
      
[dd,zx]=size(Xs');       
figure(10)
%clf
subplot(311)
plot_bar(1:zx,Xs,'g')
plot(1:zx,Xsf,'c',fitRange,Xsf(fitRange),'b')
plot(1:zx,Xsf2,'m',fitRange2,Xsf2(fitRange2),'r')
%xlabel('BPM #')     % xlabel('BPM #:  BSY 8      LTU 39      Undulator 73   Dump 78')
ylabel('x [mm]')
plot16
grid on
axis([0 180 -.20001 .20001])
title('Difference of Diff-Orbits (YC07) of Night')


subplot(3,1,2:3)
plot_bar(1:zx,Ys,'g')
plot(1:zx,Ysf,'c',fitRange,Ysf(fitRange),'b')
plot(1:zx,Ysf2,'m',fitRange2,Ysf2(fitRange2),'r')
xlabel('BPM #')     % xlabel('BPM #:  BSY 8      LTU 39      Undulator 73   Dump 78')
ylabel('y [mm]')
plot16
grid on
axis([0 180 -1.0001 1.0001])
 
 
 
Xs=  (data0(:,7*2+1)-data0(:,1));
%Ys= data0(:,7*2+2)-data(:,2) - (data0(:,7*2+1)-data0(:,2));
Ys=  (data0(:,7*2+2)-data0(:,2));
Xs(100)=Xs(99);
Ys(100)=Ys(99);
R1s(100,:)=R1s(99,:);
R3s(100,:)=R3s(99,:);


[Xsf,Ysf,p,dp,chisq,Q] = ...
          xy_traj_fit_kick(Xs',dXs',Ys',dYs',0*Xs',0*Ys',R1s(:,:),R3s(:,:),zn,z0,fitI);
      p, [Xs(i136),  Xsf(i136),Ys(i136) , Ysf(i136)]
[Xsf2,Ysf2,p2,dp2,chisq2,Q] = ...
          xy_traj_fit_kick(Xs',dXs2',Ys',dYs2',0*Xs',0*Ys',R1s(:,:),R3s(:,:),zn,z0,fitI2);
      p2, [Xs(i136),  Xsf2(i136),Ys(i136) , Ysf2(i136)]
      
      
[dd,zx]=size(Xs');          
figure(11)
%clf
subplot(3,1,1:2)
plot_bar(1:zx,Xs,'g')
plot(1:zx,Xsf,'c',fitRange,Xsf(fitRange),'b')
plot(1:zx,Xsf2,'m',fitRange2,Xsf2(fitRange2),'r')
%xlabel('BPM #')     % xlabel('BPM #:  BSY 8      LTU 39      Undulator 73   Dump 78')
ylabel('x [mm]')
plot16
grid on
axis([0 180 -1.0001 1.0001])
title('Difference of Diff-Orbits (XC07) of Night')

subplot(3,1,3)
plot_bar(1:zx,Ys,'g')
plot(1:zx,Ysf,'c',fitRange,Ysf(fitRange),'b')
plot(1:zx,Ysf2,'m',fitRange2,Ysf2(fitRange2),'r')
xlabel('BPM #')     % xlabel('BPM #:  BSY 8      LTU 39      Undulator 73   Dump 78')
ylabel('y [mm]')
axis([0 180 -.20001 .20001])
grid on
plot16




Xs=data0(:,7*3+1)-data0(:,1);
Ys=data0(:,7*3+2)-data0(:,2);
Xs(100)=Xs(99);
Ys(100)=Ys(99);
R1s(100,:)=R1s(99,:);
R3s(100,:)=R3s(99,:);
%i=1:size(Xs);
%fitStart = 50;
%fitEnd =   99;
%fitRange = fitStart:fitEnd;
%dXs(i) = ones(size(dXs))*10;
%dYs(i) = ones(size(dXs))*10;
%dXs(fitRange) = ones(1,fitEnd - fitStart + 1) * 0.01;
%dYs(fitRange) = ones(1,fitEnd - fitStart + 1) * 0.01;

[Xsf,Ysf,p,dp,chisq,Q] = ...
          xy_traj_fit_kick(Xs',dXs',Ys',dYs',0*Xs',0*Ys',R1s(:,:),R3s(:,:),zn,z0,fitI);
      p, [Xs(i136),  Xsf(i136),Ys(i136) , Ysf(i136)]
[Xsf2,Ysf2,p2,dp2,chisq2,Q] = ...
          xy_traj_fit_kick(Xs',dXs2',Ys',dYs2',0*Xs',0*Ys',R1s(:,:),R3s(:,:),zn,z0,fitI2);
      p2, [Xs(i136),  Xsf2(i136),Ys(i136) , Ysf2(i136)]
      
[dd,zx]=size(Xs');       
figure(12)
clf
subplot(311)
plot_bar(1:zx,Xs,'g')
plot(1:zx,Xsf,'c',fitRange,Xsf(fitRange),'b')
plot(1:zx,Xsf2,'m',fitRange2,Xsf2(fitRange2),'r')
%xlabel('BPM #')     % xlabel('BPM #:  BSY 8      LTU 39      Undulator 73   Dump 78')
ylabel('x [mm]')
plot16
grid on
axis([0 180 -.20001 .20001])
title('Difference of Diff-Orbits (YC04) of Night')


subplot(3,1,2:3)
plot_bar(1:zx,Ys,'g')
plot(1:zx,Ysf,'c',fitRange,Ysf(fitRange),'b')
plot(1:zx,Ysf2,'m',fitRange2,Ysf2(fitRange2),'r')
xlabel('BPM #')     % xlabel('BPM #:  BSY 8      LTU 39      Undulator 73   Dump 78')
ylabel('y [mm]')
plot16
grid on
axis([0 180 -1.0001 1.0001])
 
 
%plot(data(:,7*2+1)-data(:,1) - (data0(:,7*2+1)-data0(:,1)))
%hold on
%plot(data(:,7*2+1)-data(:,1),'r')
%xlabel('BPM #')
%ylabel('X [mm]')

%plot16
%grid on
%axis([0 180 -1.0001 1.0001])