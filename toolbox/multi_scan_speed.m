%multi_scan_speed

function out = multi_scan_speed(in)

persistent initial_vals

% in.knob is the number entered into the knob

out.pvs{1,1} = 'WIRE:IN20:561:SCANPULSES';
steps_per_second = in.knob;
step_size = 5;
beam_rate= 30;
range = 3000;
velocity = steps_per_second * step_size;
scan_pulses = range * beam_rate / velocity;
out.val(1,1) = round(scan_pulses);
out.num_pvs = 1;
out.egu = 'Hz';


if in.initialize % First cycle
    initial_vals = lcaGet(out.pvs); %read initial pvs values directly
end

