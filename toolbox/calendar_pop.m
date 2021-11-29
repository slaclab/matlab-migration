function res = calendar_pop(sDate,position)
% UICAL - Calendar date picker
%
%   Created : 10/08/2007
%   Author  : Thomas Montagnon (The MathWorks France) (as uical.m)
%   Modified: 03/01/2009 by Shawn Alverson
%
%   RES = CALENDAR_POP() displays the calendar in English with the today's date
%   selected. RES is the serial date number corresponding to the date the user
%   selected.
%
%   RES = CALENDAR_POP(SDATE) displays the calendar in English with SDATE date
%   selected. SDATE can be either a serial date number or a 3-elements vector
%   containing year, month and day in this order.
%
%   See also CALENDAR.

%     INITIALIZATION
% ------------------------------------------------------------------------------

% Colors
figColor     = get(0,'DefaultUicontrolBackgroundColor'); % Figure background color
colorNoDay   = [0.95  0.95  0.95]; % Background color of the cells that are not days of the selected month
colorDayB    = [1.00  1.00  1.00]; % Background color of the cells that are day of the selected month
colorDayF    = [0.00  0.00  0.00]; % Foreground color of the cells that are day of the selected month
colorDayNB   = [0.30  0.30  0.30]; % Background color of the column headers
colorDayNF   = [1.00  1.00  1.00]; % Foreground color of the column headers
colorSelDayB = [0.70  0.00  0.00]; % Background color of the selected day
colorSelDayF = [1.00  1.00  1.00]; % Foreground color of the selected day

% Use default values if input does not exist
switch nargin
  case 0
    sDate = now;
    position = [50 50];
  case 1
    position = [50 50];
end

% Check input argument validity
if ~isnumeric(sDate)
  error('MYCAL:DateFormat:WrongClass','First input must be numeric');
end
switch numel(sDate)
  case 1
    sDate = datevec(sDate);
  case 3
    if sDate(1) < 0
      error('MYCAL:DateFormat:WrongYearVal','First element of the first input must be a valid year number');
    end
    if (sDate(2) > 12) && (sDate(2) < 1)
      error('MYCAL:DateFormat:WrongMonthVal','Second element of the first input must be a valid month number');
    end
    if (sDate(3) > 31) && (sDate(3) < 1)
      error('MYCAL:DateFormat:WrongDayVal','Third element of the first input must be a valid day number');
    end
  otherwise
    error('MYCAL:DateFormat:WrongVal','First input must be a numeric scalar or a 3-elements vector');
end
  
% Create Month Day and Time arrays
daysN   = {'S','M','T','W','T','F','S'}; % First day is always Sunday
monthsN = {'January','February','March','April','May','June',...
          'July','August','September','October','November','December'};
for k = 0:59
    if k <= 9
        HoursN{k+1} = strcat('0',int2str(k));
        MinSecN{k+1} = strcat('0',int2str(k));
    elseif k <= 23
        HoursN{k+1} = int2str(k);
        MinSecN{k+1} = int2str(k);
    else
        MinSecN{k+1} = int2str(k);
    end
end

% Initializes output
res = sDate(1:3);

% Dimensions
dayH   = 24;
dayW   = 30;
ctrlH  = 20;
figH   = (7 * (dayH - 1)) + (2 * ctrlH);
figW   = 7 * (dayW-1);
ctrlYW = 60;
ctrlMW = 80;
ctrlCW = figW - ctrlYW - ctrlMW;
daysNy = figH - ctrlH - dayH + 1;


%    UICONTROL CREATION
% ------------------------------------------------------------------------------

% Create figure
handles.FgCal = figure( ...
  'Visible', 'off', ...
  'Tag', 'FgCal', ...
  'Name', '', ...
  'Units', 'pixels', ...
  'Position', [position(1) position(2) figW figH], ...
  'Toolbar', 'none', ...
  'MenuBar', 'none', ...
  'NumberTitle', 'off', ...
  'Color', figColor, ...
  'CloseRequestFcn',@FgCal_CloseRequestFcn,...
  'WindowStyle','modal');

