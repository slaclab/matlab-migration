function [bAct, bDes, bMax, eDes] = control_magnetGet(name, secn)
%CONTROL_MAGNETGET
%  [BACT, BDES, BMAX, EDES] = CONTROL_MAGNETGET(NAME) get magnet NAME:BACT
%  and NAME:BDES.

% Features:

% Input arguments:
%    NAME: Base name of magnet PV.
%    SECN: Magnet secondary (optional, default BACT)

% Output arguments:
%    BACT: Magnet BACT
%    BDES: Magnet BDES
%    BMAX: Magnet BMAX
%    EDES: Magnet EDES

% Compatibility: Version 2007b, 2012a
% Called functions: lcaGetSmart, model_nameConvert, control_magnetNameLGPS,
%                   control_magnetQuadTrimGet, control_magnetLGPSMap,
%                   control_magnetLGPSGet, control_energyNames

% Author: Henrik Loos, SLAC
% Mod:    T.J.M - 14 May 2017, Treat WIGG same as USEG...


% --------------------------------------------------------------------

name=reshape(cellstr(name),[],1);

% Fix stupid FACET wiggler.
name(ismember(name,{'WIGE1' 'WIGE3'}))={'WIGE2'};

[name,d,isSLC]=model_nameConvert(name,'EPICS');
[bAct,bDes,bMax,eDes]=deal(zeros(size(name)));
if isempty(name), return, end


% Get magnet B or undulator K or Collimator V
str=repmat({'B'},numel(name),1);
isUnd=strncmp(name,'USEG',4)|strncmp(name,'WIGG',4);str(isUnd)={'K'};
nn=char(name);nn(:,1:min(5,end))=[];
isStep=strncmp(cellstr(nn),'STEP',4);str(isStep)={'V'};
isMcor=strncmp(name,'MCOR',4);str(isMcor)={'I'};

if nargin < 2
    secn=strcat(str,'ACT');
else
    secn=cellstr(secn);secn=secn(:);secn(end+1:numel(name),1)=secn(end);
end
secn(isMcor)=strrep(strrep(secn(isMcor),'BDES','ISETPT'),'BACT','IACT');

% Do BNDS/QUAS stuff.
[nameLGPS,is]=control_magnetNameLGPS(name,isSLC);

% Read back BACT.
nameB=name;nameB(is.Str)=nameLGPS;
bAct=lcaGetSmart(strcat(nameB,':',secn));

% Find QTRMs.
isB=strcmp(secn,'BDES') | strcmp(secn,'BACT');
bAct(isB)=control_magnetQuadTrimGet(nameB(isB),bAct(isB),secn(isB),isSLC(isB));

% New code for LGPSs.
[isS,par]=control_magnetLGPSMap(name,isSLC);
bAct(isS)=control_magnetLGPSGet(par,[],secn(isS));

% Find LGPSs.
%bAct(isB)=control_magnetLGPSGet(name(isB),bAct(isB),secn(isB),isSLC(isB));

if nargout > 1
    secn=strcat(str,'DES');secn(isMcor)=strcat(str(isMcor),'SETPT');
    bDes=lcaGetSmart(strcat(nameB,':',secn));
    isBDES=strcmp(str,'B');
    bDes(isBDES)=control_magnetQuadTrimGet(nameB(isBDES),bDes(isBDES),'BDES',isSLC(isBDES));
    bDes(isS)=control_magnetLGPSGet(par,[],'BDES');
%    bDes(isBDES)=control_magnetLGPSGet(name(isBDES),bDes(isBDES),'BDES',isSLC(isBDES));
end

if nargout > 2
    secn=strcat(str,'MAX');secn(isMcor)=strcat(str(isMcor),'SETPT.DRVH');
    bMax=lcaGetSmart(strcat(nameB,':',secn));
end

% XTA
bAct(isMcor)=bAct(isMcor)/0.579;
bDes(isMcor)=bDes(isMcor)/0.579;
bMax(isMcor)=bMax(isMcor)/0.579;

if nargout > 3
    nameEDES=control_energyNames(name);
    eDes=NaN(size(name));isSLC(isMcor)=true;
    if any(~isSLC), eDes(~isSLC)=lcaGetSmart(strcat(nameEDES(~isSLC),':EDES'));end
    isEMOD=isSLC & (is.QUAS | ~(is.Str | is.BEND | is.Trim)) & ~isMcor;
    if any(isEMOD), eDes(isEMOD)=lcaGetSmart(strcat(name(isEMOD),':EMOD'));end
%    if any(is.BNDS | is.BEND), eDes(is.BNDS | is.BEND)=lcaGetSmart(strcat(name(is.BNDS | is.BEND),':KMOD'));end
end
