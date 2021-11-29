% this function implements divide and conquer to find a global maximum in a
% 2D array.


function TwoD_divide_and_conquer()
%--------------------------------------------------------------------------
%
% This is stuff to load an example picture, it goes away when converting to
% a function.
%
%--------------------------------------------------------------------------
clear all;
close all hidden;

addpath('/home/fphysics/boshea/laser_vector_auto/')

nas_path = '/nas/nas-li20-pm00/';
experiment = 'E200';
year = '2015';
mon_day = '1106';
DAQ_num = '18361';

DAQ_to_open = [nas_path '/' experiment '/' year '/' year mon_day '/'...
    experiment '_' DAQ_num '/' experiment '_' DAQ_num '.mat'];

load(DAQ_to_open);

% Define which camera to use.
camera_name = 'AX_IMG1';
camera_to_use = data.raw.images.(camera_name);

file_num = 1;
image_to_load = camera_to_use.dat(file_num);
A = imread(image_to_load{:});

% x_start = 500;
% x_stop = 650;
% 
% y_start = 200;
% y_stop = 300;
% 
% A = A(y_start:y_stop,x_start:x_stop);

A_back = A;

figure(1)
imagesc(A_back)
set(gcf,'Position',[ 1180         585         560         420]);

x_start = 1;
y_start = 1;

for i = 1 : 1
    [sol_temp,A,temp_x,temp_y] = direction_determine(A);
    
    K = size(A);
    x_size = K(2);
    y_size = K(1);
    
    x_start = x_start + temp_x - 1;
    y_start = y_start + temp_y - 1;
    disp(num2str(x_start))
    disp(num2str(y_start))
    
    if sol_temp == 1     
        break
    end
    figure(2)
    imagesc(A)
    set(gcf,'Position',[ 1180         585-520         560         420]);
    
    figure(1)
    imagesc(A_back)
    set(gcf,'Position',[ 1180         585         560         420]);
    line([x_start x_start], [1 700],'Color','r')
    line([1 1200], [y_start y_start],'Color','r')
    rectangle('Position',[x_start y_start x_size y_size],'EdgeColor','r')
end

function [solved,A_out,sol_x,sol_y] = direction_determine(A)
% takes in only an image (or other 2D array)
% it returns the sub-array to use for further analysis.

% to determine which half of the array to keep, you need to find the larger
% dimension.  Then take the center column and the two on either side of the
% center.  If the peak is in the center, you are done.  If it is in the
% left column you continue the search in the left half.

B = size(A);
[~,C] = max(B);

center_column_i = round(B(C)/2);

if C == 1
    center_column = A(center_column_i,:);
    left_column = A(center_column_i-1,:);
    right_column = A(center_column_i+1,:);
elseif C == 2
    center_column = A(:,center_column_i);
    left_column = A(:,center_column_i-1);
    right_column = A(:,center_column_i+1);
end


[center_test,c_t_i] = max(center_column);
left_test = max(left_column);
right_test = max(right_column);

if center_test >= left_test && center_test >= right_test
    % You got lucky and the peak is in the middle!
    disp(['The peak is in the middle at : ' num2str(c_t_i)])
    D = 0;
elseif left_test >= center_test && left_test > right_test
    disp('Go left!')
    D = 1;
elseif right_test >= center_test && right_test >= left_test
    disp('Go right!')
    D = 2;
end

% output.  If a solution isn't found return the present coordinated of the
% upper left point for the current array under evaluation.


if D == 0 && C == 1
    solved = 1;
    A_out = 0;
    sol_y = center_column_i;
    sol_x = c_t_i;
elseif D == 0 && C == 2
    solved = 1;
    A_out = 0;
    sol_x = center_column_i;
    sol_y = c_t_i;
elseif D == 1 && C == 1
    solved = 0;
    A_out = A(1:center_column_i,:);
    sol_y = 1;
    sol_x = 1;
elseif D == 1 && C == 2
    solved = 0;
    A_out = A(:,1:center_column_i);
    sol_y = 1;
    sol_x = 1;
elseif D == 2 && C == 1
    solved = 0;
    A_out = A(center_column_i:end,:);
    sol_y = center_column_i;
    sol_x = 1;
elseif D == 2 && C == 2
    solved = 0;
    A_out = A(:,center_column_i:end);
    sol_y = 1;
    sol_x = center_column_i;
end
    
    
    
    
    
    



