classdef gui < base
events
    run
    logbook
    close
    reset
    load
end

properties (SetObservable, AbortSet)
    selected
end

properties (Transient)
    fig
    ax
    ctrl
    title
end

properties
    bc
    n_pic
    step_size
    step_reduction
    n_phase
    n_iter
    cutoff
    start_at_zero
    save_raw
    single_run
    file
    pen
    phase
    slice
    colormap
end

methods
    %% Constructor
    function o = gui(ini, loader)
        %% Prepare Window
        [o.fig, o.title] = o.create.fig('KillCSR', [1 1 218 58], 'marcg - x3177', o, 123);
        o.str2obj(ini)
        
        %% axes
        twi = model_rMatGet('OTRDMP', [], [], 'twiss');
        o.ax = struct(...
            'pen', o.create.axes('Penalties', [12 41 58 12], o.fig, '', 'Tilt [m/m]'),...
        	'cor', o.create.axes('Correction', [12 23 58 12], o.fig, '', 'Gradient [kG]'),...
        	'per', o.create.axes('Perturbation', [82 23 58 30], o.fig, 'Slice Index', 'Tilt [m/m]'),...
        	'cam', o.create.axes(sprintf('OTRDMP \\eta_y = %.2f m', twi(10)),...
                                [154 23 60 30], o.fig, 'x [mm]', 'y[mm]'));

        %% Ctrl
        pan = o.create.pan('Control',[103 1 24 18],o.fig);
        o.ctrl.start = o.create.button('Start', [2 13 20 2.5], pan, @o.callback_start,'r');
        o.create.button('Reset', [2 7 20 2.5], pan, @o.reset_callback,'r','on');
        o.ctrl.log = o.create.button('Log', [2 4 20 2.5], pan, @(~,~) notify(o, 'logbook'),'c');
        o.ctrl.pause = o.create.button('Pause', [2 10 20 2.5], pan, @o.callback_pause,'y');
        
        %% opt
        pan = o.create.pan('Options',[2 1 100 18],o.fig);
        o.step_size = medit(22, 10, pan, ini.step_size);
        o.step_size.add_caption('Step size', 'west', 18);
        
        o.step_reduction = medit(22, 7, pan, ini.step_reduction);
        o.step_reduction.add_caption('Step red.', 'west', 18);

        o.n_iter = medit(22, 13, pan, ini.n_iter);
        o.n_iter.add_caption('#Iterations', 'west', 18);
        
        o.n_phase = medit(59, 13, pan, ini.n_phase,['<html>'...
            '<b>Scalar: </b>Number of phase steps between 0-90° (max 19)<br>'...
            '<b>Vector: </b>Individual steps 0-180° (max 34)<br>']);
        o.n_phase.add_caption('#Phases', 'west', 18);
        o.n_phase.vector = true;
            
        o.n_pic = medit(59, 10, pan, ini.n_pic);
        o.n_pic.add_caption('#Pictures', 'west', 18);
        
        o.cutoff = medit(59, 7, pan, ini.cutoff);
        o.cutoff.add_caption('Img thresh', 'west', 18);
        
        o.create.text('Correctors',[2 4 25 2],pan,'left');
        o.bc = o.create.group(pan);
        bcX = [o.create.radio(ini.bc.field{1}, [30 4 10 2], o.bc) ...
            o.create.radio(ini.bc.field{2}, [45 4 10 2], o.bc)];
        set(o.bc, 'SelectedObject', bcX(strcmp(ini.bc.field, ini.bc.value)))
        o.start_at_zero = o.create.checkbox('  Start@0', [78 13.5 20 2],pan, ini.start_at_zero);
        o.save_raw = o.create.checkbox('  Save raw', [78 10.5 20 2],pan, ini.save_raw);
        o.single_run = o.create.checkbox('  Single run', [78 7.5 20 2],pan, ini.single_run);
        
        o.add_listener(o.global_status, 'code', 'PostSet', @o.callback_status);
        o.file = o.create.popup({'File'},   [128 9 21 10], o.fig, 1, @o.select);
        o.pen = o.create.popup({'Penalty'}, [150 9 21 10], o.fig, 1, @o.select);
        o.phase = o.create.popup({'Phase'}, [172 9 21 10], o.fig, 1, @o.select);
        o.slice = o.create.popup({'Slice'}, [194 9 21 10], o.fig, 1, @o.select);
        
        o.ctrl.load = o.create.button('Load', [2 1 20 2.5], pan, @o.loaddialog,'c');
        o.ctrl.load_field = medit(23, 1, pan, ini.path);
        o.ctrl.load_field.width = 75;
        
        % Necessary because of update_perturbation
        addlistener(o.ctrl.load_field, 'val', 'PostSet', @(~,~) loader(o.ctrl.load_field.val));
    end
    
    function load_gui(o, ~, ~)
        [FileName, PathName] = uigetfile('KillCSR--*.mat', 'Load old settings', last_folder);
             
        if isnumeric(FileName), return, end
             
        path = [PathName FileName];
        o.path.set_val(path)
        o.ctrl.load_field.set_val(path)
    end
    
    function clean(o)
        % Cleans the gui of residuals from old measurements.
        set(o.file, 'String', {'File'}, 'Value', 1)
        set(o.pen, 'String', {'Penalty'}, 'Value', 1)
        set(o.phase, 'String', {'Phase'}, 'Value', 1)
        set(o.slice, 'String', {'Slice'}, 'Value', 1)
        
        structfun(@(in) delete(get(in,'children')), o.ax)
        drawnow
    end
    
    function select(o, ~, ~)
        % Are we still virgin?
        str_phase = get(o.file, 'String');
        if length(str_phase) == 1 && strcmp(str_phase, 'File')
            return
        end
        
        o.selected = struct(...
            'file', get(o.file, 'Value'),...
            'pen', get(o.pen, 'Value'),...
            'phase', get(o.phase, 'Value'),...
            'slice', get(o.slice, 'Value'));
    end
    
    function reset_callback(o, ~, ~)
        % This function resets the gui in case it gets stuck.
        o.log.warn('Reset gui')
        o.global_status.code = o.global_status.READY;
    end
    
    function callback_pause(o, ~, ~)
        % This can be used to pause the operation. Can be usefull when the
        % scr moves out or a klystron says ciao.
        if o.run_status.code == o.run_status.PAUSE
            o.log.info('Resume operation')
            o.run_status.code = o.run_status.RUNNING;
        else
            o.log.warn('Paused operation')
            o.run_status.code = o.run_status.PAUSE;
        end
    end
        
    function callback_status(o, ~, event)
        % Toogles the on/off buttons depending on the status value.
        % Note that this toggle only happens when value is changed.
        % e.g. the stay constant as long as the satus code stays the
        % same.
        
        code = event.AffectedObject.code;
        
        % Toggle options
        if code == o.global_status.READY
            option = 'on';
        else
            option = 'off';
        end
        
        o.step_size.enable = option;
        o.step_reduction.enable = option;
        o.n_pic.enable = option;
        o.n_iter.enable = option;
        o.n_phase.enable = option;
        o.cutoff.enable = option;
        
        set(o.file, 'enable', option)
        set(o.pen, 'enable', option)
        set(o.phase, 'enable', option)
        set(o.slice, 'enable', option)
        set(o.start_at_zero, 'enable', option)
        set(o.save_raw, 'enable', option)
        set(o.single_run, 'enable', option)
        set(o.ctrl.log, 'enable',option)
        set(o.ctrl.load, 'enable',option)
        set(get(o.bc, 'children'), 'enable', option)
        
        % Pause and Start button
        if code == o.global_status.READY
            set(o.ctrl.start, 'enable', 'on', 'back','g','string','Start')
            set(o.ctrl.pause, 'enable','off','string','Pause','back','y')
        elseif code == o.global_status.RUNNING
            set(o.ctrl.start, 'enable', 'on', 'backgr','y','str','Stop')
            set(o.ctrl.pause, 'enable','on','string','Pause','back','y')
        elseif code == o.global_status.PAUSE
            set(o.ctrl.pause, 'enable','on','string','Resume','back','g')
        elseif code == o.global_status.STOP
            set(o.ctrl.pause, 'enable','off','string','Pause','back','y')
            set(o.ctrl.start, 'enable', 'off', 'backgr','r','str','Stopping')
        elseif code == o.global_status.FREEZE
            set(o.ctrl.pause, 'enable','off')
            set(o.ctrl.start, 'enable','off')
        else
            assert(false, 'Unknown Status')
        end
        
        drawnow
    end
        
    function update_cam(o, raw, ind)
        % Updates the image recorde. And draws the fit.
        delete(get(o.ax.cam, 'Children'))
        
        imagesc(raw.x_ax,raw.y_ax,raw.img(ind).img, 'Parent',o.ax.cam)
        plot(raw.x{ind}, raw.y, 'Color', 'k', 'Parent', o.ax.cam, 'linewidth', 2);
        set(o.ax.cam,'xlim', [raw.x_ax(1) raw.x_ax(end)],...
            'ylim', [raw.y_ax(1) raw.y_ax(end)], 'ydir', 'normal')
        colormap(o.colormap)
        drawnow
    end
    
    function update_lines(o, pen, knob, names)
        delete(get(o.ax.pen, 'Children'))
        errorbar(pen.tilt', pen.err','Parent', o.ax.pen);
        set(o.ax.pen, 'xtick', 1:length(names), 'xticklabel', names)

        delete(get(o.ax.cor, 'Children'))
        plot(knob.val', 'Parent', o.ax.cor);
        set(o.ax.cor, 'xtick', 1:length(names), 'xticklabel', names)
        legend(o.ax.cor, {knob.select.name})
        drawnow
    end
    
    function update_perturbation(o, pen, phase_index)
        delete(get(o.ax.per, 'Children'))
        
        errorbar(cell2mat(arrayfun(@(in) in.tilt, pen, 'uni', 0)),...
                 cell2mat(arrayfun(@(in) in.err, pen, 'uni', 0)),...
                 'parent', o.ax.per)
        
        legend(o.ax.per, {pen.name})
        set(o.ax.per, 'xtick', 1:length(pen(1).tilt), 'xticklabel',...
            arrayfun(@(in) num2str(in), phase_index, 'uni', 0))
        drawnow
    end
        
    function callback_start(o, ~, ~)
        if o.global_status.code == o.global_status.RUNNING || ...
           o.global_status.code == o.global_status.PAUSE
            % We only send a stoping signal instead of directly
            % throwing the stoping exception. This is mainly because we
            % want to stop the operation before touching the machine
            % and not lets say in the middle of saving data.
            o.log.warn('User interupt. Stopping')
            o.global_status.code = o.global_status.STOP;
        elseif o.global_status.code == o.global_status.READY
            o.global_status.code = o.global_status.RUNNING;
            notify(o, 'run')
            o.global_status.code = o.global_status.READY;
        else
            assert(false, 'Unknown global status')
        end
    end
    
    function delete(o,~,~)
        notify(o,'close')
        
        if ishandle(o.fig)
            delete(o.fig)
        end
        
        delete@base(o)
    end
end
end