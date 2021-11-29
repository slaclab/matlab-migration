% JANICE_UND_LAUNCH.m
%
% rev 0: january 26, 2015
% rev 1: february 02, 2015: add 6th bpm (890) and also bsa-data index finder to data
% for bpms
%jcs and tjs
%
%routine to fit undulator launch (X and Y)amplitude to 5 bpms readings
%this is somewhat hardcoded to the LCLS 120Hz fdbk launch: launch point is
%a RFBU03; BPM readings=[RFB03 RFBU04 RFBU05 RFBU06 RFBU07] in X and Y
%
% use function GET_Undulator_Launch_Matrices(Ebeam) to get launch fit
% coefficients
%
% Ebeam=beam energy in GeV
% 
% Launch_Matrices=[BetaX BetaY 0 0 0 0;AX;AY;RX;RY]
%
% Xo = RX*Xi ==> Xi = (RX'RX)^-1RX'Xo = AX*Xo
% Xo = six BPM readings;
% Xi = launch position and angle
%
% Ebeam=14.940;
%
%
MTRY=Get_Undulator_Launch_Matrices(Ebeam);
%
AX=MTRY(2:3,:);
AY=MTRY(4:5,:);
BetaX=[1/MTRY(1,1) MTRY(1,1)];
BetaY=[1/MTRY(1,2) MTRY(1,2)];
%
%%XOUT=[RFBU03X RFBU04X RFBU05X RFBU06X RFBU07X RFBU08Y]';% needs to be read in
%%YOUT=[RFBU03Y RFBU04Y RFBU05Y RFBU06Y RFBU07Y RFBU08Y]';% needs to be read in
% find index for bpm bsa data
for ii = 1:6
    bpmxname = ['BPMS:UND1:' num2str(2 + ii) '90:X'];
    IDX(ii)=find(strncmp(bpmxname,data.ROOT_NAME,15)); %#ok<*SAGROW>
    bpmyname = ['BPMS:UND1:' num2str(2 + ii) '90:Y'];
    IDY(ii)=find(strncmp(bpmyname,data.ROOT_NAME,15));
end
%
%
RBINNED = BSAdataLaunch_Read([IDX(1) IDY(1)],data);
sRB = size(RBINNED);
ROUT = [RBINNED zeros(sRB(1),(sRB(2) * 5))];
RBIN_ALL = BSAdataLaunch_Read_ALL([IDX(1) IDY(1)],data);
sRBA = size(RBIN_ALL);
ROUT_ALL = [RBIN_ALL zeros(sRBA(1),(sRBA(2) * 5))];
for jj=2:6;
    RBINNED=BSAdataLaunch_Read([IDX(jj) IDY(jj)],data);
    ROUT(:,(2*jj - 1):(2*jj)) = RBINNED;
    RBIN_ALL=BSAdataLaunch_Read_ALL([IDX(jj) IDY(jj)],data);
    ROUT_ALL(:,(sRBA(2)*(jj-1)+1):(sRBA(2)*jj))=RBIN_ALL;
end;
%Use RX and RY to generate dummy data for testing
%XIN_test=[1;0.25]
%YIN_test=[0.5;-0.45]
RX=MTRY(6:7,:)';
RY=MTRY(8:9,:)';
% convert ROUT in mm to XOUT and YOUT in m
XOUT=1e-3*ROUT(:,1:2:11)';
YOUT=1e-3*ROUT(:,2:2:12)';
%
%stuff XOUT_ALL(6,116,24) and YOUT_ALL(6,116,24)
% find length of data array and use to stuff XOUT_ALL and YOUT_ALL
N_Length=length(ROUT_ALL)/12;
XOUT_ALL=zeros(6,N_Length,24);
YOUT_ALL=zeros(6,N_Length,24);
XOUT_ALL_REF24=zeros(6,N_Length,24);
YOUT_ALL_REF24=zeros(6,N_Length,24);
%
for jj=1:6
    XOUT_ALL(jj,:,:)=1e-3*ROUT_ALL(:,2*(jj-1)*N_Length+1:(2*(jj-1)+1)*N_Length)';
    YOUT_ALL(jj,:,:)=1e-3*ROUT_ALL(:,(2*(jj-1)+1)*N_Length+1:2*jj*N_Length)';
end;
% use n=24 as reference orbit
XOUT_Ref=XOUT(:,24);
YOUT_Ref=YOUT(:,24);
XOUT_ALL_Ref=XOUT_ALL(:,:,24);
YOUT_ALL_Ref=YOUT_ALL(:,:,24);
%
XIN=AX*(XOUT-XOUT_Ref*ones(1,24));
YIN=AY*(YOUT-YOUT_Ref*ones(1,24));
XUND=zeros(2,N_Length,24);
YUND=zeros(2,N_Length,24);
for jj=1:24;
    XOUT_ALL_REF24(:,:,jj)=(XOUT_ALL(:,:,jj)-XOUT_ALL_Ref(:,:));
    YOUT_ALL_REF24(:,:,jj)=(YOUT_ALL(:,:,jj)-YOUT_ALL_Ref(:,:));
    XUND(:,:,jj)=AX*(XOUT_ALL(:,:,jj)-XOUT_ALL_Ref(:,:));
    YUND(:,:,jj)=AY*(YOUT_ALL(:,:,jj)-YOUT_ALL_Ref(:,:));
end;
%
DeltaX=XOUT-XOUT_Ref*ones(1,24)-RX*XIN;
DeltaY=YOUT-YOUT_Ref*ones(1,24)-RY*YIN;
%
Launch_Amplitude_X=sign(XIN(2,:)').*((BetaX*(XIN.*XIN))');
Launch_Amplitude_Y=sign(YIN(2,:)').*((BetaY*(YIN.*YIN))');
%
%calculate LSQ fit errors
%
Launch_Amplitude_Errors;
%
% alternatively, find the std of the 116 launches for each of the 24 bins
%
XTsq=(XUND(:,:,:).*XUND(:,:,:));
YTsq=(YUND(:,:,:).*YUND(:,:,:));
XU_errors=[squeeze(mean(XTsq(1,:,:),2))-squeeze(mean(XUND(1,:,:),2)).^2 ...
    squeeze(mean(XTsq(2,:,:),2))-squeeze(mean(XUND(2,:,:),2)).^2 ...
    squeeze(mean(XUND(1,:,:).*XUND(2,:,:),2))-squeeze(mean(XUND(1,:,:),2)).*squeeze(mean(XUND(2,:,:),2))];
%
YU_errors=[squeeze(mean(YTsq(1,:,:),2))-squeeze(mean(YUND(1,:,:),2)).^2 ...
    squeeze(mean(YTsq(2,:,:),2))-squeeze(mean(YUND(2,:,:),2)).^2 ...
    squeeze(mean(YUND(1,:,:).*YUND(2,:,:),2))-squeeze(mean(YUND(1,:,:),2)).*squeeze(mean(YUND(2,:,:),2))];
%
XTerrors=Ebeam/0.511e-3*sqrt(diag(XU_errors*...
    [4*BetaX(1)^2*squeeze(mean(XTsq(1,:,:),2))';...
    4*BetaX(2)^2*squeeze(mean(XTsq(2,:,:),2))';...
    8*squeeze(mean(XUND(1,:,:).*XUND(2,:,:),2))']));
%
%
YTerrors=Ebeam/0.511e-3*sqrt(diag(YU_errors*...
    [4*BetaY(1)^2*squeeze(mean(YTsq(1,:,:),2))';...
    4*BetaY(2)^2*squeeze(mean(YTsq(2,:,:),2))';...
    8*squeeze(mean(YUND(1,:,:).*YUND(2,:,:),2))']));
%
for jj=1:24
    XT_mean(jj)=Ebeam/0.511e-3*mean(BetaX*XTsq(:,:,jj));
    YT_mean(jj)=Ebeam/0.511e-3*mean(BetaY*YTsq(:,:,jj));
    XT_ERR(jj)=Ebeam/0.511e-3*std(BetaX*XTsq(:,:,jj));
    YT_ERR(jj)=Ebeam/0.511e-3*std(BetaY*YTsq(:,:,jj));
end;
%
%
%
n=2:24;
m=[0 24];
gemit_nominal=[-1.5e-6 -1.5e-6;1.5e-6 1.5e-6];
%
subplot(1,1,1);
errorbar(n,XIN(1,2:24),squeeze(std(XOUT_ALL_REF24(1,:,2:24),0,2)),'xb')
hold on
errorbar(n,YIN(1,2:24),squeeze(std(YOUT_ALL_REF24(1,:,2:24),0,2)),'*r')
hold off
%legend('X Launch','Y Launch','\gamma\epsilon_X_Y')
legend('X Launch','Y Launch')
%axis([m 1.25*gemit_nominal(:,1)']);
xlabel('Pulse_i_d (ordinal, n=1 ==>extracted pulse)')
ylabel('BPMS:UND1:0390:X_f_i_t and Y_f_i_t Launch wrt n=24 (m)')
title(['BackSwing Correction = ',num2str(BSC),'  Ebeam = ',num2str(Ebeam),' GeV BSA 2015-',num2str(bsanum(1)),'-',num2str(bsanum(2)),'-',num2str(bsanum(3))]);
%
%pause;
figure
%
%errorbar(n,Ebeam/0.511e-3*Launch_Amplitude_X(2:24),ErrorX(2:24))
errorbar(n,Ebeam/0.511e-3*Launch_Amplitude_X(2:24),XT_ERR(2:24),'.')
hold on
%errorbar(n,Ebeam/0.511e-3*Launch_Amplitude_Y(2:24),ErrorY(2:24),'g')
errorbar(n,Ebeam/0.511e-3*Launch_Amplitude_Y(2:24),YT_ERR(2:24),'.r')
%plot( m,gemit_nominal(1,:),'-r',m,gemit_nominal(2,:),'-r');
hold off
%legend('X Launch','Y Launch','\gamma\epsilon_X_Y')
legend('X Launch','Y Launch')
%axis([m 1.25*gemit_nominal(:,1)']);
xlabel('Pulse_i_d (ordinal, n=1 ==>extracted pulse)')
ylabel('Normalized Undulator Launch (m)')
title(['BackSwing Correction = ',num2str(BSC),'  Ebeam = ',num2str(Ebeam),' GeV BSA 2015-',num2str(bsanum(1)),'-',num2str(bsanum(2)),'-',num2str(bsanum(3))]);
%
%
figure
%pause;
%
%errorbar(n,Ebeam/0.511e-3*Launch_Amplitude_X(2:24),ErrorX(2:24))
errorbar(n,XT_mean(2:24),XT_ERR(2:24),'.')
hold on
%errorbar(n,Ebeam/0.511e-3*Launch_Amplitude_Y(2:24),ErrorY(2:24),'g')
errorbar(n,YT_mean(2:24),YT_ERR(2:24),'.r')
%plot( m,gemit_nominal(1,:),'-r',m,gemit_nominal(2,:),'-r');
hold off
%legend('X Launch','Y Launch','\gamma\epsilon_X_Y')
legend('X Launch','Y Launch')
%axis([m 1.25*gemit_nominal(:,1)']);
xlabel('Pulse_i_d (ordinal, n=1 ==>extracted pulse)')
ylabel('Normalized Undulator Launch (m)')
title(['BackSwing Correction = ',num2str(BSC),'  Ebeam = ',num2str(Ebeam),' GeV BSA 2015-',num2str(bsanum(1)),'-',num2str(bsanum(2)),'-',num2str(bsanum(3))]);
%
%
figure
%pause;
%
%
subplot(2,2,2)
plot(squeeze(XUND(1,:,2:23)),squeeze(YUND(1,:,2:23)),'.r');
title(['X-Y Fit: \sigma_X_f_i_t= ',num2str(std((reshape(XUND(1,:,2:23),1,22*N_Length))),'%0.3g'),' m','   \sigma_Y_f_i_t= ',num2str(std((reshape(YUND(1,:,2:23),1,22*N_Length))),'%0.3g'),' m']);
xlabel('BPMS:UND1:0390:X_f_i_t (m)');
ylabel('BPMS:UND1:0390:Y_f_i_t (m)');
subplot(2,2,1);
plot(squeeze(XOUT_ALL_REF24(1,:,2:23)),squeeze(YOUT_ALL_REF24(1,:,2:23)),'.r');
title(['X-Y Data: \sigma_X_d_a_t_a= ',num2str(std((reshape(XOUT_ALL_REF24(1,:,2:23),1,22*N_Length))),'%0.3g'),' m','   \sigma_Y_d_a_t_a= ',num2str(std((reshape(YOUT_ALL_REF24(1,:,2:23),1,22*N_Length))),'%0.3g'),' m']);
xlabel(['BPMS:UND1:0390:X_d_a_t_a (m)',' GeV BSA 2015-',num2str(bsanum(1)),'-',num2str(bsanum(2)),'-',num2str(bsanum(3))]);
ylabel('BPMS:UND1:0390:Y_d_a_t_a (m)');
subplot(2,2,3)
plot(squeeze(XUND(1,:,2:23)),squeeze(XOUT_ALL_REF24(1,:,2:23)),'.r');
title(['X_f_i_t vs X_d_a_t_a: \sigma_X_f_i_t= ',num2str(std((reshape(XUND(1,:,2:23),1,22*N_Length))),'%0.3g'),' m','   \sigma_X_d_a_t_a= ',num2str(std((reshape(XOUT_ALL_REF24(1,:,2:23),1,22*N_Length))),'%0.3g'),' m']);
xlabel('BPMS:UND1:0390:X_d_a_t_a (m)');
ylabel('BPMS:UND1:0390:X_f_i_t (m)');
subplot(2,2,4);
plot(squeeze(YUND(1,:,2:23)),squeeze(YOUT_ALL_REF24(1,:,2:23)),'.r');
title(['Y_f_i_t vs Y_d_a_t_a: \sigma_Y_f_i_t= ',num2str(std((reshape(YUND(1,:,2:23),1,22*N_Length))),'%0.3g'),' m','   \sigma_Y_d_a_t_a= ',num2str(std((reshape(YOUT_ALL_REF24(1,:,2:23),1,22*N_Length))),'%0.3g'),' m']);
xlabel('BPMS:UND1:0390:Y_d_a_t_a (m)');
ylabel('BPMS:UND1:0390:Y_f_i_t (m)');