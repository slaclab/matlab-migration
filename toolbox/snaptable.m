function energy = snaptable(position)
% Create By: Shawn Alverson
%
% snaptable creates a graphical table displaying the various energy
% snapshot configs available and allows the user to select and load a
% config directly into energyChange_gui.m
%
% if given, varargin(1) is the window position

% Get file data
pathName=fullfile(getenv('MATLABDATAFILES'),'config');
flist = dir(fullfile(pathName,'energyChange*.mat'));
numfiles = length(flist);

% Grab energy values (in GeV) and dates
for index = 1:numfiles
    stop = findstr(flist(index).name,'_c') - 1;
    elist(index) = str2double(flist(index).name(18:stop))/1000;
    dlist{index} = flist(index).date;
end

% Sort both arrays based on energy
% [elist,i] = sort(elist,'descend');
% for index = 1:numfiles
%     buffer{index} = dlist{i(index)};
% end
% dlist = buffer;
sortOrder = -1; % -1 for descending, 1 for ascending
energySort();

% Get position to load window
if nargin == 0 || isempty(position)
    position = [ 1000 200 ];
end
        
%Setup figure env vars
figColor     = get(0,'DefaultUicontrolBackgroundColor'); % Figure background color
row_plainB   = [1.00  1.00  1.00]; % Background color of the data cells
row_plainF   = [0.00  0.00  0.00]; % Foreground color of the data celss
HeadBG       = [0.30  0.30  0.30]; % Background color of the column headers
HeadFG       = [1.00  1.00  1.00]; % Foreground color of the column headers
row_selectB  = [0.00  0.00  0.70]; % Background color of the selected cells
row_selectF  = [1.00  1.00  1.00]; % Foreground color of the selected cells
Headers = {'Energy (GeV)';'Date'};
selection = 1;

% Dimensions
cellH    = 24;
cellW    = 200;
ctrlW    = 100;
ctrlH    = 24;
cellmax  = 20;
c= 1:cellmax;
figH     = (cellmax*cellH) + cellH;
figW     = 1.5*cellW;
headY    = (figH-cellH+1);
pagenow = 1;
pagetot = int32(numfiles/cellmax);
if rem(numfiles,cellmax) < 5
    pagetot = pagetot + 1;
end

% Create figure
handles.FgTable = figure( ...
  'Visible', 'off', ...
  'Tag', 'FgTable', ...
  'Name', 'Select Snapshot Config:', ...
  'Units', 'pixels', ...
  'Position', [position(1) position(2) figW figH], ...
  'Toolbar', 'none', ...
  'MenuBar', 'none', ...
  'NumberTitle', 'off', ...
  'Color', figColor, ...
  'Resize','off', ...
  'CloseRequestFcn',@FgTable_CloseRequestFcn,...
  'WindowStyle','modal');

% Column Headers
for index=1:2
  headX = (index - 1) * (cellW*0.5 - 1);
  handles.head(index) = uicontrol( ...
    'Parent', handles.FgTable, ...
    'Tag', num2str(index), ...
    'Style', 'edit', ...
    'Units', 'pixels', ...
    'Position', [headX headY cellW*(0.5*index) cellH], ...
    'ForegroundColor', HeadFG, ...
    'BackgroundColor', HeadBG, ...
    'String', Headers{index}, ...
    'ButtonDownFcn',@Headers_ButtonDownFcn, ...
    'HorizontalAlignment', 'center', ...
    'Enable','inactive');
end

% Energy UI controls
for index=1:cellmax
  % X and Y Positions
  cellX = 0;
  cellY = (cellH - 1) * cellmax - (index-1) * (cellH - 1);

  handles.ECells(index) = uicontrol( ...
    'Parent', handles.FgTable, ...
    'Tag', num2str(index), ...
    'Style', 'edit', ...
    'Units', 'pixels', ...
    'Position', [cellX cellY cellW/2 cellH], ...
    'BackgroundColor', row_plainB, ...
    'ForegroundColor', row_plainF, ...
    'String', '', ...
    'ButtonDownFcn',@DCells_ButtonDownFcn, ...
    'HorizontalAlignment', 'center', ...
    'Enable','inactive');
end

% Time UI controls
for index=1:cellmax
  % X and Y Positions
  cellX = (cellW*0.5 - 1);
  cellY = (cellH - 1) * cellmax - (index-1) * (cellH - 1);

  handles.DCells(index) = uicontrol( ...
    'Parent', handles.FgTable, ...
    'Tag', num2str(index), ...
    'Style', 'edit', ...
    'Units', 'pixels', ...
    'Position', [cellX cellY cellW cellH], ...
    'BackgroundColor', row_plainB, ...
    'ForegroundColor', row_plainF, ...
    'String', '', ...
    'ButtonDownFcn',@DCells_ButtonDownFcn, ...
    'HorizontalAlignment', 'center', ...
    'Enable','inactive');
end

% Selection button
handles.CellSelect = uicontrol( ...
  'Parent', handles.FgTable, ...
  'Tag', 'CellSelect', ...
  'Style', 'pushbutton', ...
  'Units', 'pixels', ...
  'Position', [0 0 ctrlW ctrlH], ...
  'String', 'OK', ...
  'Callback',@CellSelect);

