function IPMall(dev,num,xx30,symbol,blackw,MeV,IDoff)
%  function IPMall(dev,num,x_or_y,disp_symbol,black_or_white BG,MeV,IDoff)
%
%  e.g.:    IPMall('notG',1000000,[],'c.','black','MeV',0)
%
%  e.g.:    IPMall plots the Gas detector versus DL2 Energy
%  e.g.:    IPMall('X',120) plots GDET verus the HIGHEST correlated undulator X BPM
%           or for 'Y'
%           DON'T use UND_BPM_num for now
%  e.g.:    IPMall('GDET',120,2090) plots versus x at BPMS:UND1:2090 
%
%  Devices (dev) can be: 
%  'HX21' 'XPP1' 'XPP2' 'XPP3' 'XPP4' 'XPP5' 'XPP6' 'XCS1' 'XCS2' 'XCS3' 'MEC1' 
%  'MEC2' 'MEC3' 'MEC4' 'MEC5' 'MEC6' 'MEC7' 'MEC8' 'MEC9' 'GDET' 'notG'
%  optional: num is about time in sec display runs, default = 100 sec
%  optional: UND_BPM_num than versus orbit in x

% FJD 10-Mar-2014
%

load('/home/physics/decker/matlab/toolbox/sumold0');

if ~exist('dev') 
    dev='GDET';
end
if ~exist('IDoff') 
    IDoff=0;
end
if exist('xx30') 
    XY=upper(xx30);
end
dev=upper(dev);
if ~exist('symbol') 
    symbol='.';
end
figure(1)
if exist('blackw') && strcmp(blackw,'black')
    colordef black
    set(1,'color',[.2 0. .4],'menubar','none')
elseif exist('blackw') && strcmp(blackw,'white')
    colordef white
    set(1,'color',[.8 .8 .8],'menubar','none')
end
scale0=1;     %1/2;
scale=1;
if exist('MeV')
    scale=scale0/37.5;
end
dev0='dummy';
if strcmp(dev, 'NOTG')  
      dev0='NOTG';
end
if strcmp(dev, 'X') || strcmp(dev, 'Y') 
    XY=dev;
      dev='GDET';
end

if ~exist('num')
    num=200;
end

