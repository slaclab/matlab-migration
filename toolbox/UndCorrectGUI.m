function varargout = UndCorrectGUI(varargin)
% UNDCORRECTGUI MATLAB code for UndCorrectGUI.fig
%      UNDCORRECTGUI, by itself, creates a new UNDCORRECTGUI or raises the existing
%      singleton*.
%
%      H = UNDCORRECTGUI returns the handle to a new UNDCORRECTGUI or the handle to
%      the existing singleton*.
%
%      UNDCORRECTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNDCORRECTGUI.M with the given input arguments.
%
%      UNDCORRECTGUI('Property','Value',...) creates a new UNDCORRECTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UndCorrectGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UndCorrectGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UndCorrectGUI

% Last Modified by GUIDE v2.5 23-May-2017 01:59:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UndCorrectGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @UndCorrectGUI_OutputFcn, ...
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

% --- Executes just before UndCorrectGUI is made visible.
function UndCorrectGUI_OpeningFcn(hObject, eventdata, handles)%, varargin)
%handles.BBAtime = '10/18/2016 19:46:00';
handles.BBAtime = lcaGet('SIOC:SYS0:ML03:AO746TS');
setTag(handles.BBAtime, 'bbaDate')
setTag('Launching GUI, Plotting Pointing Offsets', 'status')
handles = initTablePlot(hObject, handles);
handles.output = hObject;
guidata(hObject, handles);
print 'hi';

function handles = initTablePlot(hObject, handles)
for i = 1:33
    handles.dOffy(i) = lcaGet(['BPMS:UND1:',int2str(i),'90:YOFF.D']);
    handles.dOffx(i) = lcaGet(['BPMS:UND1:',int2str(i),'90:XOFF.D']);
    names{i} = (['BPMS:UND1:',int2str(i),'90']);
end
handles.endX = 1000*handles.dOffx(33);
handles.endY = 1000*handles.dOffy(33);
handles.names = transpose(names);
handles.data = [handles.names num2cell(transpose(handles.dOffx)) num2cell(transpose(handles.dOffy))];
cNames = {'BPM', 'X Offset', 'Y Offset'};
set(handles.offsetTable, 'Data', handles.data, 'ColumnName', cNames, 'ColumnWidth', {120, 70, 70})
plot (handles.dOffx , 'r-' );
hold on;
plot (handles.dOffy , 'g-' );
title ( 'Current Pointing' );
xlabel ( 'Girder Number' );
ylabel ( 'x (red), y (green) (mm)' );
grid on;
hold off;

function  setTag(string,tag)
%string and tag in single quotes
r = findobj(gcf,'Tag',tag);
set(r,'String', string);

% --- Outputs from this function are returned to the command line.
function varargout = UndCorrectGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes on button press in relativePos.
function relativePos_Callback(hObject, eventdata, handles)
BBAtime = handles.BBAtime;
UndConsts  = util_UndulatorConstants;
geo        = girderGeo;

BBApos = getArchivedGirderPositions ( BBAtime );

[ NOWpos.CAM_qud_rb, NOWpos.CAM_bfw_rb, NOWpos.CAM_roll_rb ] = girderAxisFromCamAngles ( 1 : BBApos.segments, geo.quadz, geo.bfwz );

handles.x = zeros ( 1, BBApos.segments  );
handles.y = zeros ( 1, BBApos.segments  );
handles.z = zeros ( 1, BBApos.segments  );

for s = 1 : BBApos.segments
    jbfw = ( s - 1 ) * 2 + 1;
    jqud = ( s - 1 ) * 2 + 2;

    handles.x ( jbfw ) = NOWpos.CAM_bfw_rb ( s, 1 ) * 1e3 - BBApos.values.x { jbfw }( end );%+handles.bfOffx(s)*1e3;
    handles.x ( jqud ) = NOWpos.CAM_qud_rb ( s, 1 ) * 1e3 - BBApos.values.x { jqud }( end );%+handles.dOffx(s)*1e3;
    
    handles.y ( jbfw ) = NOWpos.CAM_bfw_rb ( s, 2 ) * 1e3 - BBApos.values.y { jbfw }( end );%+handles.bfOffy(s)*1e3;
    handles.y ( jqud ) = NOWpos.CAM_qud_rb ( s, 2 ) * 1e3 - BBApos.values.y { jqud }( end );%+handles.dOffy(s)*1e3;

    handles.z ( jbfw ) = UndConsts.Z_BFW  { s }-515.229;
    handles.z ( jqud ) = UndConsts.Z_QUAD { s }-515.229;   
end
handles.bfwx = handles.x(mod((1:66),2)~=0);
handles.bfwy = handles.y(mod((1:66),2)~=0);
handles.qudx = handles.x(mod((1:66),2)==0);
handles.qudy = handles.y(mod((1:66),2)==0);
plot (handles.z, handles.x , 'r-' );
hold on;
plot (handles.z, handles.y , 'g-' );
title ( 'Girder position changes since last BBA' );
xlabel ( 'Z Position (m)' );
ylabel ( 'x (red), y (green) ( {\mu}m)' );
grid on;
hold off;
setTag('Difference in girder position from last BBA', 'status')
guidata(hObject,handles)

