% this function implements divide and conquer to find a global maximum in a
% 2D array.


function [x_out, y_out] = TwoD_brute_force(image_in)
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

% x_start = 500;
% x_stop = 650;
% 
% y_start = 200;
% y_stop = 300;
% 
% A = A(y_start:y_stop,x_start:x_stop);

% A_back = A;
% 
% 
% figure(1)
% imagesc(A_back)
% set(gcf,'Position',[ 1180         585         560         420]);

A = image_in;

B = size(A);

Ni = B(1);
Nj = B(2);

x_out = 1;
y_out = 1;
max_val = 0;

for i = 1 : Ni
    for j = 1 : Nj
        if A(i,j) > max_val;
            x_out = j;
            y_out = i;
            max_val = A(i,j);
        end
    end
end

% figure(2)
% imagesc(A_back)
% set(gcf,'Position',[ 1180         585-520         560         420]);
% line([x_max x_max],[1 Ni],'Color','r')
% line([1 Nj],[y_max y_max],'Color','r')

    



