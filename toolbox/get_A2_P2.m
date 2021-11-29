function [a1a,p1a,a2a,p2a] = get_A2_P2(pvRF,delT)
%
% get_A2_P2.m
% uses get_wf_A_P to get the waveform and then get two amplitudes and
% phases for the two bunches delT apart
%
% e.g.:   [a1,p1,a2,p2] = get_A2_P2('L1X',15)
%
%  will get two amplitudes and two phase 15*9.8 ns apart for L1X

%
%
% or was saved gg_L1X...
%
%
% 
%load gg_wf_data10Hz

%  strcmp(upper(pvin),'L0B')
%  strcmp(upper(pvin),'L0B') || strcmp(upper(pvin),'20-8')
path(path,'/home/physics/decker/matlab/toolbox')
[gg,t,dt,nameold,name]=get_wf_A_P(pvRF);



pv2 = {    'ACCL:LI21:1:L1S_0_RAW_WF'
    'ACCL:LI21:1:L1S_1_RAW_WF'
    'ACCL:LI21:1:L1S_2_RAW_WF'
    'ACCL:LI21:1:L1S_3_RAW_WF'
    'KLYS:LI21:K1:L1S_0_RAW_WF'
    'KLYS:LI21:K1:L1S_1_RAW_WF'
    'KLYS:LI21:K1:L1S_2_RAW_WF'
    'KLYS:LI21:K1:L1S_3_RAW_WF'       % or Li28: 'PCAV:LI29:100:PH4_1_S_R_WF' 10 Hz
    'BPMS:LI21:233:X'
    'BPMS:LI24:801:X'
%    'BLEN:LI24:886:BL21B_S_R_WF'    %RAW_WF'
%    'PCAV:IN20:365:PH1_2_S_R_WF0'    %RAW_WF0'
%    'PCAV:LI25:300:PH3_3_S_R_WF1'    %RAW_WF1'
%    'BLEN:LI21:265:BL11A_S_R_WF'  %RAW_WF' };
};
% pv2{11}=('OSC:LR20:10:CH1_CALC_PHASE');
    
%UND:R02:IOC:10:BAT:FitTime1     % <-- BLD beam arrival time PVs
%UND:R02:IOC:10:BAT:FitTime2
pvref = {'LLRF:IN20:RH:REF_0_RAW_WF'
         'LLRF:IN20:RH:REF_1_RAW_WF'
         'LLRF:IN20:RH:REF_2_RAW_WF'
         'LLRF:IN20:RH:REF_3_RAW_WF' 
         'LLRF:IN20:RH:DGN_0_RAW_WF'
         'LLRF:IN20:RH:DGN_1_RAW_WF'
         'LLRF:IN20:RH:DGN_2_RAW_WF'
         'LLRF:IN20:RH:DGN_3_RAW_WF'  
         'PCAV:LI29:100:PH4_0_RAW_WF'
         'PCAV:LI29:100:PH4_1_RAW_WF'};
     
pvLSR = {'LASR:IN20:1:LSR_0_RAW_WF'
         'LASR:IN20:1:LSR_1_RAW_WF'
         'LASR:IN20:1:LSR_2_RAW_WF'
         'LASR:IN20:1:LSR_3_RAW_WF'
         'LASR:IN20:2:LSR_0_RAW_WF'
         'LASR:IN20:2:LSR_1_RAW_WF'
         'LASR:IN20:2:LSR_2_RAW_WF'
         'LASR:IN20:2:LSR_3_RAW_WF' };
     
pvTCAV0={'TCAV:IN20:490:TC0_0_RAW_WF'
         'TCAV:IN20:490:TC0_1_RAW_WF'
         'TCAV:IN20:490:TC0_2_RAW_WF'
         'TCAV:IN20:490:TC0_3_RAW_WF'
          'KLYS:LI20:K5:TC0_0_RAW_WF'
          'KLYS:LI20:K5:TC0_1_RAW_WF'
          'KLYS:LI20:K5:TC0_2_RAW_WF'
          'KLYS:LI20:K5:TC0_3_RAW_WF' };
        
pvuTCA={'LLRF:LI28:21:WF_REF_RAW'
        'LLRF:LI28:21:WF_VM_OUT_RAW' 
        'LLRF:LI28:21:WF_KLY_DRV_RAW'
        'LLRF:LI28:21:WF_KLY_OUT_RAW'
        'LLRF:LI28:21:WF_SLED_OUT_RAW' 
        'LLRF:LI28:21:WF_ACC_OUT_RF_RAW'
        'LLRF:LI28:21:WF_KLY_BEAM_V_RAW'
        'LLRF:LI28:21:WF_ACC_OUT_BEAM_RAW'};
    
