function [setok, result_phase, gain, data] = phase_scan_new(handles, pm_range, phase_steps,  ...
    navg, delay, rate, bpm_pv, name, order, tag, scanMode, fignum)

% Check for no PAD devices.
%isPDES=ismember(name,{'24-1' '24-2' '24-3' '29-0' '30-0' '28-2'});
isPDES=ismember(name,{'24-1' '24-2' '24-3' '29-0' '30-0'}); % 28-2 normal again
isL23=ismember(name,{'L2' 'L3'});
isKlys=strncmp(name(3:end),'-',1) & ~isPDES;

if epicsSimul_status, delay=0;rate=120;end

% Check for pulse steal.
ds=[];useBSA=0;
if numel(scanMode) > 1, ds=scanMode(2);scanMode(2)=[];end
if ds < 0, ds=[];useBSA=1;end

gain=NaN;
bpm_pv=cellstr(bpm_pv);

% Get dispersion at BPM.
if numel(bpm_pv) > 1
    r=model_rMatGet(bpm_pv(1),bpm_pv);
    en=model_rMatGet(bpm_pv,[],[],'EN');
    eta=squeeze(r(1,6,:)./r(6,6,:))*1e3; % mm
    [d,id]=max(abs(eta));
    etaX=eta(id);E0=en(id)*1e3;
else
    [etaX,E0]=getDispersion(bpm_pv{1});r=[];eta=etaX;
end

% Set up pulse steal.
if ~isempty(ds), eDef=control_tcav3eDef;rate=1;else eDef='BR';end
if ismember('BPMS:CLTS:570', bpm_pv), eDef='CUSBR'; end
% Set up BSA mode.
if useBSA
    handles.eDefName=['Phase_Scans_' datestr(now,'HHMMSS_FFF')];
    handles.eDefNumber=0;
    handles=gui_BSAControl([],handles,1,2800);
    if ~epicsSimul_status, eDefOn(handles.eDefNumber);end
end

% Find absolute klys or sbst phase.
L_PDES=0;
if isKlys || strcmp(name,'28-2')
    sect=str2double(name(1:2));
    nameL23='L2';
    if sect > 24, nameL23='L3';end
    if sect == 29, nameL23='29-0';end
    if sect == 30, nameL23='30-0';end
    L_PDES = control_phaseGet(nameL23);
end

[pAct,result_phase,d,d,initialKPHR] = control_phaseGet(name,[],ds);
presentPhase=result_phase+L_PDES; % Absolute initial phase for klystron

type='';
if isKlys
    type={'PDES' 'KPHR'};
    result_phase(2)=initialKPHR;
end

% Set difference between klys PDES & KPHR and initial absolute phase.
deltaKlysPhase=result_phase-presentPhase;

% Meaning of phases:
%  refPhase: ideal phase where to do the scan about (crest 0 or -180, or 90)
%  z: fitted phase at which reference actually occurs
%  result_phase: control system setpoints at scan start or after phase shift (PDES, [KPHR])
%  initial_phase: ideal or last measured refPhase (init PDES for L0A - L1X)

% Set crest scan phase list, presentPhase is assumed to represent crest.
phaseList=presentPhase+linspace(-1,1,phase_steps)*pm_range;
initial_phase=presentPhase;

% Set scan phase list, presentPhase is assumed to represent absolute phase.
if scanMode && order == 2
    pP=abs(util_phaseBranch(presentPhase,0));
    pm_range=min(abs(pP-acosd(cosd(pP)+[-1 1]*(1-cosd(pm_range)))));
    ph2=util_phaseBranch(-presentPhase,presentPhase);
    phSet=sort([presentPhase ph2]);
    if diff(phSet) < 2*pm_range
        pm_range=(diff(phSet)+2*pm_range)/2;
        phaseList=mean(phSet)+ ...
            linspace(-1,1,phase_steps)*pm_range;
    else
        phaseList=linspace(-1,1,ceil(phase_steps/2))*pm_range;
        phaseList=[phSet(1)+phaseList phSet(2)+phaseList];
    end
end

refPhase=0;
if strcmp(name,'L1X')     % X-band will have negative parabola (i.e., P(1) < 0)
  refPhase=-180;
end
if order == 1     % TCAV has 90 degree zero-crossing
    refPhase=90;
