%% Archiving the Phase and Amplitude into Matlab Support PV.
%  Program runs in the background.
%  Program archives two sets of data in the form of amplitude and phase
%  There are 9 signals from the feedback controlled stations whose phase
%  and amplitude program monitors.
%  Once a minute 30 data points of 9 amplitudes and 9 phases are acquired.
%  If there is no signal, nothing is acquired.
%  Mean value and the standard deviation are then calculated, (=36).
%  The total of 36 values are stored in the Matlab Support PV #201 -#236.
%  The second part of the program reads four pairs of I(.MONT) and Q(.MONT) 
%  values from MDL, Reference, Local Clock and Clock PACs. 
%  Amplitude and phase are calculated from the I and Q data and archived 
%  once a minute.
%  Operator has no control of the program.
%  Program can be stopped or restarted from the LCLS Matlab Watchers GUI,
%  alternatively by writing value "0" into the Matlab Support PV #249.
%  Written:     Vojtech Pacak       2008
%  Started:     20-May-2008
%  Updates:     27-Jun-2008, 17-Jul_2008, 18-May-2009, 20-Oct-2011,
%  10-Jan-2012, 23-Mar-2012
%  Last update:  17-Apr-2013 - changed the L1S expected ampl to 115
% 10-Apr-2014 W. Colocho: Fix jitter 

function archive_LLRF_ampl_phase

%**************************************************

%% Check if the program is not already running
disp(' ')
disp('Checking if program already running')
disp('It will take 10 seconds, please wait')
disp(' ')
try
    count_1 = 1%%%lcaGet('SIOC:SYS0:ML00:AO250');
catch
    disp('Channel Access Failed - lcaGet(Time Counter #1)')
    err = lasterror;
    fprintf('%s\n%s\n\n',datestr(now),err.message);
end

pause(10)
try
    count_2 = 1%%%lcaGet('SIOC:SYS0:ML00:AO250');
catch
    disp('Channel Access Failed - lcaGet(Time Counter #2)')
    err = lasterror;
    fprintf('%s\n%s\n\n',datestr(now),err.message);
end
if count_1 ~= count_2
    disp('***Program is already active and running***')
    return
end
disp(' ')
disp('Program started')
disp(' ')


%% Assign the program exit PV and set it to "run (=1)
run_stop = 'SIOC:SYS0:ML00:AO249';
try
    lcaPut(run_stop,1);
catch
    disp('Channel Access Failed - lcaPut(run_stop)')
    err = lasterror;
    fprintf('%s\n%s\n\n',datestr(now),err.message);
end
try
    run_flag = lcaGet(run_stop);
catch
    disp('Channel Access Failed - lcaGet(run_flag)')
    err = lasterror;
    fprintf('%s\n%s\n\n',datestr(now),err.message);
end

%% Names of the signal PVs
pvNames = {
    'LASR:IN20:1:LSR_0_AACT' % THALES LASER ampl
    'LASR:IN20:1:LSR_0_NRPA' % THALES LASER phase
    'GUN:IN20:1:GN1_AAVG'    % GUN1  ampl
    'GUN:IN20:1:GN1_PAVG'    % GUN1  phase
    'ACCL:IN20:300:L0A_AAVG' % L0A   ampl
    'ACCL:IN20:300:L0A_PAVG' % L0A   phase
    'ACCL:IN20:400:L0B_AAVG' % L0B   ampl
    'ACCL:IN20:400:L0B_PAVG' % L0B   phase
    'TCAV:IN20:490:TC0_AAVG' % TC0   ampl
    'TCAV:IN20:490:TC0_PAVG' % TC0   phase
    'ACCL:LI21:1:L1S_AAVG'   % L1S   ampl
    'ACCL:LI21:1:L1S_PAVG'   % L1s   phase
    'ACCL:LI21:180:L1X_AAVG' % L1X   ampl
    'ACCL:LI21:180:L1X_PAVG' % L1X   phase
    'TCAV:LI24:800:TC3_AAVG' % TC3   ampl
    'TCAV:LI24:800:TC3_PAVG' % TC3   phase
    'LASR:IN20:2:LSR_0_AACT' % COHERENT LASER ampl
    'LASR:IN20:2:LSR_0_NRPA' % COHERENT LASER phase
    };