pvuTCA2={'LLRF:LI28:21:WF_ADC0'
         'LLRF:LI28:21:WF_ADC1'
         'LLRF:LI28:21:WF_ADC2'
         'LLRF:LI28:21:WF_ADC3'
         'LLRF:LI28:21:WF_ADC4'
         'LLRF:LI28:21:WF_ADC5'
         'LLRF:LI28:21:WF_ADC6'
         'LLRF:LI28:21:WF_ADC7'
         'LLRF:LI28:21:WF_ADC8'
         'LLRF:LI28:21:WF_ADC9' };
pvGun = {    'GUN:IN20:1:GN1_0_RAW_WF' 
     'GUN:IN20:1:GN1_1_RAW_WF' 
     'GUN:IN20:1:GN1_2_RAW_WF' 
     'GUN:IN20:1:GN1_3_RAW_WF' 
     'KLYS:LI20:K6:GUN_0_RAW_WF'
     'KLYS:LI20:K6:GUN_1_RAW_WF'
     'KLYS:LI20:K6:GUN_2_RAW_WF'
     'KLYS:LI20:K6:GUN_3_RAW_WF' 
     'BPMS:LI21:233:X'};
    
pvL0AB = {    'ACCL:IN20:350:L0_0_RAW_WF'     % S_R --> RAW   ************************************
    'ACCL:IN20:350:L0_1_RAW_WF'
    'ACCL:IN20:350:L0_2_RAW_WF'
    'ACCL:IN20:350:L0_3_RAW_WF'
    'KLYS:LI20:K7:L0A_0_RAW_WF'
    'KLYS:LI20:K7:L0A_1_RAW_WF'
    'KLYS:LI20:K7:L0A_2_RAW_WF'
    'KLYS:LI20:K7:L0A_3_RAW_WF'
    'KLYS:LI20:K8:L0B_0_RAW_WF'
    'KLYS:LI20:K8:L0B_1_RAW_WF'
    'KLYS:LI20:K8:L0B_2_RAW_WF'
    'KLYS:LI20:K8:L0B_3_RAW_WF'
    'BPMS:IN20:731:X' };

pvL0B = {    'ACCL:IN20:350:L0_0_RAW_WF'     % S_R --> RAW   ************************************
    'ACCL:IN20:350:L0_1_RAW_WF'
    'ACCL:IN20:350:L0_2_RAW_WF'
    'ACCL:IN20:350:L0_3_RAW_WF'
    'KLYS:LI20:K8:L0B_0_RAW_WF'
    'KLYS:LI20:K8:L0B_1_RAW_WF'
    'KLYS:LI20:K8:L0B_2_RAW_WF'
    'KLYS:LI20:K8:L0B_3_RAW_WF'
    'BPMS:IN20:731:X' 
    'BLEN:LI21:265:AIMAX'     %BL11A_RAW_WF'   %S_R_WF'  %RAW_WF'
    };

pv3= {'ACCL:LI21:180:L1X_0_RAW_WF'
      'ACCL:LI21:180:L1X_1_RAW_WF'
      'ACCL:LI21:180:L1X_2_RAW_WF'
      'ACCL:LI21:180:L1X_3_RAW_WF'
      'KLYS:LI21:K2:L1X_0_RAW_WF'
      'KLYS:LI21:K2:L1X_1_RAW_WF'
      'KLYS:LI21:K2:L1X_2_RAW_WF'
      'KLYS:LI21:K2:L1X_3_RAW_WF'
      'BPMS:LI21:233:X'
      'BPMS:LI24:801:X'};
  
  pv4 = {'TCAV:LI24:800:TC3_0_RAW_WF'
         'TCAV:LI24:800:TC3_1_RAW_WF'
         'TCAV:LI24:800:TC3_2_RAW_WF'
         'TCAV:LI24:800:TC3_3_RAW_WF'
         'PCAV:LI25:300:PH3_0_RAW_WF' 
         'PCAV:LI25:300:PH3_1_RAW_WF' 
         'PCAV:LI25:300:PH3_2_RAW_WF' 
         'PCAV:LI25:300:PH3_3_RAW_WF' };
  %       'KLYS:LI24:K8:TC3_3_RAW_WF'};
   
 pvPhasCav= {  'UND:R02:IOC:10:BAT:Charge1'
               'UND:R02:IOC:10:BAT:FitTime1'
               'UND:R02:IOC:10:BAT:Charge2'
               'UND:R02:IOC:10:BAT:FitTime2'  };
 %              'UND:R02:IOC:10:BAT:Charge3'
 %              'UND:R02:IOC:10:BAT:FitTime3'
 %              'UND:R02:IOC:10:BAT:Charge4'
 %              'UND:R02:IOC:10:BAT:FitTime4' };
 
 pvXTCAV = { 'TCAV:DMP1:360:TCA:0:RAW_WF'
      'TCAV:DMP1:360:TCA:1:RAW_WF'
      'TCAV:DMP1:360:TCA:2:RAW_WF'
      'TCAV:DMP1:360:TCA:3:RAW_WF'
      'KLYS:DMP1:K1:TCA:0:RAW_WF'
      'KLYS:DMP1:K1:TCA:1:RAW_WF'
      'KLYS:DMP1:K1:TCA:2:RAW_WF'
      'KLYS:DMP1:K1:TCA:3:RAW_WF'
 %     'TCAV:DMP1:360:TCB:4:RAW_WF'    % or 4 5 6 7 ??
 %     'TCAV:DMP1:360:TCB:5:RAW_WF'
 %     'TCAV:DMP1:360:TCB:6:RAW_WF'
 %     'TCAV:DMP1:360:TCB:7:RAW_WF'
     };
 
