function [P, roll] = girderAngle2Axis(z, camAngles)
%
%   [P, roll] = girderAngle2Axis(z, camAngles)
%
% Calculate displacement and roll of the Girder Axis at z, given a set of cam angles
%
% The Girder Axis (GA) is a theoretical line that moves with the girder.
% When cams are in the neutral position, the GA is coincident with the
% design beamline.
%
% P is a 3-d vector [X Y Z] 
%
% Units are mm for distance and radians for angle.
%
% roll is the rotation angle about the z axis.

% abreviations
phi1=camAngles(1); % radians
phi2=camAngles(2);
phi3=camAngles(3);
phi4=camAngles(4);
phi5=camAngles(5);

% get geometry
geo = girderGeo;

% calculate the position of the Girder axis is the cam planes
[P3, roll] = camMove3(phi1, phi2, phi3, geo);% 3-cam plane
[P2] = camMove2(phi4, phi5, roll, geo);% 2-Cam plane

% extrapolate from cam planes to point to the z plane
P = P3 + ((z - geo.z3)/(geo.z2 - geo.z3)) * (P2 - P3);
P(3)=z; % make 3d vector

function [P, roll] = camMove3(phi1,phi2,phi3,geo)
%Return roll and transverse displacement of Girder Axis at 3-Cam plane
%given phi1,2,3, and geometry data
%
%P is a vector [x y] [mm] the the displaced position of the Girder Axis
%from the phi= 0 neutral position
%
% See LCLS-TN-02-01 for documentation
P = geo.m3inv * [geo.e1*sin(phi1); geo.e2*sin(phi2); geo.e3*sin(phi3) ];
roll = P(3);
P(3) ='';
P = P';
     
function [P] = camMove2(phi4,phi5, roll, geo)
%Return transverse displacement of Girder Axis at 2-Cam plane given phi4,5,
%roll and geometry data
%
%P is a vector [x y] [mm] the the displaced position of the Girder Axis
%from the phi= 0 neutral position Roll is assumed to be fixed by the
%upstream 3-cam plane. 
% 
% See LCLS-TN-02-01 for documentation
P = geo.m2inv * [geo.e4*sin(phi4) - roll* dot(geo.u4, cross([0 0 1], geo.cp4));...
                 geo.e5*sin(phi5) - roll* dot(geo.u5, cross([0 0 1], geo.cp5))];
P = P';


     
