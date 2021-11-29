function eV = deg2eV(deg,n, material)
%
% eV = deg2eV(deg,n, material)
%
% Calculate bragg reflection energy for given wavelength and index for
% diamond (default) or 'silicon')

if nargin == 2
    material = 'diamond';
else
    if ~strcmpi(material, 'diamond')
        material = 'silicon';
    end
end

n = norm(n);
dnm = latticeConstant(material);
lambda = 2*dnm*sin(deg*pi/180)/n;
eV = nm2eV(lambda);