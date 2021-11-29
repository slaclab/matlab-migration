function list = pl_set(list, name, value)
%PL_SET
%  LIST = PL_SET(LIST, NAME, VALUE) sets the internal value of the PV
%  called NAME to VALUE.  NAME is the descriptive string provided when adding
%  PVs to the list with PL_ADD.  Use PL_SET before calling PL_WRITE.
%
% Input arguments:
%    LIST:  The PV list that contains a PV described with NAME.  If NAME is
%       not found, or multiple PVs match NAME, the unmodified list is
%       returned.
%    NAME:  The name of a PV that has been added with PL_ADD, e.g. 'L2 phase'.
%    VALUE: The new value of the PV that will be stored in the list.  Note:
%       use PL_WRITE after PL_SET to update the live PVs with the internal
%       values.
%
% Output arguments:
%    LIST:  The modified list, with NAME's value changed to VALUE.
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

index = strmatch(upper(name), upper(list.names));

if length(index) < 1;
    disp([name ' not found']);
elseif length(index) > 1
        disp([name 'found ' num2str(length(index)) 'times']);
else
    list.vals(index) = value;
end

return