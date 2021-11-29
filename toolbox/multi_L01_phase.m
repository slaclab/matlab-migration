%multi_L01_phase.m

function out = multi_L01_phase(in)
persistent initial_vals

% in.knob is the number entered into the knob


% enter names of the pvs that will be controlled.
out.pvs{1,1} = 'GUN:IN20:1:GN1_PDES';
out.pvs{2,1} = 'ACCL:IN20:300:L0A_PDES';
out.pvs{3,1} = 'ACCL:IN20:400:L0B_PDES';
out.pvs{4,1} = 'LASR:IN20:1:LSR_PDES2856';
out.pvs{5,1} = 'TCAV:IN20:490:TC0_PDES'; 
out.pvs{6,1} = 'ACCL:LI21:1:L1S_PDES';
out.pvs{7,1} = 'ACCL:LI21:180:L1X_PDES';

out.num_pvs = 7; % number of pvs used
out.egu = 'degS';


if in.initialize % First cycle
    initial_vals = lcaGet(out.pvs); %read initial pvs values directly
end


% the calculated outputs
for j = 1:6
    out.val(j,1) =  initial_vals(j,1) + in.knob; % the calculation
end
out.val(7,1) = initial_vals(7,1) + in.knob * 4; % X-band