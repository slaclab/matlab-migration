function [name, val] = plotz(prim, secn, region, varargin)
%PLOTZ
% [NAME, VAL] = PLOTZ(PRIM, SECN, REGION, OPTS) Z-plot facility for
% modelled devices, other devices will appear at z=0. Finds all PVs with
% primaries PRIM in regions REGION, e.g. {'L2' 'L3'} and obtains value of
% secondary SECN ans then creates stem plot. Both PRIM and SECN can be
% multiple items, different SECNs are plotted with different colors.
% 
% Features:
% 
% Input arguments:
%    PRIM:   Char or cellstr (array) of primary names, e.g. 'QUAD'
%    SECN:   Char or cellstr (array) of secondary tags, e.g. 'BDES'
%    REGION: Optional parameter for accelerator areas, default 'FULL', 
%    e.g. 'L2','L3','FULL'
%    OPTS:   Options
%            DELAY: Default 0, plot once, if > 0, plot in loop with this delay
%            HISTORY: Default 10, saves data from the past number of
%            iterations, e.g. 'delay',1,'history',10
%            saves data from the last 10 seconds
% 
% Output arguments:
%    NAME: List of names found
%    VAL:  List of values plotted
% 
% Example function calls:
% plotz('BPMS','X1H', 'L3')
% plotz('VPIO','P','FULL','delay',1,'history',100) 
% 
% Compatibility: Version 7 and higher
% Called functions: util_parseOptions, model_nameRegion, model_rMatGet, lca*

% Author: Henrik Loos, SLAC
% Modified: Phillip Gribnau, August 2011

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'delay',0, ...
    'history',10 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

if nargin < 3, region=[];end
if strcmp(region,'FULL'), region=[];end
[name,id,isSLC]=model_nameRegion(prim,region);
name(isSLC) = []; %Remove isSLC devices
secn=cellstr(secn);
if(isempty(name))
    pv = meme_names('name',[prim, '%', secn{:}]);
    z = 1:length(pv);
else
    pv=cell(numel(name),numel(secn));
    for j=1:numel(secn), pv(:,j)=strcat(name,':',secn(j));end
    z=model_rMatGet(name,[],[],'Z');

end

egu='';
if ~all(isSLC)
    egu=lcaGetSmart([strtok(pv{1},'.') '.EGU']);
end

%lcaSetSeverityWarnLevel(4);
[val,ts]=lcaGetSmart(pv(:));
h = figure('Name',['ZPlot: ' prim ' ' char(secn) ' ' region],'NumberTitle','off');
set(0,'CurrentFigure',h);
%if z(length(z)) > 0
    if ~isempty(name)
    stem(z,reshape(val,[],numel(secn)),'.','MarkerEdgeColor','r','MarkerSize',15);
    xlabel('Z Position  (m)');
    uData.cursorType = 'modelled';
else
    stem(reshape(val,[],numel(secn)),'.','MarkerEdgeColor','r','MarkerSize',15);
    xlabel('Ordinal Position');
    uData.cursorType = 'unmodelled';
end

% x,y axis labels
% xlabel('z Position  (m)');
ylabel(strcat(secn,'  (',egu,')'));
% title
prim=cellstr(prim);
tStr=['Z-Plot ' sprintf('%s ',prim{:})];
title([tStr datestr(lca2matlabTime(ts(1)))]);

% Customize datacursor
dcm_obj = datacursormode();
set(dcm_obj,'UpdateFcn',@dataCursorShowTime);

% Setup Menu
[sys,accelerator] = getSystem;
uData.accelerator = accelerator;
menu = uimenu('Label', 'Options', 'Tag','plotOptions');
uData.optList = {'startUpdate','stopUpdate','linearScale','logScale','pvValues', ...
    'plotHistory','difference','single','printOpsLog','printLcls','math'};
optListLabel = {'Start Update','Stop Update','Linear Scale','Log Scale', ...
    'Current PV Values','Recent Plot History','ZPlot Difference','Single PV History',...
    'Print Ops Log', ['Print ',upper(accelerator),' Log'], 'Math'};
