%
% [frequency, intensity] = do_fft(timestamps, signals)
%
% Takes the given time domain data, removes points with duplicate
% time stamps, performs Blackmann-Harris apodization, zero filling
% and finally the FFT. Returns the frequency scale and the complex
% 'intensity' spectrum.
%
% Package: FFT GUI, Lars Froehlich
%
function [frequency, intensity] = do_fft(timestamps, signals)
    num_monitors = size(timestamps, 1);
    num_samples = size(timestamps, 2);
    
    if (num_monitors == 0 || num_samples == 0)
        frequency = [];
        intensity = [];
        return;
    end

    % Remove DC offsets
    ptimestamps = cell(num_monitors);
    psignals = cell(num_monitors);

    for i = 1:num_monitors
        ptimestamps{i} = timestamps(i,:) - timestamps(i,1);
        psignals{i}    = signals(i,:) - mean(signals(i,:));
    end

    % Remove duplicate timestamps
    for i = 1:num_monitors
        dt = diff(ptimestamps{i});
        bad_idx = find(dt == 0);
        ptimestamps{i}(bad_idx) = [];
        psignals{i}(bad_idx) = [];
    end

    % Zero filling
    ZFF = 4;
    for i = 1:num_monitors
        num_samples = length(psignals{i});
        duration = ptimestamps{i}(end) - ptimestamps{i}(1);
        time_scale = linspace(0, ZFF*duration, ZFF*num_samples);
        psignals{i} = [interp1(ptimestamps{i}, psignals{i}, time_scale(1:num_samples)) ...
                      .* blackmann_harris(num_samples), zeros(1, (ZFF-1)*num_samples)];
        ptimestamps{i} = time_scale;
    end

    % FFT
    frequency = cell(num_monitors);
    intensity = cell(num_monitors);

    for i = 1:num_monitors
        [frequency{i}, intensity{i}] = fourier_transform(ptimestamps{i}, psignals{i});

        good_idx = find(frequency{i} > 0);
        frequency{i} = frequency{i}(good_idx);
        intensity{i} = abs(intensity{i}(good_idx));
    end
return
