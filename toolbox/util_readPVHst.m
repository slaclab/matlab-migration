function [pvRec, pulseIdList, isPV] = util_readPVHst(pvNameList, eDefNum, getAll, nUse)

% X = PV name
% X4 = Last value in edef 4
% XHST4 = Buffer of values in edef 4
% XCNTHST4 = Buffer of valid flags for edef 4
% XRMSHST4 = Buffer of rms values for edef 4

if nargin < 3, getAll=0;end
pvNameList=cellstr(pvNameList);
nPV=numel(pvNameList);

pulseIdPV=sprintf('PATT:%s:1:PULSEIDHST%d',getSystem,eDefNum);
if nargin < 4 || ~nUse
    nUse=lcaGet([pulseIdPV '.NUSE']);
end
pulseIdList=lcaGet(pulseIdPV,nUse);
pvRec(1:nPV,1)=struct;
isPV=true(0);
if ~nPV, return, end

[valList,tsList,isPV]=lcaGetSmart(strcat(pvNameList,sprintf('HST%d',eDefNum)),nUse);
valList(:,end+1:nUse)=NaN;

for j=1:nPV
    pvRec(j).name=pvNameList{j};
    pvRec(j).val=valList(j,:);
    pvRec(j).ts=lca2matlabTime(tsList(j));
    pvRec(j).desc='';
    pvRec(j).egu='';
end

if ~getAll, return, end
pv=util_readPV(pvNameList,1);
[pvRec.desc]=deal(pv.desc);
[pvRec.egu]=deal(pv.egu);
