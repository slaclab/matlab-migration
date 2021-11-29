%
% data_path = fft_get_data_path
%
% Gets the MATLAB data path from the environment variable
% 'MATLABDATAFILES', tries to create a subdirectory 'fft_gui'
% there, and returns the absolute path to that directory.
%
% Package: FFT GUI, Lars Froehlich
%
function data_path = fft_get_data_path
    data_path = getenv('MATLABDATAFILES');
    data_path = fullfile(data_path, 'fft_gui');
    if exist(data_path)
    else
        mkdir(data_path);
    end
return
