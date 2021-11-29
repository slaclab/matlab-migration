function [ipParam, property] = imgProcessing_panel_defaultCallback(source, event, ipParam)
sourceTag = get(source, 'tag');
sourceVal = get(source, 'value');
property = [];
if strcmpi(sourceTag, 'algPopupmenu')
    ipParam.algIndex = sourceVal;
    property = 'algIndex';
elseif strcmpi(sourceTag, 'applyButton')
    property='applyIp';
elseif strcmpi(sourceTag, 'autoApplyCheckbox')
    if sourceVal == 1
        enableVal = 'off';
        property='applyIp';
    else
        enableVal = 'on';
    end
    handles =guihandles(imgUtil_getParentFig(source));
    set(handles.applyButton, 'enable', enableVal);        
elseif strcmpi(sourceTag, 'autoBppCheckbox')
    ipParam.nrColors.auto = sourceVal;
    property = 'colormap';
elseif strcmpi(sourceTag, 'autoCropCheckbox')
    ipParam.crop.auto = sourceVal;
    ipParam.crop.custom = 0; 
    property = 'crop';
elseif strcmpi(sourceTag, 'beamSizeUnitsPopupmenu')
    allOptions = get(source, 'string');
    ipParam.beamSizeUnits = allOptions{sourceVal};
    property = 'beamSizeUnits';
elseif strcmpi(sourceTag, 'colormapFcnPopupmenu')
    allOptions = get(source, 'string');
    ipParam.colormapFcn = allOptions{sourceVal};
    property = 'colormap';    
elseif strcmpi(sourceTag, 'currentCentroidCheckbox')
    ipParam.annotation.centroid.current.flag = sourceVal;
    property = 'centroid';
elseif strcmpi(sourceTag, 'customCropCheckbox')
    ipParam.crop.auto = 0;  
    ipParam.crop.custom = sourceVal;  
    property = 'crop';
elseif strcmpi(sourceTag, 'floorFilterCheckbox')
    %do nothing, as floor filter is always applied
elseif strcmpi(sourceTag, 'medianFilterCheckbox')
    ipParam.filter.median = sourceVal;
    property = 'filter';
elseif strcmpi(sourceTag, 'bppSlider')
    ipParam.nrColors.val = 2^round(sourceVal);
    property = 'colormap';
elseif strcmpi(sourceTag, 'nrSlicesEdit')
    try
        %string property
        ipParam.slice.total = str2double(get(source, 'string'));
        ipParam.slice.index = 1;
        property = 'slice';
    catch
        imgUtil_notifyLastError();
    end
elseif strcmpi(sourceTag, 'slicePopupmenu')
    ipParam.slice.index = sourceVal;
    property = 'slice';
elseif strcmpi(sourceTag, 'sliceXCheckbox')
    ipParam.slice.plane = 'x';
    property = 'slice';
elseif strcmpi(sourceTag, 'sliceYCheckbox')
    ipParam.slice.plane = 'y';
    property = 'slice';
elseif strcmpi(sourceTag, 'subtractAcquiredBgCheckbox')
    ipParam.subtractBg.acquired = sourceVal;
    ipParam.subtractBg.calculated = 0;
    property = 'subtractBg';
elseif strcmpi(sourceTag, 'subtractCalculatedBgCheckbox')
    ipParam.subtractBg.acquired = 0;
    ipParam.subtractBg.calculated = sourceVal;
    property = 'subtractBg';
end

