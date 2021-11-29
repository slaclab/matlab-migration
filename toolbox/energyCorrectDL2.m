function correctedEnergy = energyCorrectDL2(beamline, x1, x2, bendEnergyGeV)
%
%  correctedEnergy = energyCorrectDL2(beamline, x1, x2, bendEnergyGeV)
%
% Returns the "corrected" beam energies for each bunch based on specific DL2
% bpms.
%
% x1 is an array of  horizontal beam positions. 
%  For the HXR line it is BPMS:LTUH:250.
%  For the SXR line is it BPMS:LTUS:235
% x2 is an array of  horizontal beam positions. 
%  For the HXR line it is BPMS:LTUH:450.
%  For the SXR line is it BPMS:LTUS:370
%
% x1 and x2 should should be synchronous data
%
% correctedEnergy is an array of bunch energies [GeV], corresponding to the bpm
% readings.
%
% bendEnergy, if supplied, is the beam energy assumed when the bpm readings
% are zero. If absent, the current bend energy in the DUMP is used.
%
% This is a fast, limited scope program. Dispersions are hard wired. It does not call model data.

if strcmp(beamline, 'HXR')
    eta1 = 0.125; % BPMDL1 MAD value
    eta2 = -0.125;% BPMDL3 MAD value
    if nargin<4 % i.e. if no bend energy is supplied
        [bendEnergyGeV,~] = lcaGetSmart('BEND:DMPH:400:BDES'); %use bdes for consistency
    end
end

if strcmp(beamline,'SXR')
    eta1 = -0.417;% BPMDL13 MAD value
    eta2 = 0.425; % BPMDL17 MAD value
    if nargin<4 % i.e. if no bend energy is supplied
        [bendEnergyGeV,~] = lcaGetSmart('BEND:DMPS:400:BDES'); %use bdes for consistency
    end
end

correctedEnergy = bendEnergyGeV...
    + bendEnergyGeV*0.001*(  x2(1,:) - x1(1,:) )/(eta2 - eta1);

