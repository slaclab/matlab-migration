function [HXRSS] = HXRSSrecall(time)
%
% Example:  [hxrsss] = HXRSSrecall(now -1) will return
% the various HXRSS parameters offsets one day previous to the present time.
%

% convert all formats to serial date number
time = datenum(datestr(time));

% set up time interval for archive recall
starttime = time;
stoptime = starttime + 	1/(24*3600);% long period because history bombs if no data is availble
stoptime =datestr(stoptime);
starttime = datestr(starttime);

HXRSSdata = {...
'angle',    'XTAL:UND1:1653:ACT';...
'yaw', 'XTAL:UND1:1652:ACT';...
'vertical',  'XTAL:UND1:1650:ACT';...
'delay', 'SIOC:SYS0:ML01:AO901'};

HXRSSpv = HXRSSdata(:,2);
[~, v] = history(HXRSSpv, {starttime; stoptime},'verbose',0);

for q=1:length(HXRSSdata)
    fn = HXRSSdata{q,1};
    value = mean(v{q});
    HXRSS.(fn) = value ;
end
HXRSS.time = datestr(time);
