function segmentMoveWait(nUnd, beamOffState)
%SEGMENTMOVEWAIT
%  SEGMENTMOVEWAIT(NUND, BEAMOFFSTATE) waits for undulator motion to
%  complete and restores BYKIK state.

% Input arguments:
%    NUND:         vector of segment numbers
%    BEAMOFFSTATE: original state of BYKIK (optional)

% Output arguments:

% Compatibility: Version 2007b, 2012a
% Called functions: model_nameConvert, lcaGet, lcaPut

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if isempty(nUnd), return, end

undPV=model_nameConvert(cellstr(num2str(nUnd(:),'US%02d')));

% Wait until all completed.
while any(strcmp(lcaGet(strcat(undPV,':LOCATIONSTAT')),'MOVING')), pause(1.);end

% Apply BPM offset correction and corrector magnet change.
%segmentInOutOffsetApply(nUnd); % Done by EPICS now

if nargin < 2, return, end

% Put TDUND to previous state.
beamOffPV='IOC:BSY0:MP01:BYKIKCTL';
lcaPut(beamOffPV,beamOffState);pause(1.);
