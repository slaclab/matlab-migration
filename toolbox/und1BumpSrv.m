function und1BumpSrv

% Important PV.
watcherpv = 'SIOC:SYS0:ML03:AO630';
accelerator = 'LCLS';
locname = 'UND1';
rootname = ['PHYS:' locname ':BUMP'];
acrreqname = ['ACR:' locname ':BUMP:REQUEST'];
looppause = 0.05; % intra loop pause between monitor checks
disableFBIfLessThan = 9;
maxCorrStr = 6e-3;

% Initialize and define all the things
fprintf('\n%s und1BumpSrv Started\n',datestr(now))
W = watchdog(watcherpv,10,['undBumpSrv: ' rootname]);
if get_watchdog_error(W)
    error('Could not start watchdog. Dog required for entry.')
end

% Annoying warnings are annoying.
lcaSetSeverityWarnLevel(3)

% Get the name and number of hutches available for this panel.
mmbo = {'ZR','ON','TW','TH','FR','FV','SX','SV','EI','NI','TE','EL','TV','TT','FT','FF'}.';
ctrlloc = lcaGetSmart(strcat(rootname, ':CONTROLLOC.', mmbo, 'ST'));
ctrlnum = find(~cellfun(@isempty,ctrlloc))-1;
% SHOULD BE ABOVE LINE ONCE ALL PVS MADE
ctrlloc = ctrlloc(ctrlnum+1);
Nloc = numel(ctrlloc);%Nloc = 4;
maxbumpnum = lcaGetSmart(strcat(rootname, ':REQUEST.', mmbo, 'ST'));
maxbumpnum = find(cellfun(@isempty,maxbumpnum),1,'first')-2;

% PVs we monitor for changes
% First numel(CTRLNUM) PVs are bump requests
listenpvs = strcat(ctrlloc, ':', locname, ':BUMP:REQUEST');
% SHOULD BE ABOVE LINE ONCE ALL PVS MADE!
%listenpvs = strcat(ctrlloc(1:4), ':', locname, ':BUMP:REQUEST');
% Last is the location making a request
listenpvs{end+1} = [rootname, ':CONTROLLOC'];

% nope...
listenpvs = {[rootname, ':CONTROLLOC'];...
    [rootname, ':REQUEST']};
Nlistenpvs = numel(listenpvs);
% PVs that hold the bump settings
setnames = {'STARTLOC';'STOPLOC';'AMPL';'PLANE'};
Nsetnames = numel(setnames);
Nsettotal = Nsetnames*maxbumpnum;
bumpsetpvs = cell(Nsettotal,1);
% settingpvs((-3:0)+4*BUMPNUM) are PVs for settings above with diff bump #
for k = 1:maxbumpnum
    bumpsetpvs((-3:0)+4*k) = strcat([rootname ':B' num2str(k)],setnames);
end

% PVs that hold what the loop thinks its doing
currentpvs = strcat([rootname ':CURRENT'],...
    {'BUMP';'START';'STOP';'AMPL';'PLANE'});

% Initialize from a cold start
oldlistenval = lcaGetSmart(listenpvs,1,'int');
oldbumpset = reshape(lcaGetSmart(bumpsetpvs,1,'int'),...
    Nsetnames,maxbumpnum);
zerocurval = [0;1;33;0;0]; % assume start with nada
lcaPutSmart(currentpvs,zerocurval); % make current setting agree

% Corrector pvs (rail check)
%corrpvs=model_nameRegion({'XCOR','YCOR'},'UND1');

% Function for managing reading FB (feedback...) status of machine
oldFbStatus = getFBstatus;
oldBDes.names = '';
oldBDes.values = [];

