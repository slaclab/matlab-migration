function [eLossRel, eFlux, tDump] = dumpEnergySpectrum()
%
% [eLossRel, eFlux, tDump] = dumpEnergySpectrum()
%
% Get an electron energy spectrum from the dump screen
% 
imageGrab= profmon_measure('OTRS:DMP1:695',1,'doPlot',0, 'nBG',0,'doProcess',0);
y_out = sum(imageGrab.img,2);
dispersionDump = .698; % dispersion at dump screen in meters
pixel2m =imageGrab.res * 1e-6; 
eLossRel = (1:length(y_out)) *pixel2m/dispersionDump;
eFlux = y_out;
tDump = imageGrab.ts;