for i = 1:length(uData.optList)
    if i==3 || i==5 || i==9,
        uimenu(menu,'Label', optListLabel{i}, 'Callback', { @plotIt , uData.optList{i} }, 'Separator', 'on');
%     elseif opts.delay==0 && (i==1 || i==2 || i==6),
%         uimenu(menu,'Label', optListLabel{i}, 'Callback', { @plotIt , uData.optList{i} }, 'Enable', 'off');
    else
        uimenu(menu,'Label', optListLabel{i}, 'Callback', { @plotIt , uData.optList{i} });
    end    
end

size = length(val);
max = opts.history; %max size of iterations saved
new = 1; %ptr to newest value added in history
% valArray = zeros(size,1);
% valArray(:,1) = val;
timeArray = cell(1,1);
timeArray{1} = datestr(lca2matlabTime(ts(1)));

uData.log = 0;
uData.delay = opts.delay;
uData.new = new;
uData.timeArray = timeArray;
uData.egu = egu;
uData.secn = secn;
uData.prim = prim;
uData.z = z;
uData.valArray = val;
uData.pv = pv;
uData.stop = 0;
uData.figH = gcf;
% 
uData.pv = pv;
uData.tStr = tStr;
uData.max = max;
uData.size = size;
% 
set(uData.figH,'UserData',uData);

end

% Creates figure window without needing focus
function h = sfigure(h)
if nargin>=1
    if ishandle(h)
        set(0, 'CurrentFigure', h);
    else
        h = figure(h);
    end
else
    h = figure;
end
end


function txt = dataCursorShowTime(empt,event_obj)
uData = get(gcf,'UserData');
pos = get(event_obj,'Position');
switch uData.cursorType
    case 'modelled'
        index = find(uData.z==pos(1));
        txt = {uData.pv{index}, ['X= ',num2str(pos(1))],...
            ['Y= ',num2str(pos(2))]};
    case 'unmodelled'
        txt = {uData.pv{pos(1)}, ['X= ',num2str(pos(1))],...
            ['Y= ',num2str(pos(2))]};
    case 'pv' % x-axis shows pv names
        txt = {['PV= ',uData.cursorInfo{pos(1)}],...
            ['Val= ',num2str(pos(2))]};
    case 'time' % x-axis shows time
        txt = {['Time= ',datestr(uData.cursorInfo(pos(1)))],...
            ['Val= ',num2str(pos(2))]};
end
end

function updatePlot()
uData = get(gcf,'UserData');
valArray = zeros(uData.size,1);
timeArray = uData.timeArray;

while uData.delay
    % Correctly closes plot window while updating
    try 
        fig = get(uData.figH);
        sfigure(uData.figH);
        uData = get(gcf,'UserData');
    catch
        fprintf('Plot Closed\n');
        break
    end

    if( (isempty(uData) == 0) && uData.stop == 0),
        [val,ts]=lcaGetSmart(uData.pv(:));
        if uData.z(length(uData.z)) > 0
            stem(uData.z,reshape(val,[],numel(uData.secn)),'.','MarkerEdgeColor','r','MarkerSize',15);
            if uData.log > 0
                plotScale('log');
            end
            xlabel('Z Position  (m)');
        else
            stem(reshape(val,[],numel(uData.secn)),'.','MarkerEdgeColor','r','MarkerSize',15);
            if uData.log > 0
                plotScale('log');
            end
            xlabel('Ordinal Position');
        end
        ylabel(strcat(uData.secn,'  (',uData.egu,')'));
        title([uData.tStr datestr(lca2matlabTime(ts(1)))]);
      
        % Recent history update
        new = uData.new+1;
        if new > uData.max, new=1; end
        valArray(:,new) = val;
        timeArray{new} = datestr(lca2matlabTime(ts(1)));
        uData.valArray = valArray;
        uData.timeArray = timeArray;
        uData.new = new;
        uData.figH = gcf;
        set(uData.figH,'UserData',uData);
        
        pause(uData.delay);
        drawnow;
    else
        break;
    end  
