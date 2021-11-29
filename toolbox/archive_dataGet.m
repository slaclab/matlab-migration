function [v, t, vv, tt] = archive_dataGet(name, st, et, varargin)
%ARCHIVE_DATAGET
%  ARCHIVE_DATAGET(NAME, ST, ET, OPTIONS) get archive data for multiple
%  signals.  If 4th argument set, the data is also plotted.

% Features:

% Input arguments:
%    NAME: Name(s) of PV.

% Output arguments:
%    V: Cell array of values
%    T: Cell array of time stamps
%    VV: Numeric array of values at union set of time stamps
%    TT: Union set of time stamps

% Compatibility: Version 7 and higher
% Called functions: get_archive

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------


if nargin < 3, et=[];end
if nargin < 2, st=[];end
if isempty(et), et=now;end
if isempty(st), st=et-1/24;end
name=cellstr(name);

st=datestr(st,'mm/dd/yyyy HH:MM:SS');
et=datestr(et,'mm/dd/yyyy HH:MM:SS');

% Read values from archive.
[v,t]=deal(cell(numel(name),1));
for j=1:numel(name)
    disp(['Reading ' name{j}]);
    try
        [v{j},t{j}]=get_archive(name{j},st,et,0,[],1);
    catch
        disp(['Reading ' name{j} ' failed']);
        continue
    end
    t{j}=datenum(t{j},'dd-mmm-yyyy HH:MM:SS'); % Provide format to speed things up
    t{j}([1 end+1],1)=datenum({st et});
    v{j}(end+1,1)=v{j}(end);
end

if nargin > 3, archive_plot(name,v,t,st,et);end

if nargout < 3, return, end

% Bin onto common time base.
tt=unique(vertcat(t{:}));
vv=zeros(numel(tt),numel(name));
for j=1:numel(name)
    [tj,id]=unique(t{j});
    tj=[tj [tj(2:end)-1/24/60/60/1000;Inf]]';
    vj=[v{j}(id) v{j}(id)]';
    if isempty(tt) || isempty(vj), continue, end
    vv(:,j)=interp1(tj(:),vj(:),tt,'nearest');
end


function archive_plot(name, v, t, st, et)

% Plot data.
col=get(gca,'ColorOrder');%col=col([1 1 3 3],:);
use=1:numel(name);
for j=use
    if j > 1 && j <5
        stairs(t{j},v{j},'-','Color',col(mod(j-1,7)+1,:));
    else
        stairs(t{j},v{j},'Color',col(mod(j-1,7)+1,:));
    end
    hold on
end
hold off
legend(name(use));legend boxoff
xlim(datenum({st et}));
datetick('keeplimits');
