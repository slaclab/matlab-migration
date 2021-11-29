classdef dechirper_dechirper < base
    % This class links both the backe and the control elements (gap/center)
    % It furthermore returns the needed values once the dechirper is
    % driven.
    
    properties (Transient)
        mode
    end
    
    properties
        gapUS
        gapDS
        centerUS
        centerDS
        chirp
        readPV
        writePV
        update_period
    end
    
    methods
        function o = dechirper_dechirper(ini, gui, plane)
            % gui representation
            if strcmp(plane, 'Vertical')
                dx = 10;
            else
                dx = 43;
            end
            o.str2obj(ini)
            o.mode = gui.mode;
            
            o.centerDS = medit(15 + dx, 4, gui.pan.ctrl, ini.centerDS);
            o.create_readback(31 + dx, 4, gui.pan.ctrl, o.readPV.centerDS);
            
            o.centerUS = medit(15 + dx, 7, gui.pan.ctrl, ini.centerUS);
            o.create_readback(31 + dx, 7, gui.pan.ctrl, o.readPV.centerUS);
            
            o.gapDS = medit(15 + dx, 10, gui.pan.ctrl, ini.gapDS);
            gap_readback = o.create_readback(31 + dx, 10, gui.pan.ctrl, o.readPV.gapDS);
            
            o.gapUS = medit(15 + dx, 13, gui.pan.ctrl, ini.gapUS);
            o.create_readback(31 + dx, 13, gui.pan.ctrl, o.readPV.gapUS);
            
%             o.chirp = medit(15 + dx, 1, gui.pan.ctrl, ini.chirp);
%             o.create_readback(31 + dx, 1, gui.pan.ctrl, 'chirp', gap_readback);
            
            % add captions
            h = o.gapUS.add_caption(plane, 'north', 0);
            set(h, 'Position', get(h, 'Position') .* [1 1 2 1])
            if strcmp(plane, 'Vertical')
                o.centerUS.add_caption('US Gap Cen', 'west', 24);
                o.centerDS.add_caption('DS Gap Cen Off', 'west', 24);
                o.gapUS.add_caption('US Gap Width', 'west', 24);
                o.gapDS.add_caption('DS Gap W Off', 'west', 24);
            end
            
            % set callback for gap - chirp
%             o.add_listener(o.gapUS, 'change', @o.gap2chirp);
%             o.add_listener(o.gapDS, 'change', @o.gap2chirp);
%             o.add_listener(o.chirp, 'change', @o.chirp2gap);
            
            o.add_listener(gui, 'Move_in', @o.move_to)
            o.add_listener(gui, 'Move_out', @o.move_out)
            o.add_listener(gui, 'Move10', @o.move10)
        end
        
        function gap2chirp(o, ~, ~)
            o.chirp.set_val(eloss2gap(o,2, o.gapUS.val))
        end
        
        function chirp2gap(o, ~, ~)
            o.gapUS.set_val(eloss2gap(o,1))
            %o.gapDS.set_val(eloss2gap(o,1))
        end
        
        function h = create_readback(o, x, y, pan, channel, readback)
            function read(~, ~)
                set(h, 'string', sprintf('%.3f', lcaGetSmart(channel)))
            end
            
            function chirp(~, ~)
%                 set(h, 'string', sprintf('%.3f', eloss2gap(o,2, str2double(get(readback, 'string')))))
            end
            
            h = o.create.edit([x y medit.WIDTH medit.HEIGTH],'0', pan);
            set(h, 'enable', 'off')
            
            if strcmp(channel, 'chirp')
                o.add_listener(o.tic, 'tic', @chirp);
            else
                o.add_listener(o.tic, 'tic', @read);
            end
        end
        
        function move_to(o, ~, ~)
            % Moves the dechirper at a specific loaction
            lcaPutSmart(o.writePV.centerUS, o.centerUS.val);
            lcaPutSmart(o.writePV.centerDS, o.centerDS.val);
            lcaPutSmart(o.writePV.gapUS, o.gapUS.val);
            lcaPutSmart(o.writePV.gapDS, o.gapDS.val);
            pause(.5)
            lcaPutSmart(o.writePV.move, 1);
        end
        
        function move_out(o, ~, ~)
            % Moves the beam outside of the beam. The out value of the gap
            % is given by a PV
            lcaPutSmart(o.writePV.out, 1);
        end
        
        function move10(o, ~, ~)
          lcaPutSmart(o.writePV.to10,1)
        end
    end
end