end

return
end

% plotIt function
function plotIt(src,evt,optStr) %
uData = get(gcf,'UserData');

% Print Log
if strcmp(optStr, 'printLcls'), 
    util_printLog(uData.figH);
    return, 
end

% Print Ops Log
if strcmp(optStr, 'printOpsLog'), 
    print(gcf, '-dpsc2', '-Pelog_mcc'),  
    return, 
end

% Set Y-axis linear scale
if strcmp(optStr, 'linearScale'),
    fprintf('Plot Linear Scale\n');
    plotScale('linear');
    uData.log = 0;
    uData.figH = gcf;
    set(uData.figH,'UserData',uData);
    return,
end

% Set Y-axis log scale
if strcmp(optStr, 'logScale'),
    fprintf('Plot Log Scale\n');
    plotScale('log');
    uData.log = 1;
    uData.figH = gcf;
    set(uData.figH,'UserData',uData);
    return,
end

% Print table of  current pv values
if strcmp(optStr, 'pvValues'),
    fprintf('PV Values\n');
    new = uData.new;
    z = uData.z;
    v = uData.valArray(:,new);
    timeArray = uData.timeArray;
    time = char(timeArray(new));
    colnames = {'PV','Z Position  (m)'};
    colnames{3} = time;
    for jj = 1:numel(z)
        p = char(uData.pv(jj));
        if z(length(z)) > 0
            zPrec = z(jj);
        else
            zPrec = sprintf('%.0f',jj);
        end
        vPrec = v(jj);
        data(jj,:) = {p zPrec vPrec};
    end
    width = 650;
    height = 700;
    f = figure('Position', [100 100 width height],'Name',['Current PV Values:' time],...
        'NumberTitle', 'off');
    table = uitable(f, data, colnames, 'ColumnWidth', 200, 'Position', [0 0 width height]);
    return,
end

% Start updating plot
if strcmp(optStr, 'startUpdate'),
    fprintf('Update Started\n');
    prompt={'Delay (in seconds)'};
    name='Delay Time';
    numlines=1;
    % Get delay time
    defaultanswer={'1'};
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='none';
    answer=inputdlg(prompt,name,numlines,defaultanswer,options);
    uData.delay = str2double(answer(1));

    uData.stop = 0;
    uData.figH = gcf;
    set(uData.figH,'UserData',uData);
    updatePlot();
    return,
end

% Stop updating plot
if strcmp(optStr, 'stopUpdate'),
    fprintf('Update Stopped\n');
    uData.stop = 1;
    uData.figH = gcf;
    set(uData.figH,'UserData',uData);
    return,
end

% Plot History
if strcmp(optStr, 'plotHistory'),
    fprintf('Plot History\n');
    recentHist();
    return,
end

% Difference to Point in Time
if strcmp(optStr, 'difference'),
    fprintf('Difference\n'); 
    difference();
    return,
end

% Single PV History
if strcmp(optStr, 'single'),
    fprintf('Single PV History\n');
    singleHistory(); 
    return,
end

% Math Plot Function
if strcmp(optStr, 'math'),
    fprintf('Math Function\n');
    math(); 
    return,
end

end

% Change Plots Y-Scale
% TYPE: 'linear' or 'log'
function plotScale(type)
    if(strcmp(type,'log') || strcmp(type,'linear')) == 0
        return
    end
    ax = axis;
    set (gca, 'yscale', type)
    set (gca, 'XAxisLocation', 'bottom' );
    axis (ax);
    k = get(gca, 'children');
    l = get(k(2), 'children');
    ydatazeros = get(l(1), 'ydata');
    if strcmp(type,'log')
        ydataones = ydatazeros;
        ydataones(ydatazeros == 0) = 1;
        set(l(1),'ydata',ydataones);
    else
        set(l(1),'ydata',ydatazeros);
    end
