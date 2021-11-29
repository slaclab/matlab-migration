function beamOffState = segmentMoveInOut(nUnd, val, noWait)
%SEGMENTMOVEINOUT
%  BEAMOFFSTATE = SEGMENTMOVEINOUT(NUND, VAL) inserts or retracts multiple undulator segments.

% Input arguments:
%    NUND:   vector of segment numbers
%    VAL:    scalar or vector of desired segment status (0: OUT, 1: IN)
%    NOWAIT: Optional, if 1 function returns w/o waiting for motion completion

% Output arguments:

% Compatibility: Version 2007b, 2012a
% Called functions: model_nameConvert, lcaGet, lcaPut, lcaPutNoWait,
%                   epicsSimul_status, segmentMoveWait

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

beamOffState=0;
if isempty(nUnd), return, end

nUnd=nUnd(:);val=val(:);
val(end+1:length(nUnd),1)=val(end);
val=logical(val);
undPV=model_nameConvert(cellstr(num2str(nUnd,'US%02d')));

% Determine undulator action.
action(val,1)={'TRIM'};
action(~val,1)={'EXTRACT'};

% Insert TDUND.
%beamOffPV='DUMP:LTU1:970:TDUND_PNEU';
beamOffPV='IOC:BSY0:MP01:BYKIKCTL';
beamOffState=lcaGet(beamOffPV,0,'double');
lcaPut(beamOffPV,0);pause(1.);

% Move undulator segments.
lcaPutNoWait(strcat(undPV,':',action,'.PROC'),1);pause(1.);

% Do simulation
if epicsSimul_status
    str={'AT-XOUT';'ACTIVE-RANGE'};
    lcaPut(strcat(undPV,':LOCATIONSTAT'),str(val+1));
    lcaPut(strcat(undPV,':TMXPOSC'),80*(1-val));
    lcaPut(strcat(undPV,':TM1MOTOR.RBV'),80*(1-val));
end

if nargin == 3 && noWait, return, end

segmentMoveWait(nUnd,beamOffState);

%{
% Wait until all completed.
while any(strcmp(lcaGet(strcat(undPV,':LOCATIONSTAT')),'MOVING')), pause(1.);end

% Apply BPM offset correction and corrector magnet change.
%segmentInOutOffsetApply(nUnd); % Done by EPICS now

% Put TDUND to previous state.
lcaPut(beamOffPV,beamOffState);pause(1.);
%}
