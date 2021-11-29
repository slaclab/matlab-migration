function MLImageArchiver
% Saves profmon images for machine learning applications
% Tim Maxwell Nov 2, 2018

% delay between image acquisitions retrieved from EPICS
mindelay = 3; % minimum minutes delay per capture
maxdelay = 120; % max minutes delay per capture
loopdelay = 0.5; % loop polling speed in seconds
darkage = 60; % Only save no-beam images if it's been this many minutes since the last
Nimgs = 5;
NelMin = 1e7; % less than this is "no beam"
deffiletag = 'ProfMon'; % default file prefix.
cname = 'OTRDMP';

ename = model_nameConvert(cname);

% eh, what the hell.. do VCC too
cname2 = 'VCC';
ename2 = model_nameConvert(cname2);
cname3 = 'C-IRIS';
ename3 = model_nameConvert(cname3);
vccholdtime = 1;

global eDefQuiet; % Stop eDef messages after one good iteration

[ sys , accelerator ] = getSystem();
if isequal('LCLS',accelerator) % LCLS only
    ok = 1;
else
    s = 'Sorry, this only works for LCLS';
    put2log(s);
    ok = 0;
end

lastbeam = now - maxdelay/1440;
lastvcc = lastbeam;
lastdark = now - darkage/1440;
if (ok)
    % Watchdog check
    W = watchdog('SIOC:SYS0:ML03:AO091', 1, 'ML Image Archiver counter' );
    if get_watchdog_error(W)
        put2log('Another MLImageArchiver.m is running, exiting');
        exit
    end
    countdownPV = 'SIOC:SYS0:ML03:AO092';
    lcaPutSmart([countdownPV '.DESC'],'ML Image Archiver delay');
    lcaPutSmart([countdownPV '.EGU'],'minutes');
    [suppData.desc, suppData.pv] = initPVlist;
    statPVs = {...
        countdownPV;...
        'OTRS:DMP1:695:PNEUMATIC';...
        'KLYS:DMP1:1:MOD'};
    try
        lcaSetMonitor(statPVs,1,'double');
    catch ex
        lcaClear;
        rethrow(ex)
    end
        
    % Labels all cmLog messages with this name
    Logger = getLogger('ML Img Archiver');
    faultcount = 0;
    while ok
        try
            W = watchdog_run(W); % run watchdog counter
            if get_watchdog_error(W)
                s = 'Some sort of watchdog timer error';
                put2log(s);
            end
            statVals = lcaGetSmart(statPVs,1,'double');
            % Impose limits
            holdtime = statVals(1);
            holdtime = max([mindelay, min([maxdelay,holdtime])]);
            if now >= lastbeam + holdtime/1440
                tmit = lcaGetSmart('BPMS:DMP1:693:TMITBR',1,'double');
                doimgs = false;
                if (tmit > NelMin) && (statVals(3) == 1) % beam on screen and Modulator on
                    filetag = deffiletag;
                    doimgs = true;
                    lastbeam = now;
                elseif (tmit < NelMin) || ~statVals(2) % no beam or screen out
                    filetag = [deffiletag,'BG'];
                    % save BG images if it's been a whle.
                    doimgs = now >= lastdark + darkage/1440;
                    if doimgs,lastdark = now;end;
                end
                if doimgs
                    [suppData.val,suppData.ts, suppData.isPv] = ...
                        lcaGetSmart(suppData.pv);
                    d = profmon_grabSeries(cname,Nimgs);
                    for k = 1:length(d)
                        data = d(k);
                        data.otherPVs = suppData;
                        data.back = [];
                        ml_dataSave(data,filetag,...
                            ename,d(1).ts,['-' num2str(k) '.mat']);
                    end
                end
            end
            if now >= lastvcc + vccholdtime/1440;
                % throw in a VCC image, hastily written add on:
                if lcaGetSmart('LASR:IN20:196:PWR1H') >= 1.8
                    data = profmon_grab(cname2);
                    data2 = profmon_grab(cname3);
                    data.back = [];
                    data2.back = [];
                    ml_dataSave(data,deffiletag,...
                        ename2,data.ts,'.mat');
                    ml_dataSave(data2,deffiletag,...
                        ename3,data.ts,'.mat'); % Bad practice, but yes I'm saving the CIRIS image w/ the vcc time stamp for file name.
                    lastvcc = now;
                end
            end
            faultcount = 0;
            pause(loopdelay);
        catch ex
            if mod(faultcount,10) == 0 % don't totally spam log file
                put2log(['Problem: ' ex.message])
                put2log('Trying connection reset...');
                lcaClear;
                lcaSetMonitor(statPVs,1,'double');
            end
            faultcount = faultcount + 1;
        end
    end
    lcaClear;
end

s = 'ML Image Archiver exit';
put2log(s);


