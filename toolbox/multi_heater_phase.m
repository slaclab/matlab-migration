%multi_heater_phase.m

function out = multi_heater_phase(in)
persistent initial_vals

% in.knob is the number entered into the knob


% enter names of the pvs that will be controlled.
out.pvs{1,1} = 'GUN:IN20:1:GN1_PDES';
out.pvs{2,1} = 'ACCL:IN20:300:L0A_PDES';
out.pvs{3,1} = 'ACCL:IN20:400:L0B_PDES';
out.pvs{4,1} = 'LASR:IN20:1:LSR_PDES2856';


out.num_pvs = 4; % number of pvs used
out.egu = 'degS';


if in.initialize % First cycle
    initial_vals = lcaGet(out.pvs); %read initial pvs values directly
end


knob = in.knob; % the control knob

% the calculated outputs
for j = 1:out.num_pvs
    out.val(j,1) =  initial_vals(j,1) + in.knob; % the calculation
end