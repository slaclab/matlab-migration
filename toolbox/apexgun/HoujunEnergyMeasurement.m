v1=630;
phi1=-30;
g1=v1*cos(phi1/180*pi)/511+1;
b1=(1-g1^-2)^0.5;

phi2=phi1-20;
v2=v1*cos(phi2/180*pi);
g2=v2/511+1;
b2=(1-g2^-2)^0.5;

L=2.5;
c=3e8;
f=1.3e9;

dphi = (L/b2/c - L/b1/c)*2*pi*f/pi*180