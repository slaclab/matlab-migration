function [ DeflectingAngle_rad, DeflectingAngle_deg,PeakField_T,EffectLength_m] = ...
    correctorproperties( CorrectorID,HorVertFlag,I,BeamEnergy_MeV )
%Calculate the deflecting angle in rad and deg, the peak field in T and the
%effective lenght for the APEX correctors.
%(FS March 16, 2012)
%Sintax: [DeflectingAngle_rad, DeflectingAngle_deg, MaxField_T,EffectLength_m]=
%              correctorproperties( CorrectorID,HorVertFlag,I,BeamEnergy_MeV )
%CorrectID can be 1,2,3,4,5 and 6. Other values will be forced to 0;
%HorVertFlag: 0=horizontal; 1=vertical. Other values will be forced to 0.
%I is the current in A applied to the corrector;
%BeamEnergy_MeV is the electron beam energy in MeV.

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

if CorrectorID<1 | CorrectorID>6
    ['WARNING: wrong corrector ID. ID set to 0']
    CorrectorID=0;
end

if HorVertFlag~=1 && HorVertFlag~=0
    ['WARNING: wrong HorVertFlag value. Flag set to 0 (horizontal)']
    HorVertFlag=0;
end


%Integrator parameters 
IntPrec=10^-9;% integration precision
if CorrectorID==1
    xint=0.05738;% integration half-interval for corrector 1 (air coil)
else
    xint=0.3311;% integration half-interval for correctors 2,3 and 4 (iron coils)
end
%MAIN LOOP

for jj=1:1:LoopSize
    
    %Calculate BRho
    me=9.1095*10^(-31);
    qe=1.6022*10^(-19);
    cc=2.9979*10^8;
    Gamma=1.957*Eh(jj)+1;
    BetaGamma=sqrt(Gamma^2-1);
    BRho=BetaGamma*me*cc/qe;
    
    Ih1=Ih(jj);

    %Calculate Integral and output quantities
    F=@(x)correctorfield(CorrectorID,HorVertFlag,x,Ih1);

    LinInt=quad(F,-xint,xint,IntPrec);
    PeakField_T(jj)=correctorfield(CorrectorID,HorVertFlag,0,Ih1);
    EffectLength_m(jj)=LinInt/PeakField_T(jj);

    DeflectingAngle_rad(jj)=LinInt/BRho;
    DeflectingAngle_deg(jj)=DeflectingAngle_rad(jj)/pi*180;
end

end

