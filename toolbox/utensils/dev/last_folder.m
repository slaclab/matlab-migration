function out = last_folder
    % Returns the used folder
    %
    % By marcg@slac.stanford.edu
    
    root = fullfile(getenv('MATLABDATAFILES'),'data');
    [year, month, day] = date_today;
    
    while true
        out = sprintf('%s/%i/%i-%02i/%i-%02i-%02i/', root, year, year, month, ...
                                           year, month, day);
        if exist(out, 'file')
            return
        end
        
        % go back in time...
        day = day - 1;
        if day == 0
            day = 31;
            month = month - 1;
        end
        
        if month == 0
            month = 12;
            year = year - 1;
        end
    end
    
function [year, month, day] = date_today
    cl = clock;
    
    year = cl(1);
    month = cl(2);
    day = cl(3);