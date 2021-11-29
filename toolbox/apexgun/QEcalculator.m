function [QE1 QE2 QE3 ICTcharge_C_scope LaserEnergy_J_scope MeasTime_s IntQ AvgChrg RedPdiode_V_scope RedICT_V_scope RedLaserPmeter RedICT_EPS RedTimeScale_s] = QEcalculator(Photodiode_V,ICT_V,LaserPmeter,ICT_EPS, TimeScale_s,MeasDate_num,PlotFlag)
% Calculates QE and other quantities from ICT1 and laser measurements.
% 
% SINTAX:[QE1 QE2 QE3 ICTcharge_C_scope LaserEnergy_J_scope MeasTime_s IntQ AvgChrg RedPdiode_V_scope RedICT_V_scope RedLaserPmeter RedICT_EPS RedTimeScale_s] = 
% = QEcalculator(Photodiode_V,ICT_V,LaserPmeter,ICT_EPS, TimeScale_s,MeasDate_num,PlotFlag)
% 
% INPUT QUANTITIES:
% Photodiode_V= photodiode signal in V;
% ICT_V= ICT1 signal in V;
% LaserPmeter= Laser power meter [a.u.]
% ICT_EPS= ICT1 from fast EPS system [a.u]
% TimeScale_s= Time axis in seconds for the two previous signals; 
% MeasDate_num= Date and Time of each single measurement in MatLab
% numerical format;
% PlotFlag = If different than 0 plots of the output quantities are generated
%
% OUTPUT QUANTITIES:
% QE1= quantum efficiency from scope signals;
% QE2= quantum efficiency from scope ICT and laser power meter;
% QE3= quantum efficiency from EPS ICT and laser power meter;
% ICTcharge_C= ICT1 charge per bunch in C;
% LaserEnergy_J= laser pulse energy in J;
% MeasTime_s= Sequential time in seconds at which the individual measurements were made;
% IntQ=integrated charge in C;
% AvgChrg= average charge per bunch over the acquirsition perion;
% RedPhotodiode_V= Cleaned photodiode signal in V;
% RedICT_V= Cleaned ICT1 signal in V;
% RedLaserPmeter= Calibrated laser energy per pulse in J (from power meter);
% RedICT_EPS= Calibrated charge per bunch (from EPS);
% RedTimeScale_s= Cleaned time axis in seconds for the two previous signals; 

SizePhotodiode=size(Photodiode_V);
SizeTimeScale=size(TimeScale_s);
SizeICT=size(ICT_V);
SizeMeasDate=size(MeasDate_num);
SizeICT_EPS=size(ICT_EPS);
SizeLaserPmeter=size(LaserPmeter);

qe=1.6022e-19;
cc=2.9979e8;
hh=6.626e-34;
RepRate=1.e6; % Actual repetition rate in Hz
lambda=266e-9;%laser wavelength in m
Zscope=50;%scope impedance in Ohm
ICTfactor_scope=20;% ICT1 chrage conversion factor
ICT_AttnFct_scope=2;% ICT signal attenuation factor
PhotodiodeCal=17.e-9/24.e-3;% Photodiode calibration factor in J/Vpeak
LaserPmeter_cal=1e-8/2^15*(1./0.035-1.0)*0.8*(1-0.04)^2;% Laser power meter calibration factor in J/count at 1 MHz repetition rate
ICT_EPS_cal=1/1250*0.245e-3/1e6;% ICT1 from EPS calibration factor in C/count at 1 MHz repetition rate
     
EffectiveRedNumber=0;% Number of points to be removed at the beginning of signals (if spikes are present)
BackGrN_diode=75-EffectiveRedNumber; % Number of points (at the beginning of the photodiode signal) to be used for calculating signal offset
BackGrN_ICT=75-EffectiveRedNumber;% Number of points (at the beginning of the ICT signal) to be used for calculating signal offset
ICTInt1=74-EffectiveRedNumber;%integration extreme 1 in ICT charge integration process
ICTInt2=105-EffectiveRedNumber;%integration extreme 2 in ICT charge integration process
PhotoDiodeInt1=76-EffectiveRedNumber;%ROI extreme 1 for photodiode signal
PhotoDiodeInt2=130-EffectiveRedNumber;%ROI extreme 2 for photodiode signal

% Remove noise spike at the beginning of the photodiode signal if necessaary
ErrorFlag=0;
if SizePhotodiode(2) == SizeTimeScale(2)
    RedTimeScale_s=TimeScale_s(EffectiveRedNumber+1:SizeTimeScale(2));
    RedPdiode_V_scope=Photodiode_V(1:SizePhotodiode(1),EffectiveRedNumber+1:SizePhotodiode(2));
else
    ErrorFlag=1;
end

if SizeICT == SizePhotodiode
    RedICT_V_scope=ICT_V(1:SizePhotodiode(1),EffectiveRedNumber+1:SizePhotodiode(2));
else
    ErrorFlag=1;
end

if SizeMeasDate(1) ~= SizePhotodiode(1)
    ErrorFlag=1;
end

if SizeICT_EPS ~= SizePhotodiode(1)
    ErrorFlag=1;
end

if SizeLaserPmeter ~= SizePhotodiode(1)
    ErrorFlag=1;
end

if ErrorFlag==1
    ['Error: input variable dimensions not matching.']
    return
end

