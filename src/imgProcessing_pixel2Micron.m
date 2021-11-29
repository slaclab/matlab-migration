function imgProcessing_pixel2Micron(ax, camera, applyOffsetToX, applyOffsetToY)
if nargin < 3
    applyOffsetToX = 1;
end
if nargin < 4
    applyOffsetToY = 1;
end

if strcmpi(get(ax, 'visible'), 'off')
    return;
end

set(ax, 'xLimMode', 'manual', 'yLimMode', 'manual');
transformRange(ax, 'xLim', 'x', applyOffsetToX);
transformRange(ax, 'yLim', 'y', applyOffsetToY);


children = get(ax, 'children');
for i=1:size(children,1)
    child =children(i);
    transformRange(child, 'xData', 'x', applyOffsetToX);
    transformRange(child, 'yData', 'y', applyOffsetToY);
end

%%%%%%%%%%%%%%
    function transformRange(h, property, field, applyOffset)
    val = [];
    try
        val = get(h, property);
    catch
        %do nothing
    end
    if isempty(val)
        return;
    end
    if applyOffset
        val = val - camera.img.origin.(field);
    end
    val = val * camera.img.resolution;
    try % Set sometimes fails
        set(h, property, val);
    catch
        %do nothing
    end
    end
%%%%%%%%%%%%%%
end

