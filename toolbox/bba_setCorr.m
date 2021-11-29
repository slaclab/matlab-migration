function bba_setCorr(static, quadDelta, appMode, varargin)

% Virtually move quads by QUADDELTA with change in corrector strengths.

% Integrated field strengths for undulator quads.
[d,bQuad]=control_magnetGet(static.quadList);
bQuad=[1;-1]*bQuad';
deltaCorr=bQuad.*quadDelta;
if ~any(deltaCorr(:)), deltaCorr=0;end

bba_corrSet(static,deltaCorr,appMode,varargin{:});
