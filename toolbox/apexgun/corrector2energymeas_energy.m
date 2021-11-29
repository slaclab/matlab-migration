function [Energy_MeV, Gamma, Brho_Tm] = ...
    corrector2energymeas_energy( HorVertFlag,I,DeltaX_m )
%Calculate the energy in MeV, the gamma, and the B Rho for an energy
%measurement using the APEX corrector 2 and screen 1.
%(FS March 24, 2012)
%Sintax: [Energy_MeV, Gamma, Brho_Tm]=
%              corrector2energymeas_energy(HorVertFlag,I,DeltaX_m)
%HorVertFlag: 0=horizontal; 1=vertical. Other values will be forced to 0.
%I is the current in A applied to corrector 2;
%DeltaX_m is the beam centroid offset at screen 1 in m.

% Define input variable dimension
Isize=size(I);
Esize=size(DeltaX_m);

if Isize(2)~=Esize(2)
    if Esize(2)>Isize(2)
        for ii=1:1:Esize(2); Ih(ii)=I;end
        Eh=DeltaX_m;
        LoopSize=Esize(2);
    else
        for ii=1:1:Isize(2); Eh(ii)=DeltaX_m;end
        Ih=I;
        LoopSize=Isize(2);
    end
else
    LoopSize=Isize(2);
    Eh=DeltaX_m;
    Ih=I;
end

if HorVertFlag~=1 && HorVertFlag~=0
    ['WARNING: wrong HorVertFlag value. Flag set to 0 (horizontal)']
    HorVertFlag=0;
end

CorrectorID=2;%Selects corrector 2
DistCorr1Screen_m=0.4266;% Distance corrector 2 screen in m
%Calculate corrector equivalent lenght
[trash1 trash2 trash3 Leq]=correctorproperties(CorrectorID,HorVertFlag,1,1);

%MAIN LOOP
ee=1.6022e-19;
mm=9.1095e-31;
cc=2.9979e8;

for jj=1:1:LoopSize
    
    Ih1=Ih(jj);
    Bh=correctorfield(CorrectorID, HorVertFlag,0,Ih1);
    TanAngle=Eh(jj)/DistCorr1Screen_m;
    Brho_Tm(jj)=(Bh*Leq)/TanAngle;
    BetaGamma=ee*Brho_Tm(jj)/mm/cc;
    Gamma(jj)=sqrt(BetaGamma^2+1);
    Energy_MeV(jj)=(Gamma(jj)-1)*mm*cc^2/ee*1e-6;

end

end

