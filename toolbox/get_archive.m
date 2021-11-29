function [values,times] = get_archive(name,starttime,endtime,show_plot,mrk,density)

% [values,times] = get_archive(name,starttime,endtime[,show_plot,mrk]);
%
% Acquires and plots history of named device from a start time and end time.
%
%   INPUTS:
%       name:       The name of a history variable (e.g.,
%                   'QUAD:IN20:121:BACT')
%       starttime:  Beginning time in format 'mm/dd/yyyy hh:mm:ss', or std
%                   matlab date formats
%       endtime:    Ending time in format as "starttime" above
%       show_plot:  (Optional,DEF=1) If "show_plot"=1, also draws plot,
%                   Any other value inhibits plot.
%       mrk:        (Optional, DEF='.r-') Plot marker (e.g., 'bo').
%       density:    (Optional, DEF=0) Data sparsity, 0 sparse, 1 normal
%
%   OUTPUTS:
%       values:     The values of the device (row vector).
%       times:      The time stamps of the values ('mm/dd/yyyy hh:mm:ss').
%
% Example:
%
%>>[values,times] = get_archive('QUAD:IN20:121:BACT',...
%                               '07/01/2007 00:00:00','07/10/2007 00:00:00');

%=====================================================================

%{
persistent da;

tn = get_time;
if ~exist('starttime','var')    % if start date/time not input
    starttime = [datestr(datenum(tn)-1,23) ' ' datestr(datenum(tn)-1,13)];
end
if ~exist('endtime','var')
    endtime = [datestr(tn,23) ' ' datestr(tn,13)];
end

try % try to convert from matlab to aida date format
    if length(starttime)~=19
        starttime = [datestr(starttime,23) ' ' datestr(datenum(starttime),13)];
        endtime = [datestr(endtime,23) ' ' datestr(datenum(endtime),13)];
    end
catch % if NG use default range
    starttime = [datestr(datenum(tn)-1,23) ' ' datestr(datenum(tn)-1,13)];
    endtime = [datestr(tn,23) ' ' datestr(tn,13)];
end
%}

if ~exist('starttime','var')    % if start date/time not input
    starttime = now-1;
end
if ~exist('endtime','var')
    endtime = now;
end

if ~exist('mrk','var')
  mrk = '.r-';
end

if ~exist('density','var')
  density = 0;
end

if ~exist('show_plot','var')
  show_plot = 1;
end

%{
namel = [name '//HIST.lcls'];

aidainit;

if(isempty(da))
    import edu.stanford.slac.aida.lib.da.DaObject;
    da = DaObject();  
else
    da.reset;
end
disp 'Acquisition begins ...'
da.setParam('STARTTIME',starttime);  
da.setParam('ENDTIME',endtime);   
if density, da.setParam('DENSITY','NORMAL');end
hist = da.getDaValue(namel);                          
disp 'Acquisition ends successfully'

pts = hist.get(0).size();                        
dblArray = javaArray('java.lang.Double',pts);   
values1 = double(hist.get(0).toArray(dblArray));                      
StringArray = javaArray('java.lang.String',pts);
times1 = char(hist.get(1).toArray(StringArray));                      
%}

opts={};if ~density, opts={'Operator','firstSample'};end
[times1,values1] = history(name,[datenum(starttime) datenum(endtime)],opts{:});
times1=datestr(times1);

if show_plot==1
  egu = lcaGet([name '.EGU']);
  disp 'Plotting...'
  plot(datenum(times1),values1,mrk);
  datetick('x');
  xlabel(sprintf('%s to %s',times1(1,:),times1(end,:)))
  ylabel([name ' (' cell2mat(egu) ')'])
  title(name);
end

if nargout>0
  values = values1;
end
if nargout>1
  times = times1;
end
