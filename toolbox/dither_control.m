%dither_control.m


function dither_control()
peak_current_pv = 'BLEN:LI24:886:BL21A_S_SUM';
peak_current_pv = 'BLEN:LI24:886:BL21B_S_SUM';
%bc2_energy = 'BPMS:LI24:801:XBR'
chirp_pv = 'SIOC:SYS0:ML00:AO267';
delay = 1;
dither = 10; % was 10
chirpmax = -2500;
chirpmin = -3800;
gain = .0003;
%gain = 0;
chirp= lcaGet(chirp_pv);
while 1
  
  chirp_lo = chirp - dither;
  lcaPut(chirp_pv, chirp_lo); % set new chirp
  pause(delay);
  ipk_lo = lcaGet(peak_current_pv);
  chirp_hi = chirp + dither;
  lcaPut(chirp_pv, chirp_hi);
  pause(delay)
  ipk_hi = lcaGet(peak_current_pv);
  ipk_dif = (ipk_hi - ipk_lo)/dither;
  chirp = chirp + ipk_dif * gain;
  chirp = max(chirpmin, min(chirpmax, chirp));
  disp(['dif = ', num2str(ipk_dif), '  chirpnew = ', num2str(chirp)]);
end


end
