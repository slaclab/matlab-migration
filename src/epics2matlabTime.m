function matlabTS = epics2matlabTime(epicsTS, timeDiffToUTCInHours)
% The real part of EPICS TS is the number of seconds since 01/01/1990 00:00:00 UTC.
% The imaginary part of EPICS TS is the number of nanoseconds.
% DO NOT USE for time stamps returned from lcaGet - use lca2matlabTime instead.

epicsTSSecs = real(epicsTS);
epicsTSNSecs = imag(epicsTS);

if nargin == 1
    if usejava('jvm')
        tz = java.util.TimeZone.getDefault();
	% See http://java.sun.com/j2se/1.5.0/docs/api/java/util/TimeZone.html#getOffset(long)
        timeDiffToUTCInHours = tz.getOffset(epicsTSSecs*1000)/(60*60*1000);
    else
        timeDiffToUTCInHours = 0;
    end
end

% Seconds between January 1st, 0000, which is when MATLAB time starts, and January 1st 1990, 
% which is when EPICS  time starts
dOffsetInDays = datenum(1990, 01, 01, 0, 0, 0);
dOffsetInSecs = dOffsetInDays * 24 * 60 * 60;

epicsTSSecs = real(epicsTS);
epicsTSNSecs = imag(epicsTS);

matlabTSInSecs = dOffsetInSecs + epicsTSSecs + epicsTSNSecs / 10 ^ 9 + timeDiffToUTCInHours * 60 * 60;
%in days
matlabTS = matlabTSInSecs/(24 * 60 * 60);
