function plotHistory( pv, timeRange, flags)
%function plotHistory( pv, timeRange, flags);
% Inputs:
%
%     pv - The name of an AIDA acquireable history variable. These
%                typically end in //HIST, or sometimes //HIST.lcls if from
%                EPICS. See aidalist unix script.  User is prompted for PV
%                if not specified.
%
%     timeRange -  Cell array containing startTime and endTime.
%                  Time in format 'mm/dd/yyyy hh:mm:ss'.  Defaults to last
%                  2 hours if not specified.
%
%     flags - Vector of option flags.  Optional (defaults to no aditional option).
%     flags(1) = Interpolation Step:
%                value in seconds used to generate evenly spaced time vector and
%                interpolated data instead of raw archiver data.
%     flags(2) = Median Filter on/off.
%     flags(3) = Multi-plot.
%
%example:
%pv = 'FBCK:BCI0:1:CHRG';
%timeRange = {'05/11/2008 12:31:20', '05/11/2008 13:31:20' };
%flags = [0 0 0];
%plotHistory(pv, timeRange, flags);

% W. Colocho, June 2008.

%prompt for pv if not given
if nargin < 1,
  pv = inputdlg({'Enter PV:'},'PV?', 1);
  if(isempty(pv)),fprintf('Error: no pv given\n'); return, end
  pv = upper(char(pv));
end
%prompt for timeRange if not given
if nargin < 2, timeRangeString = '2 Hours'; timeRange = {''};
  else timeRangeString = 'UseTimeRange';
end
if nargin <3, flags = [0 0 0]; end
%find out machine name
[sys, accelerator] = getSystem;
uData.guiMODE = lcaGetSmart(sprintf('SIOC:%s:AL00:MODE',sys));


uData.figH= figure;
dcm_obj = datacursormode(uData.figH);
set(dcm_obj, 'UpdateFcn',@dataCursorShowTime)
if ( strcmp('usr', strtok(which('plotHistory'),'/') ) )
   %set(uData.figH, 'DeleteFcn', 'stopTimerOnClose');%exit matlab when figure is closed if on production.
   %set(uData.figH,'CloseRequestFcn','exit');
else
    set(uData.figH, 'DeleteFcn', 'stopTimerOnClose'); %For development stop timer if window is closed.
end
uData.source = 'appliance';
uData.timeRange = timeRange;
uData.pv = pv;
uData.interpStep = flags(1);
uData.medFilt = flags(2);
uData.accelerator = accelerator;
uData.multi = flags(3);
uData.rmsFilt = 0;
 disp(['Data source is: ' uData.source])
 set(uData.figH,'Name', ['Data source is: ' uData.source])
% Setup Toolbar
makeToolbar(uData);

%Setup Menus
timeStr = {'2 Hours', '4 Hours', '8 Hours', '12 Hours', '24 Hours', '48 hours',  ...
           'Three Days', 'Four Days', 'Week', 'Two Weeks' , 'Three Weeks', ...
           'Four Weeks', 'Eight Weeks'};
menuH1 = uimenu('Label', 'Time Range', 'Tag', 'plotLastMenu');
for i = 1:length(timeStr)
  uimenu(menuH1,'Label',timeStr{i} ,'Callback',{@plotIt,timeStr{i}});
end
menuH2 = uimenu('Label', 'Options', 'Tag','plotOptions');
uData.optList = {'printOpsLog','printLcls','limitsScale','medianFilter','ignoreFlyer', 'rmsFilter',...
                 'stepLeft','stepRight','stepLDay','stepRDay','userRange','multiPlot', ...
                 'stripTool','corrcoef','polyfit','math'};
optListLabel = {'Print Ops Log', ['Print ',upper(accelerator),' Log'],'Limits Scale','Median Filter', 'Ignore Flyer', ...
                'rms Filter', '<-Step Time', 'Step Time->', 'Step Time -Day', 'Step Time +Day', 'Enter Time Scale', ...
                'Multi Plot', 'StripTool', 'Correlation Coefficient', 'Polynomial Fit', 'Math'};
%uimenu(menuH2,'Label', 'Median Filter', 'Callback', {@plotIt,'medianFilter'});
for i = 1:length(uData.optList)
    uimenu(menuH2,'Label', optListLabel{i}, 'Callback', {@plotIt,uData.optList{i} });
end
uData.timeStr = timeStr;
set(uData.figH,'UserData',uData);
plotIt([],[],timeRangeString)
end

% Create toolbar
function makeToolbar(uData)
% toolbar = findall(uData.figH,'Type','uitoolbar');
% toolbarList = {'limitsScale', 'medianFilter'};
% toolbarString = {'Limits Scale', 'Median Filter'};
% uitoggletool( toolbar, 'CData',rand(20,20,3), 'TooltipString','StripTool', ...
%                 'Separator','on', 'HandleVisibility','off', ...
%                 'ClickedCallback', {@plotIt, 'stripTool'} );
% for i = 1:length(toolbarList)
%    uipushtool( toolbar, 'CData',rand(20,20,3), 'TooltipString',toolbarString{i}, ...
%                 'HandleVisibility','off', 'ClickedCallback', {@plotIt, toolbarList{i}} );
% end
%stripTool needs to be uitoggletool

% % '/home/physics/pgribnau/WORK/plotHistory/','24Hour.bmp'
% % icon1 = fullfile('/home/physics/pgribnau/WORK/plotHistory/icons/','24Hour.gif');
% % icon2 = fullfile(matlabroot,'/toolbox/matlab/icons/tool_arrow.gif');


