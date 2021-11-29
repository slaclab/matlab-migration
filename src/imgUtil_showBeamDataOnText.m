function imgUtil_showBeamDataOnText(camera, ipParam, ipOutput, h)

if isempty(ipOutput) || isempty(ipOutput.beamlist)
    s = '';
else
    stats = ipOutput.beamlist(ipParam.algIndex).stats;
    units = ipParam.beamSizeUnits;
    if strcmpi(units, 'um')
        stats(1) = (stats(1) - camera.img.origin.x) * camera.img.resolution;
        stats(2) = (stats(2) - camera.img.origin.y) * camera.img.resolution;
        stats(3) = stats(3) * camera.img.resolution;
        stats(4) = stats(4) * camera.img.resolution;
        stats(5) = stats(5) * camera.img.resolution * camera.img.resolution;
    end
    s = imgUtil_fitResults2String(stats,units);
end

set(h, 'string', s);