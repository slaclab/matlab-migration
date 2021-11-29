function [Curr_A,PeakB_T] = solenoidcurrforfocal( SolenoidID,f_m,BeamEnergy_MeV )
%Calculate the current in A and the peak fileld in T to get the desired 
%focal length in m for the APEX solenoids.
%(FS March 13, 2012)
%Sintax: [Curr_A,PeakB_T]=currentforsolfocal(SolenoidID,f_m,BeamEnergy_MeV)
%SolenoidID is 0 for the Bucking Coil and 1,2 and 3 for the Focus Solenoids;
%f_m is the desired focal lenght in m;
%BeamEnergy_MeV is the electron beam energy in MeV.

% Define input variable dimension
Fsize=size(f_m);
Esize=size(BeamEnergy_MeV);

if Fsize(2)~=Esize(2)
    if Esize(2)>Fsize(2)
        for ii=1:1:Esize(2); Fh(ii)=f_m;end
        Eh=BeamEnergy_MeV;
        LoopSize=Esize(2);
    else
        for ii=1:1:Fsize(2); Eh(ii)=BeamEnergy_MeV;end
        Fh=f_m;
        LoopSize=Fsize(2);
    end
else
    LoopSize=Fsize(2);
    Eh=BeamEnergy_MeV;
    Fh=f_m;
end

if SolenoidID<0 | SolenoidID>3
    ['WARNING: wrong solenoid ID. ID set to 1']
    SolenoidID=1;
end
if SolenoidID==0
    F0=15;% initial current guess in A for bucking coil
else
    F0=5;% initial current guess for focus solenoids
end


%MAIN LOOP

for jj=1:1:LoopSize
        
    Fh1=Fh(jj);
    Eh1=Eh(jj);

    %Calculate Integrals and output quantities
    F=@(x)solenoidproperties(SolenoidID,x,Eh1)-Fh1;
    
    Curr_A(jj)=fzero(F,F0);
    PeakB_T(jj)=solenoidfield(SolenoidID,0,Curr_A(jj));

end

end

