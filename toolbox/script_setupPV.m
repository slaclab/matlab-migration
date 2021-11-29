function pvout = script_setupPV(pv, text, egu, prec, comment, sysx, mlxx)
%SCRIPT_SETUPPV
%  PVOUT = SCRIPT_SETUPPV(PV, TEXT, EGU, PREC, COMMENT, [SYSX, MLXX])
%    sets the description, units, comment and etc fields for generic SIOC PVs. 
%
% Input arguments:
%   PV:     PV name, as a string (e.g. 'SIOC:SYS1:ML00:AO123') or number (e.g. 123).
%   TEXT:   String that goes into the .DESC field
%   EGU:    String that goes into the .EGU field
%   PREC:   Numerical precision
%   COMMENT: String that goes into the comment PV (e.g. 'SIOC:SYS1:ML00:SO0123')
%   SYSX, MLXX:  If PV is supplied as a number, the system and region default 
%           to 'SYS0' and 'ML00'.  Different ones can be specified with
%           SYSX and MLXX.  
%
% Output arguments:
%   PVOUT:  PV name, as a string.
%
% Compatibility: Version 7 and higher
%
% Author: Nate Lipkowitz, SLAC
%
% --------------------------------------------------------------------
prefix = 'SIOC';

if nargin < 6
    sysx = 'SYS0';
    mlxx = 'ML00';
end

if isnumeric(pv)
    pv = reshape(pv, [], 1);
    % if PV is the number of the PV, construct the PV string
    pvnum = num2str(abs(round(pv)), '%03.0f');    % pad pv number with zeros

else
    pv = reshape(cellstr(pv), [], 1);
    n = 0;
    while ~isempty(char(pv))
        n = n + 1;
        [a{n}, pv] = strtok(pv, ':');
    end
    if nargin > 5
        sysx = cellstr(repmat(sysx, size(a{2})));
        mlxx = cellstr(repmat(mlxx, size(a{3})));
    else
        sysx = a{2};
        mlxx = a{3};
    end
    pvnum = strtok(a{4}, 'AO');
end

pv = strcat(prefix, ':', sysx, ':', mlxx, ':AO', pvnum);
pv_comment = strcat(prefix, ':', sysx, ':', mlxx, ':SO0', pvnum);

lcaPut(strcat(pv, '.DESC'), text);
lcaPut(strcat(pv, '.EGU'), egu);
lcaPut(strcat(pv, '.PREC'), prec);
lcaPut(pv_comment, comment);

pvout = pv;

end