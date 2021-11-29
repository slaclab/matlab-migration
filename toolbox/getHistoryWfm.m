function [time, value, requestStr] = getHistoryWfm(pvName, timeRange, varargin)
%function [time, value, requestStr] = getHistory(pvName, timeRange, varargin)
% inputs:
%  pvName
% timeRange - cell array of start and end times OR matrix of matlab
%                    datenumbers for start and end times.
% options are parameter, value pairs:
% 'Operator':  {'firstSample', 'rms', 'mean', 'jitter', 'sigma',  'ignoreflyers'}
% 'Bin': string indicating bin length in seconds.
% 'Std': ignoreflyers takes a second argument, #of std away from mean. [3 stds default]
% Default is firstSample_60 (Get 1st sample of each 60 second bin)
%
% Outputs:
%   time - Archive time
%   value - PV value TODO: operator(PV)
%   requestStr - string with post_processing information
% See: http://epicsarchiverap.sourceforge.net/userguide.html#post_processing
%Example:
% timeRange = {'07/14/2013 08:00:00'; '08/07/2013 14:00:00'}; 
%
% [t,v] = getHistoryWfm( 'CUDKLYS:MCC0:ONBC1SUMY', timeRange);
%

% William Colocho.

%TODO nargin <1 prompt for info.
%TODO add pv to file if channel data is not archived.
if nargin <1
    warndlg('Nothing Done')
    return
end
[sys, accelerator] = getSystem;
accelerator = lower(accelerator);

% Set default options.
optsdef=struct( ...
    'Operator','None', ...
    'Bin',[], ...
    'Std', 3, ...
    'waitTime', 5 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);



if isnumeric(timeRange), timeRange = num2cell(timeRange); end
timeRange = datenum(timeRange);
if iscellstr(pvName), pvName = pvName{:}; end



switch opts.Operator
    case 'None',  requestStr =  pvName;
    case 'rms', warndlg('RMS will be implemented soon...'), requestStr = 'rms'; time = 0; value = 0; return
    case { 'firstSample'  'median' 'mean' 'std'  'jitter'  'variance'  'popvariance' 'kurtosis' 'skewness'  }
        if any(opts.Bin)
            requestStr = sprintf('%s_%s(%s)',opts.Operator, opts.Bin, pvName);
        else
            requestStr = sprintf('%s(%s)',opts.Operator, pvName);
        end
    case  'ignoreflyers'
        if any(opts.Bin)
            requestStr = sprintf('%s_%s_%s(%s)',opts.Operator, opts.Bin, opts.Std, pvName);
        else
            requestStr = sprintf('%s(%s)',opts.Operator, pvName);
        end

    otherwise
        requestStr =  pvName; %pvName can also be a well formatted request like mean_60(PV)
end

%Change date to format yyyy-mm-ddThh:mm:ss.000Z
[stat nowUTC] = system('date -u +%D%t%X ');
localTnum = now;
utcTnum = datenum(nowUTC) ;
deltaT = round(24*(localTnum - utcTnum )) / 24; % UTC to local time in units of Days

 dateStart = datestr(timeRange(1)-deltaT,'yyyy-mm-ddTHH:MM:SS.000Z');
 dateEnd =  datestr(timeRange(2)-deltaT,'yyyy-mm-ddTHH:MM:SS.000Z');
 tempFileName = sprintf('/tmp/%s_%s_%.0f.mat',strrep(pvName,':','_'), datestr(now,30), 10000*rand);
% urlwrite to save the file
urlToSend = ['http://' accelerator '-archapp.slac.stanford.edu/retrieval/data/getData.mat' '?pv=' requestStr '&from=' dateStart '&to=' dateEnd];
[f status] = urlwrite(['http://' accelerator '-archapp.slac.stanford.edu/retrieval/data/getData.mat'], tempFileName, 'get', ...
     {'pv', requestStr, 'from', dateStart, 'to', dateEnd});
try
    dat = load(tempFileName);
catch
    disp(['Failed to get .mat file from Archiver Appliace for URL: ' urlToSend])
    warndlg('Failed to get .mat file from Archiver Appliance.  See terminal output for details.');
    time = NaN;
    value = NaN;
    requestStr = urlToSend;
    return;
end
delete(tempFileName);
try
    header = dat.header;
    data = dat.data;
catch
    fprintf('Could not get data from file for PV: %S\n', pvName);
    time = NaN;
    value = NaN;
    requestStr = urlToSend;
    return
end

pts = length(data.values); 
if(pts==0)
  disp('Number of points returned by archiver command for time range is zero ')
  disp(datestr(timeRange))
end
isdst = double(data.isDST);
time = double(data.epochSeconds) + (isdst-8)*60*60;
value = data.values;

% convert from UNIX to Matlab time
unixT = datenum(datevec('1/1/1970 00:00:00')) * 24*60*60;
time = (time + unixT)/24/60/60 ; 
%fprintf('PV: %s, last time: %s\n', pvName, datestr(time(end)))
end
