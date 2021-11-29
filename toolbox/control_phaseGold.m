function [pAct, pDes, gold] = control_phaseGold(name, val, pAct, ds)
%PHASEGOLD
%  [PACT, PDES, GOLD] = PHASEGOLD(NAME, VAL, PACT, DS) sets RF PDES to VAL
%  without changing any actual phase by adjusting phase offsets
%  accordingly. Uses present PDES and PACT (EPICS PAD devices) or if
%  provided PACT as reference.

% Features:

% Input arguments:
%    NAME: String or cell string array for base name of RF PV or MAD alias.
%    VAL : New PDES values.
%    PACT: Present PACT values for EPICS PAD devices, optional.
%    DS  : Data Slot for PAU, default empty, i.e. set global parameters

% Output arguments:
%    PACT: List of RF devices actual phase, NaN if read failure
%    PDES: List of RF devices set phase, NaN if read failure
%    GOLD: List of RF devices new phase offsets, NaN if read failure

% Compatibility: Version 2007b, 2012a
% Called functions: control_phaseNames, control_phaseGet, control_phaseSet,
%                   lcaPut

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Get EPICS name.
if nargin < 4, ds=[];end
if nargin < 3, pAct=[];end
if nargin < 2, val=[];end
[name,is,d,nPdes,d,d,d,d,fdbk,send] = control_phaseNames(name);
[pAct0,pDes,gold0]=control_phaseGet(name,{'PHAS' 'PDES' 'GOLD'},ds);
if isempty(pAct), pAct=pAct0;end
if isempty(name), return, end
if isempty(val), val=pDes;end
val=val(:);val(end+1:numel(name),1)=val(end);pAct=pAct(:);

% Calculate new GOLD values.
isGold=is.SLC | is.L23 | is.PAC | is.PAD | is.KLY | is.LSN;
dPhi=val-pDes;
dPhi(is.PAD)=-(val(is.PAD)-pAct(is.PAD));
gold=gold0-dPhi;
gold(~is.LSN)=util_phaseBranch(gold(~is.LSN));

% Find single PDES for multiple PADs
[d,id]=unique(nPdes);isUn=false(size(isGold));isUn(id)=isGold(id);

% Display.
disp(char(strcat({'Original '},nPdes(isUn),{' = '},num2str(pDes(isUn),'%8.3f deg'))));
disp(char(strcat({'Original '},name(isGold),{' phase offset = '},num2str(gold0(isGold),'%8.3f deg'))));
%disp(char(strcat({'New '},name(isGold),{' phase offset = '},num2str(gold(isGold),'%8.3f deg'))));

% Set new PDES and GOLD.
if any(is.FBK) && ~any(is.LSN)
    lcaPut(fdbk(is.FBK),0); % turn OFF feedback temporarily
    lcaPut(send(is.FBK),1); % disable feedback temporarily
end
control_phaseSet(name(isUn),val(isUn),0,0,[],ds); % No trim
control_phaseSet(name(isGold),gold(isGold),0,0,'GOLD');
if any(is.FBK) && ~any(is.LSN)
    lcaPut(send(is.FBK),0); % re-enable feedback
    lcaPut(fdbk(is.FBK),1); % switch ON feedback
end

% Set new Klystron GOLD if SBST golded.
if any(is.SBS)
    klys=repmat(strrep(strrep(name(is.SBS)','SBST','KLYS'),':1',':'),8,1);
    klys=reshape(strcat(klys(:),repmat(num2str((11:10:81)'),numel(find(is.SBS)),1)),8,[]);
    isBad=ismember(klys,{'KLYS:LI21:11' 'KLYS:LI21:21' 'KLYS:LI24:11' 'KLYS:LI24:21' ...
        'KLYS:LI24:31' 'KLYS:LI24:71' 'KLYS:LI24:81'});
    gold=zeros(numel(klys),1);
    [d,d,d,d,d,gold(~isBad)]=control_phaseGet(klys(~isBad));
    klysVal=gold-reshape(repmat(val(is.SBS)'-pDes(is.SBS)',8,1),[],1);
    control_phaseSet(klys(~isBad),klysVal(~isBad),0,0,'GOLD');
end

[pAct,pDes,gold]=control_phaseGet(name,{'PHAS' 'PDES' 'GOLD'},ds);
