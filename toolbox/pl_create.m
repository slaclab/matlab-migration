function list = pl_create(name)
%PL_CREATE
%  LIST = PL_CREATE([NAME]) creates an empty structure to hold a
%  list of EPICS PVs for input and output.  This is like a constructor if
%  you are used to object-oriented programming.
%
%  See also pl_add, pl_read, pl_write, pl_get, pl_set
%
% Input arguments:
%    NAME:    (Optional) A name to be associated with the PV list.  If NAME
%    is not supplied, NAME will default to the name of the script calling
%    pl_create().
%
% Output arguments:
%    LIST:  An empty PV list of length zero, which can be passed to other pl_* functions.
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

if nargin < 1
    [st, i] = dbstack();
    name = st(length(st)).name;
end

list = struct;
list.length = 0;
list.name = name;

return