function bActS = control_magnetLGPSGet(par, bActL, secn, isSLC)
% Name is QUAD name, finds LGPS if present.

if nargin < 4, isSLC=[];end
if nargin < 3, secn='BACT';end
if nargin < 2, bActL=[];end

% Test if PAR is struct, if not call control_magnetLGPSMap().
if ~isstruct(par)
    name=par;bActS=bActL;
    if isempty(bActS), bActS=zeros(numel(name),1);end
    [isS,par]=control_magnetLGPSMap(name,isSLC);
    bActS(isS)=control_magnetLGPSMapGet(par,[],secn);
    return
end

if isempty(fieldnames(par)), bActS=zeros(0,1);return, end

idC=par.idC; % Map
pS=par.pS; % String polynomials
isB=par.isB; % is BNDS
nameL=par.nameL; % LGPS names
pL=par.pL; % LGPS polynomials
bM=par.bM; % max B LGPS

% Find unique SECN.
[secn,d,idS]=unique(reshape(cellstr(secn),1,[]));

% Get LGPS B.
if isempty(bActL)
    bActL=cell(1,numel(secn));
    [bActL{:}]=control_deviceGet(nameL,secn);
    bActL=[bActL{:}];
end

% Get LGPS currents.
iL=bActL*0;
for j=1:numel(nameL)
    for k=1:size(bActL,2)
        iL(j,k)=polyval(pL(j,:),bActL(j,k));
    end
end

% Sum all LGPS per string magnet.
iS=zeros(numel(idC),1);
for j=1:numel(iS)
    iS(j)=sum(iL(idC{j},idS(min(j,end))));
end

% Calc quad B.
bActS=iS*0;pL(:,end+1:2)=1; % Make sure at least 2 coefficients.
for j=find(~isnan(iS))'
    p=pS(j,:);
    if isB(j) && ~isempty(idC{j})
        id=idC{j}(1);
        if ~(pL(id,end-1) == 1)
            p=pL(id,:);
        end
    end
    p(end)=p(end)-iS(j);
    r=roots(p);r(imag(r) ~= 0)=[];
    if isB(j) && ~isempty(idC{j})
        r(sign(r) ~= sign(bM(id)))=[];
        r(abs(r) > abs(bM(id)))=[];
    end
    bS=[r;NaN];bActS(j)=bS(1);
end
