classdef main < base
% Model object. For hijackers:
% The easiest way to set default values is to load an old save file.
% Furthermore does the field last_save contain the last saved data.
%
% By marcg@slac.stanford.edu

% TODO: SETUP select, vieleicht in die gui rein?

properties
    % Debug flags
    DEBUG = false
    WAIT = false
    WATCH_SINGLE_IMAGE = false
end

properties
    gui
    timestamp = now
    iter_names
    knob
    phase
    meta
    penalty
    step_size
    bg_img
    pen
end

properties (Constant)
    CAM = 'OTRDMP'
    VERSION = 0.2
    DEFAULT = '~/marcg/matlab/toolbox/utensils/KillCSR/default.mat'
end

methods  
    function load(o, path)
        % The trick with loading is that we actually nearly restart the 
        % entire program with the new data set. This means even though 
        % nothing of logger is saved we still initialize (not construct) it
        % here since its handle is a child of gui.fig
        o.global_status.code = o.global_status.FREEZE;
 
        try
            ini = load(path);
        catch e
            o.log.warn(e.message)
            o.global_status.code = o.global_status.READY;
            return
        end
            
        % Since we discard the gui object prior to each load, we do not need
        % to keep track of its listeners, since their lifetime should be
        % linked to their source (o.gui)
        if ~isempty(o.gui) && ~isstruct(o.gui)
            delete(o.gui)
        end
        
        ini = back_version(ini.data, path);
        o.str2obj(ini)
        
        ini.gui.path.val = path;
        o.gui = gui(ini.gui, @o.load);
        addlistener(o.gui, 'logbook', @o.write_logbook);
        addlistener(o.gui, 'run', @o.run);
        addlistener(o.gui, 'load', @(~,~) o.load(o.gui.selected.path));
        addlistener(o.gui, 'selected', 'PostSet', @o.select);
        
        % In case this program is not virgin anymore we need to load the
        % old measurement data
        if ~isempty(ini.pen)
            o.phase = phase.str2obj(ini.phase);
            o.select
            
            o.gui.update_lines(o.pen, o.knob, o.iter_names)
        end
        
         set(o.gui.fig, 'visible', 'on')
         o.log.init([128 2 87 13.5], o.gui.fig);
        
        o.log.info(['Loaded ''' path ''''])
        o.global_status.code = o.global_status.READY;
    end
    
    function write_logbook(o, ~, ~)
        % Note that that the only way to save the data is to create a
        % logbook entry.
        o.global_status.code = o.global_status.FREEZE;
        
        % In case we don't want the raw data we can save some space
        data = o.obj2str;
        if ~get(o.gui.save_raw, 'Value')
            data.bg_img = [];
        end

        if o.DEBUG
            save('test.mat', 'data')
            o.load('test')
            return
        end
        
        [filename, pathname] = util_dataSave(data, 'KillCSR', '', now);
        path = [pathname '/' filename];
        o.log.info(['Data saved under ''.../' filename ''''])
        
        % Create Logbook entry
        txt = inputdlg('Logbook entry', 'Logbook entry',[20 50],...
            {['Data is saved under ''' path '''']});
        if isempty(txt), return, end
        
        title = get(o.gui.title, 'string');
        set(o.gui.title, 'string', [title ' - ' filename])
        util_printLog(o.gui.fig, 'title', 'KillCSR', 'text', txt{1})
        o.log.info('created logbook entry')
        set(o.gui.title, 'string', title)
        
        o.global_status.code = o.global_status.READY;
    end
    
    function select(o, ~, ~)
        % Draw both the perturbation as well as the camera image after
        % selecting a new data set. This funciton gets called if a new data
        % is selected (this includes first non-virgin load)
        
        if get(o.gui.single_run, 'Value') || ~get(o.gui.save_raw, 'Value')
            return
        end
        
        % First row and numbers and slices - since they don't change.
        if sum(strcmp(get(o.gui.file, 'String'), 'File'))
            set(o.gui.file, 'string', o.iter_names, 'Value', length(o.iter_names))
            set(o.gui.phase, 'string', range2str(length(o.pen.raw{1}(1).err)), 'Value', 1)
            set(o.gui.slice, 'string', range2str(length(o.pen.raw{1}(1).raw(1).x)), 'Value', 1)
            o.gui.select
            return
        end
        
        % Then Penalties, which might change
        sel = o.gui.selected;
        pen_str = {o.pen.raw{sel.file}.name};
        if ~isequal(get(o.gui.pen, 'string'), pen_str')
            set(o.gui.pen, 'string', pen_str, 'Value', 1)
        end
        
        o.gui.update_perturbation(o.pen.raw{sel.file}, o.phase.ind)
        o.gui.update_cam(o.pen.raw{sel.file}(sel.pen).raw(sel.phase), sel.slice)
    end
    
    %% Main correction algorithm
    function run(o,~,~)
%         try
            opt = o.prep_measurement;
            
            % Main loop
            for iter = 1:opt.n_iter.val
                % We are limited by int32 - why not uint64?
                for run = 1:2147483647
                    o.iter_names{end+1} = sprintf('R%iI%i', run, iter);
                    o.log.info(['<b>..Starting run ' o.iter_names{end} '</b>'])
                    
                    if o.correct(opt) || opt.single_run || o.knob.invalid
                        opt.step_size.val = opt.step_size.val / opt.step_reduction.val;
                        break
                    end
                end
                
                if opt.single_run, break, end
                
                if o.knob.invalid
                    o.log.warn('Run out knobs. Aborting')
                    break
                end
            end
            o.log.info('Finished optimisation')
%         catch me
%             % I use exceptions for flow control. Once I get the exception
%             % STOP the program retriews down here, STOP is either send by
%             % the user (pressing the stop button)
%             
%             if ~strcmp(me.message, 'STOP')
%                 rethrow(me)
%             else
%                 o.gui.log.warn('Emergency Stop')
%             end
%         end

        o.write_logbook
        o.select
    end
    
    function opt = prep_measurement(o)
        o.log.info('Preparing for correction')
        o.gui.clean
        o.pen = struct('tilt', [], 'err', [], 'raw', {{}});
        o.iter_names = {};
            
        opt = o.gui.obj2str;
        o.timestamp = now;
        
        o.phase = phase(o.meta.phase, opt.n_phase);
        o.knob = knob(o.meta.knob, opt.bc.value, opt.start_at_zero);
        
        % Meassure BG once
        if o.DEBUG
            fake_img.reset
            o.bg_img = fake_img.getFake(0);
        else
            o.bg_img = profmon_grabBG(o.CAM, 1);
        end
    end

    function bound = correct(o, opt)       
        % Measure without perturbation, this also corresponds to our global
        % penalty
        o.log.info('....Measure NULL')
        pen = o.scan('Null');
        o.pen.tilt(:,end+1) = pen.tilt;
        o.pen.err(:,end+1) = pen.err;
        
        M = zeros(2, o.phase.n_phase);
        o.gui.update_perturbation(pen, o.phase.ind)
        
        % Measure the penalties for both perturbations
        for i = 1:2
            
            if ~o.knob.perturb(i, opt.step_size.val)
                % We do not measure that knob anymore. Since we leave the
                % matrix element as zero we are in the clear
                continue
            end
            
            o.log.info(['....Measure ' o.knob.select(i).name])
            pen(end + 1) = o.scan(o.knob.select(i).name); %#ok, small
            o.gui.update_perturbation(pen, o.phase.ind)
            
            M(i, :) = pen(end).tilt - pen(1).tilt;
        end
        
        % Correct for it
        change = -o.inv(M)' * pen(1).tilt;
        bound = true;
        
        for i = 1:2
            if abs(change(i)) > 2
                bound = false;
                o.gui.log.warn(sprintf('Unboud in %s - wanted %f', ...
                            o.knob.select(i).name, change(i)*opt.step_size.val))
                change(i) = 2 * sign(change(i));
            end
        end
        
        % save raw data
        if opt.save_raw
            o.pen.raw{end + 1} = pen;
        end
        
        % adjust the machine
        if ~opt.single_run
            o.gui.update_lines(o.pen, o.knob, o.iter_names)
            o.knob.set_value(change * opt.step_size.val)
        end
    end
    
	function out = scan(o, name)
        % Scan a single settings along the given phase advances
        out = struct(...
            'name', name, ...
            'tilt', zeros(o.phase.n_phase, 1),...
            'err', zeros(o.phase.n_phase, 1),...
            'raw', struct('img', [], 'x_ax', [], 'y_ax', [], 'tilt', [], ...
                          'x', [], 'y', []));
        
        % Scan loop
        for i = 1:o.phase.n_phase
            fprintf('Scan %i of %i\n', i, o.phase.n_phase)
            o.phase.set_phase_advance(i)
            pause(3) % To give the feedback time...
            [out.tilt(i), out.err(i), out.raw(i)] = get_tilt(o);
        end
    end

     %% getTilt
    function [tilt, err, raw] = get_tilt(o)
        %% Prepare Fit
        if o.WAIT
            waitfor(msgbox('Ready'))
        end
        
        % Image aquestion
        if o.DEBUG
            raw.img = fake_img.getFake(o.gui.n_pic.val);
        else
            raw.img = profmon_grabSeries(o.CAM, o.gui.n_pic.val);
        end
       
       % calculate the absolute axes with units mm
       n = [o.gui.n_pic.val, raw.img(1).roiXN, raw.img(1).roiYN];
       raw.x_ax = (raw.img(1).roiX - raw.img(1).centerX + (1:n(2))) * raw.img(1).res / 1000;
       raw.y_ax = (raw.img(1).roiY - raw.img(1).centerY + (1:n(3))) * raw.img(1).res / 1000;
       
       % normalized reference system
       x = repmat(raw.x_ax',1,n(3))';
       y = repmat(raw.y_ax',n(2),1);
       x = x(:);
       
       % initialize - x/y only contains 2 points. This must be extendend
       % when we move to sextupoles. y is constant (ylim)
       raw.tilt = zeros(n(1),1);
       raw.x = cell(n(1),1);
       raw.y = [raw.y_ax(1) raw.y_ax(end)];
       
        %% Fit the images
        for i = 1:n(1)
            % Prepare Image - make it double since matlab "promotes" double
            % to uint16
            z = clean(double(raw.img(i).img - o.bg_img.img), 7, o.gui.cutoff.val, 1);
            z(z<0) = 0;            
            z = z(:);

            sz = sum(z);
        
            [xm, xoff] = rm_off(x);
            [ym, yoff] = rm_off(y);
        
            raw.tilt(i) = sum(xm .* ym .* z) / sum(ym.^2 .* z);
            raw.x{i} = (raw.y - yoff) * raw.tilt(i) + xoff;
            
            if o.WATCH_SINGLE_IMAGE
                o.gui.update_cam(raw, i)
                pause(.5)
            end
        end
        o.gui.update_cam(raw, n(1))
        
        % Prepare output - take median instead of mean. I know this means
        % the showed statistical error might be off, but a better
        % correction performance is more important in this case.
        tilt = raw.tilt(~isnan(raw.tilt));
        
        err = std(tilt);
        tilt = median(tilt);
        
        function [x, off] = rm_off(x)
            off = sum(x .* z) / sz;
            x = x - off;
        end
    end
    
    function out = inv(o,in)
        % Simple function to create the psuedo inverse. I make a cutoff in
        % eigenvalues that are smaller than 1e-3. Which might still be a bit to
        % liberal.

        % NaN problem - this should not happen anymore, but better safe
        % than sorry
        ind = isnan(in);
        if sum(sum(ind))
            o.log.warn('Found NaN - setting it to zero')
            in(isnan(in)) = 0;
        end

        [u,e,v] = svd(in);
        e = e.^-1;
        e(isinf(e))=0;
        e(abs(e)>1e3) = 0;
        out = v*e'*u';
    end
end
end

function out = range2str(max)
    out = cellstr(num2str((1:max)'));
end