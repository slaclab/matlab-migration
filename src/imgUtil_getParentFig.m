function fig = imgUtil_getParentFig(uiObj)
% This function gets the parent figure of the specified UI object
parent = get(uiObj, 'parent');
if parent == 0
    fig = uiObj;
else
    fig = imgUtil_getParentFig(parent);
end