ipmall={ 'XPP:MON:IPM:01:SUM'    %good  SXR was bad
    %'HX2:SB1:IPM:01:SUM'        %XPP in SXR
    % SXR
    %  'SXR:GMD:BLD:AvgPulseIntensity'     % not synchrounous
    %  'SXR:GMD:BLD:milliJoulesPerPulse' 
      
      'SXR:GMD:BLD:milliJoulesPerPulse'    % new 2018
      'SXR:GMD:BLD:SumAllPeaksFiltBkgd'
    % 'SXR:GMD:BLD:SumAllPeaksRawBkgd'



     


%      'SXR:GMD:BLD:CumSumAllPeaks'

% XPP
%'XPP:MON:IPM:01:SUM'    %good   commented out for SXR
%'XPP:MON:IPM:02:SUM'    %good     "                "
'XPP:SB2:IPM:01:SUM'    %good
'XPP:SB2:BMMON:SUM'     % new Sep 2018
%'XPP:SB3:IPM:01:SUM'
%'XPP:SB3:IPM:02:SUM'  % ??
'XPP:SB4:IPM:01:SUM'


'XPP:USR:IPM:01:SUM'
%'XPP:USR:IPM:02:SUM'

% XRT -- these 2 sets are not accessible yet
%       there should also be a DG2 set

%'HFX:DG1:IPM:01:SUM'
%'HFX:DG2:IPM:01:SUM'
%'HFX:DG3:IPM:01:SUM'

% XCS

'XCS:DG1:IMB:01:SUM'
'XCS:DG1:IMB:02:SUM'    %good
'XCS:DG3:IMB:03:SUM'

% MEC line in XRT

%'MEC:HXM:IPM:01:SUM'
'MEC:HXM:PIM:01:SUM'
'MEC:HXM:PIM:01:SUM'


'MEC:XT2:IPM:02:SUM'

'MEC:XT2:PIM:02:SUM'

'MEC:XT2:IPM:03:SUM'

'MEC:XT2:PIM:03:SUM'

'MEC:XT2:PIM:02:SUM'  % just to have right number I added three here
'MEC:XT2:IPM:03:SUM'
'MEC:XT2:PIM:03:SUM'


% 'MEC:USR:IMB:01:SUM'  % now gone?


% 'MEC:USR:IMB:02:SUM'  % now gone?

% Not working yet
%MEC:TC1:IMB:01:CH0
%MEC:TC1:IMB:01:CH1
%MEC:TC1:IMB:01:CH2
%MEC:TC1:IMB:01:CH3
% 'MEC:TC1:IMB:01:SUM'   % now gone?
'GDET:FEE1:241:ENRC'    %241 361
%'BPMS:UND1:2090:X'};
'BPMS:LTU1:250:X'
'BPMS:LTU1:450:X'
};
%if exist('xx20')
%    ipmall(21)=cellstr(['BPMS:UND1:', num2str(xx20),':X']);
%end
bpmx={'BPMS:UND1:190:X'
  'BPMS:UND1:290:X'
  'BPMS:UND1:390:X'
'BPMS:UND1:490:X'
'BPMS:UND1:590:X'
'BPMS:UND1:690:X'
'BPMS:UND1:790:X'
'BPMS:UND1:890:X'
'BPMS:UND1:990:X'
'BPMS:UND1:1090:X'
'BPMS:UND1:1190:X'
  'BPMS:UND1:1290:X'
  'BPMS:UND1:1390:X'
'BPMS:UND1:1490:X'
'BPMS:UND1:1590:X'
'BPMS:UND1:1690:X'
'BPMS:UND1:1790:X'
'BPMS:UND1:1890:X'
'BPMS:UND1:1990:X'
'BPMS:UND1:2090:X'
'BPMS:UND1:2190:X'
  'BPMS:UND1:2290:X'
  'BPMS:UND1:2390:X'
'BPMS:UND1:2490:X'
'BPMS:UND1:2590:X'
'BPMS:UND1:2690:X'
'BPMS:UND1:2790:X'
'BPMS:UND1:2890:X'
'BPMS:UND1:2990:X'
'BPMS:UND1:3090:X'
'BPMS:UND1:3190:X'
'BPMS:UND1:3290:X'
'BPMS:UND1:3390:X' };

bpmy={'BPMS:UND1:190:Y'
  'BPMS:UND1:290:Y'
  'BPMS:UND1:390:Y'
'BPMS:UND1:490:Y'
'BPMS:UND1:590:Y'
'BPMS:UND1:690:Y'
'BPMS:UND1:790:Y'
'BPMS:UND1:890:Y'
'BPMS:UND1:990:Y'
'BPMS:UND1:1090:Y'
'BPMS:UND1:1190:Y'
  'BPMS:UND1:1290:Y'
  'BPMS:UND1:1390:Y'
'BPMS:UND1:1490:Y'
'BPMS:UND1:1590:Y'
'BPMS:UND1:1690:Y'
'BPMS:UND1:1790:Y'
'BPMS:UND1:1890:Y'
'BPMS:UND1:1990:Y'
'BPMS:UND1:2090:Y'
'BPMS:UND1:2190:Y'
  'BPMS:UND1:2290:Y'
  'BPMS:UND1:2390:Y'
'BPMS:UND1:2490:Y'
'BPMS:UND1:2590:Y'
'BPMS:UND1:2690:Y'
'BPMS:UND1:2790:Y'
'BPMS:UND1:2890:Y'
'BPMS:UND1:2990:Y'
'BPMS:UND1:3090:Y'
'BPMS:UND1:3190:Y'
'BPMS:UND1:3290:Y'
'BPMS:UND1:3390:Y' };
ipmuxy=[ipmall; bpmx; bpmy];
add1=1;
end20=20+add1;  %3
end21=21+add1;