return
end

% 
function recentHist()
    uData = get(gcf,'UserData');
    z = uData.z;
    valArray = uData.valArray;
    timeArray = uData.timeArray;
    new = uData.new;
    % get column names
    colnames = {'PV','Z Position  (m)'};
    for ii = 3:(length(timeArray) + 2)
       time = char(timeArray(new));
       colnames{ii} = time;
       if new-1<1, new=length(timeArray);
       else new = new-1;
       end
    end
    % get data values
    new = uData.new;
    for jj = 1:numel(z)
        p = char(uData.pv(jj));
        if z(length(z)) > 0
            zPrec = z(jj);
        else
            zPrec = sprintf('%.0f',jj);
        end
        data(jj,1) = {p};
        data(jj,2) = {zPrec};
        for kk = 3:(length(timeArray)+2)
            vPrec = valArray(jj,new);
            data(jj,kk) = { vPrec };
            if new-1<1, new=length(timeArray);
            else new = new-1;
            end
        end
    end
    width = 1050;
    height = 700;
    f = figure('Position', [100 100 width height]);
    table = uitable(f, data, colnames, 'ColumnWidth', 200, 'Position', [0 0 width height]); %[ x-pos y-pos width height]
return
end

% Difference to a Point in Time Function
function difference() %
    uData = get(gcf,'UserData');    
    prompt={'Time: (mm/dd/yyyy hh:mm:ss)',...
        'Reference Time: (mm/dd/yyyy hh:mm:ss)'};
    name='Start Time Values - Reference Time Values';
    numlines=1;

    % Get recent date
    timeVec = datevec(uData.timeArray{uData.new});
    timeNum = formatTime(timeVec);
    timeStr1 = [ timeNum{2}, '/', timeNum{3}, '/', timeNum{1}, ' 00:00:00'];
    timeStr2 = [ timeNum{2}, '/', timeNum{3}, '/', timeNum{1}, ' ', timeNum{4}, ':',...
        timeNum{5}, ':', timeNum{6} ];
    defaultanswer={timeStr1,timeStr2};
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='none';
    answer=inputdlg(prompt,name,numlines,defaultanswer,options);

    str1 = char(answer{1});
    if( str1(length(str1)) == '9' )
        str1(length(str1)) = '8';
        timeRange1 = {str1;answer{1}};
        swap1 = 1;
    else
        str1(length(str1)) = '9';
        timeRange1 = {answer{1};str1};
        swap1 = 0;
    end
    str2 = char(answer{2});
    if( str2(length(str2)) == '9' )
        str2(length(str2)) = '8';
        timeRange2 = {str2;answer{2}};
        swap2 = 1;
    else
        str2(length(str2)) = '9';
        timeRange2 = {answer{2};str2};
        swap2 = 0;
    end
    % Create wait bar
    b = waitbar(0,'Retrieving History...',...
        'CreateCancelBtn',...
        'setappdata(gcbf,''canceling'',1)');
    setappdata(b,'canceling',0);

    histArray = zeros(numel(uData.pv),4);
    diff = zeros(numel(uData.pv),1);
    for ii = 1:numel(uData.pv)
        % Check cancel button press
        if getappdata(b,'canceling')
            break
        end
        %aidaName = strcat(uData.pv(ii),'//HIST.lcls');
        aidaName = uData.pv(ii); %3/2014 change from AIDA to appliance calls.
        try
            [time1, value1] = history(aidaName, timeRange1);
            [time2, value2] = history(aidaName, timeRange2);
        catch
            errordlg('Failed to retrieve history','Error'); 
            delete(b);
            return
        end
        
        if(isempty(time1) || isempty(time2)) %value output in plot is 0
            continue
        end
        if swap1 == 0
            startTime = time1(1);
            startVal = value1(1);
        else
            len = length(time1);
            startTime = time1(len);
            startVal = value1(len); 
        end
        histArray(ii,1) = startTime;
        histArray(ii,2) = startVal;
        if swap2 == 0
            endTime = time2(1);
            endVal = value2(1);
        else
            len = length(time2);
            endTime = time2(len);
            endVal = value2(len); 
        end
        histArray(ii,3) = endTime;
        histArray(ii,4) = endVal;
        
        diff(ii,1) = (startVal - endVal);
        waitbar(ii/numel(uData.pv));
    end
    delete(b);

    range = [char(answer(1)) ' minus ' char(answer(2))];
    h = figure('Name',['ZPlot Difference: ' range],'NumberTitle','off');
    set(0,'CurrentFigure',h)
    stem(reshape(diff,[],1),'.','MarkerEdgeColor','r','MarkerSize',15);
    % x,y axis labels
    xlabel('Zplot PV''s');
    ylabel(strcat('Difference  (',uData.egu,')'));
    % title
    tStr=range;
    title(tStr);
    changeCursor('pv',uData.pv);
    return,
