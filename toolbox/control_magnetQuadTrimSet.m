function [bDesT, nameQTRM, isQTRM] = control_magnetQuadTrimSet(name, bDes, bDesQ)
% Name is QUAD name, finds QTRM if present.

[name,is,isSLC]=model_nameConvert(reshape(cellstr(name),[],1));
[nameQTRM,isQTRM]=model_nameConvert(strrep(name,'QUAD','QTRM'));
[m,prim]=model_nameSplit(name);
isQTRM=isQTRM & strcmp(prim,'QUAD');
use=isSLC & isQTRM;
bDesT=bDes;nameQTRM(~use)=name(~use);

if ~any(use), return, end

if nargin < 3
    bDesQ=control_deviceGet(name(use),'BDES');
else
    bDesQ(~use)=[];
end

[polyQU,polyQD]=control_deviceGet(name(use),{'IVBU' 'IVBD'});
nDegree=max(size(polyQU,2),size(polyQD,2));
polyQU(:,end+1:nDegree)=0;
polyQD(:,end+1:nDegree)=0;
polyQ=fliplr(polyQU);
polyQ(~any(polyQU,2),:)=fliplr(polyQD(~any(polyQU,2),:));

% Get main current, add trim current and find main B.
use=find(use);
for j=1:numel(use)
    iA=polyval(polyQ(j,:),bDes(use(j)));
    iQ=polyval(polyQ(j,:),bDesQ(j));
    iT=iA-iQ;
    bDesT(use(j))=iT;
end