RF_BPM = {    'BPMS:UND1:2390:RWAV'
    'BPMS:UND1:2490:RWAV'
    'BPMS:UND1:2590:RWAV'
    'BPMS:UND1:2690:RWAV'
    'BPMS:LI28:401:RWAV'
    'BPMS:LI28:501:RWAV'
    'BPMS:LI28:601:RWAV'
    'BPMS:IN20:221:RWAV'
     };
 
          

[i1 i2 i3]=size(gg);
i30=i3;
i512=i2;   %5000;
i280=i2;
gg1=reshape(gg(1,:,:),i512,i30);
gg2=reshape(gg(2,:,:),i512,i30);
gg3=reshape(gg(3,:,:),i512,i30);
gg4=reshape(gg(4,:,:),i512,i30);
gg5=reshape(gg(5,:,:),i512,i30);
gg6=reshape(gg(6,:,:),i512,i30);
gg7=reshape(gg(7,:,:),i512,i30);
%gg8=gg7;
gg8=reshape(gg(8,:,:),i512,i30);
%gg9=reshape(gg(9,:,:),i512,i30);
%gg10=reshape(gg(10,:,:),i512,i30);
%gg11=reshape(gg(11,:,:),i512,i30);
%gg12=reshape(gg(12,:,:),i512,i30);
%gg13=reshape(gg(13,:,:),i512,i30);%
%gg14=reshape(gg(14,:,:),i512,i30);
%g1r=((-atan2(gg1(3:4:80,:),gg1(4:4:80,:)))/pi*180);
%g1c=(( atan2(gg1(1:4:80,:),gg1(4:4:80,:)))/pi*180);
%g1b=((-atan2(gg1(1:4:80,:),gg1(2:4:80,:))-pi)/pi*180);
%g1m=(( atan2(gg1(3:4:80,:),gg1(2:4:80,:))-pi)/pi*180);
g1r=((-atan2(gg1(3:4:280,:),gg1(4:4:280,:)))/pi*180);
g1c=(( atan2(gg1(1:4:280,:),gg1(4:4:280,:)))/pi*180);
g1b=((-atan2(gg1(1:4:280,:),gg1(2:4:280,:))-pi)/pi*180);
g1m=(( atan2(gg1(3:4:280,:),gg1(2:4:280,:))-pi)/pi*180);
g2r=((-atan2(gg2(3:4:i280,:),gg2(4:4:i280,:)))/pi*180);
g2c=(( atan2(gg2(1:4:i280,:),gg2(4:4:i280,:)))/pi*180);
g2b=((-atan2(gg2(1:4:i280,:),gg2(2:4:i280,:))-pi)/pi*180);
g2m=(( atan2(gg2(3:4:i280,:),gg2(2:4:i280,:))-pi)/pi*180);
%i280=512;
ig=gg1(1:4:i280,:)-gg1(3:4:i280,:);
qg=gg1(2:4:i280,:)-gg1(4:4:i280,:);
piq=((-atan2(ig(:,:),qg(:,:))-pi)/pi*180);
aiq=sqrt(ig.^2+qg.^2);
%i280=512;
ig2=gg2(1:4:i280,:)-gg2(3:4:i280,:);
qg2=gg2(2:4:i280,:)-gg2(4:4:i280,:);
piq2=((-atan2(ig2(:,:),qg2(:,:))-pi)/pi*180);
aiq2=sqrt(ig2.^2+qg2.^2);
ig3=gg3(1:4:i280,:)-gg3(3:4:i280,:);
qg3=gg3(2:4:i280,:)-gg3(4:4:i280,:);
piq3=((-atan2(ig3(:,:),qg3(:,:))-pi)/pi*180);
aiq3=sqrt(ig3.^2+qg3.^2);
ig4=gg4(1:4:i280,:)-gg4(3:4:i280,:);
qg4=gg4(2:4:i280,:)-gg4(4:4:i280,:);
piq4=((-atan2(ig4(:,:),qg4(:,:))-pi)/pi*180);
aiq4=sqrt(ig4.^2+qg4.^2);
ig5=gg5(1:4:i280,:)-gg5(3:4:i280,:);
qg5=gg5(2:4:i280,:)-gg5(4:4:i280,:);
piq5=((-atan2(ig5(:,:),qg5(:,:))-pi)/pi*180);
aiq5=sqrt(ig5.^2+qg5.^2);
ig6=gg6(1:4:i280,:)-gg6(3:4:i280,:);
qg6=gg6(2:4:i280,:)-gg6(4:4:i280,:);
piq6=((-atan2(ig6(:,:),qg6(:,:))-pi)/pi*180);
aiq6=sqrt(ig6.^2+qg6.^2);
ig8=gg8(1:4:i280,:)-gg8(3:4:i280,:);
qg8=gg8(2:4:i280,:)-gg8(4:4:i280,:);
piq8=((-atan2(ig8(:,:),qg8(:,:))-pi)/pi*180);
aiq8=sqrt(ig8.^2+qg8.^2);
isp10=8;
if isp10==10
   ig9=gg9(1:4:i280,:)-gg9(3:4:i280,:);
   qg9=gg9(2:4:i280,:)-gg9(4:4:i280,:);
   piq9=((-atan2(ig9(:,:),qg9(:,:))-pi)/pi*180);
   aiq9=sqrt(ig9.^2+qg9.^2);
   ig10=gg10(1:4:i280,:)-gg10(3:4:i280,:);
   qg10=gg10(2:4:i280,:)-gg10(4:4:i280,:);
   piq10=((-atan2(ig10(:,:),qg10(:,:))-pi)/pi*180);
   aiq10=sqrt(ig10.^2+qg10.^2);
