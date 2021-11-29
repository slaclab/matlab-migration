function list = pl_add(list, pvname, desc)
%PL_ADD
%  LIST = PL_ADD(LIST, PVNAME, [DESC]) adds the PV specified in PVNAME to
%  the list of PVs specified by LIST.
%
%  See also pl_create, pl_add_ML0*, pl_read, pl_write, pl_get, pl_set
%
% Input arguments:
%    LIST:  The PV list that PVNAME will be added to.  Note the modified
%       list is returned by this function, so calls should be of the form
%       mylist = pl_add(mylist, name, description);
%    PVNAME:  The name of the PV to be added to the LIST, e.g. 'BEND:DMP1:400:BDES'.
%    DESC: (Optional) A unique descriptive string, e.g. 'BYD setpoint'
%
% Output arguments:
%    LIST:  The modified list, with PVNAME added to it.
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
    disp('using default name');
    desc = pvname;
end

% check that it exists
try
    dummy = lcaGet(pvname);
catch
    % bail out if not
    disp([pvname ' not found']);
    return
end

% add it to the list

if list.length < 1
    % if this is the first thing to be added to the list, set up some
    % default values
    list.pvs    = cell(1);
    list.names  = cell(1);
    list.vals   = 0;
    list.ts     = 0;
    list.isPV   = 1;
else
    % allocate some more space
    % up yours, m-lint
    list.pvs    = [list.pvs; cell(1)];
    list.names  = [list.names; cell(1)];
    list.vals   = [list.vals; 0];
    list.ts     = [list.ts;   0];
    list.isPV   = [list.isPV; 1];
end

list.length = list.length + 1;
list.pvs{list.length} = pvname;
list.names{list.length} = desc;

return