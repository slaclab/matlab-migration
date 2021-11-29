function [theta,G] = fbGetCorrectorKicks(G,p,p_setp)

%	[theta,G] = fbGetCorrectorKicks(dev0, XCORs,YCORs,p,p_setp);
%
%	Convert trajectory fit results, p, & set-points, p_setp, into 2x & 2y kick angles, theta
%
%	INPUTS:		G:          The conversion matrix from theta to (p-p_setp)
%				p:			The initial conditions of the diff. orbit [xpos xang ypos yang] in (mm mrad mm mrad)
%				p_setp:		The desired set-point of the initial conditions [xpos xang ypos yang] in (mm mrad mm mrad)
%
%	OUTPUTS:	theta:		2 x-kick and 2 y-kick angles to get to the set-point [mrads]
%                           but we need theta in rad, so theta*10-3;
%===============================================================================

theta = (G\(p_setp-p)'*1e-3);
