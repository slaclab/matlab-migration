function photonEnergy = electron2PhotonEnergy(electronEnergy)
%electronEnergy in GeV -> photonEnergy in eV
A = 0.03; %lambdaUnd
B = 0.000511; %electronRestE
C = electronEnergy;
D = 3.5; %undulatorK
E = 1239.84; %hc

photonEnergy = E./(1e9*((A*(B^2))./(2*(C.^2)))*(1+((D^2)./2)));
end