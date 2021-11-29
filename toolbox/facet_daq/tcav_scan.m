%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tcav_scan : function to scan TCAV amplitude and phase
%
% amp   : amplitude in arb. I&Q units
% phase : absolute phase in deg.
%         NOTE: not phase rel. to e-beam
% flip  : adds 180 deg. to phase if set to 'flip'
%
% M.Litos - Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tcav_scan(amp, phase_low, phase_high, nstep, flip)

if nargin<5
    flip = 'no';
end

% TCAV Params
TCAV_MAX_AMP = 3000;
TCAV_Q_ADJ = 'TCAV:LI20:2400:TCA_Q_ADJUST';
TCAV_I_ADJ = 'TCAV:LI20:2400:TCA_I_ADJUST';

% check amplitude is within bounds
if (abs(amp)>TCAV_MAX_AMP)
    error('Desired value exceeds maximum allowable TCAV amplitude.');
else
    
    % convert phase to radians
    phase_low  = phase_low*pi/180.;
    phase_high = phase_high*pi/180.;

    % flip phase by 180 deg. if called for
    if amp<0 || strcmp(flip,'flip')
        phase_low  = phase_low  + pi;
        phase_high = phase_high + pi;
        amp = abs(amp);
    end
    
    fprintf('Setting TCAV amp to %d \n',amp);
    
    dphase = abs(phase_high-phase_low)/nstep;
    
    for i = 1 : nstep

        phase = phase_low + (i-1)*dphase;
        
        % set I & Q        
        i_setval = amp*sin(phase);
        q_setval = amp*cos(phase);
    
        lcaPut(TCAV_I_ADJ, i_setval);
        lcaPut(TCAV_Q_ADJ, q_setval);
    
        % print amp and phase to screen
        phase = phase*180/pi;
        fprintf('Setting TCAV phase to %d \n',phase);
        
        pause(1);
    
    end
        
end


end%function