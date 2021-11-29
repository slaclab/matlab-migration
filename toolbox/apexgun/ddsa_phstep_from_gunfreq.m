function [ddsa_phstep] = ddsa_phstep_from_gunfreq(GunFreq_MHz) % FS April 12, 2014
% Calculates the setting for the LLRF1 PV ddsa_phstep for a given frequency.
%Sintax: [ddsa_phstep] = ddsa_phstep_from_gunfreq(GunFreq_MHz)
% GunFreq_MHz= gun frequency in MHz.
  
GunFreq_MHz=abs(GunFreq_MHz);

% From fit
mm=-9.738181818182e-5;
qq=204.28;

ddsa_phstep=GunFreq_MHz/mm-qq/mm;

end


