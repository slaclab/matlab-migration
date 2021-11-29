%
% monitors = fft_parse_monitor_desc(str)
%
% Parses the raw input from an edit field into a 'monitors'
% struct, neatly packed in fields .pv and .desc .
%
% Package: FFT GUI, Lars Froehlich
%
function monitors = fft_parse_monitor_desc(str)
    num_monitors = 0;
    monitors = [];

    for i = 1:length(str)
        line = strtrim(str{i});
        if (~isempty(line))
            num_monitors = num_monitors + 1;
            [pv desc] = strtok(line);
            monitors(num_monitors).pv = pv;
            monitors(num_monitors).desc = strtrim(desc);
        end
    end
return