end


iga=gg1(1:i280-3,:)-gg1(3:i280-1,:);
qga=gg1(2:i280-2,:)-gg1(4:i280,:);
piqa=((-atan2(iga(:,:),qga(:,:))-pi)/pi*180);
aiqa=sqrt(iga.^2+qga.^2);
piqs=zeros(size(piqa));
piqs(4:4:end,:)= piqa(4:4:end,:)+0;
piqs(1:4:end,:)= piqa(1:4:end,:)+90;
piqs(2:4:end,:)= piqa(2:4:end,:)+180;
piqs(3:4:end,:)= piqa(3:4:end,:)+270;
%figure()
%plot(mod(piqs,360))

for i=1:12
    if exist(['gg' num2str(i)])
        gg0 = eval(['gg' num2str(i)]);
   %     gg0=gg1;
        iga=gg0(1:i280-3,:)-gg0(3:i280-1,:);
        qga=gg0(2:i280-2,:)-gg0(4:i280,:);
        piqa=((-atan2(iga(:,:),qga(:,:))-pi)/pi*180);
        aiqs=sqrt(iga.^2+qga.^2)/2;
        piqs=zeros(size(piqa));
        piqs(4:4:end,:)= piqa(4:4:end,:)+0;
        piqs(1:4:end,:)= piqa(1:4:end,:)+90;
        piqs(2:4:end,:)= piqa(2:4:end,:)+180;
        piqs(3:4:end,:)= piqa(3:4:end,:)+270;
        piqf=mod(piqs,360);
        if i==1
            ph1 = piqf;
            am1 = aiqs;
        end
        if i==2
            ph2 = piqf;
            am2 = aiqs;
        end
        if i==3
            ph3 = piqf;
            am3 = aiqs;
        end
        if i==4
            ph4 = piqf;
            am4 = aiqs;
        end
        if i==5
            ph5 = piqf;
            am5 = aiqs;
        end
        if i==6
            ph6 = piqf;
            am6 = aiqs;
        end
        if i==7
            ph7 = piqf;
            am7 = aiqs;
        end
        if i==8
            ph8 = piqf;
            am8 = aiqs;
        end
        if i==9
            ph9 = piqf;
            am9 = aiqs;
        end
        if i==10
            ph10 = piqf;
            am10 = aiqs;
        end
        if i==11
            ph11 = piqf;
            am11 = aiqs;
        end
        if i==12
            ph12 = piqf;
            am12 = aiqs;
        end
        if i==13
            ph13 = piqf;
            am13 = aiqs;
        end
        if i==14
            ph14 = piqf;
            am14 = aiqs;
        end
      
    end
