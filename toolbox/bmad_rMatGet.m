function [rMat, zPos, lEff, twiss, energy, n] = bmad_rMatGet(nameList, nameTo, opts, param)
%BMAD_RMATGET
% [RMAT, ZPOS, LEFF, TWISS, ENERGY] = BMAD_RMATGET(NAMELIST, NAMETO, OPTS, PARAM)
% gets transport matrix RMAT, z position ZPOS, effective length LEFF, Twiss
% params TWISS [energy phi_x beta_x alpha_x eta_x eta'_x phi_y ... eta'_y]'
% and energy ENERGY for devices in string or cellstr array NAMELIST. Names
% can be in MAD, EPICS format. The model data is retrieved from BMAD. 
% If NAMETO is not empty, the R-matrix
% is calculated from NAMELIST to NAMETO with both being arrays of same
% length or one scalar. If param is given and
% is 'Z', 'LEFF', 'twiss', or 'EN', then only this value is returned as
% RMAT. If NAMELIST is any MAD beam path names, the whole
% model table is returned.
%
% Features:
%
% Input arguments:
%    NAMELIST: Char or cellstr (array) of device names in MAD, EPICS, or SLC
%    NAMETO: Char or cellstr (array) of device names for from-to matrix (optional)
%    OPTS: Options, optional
%    PARAM: Optional parameter to only get 'R', 'Z', 'LEFF', 'twiss', or 'EN' returned
%
% Output arguments:
%    RMAT: Transport matrix(es) to NAMELIST or from NAMELIST to NAMETO
%    ZPOS: z-position of element(s) in NAMELIST (element.S)
%    LEFF: Effective length of element(s) in NAMELIST
%    TWISS: Twiss parameters a element(s) in NAMELIST
%    ENERGY: Energy at element(s) in NAMELIST

% Compatibility: Version 7 and higher, model_rMatGet.m
% Called functions: -----------> 
%                   

% Author: William Colocho, SLAC
%[modelSource,modelOnline]=model_init;

zLCLS=2014.701916; % in m, begin of LCLS injector relative to linac
[sys,accel]=getSystem;
if nargin < 4, param=[];end
paramList = {'R' 'Z' 'LEFF' 'twiss' 'EN' 'n'};
[param,idPar]=util_parseParams(param,paramList,nargout);
rOpts=cellstr(opts);
rOpts = rOpts(strncmp('POS',opts,3));
if isempty(rOpts) 
    rOpts = {'POS=END'};
%else
%    rOpts = rOpts{1};  
end
type='DESIGN';
typOpt=[opts{find(strncmp(opts,'TYPE=',5),1,'last')}];
if ~isempty(typOpt), type=upper(typOpt(6:end));end

