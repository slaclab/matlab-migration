function [bendEnergyGeV, dGeV] = kmEnergyMeasure()
%
% [BeamEnergy] = kmEnergyMeasure()
%
% Use BSA to get DOGLEG2 bpm's and construct the machine energy for shots
% specified by kmEnergyScan event defintion.
%

% Basic data
etax = .125 ; % [m] need to find out what eta is at bpms

% Read the bend magnet setting
pvb(1) = {'BEND:LTU1:220:BACT'};
pvb(2) = {'BEND:LTU1:280:BACT'};
pvb(3) = {'BEND:LTU1:420:BACT'};
pvb(4) = {'BEND:LTU1:480:BACT'};
pvb = pvb'; % make column vector

[bendStrengthGeV, ts]  = lcaGetSmart(pvb);
bendEnergyGeV = mean(bendStrengthGeV);

% Read the bpm signals
pvxy(1) = {'BPMS:LTU1:250:XHSTBR'};
pvxy(2) = {'BPMS:LTU1:250:YHSTBR'};
pvxy(3) = {'BPMS:LTU1:450:XHSTBR'};
pvxy(4) = {'BPMS:LTU1:450:YHSTBR'};
pvxy = pvxy';

[bpms, ts]  = lcaGetsmart(pvxy);
% Calculate the energy
dGeV = bendEnergyGeV*0.001* ( bpms(1) + bpms(2) )/(2*etax);