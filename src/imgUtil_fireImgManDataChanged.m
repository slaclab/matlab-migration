function imgUtil_fireImgManDataChanged()
figs = allchild(0);
for i=1:size(figs,1)
    try
        fHandle = getappdata(figs(i), 'notifyImgManDataChangedFcn');
        if ~isempty(fHandle)
            fHandle();
        end
    catch
    end
end