icondir = '/afs/slac/g/lcls/matlab/toolbox/icons/';
if exist(icondir) ~= 7
   icondir = '/usr/local/lcls/tools/matlab/toolbox/icons/';
end

icon1 = fullfile(icondir,'hour24.gif');
icon2 = fullfile(icondir,'week.gif');
icon3 = fullfile(icondir,'printopslog.gif');
icon4 = fullfile(icondir,'printlcls.gif');
icon5 = fullfile(icondir,'limitsscale.gif');
icon6 = fullfile(icondir,'medianfilter.gif');
icon7 = fullfile(icondir,'ignoreflyer.gif');
icon8 = fullfile(icondir,'stepleft.gif');
icon9 = fullfile(icondir,'stepright.gif');
icon10 = fullfile(icondir,'steplday.gif');
icon11 = fullfile(icondir,'steprday.gif');
icon12 = fullfile(icondir,'userrange.gif');
icon13 = fullfile(icondir,'multiplot.gif');
icon14 = fullfile(icondir,'striptool.gif');
icon15 = fullfile(icondir,'corrcoef.gif');
icon16 = fullfile(icondir,'polyfit.gif');
icon17 = fullfile(icondir,'math.gif');
iconList = { icon1, icon2, icon3, icon4, icon5, icon6, icon7, icon8, icon9, icon10, icon11, icon12, ...
             icon13, icon14, icon15, icon16, icon17 };
for i = 1:length(iconList)
    [cdata,map] = imread(iconList{i});
    map(find(map(:,1)+map(:,2)+map(:,3)==3)) = NaN; %convert white pixels into transparent background
    iconList{i} = ind2rgb(cdata,map); %convert into 3D RGB-space
end

toolbar = uitoolbar(uData.figH);
toolbarList = {'24 Hours', 'Week', 'printOpsLog', 'printLcls', 'limitsScale', 'medianFilter', ...
               'ignoreFlyer', 'stepLeft', 'stepRight', 'stepLDay', 'stepRDay', 'userRange', ...
               'multiPlot', 'stripTool', 'corrcoef', 'polyfit', 'math' };
toolbarString = {'24 Hours', 'Week', 'Print Ops Log', ['Print ',upper(uData.accelerator),' Log'], ...
                 'Limits Scale', 'Median Filter', 'Ignore Flyer', '<-Step Time', 'Step Time->', ...
                 'Step Time -Day', 'Step Time +Day', 'Enter Time Scale', 'Multi Plot', ...
                 'Strip Tool', 'Correlation Coefficient', 'Polynomial Fit', 'Math' };

hasSep = [3,5,8,13];
istoggletool = [14];
for i = 1:length(toolbarList)
    if find(istoggletool == i)
        uitoggletool( toolbar, 'CData',iconList{i}, 'TooltipString',toolbarString{i}, ...
                    'HandleVisibility','off', 'ClickedCallback', {@plotIt, toolbarList{i}} );
    elseif find(hasSep == i)
        uipushtool( toolbar, 'CData',iconList{i}, 'TooltipString',toolbarString{i}, 'Separator','on', ...
                    'HandleVisibility','off', 'ClickedCallback', {@plotIt, toolbarList{i}} );
    else
        uipushtool( toolbar, 'CData',iconList{i}, 'TooltipString',toolbarString{i}, ...
                    'HandleVisibility','off', 'ClickedCallback', {@plotIt, toolbarList{i}} );
    end
end

end

% plotIt function
function plotIt(src,evt,optStr) %
plotAgain = 1;
uData = get(gcf,'UserData');
if ~isfield(uData,'newLinePlot'), uData.newLinePlot = 1; else uData.newLinePlot = 0; end
if strcmp (optStr, 'printLcls'),
    switch uData.accelerator
        case 'LCLS', util_printLog(uData.figH);
        case 'FACET', print(gcf,'-dpsc2','-Pfacetlog');
    end
    return,
end

if strcmp(optStr, 'printOpsLog'),
    print(gcf, '-dpsc2', '-Pelog_mcc'),
    return,
end
medFiltStr = '';

[timeRange,range] = getTimeRange(optStr, uData);
uData.timeRange = timeRange;

% Get list of pv's for multi plot
if strcmp (optStr, 'multiPlot'),
    if ~ischar(uData.pv(1))
        pvStr = char(uData.pv(1));
    else
        pvStr = uData.pv;
    end
    name1 = pvStr(1:4);
    len = length(pvStr);
    name2 = pvStr(len-3:len);

    prompt={'aidalist search input'};
    name='Get PV List';
    numlines=1;
    defaultList = { strcat(name1,'%',name2) };
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='none';
    answer=inputdlg(prompt,name,numlines,defaultList,options);
    pvList = aidalist(char(answer));

    str = pvList;
    [s,v] = listdlg('PromptString','Select a file:',...
                'SelectionMode','multiple',...
                'ListString',str,...
                'ListSize', [200 600]);
    if isempty(s), return; end
    plotHistory(pvList(s),timeRange, [0 0 1]);
    return,
end

% Correlation Coefficient
if strcmp (optStr, 'corrcoef'),
    prompt={'X-Axis' , 'Y-Axis', 'Start Time', 'End Time'};
    name='Correlation Coefficient';
    numlines=1;
    defaultAxis = { uData.pv, uData.pv, timeRange{1}, timeRange{2} };
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='none';
    answer=inputdlg(prompt,name,numlines,defaultAxis,options);
    if isempty(answer), return, end

    flag = [1 0];
    plotForms(answer, range, uData, flag);
    return,
end

