function control_chicaneWatcher
% Watch for listenPVlist and perform requested action by calling
% model_energyBLEMTrim
%H. Loos Aug. 2014.

global messagePV
messagePV='SIOC:SYS0:ML00:CA024';

statPVs=strcat('SIOC:SYS0:ML01:AO',cellstr(num2str([430:437 440:450 509 511:529]','%03d')));
watcherPV=statPVs(1);
setPVlist = statPVs(2:6);
ctrlPVlist = statPVs([15:19 7:8]);
funcPVlist = statPVs(10:14);
rbPVlist = statPVs(20:end);

% Copy present readback values into set points.
lcaPut(setPVlist(1:5),lcaGet(rbPVlist([6 2:3 19:20])));
lcaPut(ctrlPVlist(1:5),lcaGet(rbPVlist([6 2:3 19:20])));

state=control_deviceGet({'BXSS2' 'BXHS2'},'STATE','double') > 0;
if ~state(1), lcaPut(ctrlPVlist(6),lcaGet(rbPVlist(14)));end
if ~state(2), lcaPut(ctrlPVlist(7),lcaGet(rbPVlist(15)));end

lcaPutSmart(strcat(setPVlist,'.DRVH'),[40 65 50 1000 50]');
lcaPutSmart(strcat(ctrlPVlist,'.DRVH'),[40 65 50 1000 50 9800 6600]');
lcaPutSmart(strcat(ctrlPVlist,'.DRVL'),[0 0 0 0 0 -9800 -6600]');
lcaPutSmart(strcat(ctrlPVlist,'.HOPR'),[40 65 50 1000 50 9800 6600]');
lcaPutSmart(strcat(ctrlPVlist,'.LOPR'),[0 0 0 0 0 -9800 -6600]');

% Real list.
%{
names=model_nameConvert({'BXH2';'BX12';'BX22';'BXSS2';'BXHS2'});
baseList=strrep(names,'BEND','REFS');
desTag={'X' 'R56' 'R56' 'T' 'T'}';
funcPVlist=strcat(baseList,':FUNC');
setPVlist=strcat(baseList,':',desTag,'DES');
ctrlPVlist=strcat(baseList,':',desTag,'CTRL');
ctrlPVlist(6:7)=strcat(baseList(4:5),':',{'P' 'P'}','CTRL');
tag={'R56' 'X' 'P' 'T'};
for j=1:numel(tag)
    rbPVlist((j-1)*numel(baseList)+(1:numel(baseList)),1)=strcat(baseList,':',tag(j),'ACT');
end
%}

%   Name    Scale Mags                                Quads                                         RF Phase
devList={ ...
    'BCH'   1e-3 {'BXH2' 'BXH1T' 'BXH3T' 'BXH4T'}     {'QA01' 'QA02' 'QE01' 'QE02' 'QE03' 'QE04'} 'SIOC:SYS0:ML00:AO080'; ...
    'BC1'   1e-3 {'BX12' 'BX11T' 'BX13T' 'BX14T'}     {'QA12' 'Q21201' 'QM11' 'QM12' 'QM13'}      'SIOC:SYS0:ML00:AO060'; ...
    'BC2'   1e-3 {'BX22' 'BX21T' 'BX23T' 'BX24T'}     {'Q24701A' 'QM21' 'QM22' 'Q24901A'}         'SIOC:SYS0:ML00:AO063'; ...
    'SXRSS' 1    {'BXSS2' 'BXSS1T' 'BXSS3T' 'BXSS4T'} {}                                          ''                    ; ...
    'HXRSS' 1    {'BXHS2' 'BXHS1T' 'BXHS3T' 'BXHS4T'} {}                                          ''                    ; ...
    'SXRSS' 1    {'BXSS2'}                            {'BXSS1T' 'BXSS2T' 'BXSS3T' 'BXSS4T'}       ''                    ; ...
    'HXRSS' 1    {'BXHS2'}                            {'BXHS1T' 'BXHS2T' 'BXHS3T' 'BXHS4T'}       ''                    ; ...
    };

messagePut('Chicane watcher started.');
disp_log('control_chicaneWatcher.m started') ;
lcaPutSmart(watcherPV,0); % Don't reset
aliveCounter = 0;

lcaPutSmart(strcat(funcPVlist,'.MDEL'),-1); %Get a callback anytime PV is put to.
lcaSetMonitor([ctrlPVlist;funcPVlist]);
pause(1);
lcaGetSmart([ctrlPVlist;funcPVlist]); %clear monitor

while 1
    [newCtrl,newFunc] = deal(0);
    while ~any([newCtrl;newFunc])
        pause(0.1)
        newCtrl = lcaNewMonitorValue(ctrlPVlist); 
        newFunc = lcaNewMonitorValue(funcPVlist);
        aliveCounter = aliveCounter + 1;
        lcaPutSmart(watcherPV, aliveCounter);
    end
    ctrlVal = lcaGetSmart(ctrlPVlist);
    funcVal = lcaGetSmart(funcPVlist);
    setVal = lcaGetSmart(setPVlist);
    doSTDZ = lcaGetSmart('SIOC:SYS0:ML01:AO440');
    for j=1:5
        if newFunc(j) && funcVal(j) == 1 % BCH X, BC1, BC2 R56, SXRSS, HXRSS delay
            chicaneSet(devList(j,:),setVal(j),doSTDZ);
            lcaPut(ctrlPVlist(j),setVal(j));lcaGetSmart(ctrlPVlist(j)); %clear monitor
            lcaPut(funcPVlist(j),0);
        end
    end
    for j=4:5
        if newFunc(j) && funcVal(j) > 1 % SXRSS, HXRSS turn ON/OFF
            control_chicaneOnOff(devList{j+2,1},devList{j+2,3},devList{j+2,4},3-funcVal(j));
            lcaPut(funcPVlist(j),0);
        end
    end
    for j=4:5
        if newCtrl(j) % SXRSS, HXRSS delay
            chicaneSet(devList(j,:),ctrlVal(j),-1);
            lcaPut(setPVlist(j),ctrlVal(j));
        end
    end
    for j=6:7
        if newCtrl(j) % SXRSS, HXRSS phase
            control_chicanePhaseSet(devList{j,1},devList{j,3},devList{j,4},ctrlVal(j));
        end
    end
end


% --------------------------------------------------------------------
function messagePut(str)

global messagePV
lcaPutSmart(messagePV,double(char(str)));


% --------------------------------------------------------------------
function control_chicaneOnOff(name, nMain, nTrim, val)

bykik=lcaGet('IOC:BSY0:MP01:BYKIKCTL');
lcaPut('IOC:BSY0:MP01:BYKIKCTL','No');
state=control_deviceGet(nMain,'STATE','double');

stateStr={'OFF' 'ON'};
if state == val
    messagePut([name ' main supply already ' stateStr{state+1}]);
end
    
doAct=val ~= state;
if val
    if ~state
        messagePut([name ' main supply turning ON']);
        control_magnetSet(nMain,[],'action','TURN_ON'); % Does turn on involve a TRIM?
        pause(2);
    end
    act='STDZ';
    stdzok=control_deviceGet(nMain,'STDZOK','double');
    doAct=~stdzok;
else
    act='DEGAUSS';
%    degausok=control_deviceGet(nMain,'DEGAUSOK','double');
%    doAct=~degausok;
end

if doAct
    messagePut([name ' setting trims to zero in progress']);
    control_magnetSet(nTrim,0,'action','TRIM');
    messagePut([name ' ' act ' in progress']);
    control_magnetSet(nMain,0,'action',act);
    messagePut([name ' ' act ' complete']);
end
lcaPut('IOC:BSY0:MP01:BYKIKCTL',bykik);


% --------------------------------------------------------------------
function chicaneSet(devList, setVal, doSTDZ)

n=devList{3};
[d,BDES0,d,energy]=control_magnetGet(n(1));
if ismember(devList{1},{'BCH'})
    energy(2)=energy;[d,d,d,energy(1)]=control_magnetGet('QA01');
end
if ismember(devList{1},{'SXRSS' 'HXRSS'})
    energy=lcaGet('REFS:DMP1:400:EDES');
end
control_chicaneSet(devList{1},n,devList{4},devList{5},setVal*devList{2},energy,BDES0,doSTDZ);


% --------------------------------------------------------------------
function control_chicaneSet(name, nMags, nQuad, nPhase, val, energy, BDES0, doSTDZ)

[bDes,xpos,phi]=BC_adjust(name,val,energy,BDES0);
bDes(5:end)=bDes(5:end)+control_magnetGet(nQuad,'BDES')';
mShut=lcaGet('IOC:BSY0:MP01:MSHUTCTL');
lcaPut('IOC:BSY0:MP01:MSHUTCTL','No');
str=[name ' chicane beam disabled for TRIM'];
disp_log(str);messagePut(str);
pause(0.5);
if ~strcmp(name,'BCH'), phi=-phi;end
if ~isempty(nPhase), lcaPutSmart(nPhase,phi);end
control_chicaneMove(name,xpos*1e3);
opts=struct();
if doSTDZ == -1
    str=[name ' chicane PRTB request started'];
    disp_log(str);messagePut(str);
    opts.wait=1;
    control_magnetSet(nMags(1),bDes(1),opts);
elseif doSTDZ
    str=[name ' chicane quick STDZ request started'];
    disp_log(str);messagePut(str);
    control_magnetQuickSTDZ(nMags(1),bDes(1));
else
    str=[name ' chicane TRIM request started'];
    disp_log(str);messagePut(str);
    control_magnetSet(nMags(1),bDes(1),'action','TRIM');
end
str=[name ' setting trims [and quads]'];messagePut(str);
control_magnetSet([nMags(2:end) nQuad],bDes(2:end),opts);
control_chicaneWait(name,xpos*1e3);
lcaPut('IOC:BSY0:MP01:MSHUTCTL',mShut);
str=[name ' set to ' num2str(val) ', main set to ' num2str(bDes(1)) ' kG-m'];
messagePut(str);


% --------------------------------------------------------------------
function control_chicanePhaseSet(name, nMain, nTrim, ph)

state=control_deviceGet(nMain,'STATE');
if strcmp(state,'OFF')
    energy=lcaGet('REFS:DMP1:400:EDES');
    lambda=0.03/2/(energy/511e-6)^2*(1+(3.5^2)/2)*1e10;
    Angstroms=ph/360*lambda;
    bDes=BC_phase(Angstroms,energy,name);
    control_magnetSet(nTrim,bDes,'wait',0.25);
    str=[name ' phase set to ' num2str(ph) ' deg, trim set to ' num2str(bDes(1)) ' kG-m'];
else
    str=[name ' phase set request denied, chicane on'];
end
messagePut(str);


% --------------------------------------------------------------------
function control_chicaneMove(name, val)

switch name
    case 'BC1'
        nMot='BMLN:LI21:235';
    case 'BC2'
        nMot='BMLN:LI24:805';
    otherwise
        return
end

str=[name ' chicane mover set to '  num2str(val) ' mm'];
messagePut(str);
if val <= 0
    val=val-1; % make sure chicane hits limit switch with an extra 1 mm
end
lcaPutNoWait(strcat(nMot,':MOTR'),val); % set abs position for BC1 chicane mover
if epicsSimul_status
    lcaPut(strcat(nMot,':LVPOS'),val);
end


% --------------------------------------------------------------------
function iok = control_chicaneWait(name, val)

iok=1;
switch name
    case 'BC1'
        nMot='BMLN:LI21:235';
    case 'BC2'
        nMot='BMLN:LI24:805';
    otherwise
        return
end

% Now wait for BC mover to converge to its proper position...
for j = 1:40
    act = lcaGet(strcat(nMot,':LVPOS'));  % read BC LVDT position (mm)
    if abs(act - val) < 5
        return
    else
        str=['Waiting for ' name ' mover: ' num2str(act) ' mm should be ' num2str(val) ' mm'];
        messagePut(str);
        pause(3);
    end
end
str=[name ' chicane mover is not converging'];
messagePut(str);
iok = 0;


% --------------------------------------------------------------------
function control_magnetQuickSTDZ(name, bDes)

bDes0=control_magnetGet(name,'BDES');
[bMin,bMax]=control_deviceGet(name,{'BDES.LOPR' 'BDES.HOPR'});
if bDes < bDes0
    messagePut(['Setting ' char(name) ' to BMAX']);
    control_magnetSet(name,bMax);
    pause(10);
    messagePut(['Setting ' char(name) ' to BMIN']);
    control_magnetSet(name,bMin);
    pause(10);
end
messagePut(['Setting ' char(name) ' to BDES']);
control_magnetSet(name,bDes,'action','TRIM');


% --------------------------------------------------------------------
function matlabPVClear(num)

statPVs=strcat('SIOC:SYS0:ML01:AO',cellstr(num2str(num(:),'%03d')));
lcaPutSmart(statPVs,0);
lcaPutSmart(strrep(statPVs,'AO','SO0'),'comment');
lcaPutSmart(strcat(statPVs,'.DESC'),'spare');
lcaPutSmart(strcat(statPVs,'.EGU'),'egu');
lcaPutSmart(strcat(statPVs,'.PREC'),0);
