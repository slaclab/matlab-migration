function [output_energy,output_phase,egain0] = set_phase(energy_pv,phase_pv,dphase,zero_phase,ud)

egain0  = lcaGet(energy_pv,0,'double');   % read present voltage [MV]

f = cos((pi/180)*dphase);
if ud=='u'
  output_energy = egain0*f;      % if moving up to crest, reduce Egain
elseif ud=='d'
  output_energy = egain0/f;
else
  output_energy = egain0;        % don't change amplitude for L0a, L1X, or TCAV
end
output_phase  = dphase + zero_phase;
pv{1,1}  = energy_pv;
pv{2,1}  = phase_pv;
dat(1,1) = output_energy;
dat(2,1) = output_phase;
disp(['Setting RF phase to ', num2str(output_phase) ' deg']);
if ud=='u'
  disp(['Scaling RF voltage DOWN to ', num2str(output_energy) ' MV']);
else
  disp(['Scaling RF voltage UP to ', num2str(output_energy) ' MV']);
end

lcaPut(pv,dat);