pvNames_PAC = {
    'LLRF:IN20:RH:RFR_I_MONT'% REF I
    'LLRF:IN20:RH:RFR_Q_MONT'% REF Q
    'LLRF:IN20:RH:MDL_I_MONT'% MDL I
    'LLRF:IN20:RH:MDL_Q_MONT'% MDL Q
    'LLRF:IN20:RH:LCL_I_MONT'% LoCLOCK I
    'LLRF:IN20:RH:LCL_Q_MONT'% LoCLOCK Q
    'LLRF:IN20:RH:CLK_I_MONT'%   CLOCK I
    'LLRF:IN20:RH:CLK_Q_MONT'%   CLOCK Q
    };

%% Labels of Matlab Support PVs
labels = {
    'LSR-COH1 ampl-MEAN';'LSR-COH1 ampl-STDE';'LSR-COH1 phas-MEAN';'LSR-COH1 phas-STDE';...
    'GUN_1 ampl-MEAN';'GUN_1 ampl-STDE';'GUN_1 phas-MEAN';'GUN_1 phas-STDE';...
    'L0A   ampl-MEAN';'L0A   ampl-STDE';'L0A   phas-MEAN';'L0A   phas-STDE';...
    'L0B   ampl-MEAN';'L0B   ampl-STDE';'L0B   phas-MEAN';'L0B   phas-STDE';...
    'TC0   ampl-MEAN';'TC0   ampl-STDE';'TC0   phas-MEAN';'TC0   phas-STDE';...
    'L1S   ampl-MEAN';'L1S   ampl-STDE';'L1S   phas-MEAN';'L1S   phas-STDE';...
    'L1X   ampl-MEAN';'L1X   ampl-STDE';'L1X   phas-MEAN';'L1X   phas-STDE';...
    'TC3   ampl-MEAN';'TC3   ampl-STDE';'TC3   phas-MEAN';'TC3   phas-STDE';...
    'LSR-COH2 ampl-MEAN';'LSR-COH2 ampl-STDE';'LSR-COH2 phas-MEAN';'LSR-COH2 phas-STDE';...
    'PAC RFR ampl';'PAC RFR phas';'PAC MDL ampl';'PAC MDL phas';...
    'PAC LCL ampl';'PAC LCL phas';'PAC CLK ampl';'PAC CLK phas'};

%% Comment PV's
comment = cell(length(labels),1);
for n=1:length(labels)
    comment(n) = {
        ['SIOC:SYS0:ML00:SO0',num2str(200+n)]
        }'; % must be a column cell array, using the " ' "
end

%% Units of Matlab Support PVs
%     'Arb_U';'Arb_U';'Deg_S'; 'Deg_S';...  % LASER
%     'MV';   'MV';   'Deg_S'; 'Deg_S';...  % GUN_1
%     'MV';   'MV';   'Deg_S'; 'Deg_S';...  % L0A
%     'MV';   'MV';   'Deg_S'; 'Deg_S';...  % L0B
%     'MV';   'MV';   'Deg_S'; 'Deg_S';...  % TC0
%     'MV';   'MV';   'Deg_S'; 'Deg_S';...  % L1S
%     'MV';   'MV';   'Deg_X'; 'Deg_X';...  % L1X
%     'MV';   'MV';   'Deg_S'; 'Deg_S';...  % TC3

%% Matlab Support PV storage names
store_place_PV = cell(length(labels),1); % preallocate space
for n = 1 : length(labels)     % 1:36
    store_place_PV(n)={['SIOC:SYS0:ML00:AO',num2str(n+200)]};
end

