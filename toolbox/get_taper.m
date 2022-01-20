function [myval,mytime] = get_taper(start_time)

%================================================================
% Enter time in format 'mm/dd/yyyy HH:MM:SS.'
% For example: '07/01/2009 00:00:00'.  Returns undulator K values
% between that time and one second later.
% Author D. Ratner
%================================================================
und_num = 33;


end_num = datenum(start_time);

onesec = 1.1574e-05;
end_time = datestr(end_num+onesec,'mm/dd/yyyy HH:MM:SS');

%und_names = {};
% for j=1:und_num
%   und_names{j} = ['USEG:UND1:' num2str(j) '50:KACT//HIST.lcls'];
% end

% for j=1:und_num
%     pv = ['USEG:UND1:' num2str(j) '50:KACT//HIST.lcls'];
%     n = length(pv);
%     pvs(j,1:n) = pv;
% end
%
% und_names = mat2str(pvs);
%
% [values,times] = get_archive_multiple(und_names,start_time,end_time);


%und_names = {};
for j=1:und_num
  und_name = ['USEG:UND1:' num2str(j) '50:KACT'];
  try
    %[values,times] = get_archive(und_name,start_time,end_time,0);  % doesn't work after '03/12/2014 06:29:57'
    time_range={start_time;end_time};
    [times,values] =history(und_name,time_range);

    myval(j) = values(1);
    first_time{j} = times(1,:);
  catch ME
    myval(j)=0; % get_archive fails for SXRSS chicane now
    first_time{j}=0;
    disp(['history failed on und' num2str(j)])
  end

end


for j=1:und_num
    t = first_time{j};
    n = length(t);
    mytime(j,1:n) = t;
end
myval = myval.';
mytime;





function [values,times] = get_archive_multiple(pvs,start_time,end_time)

% AIDA-PVA imports
aidapva;

requestBuilder = pvaRequest(pvs);
requestBuilder.with('STARTTIME', start_time);
requestBuilder.with('ENDTIME', end_time);
hist = ML(requestBuilder.get());

%You can extract the data like this:

pts = hist.size;
values = hist.values.values;
times = hist.values.times;
