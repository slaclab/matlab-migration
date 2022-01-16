function PVName = DeassignMultiknob(PV)
%  DeassignMultiknob
%  DesssignMultiknob(PV) de-assigns a multiknob PV


% Input arguments:
%    PV: multiknob PV (MKB:SYS0:n or MKB:SYS0:n:FILE)

% Output arguments:
%    PVName: PVname(1) should be 0 if successfully de-assigned

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Jeff Rzepiela, SLAC

% --------------------------------------------------------------------
global mkbRequestBuilder
if strcmpi(PV, 'MKB:VAL')
    return
end
disp_log ('reset MKB')
idx=strfind(PV,'FILE');
if isempty(idx)
    PV=[PV ':FILE'];
end
lcaPut(PV,0);
PVName=lcaGet(PV,0,'double');
