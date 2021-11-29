%
% [timestamps, signals] = fft_do_measurement(handles, monitors,
%                                            max_samples, reprate)
%
% Takes data from the PVs specified in the 'monitors' struct with
% the sampling rate 'reprate'. Stops after 'max_samples' have
% been taken, or on user interaction.
% Returns the measured timestamps (in Matlab format, i.e. days) and
% raw time domain signals.
%
% package: FFT GUI, Lars Froehlich
%
function [timestamps, signals] = fft_do_measurement(handles, monitors, max_samples, reprate)

    global settings;

    
    set_status(handles, 'Measurement started, waiting for valid data...');
    
    old_button_enable_status = get(handles.buttonStartMeasurement, 'Enable');
    set(handles.buttonStartMeasurement, 'String', 'Stop Measurement', ...
        'BackgroundColor', [0.8 0.4 0.4], 'Enable', 'on');
    set(handles.radioTimeDomain, 'Value', 1);
    set(handles.togglePauseMeasurement, 'Value', 0, 'Enable', 'on');

    num_monitors = length(monitors);

    pv_list = cell(2*num_monitors,1);
    for i = 1:num_monitors
        pv_list{i} = monitors(i).pv;
        pv_list{num_monitors+i} = [monitors(i).pv '.SEVR'];
    end


    signals    = zeros(num_monitors, max_samples);
    timestamps = zeros(num_monitors, max_samples);

    plot(handles.axesMain, [0,1], [0,1]); set(handles.axesMain, 'FontSize', 12);

    
    start_time = now;
    num_samples = 0;


    % Main loop: cycle until 'stop measurement' has been pressed
    while (~settings.start_measurement)

       tic;

       % Cycle until we have valid data for all channels or
       % one of the measurement control buttons has been pressed.
       while (~settings.pause_measurement && ~settings.start_measurement)

           [val, ts] = lcaGet(pv_list, 1, 'double');
           err(1:num_monitors) = val(num_monitors+1:2*num_monitors);

           if (any(err ~= 0))
               disp('Read error.');
               pause(0.5);
           else
               % Insert the data point into our arrays
               num_samples = num_samples + 1;
               signals(1:num_monitors,num_samples)    = val(1:num_monitors);
               timestamps(1:num_monitors,num_samples) = ...
                   (lca2matlabTime(ts(1:num_monitors))-start_time) * 24 * 3600;
               break;
           end

       end

       if (mod(num_samples,3*ceil(reprate))==2 || num_samples==max_samples)
           fft_plot_data(handles, monitors, timestamps(:,1:num_samples), signals(:,1:num_samples));
           set_status(handles, sprintf('%d/%d shots', num_samples, max_samples), ...
                      (num_samples-1)/(max_samples-1));
       end

       pause(max(0.001, 0.98/reprate-toc));
    end
    
    signals = signals(1:num_monitors, 1:num_samples);
    timestamps = timestamps(1:num_monitors, 1:num_samples);
    
    settings.start_measurement = false;
    settings.pause_measurement = false;

    enable_gui(handles.figureMain);
    set(handles.buttonStartMeasurement, 'String', 'Start Measurement', ...
        'BackgroundColor', get(0, 'DefaultUIControlBackgroundColor'), ...
        'Enable', old_button_enable_status);
    set(handles.togglePauseMeasurement, 'Value', 0, ...
        'String', 'Pause Measurement', ...
        'BackgroundColor', get(0, 'DefaultUIControlBackgroundColor'), ...
        'Enable', 'on');

return
