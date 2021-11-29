function [energy, region, fudge] = model_energySetPoints(val, id, modelBeamPath)
%MODEL_ENERGYSETPOINTS
% [ENERGY, REGION, FUDGE] = MODEL_ENERGYSETPOINTS(VAL, ID) returns list of
% energy set points ENERGY in GeV at the GUN, DL1, BC1, BC2, and DL2 used
% for LEM. If MODEL_SIMUL is on, setpoints from the model simulation PVs
% are used instead.  If list VAL is provided, non-zero, non-NaN entries
% will be used to update the respective set points.
% If ID is also given, VAL is used to update set points ID, e.g.
% model_energySetPoints([0 NaN 0 4.3 13.64]) updates BC2 and DL2 set
% points, model_energySetPoints([0.25 13.64],[3 5]) updates BC1 and DL2.
% The accelerator regions related to the energy differences are returned in
% REGION.  The fudge factors corresponding to REGION are returned in FUDGE.

% Features: Localized for LCLS/FACET/NLCTA/XTA/ASTA

% Input arguments:
%    VAL: List of new energy set points (optional)
%    ID : Index list of set points to update

% Output arguments:
%    ENERGY: List of energy set points
%    REGION: List of accelerator areas corresponding to the energy
%            differences, e.g. L0, L1, etc. Empty entries for disjoint
%            parts
%    FUDGE:  Fudge factors at last magnet scaling corresponding to REGION

% Compatibility: Version 7 and higher
% Called functions: model_init, getSystem, control_deviceGet, lcaPutSmart,
%                   lcaGet

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Get model simulation status.
[d,d,modelSimul,b, modelBeamPathInit ]=model_init;

%Try to get modelBeamPath from model_init if not provided via function call
if ~exist('modelBeamPath', 'var'), modelBeamPath=modelBeamPathInit; end
[sys, accelerator] = getSystem;

% NLCTA case.
if strcmp(accelerator, 'NLCTA')
    energy=[0.06;0.12];
    region={'NLCTA'};
    fudge=1;
    return
end

% FACET case.
if strcmp(accelerator, 'FACET') || isempty(accelerator)
    switch modelBeamPath
        case {'F2_ELEC', 'F2_ELECI'}
            %Note enPV last region repeated to conform with LCLS BSY +
            %DMP(s) feature of different L3 energy in dual energy mode.
            enPV = {'SIOC:SYS1:ML00:AO896'; 'SIOC:SYS1:ML00:AO892'; 'SIOC:SYS1:ML00:AO893'; ...
                'SIOC:SYS1:ML00:AO894'; 'SIOC:SYS1:ML00:AO895' };
            energy = lcaGetSmart(enPV);
            %energy = [ 0.0060    0.1251    0.2957    4.5000    9.300];
            fudge = [ 1 1 1 1 1 ]; %TODO get these from control system
            region = {'L0F'; 'L1F'; 'L2F'; 'L3F'; 'FACET2_LI20'};
        otherwise %legacy 2018 code
            energy=[zeros(5,1);lcaGetSmart('VX00:LEMG:4:EINI');lcaGetSmart('VX00:LEMG:4:EEND',1)];
            region=[repmat({''},5,1);{'FACET'}];
            fudge=[zeros(5,1);lcaGetSmart('VX00:LEMG:4:FUDG',1)];
    end
    return
end

% Define desired energy set point source.
if modelSimul
    enPV=strcat('SIOC:SYS0:ML00:AO87',{'1' '2' '3' '4' '5'}');
    fudgePV=strcat('SIOC:SYS0:ML00:AO87',{'6' '7' '8' '9'}');
    switch modelBeamPath, case 'CU_SXR',dmpRegion = {'CLTS_DMPS'}; case 'CU_HXR', dmpRegion = {'CLTH_DMPH'}; end
else
    switch modelBeamPath
        case 'CU_SXR', L3_PV = 'LI30:901'; DMP_PV = 'DMPS:400'; dmpRegion = {'CLTS_DMPS'};
        case 'CU_HXR', L3_PV = 'LI30:901'; DMP_PV = 'DMPH:400'; dmpRegion = {'CLTH_DMPH'};
        otherwise,  L3_PV = 'LI30:901'; DMP_PV = 'DMPH:400'; dmpRegion = {'CLTH_DMPH'};
    end
    %%%enPV=strcat('REFS:',{'IN20:231' 'IN20:751' 'LI21:231' 'LI24:790' 'LI30:900' DMP_PV}',':EDES');
    %enPV=strcat('REFS:',{'IN20:231' 'IN20:751' 'LI21:231' 'LI24:790'  DMP_PV}',':EDES');
    enPV=strcat('REFS:',{'IN20:231' 'IN20:751' 'LI21:231' 'LI24:790' L3_PV DMP_PV}',':EDES');
    fudgePV=strcat('ACCL:',{'IN20:350' 'LI21:1' 'LI22:1' 'LI25:1' L3_PV DMP_PV}',':FUDGELAST');
end
region(1:4,1)={'L0' 'L1' 'L2' 'L3'};
region(5,1) = dmpRegion;

% LCLS2 (EIC only so far) case.
if any(strcmp(accelerator, 'LCLS2'))
    enPV=strcat('SIOC:SYS0:ML05:AO00',{'1'}');
    fudgePV={};
    region={'GUNB'};
end

% XTA case.
if any(strcmp(accelerator, 'XTA'))
    enPV=strcat('SIOC:SYS6:ML00:AO00',{'1' '2'}');
    fudgePV=strcat('SIOC:SYS6:ML00:AO00',{'3'}');
    region={'XTA'};
end

% ASTA case.
if any(strcmp(accelerator, 'ASTA'))
    enPV=strcat('SIOC:SYS7:ML00:AO00',{'1'}');
    fudgePV={};
    region={};
end

% Set set points if VAL provided.
if nargin > 0 && ~isempty(val)
    if nargin < 2, id=val > 0;end
    lcaPutSmart(enPV(id),reshape(val(val > 0),[],1));
end

% Get desired energy set points.
energy(1:numel(enPV),1)=lcaGet(enPV); % in GeV
fudge(1:numel(fudgePV),1)=lcaGetSmart(fudgePV);
