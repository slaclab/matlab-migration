function varargout = Linac_RF_summary(varargin)
% LINAC_RF_SUMMARY M-file for Linac_RF_summary.fig
%      LINAC_RF_SUMMARY, by itself, creates a new LINAC_RF_SUMMARY or raises the existing
%      singleton*.
%
%      H = LINAC_RF_SUMMARY returns the handle to a new LINAC_RF_SUMMARY or the handle to
%      the existing singleton*.
%
%      LINAC_RF_SUMMARY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LINAC_RF_SUMMARY.M with the given input arguments.
%
%      LINAC_RF_SUMMARY('Property','Value',...) creates a new LINAC_RF_SUMMARY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Linac_RF_summary_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Linac_RF_summary_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Linac_RF_summary

% Last Modified by GUIDE v2.5 24-Feb-2008 15:23:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Linac_RF_summary_OpeningFcn, ...
                   'gui_OutputFcn',  @Linac_RF_summary_OutputFcn, ...
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


% --- Executes just before Linac_RF_summary is made visible.
function Linac_RF_summary_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
handles.sbstN=(21:30)';
handles.sbstS=strcat(cellstr(num2str(handles.sbstN)),'-S');
handles.klysN=(1:8)';
for j=handles.klysN'
    handles.klysS(j,:)=strcat(cellstr(num2str(handles.sbstN)),'-',num2str(j))';
end
handles.klysS{8,handles.sbstN == 24}='TCAV3';

sPos=-4.5;
for j=1:length(handles.sbstN)
    sbst=handles.sbstN(j);
    sPos=sPos+8.7;
    props={'Style','text','HorizontalAlignment','center','units','characters'};
    if sbst == 25
        uicontrol(props{:},'String',{'B' 'C' '2'},'FontSize',20,'ForegroundColor','blue', ...
            'FontWeight','bold','Position',[sPos 20 4.8 7.5]);
        sPos=sPos+6.5;
    end
    uicontrol(props{:},'String',num2str(sbst),'FontSize',20, ...
        'FontWeight','bold','Position',[sPos 35.3 7 1.8]);
    props1=[props {'String','0','FontSize',12,'ForegroundColor','yellow', ...
        'BackgroundColor','black'}];
    handles.hPDES(j)=uicontrol(props1{:}, ...
        'Position',[sPos 32.8 7 1.25]);
    handles.hPACT(j)=uicontrol(props1{:}, ...
        'Position',[sPos 34.05 7 1.25]);
    kPos=32.8;
    for k=handles.klysN'
        kPos=kPos-2.5;
        if mod(k,3) == 1, kPos=kPos-.3;end
        handles.hKlys(k,j)=uipanel('Title',num2str(k),'units','characters', ...
            'Position',[sPos kPos 7 2.5],'BorderType','line', ...
            'FontSize',20,'BackgroundColor','black','HighlightColor','green', ...
            'ForegroundColor','green', ...
            'BorderWidth',3,'FontWeight','bold','TitlePosition','centertop');
        if sbst == 21 && any(k == [1 2]) || sbst == 24 && k == 7
            set(handles.hKlys(k,j),'Visible','off')
        end
    end
end

handles.BC1_RF_pvs =    {
                        'ACCL:LI21:1:L1S_PDES'
                        'ACCL:LI21:1:L1S_ADES'
                        'SIOC:SYS0:ML00:AO113'
                        'SIOC:SYS0:ML00:AO112'
                                                };  % L1S phase (deg), voltage (MV), phase-target, voltage-target

handles.L3_RF_pvs =     {
                        'ACCL:LI29:0:A_SUM'
                        'ACCL:LI30:0:A_SUM'
                                                };  % L1S phase (deg), voltage (MV), S-29, S-30 flat energy

handles.FB31_pvs =      {
                        'FB31:PHAS:271:VDES'
                        'FB31:PHAS:281:VDES'
                                                };  % FB31 phases
guidata(hObject, handles);

%set(handles.START,'Value',1);
%START_Callback(handles.START, [], handles);


% UIWAIT makes Linac_RF_summary wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Linac_RF_summary_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)

tags = {'Start' 'Stop'};
colr = {'green' 'white'};
set(hObject,'String',tags{get(hObject,'Value')+1}, ...
    'BackgroundColor',colr{get(hObject,'Value')+1});
