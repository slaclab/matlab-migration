function [ DeltaCentroid_m, DeflectingAngle_rad] = ...
    corrector2energymeas_deltacentroid(HorVertFlag,I,BeamEnergy_MeV )
%Calculate the centroid offset in m at APEX screen 1 and the deflecting angle in rad when 
% a current I is applied to APEX corrector 2 with a beam with energy
% BeamEnergy_MeV.
%(FS March 24, 2012)
%Sintax: [DeltaCentroid_m, DeflectingAngle_rad]=
%              corrector2energymeas_deltacentroid(HorVertFlag,I,BeamEnergy_MeV )
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

CorrectorID=2;
Corr2ScreenDist_m=.4266;

if HorVertFlag~=1 && HorVertFlag~=0
    ['WARNING: wrong HorVertFlag value. Flag set to 0 (horizontal)']
    HorVertFlag=0;
end


%Integrator parameters 
IntPrec=10^-9;% integration precision
xint=0.28;% integration half-interval


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

    DeflectingAngle_rad(jj)=LinInt/BRho;
    DeltaCentroid_m(jj)=DeflectingAngle_rad(jj)*Corr2ScreenDist_m;
end

end

