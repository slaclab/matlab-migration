function [m, k] = model_energyMagScale(magnet, klys, varargin)
%ENERGYMAGSCALE
% [M, K] = ENERGYMAGSCALE(MAGNET, KLYS, OPTS) calculates new BDES for
% magnets in structure MAGNET by scaling from EDES to EACT. Also calculates
% proper current for bend trims present in the device list.

% Features:

% Input arguments:
%    MAGNET: Structure as returned from MODEL_ENERGYMAGPROFILE
%    KLYS:   Optional, default []. Then MAGNET & KLYS are the sub-structures 
%    OPTS:   Options
%            UNDMATCH:  Default 0, calculate undulator matching quad BDES
%            DMPMATCH:  Default 0, calculate dump matching quad BDES
%            DESIGN:    Default 0, set non-matching quads to design
%            DESIGNALL: Default 0, set all quads to design
%            DISPLAY:   Default 0, print list of names and values

% Output arguments:
%    M: Updated structure MAGNET
%    K: Updated structure KLYS

% Compatibility: Version 7 and higher
% Called functions: util_parseOptions, model_energyUndMatch,
%                   model_energyBTrim, model_energyDmpMatch,
%                   (obsolete) control_magnetQtrimGet, control_magnetQtrimSet

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'undMatch',0, ...
    'dmpMatch',0, ...
    'design',0, ...
    'designAll',0, ...
    'undBBA',0, ...
    'display',0 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);
if nargin < 2, klys=[];end

m=magnet;k=klys;
if isfield(magnet,'magnet'), [m,k]=deal(m.magnet,m.klys);end
if ~isfield(m,'bDes'), return, end

bDes=m.bDes;

%nameQ30=strcat('Q30',{'2';'3';'4';'5';'6';'7';'8'},'01');
nameQ30={};
isQUMH=ismember(m.name,strcat('QUM',{'1';'2';'3';'4'}));
isQUMS= ismember(m.name,{'QUM1B' 'QUM2B' 'QUM3B' 'QUM4B' 'QSXH16' 'QSXH19' 'QSXH21' 'QSXH24'});
%nameDmp={'QUM1' 'QUM2' 'QUM3' 'QUM4' 'QUE1' 'QUE2' 'QDMP1' 'QDMP2' 'QU33'};
%nameDmp={'QUE1' 'QUE2' 'QDMP1' 'QDMP2' 'QU33'};
nameDmpH={'QUE1' 'QUE2' 'QDMP1' 'QDMP2' 'QHXH46'};
isDMPH=ismember(m.name,nameDmpH);
nameDmpS={'QUE1B' 'QUE2B' 'QDMP1B' 'QDMP2B' 'QSXH47'};
isDMPS=ismember(m.name,nameDmpS);
%isDMP=ismember(m.name,nameDmp);
isQ30=ismember(m.name,nameQ30);
%isQU33=strcmp(m.name,'QU33');  
%2020  last undulator quads are 'QHXH46' and 'QSXH47'
isQHXH46=strcmp(m.name,'QHXH46');
isQSXH47=strcmp(m.name,'QSXH47');
isT.Q30=ismember(m.name,strcat(nameQ30,'T'));
isT.BXH=ismember(m.name,strcat('BXH',{'1';'3';'4'},'_TRIM'));
isT.BX0=ismember(m.name,strcat('BX0',{'1'},'_TRIM'));
isT.BX1=ismember(m.name,strcat('BX1',{'1';'3';'4'},'_TRIM'));
isT.BX2=ismember(m.name,strcat('BX2',{'1';'3';'4'},'_TRIM'));
isT.BX3=ismember(m.name,strcat('BX3',{'1';'2';'5';'6'},'_TRIM'));
isT.BCX32=ismember(m.name,strcat('BCX32',{'1';'3';'4'},'_TRIM'));
isT.BCX35=ismember(m.name,strcat('BCX35',{'1';'3';'4'},'_TRIM'));
isT.BCX36=ismember(m.name,strcat('BCX36',{'1';'3';'4'},'_TRIM'));
isT.BX3B=ismember(m.name,strcat(strrep('BX3#B','#',{'1','2'}),'_TRIM'));

isTrim=isT.Q30 | isT.BXH | isT.BX1 | isT.BX2 | isT.BX3 | ...
      isT.BCX32 |  isT.BCX35 |isT.BCX36 | isT.BX3B;  
m.eAct(isTrim)=0;

% Unused code for LI30 quad trims.
bDes(isQ30)=control_magnetQtrimGet(m.name(isQ30),bDes(isQ30),bDes(isT.Q30));

bDesOld=bDes;
bDes=m.eAct./m.eDes.*bDes;