ipmalldum = {'HX21'
    'XPP1'
    'XPP2'
    'XPP3'
    'XPP4'
    'XPP5'
    'XPP6'
    'XCS1'
    'XCS2'
    'XCS3'
    'MEC1'
    'MEC2'
    'MEC3'
    'MEC4'
    'MEC5'
    'MEC6'
    'MEC7'
    'MEC8'
    'MEC9'
    'GDET'};
 ispec=find(strcmp(ipmalldum, dev) == 1);
    
    
    
    
    
energy=lcaGet('BEND:LTU0:125:BDES');
photonE=lcaGet('SIOC:SYS0:ML00:AO627');
%scale=1;
if energy>8
    scale=scale*2;
end
    

sumall0now=lcaGetSmart(ipmall);
if strcmp(dev0,'NOTG')
    iphot=find(sumall0now(1:end-3)>sumall0(1:end-2)+.5);    % 0.5
    ispec=max(iphot);
    if isempty(ispec);
        ispec=length(ipmalldum);   % GDET
    end
end

[i20, idd]=size(ipmuxy);
i600=30;
%figure(1)
%h1m=plot(sumall0(end,:)/1.25,sumall0(end-1,:),'*');
%plotfj18
%title('Gas Detector vs Energy')
%xlabel('Energy Deviation [%]')
%ylabel('FEL Inensity [mJ]')
%axis([-.4 .4 0 3.6])
tt1=0;
tcount=0;
tbad=0;


for j=1:num
    
energy=lcaGet('BEND:LTU0:125:BDES');
photonE=lcaGet('SIOC:SYS0:ML00:AO627');
%scale=1;
if energy>8
    scale=2;
    if exist('MeV')
        scale=scale/150;
    end
end

  sumall0now=lcaGetSmart(ipmall);
if strcmp(dev0,'NOTG')
     %iphot=find(sumall0now(1:end-2)>sumall0(1:end-2)+.01);
    iphot=find(sumall0now(1:10)>sumall0(1:10)+.01);  % MEC stuff > 15 (mess)
    ispec=max(iphot);
    if ~isempty(ispec)
        dev=ipmall{ispec}(1:3);
    end
    if isempty(ispec);
        ispec=length(ipmalldum);
        dev='GDET';
    end
end
  
    
sumall=zeros(i20,i600);
ts=zeros(i20,i600);
tic;
i=0;
ID=zeros(i600,1);
IDint=zeros(i600,1);
%tt1=1
while i<=i600-1
    i=i+1;
    [sumall(:,i), ts(:,i)]=lcaGet(ipmuxy);
    ID(i)=lcaTs2PulseId(ts(end20,i));
    IDint(i)=lcaTs2PulseId(ts(ispec,i))+IDoff;
 %  [ID(1:7)'; IDint(1:7)']
    if(i>1 && ID(i)==ID(i-1))   || (ID(i)~=IDint(i)+0*3* max(~strcmp(dev,'GDET'),1*tt1)); 
    %if(i>1 && ID(i)==ID(i-1))  || (ID(i)~=IDint(i)+1*3* max(~strcmp(dev,'GDET')*0,1*tt1)); 
        i=i-1;
    %elseif (ID(i)~=IDint(i))
    end  
pause(0.002)
end
t=toc;

cc=zeros(i20,1);
for ii=20+add1:i20
corr=corrcoef(sumall(ispec,:),sumall(ii,:));
cc(ii)=corr(1,2);
end
[ccmx,imx]=max(cc(21+add1:53+add1).^2);
[ccmy,imy]=max(cc(54+add1:i20).^2);
if ~exist('imx0'), imx0=imx; imy0=imy; imxarr=[]; imyarr=[]; end
if abs(imx-imx0)<4
   %  imxarr= int8([imx imxarr]); 
    imxarr= ([imx imxarr]); 
end
imx = round(median(imxarr));

%if abs(imx-imx0)>2
%      imx=imx0;
%end
imx0=imx;

if abs(imy-imy0)<4
   % imyarr= int8([imy imyarr]); 
    imyarr= ([imy imyarr]); 
end
imy = round(median(imyarr));

%if abs(imy-imy0)>2
%      imy=imy0;
%end
imy0=imy;

