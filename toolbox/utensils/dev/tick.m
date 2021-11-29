classdef tick < base0
    % This is global time giver, using only one clock makes it easier since
    % timers are a pain in matlab...
    %
    % by marcg@slac.stanford.edu
    
    properties (Transient)
        timer
    end
    
    properties (Constant)
        PERIOD = 1
    end
    
    events
        tic
    end
    
    methods
        function o = tick
            o.timer = timer('ExecutionMode', 'FixedRate','TimerFcn',...
                            @o.timer_fun, 'Period', o.PERIOD,...
                            'StopFcn', @stop , 'StartFcn', @start);
        end
        
        function timer_fun(o, ~, ~)
            % The main reason for this is to have a debug possibility
            
            notify(o, 'tic')
        end
        
        function delete(o, ~, ~)
            stop(o.timer)
            delete(o.timer)
        end
    end
end

% Necessary since this ancient version of matlab doesn't like anonymious
% functions (too many output arguments) for Start/Stop fcn - TimerFcn is
% fine though.

function stop(~, ~)
    base.log.warn('Stop global timer')
end

function start(~, ~)
     base.log.info('Start global timer')
end