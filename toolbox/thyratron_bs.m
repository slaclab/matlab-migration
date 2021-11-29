function [gg75exp,t,dt,nameold] = thyratron_bs(pvin,ijk,i30)
%   [gg75exp,t,dt,nameold] = thratron_bs(PVin,time_us,pulse_number)
%   shows the thyratron back swing problem
%   e.g.:    thyratron_bs('L1S') or
%   default: thyratron_bs('21-1',25,100)


% old stuff
% get_HVjit gets the 8 PAD readings from the desired station and makes
% displays
% function [gg,t,dt] = get_HVjit(pvin,ij)
% pv = wf_pv OR station name: 'L1S', '20-8', 'XTCAV' ...
% ij = number of samples  OR 100 when empty
path(path,'/home/physics/decker/matlab/toolbox')

if ~exist('pvin')
    pvin = 'L1S';
end

if ~exist('ijk')
    ijk = 25;
end
ijk=round(ijk/5);
 

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

pvref = {'LLRF:IN20:RH:REF_0_S_R_WF'
         'LLRF:IN20:RH:REF_1_S_R_WF'
         'LLRF:IN20:RH:REF_2_S_R_WF'
         'LLRF:IN20:RH:REF_3_S_R_WF' };
     
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
     'KLYS:LI20:K6:GUN_3_RAW_WF' };
    
pvL0A = {    'ACCL:IN20:350:L0_0_RAW_WF'     % S_R --> RAW   ************************************
    'ACCL:IN20:350:L0_1_RAW_WF'
    'ACCL:IN20:350:L0_2_RAW_WF'
    'ACCL:IN20:350:L0_3_RAW_WF'
    'KLYS:LI20:K7:L0A_0_RAW_WF'
    'KLYS:LI20:K7:L0A_1_RAW_WF'
    'KLYS:LI20:K7:L0A_2_RAW_WF'
    'KLYS:LI20:K7:L0A_3_RAW_WF'
    'BPMS:IN20:731:X' };

pvL0B = {    'ACCL:IN20:350:L0_0_RAW_WF'     % S_R --> RAW   ************************************
    'ACCL:IN20:350:L0_1_RAW_WF'
    'ACCL:IN20:350:L0_2_RAW_WF'
    'ACCL:IN20:350:L0_3_RAW_WF'
    'KLYS:LI20:K8:L0B_0_RAW_WF'
    'KLYS:LI20:K8:L0B_1_RAW_WF'
    'KLYS:LI20:K8:L0B_2_RAW_WF'
    'KLYS:LI20:K8:L0B_3_RAW_WF'
    'BPMS:IN20:731:X' };

pv3= {'ACCL:LI21:180:L1X_0_RAW_WF'
      'ACCL:LI21:180:L1X_1_RAW_WF'
      'ACCL:LI21:180:L1X_2_RAW_WF'
      'ACCL:LI21:180:L1X_3_RAW_WF'
      'KLYS:LI21:K2:L1X_0_RAW_WF'
      'KLYS:LI21:K2:L1X_1_RAW_WF'
      'KLYS:LI21:K2:L1X_2_RAW_WF'
      'KLYS:LI21:K2:L1X_3_RAW_WF'};
  
  pv4 = {'TCAV:LI24:800:TC3_0_RAW_WF'
         'TCAV:LI24:800:TC3_1_RAW_WF'
         'TCAV:LI24:800:TC3_2_RAW_WF'
         'TCAV:LI24:800:TC3_3_RAW_WF'
         'PCAV:LI25:300:PH3_0_RAW_WF' 
         'PCAV:LI25:300:PH3_1_RAW_WF' 
         'PCAV:LI25:300:PH3_2_RAW_WF' 
         'PCAV:LI25:300:PH3_3_RAW_WF' };
    %     'KLYS:LI24:K8:TC3_0_RAW_WF'
    %     'KLYS:LI24:K8:TC3_1_RAW_WF'
    %     'KLYS:LI24:K8:TC3_2_RAW_WF'
    %     'PCAV:LI25:300:PH3_3_RAW_WF0' };
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
%      'TCAV:DMP1:360:TCB:0:RAW_WF'    % or 4 5 6 7 ??
%      'TCAV:DMP1:360:TCB:1:RAW_WF'
%      'TCAV:DMP1:360:TCB:2:RAW_WF'
%      'TCAV:DMP1:360:TCB:3:RAW_WF'
     };
if strcmp(upper(pvin),'GUN') || strcmp(upper(pvin),'20-6')
   pv = pvGun;
   nameold = '20-6';
   tpv='TRIG:IN20:RF16:TDES';
   pvvolt='KLYS:LI20:K6:GUN_2_S_SACT';
end
if strcmp(upper(pvin),'L0A') || strcmp(upper(pvin),'20-7')
   pv = pvL0A;
   nameold = '20-7';
   tpv='TRIG:IN20:RF17:TDES';
   pvvolt='KLYS:LI20:K7:L0A_2_S_SACT';
end
if strcmp(upper(pvin),'L0B') || strcmp(upper(pvin),'20-8')
   pv = pvL0B; 
   nameold = '20-8';
   tpv='TRIG:IN20:RF18:TDES';
   pvvolt='KLYS:LI20:K8:L0B_2_S_SACT';
   
end
if strcmp(upper(pvin),'L1S') || strcmp(upper(pvin),'21-1')
   pv = pv2; 
   nameold = '21-1';
   tpv='TRIG:IN20:RF19:TDES';
   pvvolt='KLYS:LI21:K1:L1S_2_S_SACT';
