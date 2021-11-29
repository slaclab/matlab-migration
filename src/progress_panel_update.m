function progData = progress_panel_update(progHandles, progData, property)

if nargin < 1
    return;
end
if nargin < 2 || isempty(progData)
    progData = construct_progress();
end
if nargin < 3
    property = [];
end
if isempty(progHandles)
    return;
end

if strcmpi(property, 'cancel')
    progress_cancel(progHandles, 1);
    progData = construct_progress();
end
if strcmpi(property, 'start')
    progData.startTime = now();
    progress_cancel(progHandles, 0);
end
if strcmpi(property, 'stop')
    progData = construct_progress();
end
set(progHandles.progressMessageText, 'string', progData.message);
imgUtil_log(progData.message);
if progData.value > 0 && progData.value <= 1  
    %progress bar
    valInPercent = round(progData.value *100);
    if valInPercent > 100
        valInPercent = 100;
    end
    if valInPercent < 0
        valInPercent = 0;
    end 
    
    %rgb
    parentFig = imgUtil_getParentFig(progHandles.progressImage);
    bgColor = get(parentFig, 'color');
    z = zeros(1, valInPercent);
    o = ones(1, 100 - valInPercent);
    cdata = zeros(1, 100, 3);
    for index=1:3
        cdata(:, :, index) = [z o*bgColor(index)];%black, then bg color
    end
    set(progHandles.progressImage, 'cdata', cdata);
   
    if progData.startTime > 0
        dTime = now - progData.startTime;
        timeTillTaskFinished = dTime / progData.value;
        timeLeftInDays = timeTillTaskFinished - dTime;
        timeLeftInSecs = ceil(timeLeftInDays * 24 * 60 * 60);
        timeString = sprintf('(est. time left: %d s)', timeLeftInSecs);
        set(progHandles.estTimeLeftText, 'string', timeString);
    end
else
    set(progHandles.progressImage, 'cdata', []);
    set(progHandles.estTimeLeftText, 'string', '');
end
drawnow();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function progress = construct_progress()
%progress
progress.message = '';
progress.startTime = -1;
progress.value = -1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function progress_cancel(progHandles, flag)
setappdata(progHandles.progressAxes, 'cancelFlag', flag);

