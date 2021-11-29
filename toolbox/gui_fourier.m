function varargout = gui_fourier(varargin)
% GUI_FOURIER M-file for gui_fourier.fig
%      GUI_FOURIER, by itself, creates a new GUI_FOURIER or raises the existing
%      singleton*.
%
%      H = GUI_FOURIER returns the handle to a new GUI_FOURIER or the handle to
%      the existing singleton*.
%
%      GUI_FOURIER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FOURIER.M with the given input arguments.
%
%      GUI_FOURIER('Property','Value',...) creates a new GUI_FOURIER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_fourier_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_fourier_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_fourier

% Last Modified by GUIDE v2.5 15-Jun-2007 14:38:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_fourier_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_fourier_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui_fourier is made visible.
function gui_fourier_OpeningFcn(hObject, eventdata, handles, varargin)
    % Choose default command line output for gui_fourier
    handles.output = hObject;

    handles.checkMonitor = [];
    handles.checkMonitor(1)  = handles.checkMonitor1;
    handles.checkMonitor(2)  = handles.checkMonitor2;
    handles.checkMonitor(3)  = handles.checkMonitor3;
    handles.checkMonitor(4)  = handles.checkMonitor4;
    handles.checkMonitor(5)  = handles.checkMonitor5;
    handles.checkMonitor(6)  = handles.checkMonitor6;
    handles.checkMonitor(7)  = handles.checkMonitor7;
    handles.checkMonitor(8)  = handles.checkMonitor8;
    handles.checkMonitor(9)  = handles.checkMonitor9;
    handles.checkMonitor(10) = handles.checkMonitor10;
    handles.checkMonitor(11) = handles.checkMonitor11;
    
    set(handles.checkMonitor(:), 'Enable', 'off');
    
    % Update handles structure
    guidata(hObject, handles);
return



function varargout = gui_fourier_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;
return



function buttonStartMeasurement_Callback(hObject, eventdata, handles)
    global settings;
    settings.start_measurement = true;
return



function buttonPrintExport_Callback(hObject, eventdata, handles)
    set(handles.figureMain, 'Visible', 'off');
    
    fig = figure('NumberTitle', 'off', 'Name', 'Print window', ...
                 'Units', 'centimeters', 'Position', [1 1 24 18]);
    old_units = get(handles.axesMain, 'Units');
    old_pos = get(handles.axesMain, 'Position');

    % Move the figure and legend into the new figure window
    set(handles.axesMain, 'Units', 'centimeters', 'Position', [2 2 20 14], ...
        'Parent', fig);
    set(handles.legend, 'Parent', fig);

    % Present a print dialog to the user
    lcls_print_export(fig);
    
    % Move the figure and legend back to the main figure
    set(handles.axesMain, ...
        'Parent', handles.figureMain, ...
        'Units', old_units, 'Position', old_pos);
    set(handles.legend, 'Parent', handles.figureMain);

    delete(fig);
    
    set(handles.figureMain, 'Visible', 'on');
    set(handles.axesMain, ...
        'Units', old_units, 'Position', old_pos);
return



function buttonClose_Callback(hObject, eventdata, handles)
    global settings;
    settings.close_requested = true;
return



function editMaxNumSamples_Callback(hObject, eventdata, handles)
return



function editMaxNumSamples_CreateFcn(hObject, eventdata, handles)
return



function editSamplingRate_Callback(hObject, eventdata, handles)
return



function editSamplingRate_CreateFcn(hObject, eventdata, handles)
return



function editPVs_Callback(hObject, eventdata, handles)
return



function editPVs_CreateFcn(hObject, eventdata, handles)
return



function radioTimeDomain_Callback(hObject, eventdata, handles)
    global data;
    set(handles.radioTimeDomain, 'Value', 1);
    set(handles.popupScale, 'Enable', 'off');
    fft_plot_data(handles, data.monitors, ...
              data.timestamps, data.signals, ...
              data.frequencies, data.intensities);
return



function radioFrequencyDomain_Callback(hObject, eventdata, handles)
    global data;
    set(handles.radioFrequencyDomain, 'Value', 1);
    set(handles.popupScale, 'Enable', 'on');
    fft_plot_data(handles, data.monitors, ...
              data.timestamps, data.signals, ...
              data.frequencies, data.intensities);
return



function buttonLoadData_Callback(hObject, eventdata, handles)
    global data settings;

    disable_gui(handles.figureMain);

    old_wd = pwd;
    cd(fft_get_data_path);
    
    [filename, pathname] = uigetfile('*.mat', 'Load file...');
    cd(old_wd);
    if (isequal(filename, 0))
        enable_gui(handles.figureMain);
        return;
    end
    
    settings.data_filename = fullfile(pathname, filename);
    
    set_status(handles, 'Importing file...', 0);

	fft_clear_data;
    try
        data = load(settings.data_filename);
        if (isfield(data, 'signal')),       data.signals     = data.signal;     end
        if (isfield(data, 'timestamp')),    data.timestamps  = data.timestamp;  end
        if (isfield(data, 'frequency')),    data.frequencies = data.frequency;  end
        if (isfield(data, 'intensity')),    data.intensities = data.intensity;  end
        if (isfield(data, 'data') && ~isfield(data, 'timestamps'))
            data = data.data;
        end
        if (~isfield(data, 'monitors'))
            num_monitors = size(data.signals,1);
            for i = 1:num_monitors
                data.monitors(i).pv = 'dummy';
                data.monitors(i).desc = sprintf('monitor %d', i);
            end
        end
    catch
        fft_clear_data;
    end

    fft_enable_monitor_checkboxes(handles);

    monitor_str = cell(length(data.monitors),1);
    for i = 1:length(data.monitors)
        monitor_str{i} = sprintf('%s   %s', data.monitors(i).pv, data.monitors(i).desc);
    end
    set(handles.editPVs, 'String', monitor_str);
    
    set_status(handles, 'Doing FFT ...', 0.5);
    [data.frequencies, data.intensities] = do_fft(data.timestamps, data.signals);
    set_status(handles, 'Done.', 1);

    % Switch to frequency domain
    gui_fourier('radioFrequencyDomain_Callback',handles.radioFrequencyDomain,[],handles)

    fft_plot_data(handles, data.monitors, ...
              data.timestamps, data.signals, ...
              data.frequencies, data.intensities);

    set_status(handles, 'Ready.');

    enable_gui(handles.figureMain);
    fft_enable_monitor_checkboxes(handles);

return



function checkMonitor_Callback(hObject, eventdata, handles)
    global data;
    fft_plot_data(handles, data.monitors, ...
              data.timestamps, data.signals, ...
              data.frequencies, data.intensities);
return



function togglePauseMeasurement_Callback(hObject, eventdata, handles)
    global settings;

    if (get(hObject, 'Value') == 1)
        set(handles.togglePauseMeasurement, ...
            'String', 'Measurement Paused', ...
            'BackgroundColor', [0.7 0.7 0.0]);
        settings.pause_measurement = true;
    else
        set(handles.togglePauseMeasurement, ...
            'String', 'Pause Measurement', ...
            'BackgroundColor', get(0, 'DefaultUIControlBackgroundColor'));
        settings.pause_measurement = false;
    end
return



function popupScale_Callback(hObject, eventdata, handles)
    global data;
    fft_plot_data(handles, data.monitors, ...
              data.timestamps, data.signals, ...
              data.frequencies, data.intensities);
return



function popupScale_CreateFcn(hObject, eventdata, handles)
return