% Polynomial Fit
if strcmp (optStr, 'polyfit'),
    prompt={'X-Axis' , 'Y-Axis', 'Degree N', 'Start Time', 'End Time'};
    name='Correlation Coefficient';
    numlines=1;
    defaultAxis = { uData.pv, uData.pv, '1', timeRange{1}, timeRange{2} };
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='none';
    answer=inputdlg(prompt,name,numlines,defaultAxis,options);
    if isempty(answer), return, end

    flag = [0 1];
    plotForms(answer, range, uData, flag);
    return,
end

% Math Plot Function
if strcmp (optStr, 'math'),
    prompt={'Time Start: ''mm/dd/yyyy hh:mm:ss''', 'Time End: ''mm/dd/yyyy hh:mm:ss''',...
        'Formula: (ie. A+B)', 'A = Device 1:', 'B = Device 2:', 'C = Device 3:', 'D = Device 4:'};
    name='Formula';
    numlines=1;

    form = '';
    defaultanswer = { timeRange{1}, timeRange{2}, form, uData.pv, uData.pv, '', '' };
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='none';
    answer=inputdlg(prompt,name,numlines,defaultanswer,options);
    if isempty(answer), return, end

    math(answer, uData);
    return,
end

% Get new data unless option is median filter, ignore flyer, or user scale or stripTool.
stripToolStart = 0;
stripToolStop = 0;
switch optStr
    case 'medianFilter'
       if (uData.medFilt==0), uData.medFilt = 1; end
          getNewData = 0;
          uData.limScale = 0;
    case 'rmsFilter'
       uData.rmsFilt = 1;
       getNewData = 0;
       uData.limScale = 0;
    case 'limitsScale', getNewData = 0; uData.limScale = 1;
    case 'ignoreFlyer', getNewData = 0;
        if ~uData.multi
            removeIndx = [find(( uData.value > mean(uData.value) + 3 * std(uData.value))) , ...
                find(( uData.value < mean(uData.value) - 3 * std(uData.value)))];
            uData.value(removeIndx) = [];
            uData.time(removeIndx) = [];
        end
        uData.ignoreFlyer = 1; uData.limScale = 0;
%     case 'stripTool', getNewData = 0; uData.limScale = 0; uData.ignoreFlyer = 0; stripToolStart = 1;
%                             plotAgain = 0;
    case 'stripTool',
        try
            if strcmp(get(gcbo,'State'),'off'),
                getNewData = 0; stripToolStop = 1;
            else
                getNewData = 0; uData.limScale = 0; uData.ignoreFlyer = 0; stripToolStart = 1; plotAgain = 0;
            end
        catch
            if strcmp(get(gcbo,'Checked'),'on'),
                set(gcbo,'Checked','off');
                getNewData = 0; stripToolStop = 1;
            else set(gcbo,'Checked','on');
                getNewData = 0; uData.limScale = 0; uData.ignoreFlyer = 0; stripToolStart = 1; plotAgain = 0;
            end
        end
    otherwise, getNewData = 1; plotAgain = 1; uData.limScale = 0; uData.ignoreFlyer = 0;
end
if getNewData  && ~uData.newLinePlot, stripToolStop = 1; end
if getNewData, uData.medFilt = 0; uData.rmsFilt = 0; uData.limScale = 0;end

% StripTool
%timerTools = timerfind;
lineH = findobj(uData.figH,'Type','line', 'Tag', 'LinePlot');

if stripToolStart
    lineUsDat = get(lineH(1),'UserData');
    tim = lineUsDat{2};
    if isempty(tim),
        tim = timer('TimerFcn',{@timerStripTool, lineH}, 'Period', 2.0, 'ExecutionMode',   'fixedRate');
        lineUsDat = {lineUsDat{1}, tim};
        set(lineH(1), 'UserData',lineUsDat);
    end
    start(tim)
    return
end
if stripToolStop,
    lineUsDat = get(lineH(1),'UserData');
    tim = lineUsDat{2};
    if ~isempty(tim), stop(tim) ; end
end

%timerStripTool(uData, lineH);


% Multi Plot
uData.getNewData = getNewData;
set(uData.figH,'UserData',uData)
if uData.multi
    uData = multiPlot(uData.pv,uData.timeRange,uData,range);
    set(uData.figH,'UserData',uData);
    return,
end

% Get new data unless callback is from median filter or limits scale.
%%
if(getNewData)
  title('Getting data...'), drawnow
%   switch uData.accelerator
%       case 'LCLS', aidaStr = 'HIST.lcls';
%       case 'FACET', aidaStr = 'HIST.facet';
%       otherwise, aidaStr = 'none';
%   end  W. Colocho no longer needed since we use archList instead of
%   aidalist


  archivedPv = [uData.pv ];
  try
      if ~isempty(range)
          try
              switch uData.source
                  case 'appliance', [uData.time, uData.value] = history(uData.pv, range{2});
                  case 'engine', [uData.time, uData.value] = aidaGetHistory(archivedPv, range{2},{'current'}, uData.interpStep);
              end
          catch title(sprintf('Failed to get data: %s',uData.pv)) , drawnow, return
          end
          for ll = 3:length(range)
              try
                  switch uData.source
                      case 'appliance', [timeTmp, valueTmp] = history(uData.pv, range{ll});
                      case 'engine', [timeTmp, valueTmp] = aidaGetHistory(archivedPv, range{ll},{'current'}, uData.interpStep);
                  end
              catch
                  title(sprintf('Failed to get data: %s',uData.pv)) , drawnow, return
              end
              uData.time = horzcat(timeTmp, uData.time);
              uData.value = horzcat(valueTmp, uData.value);
          end
      else
          try
              switch uData.source
                  case 'appliance', [uData.time, uData.value] = history(uData.pv, timeRange);
                  case 'engine',[uData.time, uData.value] = aidaGetHistory(archivedPv, timeRange,{'current'}, uData.interpStep);
              end
          catch
              title(sprintf('Failed to get data: %s',uData.pv)) , drawnow,
              addPVtoRequestToArchive(uData);
              return
          end
      end
  catch  %Add to "To Be Archived" list
        % isArchived = length(archList(uData.pv));
      try
          addPVtoRequestToArchive(uData);
          return
      catch
          fprintf('%s Failed to write to /u1/%s/tools/ArchiveBrowser/toBeArchivedList/', datestr(now),lower(uData.accelerator));
      end
  end %if Archived

