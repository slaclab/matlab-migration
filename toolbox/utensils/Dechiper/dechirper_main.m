classdef dechirper_main < base
    % A diagram shows the parent-child relationship's (No inheritance!),
    % gui elements like edit_pannel are not listed.
    %
    % by marcg@slac.stanford.edu
    
    properties (Constant)
        DEFAULT = 'default.mat'
        VERSION = 0.1
    end
    
    properties
        matching = pi
        emitter = pi
        bpm_gui = pi
    end
    
    properties
        gui
        dechirper
        bpm
        aligner
    end
    
    methods
        function write_logbook(o, ~, ~)
            o.global_status.code = o.global_status.FREEZE;
            
            % Save data
            data = o.obj2str;
            data.watch = o.global_status.obj2str;
            [filename, pathname] = util_dataSave(data, 'Dechirper', '', now);
            path = [pathname '/' filename];
            o.log.info(['Data saved under ''' path ''''])
            
            % Create Logbook entry
            txt = inputdlg('Logbook entry', 'Logbook entry',[20 50], ...
                           {['Data is saved under ''' path '''']});
            
            % By pressing cancel the string is removed, which should make
            % Tim happy.
            if isempty(txt), txt={''}; end
            
            title = get(o.gui.title, 'string');
            set(o.gui.title, 'string', [title ' -> ' filename])
            util_printLog(o.gui.fig, 'title', 'Dechirper', 'text', txt{1})
            o.log.info('created logbook entry')
            set(o.gui.title, 'string', title)
            
            o.global_status.code = o.global_status.NOT_READY;
        end
        
        function load(o, path)
            % The trick with loading is that we actually actually nearly
            % restart the entire program with the new data set.
            
            o.global_status.code = o.global_status.FREEZE;
            delete(o)

            ini = load(path);

            o.gui = dechirper_gui(ini.data.gui, o);
            o.add_listener(o.gui, 'Reset', @o.unblock);
            o.add_listener(o.gui, 'Align', @o.align);
            o.add_listener(o.gui, 'Log', @o.write_logbook);
            o.add_listener(o.gui, 'Match', @o.match);
            o.add_listener(o.gui, 'Emittance', @o.emit);
            o.add_listener(o.gui, 'bpm', @o.bpm_gui_fun);
            o.add_listener(o.gui, 'ObjectBeingDestroyed', @o.delete);
            o.add_listener(o.gui, 'Quit', @o.quit);
          
            o.dechirper = struct(...
                'Vertical', dechirper_dechirper(ini.data.dechirper.Vertical,...
                                                  o.gui, 'Vertical'),...
                'Horizontal', dechirper_dechirper(ini.data.dechirper.Horizontal,...
                                                  o.gui, 'Horizontal'));
            
            o.aligner = dechirper_align_group(ini.data.aligner, o.dechirper, o.gui);
                       
            o.bpm = [dechirper_bpm(ini.data.bpm(1), 1, 2, o.gui.pan.bpm),...
                     dechirper_bpm(ini.data.bpm(2), 2, 2, o.gui.pan.bpm)];
            
            % Init stuff
            set(o.gui.fig, 'visible', 'on')
            o.log.init([42 23 51 12], o.gui.fig);
            o.log.info(['Loaded ''.../' path ''''])
            o.global_status.init(ini.data.watch, o.gui.pan.setup, [20 3.5 18 3], o);
            
            start(o.tic.timer)
            o.global_status.code = o.global_status.NOT_READY;
        end
        
        function quit(o, ~, ~)
            % We close and clean up
            o.delete
            quit
        end
        
        function delete(o, ~, ~)
            % Destroy all the objects which will be newly created after the
            % load again. The global clock gets stopped
            
            if isvalid(o.tic.timer)
                stop(o.tic.timer)
            end
            
            % close remaining windows
            if ishandle(o.matching), delete(o.matching), end
            if ishandle(o.emitter), delete(o.emitter), end
            delete@base(o)
        end
        
        function match(o, ~, ~)
            function close(fig, ~)
                o.log.warn('Closing Matching gui')
                delete(fig)
            end
            
            if ~ishandle(o.matching)
                o.log.info('Opening Matching gui')
                o.matching = matching_gui;
                set(o.matching, 'CloseRequestFcn', @close)
                
                % It is necessary to shadow the gcbo builtin
                gcbo = findobj(o.matching, 'string', 'LI28');
                callback = get(gcbo, 'Callback');
                eval(callback);
            end
            
            figure(o.matching)
        end
        
        function emit(o, ~, ~)
            function close(fig, ~)
                o.log.info('Closing Emittance gui')
                delete(fig)
            end
            
            if ~ishandle(o.emitter)
                o.log.info('Opening Emittance gui')
                o.emitter = emittance_gui;
                set(o.emitter, 'CloseRequestFcn', @close)
                
                % It is necessary to shadow the gcbo builtin
                gcbo = findobj(o.emitter, 'string', 'LI28');
                callback = get(gcbo, 'Callback');
                eval(callback);
            end
            
            figure(o.emitter)
        end
        
        function bpm_gui_fun(o, ~, ~)
            function close(fig, ~)
                o.log.info('Closing bpms_vs_z gui')
                delete(fig)
            end
            
            if ~ishandle(o.bpm_gui)
                o.log.info('Opening bpms_vs_z gui')
                o.bpm_gui = bpms_vs_z_gui;
                set(o.bpm_gui, 'CloseRequestFcn', @close)
                
                set_popup(o.bpm_gui, 'REGION', 4)
                set_popup(o.bpm_gui, 'LASTBPM', 38)
                set_popup(o.bpm_gui, 'FIRSTBPM', 17)
                
                set_txt(o.bpm_gui, 'FITPOINT', 'BPMS:LTU1:550')
                
                set_check(o.bpm_gui,  'Show magnets', 0)
                set_check(o.bpm_gui,  'Fit X-position', 1)
                set_check(o.bpm_gui,  'Fit X-angle', 1)
                set_check(o.bpm_gui,  'Fit Energy', 1)
                set_check(o.bpm_gui,  'Fit X-kick', 1)
                set_check(o.bpm_gui,  'Fit Y-position', 1)
                set_check(o.bpm_gui,  'Fit Y-angle', 1)
                set_check(o.bpm_gui,  'Fit Y-kick', 1) 
                
%                 gcbo = findobj(o.bpm_gui, 'STRING', 'Show magnets');
%                 set(gcbo, 'Value', 0);
%                 callback = get(gcbo, 'Callback');
%                 callback(gcbo, gcbo);                
            end
            
            figure(o.bpm_gui)
        end
        
        function align(o, ~, ~)
            o.log.info('Start Alignment')
            err = o.aligner.align(o.gui.obj2str);
            
            if isempty(err)
                if o.global_status.code == o.global_status.RUNNING
                    o.log.info('Finished Alignment')
                else
                    o.log.warn('Emergency stop')
                end
            else
                o.log.warn(err)
            end
        end
           
        function reset_center(o)
            disp('Resetting center')
        end
    end
end

function set_check(h, txt, val)
  gcbo = findobj(h, 'string', txt);
  set(gcbo, 'Value', val);
  callback = get(gcbo, 'Callback');
  callback(gcbo, gcbo);
end

function set_popup(h, tag, val)
  gcbo = findobj(h, 'tag', tag);
  set(gcbo, 'value', val);
  callback = get(gcbo, 'Callback');
  callback(gcbo, gcbo);
end


function set_txt(h, tag, val)
  gcbo = findobj(h, 'tag', tag);
  set(gcbo, 'string', val);
  callback = get(gcbo, 'Callback');
  callback(gcbo, gcbo);
end