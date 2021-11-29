classdef creator < base0
    % Simple module creator used to ensure common layout of gui elements
    %
    % By marcg@slac.stanford.edu
    
    properties (Constant)
        NORMAL = 14
        SMALL = 8
        BACKGROUND = [.8 .8 .8]
        FONTNAME = 'Helvetic'
    end
    
    methods (Static)
        function out = button(name, pos, parent, callback, color, enable)
            if ~exist('enable', 'var')
                enable = 'off';
            end
            
            out = uicontrol('style','pushbutton','units','characters',...
                'FontSize',creator.NORMAL,'Parent',parent,...
                'Callback',callback,'string',name,'enable',enable,...
                'backgroundcolor',color,'position',pos);
        end
        
        function out = radio(name, pos, parent)
            out = uicontrol('style','radiobutton','string',name,'units',...
                'characters','parent',parent,'FontSize',creator.NORMAL,...
                'Position',pos,'backgroundcolor',creator.BACKGROUND);
        end
        
        function out = group(pan)
            out = uibuttongroup(pan,'bordertype','none','backgroundcolor',...
                creator.BACKGROUND);
        end
        
        function out = text(txt, pos, parent, align)
            out = uicontrol('style', 'text','units','characters',...
                'FontSize', creator.NORMAL,'position', pos,...
                'Parent', parent, 'string', txt, 'horizontalAlign',align,...
                'BackGroundColor',creator.BACKGROUND,...
                'FontName', creator.FONTNAME);
        end
        
        function out = slider(name, pos, parent, callback)
            out = uicontrol('style','slider','parent',parent,'units','characters',...
                'position', pos, 'Callback', callback);
            
            text(name, [pos(1)-length(name)-2 pos(2) length(name)+1 pos(4)]);
        end
        
        function out = checkbox(name, pos, parent, value)
            out = uicontrol('style','checkbox','string',name,...
                'fontsize',creator.NORMAL,'units','characters', ...
                'parent',parent,'BackGroundColor',creator.BACKGROUND,...
                'position',pos, 'value', value);
        end
        
        function out = pan(name, pos, parent)
            out = uipanel('Title',name,'FontSize',creator.NORMAL,...
                'Units','characters','Position',pos,'parent',parent,...
                'BackgroundColor',creator.BACKGROUND);
        end
        
        function out = popup(string, pos, parent, value, callback)
            out = uicontrol('style', 'popupmenu', 'units','characters',...
                    'position',pos,'parent',parent, 'value',value,...
                    'callback',callback, 'FontSize', creator.NORMAL,...
                    'string', string);
        end
        
        function out = axes(name, pos, parent, x_label, y_label)
            out = axes('units','characters','position',pos,'parent',parent);
            
            set(out, 'nextplot','add')
            grid on
            title(out, name, 'FontSize',creator.NORMAL)
            xlabel(out, x_label,'FontSize', creator.NORMAL)
            ylabel(out, y_label,'FontSize', creator.NORMAL)
        end
        
        function out = edit(pos, string, pan)
            out = uicontrol('style', 'edit', 'units','character','string',...
                string,'FontSize', creator.NORMAL,'position', pos, ...
                'parent', pan, 'backgroundColor', base.COLOR(base.DEF));
        end
        
        function [fig, title] = fig(name, pos, author, parent, num)
          fig = figure(num);
          set(fig, 'name',name,'units','characters','CloseRequestFcn',...
                @parent.delete,'menubar','none','toolbar','none','Position',...
                pos,'color',creator.BACKGROUND,'resize','off',...
                'visible', 'off');
            
            uicontrol('style','text','units','characters','position',...
                [0 pos(4)-2 pos(3) 2],'BackgroundColor','w','string','');
            
            title = uicontrol('style','text','string',name,'BackgroundColor','w',...
                'units','characters','position',[0 pos(4)-2 pos(3) 2],...
                'FontSize',creator.NORMAL,'FontWeight','bold');
            if ~isempty(author)
                uicontrol('style','text','string',author,'units','characters',...
                    'position',[pos(3)-length(author) .5 length(author) 1],...
                    'backgroundcolor',creator.BACKGROUND,'FontSize',...
                    creator.SMALL);
            end
        end
    end
end

