function [Etrim, Ftrim] = kmSlopeTrim(CorrectedEnergy, F)
%
%  [Etrim, Ftrim] = kmSlopeTrim(CorrectedEnergy, F)
%
% Delete outliers and sort and trim data from rising edge of spectral curve

% Delete outliers
for q=1:1
    [peakSignal,peakIndex] = max(F);
    F(peakIndex) = [];
    CorrectedEnergy(peakIndex) =[];
end

% Sort the data and trim to 10% and 90% from min and max on rising edge
F(1:6) = []; % first 5 BSA points can be old, (5 due to waiting)
CorrectedEnergy(1:6)=[];

[Esort, IX] = sort(CorrectedEnergy);
Fsort = F(IX);

[peakSignal,peakIndex] = max(Fsort);
minSignal = min(Fsort);
signalRange = peakSignal - minSignal;
energyAtPeak = Esort(peakIndex);
Ftrim = Fsort;%trimmed flux
Etrim = Esort;%trimmed energy

Ftrim = Fsort(1:peakIndex);%truncate
FtrimIndex = find(   (Ftrim < (peakSignal -0.2*signalRange)) ...
    & (Ftrim > (minSignal + 0.0*signalRange) )  );
Ftrim = Ftrim(FtrimIndex);
Etrim = Etrim(FtrimIndex);

badEnergyIndex = find(Etrim > energyAtPeak);
Etrim(badEnergyIndex) =[];
Ftrim(badEnergyIndex) = [];

if length(Etrim)<2
  display('Not enough data points. Decrease Energy Step size');
end