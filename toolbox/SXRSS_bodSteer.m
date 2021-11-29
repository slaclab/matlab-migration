function [Y, move] = SXRSS_bodSteer(Separ, Offset)

% [G1Y,M3X,M3Theta,M3phi]= SXRSS_bodSteer(Separ, Offset)
%   The purpose of this script is to calculate the X-ray Steering response
%   for the BOD in the SXRSS.
%
%   INPUTS:     Separ(1): Xray Ebeam Separation on BOD10 in X-plane (mm)
%               Separ(2): Xray Ebeam Separation on BOD10 in Y-plane (mm)
%               Separ(3): Xray Ebeam Separation on BOD13 in X-plane (mm)
%               Separ(4): Xray Ebeam Separation on BOD13 in Y-plane (mm)
%               Offset(1): M3 Pitch Offset on BOD10 (mrad)
%               Offset(2): M3 Pitch Offset on BOD13 (mrad)
%   OUTPUTS:    Y:      [Yg (mm), XM3 (mm), M3Pitch (mrad), M3Roll (mrad)]
%   AUTHOR:     Dorian K. Bohler 11/20/13
% ========================================================================

   %   G1:Y  M3:X  M3:P   M3:R

M=[0.056  1897  2931  1.977; ...  % B10:X
    1.280  -3.1  12.6 -47.59; ...  % B10:Y
    0.198  1468 25750      0; ...  % B13:X
    5.687    -8    34 -413.9; ...  % B13:Y
    ];

move = -Separ + [M(1:2,3)*Offset(1); M(3:4,3)*Offset(2)];

Y = inv(M)*move;

