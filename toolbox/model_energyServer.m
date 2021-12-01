function model_energyServer()
%MODEL_ENERGYSERVER
% MODEL_ENERGYSERVER() Runs the LEM server calculations & update loop.

% Features:

% Input arguments: none

% Output arguments: none

% Compatibility: Version 7 and higher
% Called functions: lcaPutSmart, lcaGetSmart,model_energyMagProfile, 
%                   model_energyMagScale, model_nameXAL, model_nameConvert

% Author: Henrik Loos, SLAC
% 2020: Mods for CU_HXR, CU_SXR.  William Colocho

% --------------------------------------------------------------------

% Suppress minor EPICS warnings.
lcaSetSeverityWarnLevel(4);

% Initialize LEM server Matlab PVs.
%statPVs=strcat('SIOC:SYS0:ML01:AO',cellstr(num2str([60:65 141:150 401:419]','%03d')));

statList = { 
    '060'  'Watchdog counter';  '061'  'Server pause';        '062'  'Get SCP phases';
    '063'  'HXR Calc design';       '064'  'Calc all HXR design'; '065' 'Calc HXR und match';
    '141' 'HXR Undulator BBA';  '142' 'Last LEM success';     '143' 'LEM trim(1) undo(2)';
    '144'  'Calc XTCAV_H match';'145' 'SXR Undulator BBA';    '146' 'reserved';
    '147' 'reserved';           '148' 'Linac BCD Select HXR(0) SXR(1)';             '149' 'reseverd';
    '150' 'reserved';           '401' 'L0';                   '402' 'L1';
    '403' 'L2';                 '404' 'L3';                   '405' 'LTUH_DMPH';
    '406' 'LTUS_DMPS';          '407' 'reserved';   '408' 'reserved'; 
    '409' 'reserved';           '410' 'reserved'; '411' 'reserved'; 
    '412' 'reserved';           '413' 'reserved'; '414' 'reserved'; 
    '415' 'reserved';           '416' 'reserved'; '417' 'reserved'; 
    '418' 'reserved';           '419' 'reserved' };
statPVs=strcat('SIOC:SYS0:ML01:AO', statList(:,1));
lcaPutSmart(strcat(statPVs,'.DESC'), statList(:,2));

lcaPutSmart(statPVs(1),0); % Don't reset
lcaPutSmart(strrep(statPVs,'AO','SO0'),'model_energyServer.m');
% lcaPutSmart(strcat(statPVs,'.DESC'), ...
%     {'Watchdog counter' 'Server pause' 'Get SCP phases' 'Calc design' 'Calc all design' ...
%      'Calc und match' 'HXR Undulator BBA' 'Last LEM success' 'LEM trim(1) undo(2)' ...
%      'Calc XTCAV match' 'SXR Undulator BBA'}); 
%lcaPutSmart(strcat(statPVs(17:21),'.DESC'),{'L0' 'L1' 'L2' 'L3' 'LTU'});

% L23_set_phase PVs
l23List={263 1 'MeV'    'Required L2 amplitude'; ...
         264 1 'MeV'    'Required L3 energy'; ...
         265 1 'MeV'    'LTU estimated energy'; ...
         266 1 'MeV'    'BC2 estimated energy'; ...
         268 1 'degS'   'SCP vs EPICS max phase error'; ...
         269 1 '0 or 1' 'Fix SLC phases'; ...
         270 1 'MeV'    'L2 energy'; ...
         271 1 'MeV'    'L3 flat energy'; ...
         272 4 ' '      'L2 fudge'; ...
         273 4 ' '      'L3 flat fudge'; ...
         274 1 'degS'   'L2 effective phase'; ...
         275 1 'MeV'    'L2 total energy'; ...
         276 1 'MeV'    'L2 flat energy'; ...
         277 4 ' '      'L2 flat fudge'; ...
         278 1 'MeV'    'L2 nofb flat total energy'; ...
         279 1 'MeV'    'L3 nofb flat total energy'; ...
         280 1 'MeV'    'S29 flat energy'; ...
         281 1 'MeV'    'S30 flat energy'; ...
         282 0 ' '      'L2 stations on'; ...
         283 0 ' '      'L3 station on'; ...
         284 4 'ratio'  'L2 feedback strength'; ...
         285 4 'ratio'  'L3 feedback strength'; ...
         286 1 'MeV'    'BC2 nominal energy'; ...
%         287 1 'MeV'    'PR55 nominal energy'; ...
         287 1 'MeV'    'LTUS nominal energy'; ...
         288 1 'MeV'    'LTUH nominal energy' ...
         };

l23PVs=strcat('SIOC:SYS0:ML00:AO',cellstr(num2str([l23List{:,1}]','%03d')));
l23Tags=l23List(:,4);
l23Units=l23List(:,3);
l23Prec=[l23List{:,2}]';

% Initialize old L23_set_phase PVs.
lcaPutSmart(strrep(l23PVs,'AO','SO0'),'model_energyServer.m');
lcaPutSmart(strcat(l23PVs,'.DESC'),l23Tags);
lcaPutSmart(strcat(l23PVs,'.EGU'),l23Units);
lcaPutSmart(strcat(l23PVs,'.PREC'),l23Prec);

% Initialize chicane server PVs.
rbPVlist=chicane_PVinit;  

% Initialize LEM structure.
static_h=[]; static_s=[];
endClth1 = model_rMatGet('ENDCLTH_1',[],[],'Z');

% Run indefinite loop.
tic;
while 1
    % Read LEM server control & status PVs.
    is=lcaGetSmart(statPVs);

    % Increment watchdog counter.
    lcaPutSmart(statPVs(1),is(1)+1);
    
    % Display 100 loop time
    if ~mod(is(1),100) %
        fprintf('%s Elapsed time for 100 loops is %3.5f seconds\n',datestr(now),toc);
        tic;
    end

    % Decrement pause counter if larger than 0.
    lcaPutSmart(statPVs(2),max(0,is(2)-1));

    % Get klystron & magnet data.
    static_h=model_energyMagProfile(static_h,'CU_HXR', ...
            'doPlot',0,'color','k','figure',1,'update',0,'getSCP',0); %is(3)
        
    static_s=model_energyMagProfile(static_s,'CU_SXR', ...
            'doPlot',0,'color','k','figure',1,'update',0,'getSCP',0);
            
    drawnow;
    
    m_h=model_energyMagScale(static_h,[],'design',is(4),'designAll',is(5), ...
        'undMatch',is(6),'undBBA',is(7),'dmpMatch',is(10),'display',0); 
    
    m_s=model_energyMagScale(static_s,[],'design',is(4),'designAll',is(5), ...
        'undMatch',is(6),'undBBA',is(7),'dmpMatch',is(10),'display',0);  
    
   
    % Skip if pause counter > 0.
    if is(2) > 0, continue, end

    % Write to LEM PVs.
    nameBase={'L0' 'L1' 'L2' 'L3'};
    nameBasePV=strcat('ACCL:',{'IN20:350' 'LI21:1' 'LI22:1' 'LI25:1'}');

    % Update fudge factors.
    lcaPutSmart(strcat(nameBasePV,':FUDGE'),static_h.klys.fudgeAct);
    lcaPutSmart(strcat(nameBasePV,':FUDGE_BCD2'),static_s.klys.fudgeAct);


    % Update accelerating regions. 
    for j=1:numel(nameBase)
        r=static_h.abstr.(nameBase{j});
        tags={'EG_SUM' 'CH_SUM' 'A_SUM' 'P_SUM' ...
              'EG_NOFS' 'EG_FS' 'A_NOFS' 'A_FS' 'N_SUM' 'R_FS'}';
        for t=tags(ismember(tags,fieldnames(r)))'
            lcaPutSmart([nameBasePV{j} ':' t{:}],r.(t{:}));
        end
    end
    
    % Update Beam Code 2 accelerating regions
    %
    for j=1:numel(nameBase)
        r=static_s.abstr.(nameBase{j});
        tags={'EG_SUM' 'CH_SUM' 'A_SUM' 'P_SUM' ...
              'EG_NOFS' 'EG_FS' 'A_NOFS' 'A_FS' 'N_SUM' 'R_FS'}';
        for t=tags(ismember(tags,fieldnames(r)))'
            lcaPutSmart([nameBasePV{j} ':' t{:} '_BCD2'],r.(t{:}));
            %disp([nameBasePV{j} ':' t{:} '_BCD2 float 0'])
        end
    end
    %
    lcaPutSmart('ACCL:LI29:0:A_SUM',static_h.abstr.S29.('A_SUM'));
    lcaPutSmart('ACCL:LI30:0:A_SUM',static_h.abstr.S30.('A_SUM'));
    lcaPutSmart('ACCL:LI29:0:A_SUM_BCD2',static_s.abstr.S29.('A_SUM'));
    lcaPutSmart('ACCL:LI30:0:A_SUM_BCD2',static_s.abstr.S30.('A_SUM'));
    
    

    % Update klystrons.
    nameXAL=model_nameXAL(static_h.klys.name);
    % Don't put missing PVs for 26-3
    incl = ~strcmp(nameXAL,'KLYS:LI26:31');
    lcaPutSmart(strcat(nameXAL(incl),':ALEM'),static_h.klys.ampF(incl));
    lcaPutSmart(strcat(nameXAL(incl),':PLEM'),static_h.klys.phF(incl));
    lcaPutSmart(strcat(nameXAL(incl),':EGLEM'),static_h.klys.gainF(incl));
    lcaPutSmart(strcat(nameXAL(incl),':CHLEM'),static_h.klys.ampF(incl).*sind(static_h.klys.phF(incl)));
    
    %lcaPutSmart(strcat(nameXAL,':ALEM_BCD2'),static_s.klys.ampF);
    %lcaPutSmart(strcat(nameXAL,':PLEM_BCD2'),static_s.klys.phF);
    %lcaPutSmart(strcat(nameXAL,':EGLEM_BCD2'),static_s.klys.gainF);
    %lcaPutSmart(strcat(nameXAL,':CHLEM_BCD2'),static_s.klys.ampF.*sind(static_s.klys.phF));
 

    % Update magnets. 
    
    linacBeamCode = lcaGetSmart('SIOC:SYS0:ML01:AO148') + 1; %EDM toggles between 0 and 1
    switch linacBeamCode
        case 1
            isLinac = m_h.magnet.z <= endClth1;
            updateMagnets(m_h, isLinac); 
        case 2
            isLinac = m_s.magnet.z <= endClth1;
            updateMagnets(m_s, isLinac); 
    end
    %LTUH to DMPH
    isLTUH = m_h.magnet.z > endClth1;
    updateMagnets(m_h, isLTUH); 
    %LTUS to DMPS
    isLTUS = m_s.magnet.z > endClth1;
    updateMagnets(m_s, isLTUS); 
    
    
    
    % Write to L23_set_phase PVs
    val=zeros(size(l23PVs));
    for j=1:numel(val)
        val(j)=static_h.abstr.(strrep(l23Tags{j},' ','_'));
    end
    lcaPutSmart(l23PVs,val);

    % Update chicane status PVs.
    updateValues(rbPVlist);  
end

function updateMagnets(m, use)
    name=model_nameConvert(m.magnet.name); 
    % Update magnets 
    isQuad=strncmp(name,'QUAD',4);
    lcaPutSmart(strcat(name(use),':EACT'),m.magnet.eAct(use));
    lcaPutSmart(strcat(name(use),':BLEM'),m.magnet.bDes(use));
    lcaPutSmart(strcat(name(isQuad&use),':BMAGX'),m.magnet.bMag(isQuad&use,1));  
    lcaPutSmart(strcat(name(isQuad&use),':BMAGY'),m.magnet.bMag(isQuad&use,2));




function rbPVlist = chicane_PVinit()

% Initialize chicane server Matlab PVs.
props={ 1  430 'Watchdog counter' ' '   0; ...
%
        1  431 'BCH X DES'        'mm'  2; ...
        2  432 'BC1 R56 DES'      'mm'  2; ...
        3  433 'BC2 R56 DES'      'mm'  2; ...
        4  434 'SXRSS delay DES'  'fs'  1; ...
        5  435 'HXRSS delay DES'  'fs'  1; ...
        6  436 'SXRSS phase CTRL' 'deg' 1; ...
        7  437 'HXRSS phase CTRL' 'deg' 1; ...
%
        1  440 'Enable QuickSTDZ' ' '   0; ...
%
        1  441 'BCH X FUNC'       ' '   0; ...
        2  442 'BC1 R56 FUNC'     ' '   0; ...
        3  443 'BC2 R56 FUNC'     ' '   0; ...
        4  444 'SXRSS delay FUNC' ' '   0; ...
        5  445 'HXRSS delay FUNC' ' '   0; ...
        1  446 'BCH X CTRL'       'mm'  2; ...
        2  447 'BC1 R56 CTRL'     'mm'  2; ...
        3  448 'BC2 R56 CTRL'     'mm'  2; ...
        4  449 'SXRSS delay CTRL' 'fs'  1; ...
        5  450 'HXRSS delay CTRL' 'fs'  1; ...
%
        1  509 'BCH R56 ACT'      'mm'  2; ...
        2  511 'BC1 R56 ACT'      'mm'  2; ...
        3  512 'BC2 R56 ACT'      'mm'  2; ...
        4  513 'SXRSS R56 ACT'    'um'  3; ...
        5  514 'HXRSS R56 ACT'    'um'  3; ...
        6  515 'BCH X ACT'        'mm'  2; ...
        7  516 'BC1 X ACT'        'mm'  2; ...
        8  517 'BC2 X ACT'        'mm'  2; ...
        9  518 'SXRSS X ACT'      'mm'  3; ...
       10  519 'HXRSS X ACT'      'mm'  3; ...
       11  520 'BCH phase ACT'    'deg' 1; ...
       12  521 'BC1 phase ACT'    'deg' 1; ...
       13  522 'BC2 phase ACT'    'deg' 1; ...
       14  523 'SXRSS phase ACT'  'deg' 1; ...
       15  524 'HXRSS phase ACT'  'deg' 1; ...
       16  525 'BCH delay ACT'    'ps'  1; ...
       17  526 'BC1 delay ACT'    'ps'  1; ...
       18  527 'BC2 delay ACT'    'ps'  1; ...
       19  528 'SXRSS delay ACT'  'fs'  1; ...
       20  529 'HXRSS delay ACT'  'fs'  1; ...
       };

statPVs=strcat('SIOC:SYS0:ML01:AO',cellstr(num2str([props{:,2}]','%03d')));
lcaPutSmart(strrep(statPVs,'AO','SO0'),'model_energyServer.m');
lcaPutSmart(strcat(statPVs,'.DESC'),props(:,3));
lcaPutSmart(strcat(statPVs,'.EGU'),props(:,4));
lcaPutSmart(strcat(statPVs,'.PREC'),[props{:,5}]');

rbPVlist = statPVs(20:end);


function state = updateValues(rbPVlist)

nC={'BCH' 'BC1' 'BC2' 'SXRSS' 'HXRSS'};
nB={'BXH2' 'BX12' 'BX22' 'BXSS2' 'BXHS2'};
nT={'BXH1T' 'BX11T' 'BX21T' 'BXSS1T' 'BXHS1T'};
nE={'BXH2' 'BX12' 'BX22' 'BYD1' 'BYD1'};
rS=[1e3 1e3 1e3 1 1];
dS=[1e-3 1e-3 1e-3 1 1];
state=zeros(1,5);

for j=1:5
    [R56,X,phi,delay,state(j)]=control_chicaneGet(nC{j},nB{j},nT{j},nE{j});
    if isnan(R56), continue, end
    lcaPutSmart(rbPVlist(j+[0 5 10 15]),[R56*rS(j);X*1e3;phi;delay*dS(j)]);
end


function [R56, X, phi, delay, state] = control_chicaneGet(name, nMain, nTrim, nEnergy)

[X,phi,delay,state]=deal(0);R56=NaN;
energy=control_deviceGet(nEnergy,'EDES');
if ~(energy > 0), return, end % includes NaN case
%state=control_deviceGet(nMain,'STATE','double') > 0;
state=control_deviceGet(nMain,'BDES','double') > 0;
if ismember(name,{'SXRSS' 'HXRSS'}) && ~state
    bDes=control_magnetGet(nTrim,'BDES');
    [d,d,d,d,d,R56,X,phi]=BC_phase(0,energy,name,bDes);
else
    bDes=control_magnetGet(nMain,'BDES');
    [d,d,d,d,d,R56,d,d,X,d,d,phi,delay]=BC_adjust(name,0,energy,bDes);
end
