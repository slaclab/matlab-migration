function [k1, bAct, lEff, energy] = model_k1Get(name, lEff, energy)
%MODEL_K1GET
% [K1, BACT, LEFF] = MODEL_K1GET(NAME, [LEFF, ENERGY]) returns focusing
% strength for magnet(s) NAME. It uses BACT unless the global variable
% modeUseBDES is set to 1, then BDES is used. If effective length LEFF and
% energy ENERGY are not provided, they are obtained from model_rMatGet.
% BACT and LEFF are also returned.

% Features:

% Input arguments:
%    NAME:   Char or cellstr (array) of device names in MAD, EPICS, or SLC
%            If name in numeric it is used for BACT, and LEFF & ENERGY must
%            be given
%    LEFF:   List of effective lengths of magnets (optional)
%    ENERGY: List of magnet energies (optional)

% Output arguments:
%    K1:   List of K1 values for magnets in NAME
%    BACT: List of BACT (or BDES) of magnets
%    LEFF: Effective length of element(s) in NAME
%    ENERGY: List of magnet energies in NAME

% Compatibility: Version 7 and higher
% Called functions: model_init, control_magnetGet, model_rMatGet

% Author: Henrik Loos, SLAC
% History:
%   06-Jun-2019, M. Woodley
%    * handle K1L multipoles (LEFF=0)

% --------------------------------------------------------------------
[d,d,d,modelUseBDES]=model_init;

if isnumeric(name)
    [bAct,bDes]=deal(name);
else
    [bAct,bDes]=control_magnetGet(name); % kG
end
%disp('name(isnan(bAct))) in model_k1Get.m')
%name(isnan(bAct))
if modelUseBDES, bAct=bDes;end
if nargin < 2
    [lEff,energy]=model_rMatGet(name,[],[],{'LEFF' 'EN'});
end
bp=energy/299.792458*1e4; % kG m, bp = E/ec
bAct = bAct(:)';lEff = lEff(:)';bp=bp(:)'; % force dimensionality
k1=bAct./lEff./bp; % 1/m^2

idM=find(lEff==0);
if ~isempty(idM)
    k1(idM)=bAct(idM)./bp(idM); % k1L (1/m)
end
