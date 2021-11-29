classdef dechirper_gui < base
    % The main gui object for the dechirper tool
    %
    % By marcg@slac.stanford.edu
    
    events
        Align
        Match
        Emittance
        bpm
        Move_in
        Move_out
        Move10
        Log
        Reset
        redraw
        setOffset
        Quit
    end
    
    properties (Transient)
        pan
        ctrl
        align
        fig
        title
        alignment
        right_tap
        matchbuttons
        load
    end
    
    properties
        motor_control
        meta
        mode
        numStep
        numPerPoint
        emitPV
        fitname
        fitpar
        beamstopper
    end
    
    methods
        function o = dechirper_gui(ini, parent)
            % This only initializes the gui. Note that all Callbacks to go
            % events with the same name than the buttons.
            o.str2obj(ini)
            o.load = @parent.load;
            
            [o.fig, o.title] = o.create.fig('Dechirper', [1 1 195 69],...
                                          'marcg - x3177 /  jzemella - x8567', parent, 34);
            set(o.fig, 'CloseRequestFcn', @(~,~) notify(o, 'Quit'))

            %% Pannels
            o.pan = struct(...
                'ctrl', o.create.pan('Control', [1 .5 92 23], o.fig),...
                'setup', o.create.pan('Setup', [1 24 40 12], o.fig),...
                'bpm', o.create.pan('BPM', [1 36.5 92 30], o.fig),...
                'align', o.create.pan('Align', [94, .5, 100, 60.5], o.fig));
                 
            %% ctrl
            o.ctrl.in = o.create.button('Move',[1 18 18 3], o.pan.ctrl, ...
                                        @(~,~) o.move('Move_in'), 'g', 'off');
            o.ctrl.out = o.create.button('Extract',[20 18 18 3], o.pan.ctrl,...
                                         @(~,~) o.move('Move_out'), 'g', 'off');
            o.ctrl.m10 = o.create.button('Move to 10 mm',[39 18 18 3], o.pan.ctrl,...
                                         @(~,~) o.move('Move10'), 'g', 'off');
            set(o.ctrl.m10, 'FontSize', 10)
            o.create.button('Reset',[58 18 18 3], o.pan.ctrl, ...
                            @o.reset_callback, 'r', 'on');
            o.create.button('Motor...',[77 18 18 3], o.pan.ctrl, ...
                            @o.open_motor, 'c', 'on');
            
            %% setup
            o.matchbuttons = [...
                o.create.button('Match...', [20 7 18 3], o.pan.setup, ...
                                @(~,~) notify(o, 'Match'), 'c', 'on') ...
                o.create.button('Emittance...', [1 7 18 3], o.pan.setup, ...
                                @(~,~) notify(o, 'Emittance'), 'c', 'on')];
            o.create.button('Pauls BPM...', [1 3.5 18 3], o.pan.setup, ...
                            @(~,~) notify(o, 'bpm'), 'c', 'on');
            o.create.button('Set Offset', [1 0 18 3], o.pan.setup, ...
                            @(~,~) notify(o, 'setOffset'), 'g', 'on');

            %% Alignment
%             o.right_tap.group = tabgroup([94 .5 100 60.5], o.fig);
%             o.right_tap.alignemnt = o.right_tap.group.add_tab('Alignment');
%             o.right_tap.prediction = o.right_tap.group.add_tab('Prediction');
            o.alignment = tabgroup([0 0 99 51], o.pan.align);
            
            o.align = struct(...
                'align', o.create.button('Align', [1 54.5 20 3], o.pan.align,...
                                         @o.align_callback, 'r', 'off'),...
                'load',  o.create.button('Load', [94 62.5 49 3], o.fig,...
                                         @o.load_gui, 'c', 'off'),...
                'log',   o.create.button('Save / Log', [145 62.5 49 3], o.fig,...
                                         @(~,~) notify(o, 'Log'), 'c', 'off'));
             o.numStep = medit(44, 55, o.pan.align, ini.numStep);
             o.numPerPoint = medit(82, 55, o.pan.align, ini.numPerPoint);
            
             tooltip = ['<html><b>Error</b>:Ignore<br><b>Gauss</b>:Ignore<br><b>Poly</b>:Order' ...
               '<br><b>InvCubic</b>:Initial fit parameter(gap, offset_x, offset_y, scaling)'];
             ini.fitname = 1;
             o.fitname = o.create.popup({'None', 'Error', 'Gauss', 'Poly','InvCubic'}, [1 52 35 2], ...
                    o.pan.align, ini.fitname, @change_method);
             o.fitpar = medit(73, 52, o.pan.align, ini.fitpar, tooltip);
             o.fitpar.add_caption('Fitparameter', 'west', 25);
             o.fitpar.width = 25;
             o.fitpar.vector = true;
             
             o.numStep.add_caption('# Ctrl PV Vals', 'west', 22);
             o.numPerPoint.add_caption('# Samples', 'west', 20);
             
