function varargout = Phase_Scans(varargin)

% PHASE_SCANS M-file for Phase_Scans.fig
%      PHASE_SCANS, by itself, creates a new PHASE_SCANS or raises the
%      existing
%      singleton*.
%
%      H = PHASE_SCANS returns the handle to a new PHASE_SCANS or the handle to
%      the existing singleton*.
%
%      PHASE_SCANS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHASE_SCANS.M with the given input arguments.
%
%      PHASE_SCANS('Property','Value',...) creates a new PHASE_SCANS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Phase_Scans_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Phase_Scans_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Phase_Scans

% Last Modified by GUIDE v2.5 06-Nov-2020 04:54:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Phase_Scans_OpeningFcn, ...
                   'gui_OutputFcn',  @Phase_Scans_OutputFcn, ...
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


% --- Executes just before Phase_Scans is made visible.
function Phase_Scans_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Phase_Scans (see VARARGIN)

% Choose default command line output for Phase_Scans
handles.output = hObject;

handles.phScanPV='SIOC:SYS0:ML00:AO017'; % PV to indicate running status of GUI
handles.beamOffPV='IOC:BSY0:MP01:PCELLCTL';
handles.fancyPV='ACCL:LI22:1:FANCY_PH_CTRL';
handles.abstrPV='ACCL:LI22:1:ABSTR_ACTIVATE';
handles.beamRatePV=['EVNT:' 'SYS0' ':1:' 'LCLS' 'BEAMRATE'];
handles.softBeamRatePV = 'EVNT:SYS0:1:NC_SOFTRATE';
handles.hardBeamRatePV = 'EVNT:SYS0:1:NC_HARDRATE';
handles.scanMode=0;
handles.fitMode=0;
handles.pulseSteal=0;
handles.BSA=0;
handles.CLTS=0;
handles.undoData=[];
set(handles.UNDO,'Enable','off');
handles.dropKlys=[];
lcaPut(strcat(handles.phScanPV,{'.DESC';'.EGU'}),{'Phase Scan GUI running';' '});
lcaPut(strrep(handles.phScanPV,':AO',':SO0'),'Phase Scans');
configFile = fullfile(getenv('MATLABDATAFILES'),'script','Phase_Scan.mat');
handles.save_cmnd   = ['save ' configFile ' h1'];
handles.load_cmnd   = ['load ' configFile];
propList={'DATETIME' 'NAVG' 'RANGE' 'NSTEPS' 'FINALPHASE'};
nameList={'SCHOTTKY' 'L0A' 'L0B' 'TCAV0' 'L1S' 'L1X' 'L2' 'L3'};

% To add parameters to the list, comment out this next "if" and its "end"
% and run the GUI ones, then uncomment (+ maybe add the parameters to the save command)
if ~exist(configFile,'file')
  h1.laser_select = get(handles.LASRSEL,'Value');
  for name=nameList
      for prop=propList
          h1.(lower([prop{:} '_' name{:}]))=get(handles.([prop{:} '_' name{:}]),'String');
      end
  end
  h1.finalphase_k = zeros(10*9,1);    % one finalphase per 21-30 klystron (assumes 8 klys per sector)
  h1.nsteps_k     = 9*ones(10*9,1);   % one nsteps per 21-30 klystron (assumes 8 klys per sector)
  h1.navg_k       = 5*ones(10*9,1);   % one navg per 21-30 klystron (assumes 8 klys per sector)
  h1.range_k      = 30*ones(10*9,1);  % one range per 21-30 klystron (assumes 8 klys per sector)
  h1.datetime_k   = char(ones(10*9,1)*'        (no data)        ');   % e.g., '21-JUN-2008 10:21:34: BAD'
  eval(handles.save_cmnd)
end

eval(handles.load_cmnd)

% Set to presenty used laser.
%h1.laser_select=lcaGet('MIRR:LR20:111:M19_STATE',0,'double') == 0; %Use M19 mirror; nonexistent in two-bucket two laser setup
%h1.laser_select=lcaGet('SHTR:LR20:100:UV_SHUTTER',0,'double') == 1; %Use coherent 1 shutter (coh. 1 is now straight ahead laser)
h1.laser_select = lcaGet('LASR:LR20:1:UV_LASER_MODE',0,'double');

set(handles.LASRSEL,'Value',h1.laser_select);
LASRSEL_Callback(handles.LASRSEL,[],handles);
for name=nameList
    for prop=propList
        set(handles.([prop{:} '_' name{:}]),'String',h1.([lower(prop{:}) '_' lower(name{:})]));
    end
end
update_SCP(handles);
gui_statusDisp(handles.MSGBOX,'Phase scans ready to go...');
for name={'L2' 'L3'}
    set(handles.([name{:} '_ACT_DEACT']),'String',' ');
    for j='123456'
        set(handles.([name{:} '_KLYS' j]),'String',' ');
    end
end

handles = SECTOR_Callback(handles.SECTOR,[],handles);

handles.nochanges = get(handles.NOCHANGES,'Value');
handles.exportFig=[];
set([handles.SETL2 handles.SETL3],'Visible','off');

defaultFinalPhaseL23 = round(lcaGetSmart(['ACCL:LI22:1:PDES'; 'ACCL:LI25:1:PDES']));

set(handles.FINALPHASE_L2,'String', defaultFinalPhaseL23(1));
set(handles.FINALPHASE_L3,'String', defaultFinalPhaseL23(2));
%handles=appInit(hObject,handles);

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes Phase_Scans wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Phase_Scans_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close Phase_Scans.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% -------------------------------------------------------------------------
function handles = appInit(hObject, handles)

pos=get(hObject,'Position');
set(hObject,'Position',pos+[0 -2 0 2]);
h=[handles.L0A handles.L0AZERO handles.L0ACAL handles.FINALPHASE_L0A ...
    handles.NAVG_L0A handles.RANGE_L0A handles.NSTEPS_L0A handles.DATETIME_L0A ...
    handles.text31 handles.text6 handles.text7 handles.text8];
hNew=copyobj(h,hObject);
posN=cell2mat(get(hNew,'Position'));
posN(:,2)=posN(:,2)+pos(4)-posN(1,2);
set(hNew,{'Position'},num2cell(posN,2));

