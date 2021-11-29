classdef marcg_base < marcg_base0
    % This is the common base class. Since marcg_status, marcg_creator and
    % marcg_logger inheritent from marcg_base0 I had to do this
    % abstraction.
    %
    % By marcg@slac.stanford.edu
    
    properties (Constant)
        log = marcg_logger
        global_status = marcg_status
        create = marcg_creator
        tic = marcg_tick
    end
end