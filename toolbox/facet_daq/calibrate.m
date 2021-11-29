function [M,R,T] = calibrate()

% before start, set motors such that images on ax_img1/2/3 are more or less
% centered so that we don't jump out of the range of camera.
data1 = profmon_grab('EXPT:LI20:3307');
img1 = medfilt2(data1.img);
imagesc(img1);colorbar();
[x1,y1]=ginput(1);

data2 = profmon_grab('EXPT:LI20:3310');
img2 = medfilt2(data2.img);
imagesc(img2);colorbar();
[x2,y2]=ginput(1);

data3 = profmon_grab('EXPT:LI20:3313');
img3 = medfilt2(data3.img);
imagesc(img3);colorbar();
[x3,y3]=ginput(1);

% find centres of the images in mm (j7 for kinoform, j0 for axicon) 
x_1 = x1*data1.res*1e-3;
y_1 = y1*data1.res*1e-3;
x_2 = x2*data2.res*1e-3;
y_2 = y2*data2.res*1e-3;
x_3 = x3*data3.res*1e-3;
y_3 = y3*data3.res*1e-3;
%resolution mircrons/pixel
%resolutionAx_img1 = 6.4; from spreadsheet
%resolutionAx_img2 = 11.4; from spreadsheet

% to be found in: Laser -> NewFocus Picomotors -> IP1 EXPT 2-1
tilt_hor = lcaGet('MOTR:LI20:MC14:M0:CH1:MOTOR'); %get horizontal tilt of the USHM
tilt_ver = lcaGet('MOTR:LI20:MC14:M0:CH2:MOTOR'); %get vertical tilt of the USHM
pos_ver = lcaGet('MOTR:LI20:MC14:M0:CH3:MOTOR'); %vertical postion of Axicon 
pos_hor = lcaGet('MOTR:LI20:MC14:M0:CH4:MOTOR'); %horizontal postion of Axicon 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% tranlate axicon (kinoform) in horizontal direction
a1 = 30; a2 = 0;
lcaPut('MOTR:LI20:MC14:M0:CH4:MOTOR',pos_hor+a1);
lcaPut('MOTR:LI20:MC14:M0:CH3:MOTOR',pos_ver+a2);
% get centre of ax_image2 (plasma centre) with updated axicon positions in mm
data = profmon_grab('EXPT:LI20:3310');
img = medfilt2(data.img);
imagesc(img);colorbar();
[x2_new,y2_new]=ginput(1);

%convert to mm
x_2_new = x2_new*data2.res*1e-3;
y_2_new = y2_new*data2.res*1e-3;

M11 = (x_2_new-x_2)/a1;
M21 = (y_2_new-y_2)/a1;

% return to original value, then translate in vertical direction.
a1 = -30; a2 = 30;
lcaPut('MOTR:LI20:MC14:M0:CH4:MOTOR',pos_hor+a1);
lcaPut('MOTR:LI20:MC14:M0:CH3:MOTOR',pos_ver+a2);
% get centre of ax_image2 (plasma centre) with updated axicon positions in mm
data = profmon_grab('EXPT:LI20:3310');
img = medfilt2(data.img);
imagesc(img);colorbar();
[x2_new,y2_new]=ginput(1);

%convert to mm
x_2_new = x2_new*data2.res*1e-3;
y_2_new = y2_new*data2.res*1e-3;

M12 = (x_2_new-x_2)/a2;
M22 = (y_2_new-y_2)/a2;

% conversion matrix M relating a translation of axicon to a translation of
%Ax_image2 in centre plasma.
M = [M11 M12
    M21 M22];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%distance between focus plane ax_img1 and ax_img3 is z13 = 1830 mm
z13 = 1830;

%induce horizontal tilt:
b1=10; b2=0;
lcaPut('MOTR:LI20:MC14:M0:CH1:MOTOR', tilt_hor+b1);
lcaPut('MOTR:LI20:MC14:M0:CH2:MOTOR', tilt_ver+b2);

%find new positions of the centres in mm (from screens)
data1 = profmon_grab('EXPT:LI20:3307');
img1 = medfilt2(data1.img);
imagesc(img1);colorbar();
[x1_new,y1_new]=ginput(1);

data2 = profmon_grab('EXPT:LI20:3310');
img2 = medfilt2(data2.img);
imagesc(img2);colorbar();
[x2_new,y2_new]=ginput(1);

data3 = profmon_grab('EXPT:LI20:3313');
img3 = medfilt2(data3.img);
imagesc(img3);colorbar();
[x3_new,y3_new]=ginput(1);

%convert to mm
x_1_new = x1_new*data1.res*1e-3;
y_1_new = y1_new*data1.res*1e-3;
x_2_new = x2_new*data2.res*1e-3;
y_2_new = y2_new*data2.res*1e-3;
x_3_new = x3_new*data3.res*1e-3;
y_3_new = y3_new*data3.res*1e-3;

%calculate angle change about the plasma centre
angle_hor = ((x_3_new-x_3)-(x_1_new-x_1))/z13;
angle_ver = ((y_3_new-y_3)-(y_1_new-y_1))/z13; %atan is negligible

R11 = angle_hor/b1;
R21 = angle_ver/b1;

%translation of centre
T11 = (x_2_new-x_2)/b1;
T21 = (y_2_new-y_2)/b1;

%return to original value and induce vertical tilt:
b1=-10; b2=10;
lcaPut('MOTR:LI20:MC14:M0:CH1:MOTOR', tilt_hor+b1);
lcaPut('MOTR:LI20:MC14:M0:CH2:MOTOR', tilt_ver+b2);

%find new positions of the centres in mm
data1 = profmon_grab('EXPT:LI20:3307');
img1 = medfilt2(data1.img);
imagesc(img1);colorbar();
[x1_new,y1_new]=ginput(1);

data2 = profmon_grab('EXPT:LI20:3310');
img2 = medfilt2(data2.img);
imagesc(img2);colorbar();
[x2_new,y2_new]=ginput(1);

data3 = profmon_grab('EXPT:LI20:3313');
img3 = medfilt2(data3.img);
imagesc(img3);colorbar();
[x3_new,y3_new]=ginput(1);

%convert to mm
x_1_new = x1_new*data1.res*1e-3;
y_1_new = y1_new*data1.res*1e-3;
x_2_new = x2_new*data2.res*1e-3;
y_2_new = y2_new*data2.res*1e-3;
x_3_new = x3_new*data3.res*1e-3;
y_3_new = y3_new*data3.res*1e-3;

%calculate angle change about the plasma centre
angle_hor = ((x_3_new-x_3)-(x_1_new-x_1))/z13;
angle_ver = ((y_3_new-y_3)-(y_1_new-y_1))/z13; %atan is negligible

R12= angle_hor/b2;
R22 = angle_ver/b2;

R = [R11 R12
    R21 R22];

T12 = (x_2_new-x_2)/b2;
T22 = (y_2_new-y_2)/b2;

T = [T11 T12
    T21 T22];
end
%end calibration

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





