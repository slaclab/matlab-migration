%
% fft_clear_data
%
% Clears the global data struct.
%
% Package: FFT GUI, Lars Froehlich
%
function fft_clear_data
    global data;
    
    data = [];
    if (~isfield(data, 'monitors'))
        data.monitors = [];
    end
    data.timestamps = [];
    data.signals = [];
    data.frequencies = [];
    data.intensities = [];
return
