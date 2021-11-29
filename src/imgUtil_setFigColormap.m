function imgUtil_setFigColormap(fig, ipParam)
try
    cm = feval(ipParam.colormapFcn, ipParam.nrColors.val);
    set(fig, 'colormap', cm);
catch
    %do nothing
end