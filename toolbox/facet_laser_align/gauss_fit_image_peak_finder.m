
function [x_out,y_out] = gauss_fit_image_peak_finder(image_in)
% %--------------------------------------------------------------------------
% %
% % This is stuff to load an example picture, it goes away when converting to
% % a function.
% %
% %--------------------------------------------------------------------------
% clear all;
% close all hidden;
% 
% addpath('/home/fphysics/boshea/laser_vector_auto/')
% 
% nas_path = '/nas/nas-li20-pm00/';
% experiment = 'E200';
% year = '2015';
% mon_day = '1106';
% DAQ_num = '18361';
% 
% DAQ_to_open = [nas_path '/' experiment '/' year '/' year mon_day '/'...
%     experiment '_' DAQ_num '/' experiment '_' DAQ_num '.mat'];
% 
% load(DAQ_to_open);
% 
% % Define which camera to use.
% camera_name = 'AX_IMG1';
% camera_to_use = data.raw.images.(camera_name);
% 
% file_num = 1;
% image_to_load = camera_to_use.dat(file_num);
% A = imread(image_to_load{:});
% 
% x_start = 500;
% x_stop = 650;
% 
% y_start = 200;
% y_stop = 300;
% 
% A = A(y_start:y_stop,x_start:x_stop);

%--------------------------------------------------------------------------
%
% The fit
%
%--------------------------------------------------------------------------




% Now use the lineout from the simple fit to try and get a better peak.
A = image_in;

% perform the projection then fit to a gaussian.

[x_out, y_out] = simple_image_peak_finder(A);

x_proj = sum(A,1);
x_proj = double(x_proj);
y_proj = sum(A,2);
y_proj = double(y_proj);

% for the fitter
x_x = 1 : 1 : length(x_proj);
y_x = 1 : 1 : length(y_proj);

[x_fit,Qx] = gauss_fit(x_x,x_proj);
[y_fit,Qy] = gauss_fit(y_x,y_proj);

x_out = Qx(3);
y_out = Qy(3);

% figure(1)
% set(gcf,'Position',[3896        1083         560         420])
% imagesc(A)
% line([x_out x_out],[0 700],'Color','r')
% line([0 1000],[y_out y_out],'Color','r')
% 
% figure(2)
% set(gcf,'Position',[ 3294        1075         560         420])
% 
% subplot(2,1,1)
% plot(x_proj)
% hold on;
% plot(x_fit,'Color','r')
% 
% subplot(2,1,2)
% plot(y_proj)
% hold on;
% plot(y_fit,'Color','r')






