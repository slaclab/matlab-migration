classdef phase < base
    properties
        current
        n_phase
        PV
        ind
    end
    
    methods
        function o = phase(ini, n_phase)
            % In case of scalar value of opt.n_phase.val we make an equal
            % spacing between 0 and 90 deg. In case of a vector we take the
            % selected values
            if ~nargin, return, end
            
            if length(n_phase.val) == 1
                o.ind = round(linspace(1, n_phase.max, n_phase.val));
                o.n_phase = n_phase.val;
            else
                o.ind = n_phase.val;
                o.n_phase = length(n_phase.val);
            end
            
             % I assume the energy along the SEC28 quads stay the same
             % during the entire correction.
             B = ini.B_div_E_all(:, o.ind);
             o.current = B .* repmat(model_rMatGet(ini.PV, [], [], 'EN'), o.n_phase, 1)';
             
             o.PV = ini.PV;
        end
        
        function set_phase_advance(o, index)
            % This is the moment when we would actuallly touch the machine and
            % therefore we check the status. In case its not set on running we
            % abort the operation.
        
            while o.global_status.code == o.global_status.PAUSE
                pause(1)
            end

            if o.global_status.code == o.global_status.RUNNING
                control_magnetSet(o.PV, o.current(:, index));
            else
                error('STOP')
            end
            
            control_magnetSet(o.PV, o.current(:, index));
        end
    end
    
    methods (Static)
        function o = str2obj(ini)
            o = phase;
            o.current = ini.current;
            o.n_phase = ini.n_phase;
            o.PV = ini.PV;
            o.ind = ini.ind;
        end
    end
end
        
        
       