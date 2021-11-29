function [ focal_m,rotation_rad, Lequiv_m, B_HE_coeff] = solenoidproperties( SolenoidID,I,BeamEnergy_MeV )
%Calculate the focal length in m, the frame rotation in rad, the solenoid equivalent length in m, 
% and the Hard Edge model field coefficient for the APEX solenoids.
%(FS March 9, 2012)
%Syntax: [focal_m,rotation_rad, Lequiv_m, B_HE_coeff]=solenoidproperties(SolenoidID,I,BeamEnergy_MeV)
%SolenoidID is 0 for the Bucking Coil and 1,2 and 3 for the Focus Solenoids;
%I is the current in A applied to the solenoid;
%BeamEnergy_MeV is the electron beam energy in MeV.
% REMARK: Lequiv_m and B_HE_coeff for the bucking solenoid will return a NaN

me=9.1095*10^(-31);
qe=1.6022*10^(-19);
cc=2.9979*10^8;

% Define input variable dimension
Isize=size(I);
Esize=size(BeamEnergy_MeV);

if Isize(2)~=Esize(2)
    if Esize(2)>Isize(2)
        for ii=1:1:Esize(2); Ih(ii)=I;end
        Eh=BeamEnergy_MeV;
        LoopSize=Esize(2);
    else
        for ii=1:1:Isize(2); Eh(ii)=BeamEnergy_MeV;end
        Ih=I;
        LoopSize=Isize(2);
    end
else
    LoopSize=Isize(2);
    Eh=BeamEnergy_MeV;
    Ih=I;
end

%Integrator precision 
IntPrec=10^-9;

if SolenoidID<0 | SolenoidID>3
    ['WARNING: wrong solenoid ID. ID set to 1']
    SolenoidID=1;
end
if SolenoidID==0
    xint=0.3;% integration half-interval for bucking coil
else
    xint=0.5;% integration half-interval for focus solenoids
end


%MAIN LOOP

for jj=1:1:LoopSize
    
    %Calculate BRho
    Gamma=1.957*Eh(jj)+1;
    BetaGamma=sqrt(Gamma^2-1);
    BRho=BetaGamma*me*cc/qe;
    
    Ih1=Ih(jj);

    %Calculate Integrals and output quantities
    F=@(x)solenoidfield(SolenoidID,x,Ih1).^2;
    R=@(x)solenoidfield(SolenoidID,x,Ih1);

    SqInt=quad(F,-xint,xint,IntPrec);
    LinInt=quad(R,-xint,xint,IntPrec);

    focal_m(jj)=(SqInt/(4*BRho^2))^(-1);
    rotation_rad(jj)=LinInt/2/BRho;
    if SolenoidID==0
        Lequiv_m=NaN;
        B_HE_coeff=NaN;
    else
        Lequiv_m(jj)=LinInt^2/SqInt;
        B_HE_coeff=SqInt/LinInt/solenoidfield(SolenoidID,0,Ih1);
    end
end

end