% Start loop
lcaSetMonitor(listenpvs,1,'int');
while 1
    % Watchdog update
    W = watchdog_run(W);
    if get_watchdog_error(W)
        error('Watchdog lost. I quit.')
    end
    
    try
        % Listen for request changes (hutch or bump)
        newlisten = lcaNewMonitorValue(listenpvs,'int');
        if any(newlisten)
            pause(0.1); % um... why did I pause here?
            % Get request change and capture current settings
            newvals = lcaGetSmart([listenpvs;bumpsetpvs],1,'int');
            newbumpset = reshape(newvals((Nlistenpvs+1):end),Nsetnames,maxbumpnum);
            newlistenval = newvals(1:Nlistenpvs);
            % 1-Check for no kick currently (already EPICS handled)
            % 2 - If a location change and a kick was left in...
            if newlisten(1) && (oldlistenval(2) ~= 0)
                disp_log('und1BumpSrv.m: Removing kick left from last owner...')
                result = restoreToZero(zerocurval(2:end),oldFbStatus,oldBDes);
                if result == 0
                    lcaPutSmart(currentpvs,zerocurval);
                    if oldlistenval(1) == 0; % if ACR, we can also fix request to match
                        lcaPutSmart(acrreqname,0);
                    end
                    oldlistenval(2) = 0;
                    pause(0.5) % let IOC realize bump is gone
                    newlistenval(2) = lcaGetSmart(listenpvs{2},1,'int'); % get bump (which may now be allowed)
                    pause(3) % and give FB time to converge assuming it was renabled
                end
            end
            % expected problem: requesting same bump we do nothing. but
            % what if bump settings have changed? think this through more.
            if ~(newlistenval(2) == oldlistenval(2)) && ...% same bump
                ~(newlistenval(2) > 0 && oldlistenval(2) ~=0) % should never happen given how IOC works
                    if newlistenval(2) == 0
                        % we're restoring settings
                        result = restoreToZero(zerocurval(2:end),oldFbStatus,oldBDes);
                        if result == 0
                            lcaPutSmart(currentpvs,zerocurval);
                        else
                            % Nothing was done.
                            newlistenval(2) = oldlistenval(2);
                            newbumpset = oldbumpset;
                            lcaPutSmart(currentpvs,[oldlistenval(2);oldbumpset(:,oldlistenval(2))]);
                        end
                    else
                        % we're putting in a bump
                        [result,newFbStatus,newBDes] = putKick(newbumpset(:,newlistenval(2)));
                        if result ~= 0
                            % Nothing was done while trying to put in bump.
                            newlistenval(2) = oldlistenval(2);
                            newbumpset = oldbumpset;
                            lcaPutSmart(currentpvs,zerocurval);
                            if newlistenval(1) == 0
                                lcaPutSmart(acrreqname,0);
                            end
                        else
                            oldFbStatus = newFbStatus;
                            oldBDes = newBDes;
                            lcaPutSmart(currentpvs,[newlistenval(2);newbumpset(:,newlistenval(2))]);
                        end
                    end
                    oldlistenval = newlistenval;
            end
            % Output the values being used and force current settings of
            % merit to also agree (in case of race condition)
            oldbumpset = newbumpset;
        end
    catch ex
        if any(strfind(ex.message,'no channel for PV')) || ...
            any(strfind(ex.message,'invalid process variable name'))
            disp('lca monitor reset')
            lcaSetMonitor(pvs,1,'int')
        else
            rethrow(ex)
        end
    end
    pause(looppause);
end

function [result,oldfbstatus,oldbdes] = putKick(settings)
% Put in undulator kick. oldfbstatus is the struct describing the undulator
% launch feedback config before any changes were made for restoring
% later. oldbdes is structure with list of original corrector names/values
% pairs for restoring later.
%
% Result = int describing success/failure of attempt
%        = 0 if committed with no issues
%        = 1 if not committed due to inconsistent FB settings
%        = 2 if the requested bump cannot be implemented

% Only disable FB if kick starts before...
accelerator = evalin('caller','accelerator');
disableFBIfLessThan = evalin('caller','disableFBIfLessThan');
maxCorrStr = evalin('caller','maxCorrStr');

oldbdes.names = [];
oldbdes.values = [];
oldfbstatus = getFBstatus;
if ~oldfbstatus.isOkay
    result = 1;
    warning('Inconsistent or conflicting undulator launch feedback settings detected. Doing nothing.')
    return
end
if settings(1) < 9
    if lcaGetSmart('MPS:UND1:950:SXRSS_MODE',1,'int') ~= 1
        result = 2;
        warning('SXRSS optics protection: No kicks upstream of U09 unless can confirm optics out.')
        return
    end
end
if settings(2) - settings(1) < 6
    result = 2;
    warning('Start/close girder numbers too close together to do bump.')
    return
end
[names,values] = control_undOpenCloseOsc(settings(1),settings(2),1e-6*settings(3),settings(4));
if any(abs(values) > maxCorrStr)
    warning('Look out, imma rail some correctors!')
end
oldbdes.names = names;
oldbdes.values = control_magnetGet(names);
if oldfbstatus.isEnabled && (settings(1) < disableFBIfLessThan)
    disableFB(oldfbstatus);
end
%disp('Would be setting magnets here...')
disp_log('und1BumpSrv.m: Changing und corr values for bump')
control_magnetSet(names,values);
result = 0;

function result = restoreToZero(settings,oldfbstatus,oldbdes)
disableFBIfLessThan = evalin('caller','disableFBIfLessThan');
%disp('Would be restoring magnets...')
disp_log('und1BumpSrv.m: Restoring und correctors')
control_magnetSet(oldbdes.names,oldbdes.values);
if oldfbstatus.isEnabled && (settings(1) < disableFBIfLessThan)
    restoreFB(oldfbstatus);
end
result = 0;


