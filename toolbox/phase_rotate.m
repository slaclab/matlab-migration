%phase_rotate.m
% rotates an input phase in degrees, by a specified amount, avoiding 180
% degree flips. 
%out = phase_rotate(in, theta)
%in is the input phase in degrees
%theta is the rotation angle in degrees
%out is the output phase -180 to 180 degrees


function out = phase_rotate(in, theta)

inr = in * pi/180;
thetar = theta * pi/180;

s = sin(inr);
c = cos(inr);

s2 = s * cos(thetar) + c * sin(thetar);
c2 = -s * sin(thetar) + c * cos(thetar);
out = atan2(s2,c2) * 180/pi;
