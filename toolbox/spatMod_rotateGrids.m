function [gridX, gridY] = spatMod_rotateGrids(X, Y, center1, center2, degree)
% ROTATEGRIDS    Takes the [X, Y] meshgrid and rotates them clockwise
%                around the center point.
%
%   First translates the meshgrids and centers them around the origin, then
%   multiplies the points by a rotation matrix, and finally translates the
%   points back to the original center using the center coordinates.

%rotate the grid counterclockwise by -degree.
degree = degree * -1;
X = X - center2;
Y = Y - center1;
gridX = (X * cosd(degree)) - (Y * sind(degree));
gridY = (X * sind(degree)) + (Y * cosd(degree));
gridX = gridX + center2;
gridY = gridY + center1;

end