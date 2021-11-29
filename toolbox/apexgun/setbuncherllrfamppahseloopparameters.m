function [] = setbuncherllrfamppahseloopparameters()
% Sets buncher llrf phase/amp loop parameters
%   Sintax: setbuncherllrfamppahseloopparameters()

% 
%gain_iloop_amp=59999
%gain_iloop_ph=-7634
%gain_iloop_ph=gain_iloop_ph/65535*2*pi;
%gainp_amp=0
%gainp_ph=0
%gainp_ph=gainp_ph/32767*pi;

% January 13, 2016 values
gain_iloop_amp=60000
gain_iloop_ph=39500
gain_iloop_ph=gain_iloop_ph/65535*2*pi
gainp_amp=0
gainp_ph=0
gainp_ph=gainp_ph/32767*pi

% February 19, 2016 values
gain_iloop_amp=60000
gain_iloop_ph=40000
gain_iloop_ph=gain_iloop_ph/65535*2*pi
gainp_amp=0
gainp_ph=0
gainp_ph=gainp_ph/32767*pi



setpv('L1llrf:gain_iloop_amp_ao',gain_iloop_amp);
setpv('L1llrf:gain_iloop_ph_ao',gain_iloop_ph);
setpv('L1llrf:gainp_amp_ao',gainp_amp);
setpv('L1llrf:gainp_ph_ao',gainp_ph);

end

