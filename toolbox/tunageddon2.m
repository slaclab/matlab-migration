function varargout = tunageddon2(varargin)
% TUNAGEDDON2 M-file for tunageddon2.fig
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tunageddon2_OpeningFcn, ...
                   'gui_OutputFcn',  @tunageddon2_OutputFcn, ...
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

function tunageddon2_OpeningFcn(hObject, eventdata, handles, varargin)
handles.matchmagnetlist = {'QUAD:LI21:201:BCTRL'
                           'QUAD:LI21:211:BCTRL' 
                           'QUAD:LI21:271:BCTRL' 
                           'QUAD:LI21:278:BCTRL'
                           'QUAD:LI26:201:BCTRL'
                           'QUAD:LI26:301:BCTRL' 
                           'QUAD:LI26:401:BCTRL' 
                           'QUAD:LI26:501:BCTRL'
                           'QUAD:LI26:601:BCTRL'
                           'QUAD:LI26:701:BCTRL'
                           'QUAD:LI26:801:BCTRL'
                           'QUAD:LI26:901:BCTRL'
                           'QUAD:LTUH:620:BCTRL' 
                           'QUAD:LTUH:640:BCTRL' 
                           'QUAD:LTUH:660:BCTRL'
                           'QUAD:LTUH:680:BCTRL'
                           'QUAD:LTUS:620:BCTRL' 
                           'QUAD:LTUS:640:BCTRL' 
                           'QUAD:LTUS:660:BCTRL'
                           'QUAD:LTUS:680:BCTRL'
                           'QUAD:LI21:221:BCTRL'
                           'QUAD:LI21:251:BCTRL'
                           'QUAD:LI24:740:BCTRL'
                           'QUAD:LI24:860:BCTRL'
                           'QUAD:LTUH:440:BCTRL'
                           'QUAD:LTUH:460:BCTRL'  
                           'SIOC:SYS0:ML01:AO902'                                         
                           'WPLT:LR20:220:LHWP_ANGLE'
                           'WPLT:LR20:230:LHWP_ANGLE'
                           'FBCK:FB01:TR03:S1DES'
                           'FBCK:FB01:TR03:S2DES'
                           'SIOC:SYS0:ML03:AO365'
                                                       };

handles.currentmatch_mag = handles.matchmagnetlist(1);
handles.output = hObject;

handles.zigzag = 1;
handles.numsteps = 15;
numsteps = handles.numsteps;
d = findobj(gcf, 'Tag', 'numsteps');
set(d, 'String', numsteps);

handles.percent = 7;
percent = handles.percent;
r = findobj(gcf,'Tag','percent');
set(r,'String',percent);

handles.numpulses = 120;
numpulses = handles.numpulses;
nump = findobj(gcf, 'Tag', 'numpulses');
set(nump, 'String', numpulses);

handles.rejection = 0.1;
rejection = handles.rejection;
q = findobj(gcf,'Tag', 'rejection');
set(q, 'String',rejection);

handles.settle = 3;
settle = handles.settle;
z = findobj(gcf, 'Tag', 'settle');
set(z, 'String', settle);

currentmag = handles.currentmatch_mag;
a = findobj(gcf,'Tag','currentmag');
set(a,'String',currentmag);

y = findobj(gcf,'Tag','warning');
set(y,'String',' ');

value1 = lcaGet(handles.currentmatch_mag);
b = findobj(gcf,'Tag','value1');
set(b,'String',value1);
value2 = lcaGet(handles.currentmatch_mag);

handles.best = value1;
best = handles.best;
e = findobj(gcf,'Tag','best');
set(e, 'String',best);

c = findobj(gcf,'Tag','value2');
set(c,'String',value2);
%disp(handles.currentmatch_mag);

%set the remove point slider and slide range
set(handles.pointSlider,'Callback',@pointSliderCallback);
set(handles.pointSlider,'SliderStep',[1/(handles.numsteps-1) 1/(handles.numsteps-1)], 'Max', handles.numsteps-1);
set(handles.removePointButton,'Callback',@removePointCallback);

handles.setval = 0;
handles.xData=[];
handles.yData=[];
range = (handles.percent/100)*value1;

if value1>0
    handles.startval = value1 - 0.5*range;
    handles.endval = value1 + 0.5*range;
else
    handles.startval = value1 + 0.5*range;
    handles.endval = value1 - 0.5*range;
