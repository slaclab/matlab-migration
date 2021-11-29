classdef util_subplot < handle
    % A helper tool that creates all the subplot axes. For convinience it
    % can be called by util_subplot.factory - if the object already exist
    % it returns another pointer to it, if not it creates a new one and
    % attaches its handle to the figure.
    %
    % marcg@slac.stanford.edu
    
    properties
        fig
        ax
        n_row
        n_col
        LEFT = 0.1
        RIGHT = 0.1
        TOP = 0.05
        BOTTOM = 0.1
        HOR_SPACING = 0.08
        VER_SPACING = 0.02
        names
        z
    end
    
    methods
        function obj = util_subplot(n_row, n_col, fig)
            obj.n_row = n_row;
            obj.n_col = n_col;
            obj.fig = fig;
            
            d_col = (1 - obj.LEFT - obj.RIGHT - (obj.HOR_SPACING * (n_col - 1))) / n_col;
            d_row = (1 - obj.TOP - obj.BOTTOM - (obj.VER_SPACING * (n_row - 1))) / n_row;
            
            for row = 1:n_row
                y = obj.BOTTOM + (row - 1) * (d_row + obj.VER_SPACING);
                for col = 1:n_col
                    x = obj.LEFT + (col - 1) * (d_col + obj.HOR_SPACING);
                    obj.ax(col, n_row - row + 1) = axes(...
                        'Units', 'normalized', 'Position', [x y d_col d_row]);
                end
            end
        end
        
        function txt = cursor(obj, ~, event)
            pos = get(event, 'Position');
            name = obj.names{pos(1) == obj.z};
            txt = sprintf('z = %f\nvalue = %f\n%s', pos(1), pos(2), name);
        end
    end
    
    methods(Static)
        function obj = factory(n_row, n_col, fig_n, pos)
            fig = figure(fig_n);
            obj = guidata(fig);
            
            if isempty(obj)
                obj = util_subplot(n_row, n_col, fig);
                guidata(fig, obj)
                set(fig, 'OuterPosition', pos);
                
                cursor = datacursormode(fig);
                set(cursor, 'UpdateFcn', @obj.cursor)
            end
        end
    end
end