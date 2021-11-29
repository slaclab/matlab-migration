function [] = setgunllrfamppahseloopparameters()
% Sets gun llrf phase/amp loop parameters
%   Sintax: setgunllrfamppahseloopparameters()

% April 9, 2015 values
gain_iloop_amp=2301
gain_iloop_ph=29625
gain_iloop_ph=gain_iloop_ph/65535*2*pi;
gainp_amp=10324
gainp_ph=0
gainp_ph=gainp_ph/32767*pi;

% Feb 1, 2016 values
%gain_iloop_amp=898
%gain_iloop_ph=26034
%gain_iloop_ph=gain_iloop_ph/65535*2*pi;
%gainp_amp=28278
%gainp_ph=0
%gainp_ph=gainp_ph/32767*pi;

% April 9, 2015 values
gain_iloop_amp=2301
gain_iloop_ph=29625
gain_iloop_ph=gain_iloop_ph/65535*2*pi;%
gainp_amp=10324
gainp_ph=0
gainp_ph=gainp_ph/32767*pi;

% November 17 2016, Retuning of the feedback after swapping cable probes at the LLRF chassis input.
gain_iloop_amp=5041
gain_iloop_ph=0
gain_iloop_ph=gain_iloop_ph/65535*2*pi;%
gainp_amp=21994
gainp_ph=0
gainp_ph=gainp_ph/32767*pi;

setpv('llrf1:gain_iloop_amp_ao',gain_iloop_amp);
setpv('llrf1:gain_iloop_ph_ao',gain_iloop_ph);
setpv('llrf1:gainp_amp_ao',gainp_amp);
setpv('llrf1:gainp_ph_ao',gainp_ph);

end

