classdef dechirper_align_group < base
    % This is the group responsible for the alignment of both dechirper

properties
    dechirper
end

methods
    function o = dechirper_align_group(ini, dechirper, gui)
        for plane = {'Vertical' 'Horizontal'}
            o.dechirper.(plane{1}) = dechirper_align_dechirper(...
                ini.dechirper.(plane{1}), dechirper.(plane{1}),... 
                               gui.alignment.add_tab(plane{1}), gui);
            o.add_listener(o.dechirper.(plane{1}), 'status', 'PostSet', @o.setStatus)
        end
    end
    
    function setStatus(o, ~, ~)
        o.status = max([o.dechirper.Horizontal.status...
            o.dechirper.Vertical.status]);
        o.pan.status = o.status;
    end
    
    function err = align(o, opt)
        err = o.dechirper.Horizontal.align(opt);
        
        if isempty(err) && o.global_status.code == o.global_status.RUNNING
            err = o.dechirper.Vertical.align(opt);
        end
    end
end
end