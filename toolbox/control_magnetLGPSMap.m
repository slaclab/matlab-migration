function [isS, par] = control_magnetLGPSMap(name, isSLC)
% Name is QUAD name, finds LGPS if present.

name=reshape(cellstr(name),[],1);
if nargin < 2 || isempty(isSLC), [name,d,isSLC]=model_nameConvert(name);end

isS=isSLC;par=struct;
if ~any(isSLC), return, end

% Find QUAS, BNDS, SXTS, or SPTS.
[micro(isSLC,1),prim(isSLC,1),unit(isSLC,1)]=model_nameSplit(name(isSLC));
isS(isSLC)=ismember(prim(isSLC),{'BNDS' 'QUAS' 'SXTS' 'SPTS'});
idS=find(isS);isB=strcmp(prim(isS),'BNDS');

if ~any(isS), return, end

% Get unique quad list.
[nameS,isU,idU]=unique(name(isS));
unit=str2num(char(unit(idS(isU))));
micro=micro(idS(isU));

% Get LGPS list and slave power supply numbers.
microList=micro;if ismember('DR13',micro), microList=['DR12';microList];end
nLGPSList=model_nameConvert({'LGPS'},[],unique(microList));
mags=control_deviceGet(nLGPSList,'MAGS');
mags=mags(:,2:2:end);

% Encode micro in mags & unit numbers.
microL=model_nameSplit(nLGPSList);
microL(strcmp(nLGPSList,'DR12:LGPS:2'))={'DR13'};
[d,id2]=ismember(microL,unique(microList));
[d,id3]=ismember(micro,unique(microList));

% Find requested magnets in slave list.
[isM,idM]=ismember(mags+repmat(1e4*id2,1,size(mags,2)),unit+1e4*id3);
idM=idM(isM);

% Get matching LGPS names.
[idR,d]=find(isM);

% Used LGPS list.
[idL,b,idUL]=unique(idR);
nameL=nLGPSList(idL);
% Mapped list of LGPS vs. String: [nameL(idUL) nameS(idM)]

% Make mapping cell.
idC=cell(numel(nameS),1);
for j=1:numel(nameS)
    idC{j}=idUL(idM == j);
end
idC=idC(idU); % [name(idS(j)) nameL(idC2{j})']

% Get LGPS polynomials and max field.
pL=control_magnetIVBGet(nameL);
bM=control_deviceGet(nameL,'BMAX');

% Get string magnet polynomials.
pS=control_magnetIVBGet(nameS);
pS=pS(idU,:);

par.idC=idC; % Map
par.pS=pS; % String polynomials
par.isB=isB; % is BNDS
par.nameL=nameL; % LGPS names
par.pL=pL; % LGPS polynomials
par.bM=bM; % max B LGPS
