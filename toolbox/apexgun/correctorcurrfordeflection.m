function [Curr_A,PeakB_T] = ...
    correctorcurrfordeflection( CorrectorID,HorVertFlag,DeflectAngle_rad,BeamEnergy_MeV )
%Calculate the current in A and the peak field in T to get the desired 
%deflection in rad for the APEX correctors.
%(FS March 16, 2012)
%Sintax: correctorcurrfordeflection
%                 (CorrectorID,HorVertFlag,DeflectAngle_rad,BeamEnergy_MeV)
%CorrectorID can be 1,2,3,4,5 and 6.Different values will be forced to 1.
%HorVertFlag:  0=horizontal, 1=vertical.Different values will be forced to 0.
%DeflectAngle_rad is the desired deflecting angle in rad;
%BeamEnergy_MeV is the electron beam energy in MeV.

% Define input variable dimension
Fsize=size(DeflectAngle_rad);
Esize=size(BeamEnergy_MeV);

if Fsize(2)~=Esize(2)
    if Esize(2)>Fsize(2)
        for ii=1:1:Esize(2); Fh(ii)=DeflectAngle_rad;end
        Eh=BeamEnergy_MeV;
        LoopSize=Esize(2);
    else
        for ii=1:1:Fsize(2); Eh(ii)=BeamEnergy_MeV;end
        Fh=DeflectAngle_rad;
        LoopSize=Fsize(2);
    end
else
    LoopSize=Fsize(2);
    Eh=BeamEnergy_MeV;
    Fh=DeflectAngle_rad;
end

if CorrectorID<1 | CorrectorID>6
    ['WARNING: wrong corrector ID. ID set to 1']
    CorrectorID=1;
end

if HorVertFlag~=1 && HorVertFlag~=0
    ['WARNING: wrong HorVertFlag value. Value set to 0 (horizontal)']
    HorVertFlag=1;
end

F0=1;% initial current guess in A for bucking coil


%MAIN LOOP

for jj=1:1:LoopSize
        
    Fh1=Fh(jj);
    Eh1=Eh(jj);

    %Calculate Integrals and output quantities
    F=@(x)correctorproperties(CorrectorID,HorVertFlag,x,Eh1)-Fh1;
    
    Curr_A(jj)=fzero(F,F0);
    PeakB_T(jj)=correctorfield(CorrectorID,HorVertFlag,0,Curr_A(jj));

end

end

