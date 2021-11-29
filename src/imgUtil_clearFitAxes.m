function imgUtil_clearFitAxes(fitAxes)
cla(fitAxes);

%axes scales
set(fitAxes, 'xLim', [0 1]);
set(fitAxes, 'yLim', [0 1]);

%axes labels
h = get(fitAxes, 'xlabel');
set(h, 'string', '');
h = get(fitAxes, 'ylabel');
set(h, 'string', '');