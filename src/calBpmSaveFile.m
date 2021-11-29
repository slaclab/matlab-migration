%   calBpmSaveFile
%
%   This script saves all the variables from the calibration data
%   acquisition to a file.
%

path_name=(['/u1/lcls/physics/cavityBPM/calibration/data/prodCal/' beamline '/']);
date=datestr(now,31);
str = ['BPMCalib',beamline,'_',date(1:10),'_',date(12:13),'_',date(15:16)] ;
save(fullfile(path_name,str))
fprintf('All variables saved to %s%s.mat\n\n',path_name,str); 


