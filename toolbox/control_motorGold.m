function new_offsets = control_motorGold(names)

% construct PV names
motors = reshape(cellstr(model_nameConvert(names, 'EPICS')), [], 1);
pvs.motor_vals      = strcat(motors, {':MOTR.RBV'});
pvs.motor_offsets   = strcat(motors, {':MOTR.OFF'});
[prim, micr, unit]  = model_nameSplit(motors);
lvdts               = strcat({'LVDT:'}, micr, {':'}, unit);
pvs.lvdt_vals       = strcat(lvdts, {':LVPOS'});

% get starting state
lvdts = lcaGetSmart(pvs.lvdt_vals, 0, 'double');
motors = lcaGetSmart(pvs.motor_vals, 0, 'double');
offsets = lcaGetSmart(pvs.motor_offsets, 0, 'double');

% calculate new offsets
errors = lvdts - motors;
new_offsets = offsets + errors;

% write new offsets
lcaPutSmart(pvs.motor_offsets, new_offsets);

% wait a little bit for readback to update
pause(1);