%% Input Names, Units, Precision and Comment fields
for n = 1 : length(labels)     % 1:44

    % input NAMES
    lcaPut([store_place_PV{n},'.DESC'],labels(n)) % name


    % input COMMENTS
    lcaPut(['SIOC:SYS0:ML00:SO0',num2str(n+200)],'LLRF Signal Archiving');

    switch n                   % input UNITS
        case {1 2 33 34 37 39 41 43}

            lcaPut([store_place_PV{n},'.EGU'],'Arb_U')

        case {5 6 9 10 13 14 17 18 21 22 25 26 29 30}

            lcaPut([store_place_PV{n},'.EGU'],'MV')

        case {3 4 7 8 11 12 15 16 19 20 23 24 31 32 35 36 38 40 42 44}

            lcaPut([store_place_PV{n},'.EGU'],'Deg_S')

        case {27 28}

            lcaPut([store_place_PV{n},'.EGU'],'Deg_X')

    end % switch

    if n > 2*length(pvNames)
        lcaPut([store_place_PV{n},'.PREC'],1)

    elseif rem(n,2) == 0
        lcaPut([store_place_PV{n},'.PREC'],3)

    else
        lcaPut([store_place_PV{n},'.PREC'],1)

    end % if
end     % for

% Input .DESC and SOxxxx fields for Matlab Supp. PVs # 249 and 250

lcaPut({'SIOC:SYS0:ML00:AO249.DESC';'SIOC:SYS0:ML00:AO250.DESC'},...
    {'Start-Stop Control';'Archiving Running Indicator'});


lcaPut({'SIOC:SYS0:ML00:SO0249';'SIOC:SYS0:ML00:SO0250'},...
    {'INSERT "0" TO STOP PROGRAM';'RUNS WHEN NUMBER CHANGING'});


%% Input Comment fields - Initially all designed as archiving

lcaPut(comment,'LLRF Signal Archiving');


%% Prepare buffer memory for the 30 data points for pvNames
buffer = zeros(30,length(pvNames));

%% Prepare memory for pvNames_PAC
PAC_I_Q_complex = zeros(length(pvNames_PAC)/2,1);

%% Amplitudes of the signals
%  Sequence: [LSR;  GUN_1; L0A; L0B; TC0; L1S; L1X; TC3]
%sig_ampl =   [6000;  6;  57;  70;  0.6;  115;  20;  0.25;  16000];
%sig_ampl =   [760;  6;  57;  70;  0.6;  115;  20;  0.25;  1600];
sig_ampl =   [64;  6;  57;  70;  0.6;  115;  20;  0.25;  375];

%% Clear PVs and set the LabCa Monitor and the Time Counter
try
    lcaClear(pvNames);
catch
    fprintf(1,['\n*unable to clear monitor for %s\n', ...
        '*This is not an error if monitor did not exist\n'], char(pvNames(1)) );
    fprintf('%s\n\n',datestr(now));
end % try,

try
    lcaSetMonitor(pvNames); % set the monitor
catch
    disp('Failure to Set Monitor')
    err = lasterror;
    fprintf('%s\n%s\n\n',datestr(now),err.message);
end

%% Main "indefinite" while loop reading 30 datapoints for archived PVs

