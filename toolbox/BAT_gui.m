function varargout = BAT_gui(varargin)
% BAT_GUI M-file for BAT_gui.fig
%      BAT_GUI, by itself, creates a new BAT_GUI or raises the existing
%      singleton*.
%
%      H = BAT_GUI returns the handle to a new BAT_GUI or the handle to
%      the existing singleton*.
%
%      BAT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BAT_GUI.M with the given input arguments.
%
%      BAT_GUI('Property','Value',...) creates a new BAT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BAT_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BAT_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BAT_gui

% Last Modified by GUIDE v2.5 15-Apr-2013 16:36:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BAT_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @BAT_gui_OutputFcn, ...
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


% --- Executes just before BAT_gui is made visible.
function BAT_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BAT_gui (see VARARGIN)

% Choose default command line output for BAT_gui
handles.output = hObject;

handles.mfile = mfilename();

% BAT_gui config
handles.config.nsamp = 10;
handles.config.multi = 0;
handles.config.coarsewin = 1;
handles.config.fitwin = 1;

handles.plotready = 0;
handles.saved = 1;
handles.data = struct();
handles.calc = struct();

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BAT_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BAT_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_statusDisp(handles, 'Loading...');
set(hObject, 'Toolbar', 'figure');

handles.static = BAT_init();
handles = update_gui(handles);

gui_statusDisp(handles, 'Ready.  Press Acquire to collect data.');

% Get default command line output from handles structure
varargout{1} = handles.output;
guidata(hObject, handles);


function handles = update_gui(handles)

set(handles.edit_nsamp, 'String', num2str(handles.config.nsamp));
set(handles.checkbox_multi, 'Value', handles.config.multi);
set(handles.checkbox_coarsewin, 'Value', handles.config.coarsewin);
set(handles.checkbox_fitwin, 'Value', handles.config.fitwin);
drawnow;


function handles = process_data(handles)

if ~isfield(handles, 'data')
    gui_stausDisp(handles, 'No data available for plotting.');
    handles.plotready  = 0;
    return
end

% setup the "cavity select" listbox
num = handles.static.num.chans;
plot_cavstr = cell(num, 1);
for ix = 1:num
    plot_cavstr{ix} = sprintf('Channel %d', ix);
end
set(handles.listbox_cavity, 'String', plot_cavstr);

% default to plot all cavities
%set(handles.listbox_cavity, 'Value', 1);


% do the BAT_calc
num = numel(handles.data);
for ix = 1:num
    handles.calc(ix) = BAT_calc(handles.static, handles.data(ix));
end

% setup the "plot select" listbox
plotnames = fieldnames(handles.calc(1).plot);
set(handles.listbox_plot, 'String', plotnames);

handles.plotready = 1;
    

function handles = do_plot(handles, ax)

if nargin < 2, ax = handles.axes1; end
if ~handles.plotready, return, end

plotselect = get(handles.listbox_plot, 'Value');
plotnames = get(handles.listbox_plot, 'String');
plotname = plotnames{plotselect};

if handles.config.multi
    cavselect = [1 2 3 4];
else
    cavselect = get(handles.listbox_cavity, 'Value');
end

if handles.config.multi
    handles.multifig = figure(1);
    clf(handles.multifig, 'reset');
end

cla(ax, 'reset');
hold all;

for ix = 1:numel(handles.data)
    data = handles.data(ix);
    calc = handles.calc(ix);
    plotdata = calc.plot.(plotname);
    for jx = 1:numel(cavselect)
        cav = cavselect(jx);
        if handles.config.multi
            subplot(2, 2, jx); hold all;
            if handles.config.multi
                
                title(sprintf('Channel %d %s', cav, plotname), 'interpreter', 'none');
                xlabel('Time (s)');

                if handles.config.coarsewin
                    ver_line(handles.static.crude.time(1), 'k-');
                    ver_line(handles.static.crude.time(2), 'k-');
                end

                if handles.config.fitwin
                    ver_line(handles.static.fit.time(1), 'k--');
                    ver_line(handles.static.fit.time(2), 'k--');
                end

            end
        end
        plot(plotdata.time(:, 1), plotdata.data(:, cav));
    end
end

if handles.config.coarsewin
    ver_line(handles.static.crude.time(1), 'k-');
    ver_line(handles.static.crude.time(2), 'k-');
end

if handles.config.fitwin
    ver_line(handles.static.fit.time(1), 'k--');
    ver_line(handles.static.fit.time(2), 'k--');
end

if ~handles.config.multi
    cavlist = strcat(num2str(cavselect), {' '});
    title(sprintf('%s Channel %s %s', datestr(lca2matlabTime(handles.data(1).ts)), ...
        char(cavlist), plotname), 'interpreter', 'none');
