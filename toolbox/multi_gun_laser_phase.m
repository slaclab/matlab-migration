%multi_L0_phase.m

function out = multi_gun_laser_phase(in)
persistent initial_vals

% in.knob is the number entered into the knob


% enter names of the pvs that will be controlled.
out.pvs{1,1} = 'GUN:IN20:1:GN1_PDES';
out.pvs{2,1} = 'LASR:IN20:1:LSR_PDES2856';

out.num_pvs = 2; % number of pvs used
out.egu = 'degS';


if in.initialize % First cycle
    initial_vals = lcaGet(out.pvs); %read initial pvs values directly
end


knob = in.knob; % the control knob

% the calculated outputs
for j = 1:out.num_pvs
    out.val(j,1) =  initial_vals(j,1) + in.knob; % the calculation
end