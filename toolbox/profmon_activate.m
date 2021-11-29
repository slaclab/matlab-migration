function profmon_activate(pv, state, single)
%PROFMON_ACTIVATE
%  PROFMON_ACTIVATE(PV, STATE, SINGLE) inserts the screen(s) related to PV
%  and retracts all other screens. If SINGLE is set to 1 (default is 0) no
%  other screen is retracted. If STATE is 0, the screen(s) PV is retracted 
%  and other screens are not affected.

% Features:

% Input arguments:
%    PV: Base name(s) of camera PV, e.i. YAGS:IN20:211
%    STATE: Desired state of screen, 1 = 'IN' or 0 = 'OUT', default 1
%    SINGLE: Does not retract other screens if set to 1, default is 0

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: profmon_names, model_nameConvert, lcaPut, lcaGet,
%                   profmon_evrSet

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Check function arguments.
if nargin < 3, single=0;end
if nargin < 2, state='IN';end

% Get profmon type.
[pv,is]=profmon_names(pv);
if isempty(pv), return, end

stateStr=upper(state);
stateList={'OUT' 'IN'};
%if any(is.FACET), stateList={'INSERT' 'RETRACT'};end
if any(is.PCDS & ~is.SAS), stateList={'-52' '0'};end
if any(strcmp(pv,'HXX:UM6:CVP:01')), stateList={'Out' 'In'};end
if isnumeric(state) || islogical(state)
    stateStr=stateList{(state == 1)+1}; % Works for NaN, too.
end
state=double(ismember(stateStr,{'IN' 'In' 'RETRACT' '0'}));

% Get actuator PV name.
pvAct=strcat(pv,':PNEUMATIC');

% Get totally messed up PCDS actuator PVs.
listPCDS={ ...
    'AMO-SAS'  'AMO:SAS:CVV:01' 'AMO:SAS:YAG:GO'; ... % 0 OUT, 1 IN
    'DIA-CVV-02' 'AMO:DIA:CVV:02' ''            ; ...
    'SB1-PIM'  'SXR:YAG:CVV:01' 'HX2:SB1:MMS:09'; ...
    'P6'       'HXX:UM6:CVP:01' 'HXX:UM6:MPA:01:ACTUATE'; ... % 0 Out, 1 In
    'DG1-PIM'  'HXX:UM6:CVV:01' 'HXX:UM6:MMS:08'; ...
    'PM1'      'HXX:HXM:CVV:01' 'HXX:HXM:MMS:03'; ...
    'DG2-PIM'  'HFX:DG2:CVV:01' 'HFX:DG2:MMS:09'; ...
    'DG3-PIM'  'HFX:DG3:CVV:01' 'HFX:DG3:MMS:08'; ...
    'DG3-PIM2' 'XCS:DG3:CVV:02' 'XCS:DG3:MMS:17'; ...
    'PIM1'     'MEC:HXM:CVV:01' 'MEC:HXM:MMS:16'; ...
%    'SB1-PIM2' 'HFX:DG3:CVV:01' 'XCS:SB1:MMS:09'; ... % Duplicate PV
};
[isPCDS,idPCDS]=ismember(pv,listPCDS(:,2));
pvAct(isPCDS)=listPCDS(idPCDS(isPCDS),3);

% List of motor controlled devices (Name, IN, OUT).
motrList={ ...
    'SYAG'      -12000      +1600; ...   % OUT for SYAG, IN for SPMON
    'USTHZ'     -3000       +46000; ...  % IN is Ti 1um #1
    'DSTHZ'     +11100      +59600; ...  % IN is Ti 1um #1
    'USOTR'     -2950       +44550; ...  % IN is Ti 1um #1
    'IPODR'     -33000      +30000; ...  % IN is Foil #1 (?)
    'IPOTR1'    -5000       +28100; ...  % IN is Ti 500 um
    'DSOTR'     +89000      +140000; ... % IN is Ti 1um #1
    'IP2A'      +37600      +54800; ...  % IN is W/Ta 500um
    'IP2B'      +51639      +70639; ...  % IN is W/Ta 500um
% YAGPSI converted to PAL-style actuator as of Nov. 28 2017
%    'YAGPSI'    +52         +110  ; ...  % IN is YAG crystal
};
[isMotr,idMotr]=ismember(pv,model_nameConvert(motrList(:,1)));
pvAct(isMotr)=strcat(strrep(pv(isMotr,1),'MIRR','OTRS'),':MOTR'); % MIRR screens have OTRS actuator
pvAct(is.Popin) = strcat(pv(is.Popin),':STATE').'; % Popins have read-only state value
pvAct=strrep(pvAct,'EXPT:LI20:3176','OTRS:LI20:3175'); % IPODR has EOS motor
motrPos=vertcat(motrList{idMotr(isMotr),3-state});