while run_flag  % either 1 or 0 in the Matlab Support PV #249
    Time = 0; % time for one cycle of the while loop
    for n = 1:2:length(pvNames)  % number of PVs to be monitored (curr. 17)
        num_of_reading = 30;     % number of datapoint readings
        k = 1;      % counter for exit from while loop
        tic;                    % start time counter
        while k<= num_of_reading && toc <= 5
            pause(0.025)
            try
                flag = lcaNewMonitorValue(pvNames([n,n+1])); %wait for the next value
            catch
                disp('Channel Access Failed - lcaNewMonitor')
                err = lasterror;
                fprintf('%s\n%s\n\n',datestr(now),err.message);
            end
            if ~flag
            else
                try
                    buffer(k,n:n+1) = lcaGet(pvNames([n,n+1]));
                    pause(0.025)
                catch
                    disp('chanell access failure')
                    err = lasterror;
                    fprintf('%s\n%s\n%s\n%s\n\n',...
                        datestr(now),char(pvNames(n)),char(pvNames(n+1)),err.message);
                end     % try-catch

                k=k+1;
            end % if
        end     %while k
        Time = Time + toc;
        try
            lcaPut('SIOC:SYS0:ML00:AO250',round(Time))
        catch
            disp('Failure to update time counter')
            err = lasterror;
            fprintf('%s\n%s\n\n',datestr(now),err.message);
        end
    end % for n
    tic
    % Calculate MEAN and Standard Deviation values
    Mean_value = mean(buffer)'; % format result into column array,length = 17
    Stde_value = std(buffer)';  % format result into column array,length = 17

    % Store the amplitude and phase MEAN and STD into the MATLAB SUPPORT PVs
    %  If the amplite MEAN is smaller than 75% of max, do not store - no signal
    nn = 1; % index for storage places

    for n = 1 : length(sig_ampl) % 1:1:9
        if Mean_value(2*n-1) > 0.75 * sig_ampl(n)
            try
                lcaPut(store_place_PV([nn,nn+2]),Mean_value([2*n-1,2*n]))
            catch
                disp('Failure to store Mean')
                err = lasterror;
                fprintf('%s\n%s\n%s\n%s\n\n',...
                    datestr(now),char(pvNames(nn)),char(pvNames(nn+1)),err.message);
            end
            try
                lcaPut(store_place_PV([nn+1,nn+3]),Stde_value([2*n-1,2*n]))
            catch
                disp('Failure to store Standard Deviation')
                err = lasterror;
                fprintf('%s\n%s\n%s\n%s\n\n',...
                    datestr(now),char(pvNames(nn+1)),char(pvNames(nn+3)),err.message);
            end
            try
                lcaPut(comment(nn:nn+3),'LLRF Signal Archiving');
            catch
                disp('Channel Access Failed - lcaPut(comment)')
                err = lasterror;
                fprintf('%s\n%s\n\n',datestr(now),err.message);
            end
        else
            try
                lcaPut(comment(nn:nn+3),'Not Archiving, No Signal');
            catch
                disp('Channel Access Failed - lcaPut(comment #2)')
                err = lasterror;
                fprintf('%s\n%s\n\n',datestr(now),err.message);
            end
        end % end if Mean_valeu...
        nn = nn +4; % counter for next four places
    end % for loop

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Start reading of PAC I and Q values

    try
        PAC_I_Q = lcaGet(pvNames_PAC);
        pause(0.025)
    catch
        disp('chanell access failure')
        err = lasterror;
        fprintf('%s\n%s\n%s\n%s\n\n',...
            datestr(now),err.message);
    end     % try-catch

    % create complex I_Q
    for K=1:length(pvNames_PAC)/2
        PAC_I_Q_complex(K) = PAC_I_Q(K+(K-1)) + j*PAC_I_Q(2*K);
    end

    % Calculate amplitude and phase from complex I=j*Q
    % First are all amplitudes, phases are in the second half
    Ampl_Phas(1:2:length(PAC_I_Q)) = abs(PAC_I_Q_complex);
    Ampl_Phas(2:2:length(PAC_I_Q)) = 180*(angle(PAC_I_Q_complex))/pi;

    % Store the amplitude and phase of the four PACs into the MATLAB SUPPORT PVs

    K = 2*length(pvNames); % starting index for storage places



    try
        lcaPut(store_place_PV(K+1:K+length(PAC_I_Q)),Ampl_Phas')
    catch
        disp('Failure to store PAC Ampl or Phase')
        err = lasterror;
        fprintf('%s\n%s\n%s\n%s\n\n',...
            datestr(now),char(pvNames(nn)),err.message);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% waiting to finish one minute
    while Time < 59
        Time = Time +toc;
        try
            lcaPut('SIOC:SYS0:ML00:AO250',round(Time))
        catch
            disp('Failure to update time counter')
            err = lasterror;
            fprintf('%s\n%s\n\n',datestr(now),err.message);
        end
        tic
        pause(1)
    end % while time to 1 minute
    buffer = zeros(30,length(pvNames)); % reset buffer to zero
    try
        run_flag = lcaGet(run_stop);  % check for command to stop the program
    catch
        disp('Channel Access Failed - check running flag')
        err = lasterror;
        fprintf('%s\n%s\n\n',datestr(now),err.message);
    end
    %Time = Time +toc;
end     % while - MAIN from line # 227
%final exit message
disp('Program stopped')
disp(' ')