function [fileName, pathName] = ml_dataSave(data, header, name, ts, fileExt)
%DATASAVE
%  DATASAVE(DATA, HEADER, NAME, TS) saves
%  DATA in autogenerated or user specified filename and location.
dataDate=ts;
dataRoot=fullfile('/MachineLearningDataCollector');
dataYear=datestr(dataDate,'yyyy');
dataMon=datestr(dataDate,'mm');
dataDay=datestr(dataDate,'dd');
pathName=fullfile(dataRoot,dataYear,dataMon,dataDay);
if ~exist(pathName,'dir'), try mkdir(pathName);catch end, end
fileName=strrep([header '-' name '-' datestr(ts,'yyyy-mm-dd-HHMMSS') fileExt],':','_');
name=fullfile(pathName,fileName);
str='';
name=fullfile(pathName,fileName);
save(name,'data');




function [PVs, labels] = initPVlist()
labels = {...
    'XTCAV A Act',  'TCAV:DMP1:360:S_AV';...
    'XTCAV P Act',  'TCAV:DMP1:360:S_PV';...
    'XTCAV A PAD Des',  'TCAV:DMP1:360:ADES';...
    'XTCAV P PAD Des',  'TCAV:DMP1:360:PDES';...
    'XTCAV FB Des',     'SIOC:SYS0:ML01:AO168';...
    'XTCAV FB Act',     'SIOC:SYS0:ML01:AO170';...
    'Streak strength measured', 'OTRS:DMP1:695:TCAL_X';...
    'Calib. amplitude', 'SIOC:SYS0:ML01:AO214';...
    'Calib. phase',     'SIOC:SYS0:ML01:AO215';...
    'Sig_X measured',   'SIOC:SYS0:ML01:AO212';...
    'Sig_Z measured',   'OTRS:DMP1:695:BLEN';...
    'r15 measured',     'SIOC:SYS0:ML01:AO213';...
    'Gas Detector',     'GDET:FEE1:241:ENRCBR';...
    'Gun TMIT',         'BPMS:IN20:221:TMITBR';...
    'Dump TMIT',        'BPMS:DMP1:693:TMITBR';...
    'Laser stacker waveplate', 'WPLT:LR20:117:PSWP_ANGLE.RBV';...
    'Laser stacker WP max trans', 'WPLT:LR20:117:PS_ANG_MAX';...
    'P-arm laser shutter', 'SHTR:LR20:117:PARM_STS';...
    'S-arm laser shutter', 'SHTR:LR20:117:SARM_STS';...
    'Laser stacker delay', 'PSDL:LR20:117:TACT';...
    'Fast 6x6 enabled', 'FBCK:FB04:LG01:MODE';...
    'DL1 E enabled',    'FBCK:FB04:LG01:S1USED';...
    'L0B amplitude',    'ACCL:IN20:400:L0B_ADES';...
    'DL1 LEM energy',   'REFS:IN20:751:EDES';...
    'BC1 E enabled',    'FBCK:FB04:LG01:S2USED';...
    'BC1 Ipk enabled',  'FBCK:FB04:LG01:S3USED';...
    'BC1 Ipk set',      'FBCK:FB04:LG01:S3DES';...
    'BC1 Ipk actual',   'BLEN:LI21:265:AIMAXBR';...
    'L1S amplitude',    'ACCL:LI21:1:L1S_S_AV';...
    'L1S phase',        'ACCL:LI21:1:L1S_S_PV';...
    'L1X amplitude',    'ACCL:LI21:180:L1X_S_AV';...
    'L1X phase',        'ACCL:LI21:180:L1X_S_PV';...
    'BC1 LEM energy',   'REFS:LI21:231:EDES';...
    'BC1 collimator (-)', 'COLL:LI21:235:LVPOS';...
    'BC1 collimator (+)', 'COLL:LI21:236:LVPOS';...
    'BC1 R56',          'SIOC:SYS0:ML01:AO511';...
    'BC2 E enabled',    'FBCK:FB04:LG01:S4USED';...
    'BC2 Ipk enabled',  'FBCK:FB04:LG01:S5USED';...
    'BC2 Ipk set',      'FBCK:FB04:LG01:S5DES';...
    'BC2 Ipk actual',   'BLEN:LI24:886:BIMAXBR';...
    'L2 amplitude',     'ACCL:LI22:1:ADES';...
    'L2 phase',         'ACCL:LI22:1:PDES';...
    'L2 chirp',         'FBCK:FB04:LG01:CHIRPDES';...
    'BC2 R56',          'SIOC:SYS0:ML01:AO512';...
    'BC2 LEM energy',   'REFS:LI24:790:EDES';...
    'BC2 Foil 1 position', 'FOIL:LI24:804:LVPOS';...
    'BC2 Foil 2 position', 'FOIL:LI24:807:LVPOS';...
    'DL2 E enabled',    'FBCK:FB04:LG01:S6USED';...
    'L3 amplitude',     'ACCL:LI25:1:ADES';...
    'L3 phase',         'ACCL:LI25:1:PDES';...
    'L3 LEM energy',    'REFS:DMP1:400:EDES';...
    'Und bump amplitude', 'PHYS:UND1:BUMP:CURRENTAMPL';...
    'Und bump plane',   'PHYS:UND1:BUMP:CURRENTPLANE';...
    'Und bump start girder', 'PHYS:UND1:BUMP:CURRENTSTART';...
    'Und bump stop girder', 'PHYS:UND1:BUMP:CURRENTSTOP'};

PVs = labels(:,2);
labels = labels(:,1);