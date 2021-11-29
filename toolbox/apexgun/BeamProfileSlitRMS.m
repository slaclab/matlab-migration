clear

currentpath = pwd;
filepath = '/remote/apex/data/GeneralScans/';
cd(filepath)

filename = 'GeneralScan_2015_2_19_16_4_11.mat';

load(filename)

plot(ScanData(:,1),-ScanData(:,3),'ro-')

xlabel('EMVCM1 current (A)')
ylabel('Current after slit 1')
% title('RMS size 2.8 A * 360 um/A = 1011 um')

rmssize=(sum(ScanData(:,1).^2.*(ScanData(:,3)))/sum(ScanData(:,3))-(sum(ScanData(:,1).*ScanData(:,3))/sum(ScanData(:,3)))^2).^0.5; % in unit of current scan stepsize

cal = 370; % um/A

rmssize = rmssize*cal; % in um

titletxt = sprintf('RMS size %0.6g um',rmssize);
title(titletxt)

cd(currentpath)