V0    = 230;     % gain per klystron in MeV (used for 24-1, 2, 3)
dEBC1 = 10.0;       % sets BC1 polar plot full scale (MeV)
dEBC2 = 2*V0;         % sets BC2 polar plot full scale (MeV)
dEFB31 = 2*V0;         % sets FB31 polar plot full scale (MeV)
while get(hObject,'Value')

% First do klystrons...
    [act,stat,swrd]=deal(zeros(size(handles.klysS)));
    [colEdge,colBack,colText,str,sizText]=deal(cell(size(handles.klysS)));
    [act(:),stat(:),swrd(:)]=control_klysStatGet(handles.klysS);
    act=bitand(act,7); % Use only bits 1, 2, 3
    isS24=handles.sbstN == 24; % SBST 24
    stat([1:3 8],isS24)=1; % 24-1, 2, 3, & 8 are EPICS controlled - ignore bad SCP status

    % Set logical status arrays
    isACC=bitget(act,1) == 1; % Klys on ACCEL
    isStat=bitget(stat,1) == 1; % Status OK
    isMOD=bitget(swrd,4) == 1; % Modulator fault
    swrd([1:3 8],handles.sbstN == 24)=0; % 24-1, 2, 3, & 8 are EPICS controlled - ignore bad SCP status
    isAMM=bitget(swrd,7) == 1; % Amplitude mean warning
    isAMJ=bitget(swrd,8) == 1; % Amplitude jitter warning
    isPHM=bitget(swrd,10) == 1; % Phase mean warning
    isPHJ=bitget(swrd,11) == 1; % Phase jitter warning
    isAOP=isAMM | isPHM | isAMJ | isPHJ; % Any amp or phase warning
    isNotAOP=bitand(swrd,bin2dec('1111100100111111')) ~= 0; % Not amp or phase warning
    isPO15=bitand(swrd,bin2dec('11111')) ~= 0; % POIP 1 - 5 error

    colEdgeList={'magenta' 'green' 'white' '' 'yellow' 'blue'};
    colBackList={'black' 'black'  [0.5 0.5 0.5] '' [0.5 0.5 0.5]};
    colEdge(:)=colEdgeList(act+1);   % Box outline color
    colBack(:)=colBackList(act+1);   % Box background color
    colText(isStat)={'green'};
    colText(~isStat & ~isACC)={'yellow'};  % if bad status, but deactivated, only show yellow warning
    colText(~isStat & isACC)={'red'}; % if bad status, AND activated, show RED alarm
    str(:)=cellstr(num2str(repmat(handles.klysN,length(handles.sbstN),1))); % Show Klys number
    str{8,isS24}='T8';
    if act(8,isS24) == 1, colEdge(8,isS24)=colEdgeList(end);end
    str(isAMJ)={'AMJ'};
    str(isPHJ)={'PHJ'};
    str(isAMM)={'AMM'};
    str(isPHM)={'PHM'};
    str(isMOD)={'MOD'};
    sizText(:)={20};
    sizText(8,isS24)={16}; % TCAV text size
    sizText(isAOP | isMOD)={10};
    colText(~isStat & ~isNotAOP)={'yellow'}; % if bad status, AND only PHM or AMM, show YELLOW alarm
    colText(isPO15 & isACC)={'red'}; % if acticated and PIOP 1-5 alarm, show RED alarm
    
    set(handles.hKlys, ...
        {'ForegroundColor'},colText(:), ...
        {'BackgroundColor'},colBack(:), ...
        {'HighlightColor'},colEdge(:), ...
        {'Title'},str(:),{'FontSize'},sizText(:));

