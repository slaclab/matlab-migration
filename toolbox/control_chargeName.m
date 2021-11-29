function [nameQACT, nameQDES, nameFB] = control_chargeName(name)
%CHARGENAME
%  [NAMEQACT, NAMEQDES, NAMEFB] = CHARGENAME(NAME) get bunch charge actual
%  and feedback set point PV names.

% Features:

% Input arguments:
%    NAME: String or cell string array for area name.

% Output arguments:
%    NAMEQACT: Actual bunch charge in nC
%    NAMEQDES: Bunch charge set point in nC
%    NAMEFB:   Bunch charge FB compute/enable PV

% Compatibility: Version 2007b, 2012a
% Called functions: lcaGet, getSystem

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Defaults
if nargin < 1 || isempty(name), [sys,name]=getSystem;end

[nameQACT,nameQDES,nameFB]=deal('');

switch name
    case {'LCLS' ''}
        fbName={'FBCK:FB02:GN01'; ...    % new charge feedback in the injector (0=OFF,1=ON)
                'FBCK:BCI0:1'}; ...     % charge feedback in the injector (0=OFF,1=ON)
        state=lcaGet(strcat(fbName,':STATE'),0,'double');
        id=[find(state);1];id=id(1); % Default to first if none active
        secn={':S1DES' ':CHRGSP'};
        nameQDES=strcat(fbName(id),secn(id));
        secn={':S1_S' ':CHRG_S'};
        nameQACT=strcat(fbName(id),secn(id));
%        nameQACT=strcat('BPMS:IN20:221:TMIT');
        nameFB=strcat(fbName,{':MODE';':ENABLE'});
    case 'LCLS2'
        nameQACT=strcat('BPMS:IN10:221:TMIT');
    case 'FACET'
        nameQACT=strcat('BPMS:LI19:901:TMIT57');
    otherwise
        return
end
