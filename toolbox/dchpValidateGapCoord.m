function val = dchpValidateGapCoord(module, us_gw, us_gc, ds_gwo, ds_gco)
% function VAL = dchpValidateGapCoord(MODULE, US_GW, US_GC, DS_GWO, DS_GCO)
%
% Validate dechirper module gap coordinates.
%
% Inputs:
%  MODULE = 'V' or 'H'
%  US_GW  = upstream gap width (mm)
%  US_GC  = upstream gap center (mm)
%  DS_GWO = upstream gap width offset (mm)
%  DS_GCO = upstream gap center offset (mm)
%
% Output:
%  VAL = 1 if valid, 0 if invalid
switch lower(module)
    case 'v'  
        pv = 'DCHP:LTU1:545:'; % not yet active
        rail = {'T','B'}; 
    case 'h'
        pv = 'DCHP:LTU1:555:';
        rail = {'N','S'};
    otherwise
        error('Invalid module specified.')
end
% Convert to each rail's absolute system:
us_pa = us_gc + [0.5,-0.5].*us_gw;
ds_pa = (us_gc + ds_gco) + [0.5,-0.5].*(us_gw + ds_gwo);
% Validate
val = dchpValidateAbsCoord(module,us_pa(2),ds_pa(2) - us_pa(2),...
    us_pa(1),ds_pa(1) - us_pa(1));