%              o.mode = o.create.popup(ini.mode, [1 1.5 18 2], o.pan.ctrl, 1, @(~,~) 0);
                                   
             o.add_listener(o.global_status, 'code', 'PostSet', @o.callback_status);
             o.add_listener(o.tic, 'tic', @o.emit_status);
             o.add_listener(o.fitpar, 'val', 'PostSet', @(~,~) notify(o, 'redraw'))
        end
        
        function move(o, event)
          lcaPutSmart(o.beamstopper{1}, 0)
          
          while ~strcmp(lcaGetSmart(o.beamstopper{2}), 'IN')
              pause(.1)
          end
          
          notify(o, event)
        end
        
        function change_method(o, ~, ~)
          
          notify(o,'redraw')
        end
        
        function open_motor(o, ~, ~)
            for s = o.motor_control
              system(s{1});
            end
        end
        
        function load_gui(o, ~, ~)
            [FileName, PathName] = uigetfile('Dechirper*.mat', 'Load old settings', last_folder);
            if isnumeric(FileName), return, end
            
            o.load([PathName '/' FileName]);
        end
        
        function align_callback(o, ~, ~)
%             o.right_tap.alignemnt.set_active()
            
            if o.global_status.code == o.global_status.RUNNING
                o.run_status.code = o.global_status.STOP;
            else
                o.global_status.code = o.global_status.RUNNING;
                notify(o, 'Align')
                o.global_status.code = o.global_status.READY;
            end
        end
        
        function reset_callback(o, ~, ~)
            o.log.warn('Reset gui')
            o.global_status.code = o.global_status.READY;
            start(o.tic.timer)
        end
        
        function emit_status(o, ~, ~)
            if sum(strcmp(lcaGetSmart(o.emitPV), 'MAJOR'))
                set(o.matchbuttons, 'BackgroundColor', 'r')
            else
                set(o.matchbuttons, 'BackgroundColor', 'g')
            end
        end
        
        function callback_status(o, ~, event)
            % Toogles the on/off buttons depending on the status value.
            % Note that this toggle only happens when value is changed.
            % e.g. the stay constant as long as the satus code stays the
            % same.
               
            code = event.AffectedObject.code;
            
            if code == o.global_status.READY || code == o.global_status.NOT_READY
                set(o.align.load, 'enable', 'on')
                set(o.align.log, 'enable', 'on')
            else
                set(o.align.load, 'enable', 'off')
                set(o.align.log, 'enable', 'off')
            end
            
            if code == o.global_status.READY
                set(o.ctrl.in, 'enable', 'on')
                set(o.ctrl.out, 'enable', 'on')
                set(o.ctrl.m10, 'enable', 'on')
            else
                set(o.ctrl.in, 'enable', 'off')
                set(o.ctrl.out, 'enable', 'off')
                set(o.ctrl.m10, 'enable', 'off')
            end
                
            switch code
                case o.global_status.READY
                    set(o.align.align, 'enable', 'on', 'backgr','g','str','Align')
                case o.global_status.RUNNING
                    set(o.align.align, 'enable', 'on', 'backgr','y','str','Stop')
                case o.global_status.NOT_READY
                    set(o.align.align, 'enable', 'off', 'backgr','g','str','Align')
                case o.global_status.STOP
                    set(o.align.align, 'enable', 'off', 'backgr','r','str','Stopping')
                case o.global_status.FREEZE
                    set(o.align.align, 'enable', 'off')
                otherwise
                    o.log.error('unknown status')
            end
        end
        
        function delete(o, ~, ~)
%             notify(o, 'ObjectBeingDestroyed')
            
            delete@base(o)
            
            if ishandle(o.fig)
                delete(o.fig)
            end
            o.global_status.close_win
        end
    end
end

function pass(~, ~), end