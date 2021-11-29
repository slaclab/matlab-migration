%
% 2013_2 E-axes
%

%
%
% CHER_FAR (CMOS) E axis 
%
%
datename = '20131116'; % date the calibration data was taken on
visualization = 1; % 1 to see what function does
pixel_ROIY = 1:2559; % ROIY
offset = 0;
sbend_setting = 20.35 + 0;
prof_name = 'CMOS';
[EE_CHER_FAR] = E200_cher_get_E_axis(datename, prof_name, visualization, pixel_ROIY, offset, sbend_setting);
% short version
[EE_CHER_FAR] = E200_cher_get_E_axis('20131116', 'CMOS', 0, 1:2559, 0, 20.35);


%
%
% CNEAR (UNIQ) E axis 
%
%
datename = '20131125'; % date the calibration data was taken on
visualization = 1; % 1 to see what function does
pixel_ROIY = 1:1392; % ROIY
offset = 0;
sbend_setting = 20.35 + 0;
prof_name = 'CNEAR';
[EE_CHER_NEAR] = E200_cher_get_E_axis(datename, prof_name, visualization, pixel_ROIY, offset, sbend_setting);
% short version
[EE_CHER_NEAR] = E200_cher_get_E_axis('20131125', 'CNEAR',0, 1:1392, 0, 20.35);
