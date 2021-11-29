function [D,E,Dx]=SXRSS_overlapCalc(G0,G,W,X,Off)

%SXRSS_OVERLAPCALC
%  SXRSS_OVERLAPCALC(TAGS, EVENT) moves mirror positions

% Features:

% Input arguments:
%    GO:    Initial girder position for BOD wire scan (um)
%    G:     Girder position of wire scan centroid (um)
%    W:     Screen coordinates of wires (um)
%    X:     X-ray beam screen coordinates (um)
%    Off:   Off(1) M3P on BOD10, Off(2) M3P on BOD13

% Output arguments: 
%    D:     Mirror movement [G1Y (um); M3X (mm);M3P (mrad);M3O (mrad)]
%    E:     Electron beam screen coordinates (mm)
%    Dx:    [X10 Y10 X13 Y13], disp on respective screen (um)

% Compatibility: Version 2007b, 2012a
% Called functions: SXRSS_bodSteer.m 

% Author: Dorian Bohler SLAC

% Example:
%   G0=vals(1:4); G=vals(5:8); X=vals(9:12); Off=vals(13:14);
%   W=vals(15:18);
%   [D,eScCoords, dx]=SXRSS_overlapCalc(G0,G,W,X,Off);

% --------------------------------------------------------------------

E=W+G-G0;

S=X-E;

M3P_Offset= Off(1)-Off(2);

offs=[M3P_Offset 0];

[D, Dx] = SXRSS_bodSteer(S, offs);

E=E*1e-3; 