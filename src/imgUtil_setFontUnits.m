function imgUtil_setFontUnits(h)
try
    set(h, 'fontUnits', 'pixels', 'fontSize', 11.1);
catch
    %if I can't set, I don't care
end