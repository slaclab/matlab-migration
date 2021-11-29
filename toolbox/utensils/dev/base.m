classdef base < base0
    % This is the common base class. Since status, creator and
    % logger inheritent from base0 I had to do this
    % abstraction.
    %
    % By marcg@slac.stanford.edu
    
    properties (Constant)
        log = logger
        global_status = status
        create = creator
        tic = tick
    end
end