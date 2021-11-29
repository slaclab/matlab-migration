function thetaBraggDeg = eV2deg(eV,n, material)
%
% thetaBraggDeg = eV2deg(eV,n, material)
%
% Calculate bragg angle for diamond (default) or material = 'silicon'
% n is the Miller index, e.g. [0 0 4], [2 2 0], [1 1 3]; or the norm of the
% index,e.g. 16, 8, 11;
% Note for laue geometry you  want 90 - thetaBraggDeg

if nargin == 2
    material = 'diamond';
else
    if ~strcmpi(material, 'diamond')
        material = 'silicon';
    end
end

n = norm(n);
dnm = latticeConstant(material);
thetaBraggDeg = (180/pi)*asin(n*eV2nm(eV)/(2*dnm));