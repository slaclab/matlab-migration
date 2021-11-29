function [camAngles] = girderAxis2Angle(pa, pb, roll)
%
% [camAngles] = girderAxis2Angle(pa, pb, roll)
%
% Returns array of 5 cam angles (radians) that would place the Girder Axis
% through points pa =[xa ya za] [mm] and pb=[xb yb zb] with roll angle =
% roll(radians).
%
% The Girder Axis (GA) moves with the girder. When cams are in the neutral
% position the GA is coincident with the design beamline. pa and pb are 
% vectors [X Y Z] in the CAM Coordinate System (CCS). The GA is the z axis
% of the CCS and is centered on the midpoint of the undulator segment. The
% CCS y axis is up and x is toward the aisle (like the MAD coordinate
% system).
%
% roll is an optional rotation angle about the z axis. Default is zero.
%
% See LCLS-TN-09-02 for documentation. Comments in code refer to this
% paper.

[nSegs,junk] = size(pa);
if nargin==2
    roll = zeros(nSegs,1);
end

%get geometry
geo = girderGeo();

%Derive position vectors at 2-cam and 3-cam planes (See Figure 6 with P2=TA, P3=TB) 
% P2 = pa + ((geo.z2 - pa(:,3))./(pb(:,3) - pa(:,3))) * (pb - pa);
% P3 = pa + ((geo.z3 - pa(:,3))./(pb(:,3) - pa(:,3))) * (pb - pa);
dp = pb - pa;
factor2 = ((geo.z2 - pa(:,3))./(pb(:,3) - pa(:,3))) ;
factor3 = ((geo.z3 - pa(:,3))./(pb(:,3) - pa(:,3))) ;
P2 = pa; P3 = pb; % initialize arrays
for q=1:nSegs
    P2(q,:) = pa(q,:) + factor2(q)*dp(q,:);
    P3(q,:) = pa(q,:) + factor3(q)*dp(q,:);
end


% Cam angles, from equations 13 through 16
M3= geo.m3; M2 = geo.m2;
P3 = P3'; P2 = P2';
phiTerm3 = M3*[P3(1,:); P3(2,:); roll'];
phi1 = asin(phiTerm3(1,:)/geo.e1);
phi2 = asin(phiTerm3(2,:)/geo.e2);
phi3 = asin(phiTerm3(3,:)/geo.e3);

phiTerm2 = M2*[P2(1,:); P2(2,:); roll'];
phi4 = asin(phiTerm2(1,:)/geo.e4);
phi5 = asin(phiTerm2(2,:)/geo.e5);

%Return the vector of angles
camAngles=[phi1' phi2' phi3' phi4' phi5'];
