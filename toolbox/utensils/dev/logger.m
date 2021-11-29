classdef logger < base0
    % Creates a simple logger window. Not that this function also needs to
    % be initialized.
    %
    % by marcg@slac.stanford.edu
    
    properties
        msg = '<html><body>'
    end
    
    properties (Transient)
        box = pi
        handle
    end
    
    methods
        function init(o, pos, pan)
           % Code taken from:
           % http://undocumentedmatlab.com/blog/rich-matlab-editbox-contents/
           o.box = uicontrol('style','edit', 'max', 5,'units','characters',...
               'position', pos, 'parent', pan,'backgroundcolor','w');
           drawnow
           
           % This is necessary since it doesn't always find the  the jbox.
           jbox = findjobj(o.box);
           while isempty(jbox)
               pause(.1)
               fprintf('Didn''t find jbox. I''ll try again\n')
               jbox = findjobj(o.box);
           end
           
           o.handle = jbox.getViewport.getComponent(0);
           o.handle.setEditorKit(javax.swing.text.html.HTMLEditorKit);
           o.handle.setWrapping(true)
        end
        
        function info(o, msg)
            o.log('<FONT COLOR="000000">', msg)
        end
        
        function warn(o, msg)
            o.log('<FONT COLOR="FF0000">', msg)
        end
        
        function delete(o, ~, ~)
            % We just hope that it has been destroyed by the gui...
            o.handle = [];
            
            delete@base0(o)
        end
    end
    
    methods(Access=private)
        function log(o, severety, msg)
            % Prints the log message to the console, in case that the
            % logger is active it also prints it to the log screen.
            o.msg = [o.msg '<br>' time severety msg];
            
            if ishandle(o.box)
                o.handle.setText([o.msg '</body></html>'])
                o.handle.setCaretPosition(o.handle.getDocument.getLength)
            end
            
            fprintf('%s\n', msg)
            drawnow
        end
    end
end

function out = time
    c = clock;
    out = sprintf('<FONT COLOR="0000FF">%0.2i:%0.2i:%0.2i&gt;', c(4), c(5), floor(c(6)));
    
    fprintf('%0.2i:%0.2i:%0.2i>>', c(4), c(5), floor(c(6)))
end