i10=3;
tcount=tcount+1;
if t>0.38      %0.25
    maybe_out_of_Sync = t
    tbad=tbad+1;
    %tt1=1;
end
if tbad/(i10+tcount) >0.5
    tt1=1
end
if ~exist('E0') E0=[]; Int0=[]; mcx0=[]; mcy0=[]; end
tmax=1200;
if length(E0) > tmax
    E0=E0(1:tmax-i600);
    Int0=Int0(1:tmax-i600);
    mcx0=mcx0(1:tmax-i600);
    mcy0=mcy0(1:tmax-i600);
    %imxarr = imxarr(1:round(tmax/i600));  
    imxarr = imxarr(1:min(length(imxarr), round(tmax/i600)));
    imyarr = imyarr(1:min(length(imyarr), round(tmax/i600)));
end
E =[sumall(end20,:)/1.25 E0];
E450=[-sumall(end21,:)/1.25 E0];

if exist('MeV')
    E =[sumall(end20,:)/1.25*energy*10 E0];
end
mcox=[sumall(20+add1+imx,:) mcx0];    % 20 --> 21+add1
mcoy=[sumall(20+add1+33+imy,:) mcy0];
E0=E; mcx0=mcox; mcy0=mcoy;
Int=[sumall(ispec,:) Int0];
Int0=Int;
%meaInt=mean(Int);
maxInt = min(ceil(max(Int)), 1.25*max(Int));  %, 3*meaInt);
minInt=min(Int)-10*eps;
%plot(sumall(end,:)/1.25,sumall(end-1,:),'*')
EE=E;
xx=0;
yy=0;
if exist('XY')
if strcmp(XY, 'X')
    xx=1;
end

if strcmp(XY, 'Y')
    yy=1;
end
end
if xx==1
    EE=mcox;
    xx20=imx;
    XY='X';
end
if yy==1
    EE=mcoy;
    xx20=imy;
    XY='Y';
end

h1m=plot(EE,Int,symbol);    %'.'
mean(EE);
plotfj
igo=~isnan(EE);
igo2=find(E450(igo)~=0);
rmsE = round(1000*std(EE(igo)))/1000;
meaInt=mean(Int(igo2));
rmsInt = std(Int(igo2))./meaInt*100;

xlabel(['e-Beam Energy [%], rms =  ', num2str(rmsE,'%0.3f'), ' %'])
if exist('MeV')
    xlabel(['e-Beam Energy [MeV],  rms =  ', num2str(rmsE/energy/10,'%0.3f'), ' %'])
end
if exist('xx20')
    xlabel(['BPMS:UND1:', num2str(xx20), '90:', XY, ' [mm]'])
    scale=10;
end
if strcmp(dev,'GDET')
    ylabel(['FEL Intensity [mJ], rms =  ', num2str(rmsInt,'%4.1f'), ' %'])
    title(['Gas Detector vs Energy   (Eph = ', num2str(photonE,'%5.0f'), ' eV)'])
    if exist('xx20')
        title(['Gas Detector vs Undulator', XY, '  (Eph = ', num2str(photonE,'%5.0f'), ' eV)'])
    end
else
    ylabel([dev(1:3) ' IPM Sum, rms =  ', num2str(rmsInt,'%4.1f'), ' %'])
    title([char(ipmall{ispec}(1:14)) ' vs Energy   (Eph = ', num2str(photonE,'%5.0f'), ' eV)'])
    if exist('xx20')
        title([char(ipmall{ispec}(1:14)) ' vs Undulator ', XY,'   (Eph = ', num2str(photonE,'%5.0f'), ' eV)'])
    end
end
  text('FontSize',14,'Position', [.7*0.4/scale meaInt],'HorizontalAlignment','right', ... 
        'String', [num2str(mean(Int),'%0.3f'),' mJ']);
    mini=min(minInt, 0);

if mean(Int) > -.2 && mean(Int) < 10
    lcaPut('SIOC:SYS0:ML03:AO820',mean(Int));
end

axis([-.4/scale .4/scale mini maxInt])
grid on
drawnow
%M(j)=getframe;
pause(0.1)
end
