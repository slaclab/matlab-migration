function list = pl_add_ML02(list, pvnum, desc, egu, prec)
%PL_ADD_ML02
%  LIST = PL_ADD_ML02(LIST, PVNUM, [DESC, EGU, PREC]) adds the Matlab
%  support PV specified by PVNUM to the list of PVs specified by LIST.  The
%  name of the PV is SIOC:SYS0:ML02:AOXXX where XXX is determined by PVNUM,
%  which must be between 0 and 999.
%
%  PL_ADD_ML02 also writes a description, engineering units and numerical
%  precision to the Matlab support PV's .DESC, .EGU and .PREC fields if
%  they are provided in DESC, EGU and PREC.  However, the value of the PV
%  does not change until set by PL_WRITE.
%
% Input arguments:
%    LIST:  The PV list that PVNAME will be added to.  Note the modified
%       list is returned by this function, so calls should be of the form
%       mylist = pl_add(mylist, name, description);
%    PVNUM: The number of a Matlab support PV to be added to the list,
%       e.g. '275'.  Must be between 0 and 999.
%    DESC:  (Optional) A unique descriptive string, e.g. 'L2 phase'.
%       Defaults to the PV name if not supplied.
%    EGU:   (Optional) Engineering units associated with the PV, e.g.
%       'degS'.  Defaults to 'egu' if not supplied.
%    PREC:  (optional) Numerical precision associated with the PV, e.g.
%       '2'.  Defaults to '1' if not supplied.
%
% Output arguments:
%    LIST:  The modified list, with SIOC:SYS0:ML02:AOXXX added to it.
%
% Usage:
%   % create a new empty list
%   mylist = pl_create('My test list');
% 
%   % add the injector laser power to the list
%   mylist = pl_add(mylist, 'LASR:IN20:196:PWR1H', 'Laser power');
% 
%   % add a matlab support PV SIOC:SYS0:ML00:AO789 to the list
%   % with units of milliJoules and 2 decimal places of precision
%   mylist = pl_add_ML00(mylist, 789, 'My test PV', 'mJ', 2);
% 
%   % get the live values in mylist
%   mylist = pl_read(mylist);
% 
%   % extract those values out of the list
%   myRealVal = pl_get(mylist, 'Laser power');
%   myTestVal = pl_get(mylist, 'My test PV');
% 
%   % do something useful with them
%   myNewVal = myRealVal / 1000;
% 
%   % update the "test PV" in the list with some new data
%   mylist = pl_set(mylist, 'My test PV', myNewVal);
% 
%   % write the new list back out to the live PVs
%   mylist = pl_write(mylist);
%
%
% Compatibility: Version 7 and higher
% Called functions: none
%
% Author: Nate Lipkowitz, SLAC
%
% --------------------------------------------------------------------
if nargin < 3
    desc = '';
    egu  = 'egu';
    prec = 1;
end

pv = ['SIOC:SYS0:ML02:AO' sprintf('%03.0f', abs(pvnum))];
commentpv = ['SIOC:SYS0:ML02:SO0' sprintf('%03.0f', abs(pvnum))];

% check that it exists
try
    dummy = lcaGet(pv);
catch
    % bail out if not
    return
end

% set up the matlab PV

lcaPutSmart([pv, '.DESC'], desc);
lcaPutSmart([pv, '.EGU'], egu);
lcaPutSmart([pv, '.PREC'], prec);
lcaPutSmart(commentpv, list.name);

% add it to the list

list = pl_add(list, pv, desc);

return
