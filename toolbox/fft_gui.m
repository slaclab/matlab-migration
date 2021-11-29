%
% Fast Fourier Transform GUI
%
% Lars Froehlich, 06/2007
%


clc;
delete(get(0, 'Children'));

[sys,accelerator]=getSystem();
REPRATE_PV = ['EVNT:' sys ':1:' accelerator 'BEAMRATE'];


global settings data;
settings = [];
settings.close_requested = false;
settings.start_measurement = false;
settings.pause_measurement = false;
settings.data_path = fft_get_data_path;
settings.settings_filename = fullfile(settings.data_path, '.fourier_analysis-settings.mat');
fft_clear_data;


% Open and prepare GUI
fig = gui_fourier;
handles = guidata(fig);
hide_axis(handles.axesStatus);
set_status(handles, 'Ready.');



try
    tmp = load(settings.settings_filename);
    if (isfield(tmp, 'monitor_str'))
        tmp.monitor_str{end+1} = '';
        set(handles.editPVs, 'String', tmp.monitor_str);
    end
end



lcaSetMonitor(REPRATE_PV);
while (~settings.close_requested)
    if (lcaNewMonitorValue(REPRATE_PV) > 0)
        reprate = lcaGet(REPRATE_PV);
        set(handles.editSamplingRate, 'String', sprintf('%d', reprate));
    end
    
    % Start measurement if requested
    if (settings.start_measurement)
        settings.start_measurement = false;
        fft_clear_data;
        max_samples = str2double(get(handles.editMaxNumSamples, 'String'));
        reprate = str2double(get(handles.editSamplingRate, 'String'));
        data.monitors = fft_parse_monitor_desc(get(handles.editPVs, 'String'));
        if (length(data.monitors) > 11)
            disable_gui(fig);
            uiwait(msgbox(['This GUI only supports up to 11 monitors.' 10 ...
                           'Please remove some from the edit field.'], ...
                           'Too many PVs', ...
                           'warn', 'modal'));
            enable_gui(fig);
        elseif (isnan(max_samples) || isnan(reprate) || reprate <= 0)
            disable_gui(fig);
            uiwait(msgbox(['Please enter valid numbers in the ''number of samples''' 10 ...
                           'and ''repetition rate'' fields.'], 'Wrong number format', ...
                           'warn', 'modal'));
            enable_gui(fig);
        elseif (isempty(data.monitors))
            disable_gui(fig);
            uiwait(msgbox('Please enter at least one valid PV in the ''monitors'' field.', ...
                          'No monitor specified', 'warn', 'modal'));
            enable_gui(fig);
        else

            settings.data_filename = fullfile(settings.data_path, date_filename('.mat'));

            % Switch to time domain
            gui_fourier('radioTimeDomain_Callback',handles.radioTimeDomain,[],handles)

            fft_enable_monitor_checkboxes(handles);
            disable_gui(fig);
            
            % Do the measurement
            [data.timestamps, data.signals] = fft_do_measurement(handles, ...
                data.monitors, max_samples, reprate);
            
            % Save data
            set_status(handles, ...
                       sprintf('Measurement complete. Saving data to %s ...', ...
                               settings.data_filename), ...
                       0.25);
            save(settings.data_filename, 'data');

            % Do the FFT with all surrounding stuff
            set_status(handles, 'Doing the FFT ...', 0.5);
            [data.frequencies, data.intensities] = do_fft(data.timestamps, data.signals);
            set_status(handles, 'Done.', 1);

            % Switch to frequency domain
            gui_fourier('radioFrequencyDomain_Callback',handles.radioFrequencyDomain,[],handles)

            fft_plot_data(handles, data.monitors, ...
                      data.timestamps, data.signals, ...
                      data.frequencies, data.intensities);

            set_status(handles, sprintf('Data saved to %s .', settings.data_filename));

            enable_gui(fig);
            
        end
    end
    
    pause(0.05);
end


% If there is any text in the 'monitors' edit field,
% save it to the settings file.
empty_idx = [];
monitor_str = strtrim(get(handles.editPVs, 'String'));
for i = 1:length(monitor_str)
    if (isempty(monitor_str{i}))
        empty_idx = [empty_idx i];
    end
end
monitor_str(empty_idx) = [];

if (~isempty(monitor_str))
    save(settings.settings_filename, 'monitor_str');
end


lcaClear(REPRATE_PV);
delete(fig);
disp('Finished.');

if strcmp('/usr/local/lcls/tools/matlab/toolbox/fft_gui.m', which('fft_gui'))
    lcaClear(); % Disconnect from Channel Access
    exit
else
    % don't exit from matlab
end
