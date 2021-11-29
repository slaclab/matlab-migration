% BS_finder.m
%
% jcsheppard
%  rev 0: December 9, 2014
%
% routine to plot BPM values from the_matrix vs ordinal
% used to find optimal Back Swing Correction
%
% n=7 ==>BPM BSY0 1
% n=42 ==>BPM UND1 100
% n=75 ==> BPM UND1 3390
%
qIQ=find(strncmp('BPMS:',data.ROOT_NAME,5));
JXf=2:3:length(qIQ);
JYf=3:3:length(qIQ);
%
XSSTOP=[97 171];
YSSTOP=[97 171];
%
BPM_id=[353 354]; %use bpm 450 to find the zeros (XZF) as well as the non-zeros (JX and JY)
%
X=data.the_matrix(qIQ(BPM_id(1)),:);
Y=data.the_matrix(qIQ(BPM_id(2)),:);
XZF=find(X==0);
if(XZF(1)==1) XZF(1)=2; end;
if(XZF(end)>=2800-24);XZF=XZF(1:end-1); end;
JX=find(X);
JY=find(Y);
%datra
Xp1=1000*mean(data.the_matrix(qIQ(JXf(XSSTOP(1):XSSTOP(2))),XZF+1),2);
Xp2=1000*mean(data.the_matrix(qIQ(JXf(XSSTOP(1):XSSTOP(2))),XZF+2),2);
Xm1=1000*mean(data.the_matrix(qIQ(JXf(XSSTOP(1):XSSTOP(2))),XZF-1),2);
Xp1std=1000*std(data.the_matrix(qIQ(JXf(XSSTOP(1):XSSTOP(2))),XZF+1),0,2);
Xp2std=1000*std(data.the_matrix(qIQ(JXf(XSSTOP(1):XSSTOP(2))),XZF+2),0,2);
Xm1std=1000*std(data.the_matrix(qIQ(JXf(XSSTOP(1):XSSTOP(2))),XZF-1),0,2);
Xmean=1000*mean(data.the_matrix(qIQ(JXf(XSSTOP(1):XSSTOP(2))),JX),2);
%
Yp1=1000*mean(data.the_matrix(qIQ(JYf(YSSTOP(1):YSSTOP(2))),XZF+1),2);
Yp2=1000*mean(data.the_matrix(qIQ(JYf(YSSTOP(1):YSSTOP(2))),XZF+2),2);
Ym1=1000*mean(data.the_matrix(qIQ(JYf(YSSTOP(1):YSSTOP(2))),XZF-1),2);
Yp1std=1000*std(data.the_matrix(qIQ(JYf(YSSTOP(1):YSSTOP(2))),XZF+1),0,2);
Yp2std=1000*std(data.the_matrix(qIQ(JYf(YSSTOP(1):YSSTOP(2))),XZF+2),0,2);
Ym1std=1000*std(data.the_matrix(qIQ(JYf(YSSTOP(1):YSSTOP(2))),XZF-1),0,2);
Ymean=1000*mean(data.the_matrix(qIQ(JYf(YSSTOP(1):YSSTOP(2))),JY),2);
%
%
subplot(1,1,1);
 plot(Xp1-Xmean,'-r');
