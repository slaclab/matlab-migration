classdef dechirper_align_cone < base
    % This class is responsible for the alignment of a single cone
    % movement. This cone might either be Opening or clossing
    %
    % By marcg@slac.stanford.edu
    
    properties (Transient)
        ax
        dechirper
        fitpar
        fitname
    end
    
    properties
        names
        measure
        start
        stop
        center
        instrument
        taperMMPV
        check_edge1
        check_edge2
        check_center
        feedback
    end
    
    methods
        function o = dechirper_align_cone(ini, pan, up_down, dechirper, gui)           
            o.str2obj(ini)
            o.fitpar = gui.fitpar;
            o.fitname = gui.fitname;
            
            pos = get(pan, 'Position');
            pos = (pos(3) - 1) / 2;
            
            if strcmp(up_down, 'Upstream')
                dx = 0;
            else
                dx = pos;
            end

            o.dechirper = dechirper;
            
            o.measure = o.create.checkbox(['  ' up_down], [2+dx 45 pos-3 1.8], pan, ini.measure);
            o.ax = o.create.axes('', [dx+8 5 pos-9 18.5], pan, 'Center [mm]','');

            o.instrument = dechirper_instrument(ini.instrument, dx+2, pos-3, 42, pan);
            
            pos = pos - medit.WIDTH-1;
            o.start = medit(pos + dx, 38, pan, ini.start);
            o.stop = medit(pos + dx, 35, pan, ini.stop);
            o.center = medit(pos + dx, 32, pan, ini.center);
            
            pos = pos - 3;
            o.start.add_caption('Start [mm]', 'west', pos);
            o.stop.add_caption('Stop [mm]', 'west', pos);
            
            o.check_center = o.create.checkbox(' Center [mm]',...
                                    [dx+3 32 pos-3 2],pan,ini.check_center);
            set(o.check_center, 'ForeGroundColor', 'b')
            
            o.add_listener(o.instrument, 'change_instrument', @o.draw);
            o.add_listener(o.center, 'val', 'PostSet', @o.draw)
            o.add_listener(o.start, 'val', 'PostSet', @o.draw)
            o.add_listener(o.stop, 'val', 'PostSet', @o.draw)
            o.add_listener(o, 'status', 'PostSet', @o.setStatus)
            o.add_listener(gui, 'redraw', @o.draw)
            
            o.status = o.WARN;        
            o.draw
        end
        
        function setStatus(o, ~, ~)
            set(o.measure, 'BackGroundColor', o.COLOR(o.status))
        end
        
        function update_edge(o, ~, ~)
            data = o.instrument.data;
            
            if isempty(data.x)
                return
            end
                        
            if get(o.check_center, 'Value')
                o.center.set_val(data.center)
            end
        end
        
        function draw(o, ~, ~)
            delete(get(o.ax, 'children'))
            data = o.instrument.data;
            
            if isempty(data.x)
                return
            end
            
            fitname = get(o.fitname, 'String');
            data = calcFit(data, fitname{get(o.fitname, 'Value')}, o.fitpar.val);
            o.instrument.update(data)
            o.update_edge

            % Measurement Data
            errorbar(o.ax, data.x, data.y, data.err, '.')

            plot(o.ax, data.fit(1,:), data.fit(2,:))
            ylim = [min(data.y) max(data.y)] + [-1.05 1.05]*max(data.err) + [0 1e-15];
            
            % Set Data
            plot(o.ax, [o.center.val o.center.val], ylim, 'color', 'r')
            
            % Calc Data
            plot(o.ax, [data.center data.center], ylim, '-.','color', 'r')

            if o.start.val == o.stop.val
                xlim = [o.start.val o.start.val+.1];
            else
                xlim = sort([o.start.val o.stop.val]);
            end
           
            set(o.ax, 'ylim', enlarge(ylim), 'xlim', enlarge(xlim))
            drawnow
        end
        
        function err = align(o, opt)
            % This function sets the trim motor and then let's the magic
            % happen
            feedback = lcaGetSmart(o.feedback);
            
            if get(o.measure, 'Value')
                %try
                 % lcaPutSmart(o.feedback, 0)
                  err = alignGap(o, opt.numStep.val, opt.numPerPoint.val, 1);
                 % lcaPutSmart(o.feedback, feedback)
               % catch ex
                %  lcaPutSmart(o.feedback, feedback)
                 % rethrow(ex)
                %end
            
                if isempty(err) && o.global_status.code == o.global_status.RUNNING
                    o.status = o.OK;
                else
                    o.status = o.ERR;
                end
            
                o.draw
            else
                err = '';
            end
        end
    end
end

function in = enlarge(in)

    if in(1) > 0
        in(1) = in(1)*.9;
    else
        in(1) = in(1)*1.1;
    end
    
    if in(2) > 0
        in(2) = in(2)*1.1;
    else
        in(2) = in(2)*.9;
    end
end