% Move the GUI to the center of the screen
%movegui(handles.FgCal,position)

% Columns Headers containing initials of the week days
for dayNidx=1:7
  daysNx = (dayNidx - 1) * (dayW - 1);
  handles.EdDayN(dayNidx) = uicontrol( ...
    'Parent', handles.FgCal, ...
    'Tag', 'EdDay', ...
    'Style', 'edit', ...
    'Units', 'pixels', ...
    'Position', [daysNx daysNy dayW dayH], ...
    'ForegroundColor', colorDayNF, ...
    'BackgroundColor', colorDayNB, ...
    'String', daysN{dayNidx}, ...
    'HorizontalAlignment', 'center', ...
    'Enable','inactive');
end

% Days UI controls
for dayIdx=1:42
  % X and Y Positions
  [i,j] = ind2sub([6,7],dayIdx);
  dayX = (j - 1) * (dayW - 1);
  dayY = (dayH - 1) * 6 - i * (dayH - 1) + ctrlH;

  handles.EdDay(dayIdx) = uicontrol( ...
    'Parent', handles.FgCal, ...
    'Tag', 'EdDay', ...
    'Style', 'edit', ...
    'Units', 'pixels', ...
    'Position', [dayX dayY dayW dayH], ...
    'BackgroundColor', colorDayB, ...
    'ForegroundColor', colorDayF, ...
    'String', '', ...
    'HorizontalAlignment', 'center', ...
    'Enable','inactive');
end

% Listbox containing the list of months
handles.PuMonth = uicontrol( ...
  'Parent', handles.FgCal, ...
  'Tag', 'PuMonth', ...
  'Style', 'popupmenu', ...
  'Units', 'pixels', ...
  'Position', [ctrlYW-2 figH-ctrlH+1 ctrlMW+2 ctrlH], ...
  'BackgroundColor', [1 1 1], ...
  'String', monthsN, ...
  'Value', res(2), ...
  'Callback',@set_cal);

% Edit control which enables you to enter a year number
handles.EdYear = uicontrol( ...
  'Parent', handles.FgCal, ...
  'Tag', 'EdYear', ...
  'Style', 'edit', ...
  'Units', 'pixels', ...
  'Position', [0 figH-ctrlH ctrlYW-1 ctrlH+1], ...
  'BackgroundColor', [1 1 1], ...
  'String', res(1), ...
  'Callback',@set_cal);

% Selection button
handles.PbChoose = uicontrol( ...
  'Parent', handles.FgCal, ...
  'Tag', 'PbChoose', ...
  'Style', 'pushbutton', ...
  'Units', 'pixels', ...
  'Position', [ctrlYW+ctrlMW figH-ctrlH+1 ctrlCW ctrlH], ...
  'String', 'OK', ...
  'Callback','uiresume');

handles.text = uicontrol( ...
  'Parent', handles.FgCal, ...
  'Tag', 'text1', ...
  'Style', 'Text', ...
  'Units', 'pixels', ...
  'Position', [0 -3 150 ctrlH], ...
  'BackgroundColor', figColor, ...
  'HorizontalAlignment','Left', ...
  'String',' Time:             :             :');

handles.Hour = uicontrol( ...
  'Parent', handles.FgCal, ...
  'Tag', 'PuHour', ...
  'Style', 'popupmenu', ...
  'Units', 'pixels', ...
  'Position', [45 0 45 ctrlH], ...
  'BackgroundColor', [1 1 1], ...
  'String', HoursN, ...
  'Value', 1, ...
  'Callback',@set_cal);

