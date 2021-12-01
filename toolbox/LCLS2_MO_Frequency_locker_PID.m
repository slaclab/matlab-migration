%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filename: LCLS2_MO_Frequency_locker_PID.m
% Author: Chengcheng Xu (charliex)
% Date: 08/22/2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This frequency locker for the LCLS II Master Osc Wenzel VCO in S0
% Takes 5 frequency reading samples from Agilent53220A with 1 second pause
% Each readback value is subtract by the setpoint and the average 
% of the 5 samples is used as the error term.  
% V tune value is written to a SIM DAC module with +/-5V range


freq_setpoint = 162500000; % Target frequency of 162.5MHz
VCO_gain      = -55.4786; % VCO frequency response 162.5MHz
DAC_range     = 10;

Freq_err_disp_PV = 'SIOC:SYS0:ML03:AO896';
Freq_setpoint_PV = 'SIOC:SYS0:ML03:AO895';
lock_disable_PV  = 'SIOC:SYS0:ML03:AO894';
% DAC_SIM_PV_W = 'SIM16:M:MFL:DAC_OUTPUT3_REMOTE:St'
DAC_SIM_PV_W = 'SIM01:M:MFL:DAC_OUTPUT3_REMOTE:St'
DAC_PV       = DAC_SIM_PV_W;
% DAC_SIM_PV_R = 'SIM16:M:MFL:DAC_OUTPUT3_REMOTE:Rd'
DAC_SIM_PV_R = 'SIM01:M:MFL:DAC_OUTPUT3_REMOTE:Rd'
DAC_PV_Rb    = DAC_SIM_PV_R;
% RF_CNT_PV    = 'FREQ:SYS2:00:FREQ_RBCK';
RF_CNT_PV    = 'FREQ:SYS0:00:FREQ_RBCK';

%% start watchdog
Watch_dog_PV = 'SIOC:SYS0:ML03:AO897'
W = watchdog(Watch_dog_PV, 5, 'LCLS2_MO_Frequency_locker_PID.m');
if get_watchdog_error(W)
    disp_log('MO frequency locker is already running - exiting!');
    return
end

lcaPut(Freq_setpoint_PV, freq_setpoint);
DAC_bits   = 18;
bits2volt  = (2^(DAC_bits))/DAC_range;
% DAC_offset = 2^(DAC_bits-1);
DAC_offset = 0;

V_min = -5;
V_max = 5;
Kp    = 0.2;
Ki    = 0.2;
Kd    = 0.1;
D_term = 0;
I_term = 0;

bit_min = -2^(DAC_bits-1);
bit_max = 2^(DAC_bits-1);

freq_err_prev = 0;
DAC_out0  = lcaGet(DAC_PV_Rb);
freq_avg_n   = 5;
freq_err_ary = zeros(freq_avg_n,1);
freq_err_avg = mean(freq_err_ary);
pause_time = 1;

i = 0;
j = 1;
k = 1;

while i < 1
    try
        % Get lock enable status
        lock_disable = lcaGet(lock_disable_PV)
    	% Get frequency error
    	for y = 1:freq_avg_n
    		freq_fb = lcaGet(RF_CNT_PV,0,'double');
    	    freq_err = freq_setpoint - freq_fb;
    		for(x=1:1:(freq_avg_n-1))
    		    	freq_err_ary(freq_avg_n-(x-1)) = freq_err_ary(freq_avg_n - x);
    		end
    		freq_err_ary(1) = freq_err;
    		pause(pause_time)
    	end
        
        freq_err_ary
    	freq_err_ary_sort = sort(freq_err_ary);
    	freq_err_ary1 = freq_err_ary_sort(2:(end-1));
    	freq_err_avg = mean(freq_err_ary);
    	% freq_err_avg_ary(k) = freq_err_avg;
    	% k = k+1;
        
        freq_err_diff = freq_err_avg - freq_err_prev;
        disp(['Freq error = ' num2str(freq_err_avg) 'Hz'])
        disp(['Freq error diff = ' num2str(freq_err_diff) 'Hz'])
        
        dt      = pause_time*freq_avg_n;
        I_term  = I_term + (freq_err_avg*dt);
        D_term  = freq_err_diff/dt;
        
        if lock_disable
            DAC_out = round((bits2volt/VCO_gain) * (freq_err_avg));
        else
            DAC_out = round((bits2volt/VCO_gain) * ((Kp*freq_err_avg) + (Ki*I_term) + (Kd*D_term)));
        end

        lcaPut(Freq_err_disp_PV, freq_err_avg);
        freq_err_prev = freq_err_avg;
 
        disp(['DAC output desired ' num2str(DAC_out)])
        if(DAC_out > bit_max+DAC_offset)
            disp('DAC out of max range')
            DAC_out = bit_max+DAC_offset;
        elseif(DAC_out < bit_min+DAC_offset)
            disp('DAC out of min range')
            DAC_out = bit_min+DAC_offset;
        end    
            
        lcaPut(DAC_PV, DAC_out);
        %% loop wait and watchdog here
        pause(pause_time)
        W = watchdog_run(W);
        if get_watchdog_error(W)
            disp_log('Some sort of watchdog error');
            i = 0;
            break;  % Exit program
        end
        DAC_out0 = lcaGet(DAC_PV_Rb);
        disp(['DAC output is ' num2str(DAC_out0)])
        disp(' ')
    catch
        disp('An error occured, restarting')
        i = 0;
    end


    % freq_err_prev = freq_err;
    % j = j+1;
    % Watch_dog_PV = Watch_dog_PV + 1;
    % pause(pause_time)
end

% save(['Frequency_locker_' datestr(now,'mm_dd_yyyy_HH:MM:SS') '.mat']); % Save the result data for later use
