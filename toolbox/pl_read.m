function list = pl_read(list)
%PL_READ
%  LIST = PL_READ(LIST) reads the current values of the PVs stored in the
%  list and updates the internal value.  Use PL_GET after calling PL_READ
%  to access the updated values.
%
% Input arguments:
%    LIST:  The PV list to be updated via lcaGet.
%
% Output arguments:
%    LIST:  The modified PV list with the new, updated values.
%
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
% Compatibility: Version 7 and higher
% Called functions: none
%
% Author: Nate Lipkowitz, SLAC
%
% --------------------------------------------------------------------



[list.vals, list.ts, list.isPV] = lcaGetSmart(list.pvs);

% lca2matlabTime is not matlab-y :(
for index = 1:list.length
    list.ts(index) = lca2matlabTime(list.ts(index));
end

return