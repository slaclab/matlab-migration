function [ OutputVar ] = restoremagnetpss_UED( InputVar )
% Restore Magnets PSs to the values specified in the program body - No input argument required
% (FS April 29, 2014)


% Reset PSs
    ResetCell={'Sol1:Reset' 1
    'Sol2:Reset' 1
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
    'DHCM5:Reset' 1
    'DHCM6:Reset' 1
    'UHCM7:Reset' 1
    'UHCM8:Reset' 1
    'UHCM9:Reset' 1
    'UHCM10:Reset' 1
    'VCM0:Reset' 1
    'VCM1:Reset' 1
    'VCM2:Reset' 1
    'VCM3:Reset' 1
    'VCM4:Reset' 1
    'DVCM5:Reset' 1
    'DVCM6:Reset' 1
    'UVCM7:Reset' 1
    'UVCM8:Reset' 1
    'UVCM9:Reset' 1
    'UVCM10:Reset' 1
    'UQ1:Reset' 1
    'UQ2:Reset' 1
    'UQ3:Reset' 1
    'UQ4:Reset' 1
    'UQ5:Reset' 1
    'UQ6:Reset' 1
    'UDIP1:Reset' 1
    'UDIP2:Reset' 1
    'Sol1:Reset' 0
    'Sol2:Reset' 0
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
    'DHCM5:Reset' 0
    'DHCM6:Reset' 0
    'UHCM7:Reset' 0
    'UHCM8:Reset' 0
    'UHCM9:Reset' 0
    'UHCM10:Reset' 0
    'VCM0:Reset' 0
    'VCM1:Reset' 0
    'VCM2:Reset' 0
    'VCM3:Reset' 0
    'VCM4:Reset' 0
    'DVCM5:Reset' 0
    'DVCM6:Reset' 0
    'UVCM7:Reset' 0
    'UVCM8:Reset' 0
    'UVCM9:Reset' 0
    'UVCM10:Reset' 0
    'UQ1:Reset' 0
    'UQ2:Reset' 0
    'UQ3:Reset' 0
    'UQ4:Reset' 0
    'UQ5:Reset' 0
    'UQ6:Reset' 0
    'UDIP1:Reset' 0
    'UDIP2:Reset' 0
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
    'DHCM5:Enable' 1
    'DHCM6:Enable' 1
    'UHCM7:Enable' 1
    'UHCM8:Enable' 1
    'UHCM9:Enable' 1
    'UHCM10:Enable' 1
    'VCM0:Enable' 1
    'VCM1:Enable' 1
    'VCM2:Enable' 1
    'VCM3:Enable' 1
    'VCM4:Enable' 1
    'DVCM5:Enable' 1
    'DVCM6:Enable' 1
    'UVCM7:Enable' 1
    'UVCM8:Enable' 1
    'UVCM9:Enable' 1
    'UVCM10:Enable' 1
    'UQ1:Enable' 1
    'UQ2:Enable' 1
    'UQ3:Enable' 1
    'UQ4:Enable' 1
    'UQ5:Enable' 1
    'UQ6:Enable' 1
    'UDIP1:Enable' 1
    'UDIP2:Enable' 1
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
    'VCM0:Setpoint' 0
    'VCM1:Setpoint' 2e-2
    'VCM2:Setpoint' -2e-1
    'VCM3:Setpoint' 5e-1
    'VCM4:Setpoint' 7.5e-1
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
    'VCM0:Setpoint' 0
    'VCM1:Setpoint' 0
    'VCM2:Setpoint' 0.4
    'VCM3:Setpoint' -.108
    'VCM4:Setpoint' .55
    };    
end

RealSize=size(RealCell);
iimax=RealSize(1)
for ii=1:1:iimax
    setpvonline(RealCell{ii,1},RealCell{ii,2},'float',1);% fast writing option
end




end
