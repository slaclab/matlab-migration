function kmSegmentTranslateWait(mainHandles)
%
% function kmSegmentTranslateWait(mainHandles)
%
% Continuosly update KM main plot while waiting for translation motion to
% cease. Returns when not moving anymore.
%
% handles is the handles structure from the main KM gui

    % Update plot loop
    pause(1); % let the pvs update before checking
    movingStatus = segmentTranslationStatus();
    if mainHandles.debug~=1
        while any(movingStatus)
            kmSegmentPlot(mainHandles);

            set(mainHandles.messages,'String', 'Moving segments...');
            pause(1);
            set(mainHandles.messages,'String', '......Moving segme');
            pause(1);
            set(mainHandles.messages,'String', '............Moving');
            pause(1);

            movingStatus = segmentTranslationStatus();
        end
    end
    set(mainHandles.messages,'String', 'Ready');
    kmSegmentPlot(mainHandles);