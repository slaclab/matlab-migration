function [geo] =  girderGeo(segmentNo)
%
% [geo] =  girderGeo(segmentNo)
%
% Returns structure geo containing various static geometry 
% 
% All coordinates in Girder Coordinate System in [mm] or [rad].
%
% rho1:5 are vectors from rotation centers to contact points 
% e1:5 are the eccentricities of the cams
% eta1:5 are the angles of the flats for each cam
% ctr1:5 are the centers of rotation for motion by  cam1-5 resp
%
% if no segmentNo is given, the average measured eccentricities and
% distortion data are used. Otherwise the measured eccentricites for that
% particular girder are used.
%
% See LCLS-TN-09-02 for documentation

% z locations
geo.z2 = 1170;       %2-cam plane location
geo.z3 = -1170;      %3-cam plane location
geo.quadz = 1807.89; %quad center z
%geo.bfwz = -1795.26; %beam finder wire center z
geo.bfwz = geo.quadz - 1000*3.6016; % based on measured positions relative to quad 12/19/13
geo.bpmz = 1938.0;   %bpm center z
geo.bpm00z = geo.bfwz -135.770; % special case, RFBU00 is attached to first girder
geo.segmentEndUpstream = -3079/2; % upstream end of the magnetic array from drawings 3/11/13
geo.segmentEndDownstream = 3079/2; % downstream end of the magnetic array from drawings 3/11/13

% Cam contact points xyz position in [mm].
% geo.cp1 = [-151.38 -384.2 geo.z3];% adjust based on cam center position and angle 11/4/08
% geo.cp2 = [302.94 -389.35 geo.z3];% adjust based on cam center position and angle 11/4/08
% geo.cp3 = [356.56 -398.18 geo.z3];% adjust based on cam center position and angle 11/4/08
% geo.cp4 = [-184.3 -388.7 geo.z2];%switched 4/5 to match control system 10/13/08
% geo.cp5 = [357.1 -397.1 geo.z2];%switched 4/5 to match control system 10/13/08
geo.cp1 = [-150.61 -384.2 geo.z3];% from part dwgs 11/26/08
geo.cp2 = [ 303.48 -389.36 geo.z3];% from part dwgs 11/26/08
geo.cp3 = [ 357.12 -398.18 geo.z3];% from part dwgs 11/26/08
geo.cp4 = [-183.96 -389.36 geo.z2];% from part dwgs 11/26/08
geo.cp5 = [ 357.12 -398.18 geo.z2];% from part dwgs 11/26/08

%eccentricities in mm
% geo.e1 = 2.199; %2.120 design, 2.189 matlab measured, 2.199 aps
% geo.e2 = 1.549; %1.575 design, 1.468 matlab measured, 1.549 aps
% geo.e3 = 1.573; %1.575 design, 1.542 matlab measured, 1.573 aps
% geo.e4 = 1.578; %matlab measured 1.517, 1.578 aps
% geo.e5 = 1.601; %matlab measured 1.620, 1.601 aps

eAllum = [...
1	2201	1552	1552	1564	1552;
2	2197	1563	1569	1556	1560;
3	2183	1579	1552	1523	1543;
4	2160	1548	1573	1585	1550;
5	2179	1552	1572	1594	1571;
6	2187	1573	1591	1566	1555;
7	2162	1538	1580	1593	1578;
8	2200	1565	1571	1585	1562;
9	2193	1517	1560	1581	1557;
10	2164	1523	1566	1593	1570;
11	2179	1517	1585	1552	1586;
12	2175	1539	1570	1587	1571;
13	2197	1533	1569	1547	1561;
14	2179	1551	1575	1564	1590;
15	2194	1537	1577	1585	1583;
16	2151	1541	1571	1558	1582;
17	2207	1543	1548	1566	1573;
18	2201	1522	1554	1566	1587;
19	2196	1556	1550	1552	1562;
20	2173	1542	1561	1548	1557;
21	2192	1553	1580	1543	1557;
22	2160	1564	1556	1580	1538;
23	2175	1577	1560	1564	1592;
24	2171	1569	1563	1548	1534;
25	2166	1548	1595	1542	1563;
26	2199	1549	1573	1578	1601;
27	2188	1533	1578	1559	1548;
28	2177	1555	1548	1554	1518;
29	2205	1526	1553	1531	1528;
30	2187	1538	1550	1595	1587;
31	2186	1533	1565	1552	1569;
32	2198	1552	1584	1498	1508;
33	2188	1500	1504	1503	1494];
if nargin>0
    geo.e1 = eAllum(segmentNo,2)/1000;
    geo.e2 = eAllum(segmentNo,3)/1000;
    geo.e3 = eAllum(segmentNo,4)/1000;
    geo.e4 = eAllum(segmentNo,5)/1000;
    geo.e5 = eAllum(segmentNo,6)/1000;
else
    geo.e1 = 2.184; %2.120 design, 2.189 matlab measured, 2.199 aps
    geo.e2 = 1.558; %1.575 design, 1.468 matlab measured, 1.549 aps
    geo.e3 = 1.558; %1.575 design, 1.542 matlab measured, 1.573 aps
    geo.e4 = 1.558; %matlab measured 1.517, 1.578 aps
    geo.e5 = 1.558; %matlab measured 1.620, 1.601 aps
end

% Cam contact angles in radians
geo.eta1 = -0*pi/180 + eps;% 0 is design, use eps to avoid infinities
geo.eta2 =  -25.6*pi/180;
geo.eta3 = 42.8*pi/180;%design 42.8
geo.eta4 = -25.6*pi/180;%switched 4/5 to match control system 10/13/08
geo.eta5 = 42.8*pi/180;%switched 4/5 to match control system 10/13/08