end

    
        
   %     eval(['gg' num2str(i)])
 
 

mm=[mean(g1m)' mean(g1c)' mean(g1r)' mean(g1b)'];


i58=40;  %55; %1; %40;
i80=60;  %80; %20; %24;  %55;
i15= 3;
for i=1:i2/4-9  %105   %60   %40
    s11(i)=std(mean(piq (0+i:i15+i,:))-mean(piq8(i58:i80,:)));
    s12(i)=std(mean(piq2(0+i:i15+i,:))-mean(piq8(i58:i80,:))); %  piq(5:14,:)));   %9:28
    s13(i)=std(mean(piq3(0+i:i15+i,:))-mean(piq8(i58:i80,:))); 
    s14(i)=std(mean(piq4(0+i:i15+i,:))-mean(piq8(i58:i80,:)));  %3(21:40,:))); 
    s15(i)=std(mean(piq5(0+i:i15+i,:))-mean(piq8(i58:i80,:)));
    s16(i)=std(mean(piq6(0+i:i15+i,:))-mean(piq8(i58:i80,:)));
    s18(i)=std(mean(piq8(0+i:i15+i,:))-mean(piq8(i58:i80,:)));
    
    s88(i)=std(mean(piq8(0+i:9+i,:))-mean(piq6(11:20,:)));  
    s89(i)=std(mean(piq8(0+i:9+i,:))-mean(piq6(51:60,:)));  
%    s90(i)=std(mean(piq8(0+i:9+i,:))-mean(piq6(61:70,:)));  
 %   s22(i)=std(mean(piq2(9+i:28+i,:))-mean(piq3(45:64,:)));  
 %   s33(i)=std(mean(piq3(9+i:28+i,:))-mean(piq3(45:64,:))); 
 %   s44(i)=std(mean(piq4(9+i:28+i,:))-mean(piq3(45:64,:))); 
end



