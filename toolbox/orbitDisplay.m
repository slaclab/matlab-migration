function orbitDisplay(varargin)

% Set default options.
optsdef=struct( ...
    'eDef','BR', ...
    'chargeLim',300, ...
    'xLim',1, ...
    'zLim',[], ...
    'sector','', ...
    'diff',0, ...
    'ref',0, ...
    'gui',1, ...
    'delay',.1);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Find TCAV3 eDef.
if isempty(opts.eDef)
    handles.eDefName='tcav_feedback';
    handles.eDefNumber=0;
    handles=gui_BSAControl([],handles,1,-1);
    lcaPut(num2str(handles.eDefNumber,'EDEF:SYS0:%d:INCM92'),1);
    if ~ispc, eDefOn(handles.eDefNumber);end
    opts.eDef=handles.eDefNumber;
end

% Set up figure.
figure(1);clf;set(1,'MenuBar','none','NumberTitle','off');
h1=subplot(3,1,1);
h2=subplot(3,1,2);
h3=subplot(3,1,3);
util_marginSet(1,[.12 .05],[.1+0.08*opts.gui 0.02 0.02 .03]);
util_appFonts(1,'fontSize',12);
hl1=plot(0,0,'k',0,0,'b',0,0,'c','Parent',h1);
hl2=plot(0,0,'k',0,0,'g',0,0,'y','Parent',h2);
hl3=plot(0,0,'k',0,0,'r',0,0,'m','Parent',h3);
set([hl1(2:end) hl2(2:end) hl3(2:end)],'LineWidth',2);
ylabel(h1,'x  (mm)');
ylabel(h2,'y  (mm)');
ylabel(h3,'Charge  (pC)');
xlabel(h3,'z Position  (m)');

if isnumeric(opts.eDef), opts.eDef=opts.eDef(:);end
opts.eDef=cellstr(num2str(opts.eDef,'%d'));
opts.sector=cellstr(opts.sector);
lcaSetSeverityWarnLevel(5);

% Get BPM list.
[nAll,x]=getBPMs(opts.sector,[hl1 hl2 hl3]);
if ~isempty(opts.zLim), set([h1 h2 h3],'XLim',opts.zLim);end
set([h1 h2],'XTickLabel','','XLim',get(h3,'XLim'));
[x2,y2,t2]=deal(x*NaN);

if opts.gui, gui_init(opts,@callback);end

while opts.delay && ishandle(1)
    [data,ts]=lcaGetSmart(strcat(nAll,opts.eDef{1}));ts=[ts(1:end);0];
    data=reshape(data,[],3);
    x=[0;1;NaN]*data(:,1)';
    y=[0;1;NaN]*data(:,2)';
    t=[0;1;NaN]*data(:,3)';
    vis=NaN;
    dif=opts.diff && ~all(isnan(x2(:)));
    if opts.ref, [x2,y2,t2]=deal(x,y,t);opts.ref=0;end
    if numel(opts.eDef) > 1
        data=reshape(lcaGetSmart(strcat(nAll,opts.eDef{2})),[],3);
        x2=[0;1;NaN]*data(:,1)';
        y2=[0;1;NaN]*data(:,2)';
        t2=[0;1;NaN]*data(:,3)';
        vis=1;
    end
    if dif
        x=x-x2;y=y-y2;t=t-t2;%[x2,y2,t2]=deal(x2*NaN);
        vis=NaN;
    end
    set(hl1(2),'YData',x(:));
    set(hl2(2),'YData',y(:));
    set(hl3(2),'YData',t(:)*1.6021e-19*1e12);
    set(hl1(3),'YData',x2(:)*vis);
    set(hl2(3),'YData',y2(:)*vis);
    set(hl3(3),'YData',t2(:)*vis*1.6021e-19*1e12);
    set(1,'Name',['Orbit Display ' sprintf('%s ',opts.sector{:}) '| EDef ' sprintf('%s ',opts.eDef{:}) '| ' datestr(lca2matlabTime(ts(1)))]);
    set([h1 h2],'YLim',opts.xLim*[-1.1 1.1]);
    set(h3,'YLim',opts.chargeLim*[-1.1*dif 1.1]);

    pause(opts.delay);
    drawnow;
    if ~ishandle(1), if opts.gui, util_appClose(1);end, return, end
    if ~opts.gui, continue, end
    handles=guidata(1);
    if ~isequal(opts.sector,handles.sector)
        [nAll,x]=getBPMs(handles.sector,[hl1 hl2 hl3]);
        [x2,y2,t2]=deal(x*NaN);
        if ~isempty(opts.zLim), set([h1 h2 h3],'XLim',opts.zLim);end
        set([h1 h2],'XTickLabel','','XLim',get(h3,'XLim'));
    end
    opts.eDef=handles.eDef;
    for t={'delay' 'xLim' 'chargeLim'}
        if isempty(handles.(t{:})), continue, end
        opts.(t{:})=handles.(t{:});
    end
    opts.diff=handles.diff;
    opts.ref=handles.ref;
    opts.sector=handles.sector;
    handles.ref=0;
    guidata(1,handles);
