function segmentTranslateWait(segmentList)
%
% segmentTranslateWait(segmentList)
%
% Waits until all segments in list have stopped translating
% If no arguments is given, it will wait for all segments to stop

if nargin == 0
    segmentList = 1:33;
end

pause(1); % let the pvs update before checking
movingStatus = segmentTranslationStatus(segmentList);

while any(movingStatus)
    pause(2);
    movingStatus = segmentTranslationStatus(segmentList);
end

