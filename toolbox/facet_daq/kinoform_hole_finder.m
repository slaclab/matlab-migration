% this file looks for the center of the hollow channel ring.

% it performs the projection in both axes, uses the built in matlab
% function "findpeaks" and grabs the two highest points in both directions.
%  The mean of the two points for each direction is taken to be the center
%  of the hole.  Those two values are returned as x_bar and y_bar.

function [x_bar, y_bar] = kinoform_hole_finder(image_in)

x_proj = sum(image_in,1);
y_proj = sum(image_in,2);

% find the maximums in the y direction

[yPKS,yLocs] = findpeaks(y_proj);
[xPKS,xLocs] = findpeaks(x_proj);

% find the max of the peaks, store its position and remove it from the
% list.  The next maximum should be the other side of the ring.

[~,B] = max(yPKS);
i_y_max_1 = yLocs(B);

yPKS(B) = 0;

[~,B] = max(yPKS);
i_y_max_2 = yLocs(B);

% now x

[~,B] = max(xPKS);
i_x_max_1 = xLocs(B);

xPKS(B) = 0;

[~,B] = max(xPKS);
i_x_max_2 = xLocs(B);

% Assume it is actually a circle and take the mean as the center.

y_bar = round((i_y_max_1 + i_y_max_2)/2);
x_bar = round((i_x_max_1 + i_x_max_2)/2);