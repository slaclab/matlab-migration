%jjk
%% UED PLL 119 MHz locker
%  Tested by Charlie Xu and Xiaozhe Shen on 03/20/2017
% function UED_PLL_freq_locker()
    freqSetPoint = 119e6;  % Target frequency of 119 MHz
    gainVCO = -6.8261; % -6.8261Hz / Volt for the 119MHz Wenzel voltage control oscillator (VCO)
    dacPv = 'LLRF:AS01:RH:PLL_CTRK_OUT';
    rfCountPv = 'FCNT:AS01:1:FREQ_RBCK';
    feedbackStatusPv = 'SIOC:SYS7:ML00:AO022';  % Status PV indicating whether the feedback is running or not
                                                % greater than 0 means running,
                                                % -2 means someone manually
                                                % change the PV and the
                                                % feedback terminates itself

    dacBit = 16; % 16 bit DAC
    voltMax = 5; % Maximum 5 volts output
    dacPerVolt = (2^(dacBit-1))/voltMax;  %  dac count per volt
    dacMin = -1 * (2^(dacBit-1));
    dacMax = 2^(dacBit-1);
    dacOut = 0;  % dac output 
    dacOut0 = dacOut;

    kP = 0.5; % P term in the PID loop

    fineTuneThres = 0.5; % Threshold for fine tuning
    fineTuneTick = 100; % Fine tune mode only changes 100 ticks per time
    deadband = 0.02; % Within the deadband, applying correction will make the signal jitter rapidly so that the 
                    % phase noise will be increased. The current strategy is to let the signal slowly, 
                    % freely drift within the deadband                
    loopPause = 1.5; % Apply correction every Loop_pause seconds

    feedbackStatusValue = lcaGet(feedbackStatusPv);
    feedbackStatusValue0 = feedbackStatusValue -1;
    feedbackStatusMax = 9999;

    %cleanupObj = onCleanup(@resetUedPllFeedbackStatus); % When terminated, put the status PV back to 0

    if (feedbackStatusValue > 0)
        disp('Another instance of the script is running, cannot run two copies in the same time')
        return
    else
        lcaPut(feedbackStatusPv, 1);  % Start the feedback with status 1
        feedbackStatusValue = lcaGet(feedbackStatusPv);
        feedbackStatusValue0 = feedbackStatusValue - 1;
        dacOut0 = dacOut;
        while 1
            try
                feedbackStatusValue = lcaGet(feedbackStatusPv);
                if (feedbackStatusValue ~= (feedbackStatusValue0 + 1) )
                    disp('Someone else is tampering with the watch dog counter PV, exiting')
                    lcaPut(MATLAB_WG_PV, -2);
                    return
                else
                    freqReadback = lcaGet(rfCountPv,0,'double');
                    freqError = freqSetPoint - freqReadback;
                    disp(['Frequency read back is: ' num2str(freqReadback)]);
                    if (abs(freqError) > deadband)  % 0.1 Hz can be modified if DAC is clean 
                        disp(['Freq error > ' num2str(deadband) 'Hz'])
                        if(abs(freqError) < fineTuneThres)
                            disp(['Fine mode freq error < ' num2str(fineTuneThres) ' Hz']);
                            dacOut = round(dacOut0 + dacPerVolt*((fineTuneTick*(voltMax/(2^(dacBit-1)))*(abs(freqError)/freqError))/gainVCO)); % fine tune mode will only change 100 tick at a time.
                        else
                            disp(['Coarse mode freq error > ' num2str(fineTuneThres) ' Hz']);
                            dacOut = round( dacOut0 + dacPerVolt*( kP*freqError/gainVCO ) );
                        end
                        % Prevent DAC output wrapping
                        if(dacOut > dacMax)
                            disp(['DAC out of range, output ' num2str(dacMax) ' ticks'])
                            dacOut = dacMax;
                        elseif(dacOut < dacMin)
                            disp(['DAC out of range, output ' num2str(dacMin) ' ticks'])
                            dacOut = dacMin;
                        end

                        disp(['Freq error = ' num2str(freqError) ' Hz'])
                        dacOut0 = dacOut;
                        disp(['DAC output is: ' num2str(dacOut) ' ticks']);                    
                        disp(' ')
                        lcaPut(dacPv, dacOut);
                    else
                        disp(['Freq error < ' num2str(deadband) ' Hz, holding DAC'])
                    end


                    if feedbackStatusValue >= feedbackStatusMax
                        feedbackStatusValue = 1;
                        feedbackStatusValue0 = 0;
                    else
                        feedbackStatusValue0 = feedbackStatusValue;
                        feedbackStatusValue = feedbackStatusValue + 1;
                    end

                    disp(['Feedback counter is ' num2str(feedbackStatusValue) ' out of ' num2str(feedbackStatusMax)]);
                    disp(' ')

                    lcaPut(feedbackStatusPv, feedbackStatusValue);

                    pause(loopPause);                   
                end
            catch ME
                rethrow(ME)
                disp('Encountered error, going to keep trying')
            end
        end
    end
% end