end
startval = handles.startval;
g = findobj(gcf, 'Tag', 'startval');
set(g, 'String', startval);
endval = handles.endval;
h = findobj(gcf, 'Tag', 'endval');
set(h, 'String', endval);
guidata(hObject, handles);
grid off
% set(handles.radioGDETgroup,'SelectionChangeFcn',@radioGDETgroup_SelectionChangeFcn);




function varargout = tunageddon2_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function matchmags_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
str = get(hObject, 'String');
FocusToFig(hObject);
switch str{val};
    case '21:201' 
        handles.currentmatch_mag = handles.matchmagnetlist(1);
    case 'QM11' 
        handles.currentmatch_mag = handles.matchmagnetlist(2);
    case 'QM12'
        handles.currentmatch_mag = handles.matchmagnetlist(3);
    case 'QM13'
        handles.currentmatch_mag = handles.matchmagnetlist(4);
    case '26:201' 
        handles.currentmatch_mag = handles.matchmagnetlist(5);
    case '26:301' 
        handles.currentmatch_mag = handles.matchmagnetlist(6);
    case '26:401'
        handles.currentmatch_mag = handles.matchmagnetlist(7);
    case '26:501'
        handles.currentmatch_mag = handles.matchmagnetlist(8);
    case '26:601' 
        handles.currentmatch_mag = handles.matchmagnetlist(9);
    case '26:701'
        handles.currentmatch_mag = handles.matchmagnetlist(10);
    case '26:801'
        handles.currentmatch_mag = handles.matchmagnetlist(11);
    case '26:901'
        handles.currentmatch_mag = handles.matchmagnetlist(12);
    case 'LTUH:620' 
        handles.currentmatch_mag = handles.matchmagnetlist(13);
    case 'LTUH:640' 
        handles.currentmatch_mag = handles.matchmagnetlist(14);
    case 'LTUH:660'
        handles.currentmatch_mag = handles.matchmagnetlist(15);
    case 'LTUH:680'
        handles.currentmatch_mag = handles.matchmagnetlist(16);   
    case 'LTUS:620' 
        handles.currentmatch_mag = handles.matchmagnetlist(17);
    case 'LTUS:640' 
        handles.currentmatch_mag = handles.matchmagnetlist(18);
    case 'LTUS:660'
        handles.currentmatch_mag = handles.matchmagnetlist(19);
    case 'LTUS:680'
        handles.currentmatch_mag = handles.matchmagnetlist(20);      
    case 'CQ11' 
        handles.currentmatch_mag = handles.matchmagnetlist(21);
    case 'CQ12' 
        handles.currentmatch_mag = handles.matchmagnetlist(22);
    case 'CQ21'
        handles.currentmatch_mag = handles.matchmagnetlist(23);
    case 'CQ22'
        handles.currentmatch_mag = handles.matchmagnetlist(24);
    case 'CQ31' 
        handles.currentmatch_mag = handles.matchmagnetlist(25);
    case 'CQ32' 
        handles.currentmatch_mag = handles.matchmagnetlist(26);
    case 'HXRSS'
        handles.currentmatch_mag = handles.matchmagnetlist(27);
    case 'LHWP1'
        handles.currentmatch_mag = handles.matchmagnetlist(28);
    case 'LHWP2'
        handles.currentmatch_mag = handles.matchmagnetlist(29);   
    case 'XCAVX'
        handles.currentmatch_mag = handles.matchmagnetlist(30);
    case 'XCAVY'
        handles.currentmatch_mag = handles.matchmagnetlist(31);    
    case 'Test' %mode to debug
        handles.currentmatch_mag = handles.matchmagnetlist(32);
        handles=setTestMode(handles);
end    



if val > 4 && val < 13
    handles.percent = 25;
else 
    handles.percent = 7;
end       
percent = handles.percent;
r = findobj(gcf,'Tag','percent');
set(r,'String',percent);


currentmag = handles.currentmatch_mag;
a = findobj(gcf,'Tag','currentmag');
set(a,'String',currentmag);

%y = findobj(gcf,'Tag','warning');
%set(y,'String',currentmag);

coherent1 = lcaGet('SHTR:LR20:289:LH_STS');
coherent2 = lcaGet('SHTR:LR20:299:LH_STS');

if strcmp(coherent1,'OUT') && strcmp(coherent2,'IN') && strcmp(currentmag,'WPLT:LR20:230:LHWP_ANGLE')
    set(handles.warning,'String', 'Warning: We are currently using Coherent 1, so please choose LHWP1.');