end
xlabel('Time (s)');

% --- Executes on button press in pushbutton_acquire.
function pushbutton_acquire_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_acquire (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_statusDisp(handles, 'Starting acquisition...');

if ~handles.saved
    if ~strcmpi(questdlg('Data not saved!  Proceed anyway?'), 'Yes'), return; end
end

handles = rmfield(handles, 'data');  handles = rmfield(handles, 'calc');
handles.saved = 0;

for ix = 1:handles.config.nsamp
    gui_statusDisp(handles, strcat({'Acquiring '}, num2str(ix), {'/'}, num2str(handles.config.nsamp), ' samples'));
    handles.data(ix) = BAT_collect(handles.static);
end

gui_statusDisp(handles, 'Acquisition finished.');
guidata(hObject, handles);

handles = process_data(handles);
handles = do_plot(handles);

guidata(hObject, handles);
    


% --- Executes on selection change in listbox_plot.
function listbox_plot_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_plot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_plot

handles = do_plot(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox_plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_nsamp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nsamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.config.nsamp = str2int(get(hObject, 'String'));
handles = update_gui(handles);
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of edit_nsamp as text
%        str2double(get(hObject,'String')) returns contents of edit_nsamp as a double


% --- Executes during object creation, after setting all properties.
function edit_nsamp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nsamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_save.
function handles = pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = util_dataSave(handles.data, 'BAT_gui', handles.static.array.waveform, ...
    lca2matlabTime(handles.data(1).ts));
gui_statusDisp(handles, sprintf('Data saved to %s', filename));
handles.saved = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = rmfield(handles, 'data');  handles = rmfield(handles, 'calc');
handles.saved = 1;

handles.data = util_dataLoad();

handles = process_data(handles);
handles = do_plot(handles);

guidata(hObject, handles);

% --- Executes on selection change in listbox_cavity.
function listbox_cavity_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_cavity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = do_plot(handles);
guidata(hObject, handles);

% Hints: contents = get(hObject,'String') returns listbox_cavity contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_cavity


% --- Executes during object creation, after setting all properties.
function listbox_cavity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_cavity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_plothelp.
function pushbutton_plothelp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plothelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

helptxt = {'This is what all the plot names mean:'};
helptxt = [helptxt; {' '}];
helptxt = [helptxt; {'raw = raw waveform from digitizer'}];
helptxt = [helptxt; {'bgsub = background-subtracted raw waveform'}];
helptxt = [helptxt; {'I_u, Q_u = I & Q, after downconversion'}];
helptxt = [helptxt; {'I_x, Q_x = I & Q, after first windowing'}];
helptxt = [helptxt; {'I, Q = I & Q, after offset rotation'}];
helptxt = [helptxt; {'I_f, Q_f = I & Q, after filtering'}];
helptxt = [helptxt; {'P_f = total power (ampl ^ 2)'}];
helptxt = [helptxt; {'T_f = phase'}];
helptxt = [helptxt; {'P_f_fit = total power after second windowing'}];
helptxt = [helptxt; {'T_f_fit = phase after second windowing'}];

helpstr = [];
for ix = 1:numel(helptxt)
    helpstr = [helpstr sprintf('%s\n', helptxt{ix})];
end

helpdlg(helpstr, 'Plot names decoder ring');


% --- Executes on button press in checkbox_multi.
function checkbox_multi_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_multi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_multi

handles.config.multi = get(hObject, 'Value');
handles = update_gui(handles);
handles = do_plot(handles);
guidata(hObject, handles);


% --- Executes on button press in checkbox_coarsewin.
function checkbox_coarsewin_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_coarsewin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_coarsewin
handles.config.coarsewin = get(hObject, 'Value');
handles = update_gui(handles);
handles = do_plot(handles);
guidata(hObject, handles);

% --- Executes on button press in checkbox_fitwin.
function checkbox_fitwin_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_fitwin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_fitwin
handles.config.fitwin = get(hObject, 'Value');
handles = update_gui(handles);
handles = do_plot(handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton_print.
function pushbutton_print_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~handles.saved
    handles = pushbutton_save_Callback(handles.pushbutton_save, [], handles);
end

if handles.config.multi
    util_printLog(handles.multifig);
else
    printfig = figure();
    printax = axes();
    handles = do_plot(handles, printax);
    set(printax, 'XLim', get(handles.axes1, 'XLim'));
    set(printax, 'YLim', get(handles.axes1, 'YLim'));
    util_printLog(printfig);
end