% List of all profile monitors.
profList={'YAG01' 'YAG02' 'YAG03' ...
          'YAGS1' 'YAGS2' ...
          'OTRH1' 'OTRH2' 'OTR1' 'OTR2' 'OTR3' 'OTR4' ...
          'OTR11' 'OTR12' 'OTR21' 'OTR30' ... % 8-Spe-2016 removed PR45 in Prep of BSY for LCLS2
          'YAGPSI'}; % Added Nov 28, 2017

%for j=1:length(profList)
%    pos=find(strcmp(profList{j},model_nameConvert(pv,'MAD')))-1;
%    if any(pos)
%        profList=profList{j}(1:pos);break
%    end
%end
%if ~any(pos), profList={};end
pvList=model_nameConvert(profList(:));

%NLCTA profmon
if any(is.NLCTA)
    profList={'P810340T' 'P810595T' 'P811210T' 'P811270T' 'P811550T' 'P811930T' 'P812250T' 'P812100T' 'P812290T' 'P812250T' 'P812190T'};
    camList={'CAM0340' 'CAM0595' 'CAM1210' 'CAM1270' 'CAM1550' 'CAM1930' 'CAM2055' 'CAM2100' 'CAM2290' 'CAM2250' 'CAM2190'};
    pvCam=model_nameConvert(camList(:));
    pvProf=model_nameConvert(profList(:));
    [is1,idx]=ismember(pv,pvProf);
%    idx = strmatch(pv,pvProf);
%    if ~any(idx)
        [is1(~is1),idx(~is1)]=ismember(pv(~is1),pvCam);
%        idx = strmatch(pv,pvCam);
%    end
    %     aidaput('TA03:MISC:1037//UVBMSTOP',1); % deactivate beam
%     lcaPut('ESB:BO:2124-7:BIT1',1);% deactivate beam
%     pause(0.1);
    lcaPut(pvProf(idx(is1)),state); % insert/retract profmon
    pause(0.5);
    %     aidaput('TA03:MISC:1037//UVBMSTOP',2); % restore beam
%     lcaPut('ESB:BO:2124-7:BIT1',0);% activate beam
    lcaPut(strcat(pvCam(idx(is1)),':TriggerMode'),'Sync In 1'); %set trigger mode
    return;
end

if any(is.FACET)
    pvList = '';
end

% Temp for XTA & ASTA cameras.
if any(is.XTA | is.ASTA)
    source=strcat(pv(is.XTA | is.ASTA),':Acquisition');
    lcaPutNoWait(source,1);
    return
end
    
% Temp for LCLS AD cameras.
if any(is.LCLS & is.AreaDet)
    source=strcat(pv(is.LCLS & is.AreaDet),':Acquisition');
    lcaPutNoWait(source,1);
end
    
% Retract all monitors.
if state && ~single && ~isempty(pvList)
    lcaPut(strcat(pvList,':PNEUMATIC'),stateList{1});
end

% Get present screen state.
pState=false(size(pv));
if any(~isMotr & ~is.Popin)
    pState(~isMotr & ~is.Popin)=ismember(lcaGet(pvAct(~isMotr & ~is.Popin),0,'char'),{'IN' 'In' 'RETRACT' '0.0000'});
elseif any(isMotr)
    pState(isMotr)=state == (lcaGet(pvAct(isMotr)) == motrPos);