function disableFB(fbstatus)
% Code for using info in fbstatus to disable launch FB goes here
%disp('Would be disabling FB here...')
disp_log('und1BumpSrv.m: Disabling und launch feedbacks')
lcaPutSmart(fbstatus.name(1:3),0);


function restoreFB(fbstatus)
%disp('Would be re-enabling FB here...')
disp_log('und1BumpSrv.m: Re-enabling und launch feedbacks')
lcaPutSmart(fbstatus.name(1:3),fbstatus.val(1:3));
    
function fbstatus = getFBstatus
% Function should return structure FBSTATUS with fields
%   name = PVs for various FB statues
%   val  = Numerical value of FB PV states specified by name
%   isOkay = FB values evaluate to a non-conflicting state
%   isEnabled = FB (of some kind) is enabled
accelerator = evalin('caller','accelerator');
switch accelerator
    case 'LCLS'
        % fbstatus.name is cell string with these entries for LCLS UND1:
        % 1 = control_launchGird16.m/control_launch.m
        % 2 = matlab und orbit feedback Enable/Disable (1/0) status
        % 3 = fast und orbit feedback mode ENABLE/COMPUTE (1/0) status
        % 4 = WE DO NOT CHANGE THIS, but we do check that it's consistent. is
        %     status flag, 1 = fast should be active, 2 = matlab is.
        fbstatus.name ={'SIOC:SYS0:ML00:AO818';'FBCK:UND0:1:ENABLE';...
            'FBCK:FB03:TR04:MODE';'SIOC:SYS0:ML02:AO127'};
        try
            fbstatus.val = lcaGetSmart(fbstatus.name,0,'double');
            if any(isnan(fbstatus.val))
                error('Could not retrieve a feedback state')
            end
        catch ex
            warning(ex.message)
            fbstatus.isOkay = 0;
            fbstatus.isEnabled = 0;
            return
        end
        % Only one of the following should be true
        fbstatus.isOkay = (((fbstatus.val(2)==0)&&(fbstatus.val(3)==0)) ... % there's no feedback engaged
             || ((fbstatus.val(2)==1)&&(fbstatus.val(3)==0)&&(fbstatus.val(4)==2)) ... % matlab feedback is only selected
             || ((fbstatus.val(2)==0)&&(fbstatus.val(3)==1)&&(fbstatus.val(4)==1))); % fast feedback is only selected
        fbstatus.isEnabled = ((fbstatus.val(2)==1)||(fbstatus.val(3)==1));
end


function [names, coeffs] = control_undOpenCloseOsc(first,last, val, plane)
% [names, coeffs] = control_undOpenCloseOsc(first,last, val, plane)
%
% Calculate undulator orbit bump starting at FIRST and closed by LAST with
% amplitude VAL (m) in PLANE
%   0 = X
%   1 = Y
%   2 = X & Y
%
% Returns NAMES for the corrector PVs and COEFFS for the suggested values

if last < first + 4
    name = nan;
    coeffs = nan;
    return
end

if nargin < 2, val=0.4e-3;end
if nargin < 3, plane=0;end;

incl = logical([ismember(plane,[0,2]), ismember(plane,[1,2])]);
nPlane = sum(incl);
corrToUse = [first, [-3,0]+last];
nCorr = numel(corrToUse);
iCorr = zeros(1,nCorr);
iBPM = zeros(1,nPlane);
s=bba_simulInit;
for k= nCorr:-1:1
    name = strcat('XCU',num2str(corrToUse(k),'%02i'));
    iCorr(k)=find(strcmp(s.corrList,model_nameConvert(name,'MAD')));
end
r=bba_responseMatGet(s,0);
% Pretty much ignore actual orbit
x=nan(2,numel(s.bpmList));
% Want zero after bump
x(incl,(3+last):end)=0;
if incl(1)
    % Line could use work for more generality...
    [~,iBPM(1)]=max(abs(r(1:2:2*(last),5+33*2+37*2+33*4+2*iCorr(1)-1)));
    x(1,iBPM(1)) = val;
end
if incl(2)
    [~,iBPM(nPlane)] = max(abs(r((1:2:2*(last))+1, 6+33*2+37*2+33*4+2*iCorr(1)-1)));
    x(2,iBPM(nPlane)) = val;
end
opts.use=struct('init',0,'BPM',0,'quad',0,'corr',1);
opts.iCorr=iCorr;
% Do fits for both x and y
f=bba_fitOrbit(s,r,x,[],opts);
% Plot expected orbit (for testing)
%bba_plotOrbit(s,x,[],f.xMeasF,[]);
names=s.corrList(opts.iCorr);
names=[names strrep(names,'X','Y')];
names=names(:,incl);
names=reshape(names,1,numel(names));
coeffs=f.corrOff(incl,opts.iCorr);
coeffs=reshape(coeffs,1,numel(coeffs));
