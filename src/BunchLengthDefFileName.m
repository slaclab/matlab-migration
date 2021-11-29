% Bunch Length default save file name
% Mike Zelazny - zelazny@stanford.edu

function defaultFileName = BunchLengthDefFileName ()

% Get current date and time for use as default file name
[nowDate,nowTime] = strtok(datestr(now,31));
defaultFileName = strrep(strrep(sprintf('%s-%s',nowDate,nowTime),' ',''),':','');
