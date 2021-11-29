function [] = gunatnominalenergy % FS April 9, 2014
% Set RF the power in cavity to obtain the nominal energy value NomEnergy_MeV.
%Sintax: gunatnominalenergy
% The function enters a perpetual loop that can be interrupted by Ctrl+C.
  
NomEnergy_MeV=0.784;
CellPower=20000*sqrt(NomEnergy_MeV/0.784)
CellPower=20000
NomAccur=.5e-3
NomGain=0.4e-2
while 1
    powerfeedback_cavityprobe(CellPower,NomAccur,NomGain)
end

end


