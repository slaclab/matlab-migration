set(gcf, 'Color', 'w');
set(0, 'defaultaxesfontsize', 20);
set(0,'defaulttextfontsize',18);
    prof_name = 'CELOSS';
    datename = '20130423'; % date the calibration data was taken on
    visualization = 0; % 1 to see what function does
    sbend_setting = 20.35; % sbend setting the experimental data was taken at
    pixel_ROI = 1:1392; % ROI
    offset = 0;
   E = E200_cher_get_E_axis(datename, prof_name, visualization, pixel_ROI, 0, sbend_setting); % quick to call
%   [E, Eres, D] = E200_cher_get_E_axis(datename, prof_name, visualization, pixel_ROI, 0, sbend_setting); % slower to call
   subplot(3,1,1);
   hh = plot(pixel_ROI, E);
   set(hh, 'LineWidth', 3');
   xlabel('pix [#]');
   ylabel('E [GeV]');
   grid on;
   subplot(3,1,2);
   hh =plot(E, Eres);
   set(hh, 'LineWidth', 3');
   xlabel('E [GeV]');
   ylabel('E res. [GeV]');
   grid on;
   subplot(3,1,3);
   hh = plot(E, D*1e2);
   set(hh, 'LineWidth', 3');
   xlabel('E [GeV]');
   ylabel('D_y [cm]');
   grid on;
