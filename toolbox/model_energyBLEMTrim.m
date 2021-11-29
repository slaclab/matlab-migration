function model_energyBLEMTrim(varargin)
%MODEL_ENERGYBLEMTRIM
% MODEL_ENERGYBLEMTRIM() Trims magnets to BLEM values depending on
% selected LEM regions from LEM server PVs.

% Features:

% Input arguments:
%    OPTS:   Options
%            ACTION: Selects magnet function, default TRIM
%            UNDO:   Uses BDESSAVE & EDESSAVE to restore previous settings
%            QUIET:  Don't query for user input

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: lcaGetSmart, model_nameRegion, lcaPutSmart,
%                   model_energyMagTrim, util_appClose

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'action','TRIM', ...
    'undo',0, ...
    'quiet',0, ...
    'display',0 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Obtain selected LEM regions.
statPVs=strcat('SIOC:SYS0:ML01:AO',cellstr(num2str((401:406)','%03d')));
use=lcaGetSmart(statPVs) == 1;
regList=lcaGetSmart(strcat(statPVs,'.DESC'));

% Determine source PVs.
attrB=':BLEM';
attrE=':EACT';
if opts.undo, attrB=':BDESSAVE';attrE=':EDESSAVE';end

% Obtain magnet names, BLEM and EACT values.
m.magnet.name=model_nameRegion([],regList(use),'LEM',1);

[m.magnet.bDes,tsB]=lcaGetSmart(strcat(m.magnet.name,attrB));
[m.magnet.eDes,tsE]=lcaGetSmart(strcat(m.magnet.name,attrE));

% Obtain state & time of last LEM.
[success,tsS]=lcaGetSmart('SIOC:SYS0:ML01:AO142');

% Obtain actual (ideal) fudge factors.
nameBasePV=strcat('ACCL:',{'IN20:350' 'LI21:1' 'LI22:1' 'LI25:1'}');
m.klys.fudgeDes=lcaGetSmart(strcat(nameBasePV,':FUDGE'));
if opts.undo, m.klys=[];end

% Query for magnet trim.
if opts.quiet
    str='Continue';
elseif opts.undo
    str=questdlg(['Do you really want to Undo LEM Trim in ' sprintf('%s ',regList{use}) '?'],'Undo LEM Trim Magnets','Continue','Abort','Abort');
else
    str=questdlg(['Do you really want to Trim all magnets in ' sprintf('%s ',regList{use}) 'to BLEM values?'],'LEM Trim Magnets','Continue','Abort','Abort');
end

% Check time stamps for undo.
if opts.undo && strcmp(str,'Continue')
    tsB=lca2matlabTime(tsB);
    tsE=lca2matlabTime(tsE);
    tsS=lca2matlabTime(tsS);
    if any([tsB;tsE] > tsS) || any([tsB;tsE] < tsS-30/24/60/60) || ~success
        strTS={'Time stamps of LEM undo data out of sync or last LEM action unsuccessful. ' ...
            'Cancelling UNDO action...'};
        if opts.quiet
            gui_statusDisp([],strTS);
        else
            uiwait(errordlg(strTS,'Invalid LEM Undo Data','modal'));
        end
        str='';
    end
end

% If requested, trim or undo trim magnets & update fudge factors and LEM success.
if strcmp(str,'Continue') && any(use)
    if ~opts.undo
        eDesOld=lcaGetSmart(strcat(m.magnet.name,':EDES'));
        lcaPutSmart(strcat(m.magnet.name,':EDESSAVE'),eDesOld);
        bDesOld=lcaGetSmart(strcat(m.magnet.name,':BDES'));
        lcaPutSmart(strcat(m.magnet.name,':BDESSAVE'),bDesOld);
%        control_magnetSet(m.magnet.name,[],'action','SAVE_BDES','wait',.5);
    end
     %removeList =  strncmp('BTRM:LI24:810', m.magnet.name,13);
     %m.magnet.name(removeList) = [];
     %m.magnet.bDes(removeList) = [];
     %m.magnet.eDes(removeList) = [];
    iok=model_energyMagTrim(m,[],opts);
    lcaPutSmart('SIOC:SYS0:ML01:AO142',iok);
end

% Reset LEM server pause counter.
lcaPutSmart('SIOC:SYS0:ML01:AO061',0);

% Exit Matlab if only application running.
if numel(dbstack) == 1, util_appClose([]);end