end %if getNewData
%%

if(uData.medFilt),
    uData.medFilt = uData.medFilt+10;
    uData.value = medfilt1(uData.value, uData.medFilt);
    uData.medFiltStr = ' (Median Filtered)';
else
    uData.medFiltStr = '';
end

if(uData.rmsFilt)
    uData.rmsFiltSize = 10;
    uData.value = rmsfilt1(uData.value, uData.rmsFiltSize);
    uData.medFiltStr = '  - RMS (data)';
    uData.rmsFilt = 0;
else
    uData.medFiltStr = '';
end

set(uData.figH,'UserData',uData);

%Plot
if (length(uData.value) < 10), markStr = 'o-'; else markStr = '-'; end
if plotAgain
    if uData.newLinePlot,
        lineH = plot(uData.time, uData.value,markStr);
        lineUsDat =  {uData.pv, []}; set(lineH,'UserData', lineUsDat, 'Tag', 'LinePlot');
    else
        set(lineH,'XData',uData.time,'YData',uData.value)
    end

end

set(uData.figH,'Color',[.6 .7 .7])
zoomHandle = zoom;  set(zoomHandle,'ActionPostCallback','plotHistoryMakeLabels');
plotHistoryMakeLabels;

if(strmatch('limitsScale',optStr))

    pvLim = [regexprep(uData.pv,{'CON','DES'},'ACT'), '.'];
    limitsPVs = {[pvLim,'HIHI']; %Alarm Upper Limit
                 [pvLim,'LOLO']; %Alarm Lower Limit
                 [pvLim,'HIGH']; %Warn Upper Limit
                 [pvLim,'LOW']};%Warn Lower Limit
    limits = lcaGet(limitsPVs)';
    lh = line([ uData.time(1); uData.time(end) ] * [1 1 1 1], [limits; limits] );
    set(lh(1:2),'Color','r');
    set(lh(3:4),'Color','y');
end
set(uData.figH,'UserData',uData);
end
%%
function  addPVtoRequestToArchive(uData)
archivedPv = uData.pv;
unix(['echo ' [datestr(now), '  ', archivedPv] ' >> /u1/' lower(uData.accelerator) '/tools/ArchiveBrowser/toBeArchivedList']);
fprintf('Adding %s to "To Be Archived" list:\n', archivedPv)
title({['Added ' archivedPv];   'to "To Be Archived List" '} )
type(['/u1/'  lower(uData.accelerator) '/tools/ArchiveBrowser/toBeArchivedList']);
disp('End of /u1/lcls/tools/ArchiveBrowser/toBeArchivedList')
end
function timerStripTool(src,evt, lineH)
for lhs = 1:length(lineH)
    x = get(lineH(lhs),'XData');
    y = get(lineH(lhs),'YData');
    pv = get(lineH(lhs),'UserData');
    x = [x(2:end) now];
    y = [y(2:end) lcaGetSmart(pv{1})];
    set(lineH(lhs),'XData',x,'YData',y)
end
%axis auto
axesH = get(lineH(1),'Parent');
figH = get(axesH,'Parent');
zoomState = get(zoom(figH),'Enable');
if strcmp(zoomState, 'off')
    xLimit = get(axesH,'Xlim');
    xLimit= [x(1) x(end)]  + ( [-1 1] * diff(xLimit) * 0.05);
    set(axesH,'Xlim', xLimit);
    %datetick(axesH)
end
end

%% Correlation Coefficient & Polynomial Fit
% flag: [corrcoef polyfit]
function plotForms(answer, range, uData, flag)

figH = figure;
title('Getting data...'), drawnow

interpStep = 1; %aidaGetHistory interpolation step
if flag(1)
    timeRange = answer(3:4);
elseif flag(2)
    timeRange = answer(4:5);
else
    timeRange = uData.timeRange;
end
range = getRange(timeRange);

xaxisPv = char(answer(1));
yaxisPv = char(answer(2));

switch uData.accelerator
    case 'LCLS', aidaStr = 'HIST.lcls';
    case 'FACET', aidaStr = 'HIST.facet';
    otherwise, aidaStr = 'none';
end

