function [time, value, timeRange, timeString] = getWaveformHist(waveformPV,timeRange)
%  function [time, value, timeRange] = getWaveformHist(waveformPV,timeRange)
%  Get waveform history from channel archiver using AIDA.
%
%  Inputs:
%  waveformPV - Channel Archiver wavefrom PV.
%  timeRange - (Optional - prompt if not given)
%    cell array containing {startTime; endTime}
%    startTime - Beginning time in format 'mm/dd/yyyy hh:mm:ss'
%    endTime - Ending time in format as startTime above.
%
%  Outputs:
%  value - wavefrom matrix
%  timeVals - time stamp of waveform.
%  timeRange - As passed to the function or input by user.
%
%  Example:
% [time, value, timeRange] = getWaveformHist('WF41:HER:SPEC');
%

% William Colocho, October 2007

%Get time span
if(~exist('timeRange'))
   theEnd = now - 30 * 60/(24*60*60); %now - n * 60 seconds
   theStart = theEnd - 2/(24);
   defaultTime = {[datestr(theStart,23),' ',datestr(theStart,13)], ...
                  [datestr(theEnd,23), ' ',datestr(theEnd,13)]};
   [timeRange] = inputdlg({'Start Time','End Time'},'Enter Time Range', ...
                1, defaultTime);
   if(isempty(timeRange)), return, end
end

startTime = timeRange{1};
endTime = timeRange{2};
timeString = '';

requestBuilder = pvaRequest([ waveformPV ':HIST.lcls']);
requestBuilder.with('STARTTIME', startTime);
requestBuilder.with('ENDTIME',  endTime);
requestBuilder.with('DATEFORMAT', 'MMDDYYYY_FRAC');

%Get the value
valueHist = ML(requestBuilder.get());

pts = valueHist.size;
if(pts==0),
  error(['Number of points returned by get command for time range '...
          timeRange{1} ' to ' timeRange{2},' is zero']);
  return
end

% Make it usable

value = valueHist.value.values;

% Get wavefrom info

waveformCount = valueHist.value.waveformCount;
nWaveforms = waveformCount.length;
nWavePts = waveformCount(1);
value = reshape(value, nWavePts, nWaveforms);

% Process time
time = valueHist.value.times;
%Account for Daylight savigns times
try
    isdst = valueHist.value.isdst;
catch
    fprintf('Warning: no DST/PST flag from Archiver data time may be off by 1 hour\n');
    isdst = ones(size(time));
end

%Add tenth of seconds value from timeString.
timeString = valueHist.value.timeString;
tenthSec = str2num(timeString(:,end-1:end)) / 100/24/60/60; %#ok<ST2NM>
time = time + tenthSec;

unixT = datenum(datevec('1/1/1970 00:00:00')) * 24*60*60;
%time = (time + unixT)/24/60/60 - 7/24; %7 hours since GMT
time = (time + unixT)/24/60/60 - (8-isdst)/24; %8 hours since GMT and isdst account for PST/PDT
%char(valueHist.get(1).toArray(StringArray));
