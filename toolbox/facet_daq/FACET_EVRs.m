function param = FACET_EVRs(param)
%%%% This file correlates cameras with their EVRs and sets the EVR PVs accordingly

% There may be multiple cameras per IOC, thus the logical(sum) statement
use_cs01 = logical(sum(param.is_CS01));
use_cs02 = logical(sum(param.is_CS02));
use_cs03 = logical(sum(param.is_CS03));
use_cs04 = logical(sum(param.is_CS04));
use_cs05 = logical(sum(param.is_CS05));
use_pm20 = logical(sum(param.is_PM20));
use_pm21 = logical(sum(param.is_PM21));
use_pm22 = logical(sum(param.is_PM22));
use_pm23 = logical(sum(param.is_PM23));

% These are the base EVR PVs
evrPVs = {};
if use_cs01; evrPVs = [evrPVs; 'EVR:LI20:CS01']; end;
if use_cs02; evrPVs = [evrPVs; 'EVR:LI20:CS02']; end;
if use_cs03; evrPVs = [evrPVs; 'EVR:LI20:CS03']; end;
if use_cs04; evrPVs = [evrPVs; 'EVR:LI20:CS04']; end;
if use_cs05; evrPVs = [evrPVs; 'EVR:LI20:CS05']; end;
if use_pm20; evrPVs = [evrPVs; 'EVR:LI20:PM20']; end;
if use_pm21; evrPVs = [evrPVs; 'EVR:LI20:PM21']; end;
if use_pm22; evrPVs = [evrPVs; 'EVR:LI20:PM22']; end;
if use_pm23; evrPVs = [evrPVs; 'EVR:LI20:PM23']; end;

% Add PVs to struct
param.EVR.evrPVs = evrPVs;
num_evr = numel(evrPVs);

% These PVs toggle EVR TTL and IRQ triggers
evr_Event1CtrlOut0 = cell(num_evr,1);
evr_Event1CtrlOut1 = cell(num_evr,1);
evr_Event1CtrlOut2 = cell(num_evr,1);
evr_Event1CtrlIRQ  = cell(num_evr,1);
evr_Event1CtrlENM  = cell(num_evr,1);
evr_Event2CtrlENM  = cell(num_evr,1);

% Loop through EVRs to set PVs
for i=1:num_evr
    
    % The Event1CtrlOut PVs are the TTL triggers
    evr_Event1CtrlOut0{i,1} = [char(evrPVs(i)),':EVENT1CTRL.OUT0'];
    evr_Event1CtrlOut1{i,1} = [char(evrPVs(i)),':EVENT1CTRL.OUT1'];
    evr_Event1CtrlOut2{i,1} = [char(evrPVs(i)),':EVENT1CTRL.OUT2'];
    evrPV = evrPVs{i};
    
    % If we are using CMOS, we have separate TTL and timestamp event codes
    % Event1Ctrl is the TTL event
    % Event2Ctrl is the timestamp event
    if sum(strcmp(evrPV(10:13),{'CS01';'CS02';'CS03';'CS04';'CS05'}))
        % Mapping Event2CTRL.VME to Event1CtrlIRQ to be consistent with prior code
        evr_Event1CtrlIRQ{i,1}  = [char(evrPVs(i)),':EVENT2CTRL.VME']; 
        evr_Event1CtrlENM{i,1}  = [char(evrPVs(i)),':EVENT1CTRL.ENM'];
        evr_Event2CtrlENM{i,1}  = [char(evrPVs(i)),':EVENT2CTRL.ENM'];
        if param.event_code == 233
            % This is for positrons
            lcaPut(evr_Event1CtrlENM{i,1}, 227);
            lcaPut(evr_Event2CtrlENM{i,1}, param.event_code);
        elseif param.event_code == 213
            % This is for electrons
            lcaPut(evr_Event1CtrlENM{i,1}, 221);
            lcaPut(evr_Event2CtrlENM{i,1}, param.event_code);
        else
            % This is for laser and PAMM
            lcaPut(evr_Event1CtrlENM{i,1}, param.event_code);
            lcaPut(evr_Event2CtrlENM{i,1}, param.event_code);
        end
    else
        % For non-CMOS TTL and timestamp are same event
        evr_Event1CtrlENM{i,1}  = [char(evrPVs(i)),':EVENT1CTRL.ENM'];
        evr_Event1CtrlIRQ{i,1}  = [char(evrPVs(i)),':EVENT1CTRL.VME'];
        lcaPut(evr_Event1CtrlENM{i,1}, param.event_code);
    end
end

% Add PVs to struct
param.EVR.evr_Event1CtrlOut0 = evr_Event1CtrlOut0;
param.EVR.evr_Event1CtrlOut1 = evr_Event1CtrlOut1;
param.EVR.evr_Event1CtrlOut2 = evr_Event1CtrlOut2;
param.EVR.evr_Event1CtrlIRQ  = evr_Event1CtrlIRQ;
param.EVR.evr_Event1CtrlENM  = evr_Event1CtrlENM;
param.EVR.evr_Event2CtrlENM  = evr_Event2CtrlENM;
param.EVR.num_evr = num_evr;
