function [gg,t,dt,n,nk,nameold] = get_HVjit(pvin,ij,prt);
%function [gg,t,dt,n,nk,nameold] = get_HVjit(pvin,ij,prt);
%
% get_HVjit gets the 8 PAD readings from the desired station and makes
% displays
% function [gg,t,dt,nameold] = get_HVjit(pvin,ij)
% pv = wf_pv OR station name: 'L1S', '20-8', 'XTCAV' ...
% ij = number of samples  OR 100 when empty
% anything as prt will save and print figure(30) e.g. ...'Gun',100,'p')
%
% e.g.:   [gg,t,dt,n,nk,nameold] = get_HVjit('Gun',120);

path(path,'/home/physics/decker/matlab/toolbox')

prtt = 1;
if ~exist('prt','var')
  prtt = 0;
else
  prtt = prt;
end

if ~exist('ij','var')
  ij = 100;
end


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
         'KLYS:LI24:K8:TC3_0_RAW_WF'
         'KLYS:LI24:K8:TC3_1_RAW_WF'
         'KLYS:LI24:K8:TC3_2_RAW_WF'
         'PCAV:LI25:300:PH3_3_RAW_WF0' };
  %       'KLYS:LI24:K8:TC3_3_RAW_WF'};
   
 pvPhasCav= {  'UND:R02:IOC:10:BAT:Charge1'
               'UND:R02:IOC:10:BAT:FitTime1'
               'UND:R02:IOC:10:BAT:Charge2'
               'UND:R02:IOC:10:BAT:FitTime2'  };
 %              'UND:R02:IOC:10:BAT:Charge3'
 %              'UND:R02:IOC:10:BAT:FitTime3'
 %              'UND:R02:IOC:10:BAT:Charge4'
 %              'UND:R02:IOC:10:BAT:FitTime4' };
 
 pvXTCAV = { 'TCAV:DMPH:360:TCA:0:RAW_WF'
      'TCAV:DMPH:360:TCA:1:RAW_WF'
      'TCAV:DMPH:360:TCA:2:RAW_WF'
      'TCAV:DMPH:360:TCA:3:RAW_WF'
      'KLYS:DMPH:K1:TCA:0:RAW_WF'
      'KLYS:DMPH:K1:TCA:1:RAW_WF'
      'KLYS:DMPH:K1:TCA:2:RAW_WF'
      'KLYS:DMPH:K1:TCA:3:RAW_WF'
%      'TCAV:DMPH:360:TCB:0:RAW_WF'    % or 4 5 6 7 ??
%      'TCAV:DMPH:360:TCB:1:RAW_WF'
%      'TCAV:DMPH:360:TCB:2:RAW_WF'
%      'TCAV:DMPH:360:TCB:3:RAW_WF'
     };
if strcmp(upper(pvin),'GUN') || strcmp(upper(pvin),'20-6')
   pv = pvGun;
   nameold = '20-6';
end
if strcmp(upper(pvin),'L0A') || strcmp(upper(pvin),'20-7')
   pv = pvL0A;
   nameold = '20-7';
end
if strcmp(upper(pvin),'L0B') || strcmp(upper(pvin),'20-8')
   pv = pvL0B; 
   nameold = '20-8';
end
if strcmp(upper(pvin),'L1S') || strcmp(upper(pvin),'21-1')
   pv = pv2; 
   nameold = '21-1';
end
if strcmp(upper(pvin),'L1X') || strcmp(upper(pvin),'21-2')
   pv = pv3; 
   nameold = '21-2';
end
if strcmp(upper(pvin),'XTCAV') || strcmp(upper(pvin),'21-2')
   pv = pvXTCAV; 
   nameold = 'XTCAV';
end

[gg,t,dt,n,nk] = get_wf(pv,ij);
get_wf_an14

 myclock=clock;
 figure(45)
 t_stamp =datestr(myclock);
 text('FontSize',12,'Position', [180 24500],'HorizontalAlignment','right', 'String', t_stamp);
 
 figure(30)
 text('FontSize',12,'Position', [0 -455],'HorizontalAlignment','right', 'String', t_stamp);
 


 
 %data2=[gg t dt n nk nameold];   
     
 datan.g=gg;
 datan.n=nameold;
 datan.t0=t;
 datan.dt=dt;
 datan.n0=n;
 datan.nk=nk;   
 datan.t=t_stamp;

 if prtt == 1
     fileName=util_dataSave(datan,'RF_waveform','1',myclock);
     util_printLog(30, 'author', 'Decker (from Matlab)','title',['RF Waveform of ', pvin])
 end
 

%  load /u1/lcls/matlab/data/2016/2016-07/2016-07-08/RF_waveform-1-2016-07-08-115933.mat; 

%  d=data; gg=d.g; nameold=d.n; t=d.t0;dt=d.dt; n=d.n0; nk =d.nk; t_stamp=d.t;

%  dir /u1/lcls/matlab/data/2016/2016-07/2016-07-08/RF*

% 

