function [ OutputVar ] = restoremagnetpss( InputVar )
% Restore Magnets PSs to the values specified in the program body - No input argument required
% (FS April 29, 2014)


% Reset PSs
    ResetCell={'Sol1:Reset' 1
    'Sol2:Reset' 1
    'Sol3:Reset' 1
    'Sol1Quad1:Reset' 1
    'Sol1Quad2:Reset' 1
    'Sol2Quad1:Reset' 1
    'Sol2Quad2:Reset' 1
    'Sol1SQuad1:Reset' 1
    'Sol1SQuad2:Reset' 1
    'Sol2SQuad1:Reset' 1
    'Sol2SQuad2:Reset' 1
    'HCM0:Reset' 1
    'HCM1:Reset' 1
    'HCM2:Reset' 1
    'HCM3:Reset' 1
    'HCM4:Reset' 1
    'HCM5:Reset' 1
    'HCM6:Reset' 1
    'HCM7:Reset' 1
    'HCM8:Reset' 1
    'HCM9:Reset' 1
    'VCM0:Reset' 1
    'VCM1:Reset' 1
    'VCM2:Reset' 1
    'VCM3:Reset' 1
    'VCM4:Reset' 1
    'VCM5:Reset' 1
    'VCM6:Reset' 1
    'VCM7:Reset' 1
    'VCM8:Reset' 1
    'VCM9:Reset' 1
    'Quad1:Reset' 1
    'Quad2:Reset' 1
    'Quad3:Reset' 1
    'Quad4:Reset' 1
    'Quad5:Reset' 1
    'Sol1:Reset' 0
    'Sol2:Reset' 0
    'Sol3:Reset' 0
    'Sol1Quad1:Reset' 0
    'Sol1Quad2:Reset' 0
    'Sol2Quad1:Reset' 0
    'Sol2Quad2:Reset' 0
    'Sol1SQuad1:Reset' 0
    'Sol1SQuad2:Reset' 0
    'Sol2SQuad1:Reset' 0
    'Sol2SQuad2:Reset' 0
    'HCM0:Reset' 0
    'HCM1:Reset' 0
    'HCM2:Reset' 0
    'HCM3:Reset' 0
    'HCM4:Reset' 0
    'HCM5:Reset' 0
    'HCM6:Reset' 0
    'HCM7:Reset' 0
    'HCM8:Reset' 0
    'HCM9:Reset' 0
    'VCM0:Reset' 0
    'VCM1:Reset' 0
    'VCM2:Reset' 0
    'VCM3:Reset' 0
    'VCM4:Reset' 0
    'VCM5:Reset' 0
    'VCM6:Reset' 0
    'VCM7:Reset' 0
    'VCM8:Reset' 0
    'VCM9:Reset' 0
    'Quad1:Reset' 0
    'Quad2:Reset' 0
    'Quad3:Reset' 0
    'Quad4:Reset' 0
    'Quad5:Reset' 0
    };

RealSize=size(ResetCell);
iimax=RealSize(1)
for ii=1:1:iimax
    setpvonline(ResetCell{ii,1},ResetCell{ii,2},'float',1);% fast writing option
end
pause(3)

% Switch PSs ON
    ONCell={'Sol1:Enable' 1
    'Sol2:Enable' 1
    'Sol3:Enable' 1
    'Sol1Quad1:Enable' 1
    'Sol1Quad2:Enable' 1
    'Sol2Quad1:Enable' 1
    'Sol2Quad2:Enable' 1
    'Sol1SQuad1:Enable' 1
    'Sol1SQuad2:Enable' 1
    'Sol2SQuad1:Enable' 1
    'Sol2SQuad2:Enable' 1
    'HCM0:Enable' 1
    'HCM1:Enable' 1
    'HCM2:Enable' 1
    'HCM3:Enable' 1
    'HCM4:Enable' 1
    'HCM5:Enable' 1
    'HCM6:Enable' 1
    'HCM7:Enable' 1
    'HCM8:Enable' 1
    'HCM9:Enable' 1
    'VCM0:Enable' 1
    'VCM1:Enable' 1
    'VCM2:Enable' 1
    'VCM3:Enable' 1
    'VCM4:Enable' 1
    'VCM5:Enable' 1
    'VCM6:Enable' 1
    'VCM7:Enable' 1
    'VCM8:Enable' 1
    'VCM9:Enable' 1
    'Quad1:Enable' 1
    'Quad2:Enable' 1
    'Quad3:Enable' 1
    'Quad4:Enable' 1
    'Quad5:Enable' 1
    'SpecBend1:Enable' 1
};