ii=find(isfinite(gg8(:,1))==1);
%ii=1:256;
figure()
tz=1/1000:1/100:max(ii)/100;
subplot(2,2,1)
ggd=gg5;plot(tz,ggd(ii,:)); hold on; plot(tz,std(ggd(ii,:)')*1000,'r'),grid on
plot16
%xlabel('Time [us]')
title(['                            PAC-Out ' nameold ' Klystron PAD'])    % C-RFLT
axis([0 5 -20000 +40000])

subplot(2,2,2)
ggd=gg6;plot(tz,ggd(ii,:)); hold on; plot(tz,std(ggd(ii,:)')*1000,'r'),grid on
plot16
%xlabel('Time [us]')
title('Drive');     % 'Drive')  B-RFLT    
axis([0 5 -20000 +40000])

subplot(2,2,3)
ggd=gg7;plot(tz,ggd(ii,:)); hold on; plot(tz,std(ggd(ii,:)')*1000+mean(ggd(ii,:)'),'r'),grid on
plot16
xlabel('Time [us]')
title('HV')      
axis([0 5 -24000 -16000])

subplot(2,2,4)
ggd=gg8;plot(tz,ggd(ii,:)); hold on; plot(tz,std(ggd(ii,:)')*1000,'r'),grid on
plot16
xlabel('Time [us]')
title('FWD')      
axis([0 5 -20000 +40000])

figure()
%tz=1/1000:1/100:i280/100;
subplot(2,2,1)
ggd=gg1;plot(tz,ggd(ii,:)); hold on; plot(tz,std(ggd(ii,:)')*1000,'r'),grid on
plot16
%xlabel('Time [us]')
title(['                             Chan 0  ' nameold ' Accelerator PAD'])
axis([0 5.00001 -20000 +40000])

subplot(2,2,2)
ggd=gg2;plot(tz,ggd(ii,:)); hold on; plot(tz,std(ggd(ii,:)')*1000,'r'),grid on
plot16
%xlabel('Time [us]')
title('Chan 1')          
axis([0 5 -20000 +40000])

subplot(2,2,3)
ggd=gg3;plot(tz,ggd(ii,:)); hold on; plot(tz,std(ggd(ii,:)')*1000,'r'),grid on
plot16
xlabel('Time [us]')
title('Chan 2')    
axis([0 5 -20000 +40000])

subplot(2,2,4)
ggd=gg4;plot(tz,ggd(ii,:)); hold on; plot(tz,std(ggd(ii,:)')*1000,'r'),grid on
plot16
xlabel('Time [us]')
title('Chan 3')    
axis([0 5 -20000 +40000])



%figure
%plot((gg7'-ones(i30,1)*mean(gg7'))')
%axis([0 500 -100 150])
%grid on
%plotfj18
%xlabel('Time [10ns]')
%ylabel('Voltage Difference [350/22000 kV]')
ggdd=(gg7'-ones(i30,1)*mean(gg7'));
i380=max(find(isfinite(gg7(:,1))==1));
st7=round(std(mean(ggdd(:,120:320)'))/22000*1e6);
[ii2,kk2]=find(ggdd(:,i380)>-20);
st72=round(std(mean(ggdd(ii2,120:320)'))/22000*1e6);
%title(['L1S High Voltage Jitter ' num2str(st7) ' ppm (' num2str(st72) ' ppm)'])

k10=10;
gga7=gg7(1:k10:500,:);
for i=1:k10-1
    gga7=gga7+gg7(1+i:k10:500+i,:);
end
gga7=(gga7/k10);
ggdda=(gga7'-ones(i30,1)*mean(gga7'));

gga4=gg7(1:4:508,:);
for i=1:3
    gga4=gga4+gg7(1+i:4:508+i,:);
end
gga4=(gga4/4);
ggdda4=(gga4'-ones(i30,1)*mean(gga4'));


for i=5:46
    st7ai(i)=round(std(mean(ggdda(:,i-4:i+4)'))/22000*1e6);
end
i3_9=3:9;
i3_9=15:18;              % TS timeslot
i3_9=9:15;  
i3_9=10:16;
i3_9=14:20;
%i3_9=100:103;
gga7mm=mean(mean(gga7(i3_9,:)));
[kk7p,ddkp] = find(mean(gga7(i3_9,:)) >= gga7mm);   %ddkp is the right one
[kk7m,ddkm] = find(mean(gga7(i3_9,:)) <= gga7mm);   %20:30


[maa2,iaa2]=max(std(gga7'))
for ii4=1:50
cc=corrcoef(gga7(6,:),gga7(ii4,:));
ccaa(ii4)=cc(1,2);
end

gga7m=(gga7(:,ddkm)')-ones(size(ddkm'))*mean(gga7(:,ddkm)');
gga7p=(gga7(:,ddkp)')-ones(size(ddkp'))*mean(gga7(:,ddkp)');
gga7all=[gga7p' gga7m'];
%for i=5:46
%    st7allold(i)=round(std(mean(gga7all(:,i-4:i+4),2))/22000*1e6);
%end
st7allnew=(std(gga7all(:,:)'))/22000*1e6;

ggddp=((ggdd(ddkp,:)-ones(size(ddkp'))*mean(ggdd(ddkp,:)))');
ggddm=((ggdd(ddkm,:)-ones(size(ddkm'))*mean(ggdd(ddkm,:)))');
ggddaa=[ggddp ggddm];
clear mmggaa1;


for i=5:508
    stggaa1(i)=(std(mean(ggddaa(i-4:i+4,:)))/22000*1e6);
    mmggaa1(i,:)=((mean(ggddaa(i-4:i+4,:))));
end


 st7aa=round(mean(stggaa1(120:320)));

ggtsp=mean(ggdd(ddkp,:))-mean(ggdd);
ggtsm=mean(ggdd(ddkm,:))-mean(ggdd);

%  util_printLog(10)

cc_V_ph=corrcoef(mean(piq8(49:88,ddkm)),mean(gg7(291:343,ddkm)))



% y=[zeros(1,100) ones(1,100) zeros(1,100)];
% plot(y.*exp([1:300]/-60))
% plot(gg7(:,1)'./exp([1:512]/-2800)*-1.24/100)
dh=zeros(size(gg7));
dh(1,:)=gg7(1,:); 
dh(2:i512,:)=gg7(2:i512,:)-gg7(1:i512-1,:); 
% plot(cumsum(dh))
i3000=2500;
delx=gg7*(1-exp(-1/i3000));
dh2=dh+delx;
hint2=cumsum(dh2);     % *1.3/100;
scale=-min(min(hint2));
HVMKSU = lcaGet(['KLYS:LI' nameold(1:2) ':' nameold(4) '1:BVLT']);
sc2=HVMKSU / scale;
hint2=hint2*sc2;

gh7=hint2;



%figure
%plot([-4:.01:1.11]*9.8/10,gh7(:,:)'*-1.24/1)   %./(ones(i30,1)*exp([1:512]/-2800))*-1.24/100)
%grid
%plotfj18
%title('KLYS 21-1 Beam High Voltage')
%xlabel('Time [us]')
%ylabel('Voltage [kV]')
gg7exp=gh7*-1.24/1;     % (gg7(:,:)'./(ones(i30,1)*exp([1:512]/-2800))*-1.24/100)';
%hold on
% plot([-4:.01:1.11]*9.8/10,std(gg7exp')*1000000/310,'r')

gga7e=gg7exp(1:10:500,:);
for i=1:9
    gga7e=gga7e+gg7exp(1+i:10:500+i,:);
end

gga7e=(gga7e/10);
ggddae=(gga7e'-ones(i30,1)*mean(gga7e'));

gga4e=gg7exp(1:4:508,:);
for i=1:3
    gga4e=gga4e+gg7exp(1+i:4:508+i,:);
end
gga4e=(gga4e/4);
ggdda4e=(gga4e'-ones(i30,1)*mean(gga4e'));

% plot([-4:.04:1.11-0.04]*9.8/10,std(ggdda4e*1000000/310))
%plot([-4:.10:1.11-0.10*2]*9.8/10,std(ggddae*1000000/310),'g')

%axis([-4 1 0 600])

% plot([-4:.01:1.11]*9.8/10,ones(i30,1)*mean(gg7exp')+100*(gg7exp'-ones(i30,1)*mean(gg7exp')))
gg7exp4=zeros(size(gg7));
for i=2:510
    gg7exp4(i,:)=mean(gg7exp(i-1:i+2,:));
end
gg7exp4(1,:)=gg7exp4(2,:);
gg7exp4(511,:)=gg7exp4(510,:);
gg7exp4(512,:)=gg7exp4(510,:);

gg7exp16=zeros(size(gg7));
for i=8:504
    gg7exp16(i,:)=mean(gg7exp(i-7:i+8,:));
end
gg7exp16(1:7,:)=ones(7,1)*gg7exp16(8,:);
gg7exp16(505:512,:)=ones(8,1)*gg7exp16(504,:);

gg7exp64=zeros(size(gg7));
for i=32:480
    gg7exp64(i,:)=mean(gg7exp(i-31:i+32,:));
end
gg7exp64(1:31,:)=ones(31,1)*gg7exp64(32,:);
gg7exp64(481:512,:)=ones(32,1)*gg7exp64(480,:);

gg7expave=mean(gg7exp,2);
gg7exp4ave=mean(gg7exp4,2);
gg7exp16ave=mean(gg7exp16,2);
gg7exp64ave=mean(gg7exp64,2);

t_us=[-4.08:.01:1.03]*9.8/10;
[t0,i0]=min(abs(lcaGet(['KLYS:LI' nameold(1:2) ':' nameold(4)  '1:PADO_US'])-t_us)); %abs ???
%HVMKSU = lcaGet(['KLYS:LI' nameold(1:2) ':' nameold(4) '1:BVLT']);
m310=max(gg7expave);
sc=HVMKSU / m310;
std64=std((gg7exp64-gg7exp64ave*ones(1,i30))')*1E6/m310;
[mdd imd]=max(std64(1:200));     % was 300, but at 300 higher std
[minbeam imm]=min(std64(imd:512));
minres=min(std((gg7exp64-gg7exp64ave*ones(1,i30))')*1E6/m310);
stdppm = 0; sqrt(minbeam.^2 - minres.^2);
if stdppm == 0
    stdppm = sqrt(minbeam.^2 - 40.^2);
end






figure
%plot(t_us,sc*gg7expave,'k')
plot(1:512,sc*gg7expave,'k')
hold on , grid on
%plot(t_us,sc*(20*(gg7expave-(gg7expave(i0)))+(gg7expave(i0))),'m')
%line([t_us(i0) t_us(i0)],[0 1000])
%plot(t_us,std((gg7exp-gg7expave*ones(1,i30))')*1E6/m310,'r')
%plot(t_us,std((gg7exp4-gg7exp4ave*ones(1,i30))')*1E6/m310,'g')
%plot(t_us,std((gg7exp16-gg7exp16ave*ones(1,i30))')*1E6/m310,'b')
%plot(t_us,std((gg7exp64-gg7exp64ave*ones(1,i30))')*1E6/m310,'k')

%axis([0 500 0 400])
plotfj18
title(['KLYS ' nameold ' HV (k), FWD Amplitude (r), Phase (b)'])   %(' num2str(round(stdppm)) ' ppm)'])
xlabel('Time [9.8 ns]')
ylabel('HV [kV], A [cts/100], P [deg]')    %RMS [ppm]')

plot(2:510,am8/100,'r')
%plot(ph8)

am8m=mean(am8,2);
am8max=max((am8m));
igo=find(am8m>am8max*.05);
ph8c=zeros(509,1);
ph8c(igo)=(mean(ph8(igo,:),2));
plot(2:510,ph8c)
axx1 = round((igo(1)-80)/100)*100;
axx2 = min(500,round((igo(end)+80)/100)*100);
axis([axx1 axx2 0 400])


if strcmp(nameold,'20-6') || strcmp(name,'Gun')
   name2='GUN:IN20:1:GN1_0';    %_OFST'
end
if strcmp(nameold,'20-7') || strcmp(name,'L0A')
   name2='ACCL:IN20:350:L0_0';  %_OFST'
end
if strcmp(nameold,'20-8') || strcmp(name,'L0B')
   name2='ACCL:IN20:350:L0_2';  %_OFST'
end
if strcmp(nameold,'21-1') || strcmp(name,'L1S')
   name2='ACCL:LI21:1:L1S_0';  %_OFST'
end
if strcmp(nameold,'21-2') || strcmp(name,'L1X')
   name2='ACCL:LI21:180:L1X_0';  %_OFST'
end


figure
plot(2:510,am1/100,'r','linewidth',1.5)
hold on, grid on
am1m=mean(am1,2);
am1max=max((am1m));
igo1=find(am1m>am1max*.1);
ph1c=zeros(509,1);
ph1c(igo1)=(mean(ph1(igo1,:),2));
plot(2:510,ph1c,'linewidth',1.5)
axx1 = max(0,round((igo1(1)-80)/100)*100);
axx2 = min(500,round((igo1(end)+80)/100)*100);
axis([axx1 axx2 0 400])
delax =axx2-axx1;
plotfj18
title(['ACC ' nameold ' FWD Amplitude (r), Phase (b)'])   %(' num2str(round(stdppm)) ' ppm)'])
xlabel('Time [9.8 ns]')
ylabel('A [cts/100], P [deg]')    %RMS [ppm]')


off0=lcaGet([name2 '_OFST'])
si=lcaGet([name2 '_SIZE'])

line([off0    off0   ],[-1000 30000],'lineWidth',1.5,'color','b')
line([off0+si off0+si],[-1000 30000],'lineWidth',1.5,'color','b')

amav=round(mean(am1m(off0-1:off0-1+si))/10)/10
text(off0-delax/8,amav,num2str(amav),'fontsize',16,'color','r')
phav=round(mean(ph1c(off0-1:off0-1+si))*10)/10
text(off0-delax/8,phav,num2str(phav),'fontsize',16,'color','b')

%delT = 72

off2=off0+delT;

col =[ 0 0.7 0];           % dark green
line([off2    off2   ],[-1000 30000],'lineWidth',1.5,'color',col)
line([off2+si off2+si],[-1000 30000],'lineWidth',1.5,'color',col)

amav2=round(mean(am1m(off2-1:off2-1+si))/10)/10
text(off2+si+delax/40,amav2,num2str(amav2),'fontsize',16,'color','r')
phav2=round(mean(ph1c(off2-1:off2-1+si))*10)/10
text(off2+si+delax/40,phav2,num2str(phav2),'fontsize',16,'color','b')

a1a = mean(am1m(off0-1:off0-1+si))/100;
p1a = mean(ph1c(off0-1:off0-1+si));
a2a = mean(am1m(off2-1:off2-1+si))/100;
p2a = mean(ph1c(off2-1:off2-1+si));




lcaGet('KLYS:LI20:81:BVLT')
lcaGet('KLYS:LI20:81:PADO_US')
lcaGet(['KLYS:LI' num2str(20) ':' num2str(8) '1:PADO_US'])

tax=(1:(1*512))/1000*9.8;