end
trueInitPhase=refPhase;
if scanMode
    trueInitPhase=initial_phase;
    initial_phase=refPhase;
end

phase_steps=numel(phaseList);
ph=phaseList(:);
ii=phaseList*0;
[bpm_x,dbpm_x] = deal(zeros(numel(ph),numel(bpm_pv)));

off0=initial_phase*0+1*randn; % For simulation

data.name=name;data.bpmList=bpm_pv;data.scanMode=scanMode;data.r=r;
data.etaX=etaX;data.E0=E0;data.phaseInit=initial_phase;data.ts=now;


for j = 1:phase_steps
   if ~gui_acquireStatusGet([],handles), break, end
   set(handles.(tag),'String',sprintf('step:%3.0f...',j));
   pAct=control_phaseSet(name,phaseList(j)+deltaKlysPhase,0,[],type,ds);
   if j == 1
      if isPDES
          pause(delay);
      elseif isKlys
          pause(2*delay);
      elseif isL23
%          pause(phase_steps*delay/4);
      else
          pause(.1);
      end
   else
      if isPDES || isKlys %|| isL23
          pause(delay);
      else
          pause(.1);
      end
   end
   pause(0.5);
   if isKlys
       [phas,pdes,d,d,kphr]=control_phaseGet(name);
       disp(' ')
       disp(['KLYS:LI' name(1:2) ':' name(4) '1:KPHR = ' sprintf('%7.2f deg',kphr)])
       disp(['KLYS:LI' name(1:2) ':' name(4) '1:PDES = ' sprintf('%7.2f deg',pdes)])
       disp(['KLYS:LI' name(1:2) ':' name(4) '1:PHAS = ' sprintf('%7.2f deg',phas)])
   end
   if ~useBSA
       [X,Y,T,dX,dY,dT,iok] = control_bpmGet(bpm_pv,navg,rate,'eDef',eDef);    % read BPM navg times and average
   else
       continue
   end
   if epicsSimul_status
       pAct=pAct+.1*randn;off=off0;
       if ismember(name(1:2),{'21' '22' '23'}), off=off+control_phaseGet('L2');end
       if ismember(name,{'24-1' '24-2' '24-3' '29-0' '30-0'}), [d1,d1,d1,d1,d1,gold]=control_phaseGet(name);off=off+gold;end
       X=eta'/E0*d*(cosd(pAct(1)+off)-cosd(trueInitPhase))+.05*randn(1,numel(bpm_pv))+.5;dX=0.005+abs(eta)'*2e-4;
       Y=.5*180/pi*(cosd(pAct(1)+off)-cosd(trueInitPhase))+.05*randn;dY=.05;iok=1;
       if numel(bpm_pv) > 1
           n=numel(bpm_pv);
           X(n)=X(end);X(1:n-1)=0;
       end
   end
       if order==1 || ismember('BPMS:CLTS:570', bpm_pv)
         bpm_x(j,:)  = Y;                 % average BPM Y reading for TCAV or CLTS scan
         dbpm_x(j,:) = dY;                % error on mean of BPM Y reading
       else
         bpm_x(j,:)  = X;                 % average BPM X reading
         dbpm_x(j,:) = dX;                % error on mean of BPM X reading
       end
%   end
%   ii(j)     = all(iok);                 % no beam if ==0
   ii(j)     = iok(end);                 % no beam if ==0
   if isKlys, continue, end
   ph(j)=pAct;
end

% Set up BSA mode.
if useBSA
    if ~epicsSimul_status, eDefOff(handles.eDefNumber);end

    % Get eDef stuff.
    eDefNumStr=num2str(handles.eDefNumber);
    pulseIdPV=sprintf('PATT:%s:1:PULSEIDHST%s','SYS0',eDefNumStr);
    num=lcaGet([pulseIdPV '.NUSE']);

    % Read BPM and phase data.
    pvList=strcat(bpm_pv,':XHST',eDefNumStr);
    bpm_x=lcaGetSmart(pvList,num);dbpm_x=bpm_x*0;
    
    [n,is]=control_phaseNames(name);
    if is.KLY
        pvList=strcat(n,':PHAS_FASTHST',eDefNumStr);
    end
    if is.FBK
        pvList=strcat(n,'_PHST',eDefNumStr);
    end
    ph=lcaGetSmart(pvList,num);

    % Release eDef.
    handles=gui_BSAControl([],handles,0);
    ii=ones(1,num);
