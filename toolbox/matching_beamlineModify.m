function optics = matching_beamlineModify(optics, el_name, type, value)
%
% USAGE: 
%       optics = matching_beamlineModify(optics, el_name, type, value)
%
% INPUT: 
%   optics   : optics in
%   el_name  : type(s) of elements to modify 
%   type     : 1 for length segment , 2 for number of segments 
%   value    : see above 
%
% OUTPUT:
%   optics   : optics after adding field
%

use=ismember({optics.name},el_name);
switch type
    case 1
        ll = [optics(use).length];
        nseg = num2cell(round(ll/value));
        [optics(use).nsegment] = deal(nseg{:});
    case 2
        [optics(use).nsegment] = deal(value);
end