end

% Get Single PV History Function
function singleHistory() %
    uData = get(gcf,'UserData');    
    prompt={'Name of an AIDA acquireable history variable:',...
        'Start Time: (mm/dd/yyyy hh:mm:ss)',...
        'End Time: (mm/dd/yyyy hh:mm:ss)'};
    name='Single PV History';
    numlines=1;

    % Get recent date
    timeVec = datevec(uData.timeArray{uData.new});
    timeNum = formatTime(timeVec);
    time1 = [ timeNum{2}, '/', timeNum{3}, '/', timeNum{1}, ' 00:00:00'];
    time2 = [ timeNum{2}, '/', timeNum{3}, '/', timeNum{1}, ' ', timeNum{4}, ':',...
        timeNum{5}, ':', timeNum{6} ];
    defaultanswer={uData.pv{1},time1,time2};
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='none';
    answer=inputdlg(prompt,name,numlines,defaultanswer,options);
    %aidaName = strcat(answer(1),'//HIST.lcls');
    aidaName = strcat(answer(1)); % 3/2014 (colocho) change from aida to appliance call.
    timeRange = {answer(2);answer(3)};
    
    b = msgbox('Retrieving History...'); % display message box until history is retrieved
    try
        [time, value] = history(aidaName, timeRange);
    catch
        errordlg('Failed to retrieve history','Input Error');
        delete(b);
        return
    end
    delete(b);
    
    range = [char(timeRange{1}) ' to ' char(timeRange{2})];
    h = figure('Name',[char(aidaName) ' : ' range],'NumberTitle','off');
    set(0,'CurrentFigure',h);
    stem(reshape(value,[],1),'.','MarkerEdgeColor','r','MarkerSize',15);
    % x,y axis labels
    xlabel(range);
    ylabel(strcat(uData.secn,'  (',uData.egu,')'));
    % title
    tStr=['Z-Plot: ' char(answer(1))];
    title(tStr);
    changeCursor('time',time);   
    return,
end

% Customize data cursor
% cursorType e.g: 'main','pv','time'
function changeCursor(cursorType,cursorInfo)  
    uData.stop = 1;
    uData.cursorType = cursorType;
    uData.cursorInfo = cursorInfo;
    uData.figH = gcf;
    set(uData.figH,'UserData',uData)
    % Customize datacursor
    dcm_obj = datacursormode();
    set(dcm_obj,'UpdateFcn',@dataCursorShowTime)
    return,
end

%
function timeNum = formatTime(timeVec)
    for ii = 1:numel(timeVec)
        if timeVec(ii) < 10
           timeNum{ii} = ['0',num2str(timeVec(ii))];
        else
           timeNum{ii} = num2str(timeVec(ii));
        end
    end
    return
end