handles.Minute = uicontrol( ...
  'Parent', handles.FgCal, ...
  'Tag', 'PuMin', ...
  'Style', 'popupmenu', ...
  'Units', 'pixels', ...
  'Position', [100 0 45 ctrlH], ...
  'BackgroundColor', [1 1 1], ...
  'String', MinSecN, ...
  'Value', 1, ...
  'Callback',@set_cal);

handles.Second = uicontrol( ...
  'Parent', handles.FgCal, ...
  'Tag', 'PuSec', ...
  'Style', 'popupmenu', ...
  'Units', 'pixels', ...
  'Position', [153 0 45 ctrlH], ...
  'BackgroundColor', [1 1 1], ...
  'String', MinSecN, ...
  'Value', 1, ...
  'Callback',@set_cal);

% Display calendar for the default date
set_cal();

% Make the calendar visible
set(handles.FgCal,'Visible','on')

% Wait for user action
uiwait(handles.FgCal);

if ~isempty(res)
   % Convert date to serial date number and add time
   hour = get(handles.Hour,'String');
   hour = char(hour(get(handles.Hour,'Value')));
   minute = get(handles.Minute,'String');
   minute = char(minute(get(handles.Minute,'Value')));
   second = get(handles.Second,'String');
   second = char(second(get(handles.Second,'Value')));
   timestmp = [hour,':',minute,':',second];

   res = [datestr(datenum(res),23),' ',timestmp];
end

% Close the calendar figure
delete(handles.FgCal);


% ------------------------------------------------------------------------------
% --- CALLBACKS                                                              ---
% ------------------------------------------------------------------------------

  function FgCal_CloseRequestFcn(varargin)
    % Callback executed when the user 'onscreen'click on the close button of the figure.
    % This means he wants to cancel date selection so function returns the
    % intial date (the one used when we opened the calendar)

    % Set the output to the intial date value
    res = [];
    
    % End execution of the window
    uiresume;
  end


  function EdDay_ButtonDownFcn(varargin)
    % Callback executed when the user click on day.
    % Updates the RES variable containing the currently selected date and then
    % update the calendar.
    
    res(1) = str2double(get(handles.EdYear,'String'));
    res(2) = get(handles.PuMonth,'Value');
    res(3) = str2double(get(varargin{1},'String')); % Number of the selected day
    
    set_cal();
  end


  function set_cal(varargin)
    % Displays the calendar according to the selected date stored in RES

    % Get selected Year and Month
    year   = str2double(get(handles.EdYear,'String'));
    res(2) = get(handles.PuMonth,'value');
    
    % Check Year value (keep previous value if the new one is wrong)
    if ~isnan(year)
      res(1) = abs(round(year)); % ensure year is a positive integer
    end
    set(handles.EdYear,'String',res(1))

    % Get the matrix of the calendar for selected month and year then convert it
    % into a cell array
    c = calendar(res(1),res(2));
    v = mat2cell(c,ones(1,6),ones(1,7));

    % Cell array of indices used to index the vector of handles
    i = mat2cell((1:42)',ones(1,42),1);

    % Set String property for all cells of the calendar
    cellfun(@(i,x) set(handles.EdDay(i),'string',x),i,v(:))

    % Change properties of the "non-day" cells of the calendar
    set(handles.EdDay(c==0),'ButtonDownFcn','','BackgroundColor', colorNoDay,'string','')
    
    % Change the properties of the calendar's cells containing existing days
    set(handles.EdDay(c~=0),'ButtonDownFcn',@EdDay_ButtonDownFcn,'BackgroundColor',colorDayB, ...
      'ForegroundColor',colorDayF,'FontWeight','normal')

    % Highlight the selected day
    set(handles.EdDay(c==res(3)),'BackgroundColor',colorSelDayB,'ForegroundColor',colorSelDayF, ...
      'FontWeight','bold')
    
    % Update the name of the figure to reflect the selected day
    set(handles.FgCal,'Name',datestr(datenum(res),23))
    
    % Give focus to the "OK" button
    uicontrol(handles.PbChoose);
    
  end

end