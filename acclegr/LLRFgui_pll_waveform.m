%% ACQUIRE AND PLOT A WAVEFORM
% This program acquires 2048-point long waveform, it plots the data and
% prints the calculated average value and the standard deviation.

%% Program name
function LLRFgui_pll_waveform(hObject, eventdata, handles)

%update handles
handles=guidata(handles.output);

% first get information what program to run
pv = handles.pvNamesSel; % if=1, plot waveform; if=2, calc. FFT

switch pv
    %% Program_1 reads and plots the averaged PLL waveform
    case 1
        %% Define the pvNames,variables and prepare the buffer for the data
        set(findobj('Tag', 'text23'),'Visible','on')
        % Define all the PV's
        pvNames = {
            'LLRF:IN20:RH:PLL_BUF_RQ'
            'LLRF:IN20:RH:PLL_BUF_WF'
            };

        fs = 60; % sampling frequency
        buffer=zeros(2048,1); % buffer for the 2048 point waveform

        %% Set up the monitor
        %first clear the PV's
        try
            lcaClear(pvNames);
        catch
            fprintf(1,['\n*unable to clear monitor for %s\n', ...
                '*This is not an error if monitor did not exist\n\n'], char(pvNames(1)) );
        end % try,
        lcaSetMonitor(pvNames(2)); %Set the monitor for the waveform PV

        %% Request the new waveform and wait until updated
        lcaPut(pvNames(1),{'Enabled'}); %request
        tic
        old_time = 0;
        lcaGet(pvNames(2));
        drawnow
        flag = lcaNewMonitorValue(pvNames(2)); % flag=0 at first
        t=0;
        while ~flag
            flag = lcaNewMonitorValue(pvNames(2));%; %wait for the new waveform
            %update elapsed time counter on the GUI
            Time = toc;
            if abs(t-Time) <= 0.1
                set(findobj('Tag','text5'),'String',num2str(t))
                drawnow
                t=t+1;
            end
            pause(0.1)
            if ~flag
            else
                try
                    buffer = lcaGet(pvNames(2));
                    drawnow
                catch
                    disp('Waveform Channel Access Failed')
                end
            end %if
        end % while
        display(' ')
        display(['Total elapsed time = ',num2str(toc,4),'s'])
        %% Calculate the average value, STD and plot the waveform
        wave_aver = mean(buffer);
        wave_std  =  std(buffer);
        time = 0: 1/fs:(length(buffer)-1)/fs;
        handles.exportFig = figure(1);
        clf
        plot(time,buffer)
        v=axis;
        %axis([0,2050,v(3),v(4)]);
        grid on
        xlabel('Time [s]')
        ylabel('PLL waveform value')
        title([' PLL WAVEFORM, Average value = ',num2str(wave_aver,3),...
            '. Std. deviation = ',num2str(wave_std,3),'.'])
        set(gcf,'Name',datestr(now));
        drawnow

        %% Print final results
        fprintf(['\n**********\nAverage Waveform Value = ',num2str(wave_aver,3),...
            '\nStandard Deviation     = ',num2str(wave_std,3),' \n'])
        fprintf('**********\n')

        %% Update the GUI handles, STOP > START button, set handles.Return=0
        set(findobj('Tag','start_program'),'string','START')
        set(findobj('Tag', 'text23'),'Visible','off')
        guidata(handles.output,handles);

        %% Program_2 calculation and plotting the FFT
    case 2
        %% Define the pvNames,variables and prepare the buffer for the data
        % Define all the PV's
        pvNames = {
            'LLRF:IN20:RH:PLL_RAW_RQ'
            'LLRF:IN20:RH:PLL_RAW_WF'
            };

        fs = 10e6/256; % sampling frequency
        n = lcaGet('LLRF:IN20:RH:PLL_DATAWDTH'); % number of points
        fr = fs/n;
        freq = (0:n-1)*fr;
        set(findobj('Tag', 'text5'),'String',num2str(fr,2))
        %% Set up the monitor %first clear the PV's
        try
            lcaClear(pvNames);
            %     drawnow
        catch
            fprintf(1,['\n*unable to clear monitor for %s\n', ...
                '*This is not an error if monitor did not exist\n\n'], char(pvNames(1)) );
        end % try,

        %the next three lines must be used!!!!
        %tic
        lcaSetMonitor(pvNames(2)); %Set the monitor for the waveform PV
        lcaNewMonitorWait(pvNames(2));
        lcaGet(pvNames(2));
        %toc

        Toc = 0; %
        k=0;
        while Toc < 0.8 % repeat if waveform was not fully refreshed
            tic
            pause(0.2)
            lcaPut(pvNames(1),1); %request to refresh the waveform
            pause(0.2)
            lcaNewMonitorWait(pvNames(2)) %wait until the new data available
            try                           %acquire the data
                buffer = lcaGet(pvNames(2));
            catch
                disp('Waveform Channel Access Failed')
            end
            Toc = toc;
        end % while Toc

        %% Calculate and plot FFT
        handles.exportFig = figure(1);
        Y = fft(buffer);
        plot(freq,abs(Y),'.-')
        v=axis;
        axis([0,400,0,1.5e5]);
        grid on
        xlabel('Freq [Hz]')
        ylabel('Amplitude')
        title(' FFT of the fast PLL WAVEFORM')
        set(gcf,'Name',datestr(now));
        drawnow

        %         %% Check existence of the auxilliary buffer
        %         if exist('buffer_aux') % define buffer_aux when running program first time
        %         else
        %             buffer_aux=zeros(1,8000);
        %         end
        %         figure(2)
        %         plot(buffer_aux-buffer) %plot the difference between the old and new buffer
        %         buffer_aux = buffer; %save the data into the buffer1
        %         drawnow
        figure(1)

        %% Update the GUI handles, STOP > START button, set handles.Return=0
        set(findobj('Tag','start_program'),'string','START')
        set(findobj('Tag','phase_step'),'Visible','On','String',num2str(400))
        set(findobj('Tag','text2'),'Visible','On','String','Max.Freq.[Hz]')
        guidata(handles.output,handles);
end % case