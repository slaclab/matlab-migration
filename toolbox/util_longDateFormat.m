function s = util_longDateFormat ( v )
% UTIL_LONGDATEFORMAT converts a MATLAB date/time vector
%      (as for instance returned by the clock function)
%      into a formatted string.
%
%           S = UTIL_LONGDATEFORMAT ( CLOCK )
%      will return a sctring like
%           'Monday, January 29, 2007 13:37'
%
% Last Modified by HDN on 02-Feb-2008
%

weekdays = { 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' };
months   = { 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' };

JD = 2440000 - datenum ( 1968, 5, 23 ) + datenum ( v ( 1 ), v ( 2 ), v ( 3 ) );

s = sprintf ( '%s, %s %d, %d %2.2d:%2.2d:%2.2d', weekdays { mod ( JD, 7 ) + 1 }, months { v ( 2 ) }, v ( 3 ), v ( 1 ), v ( 4 ), v ( 5 ), floor ( v ( 6 ) ) );
end

