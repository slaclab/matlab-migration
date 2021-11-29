function [time, value, union_times, union_values] = history(pvName, timeRange, varargin)
%function [time, value, union_times, union_values] = history(pvName, timeRange)
% inputs:
% pvName - This can be a single PV name or a cell array of PV names.
%          If a cell array of PV names; we do a very basic interpolation using interp
% timeRange - cell array of start and end times OR matrix of matlab
%                    datenumbers for start and end times.
% options are parameter, value pairs:
% 'Operator':  {'firstSample', 'rms', 'mean', 'jitter', 'sigma',  'ignoreflyers'}
% 'Bin': string indicating bin length in seconds.
% 'Std': ignoreflyers takes a second argument, #of std away from mean. [3 stds default]
%         Default is firstSample_60 (Get 1st sample of each 60 second bin)
% 'endPointsMode': defaults to modify 1st and last point to align them with timeRange.
% 'verbose': 1 (default, all messages), 0 (only errors and warnings)
%
% Outputs:
%   time - A vertical array of record processing times suitable for handing off to datenum(time)
%   value - A vertical array of PV values or operator(PV)
%   union_times - If multiple PVs, this is the union of time stamps of all the PVs. If a single PV, this is the same as time
%   union_values - If multiple PVs, this is the numeric array of values at the union set of time stamps. If a single PV, this is the same as value
% See: http://epicsarchiverap.sourceforge.net/userguide.html#post_processing
%Example:
% timeRange = {'02/20/2014 08:00:00'; '02/21/2014 08:00:00'}; 
% [t,v] = history( 'VPIO:IN20:111:VRAW', timeRange);
%
% plot(datenum(t),v)
% datetick('x');
% xlabel(sprintf('%s to %s',datestr(t(1)),datestr(t(end))))
% ylabel([name])
%
% The archiver appliance can return lots of data; to sparsify data on the server use one of the sparsification operators
% See: http://epicsarchiverap.sourceforge.net/userguide.html#post_processing
% For example, to sparsify on the server using firstSample with a bin size of 3600 seconds,
% [t,v] = history('VPIO:IN20:111:VRAW', timeRange, 'Operator', 'firstSample', 'Bin', '3600');
%

% William Colocho and Henrik Loos.

  if nargin <1
      warndlg('Nothing Done')
      return
  end

optsdef=struct( ...
    'verbose',1 ...
);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

 if iscellstr(pvName)
      if length(pvName) > 1
          if opts.verbose, disp('Calling multiHistory');end
          [time, value, union_times, union_values] = multiHistory(pvName, timeRange, varargin{:});
      elseif length(pvName) == 1
          if opts.verbose, disp('Calling singleHistory');end
	  [time, value, union_times, union_values] = singleHistory(pvName, timeRange, varargin{:});
      else
          disp('Cannot determine if pvName is a cell array of strings or not');
          return
      end
  else
      if opts.verbose, disp('Calling singleHistory');end
      [time, value, union_times, union_values] = singleHistory(pvName, timeRange, varargin{:});
  end
  return
end

function [time, value, union_times, union_values] = singleHistory(pvName, timeRange, varargin)
% function [time, value, union_times, union_values] = singleHistory(pvName, timeRange, varargin)
% returns the history for a single PV.
% inputs:
% pvName - This is a single PV name
% timeRange - cell array of start and end times OR matrix of matlab
%                    datenumbers for start and end times.
% options are parameter, value pairs:
% 'Operator':  {'firstSample', 'rms', 'mean', 'jitter', 'sigma',  'ignoreflyers'}
% 'Bin': string indicating bin length in seconds.
% 'Std': ignoreflyers takes a second argument, #of std away from mean. [3 stds default]
%         Default is firstSample_60 (Get 1st sample of each 60 second bin)
% 'endPointsMode': defaults to modify 1st and last point to align them with timeRange.
%
% Outputs:
%   time - A vertical array of record processing times suitable for handing off to datenum(time)
%   value - A vertical array of PV values or operator(PV)
%   union_times - This is the same array as time
%   union_values - This is the same array as value

  [sys, accelerator] = getSystem;
  accelerator = lower(accelerator);
  pvMODE = lcaGetSmart(sprintf('SIOC:%s:AL00:MODE',sys));
  if strcmp(pvMODE, 'DEVELOPMENT')
      accelerator='dev';
  end
  % Set default options.
  optsdef=struct( ...
      'Operator','None', ...
      'Bin',[], ...
      'Std', 3, ...
      'endPointsMode', 0, ...
      'verbose',1 ...
      );

  % Use default options if OPTS undefined.
  opts=util_parseOptions(varargin{:},optsdef);

  %If timeRange is cell of strings.
  if iscell(timeRange)
      [token, remain] = strtok(timeRange);
      remain = datenum(remain) - fix(datenum(remain));
      timeRange = datenum(token) + remain;
  end

    

  if iscellstr(pvName), pvName = pvName{:}; end

  switch opts.Operator
      case 'None',  requestStr =  pvName;
      case 'rms', warndlg('RMS will be implemented soon...'), requestStr = 'rms'; time = 0; value = 0; return
      case { 'firstSample' 'firstFill' 'lastFill' 'median' 'mean' 'std'  'jitter'  'variance'  'popvariance' 'kurtosis' 'skewness' }
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

  %find out if timeRange was during daylight savings time
  
  %Change date to format yyyy-mm-ddThh:mm:ss.000Z
  [dateStart dateEnd] = local2utc(timeRange);


  if opts.verbose, disp(['Asking history for ' requestStr ' from ' dateStart ' to ' dateEnd]);end

  tempFileName = sprintf('/tmp/%s_%s_%.0f.mat',strrep(pvName,':','_'), datestr(now,30), 10000*rand);
  % fprintf('Temp file for PV: %s\n', tempFileName);

  % urlwrite to save the file
  % The ca_count is for ChannelArchiver integrations; this parameter is ignored by the appliance
  [f status] = urlwrite(['http://' accelerator '-archapp.slac.stanford.edu/retrieval/data/getData.mat'], tempFileName, 'get', ...
       {'pv', requestStr, 'from', dateStart, 'to', dateEnd, 'ca_count', '100000'});
 
  time = nan; value = nan;
  try
      dat = load(tempFileName);
      delete(tempFileName);
      if opts.verbose, disp(['mshankar Done getting history for ' requestStr ' from ' dateStart ' to ' dateEnd]);end
  catch
      fprintf('%s Could not get data from the server for PV: %s\n', datestr(now), requestStr);
  % Probably not necessary but still make an attempt to clean up
      if exist(tempFileName, 'file')
         delete(tempFileName);
      end
      return
  end


  try
      header = dat.header;
      data = dat.data;
  catch
      fprintf('%s Could not get data from the server for PV: %S\n', datestr(now), requestStr);
      return
  end
  pts = length(data.values); 
  if(pts==0)
    disp(['Number of points returned by archiver command for time range '...
            timeRange{1} ' to ' timeRange{2},' is zero']); 
  end
  isdst = double(data.isDST);
  time = double(data.epochSeconds) - (8-isdst)*60*60;
  value = data.values;

  % convert from UNIX to Matlab time
  unixT = datenum(datevec('1/1/1970 00:00:00')) * 24*60*60;
  time = (time + unixT)/24/60/60 ; 
  
  % Archive engine returs first point with time < dateStart and last point
  % with time < dateEnd.  Default is to move this points to dateStart and
  % dateEnd.
  if opts.endPointsMode
      time(1) = datenum(timeRange(1));
      time(end) = datenum(timeRange(end));
  end
  %Make vertical vectors for compatibility
  [a b] = size(time); if b ~=1, time = time'; end
  [a b] = size(value); if b ~=1, value = value'; end
  
  % For a single PV, the union is the same as the regular array
  union_times = time;
  union_values = value;