archivedXPv = [xaxisPv,':',aidaStr ];
archivedYPv = [yaxisPv,':',aidaStr ];
isXArchived = length(aidalist(xaxisPv,aidaStr));
isYArchived = length(aidalist(yaxisPv,aidaStr));
if isXArchived && isYArchived
    if ~isempty(range)
        try
            switch uData.source
                  case 'appliance', [xTime, xValue] = history(uData.pv, range{2}, 'Operator', 'firstSample', 'Bin', 1);
                  case 'engine',[xTime, xValue] = aidaGetHistory(archivedXPv, range{2},{'current'}, interpStep);
            end
        catch title(sprintf('Failed to get data: %s', xaxisPv)) , drawnow, return
        end
        try
           switch uData.source
                  case 'appliance',  [yTime, yValue] = history(uData.pv, range{2},'Operator', 'firstSample', 'Bin', interpStep);
                  case 'engine', [yTime, yValue] = aidaGetHistory(archivedYPv, range{2},{'current'}, interpStep);
           end
        catch title(sprintf('Failed to get data: %s', yaxisPv)) , drawnow, return
        end
        for ll = 3:length(range)
            try
                switch uData.source
                  case 'appliance', [timeTmpX, valueTmpX] = history(uData.pv, range{ll},'Operator', 'firstSample', 'Bin', interpStep);
                  case 'engine',[timeTmpX, valueTmpX] = aidaGetHistory(archivedXPv, range{ll},{'current'}, interpStep);
                end
            catch title(sprintf('Failed to get data: %s', xaxisPv)) , drawnow, return
            end
            xTime = vertcat(timeTmpX, xTime);
            xValue = vertcat(valueTmpX, xValue);
            try
               switch uData.source
                  case 'appliance', [timeTmpY, valueTmpY] = history(uData.pv, range{ll},'Operator', 'firstSample', 'Bin', interpStep);
                  case 'engine', [timeTmpY, valueTmpY] = aidaGetHistory(archivedYPv, range{ll},{'current'}, interpStep);
               end
            catch title(sprintf('Failed to get data: %s', yaxisPv)) , drawnow, return
            end
            yTime = vertcat(timeTmpY, yTime);
            yValue = vertcat(valueTmpY, yValue);
        end
    else
        try
           switch uData.source
                  case 'appliance',  [xTime, xValue] = history(uData.pv, timeRange,'Operator', 'firstSample', 'Bin', interpStep);
                  case 'engine', [xTime, xValue] = aidaGetHistory(archivedXPv, timeRange,{'current'}, interpStep);
           end
        catch title(sprintf('Failed to get data: %s', xaxisPv)) , drawnow, return
        end
        try
           switch uData.source
                  case 'appliance', [yTime, yValue]= history(uData.pv, timeRange,'Operator', 'firstSample', 'Bin', interpStep);
                  case 'engine', [yTime, yValue] = aidaGetHistory(archivedYPv, timeRange,{'current'}, interpStep);
           end
        catch title(sprintf('Failed to get data: %s', yaxisPv)) , drawnow, return
        end
    end
else
    if ~isXArchived
        sprintf('Not in archive: %s', xaxisPv)
    end
    if ~isYArchived
        sprintf('Not in archive: %s', yaxisPv)
    end
end

% remove NaN values
yValue(isnan(xValue)) = [];  %remove x NaNs from y and then x
xValue(isnan(xValue)) = [];

xValue(isnan(yValue)) = []; %remove y NaNs from x and then y
yValue(isnan(yValue)) = [];
% Equalize 0 values between devices
for jj = 1:numel(xValue)
    if xValue(jj) == 0
        yValue(jj) = 0;
    end
    if yValue(jj) == 0
        xValue(jj) = 0;
    end
end
% Remove all 0 values
x = xValue(xValue ~= 0);
y = yValue(yValue ~= 0);

% Plot
markStr = '.';
plot(x, y, markStr);
set(figH,'Color',[.6 .7 .7])
titleStr = {timeRange{1}, timeRange{2}};
title({titleStr{1}, titleStr{2}}, 'interpreter', 'none');
try
    xaxisUnits = char(lcaGetUnits(xaxisPv));
    yaxisUnits = char(lcaGetUnits(yaxisPv));
catch
    xaxisUnits = '';
    yaxisUnits = '';
end

if flag(1)
    form = corrcoef(x,y);
    xStr = { xaxisPv, xaxisUnits, sprintf('Correlation Coefficient: %0.5g', form(2)) };
elseif flag(2)
    degree = str2num(answer{3});
    form = polyfit(x,y,degree);
    formStr = '';
    for ii = 1:numel(form)
        if ii ~= numel(form)
            if form(ii+1) > 0
                formStr = strcat( formStr, sprintf('%0.4gX^%d +  ', form(ii), degree+1-ii) );
            else
                formStr = strcat( formStr, sprintf('%0.4gX^%d', form(ii), degree+1-ii) );
            end
        else
            formStr = strcat( formStr, sprintf('%0.4g', form(ii)) );
        end
    end

    xStr = { xaxisPv, xaxisUnits, '', sprintf('Degree: %0.5g', degree), ...
                sprintf('Coefficients: '), sprintf('%0.4d  ', form), ...
                sprintf('Coefficients for: '), formStr };

    Y = polyval(form, x);
    plot(x,y,markStr,x,Y,':');
    title({titleStr{1}, titleStr{2}}, 'interpreter', 'none');
else
    form = [];
    xStr = { xaxisPv, xaxisUnits };
end

xlabel(xStr);
yStr = { yaxisPv, yaxisUnits };
ylabel(yStr);

end

%% Math Plot Functions
function math(answer, uData)
numPvs = 4; %Set the number of devices that can be used

figH = figure;
dcm_obj = datacursormode(figH);
set(dcm_obj, 'UpdateFcn',@dataCursorShowTime)
title('Getting data...'), drawnow

interpStep = 1; %aidaGetHistory interpolation step
timeRange = answer(1:2);
range = getRange(timeRange);
formula = answer{3};
pvNames = cell(1,numPvs);
for ii = 1:numPvs
    pvNames{ii} = char(answer(ii+3));
