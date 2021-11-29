classdef dechirper_prediction < base
    properties (Transient)
        ax
        ori
        calc
        curr
        hist_ori
        hist_calc
    end
    
    properties
        path
        add_wake
        add_dechirper
        history_pv
    end
    
    % gap_PV ueber dechirper
    
    methods
        function o = dechirper_prediction(pan, dx, ini)
            pos = get(pan, 'Position');
            pos = (pos(3) - 1) / 2;
            
            o.ax = o.create.axes('', [dx+8 5 pos-9 20], pan, '','');
            o.add_wake = o.create.checkbox(' Remove Wake', [dx+3 30 pos-4 2],...
                                           pan, ini.add_wake);
            o.add_dechirper = o.create.checkbox(' Predict Dechirper', [dx+3 33 pos-3 2],...
                                           pan, ini.add_dechirper);
            o.create.button('Predict', [dx+3 27 pos-3 2], pan, @o.predict, o.COLOR(o.DEF), 'on');
            
            o.path = medit(dx+3, 36, pan, ini.path);
            o.path.width = pos-3;
            o.path.add_caption('Path of TREX file', 'north', 2);
            
            o.create.button('Load', [dx+3 38.5 (pos-3)/2 2], pan, @o.load_gui, ...
                            o.COLOR(o.DEF), 'on');
            o.create.button('Last', [dx+3 + (pos-3)/2 38.5 (pos-3)/2 2], pan,...
                            @o.load_last, o.COLOR(o.DEF), 'on');
            
            o.add_listener(o.path, 'change', @(~, ~) o.load(o.path.val));
        end
        
        function load_last(o, ~, ~)
            o.log.error('Muessi no mache')
        end
         
         function load_gui(o, ~, ~)
             dataRoot=fullfile(getenv('MATLABDATAFILES'),'data');   
             [FileName, PathName] = uigetfile('TREX-Sample-*.mat', 'Load old settings', dataRoot);
             
             if isnumeric(FileName), return, end
             
             path = [PathName FileName];
             o.path.set_val(path)
             o.load(path)
         end
         
         function load(o, path)
             try
                data = load(path);
             catch e
                 o.log.warn(e.message)
                 return
             end
             
             o.ori = flipud(data.data.img);
             o.hist_ori = sum(o.ori, 2);
             o.hist_ori = o.hist_ori /max(o.hist_ori);
             
             o.curr = data.data.curr;
             o.predict
         end
        
         function predict(o, ~, ~)
             if isempty(o.path.val)
                 o.log.warn('Specify file first')
                 return
             end
             
             o.hist_calc = o.hist_ori;
             o.calc = o.ori;
             o.draw
         end
         
         function draw(o, ~, ~)
             GAIN = 2;
             
            delete(get(o.ax,'children'))
            xlim = [0 2];
            ylim = [0 2*max(o.curr)];
             
             img = ones([size(o.ori) 3]);
             ori = o.ori/max(max(o.ori)) * GAIN;
             calc = o.calc/max(max(o.calc) * GAIN);
             
             img(:,:,2) = img(:,:,2) - ori - calc;
             img(:,:,1) = img(:,:,1) - ori;
             img(:,:,3) = img(:,:,3) - calc;
             img(img < 0) = 0;
             dy = linspace(0, ylim(2), length(o.hist_ori));
             
             imagesc(xlim, ylim, img, 'parent', o.ax)
             new_area(o.ax, o.curr, linspace(0, xlim(2), length(o.curr)), 'k')
             new_area(o.ax, dy, o.hist_ori, 'r')
             new_area(o.ax, dy, o.hist_calc, 'b')
             set(o.ax, 'xlim', xlim, 'ylim', ylim)
         end
    end
end

function new_area(ax, y, x, col)
    h = area(ax, x, y, 'FaceColor', col, 'EdgeColor', col);
    set(get(h, 'Children'),'FaceAlpha', .5)
end

function val = history_wrapper(pv, ts)
%     history - check syntax when ready
    val = 0;
end