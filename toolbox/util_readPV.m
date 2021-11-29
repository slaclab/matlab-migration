function [pvRec, isPV] = util_readPV(pvNameList, getAll, nUse)
%UTIL_READPV
%  UTIL_READPV(PVNAMELIST, GETALL) retrieves epics values for list of PV
%  names PVNAMELIST.

% Features:

% Input arguments:
%    PVNAMELIST: String or cell string array of PV names to be read
%    GETALL: Get additional .EGU and .DESC fields if set to 1, default is 0

% Output arguments:
%    PVREC: Structure array containing PV data
%        NAME: Name of PV
%        VAL: Value of PV
%        TS: Time stamp in Matlab time
%        DESC: Description field of PV (optional)
%        EGU: Units of PV (optional)
%    ISPV: List of flags indicating if the PV is valid

% Compatibility: Version 7 and higher
% Called functions: lcaGet

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if nargin < 2, getAll=0;end
if nargin < 3, nUse=0;end
pvNameList=reshape(cellstr(pvNameList),[],1);
nPV=length(pvNameList);
%valList=NaN(length(pvNameList),1);
[valList,tsList,isPV]=lcaGetSmart(pvNameList,nUse,'double');

pvRec(1:nPV,1)=struct;
for j=1:nPV
    pvRec(j).name=pvNameList{j};
    pvRec(j).val=valList(j,:);
    pvRec(j).ts=lca2matlabTime(tsList(j));
    pvRec(j).desc='';
    pvRec(j).egu='';
end
if ~getAll || ~any(isPV), return, end

props=repmat({''},2*length(pvNameList),1);
pvNameList=strtok(pvNameList,'.'); % Get base PV name w/o field
propsList=[strcat(pvNameList,'.DESC');strcat(pvNameList,'.EGU')];
props([isPV;isPV])=lcaGetSmart(propsList([isPV;isPV]),0,'char');
[pvRec.desc,pvRec.egu]=deal(props{:});
