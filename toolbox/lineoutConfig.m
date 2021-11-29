function [l] = lineoutConfig(width, height, Target)

% this function returns centered horizontal, vertical, diagonal, and anti-diagonal
% lines that are drawn based on the size of an image. This is orignally
% configured to work with the image analysis toolbox function 'improfile'
%
% inputs:
%   width - width of the image file in (pixels)
%   height - height of the image file in (pixels)
%   target - (optional)
% outputs: l1 (0 deg line) , l2 (45 deg line), l3(90 deg line), l4(135 deg line)
%   l - [l1 l2 l3 l4]
if nargin <3; Target =[0 0]; end

if ~Target
    x = height;
    y = width;
    half = x/2;
    x_vals=1:x;
    y_vals=zeros(1,x)+y/2;
    v=[x_vals;y_vals];
    x_center = x_vals(half);
    y_center = y_vals(x_center);
else
    x_vals = 1:Target(1)*2;
    y_vals = zeros(1,length(x_vals))+Target(2);
    x_center = Target(1);
    y_center = Target(2);
    v=[x_vals;y_vals];
end


theta1 = 45;
center = repmat([x_center; y_center], 1, length(x_vals));
s = v - center; 

R1 = [cosd(theta1) -sind(theta1); sind(theta1) cosd(theta1)];
so1 = R1*s;
vo1 = so1 + center;
x_rotated_1 =vo1(1,:);
y_rotated_1 =vo1(2,:);

theta2 = 45*2;
R2 = [cosd(theta2) -sind(theta2); sind(theta2) cosd(theta2)];
so2 = R2*s;
vo2 = so2 + center;
x_rotated_2 =vo2(1,:);
y_rotated_2 =vo2(2,:);

theta3 = 45*3;
R3 = [cosd(theta3) -sind(theta3); sind(theta3) cosd(theta3)];
so3 = R3*s;
vo3 = so3 + center;
x_rotated_3 =vo3(1,:);
y_rotated_3 =vo3(2,:);

% plot(x_vals,y_vals, 'k-', x_rotated_1, y_rotated_1, 'r-', x_rotated_2, y_rotated_2,...
%    'g-', x_rotated_3, y_rotated_3, 'b-',x_center, y_center, 'bo');

l1 = [x_rotated_1;y_rotated_1];
l2 = [x_rotated_2;y_rotated_2];
l3 = [x_rotated_3;y_rotated_3];

l = [v; l1 ; l2 ; l3];