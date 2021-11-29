%setL1S.m


function result = setL1S(new_phase, egain, zero_phase);

energy_pv = 'ACCL:LI21:1:L1S_ADES'
phase_pv = 'ACCL:LI21:1:L1S_PDES'


output_energy = egain / cos((pi/180)*new_phase);
output_phase = new_phase + zero_phase;

pv{1,1} = energy_pv;
pv{2,1} = phase_pv;
dat(1,1) = output_energy;
dat(2,1) = output_phase;


result.new_phase = new_phase;
result.egain = egain;
result.zero_phase = zero_phase;
result.dat = dat;




lcaPut(pv, dat);

