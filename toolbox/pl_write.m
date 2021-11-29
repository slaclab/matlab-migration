function list = pl_write(list)
%PL_WRITE
%  LIST = PL_WRITE(LIST) writes the internal values of the PVs stored in the
%  list out to the actual PVs.  Use PL_SET before calling PL_WRITE 
%  to access the updated values.
%
% Input arguments:
%    LIST:  The PV list to be written out via lcaPut.
%
% Output arguments:
%    LIST:  The PV list, which should be unchanged except for updated
%       "isPV" flags.
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
if iscell(list.vals)
    list.isPV = lcaPutSmart(list.pvs, cell2mat(list.vals));
else
    list.isPV = lcaPutSmart(list.pvs, list.vals);
end

return