% Math plot functions
function math() %
    uData = get(gcf,'UserData');    
    prompt={'Time: ''mm/dd/yyyy hh:mm:ss'' or ''now''',...
        'PRIM:', 'A = SECN 1:', 'B = SECN 2:', 'Formula: (ie. A+B)'};
    name='Formula';
    numlines=1;

    % Get recent date
    timeVec = datevec(uData.timeArray{uData.new});
    timeNum = formatTime(timeVec);
    timeStr1 = [ timeNum{2}, '/', timeNum{3}, '/', timeNum{1}, ' ', timeNum{4}, ':',...
        timeNum{5}, ':', timeNum{6} ];
    prim = uData.prim;
    secn1 = uData.secn;
    secn2 = '';
    form = '';
    defaultanswer={timeStr1,prim{1},secn1{1},secn2,form};
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='none';
    answer=inputdlg(prompt,name,numlines,defaultanswer,options);
    
    % PV Names
    [pv1,name1,egu1] = getNames(answer(2),answer(3));
    pv2 = getNames(answer(2),answer(4));
    if length(pv1) ~= length(pv2)
       errordlg('Matrix dimensions are not the same'); 
       return
    end
    
    % Time
    now = 0;
    if strcmpi('now',answer(1))
        [val1,ts1]=lcaGetSmart(pv1(:));
        date1 = datestr(lca2matlabTime(ts1(1)));
        [val2,ts2]=lcaGetSmart(pv2(:));
        now = 1;
    else
        date1 = char(answer(1));
        str1 = char(answer(1));
        if( str1(length(str1)) == '9' )
            str1(length(str1)) = '8';
            timeRange1 = {str1;answer(1)};
            swap1 = 1;
        else
            str1(length(str1)) = '9';
            timeRange1 = {answer(1);str1};
            swap1 = 0;
        end
    end
    
    % Create wait bar
    bar = waitbar(0,'Retrieving History...',...
        'CreateCancelBtn',...
        'setappdata(gcbf,''canceling'',1)');
    setappdata(bar,'canceling',0);

    newVal = zeros(numel(pv1),1);
    for ii = 1:numel(pv1) %%
        % Check cancel button press
        if getappdata(bar,'canceling')
            break
        end
        
        if now==0,
            aidaName1 = strcat(pv1(ii),'//HIST.lcls');
            aidaName2 = strcat(pv2(ii),'//HIST.lcls');
            try
                [time1, value1] = history(aidaName1, timeRange1);
                [time2, value2] = history(aidaName2, timeRange1);
            catch
                errordlg('Failed to retrieve history','Error');
                delete(bar);
                return
            end
            if(isempty(time1)) %value output in plot is 0
                continue
            end
            if swap1 == 0
                startVal1 = value1(1);
                startVal2 = value2(1);
            else
                len = length(time1);
                startVal1 = value1(len);
                len = length(time2);
                startVal2 = value2(len);
            end  
            a = startVal1;
            b = startVal2;
            newVal(ii,1) = eval(lower(answer{5}));
        else % now==1
            a = val1(ii);
            b = val2(ii);
            newVal(ii,1) = eval(lower(answer{5}));
        end

        waitbar(ii/numel(pv1));
    end
    delete(bar);

    range = [answer{5}];
    h = figure('Name',['Function: ' range],'NumberTitle','off');
    set(0,'CurrentFigure',h)
    stem(reshape(newVal,[],1),'.','MarkerEdgeColor','r','MarkerSize',15);
    % x,y axis labels
    xlabel('Zplot PV''s');
    ylabel(strcat('Result  (',egu1,')'));
    % title
    cStr = date1;
    vStr = ['PRIM=' answer{2} ' , A=' answer{3} ' , B=' answer{4}];
    tStr = {answer{5}, vStr, cStr};
    title(tStr);
    changeCursor('pv',name1);
    return,
end

function [pv,name, egu] = getNames(prim,secn)
    region=[];
    [name,id,isSLC]=model_nameRegion(prim,region);
    secn=cellstr(secn);
    pv=cell(numel(name),numel(secn));
    for j=1:numel(secn), pv(:,j)=strcat(name,':',secn(j));end
    egu='';
    if ~all(isSLC)
        egu=lcaGetSmart([strtok(pv{1},'.') '.EGU']);
    end
    return
end
