function bAct = control_magnetQuadTrimGet(name, bAct, secn, isSLC)
% Name is QUAD name, finds QTRM if present.

if nargin < 3, secn='BACT';end
if nargin < 2, bAct=[];end

name=reshape(cellstr(name),[],1);
if nargin < 4, [name,d,isSLC]=model_nameConvert(name);end
secn=reshape(cellstr(secn),[],1);

if isempty(bAct)
    bAct=control_deviceGet(name,secn);
end

if ~any(isSLC), return, end

isQTRM=isSLC;
[nameQTRM(isSLC,1),isQTRM(isSLC)]=model_nameConvert(strrep(name(isSLC),'QUAD','QTRM'));
[m,prim]=model_nameSplit(name(isSLC));
isQTRM(isSLC)=isQTRM(isSLC) & strcmp(prim,'QUAD');
use=find(isQTRM);

if ~any(use), return, end

bActT=control_deviceGet(nameQTRM(use),secn(min(use,end)));
polyQ=control_magnetIVBGet(name(use));

% Get main current, add trim current and find main B.
for j=1:numel(use)
    iQ=polyval(polyQ(j,:),bAct(use(j)));
    iT=bActT(j);
    iA=iQ+iT;
    pQ=[polyQ(j,1:end-1) polyQ(j,end)-iA];
    r=roots(pQ);
    bQ=[r(imag(r) == 0);NaN];bAct(use(j))=bQ(1);
end
