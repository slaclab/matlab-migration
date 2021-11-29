function [Qbunch_ICT1_pC, Qbunch_ICT2_pC, QE] = CalculateQbunchAndQE(reprate_MHz)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

reprate_MHz=abs(reprate_MHz);

maxreprate=0.9524; % Max rep rate in MHz
photonEnergy_eV=4.65; %photon energy in eV

if reprate_MHz>maxreprate
    reprate_MHz=maxreprate;
elseif reprate_MHz==0
    reprate_MHz=maxreprate;
end

% ICT1 and 2 calibration using fast EPS readings (See June 5, 2014)
I11=0;
I12=.304768;
C11=7;
C12=1837;
m1=(I12-I11)/(C12-C11);
q1=I12-m1*C12;

I21=0;
I22=.304768;
C21=8;
C22=1538;
m2=(I22-I21)/(C22-C21);
q2=I22-m2*C22;
CorrectionFactor=1.06*1.07;

laserCal_mWperCounts=1.33/1360;% See June 5, 2014 Calibration on Logbook "Operations"
Ratio=0;
cnt=0;
while 1
    
    cnt=cnt+1;
    
    ICT1_Uncal=getpv('BLM:0:dac20_max');
    ICT2_Uncal=getpv('BLM:0:dac21_max');
    %ICT1_Uncal=ICT1_Uncal+getpv('BLM:0:dac20_min')/2;
    %ICT2_Uncal=ICT2_Uncal+getpv('BLM:0:dac21_min')/2;
    
    LaserPowerFullRange_au=getpv('Laser:Power:FullRange');
    
    ICT1_Current_mA=ICT1_Uncal*m1+q1;
    ICT2_Current_mA=(ICT2_Uncal*m2+q2)/CorrectionFactor;
    
    Ratio=Ratio+ICT2_Current_mA/ICT1_Current_mA;
    AvgRatio=Ratio/cnt;
    LaserPowerFullRange_mW=LaserPowerFullRange_au*laserCal_mWperCounts;
    
    Qbunch1_if_952_kHz=ICT1_Current_mA*1e-3/(maxreprate*1e6);%Charge per bunch if running at 0.9524 MHz
    Qbunch2_if_952_kHz=ICT2_Current_mA*1e-3/(maxreprate*1e6);%Charge per bunch if running at 0.9524 MHz
    
    Qbunch_ICT1_pC=Qbunch1_if_952_kHz*maxreprate/reprate_MHz*1e12;
    Qbunch_ICT2_pC=Qbunch2_if_952_kHz*maxreprate/reprate_MHz*1e12;
    
    lasershutterstatus=getpv('Laser:Shutter:Closed');
    if LaserPowerFullRange_mW <=0
        QE=0;
    elseif lasershutterstatus==1
        QE=0;
    else
        QE=photonEnergy_eV*ICT1_Current_mA/LaserPowerFullRange_mW;
    end
    
    QE
    Qbunch_ICT2_pC
    Qbunch_ICT1_pC
    AvgRatio
    
    
    pause(.5)
end

      

end

