function [] = startapex_nominal % FS April 9, 2014
% Start APEX from OFF to the nominal starting point defined by the values of the following variables
% A3FWD_0 in W
% PulseLength_0 in s.
% RepRate_0 in Hz.
% Sintax: startapex_nominal.
% At the end of the procedure (it takes ~30 min), the function enters a perpetual feddback loop that keeps A3FWD at the the A3FWD_0 value
% The loop can be interrupted by Ctrl+C.
  
% Check solenoid motors
sm(1)=getpv('Sol1:M1:PNOW');
sm(2)=getpv('Sol1:M2:PNOW');
sm(3)=getpv('Sol1:M3:PNOW');
sm(4)=getpv('Sol1:M4:PNOW');
sm(5)=getpv('Sol1:M5:PNOW');

sm(6)=getpv('Sol2:M1:PNOW');
sm(7)=getpv('Sol2:M2:PNOW');
sm(8)=getpv('Sol2:M3:PNOW');
sm(9)=getpv('Sol2:M4:PNOW');
sm(10)=getpv('Sol2:M5:PNOW');

PosThreshold=3.1;
err=0;
for ii=1:10
    if sm(ii)<PosThreshold
        err=1;
        ['****ERROR: Solenoids position out of range. Check before restarting****']
        return
    end
end

    %Cavity steel heaters OFF
setpv('CavityHeater1:DutyCycle',26);
setpv('CavityHeater2:DutyCycle',26);
setpv('CavityHeater1:OnReq',1);
setpv('CavityHeater2:OnReq',1);

% set gun tuner
%Set tuner mode.
setpvonline('CavityTuner:ModeReq',2,'float',1);% Motor only mode
%setpvonline('CavityTuner:ModeReq',3,'float',1);% Motor+piezo mode
setpvonline('CavityTuner:LoadReq.OMSL',0,'float',1);% Tuner in supervisory mode (PLC feedback open)

% set gun tuner at the initial value
TunerInit_N=3000; %tuner initial value in N
PresTuner=getpv('CavityTuner:LoadAvg');
Ntunersteps=6;
TunSteps=(TunerInit_N-PresTuner)/(Ntunersteps-1);
for ActTuner=PresTuner:TunSteps:TunerInit_N
    setpvonline('CavityTuner:LoadReq',ActTuner,'float',1);
    pause(20)
    ['setting gun tuner at the initial value']
end
setpvonline('CavityTuner:LoadReq',TunerInit_N,'float',1);


%Reset Slow EPS
setpv('EPS:Reset',1);
pause(1);
setpv('EPS:Reset',0);

%open Valves
setpv('VVR1:OpenReq',1);
setpv('VVR2:OpenReq',1);

%Magnets ON 
restoremagnetpss

%Extract screens and slits and Faraday cup
setpv('Screen1:Command',0)
setpv('Screen2:Command',0)
setpv('Screen3:Command',0)
setpv('Slit1:Command',1)
setpv('Slit2:Command',1)
setpv('FaradayCup:OutReq',1)

%Insert Beam Dump
setpv('BeamDump:InReq',1)

%Close Laser Shutter
setpv('Laser:Shutter:CloseReq',1)


A3FWD_0=66000
PulseLength_0=0.98e-3
RepRate_0=1e3
Nsteps=6
startapex(A3FWD_0,PulseLength_0,RepRate_0,Nsteps)

end


