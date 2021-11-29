function dnm = latticeConstant(material)
%
% dnm = latticeConstant(material)
%
% material is 'diamond' or 'silicon'. If no material is specified diamond
% is assumed.

if nargin == 0
    material = 'diamond';
end

switch lower(material)
    case 'silicon'
        dnm = 0.54311; % nm for si
    otherwise
        dnm = 3.56683/10; % nm for diamond, http://www.siliconfareast.com/lattice_constants.htm
end