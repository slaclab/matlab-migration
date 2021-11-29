function [] = Emergencygunrftuningrecovery(llrffeedbackflag)
% Set the gun in safe mode when the RF lock is lost and enters a perpetual loop 
% (Safe mode: pulse mode with 98% dutycycle if the llrffeedbackflag =0; activates the frequency feedback if otherwise) 
% tuning the cavity frequency using the decay mode.
% Sintax: EmergencyGunRFtuningRecovery(llrffeedbackflag)
%llrffeedbackflag must be set to 0 when the MatLab gun RF amplitude feedback is used and to 1 if the llrf amplitude/phase feedback is used.

RepPeriod=1.e-3;%repetition period in s
PulseLength=.98e-3;% pulse length in s

TimeScaleCalFactor=1.0177;% Time calibration after LLRF upgrade on April 2014.

%Set tuner in idle mode.
%setpvonline('CavityTuner:ModeReq',1,'float',1);% idle mode

setpvonline('llrf1:freq_loop_close',1,'float',1)  % turn on llrf phase feedback

if llrffeedbackflag==0
    setpvonline('llrf1:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor,'float',1); %set repetition period
    setpvonline('llrf1:pulse_length_ao', PulseLength*1e8*TimeScaleCalFactor,'float',1); % set pulse lenght.
    for nn=1:3
        setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
        pause(.25)
        setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
        pause(.25)
    end
end

['WARNING: SAFETY RECOVERY MODE. Ctrl+c to exit']

pause(1)

gunatnominalfrequency

  
end

