    prof_name = 'CELOSS';
    datename = '20130423'; % date the calibration data was taken on
    visualization = 0; % 1 to see what function does
    sbend_setting = 20.35; % sbend setting the experimental data was taken at
    pixel_ROI = 1:1392; % ROI
    offset = 0;
   EE_nom = E200_cher_get_E_axis(datename, prof_name, visualization, pixel_ROI, 0, sbend_setting);
