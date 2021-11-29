% Data version history
%
% 0.1:
% initial version - might come without version flag
%
% 0.2:
% + gui.path variable - initial location of the main file
% + gui.colormap - colormap to be used for cam images     
function ini = back_version(ini, path)
    if ~isfield(ini, 'version')
        ini.version = 0.1;
    end

    if ini.version < 0.2
        ini.gui.path = path;
        data = load('colormap');
        ini.gui.colormap = data.colormap;
    end
end