classdef dechirper_align_dechirper < base
    % This object is responsible for the alignment of one dechirper
    %
    % By marcg@slac.stanford.edu
    
    properties
        cone
    end
    
    properties (Transient)
        dechirper
        pan
    end
    
    methods
        function o = dechirper_align_dechirper(ini, dechirper, pan, gui)           
            o.dechirper = dechirper;
            o.pan = pan;
            
            o.cone = struct(...
                'up', dechirper_align_cone(ini.cone.up, pan.pan, 'Upstream', dechirper, gui), ...
                'down', dechirper_align_cone(ini.cone.down, pan.pan, 'Downstream', dechirper, gui));

            o.add_listener(o.cone.up, 'status', 'PostSet', @o.setStatus)
            o.add_listener(o.cone.down, 'status', 'PostSet', @o.setStatus)
            o.add_listener(gui, 'setOffset', @o.setOffset)
        end
        
        function setOffset(o, ~, ~)
            up = o.cone.up.center.val;
            down = o.cone.down.center.val;
            
            if get(o.cone.up.check_center, 'Value')
                old = lcaGetSmart(o.dechirper.writePV.offUS);
                lcaPutSmart(o.dechirper.writePV.offUS, old + up)
            end
            
            if get(o.cone.down.check_center, 'Value')
                old = lcaGetSmart(o.dechirper.writePV.offDS);
                lcaPutSmart(o.dechirper.writePV.offDS, old + down)
            end
        end
        
        function setStatus(o, ~, ~)
            o.status = max([o.cone.up.status o.cone.down.status]);
            o.pan.status = o.status;
        end
        
        function err = align(o, opt)
            % Set's the taper and then let the cone run
            
            o.pan.set_active
            err = o.cone.up.align(opt);
            
            if isempty(err) && o.global_status.code ==o.global_status.RUNNING
                err = o.cone.down.align(opt);
            end
        end
    end
end