% --- Executes on button press in correctError.
function correctError_Callback(hObject, eventdata, handles)
% xa(1:33) : desired change in bfw  x position [microns]
% ya(1:33) : desired change in bfw  y position [microns]
% xb(1:33) : desired change in quad x position [microns]
% yb(1:33) : desired change in quad y position [microns]

slots=1:33;
disp('slots')
geo=girderGeo;
disp('geo')
[quad_rb,bfw_rb,~]=girderAxisFromCamAngles(slots,geo.quadz,geo.bfwz);
disp('girderaxis')
bfw_sp=bfw_rb;
quad_sp=quad_rb;
disp('bfw')
for j = 1 : length(slots)
     bfw_sp(j,1:3)=bfw_rb(j,1:3)-[handles.bfwx(j),handles.bfwy(j),0]/1000;
     quad_sp(j,1:3)=quad_rb(j,1:3)-[handles.qudx(j),handles.qudy(j),0]/1000;
end
disp('for loop')
girderAxisSet(slots,quad_sp,bfw_sp);%Actually moves stuff, keep commented
disp('moving stuff')
%until testing

girderCamWait(slots);
setTag('Corrected any error from last BBA', 'status')

function bbaDate_Callback(hObject, eventdata, handles)
handles.BBAtime = get(hObject,'String');
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function bbaDate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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
if nargin< 5, dim=[580 580]; end
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

% --- Executes on button press in logButton.
function logButton_Callback(hObject, eventdata, handles)
h = gcf;
set(gcf, 'InvertHardcopy', 'off')
util_printLog_wComments(h, 'author', 'UndCorrectGUI')

% --- Executes on button press in zeroPoint.
function zeroPoint_Callback(hObject, eventdata, handles)
dlgTitle = 'Zero Pointing';
dlgQuestion = 'Are you sure you want to zero the pointing';
choice = questdlg(dlgQuestion, dlgTitle, 'Yes', 'No', 'Yes');
if strcmp(choice, 'Yes')
    UndConsts = util_UndulatorConstants;

    Z_BPM  = cell2mat ( UndConsts.Z_BPM  );
    Z_QUAD = cell2mat ( UndConsts.Z_QUAD );

    z = Z_BPM(2:33)';
    xDoff=-lcaGet(strcat({'BPMS:UND1:'},num2str((1:32)','%-d'),{'90:XOFF.D'}));
    yDoff=-lcaGet(strcat({'BPMS:UND1:'},num2str((1:32)','%-d'),{'90:YOFF.D'}));

    [xfitc,xS]=polyfit ( z, xDoff, 2 );
    [yfitc,yS]=polyfit ( z, yDoff, 2 );

    xrep = polyval ( xfitc, z );
    yrep = polyval ( yfitc, z );

    xndx = find( abs ( xDoff-xrep ) < 0.001 );
    yndx = find( abs ( yDoff-yrep ) < 0.001 );

    [xfitc,xS]=polyfit ( z ( xndx ), xDoff ( xndx ), 2 );
    [yfitc,yS]=polyfit ( z ( yndx ), yDoff ( yndx ), 2 );

    xrep = polyval ( xfitc, z );
    yrep = polyval ( yfitc, z );

    xend = polyval ( xfitc, Z_QUAD ( 33 ) );
    yend = polyval ( yfitc, Z_QUAD ( 33 ) );

    setTag(['Zeroing Pointing: Repoint(0,0,', num2str(round(handles.endX)),',', num2str(round(handles.endY)),')'], 'status')
    pause(2)
    repointUndulatorLine(0,0, round ( -xend * 1000), round ( -yend * 1000 ) )
    for i = 1:33
        handles.dOffy(i) = lcaGet(['BPMS:UND1:',int2str(i),'90:YOFF.D']);
        handles.dOffx(i) = lcaGet(['BPMS:UND1:',int2str(i),'90:XOFF.D']);
    end
    handles.endX = 1000*handles.dOffx(33);
    handles.endY = 1000*handles.dOffy(33);
    plot (handles.dOffx , 'r-' );
    hold on;
    plot (handles.dOffy , 'g-' );
    hold off;
    handles.data = [handles.names num2cell(transpose(handles.dOffx)) num2cell(transpose(handles.dOffy))];
    set(handles.offsetTable, 'Data', handles.data)
    %setTag('Finished Repointing, Plotted New Pointing', 'status')
end

% --- Executes on button press in zeroOffsets.
function zeroOffsets_Callback(hObject, eventdata, handles)
    handles.RFBPMoffsets = moveRFBPMoffsets_D_to_A
    setTag('Zeroed Pointing Offsets: Writing 0 to all Und BPM D Offsets', 'status')
    guidata(hObject, handles)
    % --- Executes on button press in restoreOffsets.
function restoreOffsets_Callback(hObject, eventdata, handles)
    lcaPutSmart ( handles.RFBPMoffsets.BPMoffsetPV, handles.RFBPMoffsets.old.BPM );
    lcaPutSmart ( handkes.RFBPMoffsets.PNToffsetPV, handles.RFBPMoffsets.old.PNT );

setTag('Restored Pointing Offsets: Restoring Initial BPM D Offsets', 'status')
