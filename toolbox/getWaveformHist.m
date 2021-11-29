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

aidainit;
persistent da;
if(isempty(da)),  
   import edu.stanford.slac.aida.lib.da.DaObject;
   da = DaObject(),  
end

r = DaReference([ waveformPV '//HIST.lcls'],da);
r.setParam('STARTTIME',startTime);
r.setParam('ENDTIME', endTime);
r.setParam('DATEFORMAT','MMDDYYYY_FRAC');
%Get the value

valueHist = r.getDaValue();
pts = valueHist.get(0).size();
if(pts==0),
  error(['Number of points returned by get command for time range '...
          timeRange{1} ' to ' timeRange{2},' is zero']);
  return
end

% Make it usable

dblArray = javaArray('java.lang.Double',pts);
value = double(valueHist.get(0).toArray(dblArray));


% Get wavefrom info

waveformCount = valueHist.get(5);
nWaveforms = waveformCount.size();
nWavePts = waveformCount.get(0);
value = reshape(value, nWavePts, nWaveforms);

% Process time
time = cell2mat(cell(valueHist.get(3).toArray()));
%Account for Daylight savigns times
try
    isdst = [cell2mat(cell(valueHist.get(6).toArray()))];  %#ok<AGROW>    
catch
    fprintf('Warning: no DST/PST flag from Archiver data time may be off by 1 hour\n');  
    isdst = ones(size(time));    
end

StringArray = javaArray('java.lang.String',nWaveforms);

%Add tenth of seconds value from timeString.
timeString = [timeString; char(valueHist.get(1).toArray(StringArray))];  %#ok<AGROW>
tenthSec = str2num(timeString(:,end-1:end)) / 100/24/60/60; %#ok<ST2NM>
time = time + tenthSec;

unixT = datenum(datevec('1/1/1970 00:00:00')) * 24*60*60;
%time = (time + unixT)/24/60/60 - 7/24; %7 hours since GMT
time = (time + unixT)/24/60/60 - (8-isdst)/24; %8 hours since GMT and isdst account for PST/PDT
%char(valueHist.get(1).toArray(StringArray));