RealSize=size(ONCell);
iimax=RealSize(1)
for ii=1:1:iimax
    setpvonline(ONCell{ii,1},ONCell{ii,2},'float',1);% fast writing option
end
 pause(5)

swtch=0; % Settings selector
if swtch==0
% August 26, 2016. 100 pC beam
    RealCell={'Sol1:Setpoint' 3.94
    'Sol2:Setpoint' 3.1
    'Sol3:Setpoint' 0.
    'Sol1Quad1:Setpoint' 0
    'Sol1Quad2:Setpoint' 0
    'Sol2Quad1:Setpoint' 0
    'Sol2Quad2:Setpoint' 0
    'Sol1SQuad1:Setpoint' 0
    'Sol1SQuad2:Setpoint' 0
    'Sol2SQuad1:Setpoint' 0
    'Sol2SQuad2:Setpoint' 0
    'HCM0:Setpoint' -2.3
    'HCM1:Setpoint' -.08
    'HCM2:Setpoint' 0.35
    'HCM3:Setpoint' 1.3
    'HCM4:Setpoint' -4.6e-1
    'HCM5:Setpoint' 6.6e-1
    'HCM6:Setpoint' 7e-1
    'HCM7:Setpoint' 0
    'HCM8:Setpoint' -5e-1
    'HCM9:Setpoint' 0
    'VCM0:Setpoint' 0
    'VCM1:Setpoint' 2e-2
    'VCM2:Setpoint' -2e-1
    'VCM3:Setpoint' 5e-1
    'VCM4:Setpoint' 7.5e-1
    'VCM5:Setpoint' -2.8e-1
    'VCM6:Setpoint' 6.1e-1
    'VCM7:Setpoint' 0
    'VCM8:Setpoint' -1.4
    'VCM9:Setpoint' -8.5e-1
    'Quad1:Setpoint' -8
    'Quad2:Setpoint' 16
    'Quad3:Setpoint' -6.4
    'Quad4:Setpoint' 0
    'Quad5:Setpoint' 0
    'SpecBend1:Setpoint' 24.6
    };   
elseif swtch==1
% Add settings here if required
elseif swtch==2
% Add settings here if required
elseif swtch==3
% Add settings here if required
elseif swtch==4
% Add settings here if required
else
    RealCell={'Sol1:Setpoint' 4.25
    'Sol2:Setpoint' 2.35
    'Sol3:Setpoint' 0.
    'Sol1Quad1:Setpoint' 0
    'Sol1Quad2:Setpoint' 0
    'Sol2Quad1:Setpoint' 0
    'Sol2Quad2:Setpoint' 0
    'Sol1SQuad1:Setpoint' 0
    'Sol1SQuad2:Setpoint' 0
    'Sol2SQuad1:Setpoint' 0
    'Sol2SQuad2:Setpoint' 0
    'HCM0:Setpoint' 0
    'HCM1:Setpoint' 0
    'HCM2:Setpoint' 0
    'HCM3:Setpoint' -1.181
    'HCM4:Setpoint' -1.099
    'HCM5:Setpoint' 0
    'HCM6:Setpoint' 0
    'HCM7:Setpoint' 0
    'HCM8:Setpoint' 0
    'HCM9:Setpoint' 0
    'VCM0:Setpoint' 0
    'VCM1:Setpoint' 0
    'VCM2:Setpoint' 0.4
    'VCM3:Setpoint' -.108
    'VCM4:Setpoint' .55
    'VCM5:Setpoint' 0
    'VCM6:Setpoint' 0
    'VCM7:Setpoint' 0
    'VCM8:Setpoint' 0
    'VCM9:Setpoint' 0
    'Quad1:Setpoint' 0
    'Quad2:Setpoint' 0
    'Quad3:Setpoint' 0
    'Quad4:Setpoint' 0
    'Quad5:Setpoint' 0
    'SpecBend1:Setpoint' 0
    };    
end

RealSize=size(RealCell);
iimax=RealSize(1)
for ii=1:1:iimax
    setpvonline(RealCell{ii,1},RealCell{ii,2},'float',1);% fast writing option
end




end
