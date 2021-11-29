function [stat lvdts] = control_motorTrim(names, des)

names = reshape(cellstr(model_nameConvert(names, 'MAD')), [], 1);
stat = zeros(numel(names), 1);

% constants
gain = 0.9;
tol_multiplier = 30;
max_tries = 5;
timeout = 10;

% construct motor PV names
motors = reshape(cellstr(model_nameConvert(names, 'EPICS')), [], 1);
pvs.motor_stepsize  = strcat(motors, {':MOTR.MRES'});
pvs.motor_status    = strcat(motors, {':STATUS'});
pvs.motor_setpoint  = strcat(motors, {':MOTR.VAL'});
pvs.motor_vals      = strcat(motors, {':MOTR.RBV'});
pvs.motor_offsets   = strcat(motors, {':MOTR.OFF'});
[prim, micr, unit]  = model_nameSplit(motors);

% construct LVDT PV names
lvdts               = strcat({'LVDT:'}, micr, {':'}, unit);
pvs.lvdt_vals       = strcat(lvdts, {':LVPOS'});

% use table for tolerances.  comment this out and uncomment following block
% to use dynamic tols.
tol_table = { ...
    'M1SX',         2; ...
    'M1SDX',        4; ...
    'M2SX',         2; ...
    'M2SDX',        4; ...
    'M3SX',         2; ...
    'M3SDX',        4; ...
    'M1HX',         2; ...
    'M1HDX',        4; ...
    'M2HX',         2; ...
    'M2HDX',        4; ...    
    'SLITRIGHT',    2; ...
    'SLITLEFT',     4; ...
    'SLITBOT',      2; ...
    'SLITTOP',      4; ...   
    };

tol_index = [];
for name = names'
    tol_index = [tol_index; strmatch(name, tol_table(:,1))];
end
tols = cell2mat(tol_table(tol_index, 2));

% figure out tolerances
% stepsize = lcaGetSmart(pvs.motor_stepsize, 0, 'double');
% tols = stepsize * tol_multiplier;

% use current motor values as "desired" positions if they are not passed in
if nargin < 2
    des = lcaGetSmart(pvs.motor_vals, 0, 'double');
else
    des = reshape(des, [], 1);
end

% trim loop
for ix = 1:max_tries
    % get current positions
    lvdts = lcaGetSmart(pvs.lvdt_vals, 0, 'double');
    motors = lcaGetSmart(pvs.motor_vals, 0, 'double');

    % determine which are out-of-tol
    deltas = des - lvdts;
    isOOT = abs(deltas) > tols;
    OOTs = find(isOOT);
    
    % if any are out-of-tol
    if any(isOOT)                
        % calculate new positions
        new_motors      = motors + (deltas * gain);

        % move to new positions
        lcaPutSmart(pvs.motor_setpoint(OOTs), new_motors(OOTs));
        
        % make sure all motors are stopped
        stopped = 8;
        status = lcaGetSmart(pvs.motor_status, 0, 'double');
        if ~all(status == stopped)
            disp_log('some motor is still moving');
            return
        end        
    else
        break
    end
    
    % wait for motor readback to settle
    pause(1);
end

% pause to allow LVDT to settle
pause(1);

% now green them up
control_motorGold(names);

% final check that the trim worked
lvdts = lcaGetSmart(pvs.lvdt_vals, 0, 'double');
deltas = des - lvdts;
stat = ~(abs(deltas) > tols);