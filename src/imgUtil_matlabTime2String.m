function tStr = imgUtil_matlabTime2String(mlTime, noMsecs)
if nargin < 2
    noMsecs = 0;
end
if noMsecs
    tStr = datestr(mlTime, 'mm-dd-yyyy HH:MM:SS');
else
    tStr = datestr(mlTime, 'mm-dd-yyyy HH:MM:SS.FFF');
end