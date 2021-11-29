function [xc yc sigxc sigyc]=readcentroidposition(CamSelector,Navg)
%Calculates the centroid position in pixels of the beam on the beamline
%screens and the related rms errors.
%Syntax:[xc yc sigxc sigyc]=readcentroidposition(CamSelector,Navg)
%where CamSelector is used to select the CCD (0=>LCam1; 1=>SCam1; 2=>SCam2;
%3=>SCam3; 4=>SCam4)
% Navg sets the number of measurement averages
%TO BE DEBUGGED!!!!


timebetweenreadings_s=1;%time between readings in s

if CamSelector==0
    CamStr='LCam1';
    pxsize=6.5e-6;
elseif CamSelector==1
    CamStr='SCam1';
    pxsize=14.11e-6;% to be verified!
elseif CamSelector==2
    CamStr='SCam2';
    pxsize=9.13e-6;% to be verified
elseif CamSelector==3
    CamStr='SCam3';
    pxsize=16.19e-6;% to be verified
elseif CamSelector==4
    CamStr='SCam4';
    pxsize=16.19e-6;% to be verified
else
    CamStr='SCam1';
    CamSelector=1;
    pxsize=14.11e-6;% to be verified
end
xcStr=[CamStr,':Stat:CentroidX'];
ycStr=[CamStr,':Stat:CentroidY'];

Navg=abs(floor(Navg));
if Navg<1
    Navg=1;
end

xc=0;
yc=0;
x2c=0;
y2c=0;
for ii=1:Navg
    xact=getpv(xcStr);
    yact=getpv(ycStr);
    xc=xc+xact;
    yc=yc+yact;
    x2c=x2c+xact^2;
    y2c=y2c+yact^2;
    pause(timebetweenreadings_s)
end
xc=xc/Navg*pxsize;
yc=yc/Navg*pxsize;

x2c=x2c/Navg*pxsize^2;
y2c=y2c/Navg*pxsize^2;

sigxc=sqrt(x2c-xc^2);
sigyc=sqrt(y2c-yc^2);

end