n=2;nStr=num2str(n);
names={'scan' 'zero' 'cal' 'finalPhase' 'nAvg' 'range' 'nSteps' 'dateTime'};
exts=[repmat({'_btn'},1,3) repmat({'_txt'},1,5)];
set(hNew(1:8),{'Tag'},strcat(names,nStr,exts)');

%set(hNew(1:3),{'Tag'},strcat({'scan' 'zero' 'cal'},nStr,'_btn'));
%set(hNew(4:8),{'Tag'},strcat({'finalPhase' 'nAvg' 'range' 'nSteps' 'dateTime'},num2str(n),'_txt'));

set(h, ...
    'Callback',strcat('Phase_Scans','(''',names,exts, ...
    '_Callback'',gcbo,[],guidata(gcbo),''',nStr,''')')','Visible','on');

newTags=strcat(names,nStr,exts);
for j=1:numel(newTags)
    handles.(newTags{j})=hNew(j);
end


function [PL2,pdesL2,dpdesL2,pactL2,dpactL2,PL3,pdesL3,dpdesL3,pactL3,dpactL3] = update_SCP(handles)

set(handles.DATE_TIME,'String',datestr(now));
[PL2,pdesL2,dpdesL2,pactL2,dpactL2] = get_SBST_phases(handles,'L2');
[PL3,pdesL3,dpdesL3,pactL3,dpactL3] = get_SBST_phases(handles,'L3');
drawnow;


function [pDesList,pDes,dpDes,pAct,dpAct] = get_SBST_phases(handles, name)

sbst={'21' '22' '23' '24'};
if strcmp(name,'L3')
    sbst={'25' '26' '27' '28' '29' '30'};
end

globalphase = control_phaseGet(name);
[pActList,pDesList]=control_phaseGet(strcat(sbst,'-S'));
pDes  = mean(pDesList) + globalphase;
dpDes = std(pDesList);
pAct  = mean(pActList) + globalphase;
dpAct = std(pActList);

if abs(pAct - pDes) > 1
  clr = 'red';
else
  clr = 'green';
end
str = sprintf('%5.1f+-%3.1f',pDes,dpDes);
set(handles.(['PDES_' name]),'String',str)
str = sprintf('%5.1f+-%3.1f',pAct,dpAct);
set(handles.(['PACT_' name]),'String',str,'ForegroundColor',clr);


function [iok, rate] = checkRate(handles, name, quiet)
iok=1;
rate = lcaGet(handles.beamRatePV);    % rep. rate [Hz]
if ismember(name,{'Schottky' 'TCAV0'}) && rate > 10
  iok=0;
  if ~quiet
    warndlg([name ' does not run with beam rate > 10 Hz - please switch to 10 Hz'],'RATE TOO HIGH');
  end
  gui_statusDisp(handles.MSGBOX,'Scan cancelled due to high rate');
end
if rate < 10
  iok=0;
  if ~quiet
    warndlg('Cannot do scan at <10 Hz rate','RATE TOO LOW');
  end
  gui_statusDisp(handles.MSGBOX,'Scan cancelled due to low rate');
end


function checkNoChanges(handles, quiet)

if handles.nochanges
  if ~quiet
    warndlg('"No changes" toggle is selected, therefore no corrections will be applied','CORRECTIONS ARE SWITCHED OFF')
  end
  gui_statusDisp(handles.MSGBOX,'No changes toggles is ON');
end


function [iok, bpm_pv] = checkBend(handles, name, bendPV, tol, bendName, bpm_pvs, quiet)

bpm_pvs=cellstr(bpm_pvs);
bpm_pv       = bpm_pvs{1}; % default BPM
iok=1;

BACT        = lcaGet(bendPV);
if BACT < tol % if bend off
  if length(bpm_pvs) > 1 % if alternate BPM available
    bpm_pv=bpm_pvs{2}; % use second one
  else % if not, cancel scan
    if ~quiet
      warndlg([bendName ' bends < ' num2str(tol) ' kG-m - no ' name ' phase scan possible - quitting.'],[bendName ' BENDS OFF']);
    end
    gui_statusDisp(handles.MSGBOX,[name ' scan failed']);
    iok=0;
  end
end


function nBPM = addBPMs(nBPM)

switch nBPM
    case 'BPMS:IN20:731'
        nBPM={'BPMS:IN20:631' 'BPMS:IN20:651' 'BPMS:IN20:731'};
    case 'BPMS:IN20:945'
        nBPM={'BPMS:IN20:651' 'BPMS:IN20:925' 'BPMS:IN20:945'};
    case 'BPMS:IN20:581' % TCAV0
    case 'BPMS:LI21:233'
        nBPM={'BPMS:LI21:161' 'BPMS:LI21:201' 'BPMS:LI21:233'};
    case 'BPMS:LI24:801'
        nBPM={'BPMS:LI24:601' 'BPMS:LI24:701' 'BPMS:LI24:801'};
    case 'BPMS:LTUH:250'
        nBPM={'BPMS:LTUH:120' 'BPMS:LTUH:190' 'BPMS:LTUH:250'};
end


function [fdbkList, iok, bpm_pv] = getFeedBackRegion(handles, name, nameMAD, quiet)

iok=1;bpm_pv='';
switch nameMAD(:,1:min(end,2))
    case 'L0'
        [iok,bpm_pv]=checkBend(handles,name,'BEND:IN20:751:BACT',0.05,'DL1',{'BPMS:IN20:731' 'BPMS:IN20:945'},quiet);
    case 'TC'
        bpm_pv='BPMS:IN20:581';
    case 'L1'
        [iok,bpm_pv]=checkBend(handles,name,'BEND:LI21:231:BACT',0.05,'BC1','BPMS:LI21:233',quiet);
    case {'L2' '21' '22' '23' '24'}
        [iok,bpm_pv]=checkBend(handles,name,'BEND:LI24:790:BACT',1,'BC2','BPMS:LI24:801',quiet);
    case {'L3' '25' '26' '27' '28' '29' '30'}
        if ~handles.CLTS
            bpm_pv='BPMS:LTUH:250';
        else 
            bpm_pv = 'BPMS:CLTS:570';
        end
    end

fdbkList=control_fbNames(nameMAD);


function iok = checkFeedBack(handles, name, nameMAD, quiet, noSrcCheck)

if nargin < 5, noSrcCheck=0;end

[d,d,d,d,d,d,d,d,fdbk_pv,disable_pv]=control_phaseNames(nameMAD);

fdbk_on_off  = lcaGet(fdbk_pv,0,'double');
disabled     = lcaGetSmart(disable_pv,0,'double');
iok=1;
if fdbk_on_off == 0
  iok=0;
  if ~quiet
    warndlg([name ' RF feedback is OFF - quitting.'],[name ' FDBK OFF']);
  end
  if noSrcCheck, return, end
  gui_statusDisp(handles.MSGBOX,[name ' scan failed']);
  return
end
if disabled == 1 % Works for NaN
  iok=0;
  if ~quiet
    warndlg([name ' RF feedback is DISABLED - quitting.'],[name ' FDBK DISABLED']);
  end
  if noSrcCheck, return, end
  gui_statusDisp(handles.MSGBOX,[name ' scan failed']);
  return
end
%{
if ~strcmp(nameMAD,'LASER') || noSrcCheck, return, end
source = lcaGet(strcat(model_nameConvert(nameMAD),'_SOURCE'));  % check button on LLRF panel is set to "2856MHz Lsr Os"
if ~strncmp(source,'285',3)
  iok=0;
  if ~quiet
    warndlg('Cannot do Schottky scan unless laser feedback input source is set to "2856MHz Lsr Os". (see LASER LLRF panel)','NOT READY');
  end
  gui_statusDisp(handles.MSGBOX,'Schottky failed');
end
%}


function iok = checkPhaseScanStatus(handles, quiet)

iok=1;
if lcaGet(handles.phScanPV)
  if ~quiet
    yn = questdlg({'Phase scan is already active!' 'Continue anyway?'},'Phase scan running');
    iok=strcmp(yn,'Yes');
  end
end
if ~iok, return, end
lcaPut(handles.phScanPV,1);pause(1.); % Set phase scan run PV to 1 and wait


function scanFinish(hObject, handles, name, nameH, fig, setok, quiet, fdbkList, fdbkListOn, iKLYS, result)

set(handles.(nameH),'BackgroundColor', handles.color,'String',[name ' phase scan']);
str_res={'completed' 'failed' 'cancelled'};
gui_statusDisp(handles.MSGBOX,[name ' scan ' str_res{result+1}]);

if result == 0
    dt = datestr(now);
    ok_str={'BAD' 'OK'};
    str = [dt ': ' ok_str{setok+1}];
    eval(handles.load_cmnd);
    if iKLYS
        h1.datetime_k(iKLYS,end) = ' ';
        h1.datetime_k(iKLYS,1:length(str)) = str;
    else
        h1.(['datetime_' lower(nameH)])=str;
    end
    eval(handles.save_cmnd);
    set(handles.(['DATETIME_' nameH]),'String',str);

    handles=guidata(hObject);
    handles.exportFig=fig; % Added 08/05/2007, H. Loos
    guidata(hObject, handles);

    if strcmp(name,'Schottky'), name='LASR';end
    [d,is]=control_phaseNames(name);
    if strcmp(nameH,'SCAN'), name=nameH;end
    if ~handles.nochanges && setok
        feval([name 'ZERO_Callback'],hObject, [], handles, quiet);
    end
    if is.PAC, lcaPut(strcat('ACCL:LI',{'24:L2';'29:L3'},':RESYNC'),1);pause(1.);end
end

if handles.pulseSteal, control_pulseSteal(0);end
lcaPut(fdbkList,fdbkListOn);                    % restore feedbacks to their initial state (ON or OFF)
lcaPut(handles.phScanPV,0);pause(1.); % Set phase scan run PV to 0 and wait

% Reset invisible start button.
gui_acquireStatusSet(hObject,handles,0);


function SCHOTTKY_Callback(hObject, eventdata, handles, quiet)

if nargin < 4, quiet=0;end
name='Schottky';
nameH='SCHOTTKY';
MATLAB_pv   = 'SIOC:SYS0:ML00:AO931';
fig=100;
handles.color = get(handles.SCHOTTKY, 'BackgroundColor');
nameLas={'LASER' 'LASER2'};
nameMAD = nameLas{get(handles.LASRSEL,'Value')+1};
init_phase_shift = str2double(get(handles.(['RANGE_' nameH]),'String'));
phase_offset     = str2double(get(handles.(['FINALPHASE_' nameH]),'String'));
navg        = str2double(get(handles.(['NAVG_' nameH]),'String'));

[sys, accelerator] = getSystem;

if strcmp(accelerator, 'NLCTA')
    schottky_scan_NLCTA(phase_offset,initial_phase_shift,navg,tag,handles);
    return
end

[fdbkList,iok]=getFeedBackRegion(handles,name,nameMAD,quiet);
if ~iok, return, end

[iok,rate]=checkRate(handles,name,quiet);
if ~iok, return, end
checkNoChanges(handles,quiet);

%Check selected laser against active laser mode
laserModeStr = lcaGetSmart('LASR:LR20:1:UV_LASER_MODE');
%laserModeStr = {'COHERENT #2'} %For testing
laserMode = strfind({'COHERENT #1' 'COHERENT #2' 'BOTH' 'BOTH' 'NONE'},laserModeStr{:});
laserMode = find(cellfun(@any,laserMode));

if get(handles.LASRSEL,'Value')+1 ~= laserMode,
    guiLaserName = get(handles.LASRSEL,'String');
    mixedOk = questdlg(sprintf('%s is selected on GUI but %s is active. Continue?',...
        guiLaserName,laserModeStr{:}),'Mixed Measurement?', 'Yes','No', 'No');
   if ~strcmp(mixedOk, 'Yes')
        gui_statusDisp(handles.MSGBOX,[name ' scan NOT started - requested laser not same as UV_LASER_MODE PV']);
        return
    end
end

gui_statusDisp(handles.MSGBOX,[name ' scan started - please wait...']);


iok=checkFeedBack(handles,name,nameMAD,quiet);
if ~iok, return, end

iok=checkPhaseScanStatus(handles,quiet);
if ~iok, return, end

% Press invisible start button.
gui_acquireStatusSet(hObject,handles,1);

fdbkListOn=lcaGet(fdbkList,1,'double'); % get status of feedbacks
lcaPut(fdbkList,0);pause(1.);           % turn off feedbacks temporarily

handles.BPM_attn_pv = 'IOC:IN20:BP01:QANN';
handles.BPM_attn = lcaGet(handles.BPM_attn_pv,1,'double');  % get BPM attenuation setting (nC)
lcaPut(handles.BPM_attn_pv,2*handles.BPM_attn); % bump charge attn setting up by factor of 2 for Schottky scan
set(handles.(nameH),'BackgroundColor','white');
try
    [setok,newphase] = schottky_scan(nameMAD,phase_offset,init_phase_shift,navg,rate,nameH,handles);
    pause(.1);
    lcaPut(MATLAB_pv,newphase);
    %Zero bucket offset for two bunch mode
    switch laserMode
        case 'COHERENT #1'
            bucketOffset = lcaGetSmart('OSC:LR20:20:POC');
            lcaPutSmart('SIOC:SYS0:ML03:AO123', bucketOffset);
        case 'COHERENT #2'
            bucketOffset = lcaGetSmart('OSC:LR20:10:POC');
            lcaPutSmart('SIOC:SYS0:ML03:AO125',bucketOffset );
    end
             
catch err
    disp(err);
    disp(err.stack);
    setok=0;
    disp('Schottky failed');
    keyboard
end
lcaPut(handles.BPM_attn_pv,handles.BPM_attn);           % restore BPM attenuation factor to original, before scan
scanFinish(hObject,handles,name,nameH,fig,setok,quiet,fdbkList,fdbkListOn,0,0);


% ---------------------------------------------------------------------
function scan(hObject, handles, name, MATLAB_pv, fig, quiet)

if any(strfind(name,'-'))
    if ~strcmp(get(handles.SCAN,'Enable'),'on'), return, end
    if ~strncmp(name(4:end),'S',1) && ~strncmp(name(4:end),'0',1) && ~(bitand(control_klysStatGet(name), 1) || bitand( control_klysStatGet(name, 2), 1)), return, end
end
if nargin < 6, quiet=0;end
[nameEPICS,is]=control_phaseNames(name);

isKlys=is.SLC | is.PAC | is.KLY;
nameMAD=name;nameH=name;
if isKlys, nameH='SCAN';end
nameL23='L2';if handles.sectorN > 24, nameL23='L3';end
if handles.sectorN == 29, nameL23='29-0';end
if handles.sectorN == 30, nameL23='30-0';end
[fdbkList,iok,bpm_pv]=getFeedBackRegion(handles,name,nameMAD,quiet);
if handles.fitMode || 1, bpm_pv=addBPMs(bpm_pv);end
if ~iok, return, end
%if handles.pulseSteal, fdbkList=setdiff(fdbkList,'IOC:BSY0:MP01:BYKIKCTL');end
if handles.pulseSteal, fdbkList={handles.phScanPV;'FBCK:FB04:LG01:MODE'};end
if is.PAC, fdbkList=[fdbkList;{handles.abstrPV}];end
if is.KLY, fdbkList=[fdbkList;strcat(nameEPICS,':PTRM')];end
if ismember(name, strcat('21-', {'3', '4', '5','6','7','8'}) )  %Disable L2 Launch if one of these stations
   fdbkList = [ fdbkList; 'FBCK:FB01:TR04:MODE'];
end
[iok,rate]=checkRate(handles,name,quiet);
if ~iok, return, end
checkNoChanges(handles,quiet);
gui_statusDisp(handles.MSGBOX,[name ' scan started - please wait...']);
finalphase  = str2double(get(handles.(['FINALPHASE_' nameH]),'String'));
pm_range    = str2double(get(handles.(['RANGE_' nameH]),'String'));
phase_steps = str2double(get(handles.(['NSTEPS_' nameH]),'String'));
navg        = str2double(get(handles.(['NAVG_' nameH]),'String'));

% Special code for EPICS, L2/3, KLYS & SBST

% Check Klys final phase.
if (is.SLC || is.KLY) && handles.sectorN < 29
  if finalphase                         % if final phase of this klys is not 0 ...
    ynL = questdlg('The "Final phase" of this klystron or sub-booster is not zero.  Do you want to continue?','FINAL PHASE WARNING');
    if ~strcmp(ynL,'Yes')
      gui_statusDisp(handles.MSGBOX,[name ' scan cancelled']);
      return
    end
  end
end

% Query for L2,3 phase scan.
if is.L23 && ~quiet && ~handles.scanMode
    sbst='21-24';if strcmp(name,'L3'), sbst='25-30';end
    yn = questdlg(['This will set ' name ' (' sbst ' SBSTs) near crest, scan the phase ' ...
        'there, set precisely to crest, then set the ' name ' phase back OFF crest ' ...
        '(by ' num2str(finalphase) ' deg).  Do you want to continue?'],'CAUTION');
    if ~strcmp(yn,'Yes')
        gui_statusDisp(handles.MSGBOX,[name ' scan cancelled']);
        return
    end
end

% Set default values
phMax=Inf;                              % max phase change to crest
E1=[];E0=[];                            % energy gain of device
wait=1;                                 % pause to change phase [sec]
phTol=0.5;                              % phase tolerance to go to crest
zeroPhaseDes=0;                         % nominal crest/zero phase
order=2;                                % order of fit polynomial
setE=0;                                 % change energy of device
if epicsSimul_status, wait=0.01;end

if is.TCV, phTol=2;zeroPhaseDes=90;order=1;end
if is.L1X, phTol=-1;zeroPhaseDes=-180;end
if is.L23, phTol=0.05;end
if is.SLC || is.KLY, wait=2;E1=8*230;E0=0;end
if isKlys, phTol=0;end
if strcmp(name,'L0B') || is.L1S || is.L1X || is.L23 || is.SLC || is.KLY, setE=1;end

if is.L2
    phMax=44;
    E0 = 1E0*lcaGet('SIOC:SYS0:ML00:AO123');      % BC1 energy (MeV)
    E1 = 1E3*lcaGet('SIOC:SYS0:ML00:AO124');      % BC2 energy (MeV)
end
if is.L3
    phMax=30;
    E0 = 1E3*lcaGet('SIOC:SYS0:ML00:AO124');      % BC2 energy (MeV)
    E1 = 1E3*lcaGet('SIOC:SYS0:ML00:AO122');      % BSY energy (MeV)
end
if is.FBK % L0A, L0B, TCAV0, L1X, L1S
    iok=checkFeedBack(handles,name,nameMAD,quiet);
    if ~iok, return, end
end
if isKlys && strcmp(nameL23,'L3')
    flag = 0;
    bc1 = bitand(control_klysStatGet(name, 1), 1)
    bc2 = bitand(control_klysStatGet(name, 2), 1)
    if handles.CLTS && ~bc2, flag = 1, end
    if ~handles.CLTS && ~bc1, flag = 2, end
    warnings = {'is not active on beamcode 2. Do you want to continue with a CLTS phase scan?', 'is not active on beamcode 1. Do you want to continue with a DL2 phase scan?'}
    if flag
        yn = questdlg([name ' ' warnings{flag}], 'CAUTION');
        if ~strcmp(yn, 'Yes')
            gui_statusDisp(handles.MSGBOX,[name ' scan cancelled'])
            return
        end
    end
end
        
% Special code end

iok=checkPhaseScanStatus(handles,quiet);
if ~iok, return, end

% Press invisible start button.
gui_acquireStatusSet(hObject,handles,1);

fdbkListOn=lcaGet(fdbkList,1,'double'); % get status of feedbacks
lcaPut(fdbkList,0);pause(1.);           % turn off feedbacks temporarily
if handles.pulseSteal, lcaPut(handles.phScanPV,0);control_pulseSteal(1);end
set(handles.(nameH),'BackgroundColor','white');

L_PDES=0;if is.SLC || is.KLY, L_PDES = control_phaseGet(nameL23);end
[d,initial_phase,d,present_energy] = control_phaseGet(nameMAD);       % get present phase (L2/3 phase from Joe's phase_control.m PV) [degS]

% Do UNDO setup
set(handles.UNDO,'Enable','on','String',['Undo ' name]);
handles.undoData=[];
handles.undoData.name=nameMAD;
handles.undoData.pDes=initial_phase;
guidata(hObject,handles);

if is.PAC
    finalphase=initial_phase;
    set(handles.FINALPHASE_SCAN,'String',num2str(finalphase));
end
initial_phase=initial_phase+L_PDES;
finalphase=finalphase+L_PDES;
dPhase = initial_phase - zeroPhaseDes;

if abs(dPhase) > phTol            % don't go on-crest if already there
    yn = 'Yes';iok = 1;
    if ~is.TCV && is.FBK
        if abs(dPhase) > 10 && ~is.L1S && ~is.L1X
            if ~quiet
                str='Present |phase| or "Last crest |phase|"';
                yn = questdlg([str ' is > 10 degrees.  This is unusual for ' name '.  Do you want to continue?'],'INITIAL PHASE WARNING');
            else
                yn = 'No';
            end
        end
    end
    if strcmp(yn,'Yes') && ~handles.scanMode
        % jump to crest phase based on <PDES>, dropping klystrons where needed (L2,3)
        iok = control_phaseEnergySet(handles,nameMAD,[],E1-E0,dPhase,0,setE,phMax);
        handles=guidata(hObject);
        if ~is.TCV
            pause(2*wait);
        end
    end
    result=0;
    if ~iok, result=1;end
    if ~strcmp(yn,'Yes'), result=2;end
    if result > 0
        scanFinish(hObject,handles,name,nameH,fig,0,quiet,fdbkList,fdbkListOn,0,result);
        return
    end
end

if is.L23
    gui_statusDisp(handles.MSGBOX,[name ' phase scan now in progress - please wait...']);
end
% now phase is near crest (zero-crossing for TCAV0) (based on last scan) and voltage is scaled down to compensate (L0B, L1S)
scanMode=[handles.scanMode (1:handles.pulseSteal)*2 -(1:handles.BSA)];
[setok,result_phase,gain,handles.data] = phase_scan_new(handles,pm_range,phase_steps,navg,wait,rate,bpm_pv,nameMAD,order,nameH,scanMode,fig);
guidata(hObject,handles);
% now phase is accurately at crest (zero-crossing for TCAV0) (if good scan) & amplitude may have been set to zero the BPM X (L0B, L1S)

presentPhase=zeroPhaseDes;
if handles.scanMode, presentPhase=initial_phase;dPhase=0;setE=0;end

zero_phase=result_phase-presentPhase+zeroPhaseDes;

if is.SLC || is.KLY, pause(2);end
if is.SLC || is.KLY || is.L23, zero_phase=0;end
if setok                       % if crest phase was accurate enough...
    if ~isempty(MATLAB_pv)
        lcaPut(MATLAB_pv,zero_phase);    % store latest crest (zero for TCAV) phase reading [degS]
    end
    if is.L1X
        setE=0;
        control_ampSet(nameMAD,present_energy);  % restore original amplitude
    end
    dPhase=finalphase-presentPhase;
    nameK=control_klysName(nameMAD);
    if ismember(model_nameSplit(nameK),{'KLYS' 'SBST'})
        lcaPutSmart(strcat(nameK,':PHASSCANERR'),zero_phase);
        lcaPutSmart(strcat(nameK,':PHASSCANTS'),(now - datenum('1/1/1990'))*24*60*60);
        lcaPutSmart(strcat(nameK,':EMEASURED'),gain);
    end
end

% jump back off crest phase based on final phase, adding klystrons where needed
if abs(finalphase) > 0.05 || handles.scanMode             % don't do "go_off_crest" routine if final phase is near zero
    control_phaseEnergySet(handles,nameMAD,[],E1-E0,0,dPhase,setE,phMax);
end

if (is.SLC || is.KLY) && ~epicsSimul_status, pause(5.);end
iKLYS=0;if isKlys, iKLYS=getKlysInd(handles);end
scanFinish(hObject,handles,name,nameH,fig,setok,quiet,fdbkList,fdbkListOn,iKLYS,0);
if is.L23
    update_SCP(handles);
end


function L0A_Callback(hObject, eventdata, handles, varargin)
handles.color = get(handles.L0A, 'BackgroundColor');
scan(hObject,handles,'L0A','SIOC:SYS0:ML00:AO932',200,varargin{:});


function L0B_Callback(hObject, eventdata, handles, varargin)
handles.color = get(handles.L0B, 'BackgroundColor');
scan(hObject,handles,'L0B','SIOC:SYS0:ML00:AO933',300,varargin{:});


function TCAV0_Callback(hObject, eventdata, handles, varargin)
handles.color = get(handles.TCAV0, 'BackgroundColor');
scan(hObject,handles,'TCAV0','SIOC:SYS0:ML00:AO934',400,varargin{:});


function L1S_Callback(hObject, eventdata, handles, quiet)
handles.color = get(handles.L1S, 'BackgroundColor');
if nargin < 4, quiet=0;end
fdbkList={ ...
 'FBCK:LNG3:1'; ...   % longitudinal feedback in the injector (0=OFF,1=ON)
 'FBCK:LNG5:1'; ...   % longitudinal feedback in the injector (0=OFF,1=ON)
 'FBCK:LNG6:1'; ...   % longitudinal feedback in the injector (0=OFF,1=ON)
 'FBCK:LNG7:1'; ...   % longitudinal feedback in the injector (0=OFF,1=ON)
 'FBCK:LNG8:1'; ...   % longitudinal feedback in the injector (0=OFF,1=ON)
 'FBCK:LNG9:1'; ...   % longitudinal feedback in the injector (0=OFF,1=ON)
 };
enabled=lcaGet(strcat(fdbkList,':ENABLE'),1,'double');
state=lcaGet(strcat(fdbkList,':STATE'),1,'double');
if any(enabled & state)
  if ~quiet
    yn = questdlg('BC1 bunch length feedback is ON.  Scanning L1S phase now is not so useful, unless you want to GOLD it.  Do you really want to continue?','BC1 BUNCH LENGTH FEEDBACK IS ON!');
  else
    yn = 'No';
  end
  if ~strcmp(yn,'Yes')
    gui_statusDisp(handles.MSGBOX,'L1S scan cancelled');
    return
  end
end
scan(hObject,handles,'L1S','SIOC:SYS0:ML00:AO935',500,quiet);


function L1X_Callback(hObject, eventdata, handles, varargin)
handles.color = get(handles.L1X, 'BackgroundColor');
scan(hObject,handles,'L1X','SIOC:SYS0:ML00:AO936',600,varargin{:});


function L2_Callback(hObject, eventdata, handles, varargin)
handles.color = get(handles.L2, 'BackgroundColor');
scan(hObject,handles,'L2',[],700,varargin{:});


function L3_Callback(hObject, eventdata, handles, varargin)
handles.color = get(handles.L3, 'BackgroundColor');
scan(hObject,handles,'L3',[],800,varargin{:});


function SCAN_Callback(hObject, eventdata, handles, varargin)

scan(hObject,handles,handles.klysName,[],900,varargin{:});


function inputTxt(hObject, handles, prop, name)

eval(handles.load_cmnd);
if strcmp(name,'SCAN')
    iKLYS=getKlysInd(handles);
    h1.([prop '_k'])(iKLYS) = str2double(get(hObject,'String'));
else
    h1.([prop '_' lower(name)]) = get(hObject,'String');
end
eval(handles.save_cmnd);
guidata(hObject, handles);


function inputFinalPhase(hObject, handles, name, tol)

finalphase  = str2double(get(hObject,'String'));
name2=[' for ' name];
if strcmp(name,'SCAN'), name2='';end
if abs(finalphase) > tol
  warndlg(['Phase is out of range' name2],'OUT OF RANGE');
  set(handles.(['FINALPHASE_' name]),'String',0);
  return
end
inputTxt(hObject,handles,'finalphase',name);


function FINALPHASE_SCHOTTKY_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'finalphase','SCHOTTKY');


function NAVG_SCHOTTKY_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'navg','SCHOTTKY');


function RANGE_SCHOTTKY_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'range','SCHOTTKY');


function NSTEPS_SCHOTTKY_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'nsteps','SCHOTTKY');


function FINALPHASE_L0A_Callback(hObject, eventdata, handles)

inputFinalPhase(hObject,handles,'L0A',8);


function NAVG_L0A_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'navg','L0A');


function RANGE_L0A_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'range','L0A');


function NSTEPS_L0A_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'nsteps','L0A');


function FINALPHASE_L0B_Callback(hObject, eventdata, handles)

inputFinalPhase(hObject,handles,'L0B',45);


function NAVG_L0B_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'navg','L0B');


function RANGE_L0B_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'range','L0B');


function NSTEPS_L0B_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'nsteps','L0B');


function FINALPHASE_TCAV0_Callback(hObject, eventdata, handles)

inputFinalPhase(hObject,handles,'TCAV0',180);


function NAVG_TCAV0_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'navg','TCAV0');


function RANGE_TCAV0_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'range','TCAV0');


function NSTEPS_TCAV0_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'nsteps','TCAV0');


function FINALPHASE_L1S_Callback(hObject, eventdata, handles)

inputFinalPhase(hObject,handles,'L1S',60);


function NAVG_L1S_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'navg','L1S');


function RANGE_L1S_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'range','L1S');


function NSTEPS_L1S_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'nsteps','L1S');


function FINALPHASE_L1X_Callback(hObject, eventdata, handles)

inputFinalPhase(hObject,handles,'L1X',180);


function NAVG_L1X_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'navg','L1X');


function RANGE_L1X_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'range','L1X');


function NSTEPS_L1X_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'nsteps','L1X');


function FINALPHASE_L2_Callback(hObject, eventdata, handles)

update_SCP(handles);
inputFinalPhase(hObject,handles,'L2',45);


function RANGE_L2_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'range','L2');


function NAVG_L2_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'navg','L2');


function NSTEPS_L2_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'nsteps','L2');


function FINALPHASE_L3_Callback(hObject, eventdata, handles)

update_SCP(handles);
inputFinalPhase(hObject,handles,'L3',30);


function NAVG_L3_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'navg','L3');


function RANGE_L3_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'range','L3');


function NSTEPS_L3_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'nsteps','L3');


function FINALPHASE_SCAN_Callback(hObject, eventdata, handles)

iKLYS=getKlysInd(handles);
if any(iKLYS == [3*8+(1:3) 89 90])
  warndlg('Feedback stations 24-1, 24-2, 24-3, 29-0, and 30-0 do not accept a final phase value.','NO ENTRY ACCEPTED')
  set(handles.FINALPHASE_SCAN,'String','');
  return
end
inputFinalPhase(hObject,handles,'SCAN',120);


function NAVG_SCAN_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'navg','SCAN');


function RANGE_SCAN_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'range','SCAN');


function NSTEPS_SCAN_Callback(hObject, eventdata, handles)

inputTxt(hObject,handles,'nsteps','SCAN');


function iok = zero(hObject, handles, name, nPAC, quiet)

if nargin < 6, quiet=0;end

[nameE,is]=control_phaseNames(name);
nameMAD=name;nameH=name;
if is.SLC || is.PAC || is.KLY, nameH='SCAN';end
nameT=name;
if is.LSR
    nameH='SCHOTTKY';nameT='Laser';
    nameLas={'LASER' 'LASER2'};
    nameMAD = nameLas{get(handles.LASRSEL,'Value')+1};
    [d,is]=control_phaseNames(nameMAD);
end

substStr='';
if strcmp(name,'L2'), substStr='(21-24 SBSTs) ';end
if strcmp(name,'L3'), substStr='(25-30 SBSTs) ';end
gui_statusDisp(handles.MSGBOX,['Re-GOLDing ' nameT ' phase ' substStr '- please wait...']);

%if is.LSR || is.LSN
%    new_pdes    = str2double(get(handles.FINALPHASE_SCHOTTKY,'String'));
%else
    new_pdes    = str2double(get(handles.(['FINALPHASE_' nameH]),'String'));    % new phase setpoint after offsets fixed (deg)
%end

if is.PAC
    if isnan(new_pdes) % if scanning 24-1, 24-2, or 24-3
    else
        set(handles.(['FINALPHASE_' nameH]),'String','');
    end
end

str2='';
if is.L23, substStr=['phases in ' substStr ' so that the sub-boosters PDES'];str2=' (i.e., PDES=0 at crest)';
elseif is.SLC || is.PAC || is.KLY, substStr=['phase of ' nameT ' so that its KLYS PDES'];
else substStr=[name ' phase so that it'];
end

if ~quiet
    pdes_str = inputdlg(sprintf(['This will "GOLD" the ' substStr ...
        ' will then read %5.1f deg' str2 ...
        ', while not actually changing any real phase settings. ' ...
        ' Normally you simply continue, but you may (rarely) want to change ' ...
        'the final phase reading?'],new_pdes),'CAUTION',1,{num2str(new_pdes)});
    new_pdes = str2double(pdes_str);

    if isempty(pdes_str) || isnan(new_pdes)
        iok=0;
        gui_statusDisp(handles.MSGBOX,[nameT ' Re-GOLDing cancelled']);
      return
    end
end
set(handles.(nameH),'Enable','off');

ds=[];if handles.pulseSteal, ds=2;end
phase = [];
if is.FBK && ~is.LSN
    iok=checkFeedBack(handles,name,nameMAD,0,1);
    if ~iok, return, end

    namePhs=nameMAD;
    nameMAD     = strcat(nameMAD,'_',nPAC);

    navg        = 5;    % number of phase readings to average
    wait        = 0.1;  % pause between phase readings [sec] (fast readback)

    if ~is.LSR
        namePhs=nameMAD;
    else
%        wait=.1; % Pause for laser phase reading, uses :PBR
    end
    if epicsSimul_status, wait=.01;end
    set(handles.([name 'ZERO']),'BackgroundColor','white');
    drawnow

    phase = zeros(length(nameMAD),navg);
    for j = 1:navg                                  % average some phase readings
        set(handles.([name 'ZERO']),'String',sprintf('step:%3.0f...',j));
        drawnow
        phase(:,j) = control_phaseGet(namePhs);
        pause(wait);
    end
    disp('PAD readbacks for Gold:');
    disp(phase);
    pdes=control_phaseGet(namePhs(1),'PDES');
    if std(phase(1,:)) > 3 || abs(pdes-mean(phase(1,:),2)) > 5
        if ~strcmp(questdlg({['Phases: ' num2str(phase(1,:),' %5.1f')] 'Large PAD readback variation or offset change' 'Please enter phase values into logbook!'},'Gold Procedure','Abort','Continue','Abort'),'Continue')
            set(handles.(nameH),'Enable','on');
            set(handles.([name 'ZERO']),'BackgroundColor','default','String','zero phase');
            disp('Gold aborted');
            return
        end
    end
end

% Do UNDO setup
set(handles.UNDO,'Enable','on','String',['Undo ' name]);
handles.undoData.namePAD=nameMAD;
handles.undoData.pAct=mean(phase,2);
handles.undoData.pOld=control_phaseGet(nameMAD,'PDES');
handles.undoData.pNew=new_pdes;

% Determine if L2 or L3 zero button was pressed and turn off fancy phase.
isL23button=ismember(name,{'L2' 'L3'}) & any(hObject == [handles.L2ZERO handles.L3ZERO]);
isSCANbutton=is.PAC & hObject == handles.SCANZERO;
if isL23button, nFB=handles.fancyPV;end
if isSCANbutton, nFB=handles.abstrPV;end

if isL23button || isSCANbutton, sFB=lcaGetSmart(nFB,0,'double');lcaPut(nFB,0);pause(.5);end
control_phaseGold(nameMAD,new_pdes,mean(phase,2),ds);
if isL23button || isSCANbutton, lcaPut(nFB,sFB);end

if is.FBK && ~is.LSN
    set(handles.([name 'ZERO']),'BackgroundColor','default','String','zero phase');
    drawnow
end

% Set GOLD history PVs.
nameK=control_klysName(nameE);
if ismember(model_nameSplit(nameK),{'KLYS' 'SBST'})
    lcaPutSmart(strcat(nameK,':GOLDCHG'),new_pdes-handles.undoData.pOld);
    lcaPutSmart(strcat(nameK,':GOLDCHGTS'),(now - datenum('1/1/1990'))*24*60*60);
end

iok = 1;                                                    % meaningless for now

set(handles.(nameH),'Enable','on');

if ~iok
  gui_statusDisp(handles.MSGBOX,[nameT ' phase GOLDing cancelled']);
else
  gui_statusDisp(handles.MSGBOX,[nameT ' phase now re-GOLDed']);
end
if is.L23
    pause(1);
    update_SCP(handles);
end
guidata(hObject, handles);


function LASRZERO_Callback(hObject, eventdata, handles, varargin)

zero(hObject,handles,'LASR',{'0'},varargin{:});


function L0AZERO_Callback(hObject, eventdata, handles, varargin)

zero(hObject,handles,'L0A',{'0';'1'},varargin{:});


function L0BZERO_Callback(hObject, eventdata, handles, varargin)

zero(hObject,handles,'L0B',{'2';'3'},varargin{:});


function TCAV0ZERO_Callback(hObject, eventdata, handles, varargin)

zero(hObject,handles,'TCAV0',{'0';'1'},varargin{:});


function L1SZERO_Callback(hObject, eventdata, handles, varargin)

zero(hObject,handles,'L1S',{'0';'1';'2';'3'},varargin{:});


function L1XZERO_Callback(hObject, eventdata, handles, varargin)

zero(hObject,handles,'L1X',{'0';'1'},varargin{:});


function L2ZERO_Callback(hObject, eventdata, handles, varargin)

zero(hObject,handles,'L2',[],varargin{:});


function L3ZERO_Callback(hObject, eventdata, handles, varargin)

zero(hObject,handles,'L3',[],varargin{:});


function SCANZERO_Callback(hObject, eventdata, handles, varargin)

zero(hObject,handles,handles.klysName,[],varargin{:});


function printLog_btn_Callback(hObject, eventdata, handles)

if ~any(ishandle(handles.exportFig)), return, end
str=strtok(get(get(findobj(handles.exportFig,'type','axes'),'XLabel'),'String'),' ');
util_printLog(handles.exportFig,'title',['Phase Scan ' str]);
dataSave_btn_Callback(hObject,[],handles);


function setL(hObject, handles, name)

update_SCP(handles);
str='21-3 through 24-6';if strcmp(name,'L3'), str='25-1 through 30-8';end
phase_str = inputdlg([name ' phase shift (in degrees)'],str);
phase = str2double(char(phase_str));
scan_SCP_phases(name,phase);      % shift L2,3 phases
pause(1);
gui_statusDisp(handles.MSGBOX,[name ' phase shift completed']);
update_SCP(handles);
guidata(hObject, handles);


function SETL2_Callback(hObject, eventdata, handles)

setL(hObject,handles,'L2');


function SETL3_Callback(hObject, eventdata, handles)

setL(hObject,handles,'L3');


function iok = control_phaseEnergySetCallback(hObject, eventdata, handles, name, amp0, gain0, phase_i, phase_f, setE, phMax)

iok=control_phaseEnergySet(handles,name,amp0,gain0,phase_i,phase_f,setE,phMax);


function iok = control_phaseEnergySet(handles, name, amp0, gain0, phase_i, phase_f, setE, phMax)

% Check if phase change out of range.
if nargin < 9, phMax=Inf;end
onOff=phase_f == 0; %onOff=1 is on crest
dPhase=phase_f-phase_i; % Phase change to be implemented relative to present phase
if abs(dPhase) > phMax
    if onOff
        phStr=['The average ' name ' SBST PDES'];
    else
        phStr=['The requested ' name ' phase'];
    end
    errordlg([phStr ' value is too far off crest (>' num2str(phMax) ' deg) - no changes made.'],'BAD PHASE');
    iok = 0;
    return
end

% Check if beam needs to be blocked.
iok=1;
pvShut=handles.beamOffPV;
setShut=0;
setKlys=0;
if ismember(name,{'L2' 'L3'})
    setShut=setE;
    setKlys=1;
end
%isPDES=ismember(name,{'24-1' '24-2' '24-3' '29-0' '30-0' '28-2'});
isPDES=ismember(name,{'24-1' '24-2' '24-3' '29-0' '30-0'}); % 28-2 normal again
isKlys=strncmp(name(3:end),'-',1) & ~isPDES;
isSBST=ismember(name,{'21-S' '22-S' '23-S'});
if isSBST
    setShut=setE;
end

%nameFBL2={'SIOC:SYS0:ML00:AO294';'SIOC:SYS0:ML00:AO295'; ...
%          'FBCK:FB04:LG01:S4USED';'FBCK:FB04:LG01:S5USED'};
nameFBL2={'FBCK:FB04:LG01:S4USED';'FBCK:FB04:LG01:S5USED'};
FBL2initial = lcaGet(nameFBL2);
type='';ds=[];if handles.pulseSteal, ds=2;end
[d,pDes]=control_phaseGet(name,[],ds); % Get present phase
if isKlys
    [d,pDes(1),d,d,pDes(2)]=control_phaseGet(name);
    type={'PDES' 'KPHR'};
end

% Change energy gain.
if setE
    if isempty(gain0)
        if isempty(amp0)
            [d,d,d,amp0]=control_phaseGet(name);   % read present voltage [MV]
        end
        gain0=amp0*cosd(phase_i); % present energy gain at present phase
    else
        amp0=gain0/cosd(phase_i); % get present voltage from energy gain
    end
    output_amp = gain0/cosd(phase_f);
    dE=output_amp-amp0; % energy change by jumping from initial phase to final phase (MeV)
    if isSBST
        lcaPut(nameFBL2,0);
        [d,d,eL2]=control_phaseGet('L2');
        output_amp=eL2+dE;
    end
    if setShut
        lcaPut(pvShut,0);            % turn off beam at MPS shutter
        str={' OFF' ', near'};
        gui_statusDisp(handles.MSGBOX,sprintf(['MPS shutter closed - shifting ' name ' SBST PDES settings by %5.1f deg' str{onOff+1} ' crest.'],dPhase));
    end
    if setKlys
        if strcmp(name,'L2')
%            lcaPut(nameFBL2,0);
%            [d,d,eL2]=control_phaseGet('L2');
%            output_amp=eL2+dE;
        end
        [iok,dEK] = add_or_drop_klystrons(handles,name,dE); % drop or add klystrons as necessary to get to final phase
        pause(2);
%        output_amp=eL2+dE-dEK;
        if strcmp(name,'L2')
%            control_ampSet('L2',output_amp);
%            lcaPut(handles.fancyPV,1);  % Joe's 6x6 feedback (0=OFF,1=ON)
%            lcaPut(handles.phScanPV,1);pause(2.); % Set phase scan run PV to 1 and wait
%            lcaPut(handles.fancyPV,0);pause(1.); % Joe's 6x6 feedback (0=OFF,1=ON)
%            lcaPut(nameFBL2,1);
        end
    elseif isSBST
        control_ampSet('L2',output_amp);
        lcaPut(handles.fancyPV,1);  % Joe's 6x6 feedback (0=OFF,1=ON)
        lcaPut(handles.phScanPV,1);pause(2.); % Set phase scan run PV to 1 and wait
        lcaPut(handles.fancyPV,0);pause(1.); % Joe's 6x6 feedback (0=OFF,1=ON)
        lcaPut(nameFBL2,FBL2initial);
    elseif ~isKlys
        control_ampSet(name,output_amp);
    end
end

% Change phase.
if iok
    control_phaseSet(name,pDes+dPhase,0,[],type,ds); % shift L2 or L3 phase to or off crest
end

% don't send another trim right away (screws up micro)
if isKlys && ~setShut, pause(2);end

% Turn beam back on if previously blocked.
if setShut
    pause(2);
    gui_statusDisp(handles.MSGBOX,'MPS shutter open again - beam ON');
    lcaPut(pvShut,1);            % turn beam back ON
    iok = 1;
    pause(2); % Wait to get beam pulses before turn on new 6x6
end


function iok = checkPhaseDelta(name, phase_i, phase_f)

% if simply jumping to or off crest (i.e., not a full auto phase scan)
phase=phase_f-phase_i;
onOff=phase_f == 0; %onOff=1 is on crest
iok=1;
if onOff
    yn = questdlg(sprintf(['This will shift the ' name '-linac by %5.1f deg, based on present SBST PDES settings, and assumes this will then be ON crest.  It will drop klystrons as needed.  Do you want to continue?'],phase),'CAUTION');
    phStr=['The average ' name ' SBST PDES'];
else
    yn = questdlg(sprintf(['This will shift the ' name '-linac by %5.1f deg, based on the GUI''s "Final phase" setting, assuming ' name ' is ON crest now.  It will add klystrons as needed.  Do you want to continue?'],phase),'CAUTION');
    phStr=['The requested ' name ' phase'];
end
if ~strcmp(yn,'Yes')
    iok = 0;
    return
end
if abs(phase) < 1
    if onOff
        warndlg([phStr ' value is already within 1 deg of crest - no changes made.'],'SMALL PHASE');
    else
        warndlg([phStr ' value is too small - no changes made.'],'BAD PHASE');
    end
    iok = 0;
end


function iok = crestL(hObject, handles, name)

[PL2,pdesL2,dpdesL2,pactL2,dpactL2,PL3,pdesL3,dpdesL3,pactL3,dpactL3] = update_SCP(handles);
if strcmp(name,'L3'), pdesL2=pdesL3;end
iok = checkPhaseDelta(name,pdesL2,0);
if ~iok, return, end
iok = go_onOff_crest(handles,name,pdesL2,0);
handles=guidata(hObject);
pause(1);
update_SCP(handles);
guidata(hObject, handles);


function iok = offCrestL(hObject, handles, name)

update_SCP(handles);
phase  = str2double(get(handles.(['FINALPHASE_' name]),'String'));
iok = checkPhaseDelta(name,0,phase);
if ~iok, return, end
iok = go_onOff_crest(handles,name,0,phase);
handles=guidata(hObject);
pause(2);
update_SCP(handles);
guidata(hObject, handles);


function CRESTL2_Callback(hObject, eventdata, handles)

bykpv='IOC:BSY0:MP01:BYKIKCTL';bykst=lcaGet(bykpv,0,'double');lcaPut(bykpv,0);
fbpv=handles.fancyPV;fbst=lcaGet(fbpv,0,'double');lcaPut(fbpv,0); % Fancy FB
iok=crestL(hObject,handles,'L2');
if iok
    % get BC2 energy - added 11/17/10 nate
    energy_setpoints = model_energySetPoints*1e3;
    E_BC1 = energy_setpoints(3);
    E_BC2 = energy_setpoints(4);
    
    lcaPut({'SIOC:SYS0:ML00:AO294';'FBCK:FB04:LG01:S4USED'},0); % Energy FB
    lcaPut({'SIOC:SYS0:ML00:AO295';'FBCK:FB04:LG01:S5USED'},0); % BL FB
%     control_ampSet('L2',4300); % Energy setpoint
    control_ampSet('L2',E_BC2-E_BC1); % Energy setpoint
    lcaPut({'SIOC:SYS0:ML00:AO267';'FBCK:FB04:LG01:CHIRPDES'},0); % Chirp setpoint
end
pause(2);
lcaPut(fbpv,fbst); % Fancy FB
if iok
    pause(3);
    lcaPut({'SIOC:SYS0:ML00:AO294';'FBCK:FB04:LG01:S4USED'},1); % Energy FB
    pause(2);
end
lcaPut(bykpv,bykst);


function CRESTL3_Callback(hObject, eventdata, handles)

crestL(hObject,handles,'L3');


function OFFCRESTL2_Callback(hObject, eventdata, handles)

bykpv='IOC:BSY0:MP01:BYKIKCTL';bykst=lcaGet(bykpv,0,'double');lcaPut(bykpv,0);
fbpv=handles.fancyPV;fbst=lcaGet(fbpv,0,'double');lcaPut(fbpv,0); % Fancy FB
iok = offCrestL(hObject,handles,'L2');
if iok
    lcaPut({'SIOC:SYS0:ML00:AO294';'FBCK:FB04:LG01:S4USED'},0); % Energy FB
    lcaPut({'SIOC:SYS0:ML00:AO295';'FBCK:FB04:LG01:S5USED'},0); % BL FB
    energy_setpoints = model_energySetPoints*1e3;
    E_BC1 = energy_setpoints(3);
    E_BC2 = energy_setpoints(4);
    phase  = str2double(get(handles.(['FINALPHASE_' 'L2']),'String'));
    control_ampSet('L2',(E_BC2-E_BC1)/cosd(phase)); % Energy setpoint
    lcaPut({'SIOC:SYS0:ML00:AO267';'FBCK:FB04:LG01:CHIRPDES'},-3000); % Chirp setpoint
end
pause(2);
lcaPut(fbpv,fbst); % Fancy FB
if iok
    pause(3);
    lcaPut({'SIOC:SYS0:ML00:AO294';'FBCK:FB04:LG01:S5USED'},1); % Energy FB
    pause(2);
    lcaPut({'SIOC:SYS0:ML00:AO295';'FBCK:FB04:LG01:S5USED'},1); % BL FB
    pause(2);
end
lcaPut(bykpv,bykst);


function OFFCRESTL3_Callback(hObject, eventdata, handles)

offCrestL(hObject,handles,'L3');


function PDES_L2_Callback(hObject, eventdata, handles)

update_SCP(handles);


function PACT_L2_Callback(hObject, eventdata, handles)

update_SCP(handles);


function PDES_L3_Callback(hObject, eventdata, handles)

update_SCP(handles);


function PACT_L3_Callback(hObject, eventdata, handles)

update_SCP(handles);


function [iok, dE] = add_or_drop_klystrons(handles, name, dE)

if strcmp(name,'L2')
    klysList=[strcat({'23-'},num2str((1:8)')); ...
              strcat({'24-'},num2str((4:6)'))];
else
    klysList=[strcat({'29-'},num2str((6:8)')); ...
              strcat({'30-'},num2str((1:8)'))];
end
if dE > 0
    add_drop='add';
    ad = 2;
    act_deact = 1;        % add tubes
    act_deact_str1 = 'Activated';
    act_deact_str2 = 'Re-act';
    clr = 'green';
else
    add_drop='drop';
    ad = 1;
    act_deact = 0;        % drop tubes
    act_deact_str1 = 'Deactivated';
    act_deact_str2 = 'De-act';
    clr = 'red';
    klysList = flipud(klysList);
end
[act,d,d,d,d,enld]=control_klysStatGet(klysList);
iklys=bitand(act,ad) > 0;
iklysn=find(iklys);
%Nklys=round(interp1(cumsum([0;enld(iklys)]),0:sum(iklys),abs(dE),'linear',sum(iklys)));
[d,Nklys]=min(abs(cumsum([0;enld(iklys)])-abs(dE)));Nklys=Nklys-1;
%Nklys = round(abs(dE)/230);
handles=guidata(handles.output);
if dE > 0 && ~isempty(handles.dropKlys)
    if all(ismember(numel(iklys)+1-handles.dropKlys,iklysn))
        iklysn=numel(iklys)+1-handles.dropKlys;
    else
        warndlg('Cannot restore same complement','KLYSTRON COMPLEMENT CHANGE');
    end
    Nklys=numel(handles.dropKlys);
end
handles.dropKlys=[];
guidata(handles.output,handles);
if Nklys > 6
    errordlg(['More than 6 klystrons to ' add_drop ' - this is too many - no changes made.'],'TOO MANY KLYSTRONS')
    iok = 0;
    return
end
Nklys_available = sum(iklys);
if Nklys_available < Nklys
    errordlg(['Not enough klystrons available to ' add_drop ' - no changes made'],'NOT ENOUGH KLYSTRONS AVAILABLE')
    iok = 0;
    return
end
gui_statusDisp(handles.MSGBOX,sprintf(['MPS shutter closed - ' lower(act_deact_str2) 'ivating %1.0f klystrons (see list above)'],Nklys));
klysUsed=klysList(iklysn(1:Nklys));
control_klysStatSet(klysUsed,act_deact);
if dE < 0
    handles.dropKlys=iklysn(1:Nklys);
    guidata(handles.output,handles);
end
dE=sum(enld(iklysn(1:Nklys)))*sign(dE); % actual energy change
for j = 1:6                                     % blank out GUI fields initially
    set(handles.([name '_KLYS' num2str(j)]),'String',' ');
end
for j = 1:min(6,Nklys)                          % fill in klystron act/deact GUI fields
    set(handles.([name '_KLYS' num2str(j)]),'String',klysUsed{j});
end
klys_str=sprintf('%s,',klysUsed{:});
if ~isempty(klys_str)
    klys_str(end)=[];
else
    klys_str = ' ';
end
if strcmp(name,'L2')                            % if L2, save re-activated klystrons to PV's
    lcaPut('SIOC:SYS0:ML00:SO0055',klys_str);
    lcaPut('SIOC:SYS0:ML00:AO055',-Nklys);
    lcaPut('SIOC:SYS0:ML00:AO055.DESC',[name ' klystrons ' act_deact_str1 ':']);
else                                            % if L3, save re-activated klystrons to PV's
    lcaPut('SIOC:SYS0:ML00:SO0056',klys_str);
    lcaPut('SIOC:SYS0:ML00:AO056',-Nklys);
    lcaPut('SIOC:SYS0:ML00:AO056.DESC',[name ' klystrons ' act_deact_str1 ':']);
end
if Nklys > 0                                    % show in RED that these klys's are now deactivated
    set(handles.([name '_ACT_DEACT']),'String',[act_deact_str2 ':'], ...
        'ForegroundColor',clr);
    pause(2);
else                                            % or show no klys's deactivated
    set(handles.([name '_ACT_DEACT']),'String','(none)', ...
        'ForegroundColor','black');
end
iok = 1;


function iok = go_onOff_crest(handles, name, phase_i, phase_f)

energy_setpoints = 1e3*model_energySetPoints(); % in MeV
E_BC1 = energy_setpoints(3);
E_BC2 = energy_setpoints(4);
E_BSY = energy_setpoints(5);
if strcmp(name,'L2')
    phMax=44;
    E0 = E_BC1;      % BC1 energy (MeV)
    E1 = E_BC2;      % BC2 energy (MeV)
else
    phMax=30;
    E0 = E_BC2;      % BC2 energy (MeV)
    E1 = E_BSY;      % BSY energy (MeV)
end
iok = control_phaseEnergySet(handles,name,[],E1-E0,phase_i,phase_f,1,phMax);


function UPDATE_Callback(hObject, eventdata, handles)

update_SCP(handles);


function DEFAULTS_Callback(hObject, eventdata, handles)

phase0.SCHOTTKY = lcaGet('SIOC:SYS0:ML00:AO107');
phase0.L0A = lcaGet('SIOC:SYS0:ML00:AO109');
phase0.L0B = lcaGet('SIOC:SYS0:ML00:AO111');
phase0.L1S = lcaGet('SIOC:SYS0:ML00:AO113');
phase0.L1X = lcaGet('SIOC:SYS0:ML00:AO115');
phase0.L2  = lcaGet('SIOC:SYS0:ML00:AO118');
phase0.L3  = lcaGet('SIOC:SYS0:ML00:AO121');
eval(handles.load_cmnd)
nameList={'SCHOTTKY' 'L0A' 'L0B' 'L1S' 'L1X' 'L2' 'L3'};
for name=nameList
    set(handles.(['FINALPHASE_' name{:}]),'String',phase0.(name{:}));
    h1.(['finalphase_' lower(name{:})]) = get(handles.(['FINALPHASE_' name{:}]),'String');
end
h1.navg_k(1:90)   =  5;
h1.nsteps_k(1:90) =  9;
h1.finalphase_k(1:90) = 0;
h1.range_k(1:4*8)  = 50;
h1.range_k(81:84)  = 12;
h1.range_k((4*8+1):10*8)  = 90;
h1.range_k(85:90)  = 20;
eval(handles.save_cmnd)

setSectKlys(hObject,handles);
gui_statusDisp(handles.MSGBOX,'Restored final phase settings from operating parameters list');


function accCal(hObject, handles, name, nPAC, lim)

gui_statusDisp(handles.MSGBOX,['Calibrating ' name ' voltage - please wait...']);

[d,is,d,d,d,d,amp_pvs,ades_pv,d,disable_pv,d,scale_pvs,fdbk_pv]=control_phaseNames(strcat(name,'_',nPAC));

navg        = 5;      % number of voltage readings to average
wait        = 2;      % pause between phase readings [sec]
low_lim     = lim(1); % lowest acceptable calibration voltage [MV]
high_lim    = lim(2); % highest acceptable calibration voltage [MV]

if any(is.KLY | is.PAC)
    iok = calib_voltage_KLYS(handles,fdbk_pv{1},disable_pv{1},ades_pv{1},amp_pvs,scale_pvs,name,navg,wait,low_lim,high_lim);
else
    iok = calib_voltage(handles,fdbk_pv{1},disable_pv{1},ades_pv{1},amp_pvs,scale_pvs,name,navg,wait,low_lim,high_lim);
end
if ~iok
  gui_statusDisp(handles.MSGBOX,[name ' voltage calibration cancelled']);
else
  gui_statusDisp(handles.MSGBOX,[name ' voltage now re-calibrated']);
end


function iok = calib_voltage_KLYS(handles,fdbk_pv,disable_pv,ades_pv,amp_pvs,scale_pvs,name,navg,wait,low_lim,high_lim)

nameH=name;
[d,is]=control_phaseNames(name);
if is.SLC || is.PAC || is.KLY, nameH='SCAN';end

nameEpics=model_nameConvert(name,'SLC');
scale_pvs=strcat(nameEpics,':ECVT');

ades0 = lcaGet(strcat(nameEpics,':ENLD'));
ades_str = inputdlg(['This will re-calibrate the ' name ' voltage, while not actually changing any real voltage settings.  You should enter the pre-determined actual voltage now, or cancel?'],'ENTER NEW VOLTAGE',1,{num2str(ades0)});
if isempty(ades_str)
  iok = 0;
  return
end
new_ades = str2double(ades_str);
if (new_ades < low_lim) || (new_ades > high_lim)
  iok = 0;
  warndlg(sprintf('This is out of range: %4.1f MV < V < %4.1f MV',low_lim,high_lim),'ERROR')
  return
end

cmnd = ['set(handles.' nameH 'CAL,''BackgroundColor'',''white'')'];
eval(cmnd)
drawnow

if ~strcmp(fdbk_pv,'')
  fdbk_on_off = lcaGet(fdbk_pv,0,'double');       % check if voltage feedback on or off
  disabled    = lcaGet(disable_pv,0,'double');    % check if feedback output disabled
  if fdbk_on_off==0                               % quit if feedback OFF
    warndlg([name ' RF feedback is OFF - quitting.'],[name ' FDBK OFF'])
    iok = 0;
    return
  end
  if disabled                                     % quit if feedback disabled
    warndlg([name ' RF feedback is DISABLED - quitting.'],[name ' FDBK DISABLED'])
    iok = 0;
    return
  end
end
if ~(is.KLY || is.PAC)
  volts = zeros(length(amp_pvs),navg);
  for j = 1:navg                                  % average some voltage readings
    str = 'sprintf(''step:%3.0f...'',j)';
    cmnd = ['set(handles.' name 'CAL,''String'',' str ');'];
    eval(cmnd)
    drawnow
    vact = lcaGet(amp_pvs);
    volts(:,j) = vact;
    pause(wait);
  end
  volts_bar = mean(volts,2);
else
  volts_bar = ades0;
end
current_scalars = lcaGet(scale_pvs);                % get current scalar values
if ~strcmp(fdbk_pv,'')
  lcaPut(fdbk_pv,0,'double');                         % turn OFF feedback temporarily
  lcaPut(disable_pv,1,'double');                      % disable feedback temporarily
end
disp(sprintf(['Original ' name ' ENLD = %8.3f MV'],ades0)) % show current voltage setting in case needed
for j = 1                   % show current phase offsets in case needed
  str = sprintf(['Original ' name ' voltage scale factor = %8.6f'],current_scalars(1));
  disp(str)
end
current_scalars(1) = (new_ades./volts_bar)^2.*current_scalars(1);

lcaPut(scale_pvs,current_scalars,'double');         % set new voltage scale factors
%lcaPut(ades_pv,new_ades,'double');                  % set new voltage setpoint
if ~strcmp(fdbk_pv,'')
  lcaPut(disable_pv,0,'double');                      % re-enable feedback
  lcaPut(fdbk_pv,1,'double');                         % switch ON feedback
end
for j = 1                       % show new voltage scale factors
  str = sprintf(['New ' name ' voltage scale factor =      %8.6f'],current_scalars(j));
  disp(str)
end

cmnd = ['set(handles.' nameH 'CAL,''BackgroundColor'',[0.701960784313725 0.701960784313725 0.701960784313725])'];
eval(cmnd)
if strcmp(name,'GUN')
  cmnd = ['set(handles.' nameH 'CAL,''String'',''gun calib'');'];
else
  cmnd = ['set(handles.' nameH 'CAL,''String'',''calib. volts'');'];
end
eval(cmnd)
drawnow

iok = 1;                                                    % meaningless for now


function GUNCAL_Callback(hObject, eventdata, handles)

accCal(hObject,handles,'GUN',{'0';'1';'2';'3'},[4 8]);


function L0ACAL_Callback(hObject, eventdata, handles)

accCal(hObject,handles,'L0A',{'0';'1'},[30 80]);


function L0BCAL_Callback(hObject, eventdata, handles)

accCal(hObject,handles,'L0B',{'2';'3'},[40 100]);


function TCAV0CAL_Callback(hObject, eventdata, handles)

accCal(hObject,handles,'TCAV0',{'0';'1'},[0.1 10]);


function L1SCAL_Callback(hObject, eventdata, handles)

accCal(hObject,handles,'L1S',{'0';'1';'2';'3'},[80 180]);


function L1XCAL_Callback(hObject, eventdata, handles)

accCal(hObject,handles,'L1X',{'0';'1'},[5 30]);


% --- Executes on button press in SCANCAL.
function SCANCAL_Callback(hObject, eventdata, handles)

accCal(hObject,handles,handles.klysName,[],[140 300]);


function iKLYS = getKlysInd(handles)

isec = get(handles.SECTOR,'Value');
iklys = get(handles.KLYS,'Value');
iKLYS = (isec-1)*8 + iklys-1 + (iklys == 1).*(88-7*isec);     % 21-3 is isec=1, iklys=3, 30-8 is isec=10, iklys=8, SBST come at 81 ... 90


function handles = setSectKlys(hObject, handles)

name = [handles.sector '-' handles.klys(1)];
if ismember(name,{'29-S' '30-S'})
    name(4)='0';
end

handles.klysName=name;
button = 1;
act='';flag=1; % Enable scan
if ismember(name,{'21-1' '21-2' '24-7' '24-8'})
    flag=0;
elseif all(name(4) ~= 'S0')    % if not a SBST
    actStat1=control_klysStatGet(name, 1);
    actStat2=control_klysStatGet(name, 2);
    act='activated';
    if bitand(actStat1,1) && bitand(actStat2, 1) % Check first bit for active status on beam code 1 and 2. 
        button = 1;
    elseif bitand(actStat1, 1)
        button = 2;
    elseif bitand(actStat2, 1)
        button = 3;
    else  
        flag=0;act='deactivated';
    end
end
col={'red' 'green'};str={'no ' 'scan '};state={'off' 'on'};
green = [0 1 0]; pink = [1 0.6 .784]; blue = [0.702 0.78 1];
buttonCol = {green, blue, pink};
handles.color = buttonCol{button};
set(handles.ACT_DEACT,'ForegroundColor',col{flag+1},'String',act);
set(handles.SCAN,'String',[str{flag+1} name],'Enable',state{flag+1}, 'BackgroundColor', handles.color);

if handles.sectorN < 25
    set(handles.CLTScheckbox, 'Visible','off');
else                                             %allow CLTS scan if station is in L3 
    set(handles.CLTScheckbox, 'Visible','on');
end

guidata(hObject, handles);

iKLYS=getKlysInd(handles);
eval(handles.load_cmnd)
set(handles.FINALPHASE_SCAN,'String',num2str(h1.finalphase_k(iKLYS)))
set(handles.NAVG_SCAN,'String',num2str(h1.navg_k(iKLYS)))
set(handles.RANGE_SCAN,'String',num2str(h1.range_k(iKLYS)))
set(handles.NSTEPS_SCAN,'String',num2str(h1.nsteps_k(iKLYS)))
set(handles.DATETIME_SCAN,'String',h1.datetime_k(iKLYS,:))

function handles = KLYS_Callback(hObject, eventdata, handles)

i = get(hObject,'Value');
str = get(hObject,'String');
handles.klys = str{i};          % e.g., '1', or 'SBST'
handles=setSectKlys(hObject,handles);


function handles = SECTOR_Callback(hObject, eventdata, handles)

i = get(hObject,'Value');
str = get(hObject,'String');
handles.sector  = str{i};                   % e.g., '21'
handles.sectorN = str2double(str{i});       % e.g.,  21
handles=KLYS_Callback(handles.KLYS,[],handles);


function NOCHANGES_Callback(hObject, eventdata, handles)
handles.nochanges = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in FDBKS_ON_OFF.
function FDBKS_ON_OFF_Callback(hObject, eventdata, handles)
on_off = get(hObject,'Value');
handles.fdbklist=getFeedBackRegion(handles,'','',0);
if on_off
  handles.fdbk_states = lcaGetSmart(handles.fdbklist,0,'double');
  lcaPutSmart(handles.fdbklist,0);
  gui_statusDisp(handles.MSGBOX,'Setting all feedback loops OFF');
  set(handles.FDBKS_ON_OFF,'BackgroundColor','red','String','Set fdbks ON');
else
  lcaPutSmart(handles.fdbklist,handles.fdbk_states);
  gui_statusDisp(handles.MSGBOX,'Setting all feedback loops back to original state');
  set(handles.FDBKS_ON_OFF,'BackgroundColor','default','String','Set fdbks OFF');
end
drawnow
guidata(hObject, handles);


% --- Executes on button press in FASTSCAN.
function FASTSCAN_Callback(hObject, eventdata, handles)
handles.scanMode = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in PULSESTEAL.
function PULSESTEAL_Callback(hObject, eventdata, handles)
handles.pulseSteal = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in BSA.
function BSA_Callback(hObject, eventdata, handles)
handles.BSA = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in PULSESTEAL.
function FITMODE_Callback(hObject, eventdata, handles)
handles.fitMode = get(hObject,'Value');
guidata(hObject, handles);
acquireUpdate(hObject,handles);


% --- Executes on button press in UNDO.
function UNDO_Callback(hObject, eventdata, handles)
if isempty(handles.undoData), set(handles.UNDO,'Enable','off');return, end

d=handles.undoData;disp(d);disp(handles.dropKlys);
if isfield(d,'namePAD')
    control_phaseSet(d.namePAD,d.pNew);
    control_phaseGold(d.namePAD,d.pOld,d.pOld-d.pAct+d.pNew);
end
if isfield(d,'name')
    control_phaseSet(d.name,d.pDes);
end
handles.undoData=[];
set(handles.UNDO,'Enable','off','String','Undo');


% --- Executes on button press in LASRSEL.
function LASRSEL_Callback(hObject, eventdata, handles)
eval(handles.load_cmnd);
h1.laser_select = get(hObject,'Value');
eval(handles.save_cmnd);
str={'Coherent 1' 'Coherent 2' 'BOTH'};
set(hObject,'String',str{h1.laser_select+1});


% --- Executes on button press in acquireAbort_btn.
function acquireAbort_btn_Callback(hObject, eventdata, handles)

gui_acquireAbortAll;


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles)

if ~isfield(handles,'data'), return, end
data=handles.data;
util_dataSave(data,'PhaseScan',data.name,data.ts);


% --- Executes on button press in dataOpen_btn.
function dataOpen_btn_Callback(hObject, eventdata, handles)

[data,fileName]=util_dataLoad('Open phase scan');
if ~ischar(fileName), return, end

% Put data in storage.
handles.data=data;
guidata(hObject,handles);
acquireUpdate(hObject,handles);


function acquireUpdate(hObject, handles)

if ~isfield(handles,'data'), return, end

guidata(hObject,handles);
data=handles.data;
[d,is]=control_phaseNames(data.name);
refPhase=0;order=2-is.TCV;
if strcmp(data.name,'L1X')     % X-band will have negative parabola (i.e., P(1) < 0)
  refPhase=-180;
end
if order == 1     % TCAV has 90 degree zero-crossing
    refPhase=90;
end
phase_scan_analyse(data,1,refPhase,handles,order,'',1,handles.fitMode);


% --- Executes on button press in acquireUpdate_btn.
function acquireUpdate_btn_Callback(hObject, eventdata, handles)

acquireUpdate(hObject,handles);


% --- Executes during object creation, after setting all properties.
function FINALPHASE_L2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FINALPHASE_L2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CLTScheckbox.
function CLTScheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to CLTScheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.CLTS = get(hObject,'Value');
guidata(hObject, handles);
