function thetaBraggDeg = eV2deg(eV,n, material)
%
% thetaBraggDeg = eV2deg(eV,n, material)
%
% Calculate bragg angle for diamond (default) or material = 'silicon'
% n is the Miller index, e.g. [0 0 4], [2 2 0], [1 1 3]; or the norm of the
% index,e.g. 16, 8, 11;
% Note for laue geometry you  want 90 - thetaBraggDeg
eV = lcaGet('SIOC:SYS0:ML00:AO627');
n1 = [0 0 4];
n2 = [2 2 0];
n3 = [1 1 1];
material = 'diamond';
dnm = latticeConstant(material);
n1 = norm(n1);
thetaBraggDeg1 = (180/pi)*asin(n1*eV2nm(eV)/(2*dnm));
n2 = norm(n2);
thetaBraggDeg2 = 90 - (180/pi)*asin(n2*eV2nm(eV)/(2*dnm));
n3 = norm(n3);
thetaBraggDeg3 = (180/pi)* acos( sqrt(1/3))+ (180/pi)*asin(n3*eV2nm(eV)/(2*dnm));
lcaPut('SIOC:SYS0:ML02:AO290',thetaBraggDeg1)
lcaPut('SIOC:SYS0:ML02:AO291',thetaBraggDeg2)
lcaPut('SIOC:SYS0:ML02:AO292',thetaBraggDeg3)
delete(gcf)
if ~usejava('desktop')
    exit
end