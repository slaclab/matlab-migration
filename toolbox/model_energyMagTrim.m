function iok = model_energyMagTrim(magnet, klys, varargin)
%MODEL_ENERGYMAGTRIM
% IOK = MODEL_ENERGYMAGTRIM(MAGNET, KLYS, OPTS) Trims magnets to BDES in
% structure MAGNET.

% Features:

% Input arguments:
%    MAGNET: Structure as returned from MODEL_ENERGYMAGPROFILE
%    KLYS:   Optional, default []. Then MAGNET & KLYS are the sub-structures
%    OPTS:   Options
%            ACTION: 'TRIM' (default) or 'PERTURB'

% Output arguments:
%    IOK: Always 1

% Compatibility: Version 7 and higher
% Called functions: util_parseOptions, control_magnetGet,
%                   control_energyNames, lcaPutSmart

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'action','TRIM', ...
    'display',1 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);
iok=1;
if nargin < 2, klys=[];end

if isfield(magnet,'magnet'), [magnet,klys]=deal(magnet.magnet,magnet.klys);end

% Abort if any magnet BDES NaN.
isBad=isnan(magnet.bDes);
if any(isBad), iok=0;disp(char([{'Invalid BDES found for:'};magnet.name(isBad)]));return, end

% Trim magnets.
control_magnetSet(magnet.name,magnet.bDes,'action',opts.action);

% Set EDES.
name=control_energyNames(magnet.name);
lcaPutSmart(strcat(name,':EDES'),magnet.eDes);

% Update fugde PVs.
if isempty(klys), return, end
fudgePV=strcat('ACCL:',{'IN20:350' 'LI21:1' 'LI22:1' 'LI25:1'}',':FUDGELAST');
%fudgePV=strcat('SIOC:SYS0:ML00:AO40',{'1' '2' '3' '4'}');
lcaPutSmart(fudgePV,klys.fudgeDes);