elseif strcmp(coherent2,'OUT') && strcmp(coherent1,'IN') && strcmp(currentmag,'WPLT:LR20:220:LHWP_ANGLE')
    set(handles.warning,'String', 'Warning: We are currently using Coherent 2, so please choose LHWP2.');
else
    set(handles.warning,'String', ' ');
end   



value1 = lcaGet(handles.currentmatch_mag);
b = findobj(gcf,'Tag','value1');
set(b,'String',value1);

handles.best = value1;

handles.value1 = value1;

best = handles.best;
e = findobj(gcf,'Tag','best');
set(e, 'String',best);

value2 = lcaGet(handles.currentmatch_mag);
c = findobj(gcf,'Tag','value2');
set(c,'String',value2);
handles.currentmag = value1;

range = (handles.percent/100)*value1;

%If not in test mode, find the range info
if ~strcmp(str{val},'Test')
    if value1>0
        handles.startval = value1 - 0.5*range;
        handles.endval = value1 + 0.5*range;
    else
        handles.startval = value1 + 0.5*range;
        handles.endval = value1 - 0.5*range;
    end
    startval = handles.startval;
    g = findobj(gcf, 'Tag', 'startval');
    set(g, 'String', startval);
    endval = handles.endval;
    h = findobj(gcf, 'Tag', 'endval');
    set(h, 'String', endval);

end
guidata(hObject,handles)
warning_Update(handles)


function matchmags_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dispmags_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

 function removePointCallback(hObject, eventdata,handles)