nList=max(numel(nameList),numel(nameTo));
twiss=repmat([1 0 1 0 0 0 0 1 0 0 0]',1,nList);
zPos=zeros(1,nList);lEff=zeros(1,nList);energy=ones(1,nList);
n=[];

%beamPathList = {'SC_SXR' 'SC_HXR' 'SCBSYD' 'SCDIAG0' 'SCDASEL' 'CU_HXR' 'CU_SXR'  'CUALINE' 'FULL_MACHINE'};
beamPathList = { 'CU_HXR' };
if ~exist('opts','var')
    fprintf('Need opts.beampath information for BMAD calls\nOne Off:\n')
    fprintf('%s\n',beamPathList{:})
end

beamPathIndx = find(strncmpi(opts,'beampath',8));
if any(beamPathIndx)
    beamPath = validatestring(opts{beamPathIndx},strcat('beampath=',beamPathList));
    beamPath = strrep(beamPath, 'beampath=', '');
else
  fprintf('No option BEAMPATH provided via opts\n'), return
end

if strcmp(type, 'EXTANT'), type = 'LIVE'; end
modelPV = ['SIMULACRUM88:SYS0:1:' beamPath ':' type ':TWISS']
%modelPV = ['BMAD:SYS0:1:' beamPath ':' type ':TWISS'];

%model = eget(modelPV);
modelTwiss = eget(modelPV);
modelRmats = eget(strrep(modelPV,'TWISS','RMAT'));

if ~isempty(strmatch(nameList, beamPathList)) %Is it a full beamline?
    nameList=modelTwiss.element; %All elements
    id = 1:length(nameList);
    idTo = [];
else
    id = elementRmat(nameList, modelTwiss,rOpts(1));
    if ~isempty(nameTo)
        idTo = elementRmat(nameTo, modelTwiss,rOpts(end));
    else
        idTo = [];
    end
end

if ~isempty(idTo)
    if length(idTo) ~= length(id)
        if length(idTo) > length(id)
            id = ones(size(idTo)) * id;
        else
            idTo = ones(size(id)) * idTo;
        end
    end
end


if nargout == 1
    switch param{1}
        case 'R'
            rMat = rMatGet(modelRmats, nameTo, id, idTo); 
        case 'Z'
            rMat = modelTwiss.s(id);
        case 'LEFF'
            rMat = modelTwiss.length(id);
        case 'twiss'
            rMat = [modelTwiss.p0c(id)/1e9, modelTwiss.psi_x(id), modelTwiss.beta_x(id), modelTwiss.alpha_x(id), ...
                modelTwiss.eta_x(id), modelTwiss.etap_x(id),  modelTwiss.psi_y(id), modelTwiss.beta_y(id), ...
                modelTwiss.alpha_y(id),  modelTwiss.eta_y(id), modelTwiss.etap_y(id)]';
        case 'EN'
            rMat = modelTwiss.p0c(id)/1e9;
        case 'n'
            rMat = modelTwiss.element(id);
    end
else
    rMat = rMatGet(modelRmats, nameTo, id, idTo);
    if any( strcmp('POS=BEG', rOpts) )
        id = id +1; 
    end
    
    zPos = modelTwiss.s(id); 
    lEff = modelTwiss.length(id);
    twiss = [modelTwiss.p0c(id)/1e9, modelTwiss.psi_x(id), modelTwiss.beta_x(id), modelTwiss.alpha_x(id), ...
        modelTwiss.eta_x(id), modelTwiss.etap_x(id),  modelTwiss.psi_y(id), modelTwiss.beta_y(id), ...
        modelTwiss.alpha_y(id),  modelTwiss.eta_y(id), modelTwiss.etap_y(id)]';
    energy = modelTwiss.p0c(id)/1e9;
    n = modelTwiss.element(id);
    
  
end
end

function rMat = rMatGet(modelRmats, nameTo, id, idTo)

   for ii = 1:6
        for jj = 1:6
            r = sprintf('r%i%i',ii,jj);
            rList(ii,jj,:) = modelRmats.(r);
        end
    end
    
    if isempty(nameTo)
        for ii = 1:length(id)
            rMat(:,:,ii) = (rList(:,:,id(ii)));
        end
    else
        for ii = 1:max(length(id), length(idTo))
            rMat(:,:,ii) = rList(:,:,idTo(ii)) * inv(rList(:,:,id(ii)));
        end
    end
end

function id = elementRmat(nameList, model, rOpts)
%Return indices to modeled location based on element thinckness
%and requested location POS can be one  of [BEG,END]
%[c, ia, id] = intersect(nameList, model.element);
%isThickId = model.length(id) > 0;
[~, rOpts] = strtok(rOpts{:}, '='); rOpts = rOpts(2:end);

for ii = 1:length(nameList)
    %if isThickId(id(ii)) %Do we need this check?
        iid = find(strcmp(nameList{ii}, strtok(model.element,'#')));
        if isempty(iid), fprintf('%s %s\n',nameList{ii}, model_nameConvert(nameList{ii})); continue ,end
        switch rOpts
            case 'BEG', id(ii) = iid(1)-1;
            case 'MID'
                if length(iid) < 2
                    fprintf('Warning: No MID value for %s\n', nameList{id(ii)})
                else                    
                    d = find(strcmp('MUQ', model.element(iid(1):iid(1)+11)))
                    if any(d), id(ii) = iid(1)+d; break, end
                    % would mean(iid) work? only if always simetric ??                    
                end
                
            case 'END'
                if length(iid) == 2
                    id(ii) = iid(2);  %single thick element
                else
                    id(ii) = iid(1);
                end
        end
   % end
end
end