% offset from Photodiode signal
PhotoDiodeOff=mean(RedPdiode_V_scope(1:SizePhotodiode(1),1:BackGrN_diode)');
for ii=1:SizePhotodiode(1);
    RedPdiode_V_scope(ii,1:SizePhotodiode(2)-EffectiveRedNumber)=RedPdiode_V_scope(ii,1:SizePhotodiode(2)-EffectiveRedNumber)-PhotoDiodeOff(ii);
    PhotodiodePeak(ii)=max(RedPdiode_V_scope(ii,PhotoDiodeInt1:PhotoDiodeInt2'));% Calculate the diode peak value
end
LaserEnergy_J_scope=PhotodiodePeak*PhotodiodeCal;% Calibrate the photodiode signal

% Remove offset from ICT signal
ICTOff=mean(RedICT_V_scope(1:SizePhotodiode(1),1:BackGrN_ICT)');
for ii=1:SizePhotodiode(1)
    RedICT_V_scope(ii,1:SizePhotodiode(2)-EffectiveRedNumber)=RedICT_V_scope(ii,1:SizePhotodiode(2)-EffectiveRedNumber)-ICTOff(ii);
end

dt=TimeScale_s(2)-TimeScale_s(1);
ICTarea=sum(RedICT_V_scope(1:SizePhotodiode(1),ICTInt1:ICTInt2)')*dt;% Calculate the ICT area value
ICTcharge_C_scope=ICTarea/Zscope*ICTfactor_scope*ICT_AttnFct_scope;%Calculate the ICT charge

RedICT_EPS=-(ICT_EPS-7)*ICT_EPS_cal*1.e6/RepRate;% Calibrated charge per bunch (from EPS assuming 1 MHz repetition rate)

RedLaserPmeter=LaserPmeter*LaserPmeter_cal*1e6/RepRate;% Calibrated laser energy per pulse in J (from power meter assuming 1 MHz Reprate)

QE1=abs(ICTcharge_C_scope)/qe ./ LaserEnergy_J_scope/lambda*hh*cc;%Calculate the quantum efficiency from scope signals
QE2=abs(ICTcharge_C_scope)/qe ./ RedLaserPmeter'/lambda*hh*cc;%Calculate the quantum efficiency from ICT from scope and laser power meter
QE3=abs(RedICT_EPS)'/qe ./ RedLaserPmeter'/lambda*hh*cc;%Calculate the quantum efficiency from ICT from EPS and Laser Power meter

% Converts Date in sequential time in s
DateString=datestr(MeasDate_num);
StrSize=size(DateString);
day=str2num(DateString(1:StrSize(1),1:2));
ss=str2num(DateString(1:StrSize(1),19:20));
mm=str2num(DateString(1:StrSize(1),16:17));
hh=str2num(DateString(1:StrSize(1),13:14));
t0=ss(1)+mm(1)*60.+hh(1)*3600.+day(1)*86400;
Time_s=ss(1:StrSize(1))+mm(1:StrSize(1))*60.+hh(1:StrSize(1))*3600.+day(1:StrSize(1))*86400-t0;
MeasTime_s=Time_s';

ddT=MeasTime_s(2)-MeasTime_s(1);% Integration time step for integrated current.
SizeMeasTime=size(MeasTime_s);
TotTime=MeasTime_s(SizeMeasTime(2));
IntQ=abs(sum(RedICT_EPS)*ddT*RepRate);% integrated charge in C.
AvgChrg = IntQ/TotTime/RepRate;% Average charge per bunch in C.

if PlotFlag ~=0

    figure(20);plot(RedTimeScale_s,RedPdiode_V_scope);
    xlabel('Time [s]');
    ylabel('Photodiode Signal [V]');
    title(' ');
    
    figure(21);plot(RedTimeScale_s,RedICT_V_scope);
    xlabel('Time [s]');
    ylabel('ICT1 Signal [V]');
    title(' ');

    figure(22);plot(MeasTime_s/3600,ICTcharge_C_scope*1e12,'+','MarkerSize',3);
    
    hold; 
    plot(MeasTime_s/3600,RedICT_EPS*1e12,'ro','MarkerSize',3)
    xlabel('Time [hours]');
    ylabel('Bunch Charge [pC]');
    title('Legenda: blue "+" are from scope, red "o" is from EPS');
    hold; 

    figure(23);plot(MeasTime_s/3600,LaserEnergy_J_scope*1e9,'+','MarkerSize',3);
    
    hold;
    plot(MeasTime_s/3600,RedLaserPmeter*1e9,'ro','MarkerSize',3)
    xlabel('Time [hours]');
    ylabel('Laser Pulse Energy [nJ]');
    title('Legenda: blue "+" are from scope, red "o" from laser power meter');
    hold;

    figure(24);plot(MeasTime_s/3600.,QE1*100,'+','MarkerSize',3);
    xlabel('Time [hours]');
    ylabel('Quantum Efficiency [%]');
    title('QE from Scope Signals');

    figure(25);plot(MeasTime_s/3600.,QE2*100,'+','MarkerSize',3);
    xlabel('Time [hours]');
    ylabel('Quantum Efficiency [%]');
    title('QE from Scope ICT1 and Laser Power Meter');

    figure(26);plot(MeasTime_s/3600.,QE3*100,'k+','MarkerSize',3);
    xlabel('Time [hours]');
    ylabel('Quantum Efficiency [%]');
    title('QE from EPS ICT and Laser Power Meter');
    
    figure(27);plot(MeasTime_s/3600,abs(RedICT_EPS)*RepRate*1e3,'gx','MarkerSize',3)
    xlabel('Time [hours]');
    ylabel('Current [mA]');
    title('');
  
    figure(28);plot(MeasTime_s/3600,abs(RedICT_EPS)*1e12,'ro','MarkerSize',3)
    xlabel('Time [hours]');
    ylabel('Bunch Charge [pC]');
    title('');
  
    figure(29);plot(MeasTime_s/3600,RedLaserPmeter*1e9,'b*','MarkerSize',3)
    xlabel('Time [hours]');
    ylabel('Laser Pulse Energy [nJ]');
    title('');


end


end