end

switch uData.accelerator
    case 'LCLS', aidaStr = 'HIST.lcls';
    case 'FACET', aidaStr = 'HIST.facet';
    otherwise, aidaStr = 'none';
end

archivedPvs = cell(1,numPvs);
isArchived = cell(1,numPvs);
for ii = 1:numel(pvNames)
    archivedPvs{ii} = [pvNames{ii}, ':', aidaStr ];
    isArchived{ii} = length( aidalist(pvNames{ii},aidaStr) );
end
time = cell(1,numPvs);
value = cell(1,numPvs);
for ii = 1:numel(isArchived)
    if isArchived{ii}
        if ~isempty(range)
            try
                switch uData.source
                  case 'appliance', [time{ii}, value{ii}] = history(uData.pv, range{2},'Operator', 'firstSample', 'Bin', interpStep);
                  case 'engine',[time{ii}, value{ii}] = aidaGetHistory(archivedPvs{ii}, range{2},{'current'}, interpStep);
                end
            catch title(sprintf('Failed to get data: %s', pvNames{ii})) , drawnow, return
            end
            for ll = 3:length(range)
                try
                  switch uData.source
                  case 'appliance',  [timeTmp, valueTmp] = history(uData.pv, range{ll},'Operator', 'firstSample', 'Bin', interpStep);
                  case 'engine',  [timeTmp, valueTmp] = aidaGetHistory(archivedPvs{ii}, range{ll},{'current'}, interpStep);
                  end
                catch title(sprintf('Failed to get data: %s', pvNames{ii})) , drawnow, return
                end
                time{ii} = vertcat(timeTmp, time{ii});
                value{ii} = vertcat(valueTmp, value{ii});
            end
        else
            try
               switch uData.source
                  case 'appliance',  [time{ii}, value{ii}]  = history(uData.pv, timeRange,'Operator', 'firstSample', 'Bin', interpStep);
                  case 'engine', [time{ii}, value{ii}] = aidaGetHistory(archivedPvs{ii}, timeRange,{'current'}, interpStep);
               end
            catch title(sprintf('Failed to get data: %s', pvNames{ii})) , drawnow, return
            end
        end
    else
        sprintf('Not in archive: %s', pvNames{ii})
    end
end

% Converts NaN values to 0
for ii = 1:numel(value)
    v = value{ii};
    v(isnan(v)) = 0;
    value{ii} = v;
end
time = time{1};


badI = find(time == 0);
time(badI) = [];
if isArchived{1}, a = value{1}; a(badI) = []; end
if isArchived{2}, b = value{2}; b(badI) = [];end
if isArchived{3}, c = value{3}; c(badI) = []; end
if isArchived{4}, d = value{4}; d(badI) = []; end
newValues = eval(lower(formula));

% Plot
if (length(uData.value) < 10), markStr = 'o-'; else markStr = '-'; end
plot(time, newValues, markStr);
set(figH,'Color',[.6 .7 .7])
datetick('keeplimits');

titleStr = { formula };
title( titleStr, 'interpreter', 'none');

for ii = 1:numel(pvNames)
    if isArchived{ii}
        yaxisUnits = char(lcaGetUnits(pvNames{ii}));
        break
    end
end
yStr = { yaxisUnits };
ylabel(yStr);

% Modify when changing number devices
aStr = ['A = ' pvNames{1}];
bStr = ['B = ' pvNames{2}];
cStr = ['C = ' pvNames{3}];
dStr = ['D = ' pvNames{4}];
xStr = { sprintf('%s      %s', timeRange{1}, timeRange{2}), ...
         sprintf('%s      %s', aStr, bStr), ...
         sprintf('%s      %s', cStr, dStr) };
xlabel(xStr);

end

%% timeRange function
function [timeRange,range] = getTimeRange(timeString,uData)
range = [];
switch timeString
  case uData.timeStr
    timeRangeIndx = strmatch(timeString, uData.timeStr, 'exact');
    theEnd = now  ;
    theStartV = theEnd - [ 2/24, 4/24, 8/24, 12/24, 1, 2, 3, 4, 7, 14, 21, 28, 56];
    timeRangeIndx = strmatch(timeString, uData.timeStr, 'exact');
    if (~isempty(timeRangeIndx)),
        theStart = theStartV(timeRangeIndx);
        timeRange = {[datestr(theStart,23),' ',datestr(theStart,13)], ...
                      [datestr(theEnd,23), ' ',datestr(theEnd,13)]};
        range = getRange(timeRange,uData.source);
    end

  case {'UseTimeRange', 'medianFilter', 'limitsScale', 'ignoreFlyer', 'multiPlot', 'stripTool', ...
          'corrcoef', 'polyfit', 'math', 'rmsFilter'}
    timeRange = uData.timeRange;
    range = getRange(timeRange, uData.source);

  case {'stepLeft','stepRight','stepLDay','stepRDay'}
    timeRangeDN = datenum(uData.timeRange);
    switch timeString
        case 'stepLeft',  timeRangeDN = timeRangeDN - diff(timeRangeDN);
        case 'stepRight', timeRangeDN = timeRangeDN + diff(timeRangeDN);
        case 'stepLDay',  timeRangeDN = timeRangeDN - 1;
        case 'stepRDay',  timeRangeDN = timeRangeDN + 1;
    end
    theEnd = timeRangeDN(2); theStart = timeRangeDN(1);
    timeRange = {[datestr(theStart,23),' ',datestr(theStart,13)], ...
                  [datestr(theEnd,23), ' ',datestr(theEnd,13)]};
    range = getRange(timeRange, uData.source);

  case 'userRange'
    timeRange =  inputdlg({'Start Time','End Time'},'Enter Time Range', ...
                 1, uData.timeRange);
    if(isempty(timeRange)), fprintf('Time Range not specified; ending...\n'); end
    range = getRange(timeRange, uData.source);
