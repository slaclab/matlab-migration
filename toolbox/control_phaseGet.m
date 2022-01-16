function [pAct, pDes, aAct, aDes, kPhr, gold] = control_phaseGet(name, type, ds)
%PHASEGET
%  PHASEGET(NAME, TYPE, DS) get RF phase NAME_S_PV for EPICS devices and
%  NAME:PHAS for SLC devices (NAME:PHAS). For 24-1,2,3, it takes
%  NAME_PDES. If TYPE is specified, the output arguments will be determined
%  by the secondaries listed in TYPE.
%
% Features:
%
% Input arguments:
%    NAME: String or cell string array for base name of RF PV or MAD alias.
%    TYPE: Optional string or cell string array of secondaries.
%    DS  : Data Slot for PAU, default empty, i.e. get global parameters.
%    For other options DS takes on values:
%               Data slot 0 - Primary 60 Hz for CU_HXR
%               Data slot 1 - Primary 60 Hz for CU_SXR
%               Data slot 2 - Next 60 Hz for CU_SXR
%               Data slot 3 - Next 60 Hz for CU_HXR
%
%               Data Slots is an abstraction layer concept. We have 12
%               channels that we can be configured based on timing
%               "Conditional Expressions".
%
% Output arguments:
%    PACT: List of RF devices actual phase, NaN if read failure
%    PDES: List of RF devices set phase, NaN if read failure
%
% Compatibility: Version 2007b, 2012a, 2014b
% Called functions: model_nameConvert, aidaget, lcaGet
%                   control_phaseNames
%
% Author: Henrik Loos, SLAC
% Modified 9 Sept. 2020 by Bryce Jacobson

% --------------------------------------------------------------------

% AIDA-PVA imports
global AIDA_DOUBLE;

% Defaults
typeDef={'PHAS' 'PDES' 'AMPL' 'ADES' 'KPHR' 'GOLD'};
if nargin < 3, ds=[];end
if nargin < 2, type=[];end
if isempty(type), type=typeDef;end
type=strrep(strrep(strrep(cellstr(type),'PACT','PHAS'),'AACT','AMPL'),'POC','GOLD');
[d,id1]=ismember(type,typeDef);
[d,id2]=setdiff(typeDef,type);id=[id1 sort(id2(:))'];
type=typeDef(id(1:max(1,nargout)));

% Get EPICS name.
if epicsSimul_status, ds=[];end
[name,is,namePACT,namePDES,nameGOLD,nameKPHR,nameAACT,nameADES] = control_phaseNames(name,ds);
[pAct,pDes,aAct,aDes,kPhr,gold]=deal(nan(size(name)));

% Do simulation case.
if epicsSimul_status
    pDes=lcaGet(namePDES);
    pAct=pDes;
    aDes=lcaGet(nameADES);
    aAct=aDes;
    isKPHR=is.SLC & ~is.FPS | is.KLY;
    kPhr(isKPHR)=lcaGetSmart(nameKPHR(isKPHR));
    isGold=~cellfun('isempty',nameGOLD);
    gold(isGold)=lcaGet(nameGOLD(isGold));
    pAct(isKPHR)=kPhr(isKPHR)-gold(isKPHR);
    val={pAct,pDes,aAct,aDes,kPhr,gold};
    [pAct,pDes,aAct,aDes,kPhr,gold]=deal(val{id});
    return
end

% Use AIDA for SLC devices.
nameSLC=model_nameConvert(name,'SLC');
for j=find(is.SLC)'
    try
        if ismember('PHAS',type)
%            pAct(j)=pvaGet([nameSLC{j} ':PHAS'],AIDA_DOUBLE);
            pAct(j)=pvaGet([nameSLC{j} ':' namePACT{j}(end-3:end)],AIDA_DOUBLE);
        end
        if ismember('PDES',type)
%            pDes(j)=pvaGet([nameSLC{j} ':PDES'],AIDA_DOUBLE);
            pDes(j)=pvaGet([nameSLC{j} ':' namePDES{j}(end-3:end)],AIDA_DOUBLE);
        end
        if ismember('AMPL',type)
%            aAct(j)=pvaGet([nameSLC{j} ':AMPL'],AIDA_DOUBLE);
            aAct(j)=pvaGet([nameSLC{j} ':' nameAACT{j}(end-3:end)],AIDA_DOUBLE);
        end
        if ismember('ADES',type)
%            aDes(j)=pvaGet([nameSLC{j} ':ADES'],AIDA_DOUBLE);
            aDes(j)=pvaGet([nameSLC{j} ':' nameADES{j}(end-3:end)],AIDA_DOUBLE);
        end
        if ismember('KPHR',type)
            kPhr(j)=pvaGet([nameSLC{j} ':KPHR'],AIDA_DOUBLE);
        end
        if ismember('GOLD',type)
            gold(j)=pvaGet([nameSLC{j} ':GOLD'],AIDA_DOUBLE);
        end
    catch e
        handleExceptions(e)
        disp(['AIDA Error: No phases available for ' nameSLC{j}]);
    end
end
if all(is.SLC)
    val={pAct,pDes,aAct,aDes,kPhr,gold};
    [pAct,pDes,aAct,aDes,kPhr,gold]=deal(val{id});
    return
end

% Get EPICS phases.
is263 = strcmp(name,'KLYS:LI26:31');
use = ~is.SLC & ~is263;
if any(ismember({'PHAS' 'PDES'},type))
    pAct(use)=lcaGetSmart(namePACT(use));
    pDes(use)=lcaGetSmart(namePDES(use));
end
if any(ismember({'AMPL' 'ADES'},type))
    aAct(use)=lcaGetSmart(nameAACT(use));
    aDes(use)=lcaGetSmart(nameADES(use));
end
if ismember({'GOLD'},type)
    isGold=is.L23 | is.PAC | is.PAD | is.KLY | is.LSN;
    gold(isGold)=lcaGetSmart(nameGOLD(isGold));
end
if ismember({'KPHR'},type)
    kPhr(is.KLY)=lcaGetSmart(nameKPHR(is.KLY));
end

% Set pAct branch point 180 deg away from pDes.
use = ~is.SLC & ~is.KLY & ~is263;
pAct(use)=util_phaseBranch(pAct(use),pDes(use));

% Assemble list of requested output values.
val={pAct,pDes,aAct,aDes,kPhr,gold};
[pAct,pDes,aAct,aDes,kPhr,gold]=deal(val{id});