hold on
plot(Xm1-Xmean,'-g');
plot(Xmean-Xmean,'-b');
plot(Xmean,'-k');
hold off
xlabel('BPM Ordinal: BPM1=BSY1; BPM7=BSY83; BPM42=UND100; BPM75=UND3390')
ylabel('X (microns)')
legend('n+1','n-1','Mean','BKG Subtract')
title(['BackSwing = ',num2str(BSC)])
%
figure
%pause;
%
%
subplot(1,1,1);
plot(Yp1-Ymean,'-r');
hold on
plot(Ym1-Ymean,'-g');
plot(Ymean-Ymean,'-b');
plot(Ymean,'k');
hold off
xlabel('BPM Ordinal: BPM1=BSY1; BPM7=BSY83; BPM42=UND100; BPM75=UND3390')
ylabel('Y (microns)')
legend('n+1','n-1','Mean','BKG Subtract')
title(['BackSwing = ',num2str(BSC)])
%
%
subplot(2,1,1)
errorbar(42:75,Xp1(42:75)-Xm1(42:75),sqrt(Xp1std(42:75).^2+Xm1std(42:75).^2),'r')
hold on
errorbar(42:75,Xp2(42:75)-Xm1(42:75),sqrt(Xp2std(42:75).^2+Xm1std(42:75).^2),'b')
legend(['(n+1)-(n-1) std=',num2str(std(Xp1(42:75)-Xm1(42:75)),'%0.2g'),' \mum'],['(n+2)-(n-1) std=',num2str(std(Xp2(42:75)-Xm1(42:75)),'%0.2g'),' \mum'])
xlabel('Undulator BPM Ordinal')
ylabel('BPM X (\mum)')
title('Horizontal n+1 and n+2 Undulator Trajectory')
hold off
subplot(2,1,2)
errorbar(42:75,Yp1(42:75)-Ym1(42:75),sqrt(Yp1std(42:75).^2+Ym1std(42:75).^2),'r')
hold on
errorbar(42:75,Yp2(42:75)-Ym1(42:75),sqrt(Yp2std(42:75).^2+Ym1std(42:75).^2),'b')
legend(['(n+1)-(n-1) std=',num2str(std(Yp1(42:75)-Ym1(42:75)),'%0.2g'),' \mum'],['(n+2)-(n-1) std=',num2str(std(Yp2(42:75)-Ym1(42:75)),'%0.2g'),' \mum'])
xlabel('Undulator BPM Ordinal')
ylabel('BPM Y (\mum)')
title('Vertical n+1 and n+2 Undulator Trajectory')
hold off
%
figure
%pause;
%
subplot(2,1,1)
plot(42:75,Xp1(42:75)-Xm1(42:75),'-r')
hold on
plot(42:75,Xp2(42:75)-Xm1(42:75),'-b')
legend(['(n+1)-(n-1) mae=',num2str(mean(abs((Xp1(42:75)-Xm1(42:75)))),'%0.2g'),' \mum'],['(n+2)-(n-1) mae=',num2str(mean(abs((Xp2(42:75)-Xm1(42:75)))),'%0.2g'),' \mum'])
xlabel('Undulator BPM Ordinal')
ylabel('BPM X (\mum)')
%title(['Run ',num2str(RunNum(1)),' and Run ',num2str(RunNum(2)),' Horizontal n+1 and n+2 Undulator Trajectory',...
%   ' Ebeam=',num2str(Ebeam),' BSA-data-',BSANUM(1),'-',BSANUM(2),'-',BSANUM(3),'-',BSANUM(4)])
title([strcat('Runs ',num2str(RunNum(1)),' and ',num2str(RunNum(2)),' Horiz n+1 and n+2 Und. Traj: ',...
    ' Ebeam=',num2str(Ebeam),' BSA-data-',BSANUM(1),'-',BSANUM(2),'-',BSANUM(3),'-',BSANUM(4))])
hold off
subplot(2,1,2)
plot(42:75,Xp1(42:75)-Xm1(42:75),'-r')
hold on
plot(42:75,Yp2(42:75)-Ym1(42:75),'-b')
legend(['(n+1)-(n-1) mae=',num2str(mean(abs((Yp1(42:75)-Ym1(42:75)))),'%0.2g'),' \mum'],['(n+2)-(n-1) mae=',num2str(mean(abs((Yp2(42:75)-Ym1(42:75)))),'%0.2g'),' \mum'])
xlabel('Undulator BPM Ordinal')
ylabel('BPM Y (\mum)')
title(['Run ',num2str(RunNum(1)),' and Run ',num2str(RunNum(2)),' Vertical n+1 and n+2 Undulator Trajectory',...
    ' PM1=',num2str(PM1),' BSC=',num2str(BSC),' XC71=',num2str(XC71),' YC72=',num2str(YC72)])
hold off
%