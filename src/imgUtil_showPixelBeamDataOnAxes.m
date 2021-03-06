function imgUtil_showPixelBeamDataOnAxes(beamData, isPixelDataX, fitAxes, imgAxes)

imgAxesXLim = get(imgAxes, 'xLim');
imgAxesYLim = get(imgAxes, 'yLim');

%pixel data is plotted on one, prof/fit data on the other axes
pixelData = beamData(1, :);
profData = beamData(2, :);
fitData = beamData(3, :);
minProfFitData = min(min(profData), min(fitData));
maxProfFitData = max(max(profData), max(fitData));
if minProfFitData == maxProfFitData
    maxProfFitData = minProfFitData + 1;
end

profLine = line(...
    'parent', fitAxes,...
    'color', [0 0 1]...
    );
fitLine = line(...
    'parent', fitAxes,...
    'color', [1 0 0]...
    );
if isPixelDataX
    set(...
        profLine,...
        'XData', pixelData,...
        'YData', profData...
        );
    set(...
        fitLine,...
        'XData', pixelData,...
        'YData', fitData...
        );
    xLim = imgAxesXLim;
    yLim = [minProfFitData maxProfFitData];
    xLabelText = 'pix';
    yLabelText = '';
else
     set(...
        profLine,...
        'XData', profData,...
        'YData', pixelData...
        );
    set(...
        fitLine,...
        'XData', fitData,...
        'YData', pixelData...
        );
    xLim = [minProfFitData maxProfFitData];
    yLim = imgAxesYLim;
    xLabelText = '';
    yLabelText = 'pix';
end
%set axes coordinates
set(fitAxes,...
    'XLim', xLim,...
    'YLim', yLim...
    );
h = get(fitAxes, 'xlabel');
set(h,...
    'string', xLabelText,...
    'units', 'normalized');
set(h, 'position', [0.5 0.1 0]);

h = get(fitAxes, 'ylabel');
set(h,...
    'rotation', 270,...
    'string', yLabelText,...
    'units', 'normalized');
set(h, 'position', [0.05 0.5 0]);