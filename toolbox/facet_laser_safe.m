function [safe, states] = facet_laser_safe(state)

% sets "laser safe" mode on or off
% no argument just returns the state (safe or not)
% laser safe mode on (state = 1) means all movable diagnostics in the laser path 
% retracted and disabled (oven controls also);
% safe mode off (state = 0) re-enables the controls but does not insert
% anything
% disable/enable is done by setting the .SPMG (stop/pause/move/go) control

if nargin < 1, state = -1; end  % no input argument just queries

roots = {...
    'OTRS:LI20:3175'; ...  % ODR/OTR
    'OTRS:LI20:3180'; ...  % IPOTR1
    'OTRS:LI20:3206'; ...  % DSOTR
    'WIRE:LI20:3179'; ...  % WSIP1
    'OVEN:LI20:3185'; ...  % OVEN
    };

motors = strcat(roots, ':MOTR');

outdir = {'H' 'H' 'H' 'H' 'L'}';  % "out" is high, except for oven
tols = 1e3 * [1 1 1 1 .001]';      % 1 mm tolerance for "out", oven ctrl is mm

limits = strcat(motors, '.', outdir, 'LM');
switches = strcat(motors, '.', outdir, 'LS');
readbacks = strcat(motors, '.RBV');
enables = strcat(motors, '.SPMG');

statepvs = {...
    'SIOC:SYS1:ML00:AO730';
    'SIOC:SYS1:ML00:AO731';
    'SIOC:SYS1:ML00:AO732';
    'SIOC:SYS1:ML00:AO733';
    'SIOC:SYS1:ML00:AO734';
    };

% get "out" limits and start positions

switch state
    case -1  % query only
        outlim = lcaGetSmart(limits);
        enable = lcaGetSmart(enables, 0, 'double');
        rbv = lcaGetSmart(readbacks);
        swv = lcaGetSmart(switches);
        close = (abs(rbv - outlim) < tols); % within tols of OUT soft limit
        out = close | swv; % OUT means either at soft limit or on HW limit switch
        safe = all(out) && all(~enable);
        states = out & ~enable;
    case 0  % re-enable motion
        enable = lcaGetSmart(enables);
        disp('Enable state was:');
        disp(enable');
        lcaPutSmart(enables, 3*ones(size(enables)), 'native'); % 3 means GO
        enable = lcaGetSmart(enables);
        disp('Enable state is now:');
        disp(enable');
        safe = 0;
        states = zeros(size(statepvs));
    case 1
        outlim = lcaGetSmart(limits);
        pos = lcaGetSmart(motors);
        for ix = 1:numel(pos)
            fprintf(1, '%s pos = %.3f \t goal = %.3f\n', motors{ix}, pos(ix), outlim(ix));
        end

        % move movers to "out"
        lcaPutSmart(motors, outlim);
        disp('Waiting up to 1 minute for motors to retract...');
        out = zeros(size(motors));
        tries = 0;
        while ~all(out) && tries <= 60
            rbv = lcaGetSmart(readbacks);
            swv = lcaGetSmart(switches);
            close = (abs(rbv - outlim) < tols); % within tols of OUT soft limit
            out = close | swv; % OUT means either at soft limit or on HW limit switch
            disp(out');
            if ~all(out), pause(1); tries = tries + 1; end
        end

        if all(out)
            disp('All movers retracted');
        else
            disp('*** WARNING *** not all movers are retracted!');
        end

        % disable the movers with the SPMG button
        disp('Disabling motion controls');
        lcaPutSmart(enables, zeros(size(enables)), 'native');

        enable = lcaGetSmart(enables, 0, 'double');
        safe = all(out) && all(~enable);
        states = out & ~enable;
        if safe
            disp('Safe mode successful');
        else
            disp('Not all movers are safe for laser operation!');
        end
        
    otherwise
        disp('Mode not known');
        safe = NaN;
end
