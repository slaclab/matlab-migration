function isGeV = model_magnetIsGeV(name)
%MODEL_MAGNETISGEV
% ISGEV = MODEL_MAGNETISGEV(NAME) returns a flag indicating if the bend
% magnet's field units are in GeV/c (typical for non-chicane bend magnets)
% as supposed to kG-m.  The flag is set depending on device name area and
% unit which are hardcoded for the relevant SCP and LCLS magnets.

% Modified:
% 05-Feb-2020, M. Woodley
%   Update for LCLS2.

% Features:

% Input arguments:
%    NAME: List of bend magnet names, MAD, EPICS or SCP

% Output arguments:
%    ISGEV: Logical array with 1 if in GeV/c units or 0 otherwise

% Compatibility: Version 7 and higher
% Called functions: model_nameConvert, model_nameSplit

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

%isGeV=false(size(name));

% hardwire list of LCLS2 bends having energy polynomials
isGeV=( ...
  strcmp('BXG',name)| ...       % CU_GSPEC beampath
  strcmp('BXS',name)| ...       % CU_SPEC beampath
  strcmp('BX01',name)| ...      % CU_* beampaths (not CU_GSPEC or CU_SPEC)
  strcmp('BX02',name)| ...      % "
  strcmp('BY1',name)| ...       % *_HXR beampaths
  strcmp('BY2',name)| ...       % "
  strcmp('BX31',name)| ...      % "
  strcmp('BX32',name)| ...      % "
  strcmp('BYKIK1',name)| ...    % "
  strcmp('BYKIK2',name)| ...    % "
  strcmp('BX35',name)| ...      % "
  strcmp('BX36',name)| ...      % "
  strcmp('BYDSH',name)| ...     % "
  strcmp('BYD1',name)| ...      % "
  strcmp('BYD2',name)| ...      % "
  strcmp('BYD3',name)| ...      % "
  strcmp('BRCUSDC1',name)| ...  % CU_SXR beampath
  strcmp('BKRCUS',name)| ...    % "
  strcmp('BRCUSDC2',name)| ...  % "
  strcmp('BLRCUS',name)| ...    % "
  strcmp('BYCUS1',name)| ...    % "
  strcmp('BYCUS2',name)| ...    % "
  strcmp('BRCUS1',name)| ...    % "
  strcmp('BX31B',name)| ...     % *_SXR beampaths
  strcmp('BYKIK1S',name)| ...   % "
  strcmp('BYKIK2S',name)| ...   % "
  strcmp('BX32B',name)| ...     % "
  strcmp('BY1B',name)| ...      % "
  strcmp('BY2B',name)| ...      % "
  strcmp('BYDSS',name)| ...     % "
  strcmp('BYD1B',name)| ...     % "
  strcmp('BYD2B',name)| ...     % "
  strcmp('BYD3B',name)| ...     % "
  strcmp('BRB1',name)| ...      % SC_* beampaths (not SC_DIAG0)
  strcmp('BRB2',name)| ...      % "
  strcmp('BKYSP0H',name)| ...   % SC_HXR beampath
  strcmp('BKYSP1H',name)| ...   % "
  strcmp('BKYSP2H',name)| ...   % "
  strcmp('BKYSP3H',name)| ...   % "
  strcmp('BKYSP4H',name)| ...   % "
  strcmp('BKYSP5H',name)| ...   % "
  strcmp('BLXSPH',name)| ...    % "
  strcmp('BYSP1H',name)| ...    % "
  strcmp('BYSP2H',name)| ...    % "
  strcmp('BRSP1H',name)| ...    % "
  strcmp('BRSP2H',name)| ...    % "
  strcmp('BXSP1H',name)| ...    % "
  strcmp('BKYSP0S',name)| ...   % SC_SXR beampath
  strcmp('BKYSP1S',name)| ...   % "
  strcmp('BKYSP2S',name)| ...   % "
  strcmp('BKYSP3S',name)| ...   % "
  strcmp('BKYSP4S',name)| ...   % "
  strcmp('BKYSP5S',name)| ...   % "
  strcmp('BLXSPS',name)| ...    % "
  strcmp('BYSP1S',name)| ...    % "
  strcmp('BYSP2S',name)| ...    % "
  strcmp('BXSP1S',name)| ...    % "
  strcmp('BXSP2S',name)| ...    % "
  strcmp('BXSP3S',name)| ...    % "
  strcmp('BYSP1D',name)| ...    % SC_BSYD beampath
  strcmp('BYSP2D',name)| ...    % "
  strcmp('BKRDG0',name)| ...    % SC_DIAG0
  strcmp('BLRDG0',name)| ...    % "
  strcmp('BXDG0',name)| ...     % "
  strcmp('BYDG0',name)| ...     % "
  strcmp('BX10661' ,name)| ... %  FACET II
  strcmp('BX10661' ,name)| ... % "
  strcmp('BX10751' ,name)| ... % "
  strcmp('BX10751' ,name)| ... % "
  strcmp('BCX11314',name)| ... % "
  strcmp('BCX11314',name)| ... % "
  strcmp('BCX11331',name)| ... % "
  strcmp('BCX11331',name)| ... % "
  strcmp('BCX11338',name)| ... % "
  strcmp('BCX11338',name)| ... % "
  strcmp('BCX11355',name)| ... % "
  strcmp('BCX11355',name)| ... % "
  strcmp('BCX14720',name)| ... % "
  strcmp('BCX14720',name)| ... % "
  strcmp('BCX14796',name)| ... % "
  strcmp('BCX14796',name)| ... % "
  strcmp('BCX14808',name)| ... % "
  strcmp('BCX14808',name)| ... % "
  strcmp('BCX14883',name)| ... % "
  strcmp('BCX14883',name)); ... % "

% obsolete

%{
% Get micro and unit number.
[name,d,isSLC]=model_nameConvert(reshape(cellstr(name),[],1));
[prim,micro,unit]=model_nameSplit(name);
micro(isSLC)=prim(isSLC);
good=~strcmp(unit,'') & cellfun('isempty',regexp(unit,'\D','once'));
unitN(~good,1)=0;unitN(good,1)=str2num(char(unit(good)));

isGeV=false(size(name));
isGeV(ismember(micro,{'LTU0' 'DMP1'}))=true; % VB & DMP
isGeV(ismember(micro,{'LTU1'}) & ~strncmp(unit,'3',1))=true; % LTU ~BYKIK
isGeV(ismember(micro,{'IN20'}) & ~strncmp(unit,'4',1))=true; % Inj ~BXH
isGeV(ismember(micro,{'AB01'}) & unitN < 1000)=true; % A-line B1/2
isGeV(ismember(micro,{'DR13'}) & unitN > 80)=true; % NRTL ~sept
isGeV(ismember(micro,{'LI20'}) & ~strncmp(unit,'24',2))=true; % LI20 ~wiggler
isGeV(ismember(micro,{'DR13'}) & unitN <= 80)=true; % Also include NRTL sept as fixed angle bend
isGeV(ismember(micro,{'LI01'}))=true; % PBR
%}