end

function [dateStart dateEnd] = local2utc(timeRange)
%Return timeStr in UTC taking into account local DST
tz_la = java.util.TimeZone.getTimeZone('America/Los_Angeles');
sd = java.text.SimpleDateFormat('yyyy/MM/dd HH:mm:ss');
tz_utc = java.util.TimeZone.getTimeZone('UTC');
sd_iso8601 = java.text.SimpleDateFormat('yyyy-MM-dd''T''HH:mm:ss.000''Z''');
sd_iso8601.setTimeZone(tz_utc);

dateStart = char(sd_iso8601.format(sd.parse(datestr(timeRange(1), 'yyyy/mm/dd HH:MM:SS'))));
dateEnd   = char(sd_iso8601.format(sd.parse(datestr(timeRange(2), 'yyyy/mm/dd HH:MM:SS'))));
% sysStr3 = sprintf('date --utc --date %s +%%Y-%%m-%%dT%%T.000Z ', datestr(timeRange(1),'yyyy-mm-ddTHH:MM:SS'));
% sysStr4 = sprintf('date --utc --date %s +%%Y-%%m-%%dT%%T.000Z', datestr(timeRange(2),'yyyy-mm-ddTHH:MM:SS'));
% 
% [~, dateStart] = (system(sysStr3)); dateStart = deblank(dateStart); 
% [~, dateEnd] = system(sysStr4);     dateEnd = deblank(dateEnd);

 

end


function [time, value, union_times, union_values] = multiHistory(pvNames, timeRange, varargin)
%function [time, value, union_times, union_values] = multiHistory(pvNames, timeRange)
% inputs:
% pvNames - This is a cell array of PV names.
% timeRange - cell array of start and end times OR matrix of matlab
%                    datenumbers for start and end times.
% Outputs:
%   time - A vertical array of record processing times 
%   value - A vertical array of PV values or operator(PV)
%   union_times - This is the union of time stamps of all the PVs.
%   union_values - This is the numeric array of values at the union set of time stamps.

optsdef=struct( ...
    'verbose',1 ...
);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

  time=deal(cell(numel(pvNames),1));
  value=deal(cell(numel(pvNames),1));
  for j=1:numel(pvNames)
      if opts.verbose, disp(['Reading ' pvNames{j}]);end
      try
	  pvName = char(pvNames{j});
          [time{j}, value{j}, tt, vv]=singleHistory(pvName,timeRange, varargin{:});
      catch exc
	  fprintf('%s\n', getReport(exc))
          disp(['Reading ' pvNames{j} ' failed']);
          continue
      end
      time{j}=datenum(time{j}); 
      time{j}([1 end+1],1)=datenum(timeRange);
      value{j}(end+1,1)=value{j}(end);
  end

  % Bin onto common time base.
  union_times=unique(vertcat(time{:}));
  union_values=zeros(numel(union_times),numel(pvNames));
  for j=1:numel(pvNames)
      [tj,id]=unique(time{j});
      tj=[tj [tj(2:end)-1/24/60/60/1000;now]]';
      vj=[value{j}(id) value{j}(id)]';
      if isempty(union_times) || isempty(vj), continue, end
      union_values(:,j)=interp1(tj(:),vj(:),union_times,'nearest');
  end
end