% Now do sub-boosters...
    pTol=1;
    colAlarmList={'green' 'red'};
    colInvalidList={'yellow' 'magenta'};
    [pAct,pDes]=control_phaseGet(handles.sbstS); % Returns actual and desired phase in deg
    clrd=colInvalidList(isnan(pDes)+1)';
    clra=colAlarmList((abs(pAct-pDes) > pTol)+1)';
    clra(isnan(pAct))=colInvalidList(2);
    set(handles.hPDES, ...
        {'ForegroundColor'},clrd(:), ...
        {'String'},cellstr(num2str(pDes(:),'%5.1f')));
    set(handles.hPACT, ...
        {'ForegroundColor'},clra(:), ...
        {'String'},cellstr(num2str(pAct(:),'%5.1f')));

    pDesMean=[mean(pDes(1:4));mean(pDes(5:10))];
    pActMean=[mean(pAct(1:4));mean(pAct(5:10))];
    pTol=[1;0.5];
    clra=colAlarmList((abs(pActMean-pDesMean) > pTol)+1)';

    set(handles.MEAN_L2_PDES,'String',sprintf('%5.1f',pDesMean(1)));
    set(handles.MEAN_L3_PDES,'String',sprintf('%5.1f',pDesMean(2)));
    set(handles.MEAN_L2_PACT,'String',sprintf('%5.1f',pActMean(1)), ...
        'ForegroundColor',clra{1});
    set(handles.MEAN_L3_PACT,'String',sprintf('%5.1f',pActMean(2)), ...
        'ForegroundColor',clra{2});

% now show BC2/24-1,2,3 phasor diagram...
    BC2_phases=control_phaseGet(handles.klysS(1:3,handles.sbstN == 24));
    use=find(isACC(1:3,handles.sbstN == 24));
    use=use(1:min(2,end));
    if length(use) == 2
        showPhasor(handles.BC2PLOT,BC2_phases(use),V0,0,0,'BC2',dEBC2);
    else
        compass(handles.BC2PLOT,[0 0 0 0]);
    end

% now show BC1/L1S phasor diagram...
    try
      BC1_RF = lcaGet(handles.BC1_RF_pvs);
    catch
      BC1_RF = NaN(size(handles.BC1_RF_pvs));
    end
    showPhasor(handles.BC1PLOT,BC1_RF(1),BC1_RF(2),BC1_RF(3),BC1_RF(4),'BC1',dEBC1);

    
% now show L3/29,30 phasor diagram...
    L3_phases=control_phaseGet({'29-0';'30-0'});
    try
      L3_RF = lcaGet(handles.L3_RF_pvs);
    catch
      L3_RF = NaN(size(handles.L3_RF_pvs));
    end
%    amp=V0*sum(isACC(:,ismember(handles.sbstN,[29 30])))';
    showPhasor(handles.FB31PLOT,L3_phases,L3_RF,0,0,'L3',sum(L3_RF));

% now show FB31 phasor diagram...
%    try
%        FB31_phases=lcaGet(handles.FB31_pvs);
%    catch
%        FB31_phases=NaN(size(handles.FB31_pvs));
%    end
%    amp=V0*sum(isACC(:,ismember(handles.sbstN,[27 28])))';
%    showPhasor(handles.FB31PLOT,FB31_phases,amp,0,0,'FB31',sum(amp));

% Now show date/time and flash button to show heartbeat
    set(handles.DATE_TIME,'String',datestr(now,'dd-mmm-yyyy HH:MM:SS'))
    set(hObject,'BackgroundColor','green');
    pause(0.2);
    drawnow;
    set(hObject,'BackgroundColor','white');
    pause(.1)
    guidata(hObject,handles);
end
set(hObject,'BackgroundColor','green');


function showPhasor(ax, ph, amp, phRef, ampRef, str, maxV)

dVThr=0.9;
PRef=ampRef*exp(i*phRef*pi/180);
P=amp.*exp(i*ph*pi/180)-PRef;
PS=sum(P);
E=real(PS);
C=i*imag(PS);
col={'y-' 'g-' 'b-' 'c-'}; % Color for phasors, sum, energy and compression
col(isnan([PS PS E C]))={'m--'}; % Magenta if invalid
col(abs([0 PS E C]) > maxV*dVThr)={'r-'}; % Red if high warning
compass(ax,maxV,'w.');
hold(ax,'on');
% Plot E and C if more than one phasor
if length(P) > 1
    h=compass(ax,P,col{1});
    if ~isnan(PS)
        set(h(1),'Color',[.9 .9 0]);
        set(h(end),'Color',[1 .7 0]);
    end
    h(end+1)=compass(ax,E,col{3});
    h(end+1)=compass(ax,C,col{4});
else
    h=compass(ax,PS,col{2});
end
hold(ax,'off');
ylabel(ax,[str ' Energy (MeV)'],'Position',[maxV*1.5 0.01 1],'FontSize',9);
set(h,'LineWidth',3);
set(ax,'FontSize',9);
