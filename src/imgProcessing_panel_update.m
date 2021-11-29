% property is an optional arg, if missing => updates all views
function imgProcessing_panel_update(ipHandles, ipParam, property)
%@ipParam may contain an additional field, algNames
%first thing 
if isfield(ipParam, 'algNames')
    imgProcessing_panel_updateAlgPopupmenu(ipHandles, ipParam.algNames);
end

isArgSet = nargin > 2 && ~isempty(property);
if ~isArgSet || strcmpi(property, 'algIndex')
    set(ipHandles.algPopupmenu, 'value', ipParam.algIndex);
end
if ~isArgSet || strcmpi(property, 'centroid')
    centroid = ipParam.annotation.centroid;
    
    set(ipHandles.currentCentroidCheckbox, 'foregroundColor', centroid.current.color);
    set(ipHandles.currentCentroidCheckbox, 'value', centroid.current.flag);
end
if ~isArgSet || strcmpi(property, 'beamSizeUnits')
    str = get(ipHandles.beamSizeUnitsPopupmenu, 'string');
    for i=1:size(str,1)
        if strcmpi(str{i}, ipParam.beamSizeUnits)
            set(ipHandles.beamSizeUnitsPopupmenu, 'value', i);
            break;
        end
    end
end
if ~isArgSet || strcmpi(property, 'colormap')
    str = get(ipHandles.colormapFcnPopupmenu, 'string');
    for i=1:size(str,1)
        if strcmpi(str{i}, ipParam.colormapFcn)
            set(ipHandles.colormapFcnPopupmenu, 'value', i);
            break;
        end
    end
    minLog = log2(ipParam.nrColors.min);
    maxLog = log2(ipParam.nrColors.max);
    sliderStep = 1/(maxLog - minLog);
    bpp = round(log2(ipParam.nrColors.val));
    
    set(ipHandles.autoBppCheckbox, 'value', ipParam.nrColors.auto);
    if ipParam.nrColors.auto 
        enable = 'off';
    else
        enable = 'on';
    end
    set(ipHandles.bppSlider,...
        'enable', enable,...
        'min', minLog,...
        'max', maxLog,...
        'sliderStep', [sliderStep sliderStep],...
        'value', bpp);
    set(ipHandles.bppText,...
        'enable', enable,...
        'string', sprintf('%d bpp', bpp));
    fig = imgUtil_getParentFig(ipHandles.bppSlider); %any widget
    imgUtil_setFigColormap(fig, ipParam);    
end
if ~isArgSet || strcmpi(property, 'crop')
    set(ipHandles.autoCropCheckbox, 'value', ipParam.crop.auto);
    set(ipHandles.customCropCheckbox, 'value', ipParam.crop.custom);
end
if ~isArgSet || strcmpi(property, 'filter')
    set(ipHandles.floorFilterCheckbox, 'value', ipParam.filter.floor);
    set(ipHandles.medianFilterCheckbox, 'value', ipParam.filter.median);
end
if ~isArgSet || strcmpi(property, 'slice')
    newTotalSlices = ipParam.slice.total;
    set(ipHandles.nrSlicesEdit, 'string', newTotalSlices);
   
    indexStrings = num2str((1:newTotalSlices)');
    set(ipHandles.slicePopupmenu, 'string', indexStrings,...
        'value', ipParam.slice.index);
    
    isSlicePlaneX = strcmpi(ipParam.slice.plane, 'x');
    if isSlicePlaneX
        set(ipHandles.sliceXCheckbox, 'value', 1);
        set(ipHandles.sliceYCheckbox, 'value', 0);
    else
        set(ipHandles.sliceXCheckbox, 'value', 0);
        set(ipHandles.sliceYCheckbox, 'value', 1);
    end
end
if ~isArgSet || strcmpi(property, 'subtractBg')
    set(ipHandles.subtractAcquiredBgCheckbox, 'value', ipParam.subtractBg.acquired);
    set(ipHandles.subtractCalculatedBgCheckbox, 'value', ipParam.subtractBg.calculated);
end