classdef base0 < handle
% This is the really basic case where everything starts. Higher levels
% should inheret from base though.
%
% By marcg@slac.stanford.edu

properties (SetObservable, AbortSet, Transient)
    status = base0.DEF
end

properties (Transient)
    listener = {}
    destruction_in_process = false
end

properties (Constant)
    DEF = 1
    OK = 2
    WARN = 3
    ERR = 4
    COLOR = 'wgyr'
end
    
methods
    function out = obj2str(o)
        % This should recursevely transform object to struct.
        %
        % Not-Saved: Transient, Depent, Constant
        out = obj2strI(o);
    end
    
    function str2obj(o, in)
        % This is the oposit of obj2str. Note that this is neither a
        % constructor nor a load function.
        
        for f = fieldnames(in)'
            if isprop(o, f{1})
                o.(f{1}) = in.(f{1});
            end
        end
    end
    
    function set_max_status(o, children)
        % This assures the worst status with respect to its children.
        % This function can be used together with a property listener
        % on the childrens status
        o.status = max(children.status);
    end
    
    function add_listener(o, varargin)
        % This assures that the property listener is destroyed at
        % object destruction to not leave any dangeling listeners
        
        o.listener{end + 1} = addlistener(varargin{:});
    end
    
    function delete(o, ~, ~)
        for ele = o(:)'
            ele.destruction_in_process = true;
            meta = metaclass(ele);
            
            cellfun(@delete, ele.listener);
        
            for m = meta.PropertyList'
                if ~(m.Transient || m.Dependent || m.Constant)
                    delete_field(ele.(m.Name));
                end
            end
        end
    end
end
end

function delete_field(o)
    if ~isscalar(o)
        arrayfun(@delete_field, o);
    elseif isa(o, 'base0') && ~o(1).destruction_in_process
    	delete(o);
    elseif isstruct(o)
        structfun(@delete_field, o);
    end
end

function out = obj2strI(o)
    out = [];

    if isa(o, 'base0')
        if isscalar(o)
            meta = metaclass(o);
            
            for m = meta.PropertyList'
                if ~(m.Transient || m.Dependent || m.Constant)
                    out.(m.Name) = obj2strI(o.(m.Name));
                end
            end
        else
            out = arrayfun(@(in) obj2strI(in), o);
        end
    elseif isscalar(o) && ishandle(o) && o
        out = handle2str(o);
    elseif isscalar(o) && isstruct(o)
        for f = fieldnames(o)'
            out.(f{1}) = obj2strI(o.(f{1}));
        end
    else
        out = o;
    end
end
    
function out = handle2str(h)
    % If we didn't find the type here we assume it was a false positive
    if strcmp(get(h, 'type'), 'uicontrol') && strcmp(get(h, 'style'), 'checkbox')
        out = logical(get(h, 'Value'));
    elseif strcmp(get(h, 'type'), 'uicontrol') && strcmp(get(h, 'style'), 'popupmenu')
        out = get(h, 'string');
    elseif strcmp(get(h, 'type'), 'uipanel')
        out = struct(...
            'field', {get(get(h, 'Children'), 'string')}, ...
            'value', get(get(h, 'SelectedObject'), 'String'));
    else
        out = h;
    end
end