end


function [nAll, x] = getBPMs(sector, hl)

if isempty(sector{1}), sector=[];end
[n,d,isSLC]=model_nameRegion({'BPMS'},sector);
n(isSLC)=[];
nAll=[strcat(n,':X');strcat(n,':Y');strcat(n,':TMIT')];
z=model_rMatGet(n,[],[],'Z');
x=[0;0;NaN]*z;z=[z;z;z];z=z(:);z2=z+.1;
set(hl(1,:),'XData',z,'YData',z*0);
set(hl(2,:),'XData',z,'YData',x(:));
set(hl(3,:),'XData',z2,'YData',x(:)*NaN);


function handles = gui_init(handles, fcn)

hObject=1;
set(hObject,'DefaultUicontrolBackgroundColor',get(hObject,'Color'));
xP=2;xW=11.5;xS=1.1;
yP=1;yH=1.8;yP1=yP+yH;yH1=1.2;
par={'Parent',hObject,'Units','characters'};
par1=[par,{'Callback',fcn}];
handles.sector_txt=uicontrol(par1{:},'Style','edit','Position',[xP yP xW yH],'Tag','sector','String',sprintf('%s ',handles.sector{:}));
handles.sectorLabel_txt=uicontrol(par{:},'Style','text','Position',[xP yP1 xW yH1],'String','Sectors');xP=xP+xS*xW;
handles.eDef_txt=uicontrol(par1{:},'Style','edit','Position',[xP yP xW yH],'Tag','eDef','String',sprintf('%s ',handles.eDef{:}));
handles.eDefLabel_txt=uicontrol(par{:},'Style','text','Position',[xP yP1 xW yH1],'String','EDEFs');xP=xP+xS*xW;
handles.delay_txt=uicontrol(par1{:},'Style','edit','Position',[xP yP xW yH],'Tag','delay','String',num2str(handles.delay));
handles.delayLabel_txt=uicontrol(par{:},'Style','text','Position',[xP yP1 xW yH1],'String','Delay');xP=xP+xS*xW;
handles.diff_btn=uicontrol(par1{:},'Style','togglebutton','Position',[xP yP xW yH],'Tag','diff','String','Diff','Value',handles.diff);xP=xP+xS*xW;
handles.ref_btn=uicontrol(par1{:},'Style','pushbutton','Position',[xP yP xW yH],'Tag','ref','String','Ref');xP=xP+xS*xW;
handles.xLim_txt=uicontrol(par1{:},'Style','edit','Position',[xP yP xW yH],'Tag','xLim','String',num2str(handles.xLim));
handles.xLimLabel_txt=uicontrol(par{:},'Style','text','Position',[xP yP1 xW yH1],'String','X Lim');xP=xP+xS*xW;
handles.chargeLim_txt=uicontrol(par1{:},'Style','edit','Position',[xP yP xW yH],'Tag','chargeLim','String',num2str(handles.chargeLim));
handles.chargeLabel_txt=uicontrol(par{:},'Style','text','Position',[xP yP1 xW yH1],'String','Charge Lim');
guidata(1,handles);


function callback(hObject, varargin)

handles=guidata(hObject);
switch get(hObject,'Tag')
    case 'sector'
        handles.sector=regexp(strtrim(get(hObject,'String')),' ','split');
    case 'eDef'
        handles.eDef=regexp(strtrim(get(hObject,'String')),' ','split');
    case 'delay'
        handles.delay=str2num(get(hObject,'String'));
    case 'xLim'
        handles.xLim=str2num(get(hObject,'String'));
    case 'chargeLim'
        handles.chargeLim=str2num(get(hObject,'String'));
    case 'diff'
        handles.diff=get(hObject,'Value');
    case 'ref'
        handles.ref=get(hObject,'Value');
end
guidata(hObject,handles);