%linear potentiometer contact points
%geo.lp1= [-65.5 -379.7 geo.z3];% D Schafer 10/30/08 + .090" spacer
geo.lp1= [-72.38 -379.7 geo.z3];% update from drawings11/25/08
%geo.lp2= [ 195.4 -379.7 geo.z3];%  D Schafer 10/30/08 + .090" spacer
geo.lp2= [ 202.05 -379.7 geo.z3];% update from drawings11/25/08
geo.lp3= [ 375.0 -369.4 geo.z3];%  D Schafer 10/30/08 + .090" spacer
%geo.lp5= [-121.1 -393.9 geo.z2];%  field verification 10/30/08
geo.lp5= [-127.99 -393.9 geo.z2];% update from drawings 11/25/08
%geo.lp6= [ 195.4 -393.9 geo.z2];%  D Schafer 10/30/08 and field verification
geo.lp6= [ 316.33 -393.9 geo.z2];% update from drawings 11/25/08
geo.lp7= [ 375.0 -369.4 geo.z2];%  D Schafer 10/30/08

% unit vectors normal to cam contact surface pointing into the body
geo.u1 = [-sin(geo.eta1) cos(geo.eta1) 0];
geo.u2 = [-sin(geo.eta2) cos(geo.eta2) 0];
geo.u3 = [-sin(geo.eta3) cos(geo.eta3) 0];
geo.u4 = [-sin(geo.eta4) cos(geo.eta4) 0];
geo.u5 = [-sin(geo.eta5) cos(geo.eta5) 0];

% geometry matrices for axis/angle transformations for 3-cam plane,
% equation 12 in LCLS-TN-09-02
geo.m3 = [geo.u1(1) geo.u1(2) dot(geo.u1, cross([0 0 1], geo.cp1)) ;
          geo.u2(1) geo.u2(2) dot(geo.u2, cross([0 0 1], geo.cp2)) ;
          geo.u3(1) geo.u3(2) dot(geo.u3, cross([0 0 1], geo.cp3)) ;]; 
geo.m3inv = geo.m3^(-1);

% geometry matrices for axis/angle transformations for 2-cam plane,
% equation 15 in LCLS-TN-09-02
geo.m2 = [geo.u4(1) geo.u4(2) dot(geo.u4, cross([0 0 1], geo.cp4));
          geo.u5(1) geo.u5(2) dot(geo.u5, cross([0 0 1], geo.cp5))];
A =geo.m2;
A(:,3) = '';
geo.m2inv = A^(-1); % inverse is only 2x2. Theta (roll) must be known.
          
% Change in Quad Roll in radians for each segment when the
% segment is extracted to 80 mm due to girder support distortions. 
% Assume this is same as roll at 2-cam plane because twist only occurs
% between the two cam planes.
dr2 = 0.001*[ -0.1796250000000000
-0.1799166666666670
-0.1506666666666670
-0.1507916666666670
-0.1698333333333330
-0.1583333333333330
-0.1618750000000000
-0.1556666666666670
-0.1616250000000000
-0.1632916666666670
-0.1710000000000000
-0.1683333333333330
-0.1681666666666670
-0.1777500000000000
-0.1637500000000000
-0.1766666666666670
-0.1702500000000000
-0.1727083333333330
-0.1657500000000000
-0.1536250000000000
-0.1566250000000000
-0.1505000000000000
-0.1635000000000000
-0.1625000000000000
-0.1706250000000000
-0.1719166666666670
-0.1595000000000000
-0.1785000000000000
-0.1629166666666670
-0.1720416666666670
-0.1615000000000000
-0.1635833333333330
-0.1572083333333330 ]; % From Franz Peters 5/28/10 in mrad


dyQ = 0.001*[
-13.36
-13.32
-13.37
-11.05
-13.14
-12.22
-12.92
-12.77
-13.08
-10.34
-13.60
-13.36
-12.01
-13.09
-12.33
-13.94
-12.20
-14.78
-13.62
-12.94
-12.18
-13.85
-12.18
-12.48
-11.39
-13.05
-11.64
-13.46
-12.18
-13.36
-10.58
-10.43
-10.02];%  From Franz Peters 5/28/10 in um

dxQ = 0.001*[ 
-5.56
-5.73
-1.03
-5.47
-5.65
-3.15
-5.28
-4.49
-6.92
-6.54
-6.21
1.88
-6.84
-5.72
-5.39
-6.52
-8.63
-3.76
-7.60
-3.41
-4.51
-2.18
-3.74
-2.61
-4.07
-4.30
-2.29
-7.13
-5.13
-1.27
-9.27
-2.56
-3.34]; %  From Franz Peters 5/28/10 in um
geo.dr2 = mean(dr2);
geo.dxQ = mean(dxQ);
geo.dyQ = mean(dyQ);

geo.dr3 = 0*dr2;
geo.dxBFW  = 0;
geo.dyBFW = 0;

% Segment centers in meters
geo.segmentCenters = segmentCenters();

% Magnetic lengths from Nuhn May 31, 2013
geo.magneticLength = 1000* 3.34628; % mm average

% SXRSS BOD positions. From Daniel Morton BOD Final Checkout
% Use average relative position (accurate? values differ by only 4 mm)
geo.bodz = 1000 * mean( [( 551.1209 - geo.segmentCenters(10) ), ( 563.1634 - geo.segmentCenters(13) )] ) ;

geo.bpm34z = geo.bpmz + 184.7085; % special case, RFBU34 is attached to last girder