end

setok = 1; % Default to good measurement
data.status=ii;data.phase=ph;data.bpmX=bpm_x;data.bpmXStd=dbpm_x;

if sum(ii) < 3
  setok = 0;
  errordlg('Less than 3 valid points with beam - quitting.','INSUFFICIENT DATA');
end

if std(ph(logical(ii))) < 1
  setok = 0;
  warndlg('The RF phase variation is too small.','No RF Phase Variation')
end

% Data analysis and plotting.
dPhi=0;
if setok
    if ~gui_acquireStatusGet([],handles), setok=0;end
    [setok,dPhi,Xoff]=phase_scan_analyse(data,setok,refPhase, ...
        handles,order,tag,fignum,handles.fitMode);
end

% Apply phase change.
result_phase = result_phase + dPhi;
control_phaseSet(name,result_phase,0,0,type,ds);

if ~E0 || ~setok || scanMode, return, end         % if TCAV RF or bad data or same energy scan

% Voltage adjust L0A & L1S.
if ismember(name,{'L0B' 'L1S'})            % only adjust voltage for L0B or L1S
    energy_pv=[model_nameConvert(name) '_ADES'];
    dV = E0*Xoff/etaX;                     % Egain correction [MeV]
    if abs(dV)<5.0
        if abs(dV)>1
            msg = ['The energy appears to be a off by ' sprintf('%5.2f MeV',dV) ...
                '.  Is it OK to fix this?'];
            yn = questdlg(msg,'Energy Offset');
        else
            yn = 'Yes';
        end
        if strcmp(yn,'Yes')
            V0 = lcaGet(energy_pv,0,'double');
            disp(['changing RF voltage by ', num2str(-dV) ' MV']);
            lcaPut(energy_pv,V0-dV);
        end
    else
        msg = ['The energy appears to be a WAY off by ' sprintf('%5.2f MeV',dV) ...
            '. Please correct by hand.'];
        warndlg(msg,'Extreme Energy Offset')
    end
end


function [etaX, E0] = getDispersion(bpm_pv)

switch bpm_pv
    case 'BPMS:IN20:731'
        etaX = -263;      % BPM13 constant dispersion [mm]
        E0   = 1E3*lcaGet('BEND:IN20:751:BACT',0,'double');   % BX01/02 BACT (Gev/c)
    case 'BPMS:IN20:945'
        etaX = -472;      % BPMS2 constant dispersion [mm]
        E0   = 1E3*lcaGet('BEND:IN20:931:BACT',0,'double');   % BXS BACT (GeV/c)
    case 'BPMS:LI21:233'
        XMOV = lcaGet('BMLN:LI21:235:MOTR.RBV',0,'double');
        BL   = lcaGet('BEND:LI21:231:BACT',0,'double');       % BC1 BACT (kG-m)
        E0   = 250*(BL/0.7223)*(229.3/XMOV);                  % BC1 energy
        if XMOV > 50
            etaX = -XMOV;   % BPMS11 variable dispersion [mm]
        else
            warndlg('BC1 chicane is not ON - cannot adjust energy.','BC1 is OFF');
            etaX=1E6;
        end
    case 'BPMS:LI24:801'
        XMOV = lcaGet('BMLN:LI24:805:MOTR.RBV',0,'double');
        BL   = lcaGet('BEND:LI24:790:BACT',0,'double');       % BC2 BACT (kG-m)
        E0   = 4300*(BL/4.98)*(361.6/XMOV);                   % BC2 energy
        if XMOV > 50
            etaX = -XMOV;   % BPMS21 variable dispersion [mm]
        else
            warndlg('BC2 chicane is not ON - cannot adjust energy.','BC2 is OFF');
            etaX=1E6;
        end
    case 'BPMS:LTUH:250'
        etaX = 125;      % BPMDL1 constant dispersion [mm]
        E0   = 1E3*lcaGet('BEND:DMPH:400:BACT',0,'double');   % BYD1 BACT (GeV/c)
    case 'BPMS:CLTS:570'
        etaX = 289;    % BPMCUS8 constant dispersion [mm]
        E0 = 1E3*lcaGet('BEND:CLTS:280:BACT', 0, 'double');   % BLRCUS BACT (GeV/c)
    otherwise % if TCAV (can tell by the BPM used)
        etaX = 1;
        E0 = 0;
end
