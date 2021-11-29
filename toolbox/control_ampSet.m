function [aAct, iok] = control_ampSet(name, aDes)
%AMPSET
%  [AACT, IOK] = AMPSET(NAME, ADES) sets the amplitude of rf devices in
%  string or cellarray NAME to ADES.

% Input arguments:
%    NAME: Name of klystron (MAD, Epics, or SLC), string or cell string
%          array
%    ADES: Desired amplitude

% Output arguments:
%    AACT: Actual amplitude after setting
%    IOK : Flag for success, =0 if aida failed

% Compatibility: Version 2007b, 2012a
% Called functions: control_phaseNames, control_phaseGet,
%                   epicsSimul_status, lcaPut

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Check input arguments

% Get EPICS name.
[name,is,namePACT,namePDES,nameGOLD,nameKPHR,nameAACT,nameADES] = control_phaseNames(name);
aDes=aDes(:);aAct=zeros(size(name));
iok=1;
if isempty(name), return, end
aDes(end+1:numel(name),1)=aDes(end);
aDes0=control_phaseGet(name,'ADES');

% Do simulation case.
if epicsSimul_status
    str={'DOWN' 'UP'};
    disp(char(strcat({'Scaling '},name,{' RF voltage '},str(1+(aDes > aDes0))',{' to '},num2str(aDes),{' MV'})));
%    disp(char(strcat({'Set '},name,{' amp to '},num2str(aDes))));
    lcaPut(nameADES,aDes);
    lcaPut(nameAACT,aDes);
    aAct=aDes;
    return
end

% Return if all SLC.
if all(is.SLC), return, end

% Set amplitude of FB devices and L2/3.
isASET=~is.SLC & ~is.PAC & ~is.KLY;
str={'DOWN' 'UP'};
if any(isASET)
    disp(char(strcat({'Scaling '},name(isASET),{' RF voltage '},str(1+(aDes(isASET) > aDes0(isASET)))',{' to '},num2str(aDes(isASET)),{' MV'})));
    %disp(char(strcat({'Set '},name(isASET),{' amp to '},cellstr(num2str(aDes(isASET))))));
    lcaPut(nameADES(isASET),aDes(isASET));
end
aAct=control_phaseGet(name,'AACT');
