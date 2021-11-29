%longitudinal_feedback.m

load sys_longitudinal.mat

sections.longitudinal = 1;
sections.injector_orbit = 0;
sections.sec21_orbit = 0;

input_struct = generate_input_pvs(sections);
output_struct = generate_output_pvs(sections);

mat = generate_matrix(sys)

fbcontrol_struct.averages = 10;
fbcontrol_struct.timeout = 5;
fbcontrol_struct.gain = 0.1 * ones(length(output_struct.pvs),1);
fbcontrol_struct.cycles = 1e9;
fbcontrol_struct.delay = .1;
fbcontrol_struct.check_pv = 'BPMS:LI21:301:TMIT';
fbcontrol_struct.check_high = 1.6e9;
fbcontrol_struct.check_low = 0.8e9;

fbout = do_feedback(input_struct, output_struct, fbcontrol_struct, mat.x, 1);