end

end

%% getRange function
% Splits up the time range into chunks to prevent failed aidaGetHistory
% calls.  3/11 If server is appliance range returns timeRange
function range = getRange(timeRange, source)
    if strmatch(source, 'appliance'), range = []; return, end
    chunk = 1; %ie. 1=take timeRange in 1 day chunks
    theStart = datenum(timeRange(1));
    theEnd = datenum(timeRange(2));
    if (theEnd-theStart) > chunk %greater than 1 day
        range{1} = timeRange;
        lastStart = theStart; %hold the original start position
        theStart = theEnd - chunk; % minus 1 day from theEnd
        ii = 2;

        while theStart > lastStart
            % get the time range of 1 day span / store in array
            range{ii} = {[datestr(theStart,23),' ',datestr(theStart,13)], ...
                          [datestr(theEnd,23), ' ',datestr(theEnd,13)]}; %#ok<AGROW>
            % minus 1 day from start and end
            theEnd = theStart;
            theStart = theEnd - chunk;
            ii = ii+1;
        end
        range{ii} = {[datestr(lastStart,23),' ',datestr(lastStart,13)], ...
                      [datestr(theEnd,23), ' ',datestr(theEnd,13)]};
    else
        range = [];
    end
end

%% multiPlot function
function uData = multiPlot(pvList,timeRange,uData,range)
figH = uData.figH;
dcm_obj = datacursormode(figH);
set(dcm_obj, 'UpdateFcn',@dataCursorShowTime);

len = length(pvList);
max = 6; % max # of plots on 1 graph

% Create wait bar
bar = waitbar(0,'Retrieving History...',...
    'CreateCancelBtn',...
    'setappdata(gcbf,''canceling'',1)');
setappdata(bar,'canceling',0);
for ii = 1:len
    if ii>max, break; end
    % Check cancel button press
    if getappdata(bar,'canceling')
        break
    end

    pvName = char(pvList(ii));

    if uData.getNewData
    switch uData.accelerator
        case 'LCLS', aidaStr = 'HIST.lcls';
        case 'FACET', aidaStr = 'HIST.facet';
        otherwise, aidaStr = 'none';
    end
    archivedPv = [pvName,':',aidaStr ];
    isArchived = length(aidalist(pvName,aidaStr));
    if isArchived
        if ~isempty(range)
            try
               switch uData.source
                  case 'appliance',  [uData.time, uData.value]  = history(uData.pv, range{2},'Operator', 'firstSample', 'Bin', uData.interpStep);
                  case 'engine', [uData.time, uData.value] = aidaGetHistory(archivedPv, range{2},{'current'}, uData.interpStep);
               end
            catch title(sprintf('Failed to get data: %s',uData.pv)) , drawnow, return
            end
            for ll = 3:length(range)
                try
                   switch uData.source
                  case 'appliance', [timeTmp, valueTmp] = history(uData.pv, range{ll},'Operator', 'firstSample', 'Bin', uData.interpStep);
                  case 'engine', [timeTmp, valueTmp] = aidaGetHistory(archivedPv, range{ll},{'current'}, uData.interpStep);
                   end
                catch title(sprintf('Failed to get data: %s',uData.pv)) , drawnow, return
                end
                uData.time = vertcat(timeTmp, uData.time);
                uData.value = vertcat(valueTmp, uData.value);
            end
        else
            try
               switch uData.source
                  case 'appliance', [uData.time, uData.value]   = history(uData.pv, timeRange,'Operator', 'firstSample', 'Bin', uData.interpStep);
                  case 'engine', [uData.time, uData.value] = aidaGetHistory(archivedPv, timeRange,{'current'}, uData.interpStep);
               end
            catch title(sprintf('Failed to get data: %s',uData.pv)) , drawnow, delete(bar); return
            end
        end
    else  %Add to "To Be Archived" list
        try
            unix(['echo ' [datestr(now), '  ', archivedPv] ' >> /u1/' lower(uData.accelerator) '/tools/ArchiveBrowser/toBeArchivedList']);
            fprintf('Adding %s to "To Be Archived" list:\n', archivedPv)
            title({['Added ' archivedPv];   'to "To Be Archived List" '} )
            type(['/u1/'  lower(uData.accelerator) '/tools/ArchiveBrowser/toBeArchivedList']);
            disp('End of /u1/lcls/tools/ArchiveBrowser/toBeArchivedList')
            delete(bar);
            return
        catch
            fprintf('%s Failed to write to /u1/%s/tools/ArchiveBrowser/toBeArchivedList/', datestr(now),lower(uData.accelerator));
        end
    end %if Archived
    end

    try % if uData.value is cell
        if uData.ignoreFlyer
            removeIndx = [find(( uData.value{ii} > mean(uData.value{ii}) + 3 * std(uData.value{ii}))), ...
                find(( uData.value{ii} < mean(uData.value{ii}) - 3 * std(uData.value{ii})))];
            v = uData.value{ii};
            v(removeIndx) = [];
            uData.value{ii} = v;
            t = uData.time{ii};
            t(removeIndx) = [];
            uData.time{ii} = t;
        end
        % median filter
        if(uData.medFilt), uData.value{ii} = medfilt1(uData.value{ii},5);uData.medFiltStr = ' (Median Filtered)';
        else uData.medFiltStr = ''; end

        time{ii} = uData.time{ii};
        value{ii} = uData.value{ii};
    catch %if uData.value is double
        %median filter
        if(uData.medFilt), uData.value = medfilt1(uData.value,5);uData.medFiltStr = ' (Median Filtered)';
        else uData.medFiltStr = ''; end

        time{ii} = uData.time;
        value{ii} = uData.value;
    end
    if len < max, waitbar(ii/len); else waitbar(ii/max); end
