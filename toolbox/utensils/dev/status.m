classdef status < base0
    % Simple class to check if the machine is ready to be operated. The
    % states are hereby denoted in a enum style naming. When constructed
    % without any input it serves as an enum with observable status code.
    %
    % Since one object of this class is a constant property of base
    % we cannot inherint from it. That's way the log messages are a bit
    % weird...
    %
    % By marcg@slac.stanford.edu
    
    properties
        checkbox
        period
        check
    end
    
    properties (Transient)
        win = pi
        button
        main
    end
    
    properties (SetObservable, AbortSet)
        code = status.FREEZE
    end
    
    properties(Constant)
        READY = 0
        RUNNING = 1
        NOT_READY = 2
        STOP = 3
        FREEZE = 4
        PAUSE = 5
        FIG = 123456
    end
    
    methods       
        function o = init(o, ini, pan, pos, main)
            % ini
            %  - Period : pause between checks
            %  - check : Array
            %    + check : function string (to make it independent of its 
            %              source file with respect to fun handle) - 0=pass
            %    + msg : Error message broadcasted
            
            o.main = main;
            o.str2obj(ini)
            o.create_fig
            o.button = creator.button('Status', pos, pan, ...
                                        @o.toggle_win_visibility, 'y', 'on');
            if ~isempty(o.listener)                        
                delete(o.listener{1})
            end
            o.add_listener(base.tic, 'tic', @o.check_fun)
        end
        
        function create_fig(o)
            if ishandle(o.win), delete(o.win), end
            
            n_check = length(o.check);
            
            o.win = creator.fig('Status Checklist', [1 1 69 n_check*3 + 7],'', o, o.FIG);
            set(o.win, 'CloseRequestFcn', @o.toggle_win_visibility)
            
            tooltip = ['<html><font size="5">'...
            '<p style="background-color:#00FF00"><b>Green: </b>Test succeed. </p>'...
            '<p style="background-color:#FFFF00"><b>Yellow: </span></b>Test failed but ignore.</p>'...
            '<p style="background-color:#FF0000"><b>Red: </span></b>Test failed. This blocks '...
            'machine interaction<br> or stops alignment at earliest convieninece.</p><br>'...
            'To ignore a test unselect it.<br>'];
            
            for i = 1:n_check
                o.check(i).handle = creator.checkbox(['  ' o.check(i).msg],...
                                                        [1 i*3 67 2], o.win, 1);
                set(o.check(i).handle, 'tooltipstring', tooltip)
            end
        end
        
        function toggle_win_visibility(o, ~, ~)
            if strcmp(get(o.win, 'visible'), 'on')
                set(o.win, 'visible', 'off')
            else
                set(o.win, 'visible', 'on')
            end
        end
        
        function check_fun(o, ~, ~)
            % This loop runs through no matter what. It then changes the
            % color of each line and the button. And ajust the code value
            % if needed
            
            ok = true;
            overrule = false;
            
            % check the 
            for chk = o.check
                if eval(chk.check)
                    if get(chk.handle, 'Value')
                        ok = false;
                        set(chk.handle, 'BackgroundColor', 'r')
                        
                        if o.code == o.RUNNING
                            base.log.warn(sprintf(...
                                'Condition ''%s'' not satisfied. Abborting', chk.msg))
                            o.code = o.STOP;
                        end
                    else
                        set(chk.handle, 'BackgroundColor', 'y')
                        overrule = true;
                    end
                else
                    set(chk.handle, 'BackgroundColor', 'g')
                end
            end
           
            if ok
                if overrule
                    set(o.button, 'Backgroundcolor', 'y')
                else
                    set(o.button, 'Backgroundcolor', 'g')
                end
                
            else
                set(o.button, 'Backgroundcolor', 'r')
            end
            
            if ~ok && o.code == o.READY
                o.code = o.NOT_READY;
            end
            
            if ok && o.code == o.NOT_READY
                o.code = o.READY;
            end
            
            drawnow
        end
        
        function close_win(o, ~, ~)
            % Only made invisible I know, but should be fine, since I kill
            % when making a new one.
            
            if ishandle(o.win)
                set(o.win, 'visible', 'off')
            end
        end
        
        function toggle_overruled(o, ~, ~)
            if get(o.checkbox, 'Value')
                base.log.warn('Overrule activated')
                set(o.checkbox, 'BackgroundColor', 'y')
            else
                base.warn('Overrule deactivated')
                set(o.checkbox, 'BackgroundColor', o.create.BACKGROUND)
            end
        end
        
        function delete(o, ~, ~)
            if ishandle(o.win)
                delete(o.win)
            end
            
            delete@base0(o)
        end
    end
end