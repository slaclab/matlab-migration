function eDef = control_pulseSteal(val)
%CONTROL_PULSESTEAL
%  EDEF = CONTROL_PULSESTEAL(VAL) turns pulse stealing mode for TCAV3 on
%  and off.

% Input arguments:
%    VAL: Mode value

% Output arguments:
%    EDEF: event definition number

% Compatibility: Version 2007b, 2012a
% Called functions: control_tcav3eDef, lcaGet, pau_sync, lcaPut, SetBgrpVariable

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Check input arguments
if nargin < 1, val=[];end

eDef=control_tcav3eDef;
if isempty(val), return, end

tcavBit=hex2dec('40000000');
pockBit=hex2dec(   '80000');
ext1Bit=hex2dec(      '36');
ext0Bit=hex2dec('7FFFFFFF');
pauList={'PAU:IN20:RF01:0';'PAU:LI24:RF01:0'};
excl1_0=lcaGet(strcat(pauList,':EXCL1_0')); % DS0 exclude modifier 2

if val
    pau_sync(2);
    lcaPut('FBCK:FB04:LG01:MODE',0);
    lcaPut(strcat(pauList,':EXCL1_0'),bitset(excl1_0,31,1));
    lcaPut(strcat(pauList,':INCL1_2'),tcavBit);
    lcaPut(strcat(pauList,':INCL2_2'),pockBit);
    lcaPut(strcat(pauList,':EXCL1_2'),ext1Bit);
    lcaPut(strcat(pauList,':TIMESLOT_2'),4);
    lcaPut('PATT:SYS0:1:TCAV3CTRL',2);
    SetBgrpVariable('LCLS','TC3_STEAL','Y');
else
    SetBgrpVariable('LCLS','TC3_STEAL','N');
    lcaPut('PATT:SYS0:1:TCAV3CTRL',0);
    lcaPut(strcat(pauList,':EXCL1_0'),bitset(excl1_0,31,0));
    lcaPut(strcat(pauList,':INCL1_2'),0);
    lcaPut(strcat(pauList,':INCL2_2'),0);
    lcaPut(strcat(pauList,':EXCL1_2'),ext0Bit);
    lcaPut(strcat(pauList,':TIMESLOT_2'),0);
end
