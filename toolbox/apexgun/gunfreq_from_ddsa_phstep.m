function [GunFreq_MHz] = gunfreq_from_ddsa_phstep(ddsa_phstep) % FS April 12, 2014
% Calculates the gun frequency for a given setting of the LLRF1 PV ddsa_phstep.
%Sintax: [GunFreq_MHz] = gunfreq_from_ddsa_phstep(ddsa_phstep)
% ddsa_phstep= ddsa_phstep LLRF1 PV value.
  
ddsa_phstep=floor(abs(ddsa_phstep));

% From fit
mm=-9.738181818182e-5;
qq=204.28;

GunFreq_MHz=ddsa_phstep*mm+qq;

end