%function to remove a point and replot the parabola of best fit. 
    %Get the handle and structure for run data
    runHandle=findobj('Tag', 'startstop');
    runData=guidata(runHandle);
    
    %If there is no data run yet, just return
    if isempty(runData.xData)
        return;
    end
    
    %Get Slider handle and value
    slider=findobj('Tag', 'pointSlider');
    value=get(slider, 'Value'); %Get the selected value to remove 
    
    %toggle the include/exclude flag
    runData.dataMask(value+1)=~runData.dataMask(value+1);
    
    %Select only the data that is unmasked
    xData=runData.xData(runData.dataMask);
    yData=runData.yData(runData.dataMask);
    errors=runData.errors(runData.dataMask);
    errors_0=errors*0.25;
    
    
    %Now remove the point that we want to delete. 
    %runData.xData(value+1)=[];
    %runData.yData(value+1)=[];
    %runData.errors(value+1)=[];
    
    %with removed data, redo the fit and get a new best value
    errorbar(runData.axes1, xData, yData, errors_0,'*', 'Color', 'yellow','Tag','errorBars');
    
    hold on
    coefficients = polyfit(xData, yData, 2);
    newy = polyval(coefficients, xData);
    plot(runData.axes1,xData, newy, '-', 'Color', 'yellow','Tag','linePlot');
    
    xlabel(runData.axes1,['Signal Value of ' runData.currentmatch_mag], 'Color', 'white', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel(runData.axes1,'FEL (mJs) with jitter error bars', 'Color', 'white', 'FontSize', 16, 'FontWeight', 'bold');
    hold off
    
    d = polyder(coefficients);
    if isnan(d) == 1
        d = [0 0];
    end
    best1 = roots(d);
    second = polyder(d);

    if second < 0 && runData.startval<best1 && runData.endval>best1
        runData.best = best1;
        best = runData.best;
    else
        disp('bad fit')
        j = find(yData==max(yData));
        runData.best = xData(j);
        best = runData.best;
    end

%Change the remove point button accordingly.
if runData.dataMask(value+1) %if we readded a point
    set(hObject,'String','Remove Point','backgroundcolor','m'); 
else %If we got rid of a point
    set(hObject,'String','Add!','backgroundcolor','g'); 
end

%set the scroll bar Max to reflect number of data points
%steps=numel(runData.xData);
%set(runData.pointSlider,'Value',0); %put the slider to the lowest data point
%set(runData.pointSlider,'Max',steps-1);
%set(runData.pointSlider,'SliderStep',[1/(steps-1) 1/(steps-1)]);
q = findobj(gcf,'Tag', 'best');
set(q, 'String', best)
%lcaPut(runData.currentmatch_mag, value)
guidata(runHandle,runData); %update the data with the start/stop handle
    


function pointSliderCallback(hObject, eventdata, handles)
    %get the data associated with the start/stop handle process
    runHandle=findobj('Tag','startstop');
    data=guidata(runHandle);
    
    %If no data has been run, do not do anything
    if isempty(data.xData)
        return;
    end
    
    %if another point is highlighted then remove it
    oldHighlight=findobj('Tag','highlightedPoint');
    if ~isempty(oldHighlight)
        delete(oldHighlight);
    end
    
    removeAddButton=findobj('Tag','removePointButton');
    selectedPoint=get(hObject,'Value')+1;
    dataPlotted=data.dataMask(selectedPoint); %is this point plotted?
    
    if dataPlotted
        set(removeAddButton,'String', 'Remove Point','backgroundcolor',[1 0 1]);
        %errorBars=findobj(gcf,'Tag','errorBars');
        %linePlot=findobj(gcf,'Tag','linePlot');
        %plotFigure=findobj(gcf,'Tag','axes1');
        %Make the selected data a different color
   
        %Get the x and y selected data
        x=data.xData;
        y=data.yData;
        u=data.errors;
    
        xSelected=x(selectedPoint);
        ySelected=y(selectedPoint);
        uSelected=u(selectedPoint);
        uSelected_0 = uSelected*0.25;
        
        ySelected_rb = findobj(gcf,'Tag','ySelected');
        set(ySelected_rb,'String',ySelected);
        
        xSelected_rb = findobj(gcf,'Tag','xSelected');
        set(xSelected_rb,'String',xSelected);
        
        %Plot the one point in a different color
        hold on
        errorbar(xSelected,ySelected, uSelected_0,'*', 'Color',[0.933 0.557 0.898],'Tag','highlightedPoint')
        hold off    
    else %Data point is not currently displayed
        set(removeAddButton,'String','Add!','backgroundcolor','g');
    end
    
  
    
    
function startstop_Callback(hObject, eventdata, handles)
set(hObject, 'string', 'Stop', 'BackgroundColor', [1 0 0]);
messag = strcat('Scanning_', handles.currentmatch_mag);
logIt = get(hObject, 'Value');
if logIt == 1
    disp_log(messag)
else %if the stop button has just been pushed just return as calling two callbacks for the same thing is not productive
    return;
end

%Since a new data set is getting collected, make sure the button has been
%toggled to remove point.
removeAddButton=findobj('Tag','removePointButton');
set(removeAddButton,'String','Remove Point','backgroundcolor','m'); 

%change the tunagedon tuning flag to indicate that a scan is starting!
lcaPut('SIOC:SYS0:ML00:CALCOUT036',1);
%disp(lcaGet('SIOC:SYS0:ML00:CALCOUT036'));

x = [];
f = [];
y = [];
y2 =[];
rate = lcaGet('SIOC:SYS0:ML00:AO467');
value = lcaGet(handles.currentmatch_mag);
best = handles.value1;
if handles.startstop == 1
    value1 = lcaGet(handles.currentmatch_mag);
    handles.value1 = value1;
    b = findobj(gcf,'Tag','value1');
    set(b,'String',value1);
end
startval = handles.startval;
endval = handles.endval;
if value >0
    range = endval - startval;
else
    range = startval - endval;
end
stepsize = range/(handles.numsteps-1);
handles.startstop = 1;
settlet = handles.settle;
if value > 0
    startlim = handles.startval - stepsize;
    endlim = handles.endval + stepsize;
else
    startlim = handles.startval + stepsize;
    endlim = handles.endval - stepsize;
end
rangearray = [startlim endlim];
for k = 1:handles.numsteps;
    if value>0
        f(k) = startval + stepsize*(k-1);
    else
        f(k) = startval - stepsize*(k-1);
    end
end
handles.startstop = 1;
colordef black

%Main scan loop for each step
for i = 1:handles.numsteps;
    rate1 = lcaGet('SIOC:SYS0:ML00:AO467');
    while rate1<rate
        rate1 = lcaGet('SIOC:SYS0:ML00:AO467');
        pause(3)
    end
    Fs = lcaGet('EVNT:SYS0:1:LCLSBEAMRATE');
    T = 1/Fs*handles.numpulses;
    handles.startstop = get(hObject,'Value');
    
    %if stop button is pushed, exit the for loop
    if handles.startstop == 0
        lcaPut(handles.currentmatch_mag, value);
          %Sort the data if no more data will be taken
        [x3,order]=sort(x);
        y3=y(order);
        arrangedErrors=y2(order);
        %Set the best as the maximum mjs, regardless of fit. 
        j = find(y==max(y));
        handles.best = x(j);
        best = handles.best;
        
        break; %End the for statement
    end
     if handles.zigzag == 0
        if value > 0
            lcaPut(handles.currentmatch_mag, handles.startval+stepsize*(i-1))
        else
            lcaPut(handles.currentmatch_mag, handles.startval-stepsize*(i-1))
        end    
     else
        if mod(handles.numsteps,2) 
            scan_array=[handles.numsteps:-2:1 2:2:handles.numsteps-1];
        else
            scan_array=[handles.numsteps:-2:2 1:2:handles.numsteps-1];
        end 
        if value > 0
            scan_array = fliplr(scan_array);
        end
        diff = f - value;
        ind = find(abs(diff) == min(abs(diff)));
        ind2 = find(scan_array == ind(1));
        scan_array_use = transpose(circshift(transpose(scan_array),ind2));
        [order, arrangeI] = sort(scan_array_use);
        lcaPut(handles.currentmatch_mag, f(scan_array_use(i)))
     end            
    xAxesValues = lcaGet(handles.currentmatch_mag);
    c = findobj(gcf,'Tag','value2');
    set(c,'String',xAxesValues);
    pause(T+settlet)
%    gasDetData = lcaGet('GDET:FEE1:241:ENRCHSTBR');
       
%    str = char(handles.currentmatch_mag);
%    k = strfind(str,'LTUS');
%    if isempty(k)
%        gasDetData = lcaGet('GDET:FEE1:241:ENRCHSTBR');
%        [row,col] = size(gasDetData);
%    else
%        gasDetData = lcaGet('EM1K0:GMD:HPS:milliJoulesPerPulse_LAST_N');
%        [row,col] = size(gasDetData);
%    end
    
    if get(handles.HXR,'Value')
        gasDetData = lcaGet('GDET:FEE1:241:ENRCHSTBR');
        [row,col] = size(gasDetData);
        set(handles.warning,'String', ' ');
    elseif get(handles.SXR,'Value')
        gasDetData = lcaGet('EM1K0:GMD:HPS:milliJoulesPerPulse_LAST_N');
        [row,col] = size(gasDetData);
        set(handles.warning,'String', ' ');
    end
    
    
%    sampleStart = 2801 - handles.numpulses; 
    sampleStart = (col+1) - handles.numpulses; 
%    gasDetDataused = gasDetData(sampleStart:2800);
    gasDetDataused = gasDetData(sampleStart:col);
    for j = 1:numel(gasDetDataused)
        if gasDetDataused(j) < handles.rejection
            gasDetDataused(j) = 0;
        end
    end
    
%   Need to convert NaN to 0
    gasDetDataused(isnan(gasDetDataused))=0;
    gasDetDatausednew = nonzeros(gasDetDataused);
    gasDetMean = mean(gasDetDatausednew);
    gasDetStdDev = std(gasDetDatausednew);
    x(i) = xAxesValues;
    y(i) = gasDetMean;
    y2(i) = gasDetStdDev;
    y2_0 = y2*0.25;
    errorbar(x,y,y2_0, '*', 'Color', 'yellow','Tag','errorBars')
    xlim([min(rangearray) max(rangearray)]);
    xlabel(['Signal Value of ' handles.currentmatch_mag], 'Color', 'white', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('FEL (mJs) with jitter error bars', 'Color', 'white', 'FontSize', 12, 'FontWeight', 'bold');
    
  
    
    %Things to do on the last step
    if i == handles.numsteps
        hold on
        x3 = x(arrangeI);
        y3 = y(arrangeI);
        arrangedErrors=y2(arrangeI);
        %filter out any points that read nan...
        nanFlag=isnan(y3); %Flag nan values
        y3=y3(~nanFlag);
        x3=x3(~nanFlag);
        arrangedErrors=arrangedErrors(~nanFlag);
        
        coefficients = polyfit(x3, y3, 2);
        newy = polyval(coefficients, x3);
        plot(x3, newy, '-', 'Color', 'yellow','Tag','linePlot');
        d = polyder(coefficients);
        if isnan(d) == 1
            d = [0 0];
        end
        best1 = roots(d);
        second = polyder(d);
        handles.data.x = x;
        handles.data.y = y;
        handles.data.PV = handles.currentmatch_mag;
        if second < 0 && startval<best1 && endval>best1
            handles.best = best1;
            best = handles.best;
        else
            disp('bad fit')
            j = find(y==max(y));
            handles.best = x(j);
            best = handles.best;
        end
          hold off
    end
    
    
end
%Scanning is done so put down the flag
lcaPut('SIOC:SYS0:ML00:CALCOUT036',0);
%disp(lcaGet('SIOC:SYS0:ML00:CALCOUT036'));


%Save the output data in the handle structure
handles.yData=y3;
handles.xData=x3;
handles.errors=arrangedErrors;
numsteps=numel(x3);

%add a boolean mask so that we know what points to include in the plot display. 
%For initial display, include all points taken in a 1xnData array. 
handles.dataMask=true(1, numsteps);

%set the scroll bar Max to reflect the step size
set(handles.pointSlider,'Value',0); %put the slider to the lowest data point
set(handles.pointSlider,'Max',numsteps-1);
set(handles.pointSlider,'SliderStep',[1/(numsteps-1) 1/(numsteps-1)]);
q = findobj(gcf,'Tag', 'best');
set(q, 'String', best)
lcaPut(handles.currentmatch_mag, value)
xAxesValues = lcaGet(handles.currentmatch_mag);
c = findobj(gcf,'Tag','value2');
set(c,'String',xAxesValues);
set(hObject, 'Enable', 'on', 'String', 'Start', 'BackgroundColor', [0 1 0], 'Value', 0);
guidata(hObject, handles);

function FocusToFig(ObjH, EventData) 
% Move focus to figure, keep pop up menu from changing colors
if any(ishandle(ObjH))   % Catch no handle and empty ObjH
   FigH = ancestor(ObjH, 'figure');
   if strcmpi(get(ObjH, 'Type'), 'uicontrol')
      set(ObjH, 'enable', 'off');
      drawnow;
      set(ObjH, 'enable', 'on');
   end
     figure(FigH);
     set(0, 'CurrentFigure', FigH);
end
return;

function percent_Callback(hObject, eventdata, handles)
percent = get(hObject, 'String');
handles.percent = str2double(percent);
value1 = lcaGet(handles.currentmatch_mag);
range = (handles.percent/100)*value1;
if value1>0
    handles.startval = value1 - 0.5*range;
    handles.endval = value1 + 0.5*range;
else
    handles.startval = value1 + 0.5*range;
    handles.endval = value1 - 0.5*range;
end
startval = handles.startval;
g = findobj(gcf, 'Tag', 'startval');
set(g, 'String', startval);
endval = handles.endval;
h = findobj(gcf, 'Tag', 'endval');
set(h, 'String', endval);
guidata(hObject, handles);

function percent_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function numpulses_Callback(hObject, eventdata, handles)
numpulses = str2double(get(hObject, 'String'));
if ~isnan(numpulses)
    handles.numpulses = numpulses;
end
guidata(hObject, handles);

function numpulses_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rejection_Callback(hObject, eventdata, handles)
rejection = str2double(get(hObject, 'String'));
if ~isnan(rejection)
    handles.rejection = rejection;
end
guidata(hObject, handles);

function rejection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function settle_Callback(hObject, eventdata, handles)
settle = str2double(get(hObject, 'String'));
if ~isnan(settle)
    handles.settle = settle;
end
guidata(hObject, handles);

function settle_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function numsteps_Callback(hObject, eventdata, handles)
numsteps = str2double(get(hObject, 'String'));
if ~isnan(numsteps)
    handles.numsteps = numsteps;
   
end
guidata(hObject, handles);

function numsteps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function magDes_Callback(hObject, eventdata, handles)
magDes1 = get(hObject, 'String');
magDes = str2double(magDes1);
w = findobj(gcf, 'Tag', 'magDes1');
set(w, 'String', magDes1);
if ~isnan(magDes)
    lcaPut(handles.currentmatch_mag, magDes)
end
disp_log(strcat('Changing BACT for_', handles.currentmatch_mag))
value2 = lcaGet(handles.currentmatch_mag);
c = findobj(gcf,'Tag','value2');
set(c,'String',value2);

function magDes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function putVal_Callback(hObject, eventdata, handles)
lcaPut(handles.currentmatch_mag, handles.best)
disp_log(strcat('Changing BACT for_', handles.currentmatch_mag))
value2 = lcaGet(handles.currentmatch_mag);
c = findobj(gcf,'Tag','value2');
set(c,'String',value2);

function logbutton_Callback(hObject, eventdata, handles) 
h = gcf;
set(gcf, 'InvertHardcopy', 'off')
util_printLog2(h, 'author', 'tunageddon')
data = {handles.data.x
        handles.data.y
        handles.data.PV
                        };
util_dataSave(data, 'Tunageddon', handles.currentmatch_mag, now)

function util_printLog2(fig, varargin)
optsdef=struct( ...
    'title','Matlab', ...
    'text','', ...
    'author','Matlab' ...
    );
opts=util_parseOptions(varargin{:},optsdef);
fig(~ishandle(fig))=[];

[sys,accel]=getSystem;
queue=['physics-' lower(accel) 'log'];


for f=fig(:)'
    if ~isempty(varargin) && ismember(accel,{'FACET'})
        util_printLog_wComments(f,opts.author,opts.title,opts.text,[500 375],0);
        continue
    end 
    print(f,'-dpsc2','-noui',['-P' queue]);
   
end

function util_printLog_wComments(fig,author,title,text,dim,invert)
% Parse input arguments.
if nargin< 6, invert=1; end
if nargin< 5, dim=[480 400]; end
if nargin< 4, text='Matlab'; end
if nargin< 3, title='Matlab'; end
if nargin< 2, author='Matlab'; end

% Check if FIG is handle.
fig(~ishandle(fig))=[];

%Render tag strings to comply with XML.
text=make_XML(text);
title=make_XML(title);
author=make_XML(author);

% Determine accelerator.
[sys,accel]=getSystem;
pathName=['/u1/' lower(reshape(char(accel)',1,[])) '/physics/logbook/data'];
if ~exist(pathName,'dir'), return, end

fileIndex=0;

for f=fig(:)'
    tstamp=datestr(now,31);
    [dstr, tstr] = strtok(tstamp);
    fileName=[strrep(tstamp, ' ', 'T') sprintf('-0%d',fileIndex)];
    if invert, set(fig,'InvertHardcopy','off');end  
    ext='.png';
     print(fig,'-dpng','-r75',(fullfile(pathName,[fileName ext])));
     print(fig,'-dpsc2' ,'-loose',(fullfile(pathName,[fileName '.ps'])));
    fid=fopen(fullfile(pathName,[fileName '.xml']),'w');
    if fid~=-1
        fprintf(fid,'<author>%s</author>\n',author);
        fprintf(fid,'<category>USERLOG</category>\n');
        fprintf(fid,'<title>%s</title>\n',title);
        fprintf(fid,'<isodate>%s</isodate>\n',dstr);
        fprintf(fid,'<time>%s</time>\n',tstr(2:end));
        fprintf(fid,'<severity>NONE</severity>\n');
        fprintf(fid,'<keywords></keywords>\n');
        fprintf(fid,'<location></location>\n');
        fprintf(fid,'<metainfo>%s</metainfo>\n',[fileName '.xml']);
        fprintf(fid,'<file>%s</file>\n',[fileName ext]);
        fprintf(fid,'<link>%s</link>\n',[fileName '.ps']);
        fprintf(fid,'<text>%s</text>\n',text);
        fclose (fid);
    end
    fileIndex=fileIndex+1;
end

function str = make_XML(str)

str=strrep(str,'&','&amp;');
str=strrep(str,'"','&quot;');
str=strrep(str,'''','&apos;');
str=strrep(str,'<','&lt;');
str=strrep(str,'>','&gt;');


%Function to configure the GUI for a good test mode.
function handles=setTestMode(handles)
    handles.numsteps = 11;
    numsteps = handles.numsteps;
    d = findobj(gcf, 'Tag', 'numsteps');
    set(d, 'String', numsteps);

    handles.percent = 7;
    percent = handles.percent;
    r = findobj(gcf,'Tag','percent');
    set(r,'String',percent);

    handles.numpulses = 120;
    numpulses = handles.numpulses;
    nump = findobj(gcf, 'Tag', 'numpulses');
    set(nump, 'String', numpulses);

    handles.rejection = 0.1;
    rejection = handles.rejection;
    q = findobj(gcf,'Tag', 'rejection');
    set(q, 'String',rejection);

    handles.settle = 1;
    settle = handles.settle;
    z = findobj(gcf, 'Tag', 'settle');
    set(z, 'String', settle);
   
    handles.startval = -5;
    g = findobj(gcf, 'Tag', 'startval');
    set(g, 'String', handles.startval);

    handles.endval = 5;
    h = findobj(gcf, 'Tag', 'endval');
    set(h, 'String', handles.endval);
    
   
function startval_Callback(hObject, eventdata, handles)
startval = str2double(get(hObject, 'String'));
if ~isnan(startval)
    handles.startval = startval;
end
guidata(hObject, handles)

function startval_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function endval_Callback(hObject, eventdata, handles)
endval = str2double(get(hObject, 'String'));
if ~isnan(endval)
    handles.endval = endval;
end
guidata(hObject, handles)

function endval_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton3_Callback(hObject, eventdata, handles)
lcaPut(handles.currentmatch_mag, handles.value1)
value2 = lcaGet(handles.currentmatch_mag);
c = findobj(gcf,'Tag','value2');
set(c,'String',value2);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
delete(gcf)
if ~usejava('desktop')
    exit
end

function edit10_Callback(hObject, eventdata, handles)
handles.currentmatch_mag = get(hObject, 'String');
z = meme_names('name',handles.currentmatch_mag);
if numel(z) == 1
currentmag = handles.currentmatch_mag;
a = findobj(gcf,'Tag','currentmag');
set(a,'String',currentmag);

value1 = lcaGet(handles.currentmatch_mag);
b = findobj(gcf,'Tag','value1');
set(b,'String',value1);
handles.best = value1;
handles.value1 = value1;

best = handles.best;
e = findobj(gcf,'Tag','best');
set(e, 'String',best);

value2 = lcaGet(handles.currentmatch_mag);
c = findobj(gcf,'Tag','value2');
set(c,'String',value2);
handles.currentmag = value1;

range = (handles.percent/100)*value1;
    if value1>0
        handles.startval = value1 - 0.5*range;
        handles.endval = value1 + 0.5*range;
    else
        handles.startval = value1 + 0.5*range;
        handles.endval = value1 - 0.5*range;
    end
startval = handles.startval;
g = findobj(gcf, 'Tag', 'startval');
set(g, 'String', startval);
endval = handles.endval;
h = findobj(gcf, 'Tag', 'endval');
set(h, 'String', endval);
guidata(hObject,handles)
guidata(hObject, handles)
elseif numel(z) >1
    disp('Multiple PVs available, options are:')
    disp(z)
else
    disp('Not a PV')
end

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function pointSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pointSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function warning_Update(handles)
mag = char(handles.currentmatch_mag);
s = strfind(mag,'LTUS');
h = strfind(mag,'LTUH');
n = 0;
if ~isempty(s) && get(handles.HXR,'Value')
    while(n<=2)
        set(handles.warning,'String', 'A LTUS device is selected to scan on a HXR Gas Detector.');
        pause(1.5);
        set(handles.warning,'String', ' ');
        pause(0.75);
        set(handles.warning,'String', 'A LTUS device is selected to scan on a HXR Gas Detector.');
        n=n+1;
    end
    set(handles.warning,'String', ' ');
 elseif ~isempty(h) && get(handles.SXR,'Value')
     while(n<=2)
        set(handles.warning,'String', 'A LTUH device is selected to scan on a SXR Gas Detector.');
        pause(1.5);
        set(handles.warning,'String', ' ');
        pause(0.75);
        set(handles.warning,'String', 'A LTUH device is selected to scan on a SXR Gas Detector.');
        n=n+1;
    end
    set(handles.warning,'String', ' ');
end

% function radioGDETgroup_SelectionChangeFcn(hObject, eventdata)
% handles = guidata(hObject);
% mag = char(handles.currentmatch_mag);
% s = strfind(mag,'LTUS');
% h = strfind(mag,'LTUH'); 
% 
% switch get(eventdata,NewValue,'Tag')
%     case 'HXR'
%         if ~isempty(s)
%             set(handles.warning,'String', 'A LTUS device is selected to scan on a HXR Gas Detector.');
%         else
%             set(handles.warning,'String', ' ');
%         end
%     case 'SXR'
%         if ~isempty(h)
%             set(handles.warning,'String', 'A LTUH device is selected to scan on a SXR Gas Detector.');
%         else
%             set(handles.warning,'String', ' ');
%         end
%     otherwise 
%         set(handles.warning,'String', ' ');
% end 
        



    
