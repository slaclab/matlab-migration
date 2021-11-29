function [ output_args ] = cyclespectrometermagnet( input_args )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
MaxCurr_A=20.;
CycleNum=3;
AccuThreshold=0.9995;
MinCurr_A=0.001;
PSslewrate_A_s=5;

setpvonline('SpecBend1:SlewControl',1,'float',1);
setpvonline('SpecBend1:SlewRate',PSslewrate_A_s,'float',1);
I0=getpvonline('SpecBend1:Setpoint');

setpvonline('SpecBend1:Setpoint',0,'float',1);
ActCurr=abs(getpv('SpecBend1:CurrentRBV'));
while ActCurr>MinCurr_A
    ActCurr=abs(getpv('SpecBend1:CurrentRBV'));
end
pause(2);
setpvonline('SpecBend1:Setpoint',-MaxCurr_A,'float',1);
ActCurr=getpv('SpecBend1:CurrentRBV')/-MaxCurr_A;
while ActCurr<AccuThreshold
    ActCurr=getpv('SpecBend1:CurrentRBV')/-MaxCurr_A;
end
pause(2);
for ii=1:CycleNum
    setpvonline('SpecBend1:Setpoint',MaxCurr_A,'float',1);
    ActCurr=getpv('SpecBend1:CurrentRBV')/MaxCurr_A;
    while ActCurr<AccuThreshold
        ActCurr=getpv('SpecBend1:CurrentRBV')/MaxCurr_A;
    end
    pause(2);
    setpvonline('SpecBend1:Setpoint',-MaxCurr_A,'float',1);
    ActCurr=getpv('SpecBend1:CurrentRBV')/-MaxCurr_A;
    while ActCurr<AccuThreshold
        ActCurr=getpv('SpecBend1:CurrentRBV')/-MaxCurr_A;
    end
    pause(2);
    ['Spectrometer hysteresis cycle No: ',num2str(ii),' of ',num2str(CycleNum),' completed']
end
setpvonline('SpecBend1:Setpoint',0,'float',1);
ActCurr=getpv('SpecBend1:CurrentRBV');
while ActCurr>MinCurr_A
    ActCurr=getpv('SpecBend1:CurrentRBV');
end
setpvonline('SpecBend1:Setpoint',I0,'float',1);

end