elseif any(is.Popin)
    pState(is.Popin) = strcmp(lcaGet(pvAct(is.Popin), 0, 'char'), 'IN');
end

% Deactivate beam.
if any(pState ~= state)
    if ~any(is.Popin | is.PCDS | is.FACET | is.SCLinac)
        lcaPut('PATT:SYS0:1:POCKCNTMAX',10*50);
        trigPV='PATT:SYS0:1:POCKCTRL';
        %trigPV='TRIG:LR20:LS01:TCTL';
        lcaPut(trigPV,0);
    elseif any(is.FACET)
        trigPV='2-9';
        trigVal=control_klysStatGet(trigPV);
        control_klysStatSet(trigPV,1);
    end
end

% Get MPS shutter state.
if any(is.FACET) || all(is.SCLinac)
    mState=0;
elseif any(~is.SCLinac)
    strMS=('MPS:IN20:200:MSHT1_OUT_MPS');
    mState=lcaGet(strMS,0,'double');
end

% Insert the selected ones.
lcaPutSmart(pvAct(~isMotr & ~is.Popin),stateStr);
if any(isMotr)
    lcaPutNoWait(pvAct(isMotr),motrPos);
end

% Wait for limit switch.
t0=now;wait=10; % Seconds
if any(isMotr), wait=100;end
if any(is.Popin | is.PCDS), wait=0;pState=state;end % No status switches
str={'OUT' 'IN'};strLS=strcat(pv,':',str(state+1),'_LMTSW');
desLS=true(size(pv));
desLS(isMotr)=false;
desLS(strcmp(pv,'YAGS:GUNB:753')) = false; % don't wait for this motor that looks like a pneumatic
strLS(isMotr)=strcat(pvAct(isMotr,1),'.MOVN');
while (now-t0)*24*60*60 < wait && ~all(lcaGetSmart(strLS,0,'double') == desLS), end
if wait && (now-t0)*24*60*60 >= wait, disp('Timeout for limit switches:');disp(pv);end

% Enable trigger again.
if any(pState ~= state)
    if ~any(is.Popin | is.PCDS | is.FACET | is.SCLinac)
        lcaPut(trigPV,1);
    elseif any(is.FACET)
        control_klysStatSet(trigPV,trigVal);
    end
end

% If STATE is retract, return after checking if there are popins to retract
if ~state
    if any(is.Popin) && ...% some redundancy here?
        any(strcmpi(lcaGetSmart('CAMR:XTOD:SELECT'),...
        model_nameConvert(pv,'MAD'))) % is Popin and is the one currently "in"
        % this could act funny if the select PV is out of sync with
        % reality. then inserting/extracting same screen should fix things.
        lcaPutSmart('CAMR:XTOD:SELECT',0);
    end
    return
end

% Set trigger for PV.
profmon_evrSet(pv);

% Do the Xray popin screen select.
if any(is.Popin)
    lcaPutSmart('CAMR:XTOD:SELECT',model_nameConvert(pv(find(is.Popin,1)),'MAD'));
end

% Wait for frame rate.
t0=now;
pvRate=strcat(pv,':FRAME_RATE');
pvRate((is.LCLS & is.AreaDet) | is.AreaDet2)=strcat(pv((is.LCLS & is.AreaDet) | is.AreaDet2,1),':ArrayRate_RBV');
% This line needs revision once Frame Grabber (OTRDMP, WFOV) drivers are
% updated to areaDetector:
pvRate(is.FrameGrab) = strcat(pv(is.FrameGrab,1),':CAMERA.RATE');
while ~all(lcaGet(pvRate)) && (now-t0)*24*60*60 < 10, end
if (now-t0)*24*60*60 > 10, disp('Timeout for frame rate:');disp(pv);end

% Return if screen state unchanged or MPS shutter previously in.
if all(pState == state) || ~mState, return, end
t0=now;wait=10; % Seconds
while ~lcaGet(strMS,0,'double') && (now-t0)*24*60*60 < wait, end
if (now-t0)*24*60*60 >= wait, disp(['Timeout for MPS shutter ' strMS]);end
