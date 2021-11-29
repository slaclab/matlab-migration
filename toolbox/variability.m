filename = input('Enter the archive data filename... ', 's');
load(filename);
% Get user input
disp('The PV names of the data are . . . ')
disp(strcat('(1). . .', archive_000001_name))
try,
disp(strcat('(2). . .', archive_000002_name))
catch, no_data_streams = 1; end;
try,
disp(strcat('(3). . .', archive_000003_name))
catch, no_data_streams = 2; end;
try,
disp(strcat('(4). . .', archive_000004_name))
catch, no_data_streams = 3; end;
data2plot = input('Enter the number of the PV to plot ');
if (data2plot > no_data_streams), 
    disp(strcat('Data for number ', int2str(data2plot), ' does not exist'))
    disp(strcat('Using--', archive_000001_name, '--instead'))
    data2plot = 1;
end;
switch data2plot
    case 1
        value=archive_000001_value;
        time=archive_000001_time;
        start_time = archive_000001_starttime;
        pv_name = archive_000001_name;
    case 2
        value=archive_000002_value;
        time=archive_000002_time;
         start_time = archive_000002_starttime;
        pv_name = archive_000002_name;
    case 3
        value=archive_000003_value;
        time=archive_000003_time;
         start_time = archive_000003_starttime;
        pv_name = archive_000003_name;
    case 4
        value=archive_000004_value;
        time=archive_000004_time;
         start_time = archive_000004_starttime;
        pv_name = archive_000004_name;
end


window_size = input('Enter number of seconds to average over (integer)  ');

%value=archive_000001_value;
%time=archive_000001_time;
%for i=1:(length(value)-tau)
%    ave_val(i) = mean(value(i:i+tau-1));
%    ave_time(i) = mean(time(i:i+tau-1));
%    ave_std(i) = std(value(i:i+tau-1));
%end

%chop data into windows, min window=10 for efficiency
window_size = round(window_size); %for wise guys with floating pts
if (window_size < 10), window_size = 10, end; 
no_of_windows = floor(length(value)/window_size);
%get window averages
ave_val=zeros(no_of_windows,1);
ave_std=zeros(no_of_windows,1);
ave_time=zeros(no_of_windows,1);
j=1;
for i=1:no_of_windows
    ave_val(i) = mean(value(j:j + window_size -1 ));
    ave_std(i) = std(value(j:j + window_size -1 ));
    ave_time(i) = mean(time(j:j + window_size -1 ));
    j=j+window_size;
end

%plot the results
subplot(2,1,1)
plot(ave_time, ave_val)
ws_str = int2str(window_size);
title(pv_name);
ylabel('Running average value');
subplot(2,1,2)
newplot;
plot(ave_time, ave_std)
ylabel('Std deviation, running average');
xlabel( {strcat('Time elapsed [s] since', datestr(start_time,6),'.at.', datestr(start_time,15) );   strcat('Averaging window [s]... ', ws_str)} );