end
if strcmp(upper(pvin),'L1X') || strcmp(upper(pvin),'21-2')
   pv = pv3; 
   nameold = '21-2';
   tpv='TRIG:IN20:DGN_SPARE6:TDES';
   pvvolt='KLYS:LI21:K2:L1X_2_S_SACT';
end
if strcmp(upper(pvin),'TCAV3') || strcmp(upper(pvin),'24-8')
   pv = pv4; 
   nameold = '24-8';
   tpv='LLRF:LI24:0:REF_C_TDES';
  % pvvolt='KLYS:LI24:K8:TC3_2_S_SACT';
   pvvolt='KLYS:LI24:81:BVLT';
end
if strcmp(upper(pvin),'XTCAV') || strcmp(upper(pvin),'31-1')
   pv = pvXTCAV; 
   nameold = '31-1';
   tpv='KLYS:DMP1:360:TCA_PAD:TDES';   %XTCAV doesn't since I cannot control the time of the diag PAD
   pvvolt='KLYS:DMP1:K1:2:S_SACTUAL';
end
%[gg,t,dt] = get_wf(pv);
volt = lcaGet(pvvolt);

if ~exist('i30')
    i30 = 100;
end
%i30=10;   % default 100

gg75=zeros(ijk*512,i30);
%gg75(1:512,:)=gg(7,:,:);
%get_wf_an14
t0=lcaGet(tpv);
tstp=512*9.8;
try
for i = 1:ijk
    t=t0+(i-1)*tstp;
    lcaPut(tpv,t);
    pause(0.01)
    [gg,t,dt] = get_wf(pv,i30);
    gg75((1:512)+(i-1)*512,:)=gg(7,1:512,:);
end
lcaPut(tpv,t0);
catch me
    lcaPut(tpv,t0);
end

gg75exp=(gg75(:,:)'./(ones(i30,1)*exp([1:ijk*512]/-2800))*1.24/100)';   %-2800
gg75min=-min(min(gg75exp));
gg75exp=gg75exp/gg75min*volt;
i512=ijk*512;
dh=zeros(size(gg75));
dh(1,:)=gg75(1,:); 
dh(2:i512,:)=gg75(2:i512,:)-gg75(1:i512-1,:); 
i3000=2500;
delx=gg75*(1-exp(-1/i3000));
dh2=dh+delx;
% plot(cumsum(dh))
% hint(kk:i512,:)= hint(kk:i512,:)+((ones(i512-kk+1,1)*dh(kk,:))'./wex(:,1:i512-kk+1))';
% hint(kk:i512,:)= hint(kk:i512,:)+wext(1:i512-kk+1,:).\(ones(i512-kk+1,1)*dh(kk,:))
%wex=(ones(i30,1)*exp([0:i512-1]/-1000000));   %2800
%wex2=(ones(i30,1)*(1-exp([0:i512-1]/-1000000)));
%wext=wex'+0.5*wex2';

%plot(wext,'b')
%hint=zeros(i512,i30);
%for kk=1:i512
%    kki=kk:i512;
%    kkim=1:(i512-kk+1);
%    hint(kki,:)= hint(kki,:)+wex(:,kkim)'.\(ones(i512-kk+1,1)*dh2(kk,:));
%end
hint2=cumsum(dh2);     % *1.3/100;
scale=-min(min(hint2));
hint2=hint2/scale*volt;
tax=(1:(ijk*512))/1000*9.8;
%figure
%plot(tax-5,hint2)
%grid on

figure
%plot(tax-5,gg75exp)
plot(tax-5,hint2)
grid on
xlabel('Time [us]')
plotfj18
ylabel('Beam Voltage [counts]')
ylabel('Beam Voltage [kV]')
title([pvin, ' Thyratron Back Swing'])
axis([-5 ijk*5-5 -400 100])

figure
%plot(tax-5,100*(gg75exp'-ones(i30,1)*mean(gg75exp')*.99)')
plot(tax-5,100*(hint2'-ones(i30,1)*mean(hint2')*.99)')
grid on
xlabel('Time [us]')
plotfj18
ylabel('Beam Voltage [counts]')
ylabel('Beam Voltage [kV]')
title([pvin, ' Thyratron Back Swing (Jitter*100)'])
axis([-5 ijk*5-5 -400 400])

figure
hint2ave=hint2;   %zeros(size(hint2));
for i=2:length(hint2)-2
    hint2ave(i,:)=mean(hint2(i-1:i+2,:));
end
plot(tax-5,100*(hint2ave'-ones(i30,1)*mean(hint2ave')*.99)')
grid on
xlabel('Time [us]')
plotfj18
ylabel('Beam Voltage [counts]')
ylabel('Beam Voltage [kV]')
title([pvin, ' Thyratron Back Swing (Jitter*100) ave4'])
axis([-5 ijk*5-5 -400 400])

figure
hint2ave16=hint2;   %zeros(size(hint2));
for i=8:length(hint2)-8
    hint2ave16(i,:)=mean(hint2(i-7:i+8,:));
end
plot(tax-5,100*(hint2ave16'-ones(i30,1)*mean(hint2ave16')*.99)')
grid on
xlabel('Time [us]')
plotfj18
ylabel('Beam Voltage [counts]')
ylabel('Beam Voltage [kV]')
title([pvin, ' Thyratron Back Swing (Jitter*100) ave16'])
axis([-5 ijk*5-5 -400 400])
