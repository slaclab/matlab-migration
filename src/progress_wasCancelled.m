function flag = progress_wasCancelled(progHandles)
if isempty(progHandles)
    flag = 0;
    return;
end
flag = getappdata(progHandles.progressAxes, 'cancelFlag');