if opts.design || opts.designAll
    nameMatch=[{'QA01' 'QA02' 'QE01' 'QE02' 'QE03' 'QE04' 'QM01' 'QM02' ...
        'QB' 'QM03' 'QM04' 'Q21201' 'Q21301' 'QM11' 'QM12' 'QM13'} ...
        strcat('Q26',{'2' '3' '4' '5' '6' '7' '8' '9'},'01') ...
        {'Q5' 'Q6' 'QA0' 'QVM2'  'QEM1' 'QEM2' 'QEM3' 'QEM4' ...
        'QEM3V' 'QUM1' 'QUM2' 'QUM3' 'QUM4' ...
        'QUM1B' 'QUM2B' 'QUM3B' 'QUM4B' 'QSXH16' 'QSXH19' 'QSXH21' 'QSXH24' ...
        'QUE1B' 'QUE2B' 'QDMP1B' 'QDMP2B' 'QSXH47'}];
    nameGeV={'BX01' 'BX02' 'BY1' 'BY2' 'BX31' 'BX32' 'BX35' 'BX36' ...
             'BYD1' 'BYD2' 'BYD3' 'BYDSH' ...
             'BRCUSDC1' 'BRCUSDC2'  'BLRCUS'  'BYCUS1' 'BYCUS2'  'BRCUS1'  ...  
             'BX31B' 'BX32B' 'BY1B' 'BY2B' 'BYD1B' 'BYD2B' 'BYD3B' 'BYDSS'...
             'BYKIK1S' 'BYKIK2S' 'BKRCUS'};

    if opts.designAll, nameMatch={};end
    isDesign=strncmp(m.name,'Q',1) & ~ismember(m.name,nameMatch);
    bp=m.eAct/299.792458*1e4; % kG m
    bDesign=m.kDes.*bp.*m.lEff; % kG
    bDes(isDesign)=bDesign(isDesign);
    isGeV=ismember(m.name,nameGeV);
    bDes(isGeV)=m.eAct(isGeV);
end

if sum(isQUMH) == 4 && opts.undMatch
    bDes(isQUMH)=model_energyUndMatch(m.eAct(find(isQUMH,1)), 'CU_HXR');
end
if sum(isQUMS) == 8 && opts.undMatch
    bDes(isQUMS)=model_energyUndMatch(m.eAct(find(isQUMS,1)), 'CU_SXR');
end

if sum(isDMPH) == 5 && opts.dmpMatch
    bDmp=model_energyDmpMatch(m.eAct(find(isDMPH,1)),'CU_HXR');
    bDes(isDMPH)=bDmp(5:end);
end
if sum(isDMPS) == 5 && opts.dmpMatch
    bDmp=model_energyDmpMatch(m.eAct(find(isDMPS,1)),'CU_SXR'); 
    bDes(isDMPS)=bDmp(9:end);
end

if any(isQHXH46) && opts.undBBA
    bDesign=m.kDes.*8/299.792458*1e4.*m.lEff; % kG
    bDes(isQHXH46)=bDesign(isQHXH46);
end
if any(isQSXH47) && opts.undBBA
    bDesign=m.kDes.*8/299.792458*1e4.*m.lEff; % kG
    bDes(isQSXH47)=bDesign(isQSXH47);
end

bDesNew=bDes;

for tag={'BXH' 'BX0' 'BX1' 'BX2'}
    isTag=isT.(tag{:});
    if any(isTag)
        % Get desired main BDES from second magnet BXn2
        bDes(isTag)=model_energyBTrim(bDes(strcmp(m.name,[tag{:} '2'])),[],tag{:});
    end
end

if sum(isT.BX3) == 4
    bDes(isT.BX3)=model_energyBTrim(bDes(strcmp(m.name,'BYD1')),[],'BX3');
end

if sum(isT.BX3B) == 2
    bDes(isT.BX3B)=model_energyBTrim(bDes(strcmp(m.name,'BYD1B')),[],'BX3B');
end
 

[bDes(isQ30),bDes(isT.Q30)]=control_magnetQtrimSet(m.name(isQ30),bDes(isQ30));
bDesNew(isTrim)=bDes(isTrim);

% Display results.
if opts.display
    [z,id]=sort(m.z);
    disp([m.name(id) num2cell([(m.eAct(id)-m.eDes(id))*1e3 bDesOld(id) bDesNew(id)])]);
end

% Update magnet structure.
m.bDes=bDes;
m.eDes=m.eAct;

% Update klys structure.
if ~isempty(klys), k.fudgeDes=k.fudgeAct;end

if isfield(magnet,'magnet'), m=struct('magnet',m,'klys',k);end
