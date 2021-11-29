function [ OutputVar ] = scalemagnetswithenergy(PresentEnergy_MeV, NewEnergy_MeV)
% Scales Magnets PSs from the present energy in MeV to the new one in MeV.
% (FS Feb. 4, 2015)

PresentEnergy_MeV=abs(PresentEnergy_MeV);
NewEnergy_MeV=abs(NewEnergy_MeV);
if NewEnergy_MeV>.9
    NewEnergy_MeV=.9;
    ['WARNING: NewEnergy_MeV set to 0.9 MeV']
end
    
gamma0=PresentEnergy_MeV*1.957+1;
gamma=NewEnergy_MeV*1.957+1;
betagamma0=sqrt(gamma0^2-1);
betagamma=sqrt(gamma^2-1);
ratio=betagamma/betagamma0;

%Read Cell
ReadCell={'Sol1:Setpoint'
    'Sol2:Setpoint'
    'Sol3:Setpoint'
    'Sol1Quad1:Setpoint' 
    'Sol1Quad2:Setpoint' 
    'Sol2Quad1:Setpoint' 
    'Sol2Quad2:Setpoint' 
    'Sol1SQuad1:Setpoint' 
    'Sol1SQuad2:Setpoint' 
    'Sol2SQuad1:Setpoint' 
    'Sol2SQuad2:Setpoint' 
    'HCM1:Setpoint' 
    'HCM2:Setpoint' 
    'HCM3:Setpoint'
    'HCM4:Setpoint' 
    'HCM5:Setpoint' 
    'HCM6:Setpoint' 
    'HCM7:Setpoint' 
    'HCM8:Setpoint' 
    'HCM9:Setpoint' 
    'VCM1:Setpoint' 
    'VCM2:Setpoint' 
    'VCM3:Setpoint' 
    'VCM4:Setpoint' 
    'VCM5:Setpoint' 
    'VCM6:Setpoint' 
    'VCM7:Setpoint' 
    'VCM8:Setpoint' 
    'VCM9:Setpoint' 
    'Quad1:Setpoint' 
    'Quad2:Setpoint' 
    'Quad3:Setpoint' 
    'Quad4:Setpoint' 
    'Quad5:Setpoint' 
    'SpecBend1:Setpoint' 
    };

ReadSize=size(ReadCell);
iimax=ReadSize(1);
Value=getpv(ReadCell);% read present current value
for ii=1:1:iimax    
    NewValue=Value{ii}*ratio;% scale present current value
    setpvonline(ReadCell{ii},NewValue,'float',1);% fast writing option
end

ratio

end