handles.PrevPage = uicontrol( ...
  'Parent', handles.FgTable, ...
  'Tag', 'PrevPage', ...
  'Style', 'pushbutton', ...
  'Units', 'pixels', ...
  'Position', [(figW-155) 0 30 ctrlH], ...
  'String', '<=', ...
  'Callback',@PrevPage);

handles.PageText = uicontrol( ...
  'Parent', handles.FgTable, ...
  'Tag', 'PageText', ...
  'Style', 'Text', ...
  'Units', 'pixels', ...
  'Position', [(figW-117) -3 80 ctrlH], ...
  'BackgroundColor', figColor, ...
  'HorizontalAlignment','center', ...
  'String',['Page ',num2str(pagenow),' of ',num2str(pagetot)]);

handles.NextPage = uicontrol( ...
  'Parent', handles.FgTable, ...
  'Tag', 'NextPage', ...
  'Style', 'pushbutton', ...
  'Units', 'pixels', ...
  'Position', [(figW-31) 0 30 ctrlH], ...
  'String', '=>', ...
  'Callback',@NextPage);

CreatePage(0);

set(handles.FgTable,'Visible','on')
uiwait(handles.FgTable);

%delete(handles.FgTable);   % Close window when finished



function CellSelect(varargin)
   %disp(['Cell number ',num2str(selection),' selected!'])
   energy = elist(cellmax*(pagenow-1) + selection);
   %disp(energy)
   uiresume;
   delete(handles.FgTable);   % Close window when finished
end

function Headers_ButtonDownFcn(varargin)
    header = str2double(get(varargin{1},'Tag')); % Number of the selected cell
    sortOrder = -1*sortOrder; % flip direction of sort
    if header == 1
        energySort()
    else
        dateSort()
    end
    DisplayData()        
end

function energySort(varargin)
    % Sort both arrays based on energy
    if sortOrder == -1
        [elist,i] = sort(elist,'descend');
    else
        [elist,i] = sort(elist,'ascend');
    end
    buffer = [];
    for ind = 1:numfiles
        buffer{ind} = dlist{i(ind)};
    end
    dlist = buffer;
end

function dateSort(varargin)
    % Sort both arrays based on date
    if sortOrder == -1
       [dtemp,i] = sort(datenum(dlist),'descend'); 
    else
       [dtemp,i] = sort(datenum(dlist),'ascend');
    end
    buffer = [];
    for ind = 1:numfiles
        dlist{ind} = datestr(dtemp(ind));
        buffer(ind) = elist(i(ind));
    end
    elist = buffer;
end

function DCells_ButtonDownFcn(varargin)
    % Callback executed when the user click on a cell.
    selection = str2double(get(varargin{1},'Tag')); % Number of the selected cell  
    
    % Change the properties of the non-selected cells
    set(handles.ECells(c~=selection),'ButtonDownFcn',@DCells_ButtonDownFcn,'BackgroundColor',row_plainB, ...
      'ForegroundColor',row_plainF,'FontWeight','normal')
    set(handles.DCells(c~=selection),'ButtonDownFcn',@DCells_ButtonDownFcn,'BackgroundColor',row_plainB, ...
      'ForegroundColor',row_plainF,'FontWeight','normal')

    % Highlight the selected cell
    set(handles.ECells(selection),'ButtonDownFcn','','BackgroundColor',row_selectB,'ForegroundColor',row_selectF, ...
      'FontWeight','bold')
    set(handles.DCells(selection),'ButtonDownFcn','','BackgroundColor',row_selectB,'ForegroundColor',row_selectF, ...
      'FontWeight','bold')
end

function PrevPage(varargin)
    CreatePage(-1);
end

function NextPage(varargin)
    CreatePage(1);
end

function CreatePage(direction)
    switch direction
        case -1
            %disp('To the left!')
            if pagenow > 1
                pagenow = (pagenow - 1);               
            end
        case 0
            %disp('Refresh!')
        case 1    
            %disp('To the right!')
            if pagenow < pagetot
                pagenow = (pagenow + 1);
            end
        otherwise
    end
    
    set(handles.PageText,'String',['Page ',num2str(pagenow),' of ',num2str(pagetot)])
    
    DisplayData()
end

function DisplayData()
    top = cellmax*(pagenow-1);
    wall = (pagenow*cellmax) - numfiles;
    if (wall > 0)
        stop = cellmax - wall;
        for index = (stop+1):cellmax
            set(handles.ECells(index),'String','','Visible','off')
            set(handles.DCells(index),'String','','Visible','off')
        end
    else
        stop = cellmax;
    end
    
    for index = 1:stop
        %disp(index)
        set(handles.ECells(index),'String',num2str(elist(top + index)),'Visible','on')
        set(handles.DCells(index),'String',dlist(top + index),'Visible','on')
    end
end

function FgTable_CloseRequestFcn(varargin)
   % Callback executed when the user click on the close button of the figure.
   % This means he wants to cancel date selection so function returns the
   % intial date (the one used when we opened the calendar) 
   
   % End execution of the window
   energy = [];
   uiresume;
   delete(handles.FgTable);   % Close window when finished
end

end