end
delete(bar);

%Plot
% cla; % clear current axis (properly redraw plot for Time Range)
color = {'b','g','r','c','m','k'};
hold on
plotMax = max;
tt = 1;
tmp = 1;
skip = 0;

for jj = 1:len
    if jj>plotMax,
        % legend
        legend(pvList(tmp:jj-1), 'FontSize',10);
        tmp = jj;
        % title
        titleStr = [ sprintf('%s ', pvTitle{:}) uData.medFiltStr];
        indxRange = [1:75:length(titleStr) length(titleStr)];
        for ss = 1:length(indxRange)-1
            titleStr1(ss) = {titleStr(indxRange(ss):indxRange(ss+1))};
        end
        title(titleStr1,'interpreter','none','FontSize',10)
        % ylabel
        datetick('keeplimits');
        try epicsDesc = lcaGet([pvList(jj),'.DESC']);
        catch epicsDesc = {' '}; end
        try epicsUnits = char(lcaGetUnits(pvList(jj)));
        catch epicsUnits = ' '; end
        ylabel([epicsDesc,  epicsUnits])
        set(figH,'Color',[.6 .7 .7])

        clear pvTitle;
        hold off;

        plotHistory(pvList(jj:end),timeRange, [0 0 1]);
        uData.pv = pvList(1:jj-1);
        skip = 1;
        break;
    end

    if (length(value{jj}) < 10), markStr = 'o-'; else markStr = '-'; end
    num = mod(jj,max);
    if num==0, num=max; end
    lineType = strcat(char(color(num)), markStr);
    lineH = findobj(uData.figH,'Type','line', 'Tag','LinePlot');
    if (isempty(lineH) || (length(uData.pv) > length(lineH) ))
        lineH = plot(time{jj}, value{jj}, lineType);
        lineUsDat =  {uData.pv(jj), []};
        set(lineH,'UserData', lineUsDat, 'Tag', 'LinePlot');
    else
        for lineHndls = 1:length(lineH)
            thisUsDat = get(lineH(lineHndls), 'UserData');
            if strcmp(thisUsDat{1}{1}, uData.pv{jj}), theLineH = lineH(lineHndls); break; end
        end
        %fprintf('\n%s \n%s \n', uData.pv{jj}, thisUsDat{1}{1})
        set(theLineH,'XData', time{jj}, 'YData', value{jj})
        if ~strcmp(uData.pv{jj}, thisUsDat{1}{1}), fprintf('Errror: PVs and Labels are not consistent'); end
        axis auto
        datetick
        %
    end


    pvTitle{tt} = char(pvList(jj));
    tt = tt+1;
    if tt>max, tt=1; end
    % xlabel
    try
        handleAxes = findobj(figH,'Type','Axes');
        if length(handleAxes) > 1, xLimit = get(handleAxes(2),'Xlim');
        else xLimit = get(handleAxes,'Xlim'); end
        str = {datestr(xLimit,23) datestr(xLimit,15)};
        xStr = { sprintf('%s %s', str{1}(1,:), str{2}(1,:) ) , ...
            sprintf('%s %s', str{1}(2,:), str{2}(2,:) )};
        xlabel(xStr)
    catch
    end
end

if ~skip
    % legend
    legend(pvList(tmp:jj), 'FontSize',10);
    % title
    titleStr = sprintf('%s ', pvTitle{:});
    titleStr = [ titleStr uData.medFiltStr];
    title(titleStr,'interpreter','none', 'FontSize',10)
    % ylabel
    datetick('keeplimits');
    try epicsDesc = lcaGet([char(pvList(jj)),'.DESC']);
    catch epicsDesc = {' '}; end
    try epicsUnits = char(lcaGetUnits(pvList(jj)));
    catch epicsUnits = ' '; end
    ylabel([epicsDesc,  epicsUnits])
    %
    hold off
    set(figH,'Color',[.6 .7 .7])
end

% plot limits scale
if uData.limScale == 1
    if ~ischar(uData.pv(1))
       for kk = 1:length(uData.pv)
          pvStr{kk} = char(uData.pv(kk));
       end
    else
        pvStr{1} = uData.pv;
    end
    for kk = 1:length(pvStr)
        pvLim = [regexprep(char(pvStr(kk)),{'CON','DES'},'ACT'), '.'];
        limitsPVs = {[pvLim,'HIHI']; %Alarm Upper Limit
                     [pvLim,'LOLO']; %Alarm Lower Limit
                     [pvLim,'HIGH']; %Warn Upper Limit
                     [pvLim,'LOW']};%Warn Lower Limit
        limits = lcaGet(limitsPVs)';
        try
            lh = line([ uData.time(1); uData.time(end) ] * [1 1 1 1], [limits; limits] );
        catch
            t = uData.time{kk};
            lh = line([ t(1); t(end) ] * [1 1 1 1], [limits; limits] );
        end
        set(lh(1:2),'Color','r');
        set(lh(3:4),'Color','y');
    end
end
uData.time = time;
uData.value = value;
set(uData.figH,'UserData',uData);
end

