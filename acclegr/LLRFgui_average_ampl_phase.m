%% Program reads the phase and amplitude of selected signals RF signals.
%  Program belongs to the group of programs selected from the LLRFgui.
%  Operator can select the signal and the time to accumulate the data.
%  The result is plotted and the average values and standard deviations
%  are displayed.
%  A warning message is printed when the errors are above the tolerances.
%
%  Written:     Vojtech Pacak       2007/2008
%  Last update: 21-Jun-2013   ver 18

function LLRFgui_average_ampl_phase(hObject, eventdata, handles)

%**************************************************

%% Update handles, prepare buffer memory for the data, initialize flags
handles=guidata(handles.output);
TIME = str2double(handles.averaging_time); % preselected averaging time
buffer=zeros(4,TIME*100); % prepare the buffer for PV and timestamp
ampl_tol_flag = 0; % flags for error warning
phas_tol_flag = 0;

%% Signal definition and selection

pv = handles.pvNamesSel_2;
switch pv
    case 1
        Title = 'THALES LSR:';
        ampl_tol = 2;
        phas_tol = 0.4;
        pvNames = {
            'LASR:IN20:1:LSR_0_AACT'
            'LASR:IN20:1:LSR_0_PACT'
            }
    case 2
        Title = 'GUN:';
        ampl_tol = 0.1;
        phas_tol = 0.1;
        pvNames = {
            'GUN:IN20:1:GN1_AAVG'
            'GUN:IN20:1:GN1_PAVG'
            }
    case 3
        Title ='L0A:';
        ampl_tol = 0.1;
        phas_tol = 0.1;
        pvNames = {
            'ACCL:IN20:300:L0A_AAVG'
            'ACCL:IN20:300:L0A_PAVG'
            }
    case 4
        Title = 'L0B:';
        ampl_tol = 0.1;
        phas_tol = 0.1;
        pvNames = {
            'ACCL:IN20:400:L0B_AAVG'
            'ACCL:IN20:400:L0B_PAVG'
            }
    case 5
        Title = 'TC0:';
        ampl_tol = 0.5;
        phas_tol = 0.5;
        pvNames = {
            'TCAV:IN20:490:TC0_AAVG'
            'TCAV:IN20:490:TC0_PAVG'
            }
        TC_Ampl = lcaGet('TCAV:IN20:490:TC0_ADES');
    case 6
        Title = 'L1S:';
        ampl_tol = 0.1;
        phas_tol = 0.1;
        pvNames = {
            'ACCL:LI21:1:L1S_AAVG'
            'ACCL:LI21:1:L1S_PAVG'
            }
    case 7
        Title = 'L1X:';
        ampl_tol = 0.25;
        phas_tol = 0.5;
        pvNames = {
            'ACCL:LI21:180:L1X_AAVG'
            'ACCL:LI21:180:L1X_PAVG'
            }
    case 8
        Title = 'TC3:';
        ampl_tol = 0.5;
        phas_tol = 0.1;
        pvNames = {
            'TCAV:LI24:800:TC3_AAVG'
            'TCAV:LI24:800:TC3_PAVG'
            }
        TC_Ampl = lcaGet('TCAV:LI24:800:TC3_ADES');
    case 9
        Title = 'COHERENT LSR:';
        ampl_tol = 2;
        phas_tol = 0.4;
        pvNames = {
            'LASR:IN20:2:LSR_0_AACT'
            'LASR:IN20:2:LSR_0_PACT'
            }
    case 10
        Title = 'XTCAV:';
        ampl_tol = 0.25;
        phas_tol = 0.5;
        pvNames = {
            'TCAV:DMP1:360:AAVG'
            'TCAV:DMP1:360:PAVG'
            }
end
%***************************************************

%% Setting the LabCa Monitor
% first clear the PV's
try
    lcaClear(pvNames);
catch
    fprintf(1,['\n*unable to clear monitor for %s\n', ...
        '*This is not an error if monitor did not exist\n\n'], char(pvNames(1)) );
end % try,
lcaSetMonitor(pvNames); % set the monitor

%% Main body of the program data acquisition
k=1;
t = TIME; % this is the averaging time set at the GUI
tic; % start countdown timer
Time = toc; %This is the elapsing time
while Time <= TIME  %TIME defined by the GUI handles
    try
        lcaNewMonitorWait(pvNames)
    catch
        disp('error lcaNewMonitorWait')
    end
    try

        [buffer(1:2,k),buffer(3:4,k)] = lcaGet(pvNames);
    catch
        disp('Channel Access Failed - lcaGet(pvNames)')
    end
    %Special case for TC0 and TC3 dropping the "zero" amplitudes
    switch pv
        case{5 8}
            if buffer(1,k) < 0.5*TC_Ampl
                k=k-1;
            end
    end
    
    k=k+1;
    
    Time = toc;
    %original countdown counter control
%     if TIME-Time >= t-0.3 & TIME-Time <= t+0.3
%         set(findobj('Tag','text5'),'String',num2str(round(TIME-Time)))
%         drawnow
%         t=t-1;
%     end %if

    % simpler and better way to control the countdown counter display
    set(findobj('Tag','text5'),'String',num2str(floor(TIME-Time+1)))

    %update handles to check for "STOP"
    drawnow % this had to be added for program to accept STOP
    handles = guidata(handles.output); % get handles from GUI
    if handles.Return
        break
    end %if
end % while


%% Processing of the accumulated dData
%find the length of the non-zero buffer
limit =find(buffer(2,:),1,'last');
buffer_short = buffer(:,1:limit-1);

%check for empty buffer
if limit < 2
    disp('No data in the buffer')
    disp(' ')
    return
end %if

switch pv
    %     case 1    % correct for phase offset
    %         phase_offset = lcaGet('LASR:IN20:1:LSR_PDES2856');
    %         buffer_short(2,:) = buffer_short(2,:) + phase_offset;
    case 7    % remove phase discontinuity at +/-180 deg
        buffer_short(2,:)=mod(buffer_short(2,:)+360,360)-360;
end

t1 = datestr(lca2matlabTime(buffer_short(3,1)),'HH:MM:SS.FFF');
t2 = datestr(lca2matlabTime(buffer_short(3,end)),'HH:MM:SS.FFF');
t_second = real(buffer_short(3,:)) + imag(buffer_short(3,:))/1e9;
time_x = t_second - t_second(1); %time for x-axis of the plot
av_ampl=mean(buffer_short(1,:));
ampl_std = std(buffer_short(1,:));
ampl_rel_err= 100*ampl_std/av_ampl;
av_phas=mean(buffer_short(2,:));
phas_std = std(buffer_short(2,:));

%% Plot the amplitude and phase
handles.exportFig = figure;
clf
subplot(2,1,1);
p = plot(time_x,buffer_short(1,1:end),'.-r');
% to stop the x-axis exactlu at time_x=TIME
V=axis;
axis([0 TIME V(3) V(4)]) 

% q = get(p,'parent'); % 3 lines added to suppress scient. notation for ...
% y_format = get(q,'yTick'); % Y-axis amplitude values
% set(q,'yTickLabel',y_format);
grid on

if pv == 1 % Select correct amplitude units
    ylabel('amplitude [a.u.]')
else
    ylabel('amplitude [MV]')
end

if ampl_rel_err < ampl_tol
    title([Title,' AMPLIT., Mean = ',num2str(av_ampl,5),...
        '. Relat.err. = ',num2str(ampl_rel_err,2),'%, (tol = ',...
        num2str(ampl_tol,2),'%).'])
else
    title([Title,' AMPLIT., Mean = ',num2str(av_ampl,5),...
        '. \fontsize{12} \bf \color{red}Relat. err. = ',...
        num2str(ampl_rel_err,2),'%, (tol = ',num2str(ampl_tol,2),'%).'])
    ampl_tol_flag = 1;
end
pause(0.05)
subplot(2,1,2)
plot(time_x,buffer_short(2,1:end),'.-b')
% to stop the x-axis exactlu at time_x=TIME
V=axis;
axis([0 TIME V(3) V(4)]) 
grid on
xlabel('time [sec]')
ylabel('phase [deg]')
if phas_std < phas_tol
    title([Title,' PHASE, Mean = ',num2str(av_phas,5),'\circ.',...
        ' Std. dev. = ',num2str(phas_std,2),'\circ, (tol = ',...
        num2str(phas_tol,2),'\circ).'])
else
    title([Title,' PHASE, Mean = ',num2str(av_phas,5),'\circ.',...
        ' \fontsize{12} \bf \color{red}Std. dev. = ',...
        num2str(phas_std,2),'\circ, (tol = ',num2str(phas_tol,2),'\circ).'])
    phas_tol_flag = 1;
end

%place date&time at the top figure name and at the figure bottom
set(gcf,'Name',datestr(now));
text(-1,-1.2,datestr(now),'units','centimeters')
drawnow


%% Print the final results
fprintf(['\n**********\nStarting time = ',t1,'\n'])
fprintf(['Ending time   = ',t2,'\n**********\n'])
fprintf(['\nAverage RF Amplitude = ',num2str(av_ampl,5),...
    '\nStandard Deviation   = ',num2str(ampl_std,3),...
    '\nRelative Error       = ',num2str(ampl_rel_err,2),' %%\n'])
if ampl_tol_flag
    fprintf(2,['!!!Amplitude Relative Error larger than ',...
        num2str(ampl_tol),'%% !!!\n'])
end
fprintf('***********************************\n')
fprintf(['\nAverage RF Phase     = ',num2str(av_phas,5),...
    ' deg\nStandard Deviation   = ',num2str(phas_std,3),' deg\n'])
if phas_tol_flag
    fprintf(2,['!!!Phase Standard Deviation larger than ',...
        num2str(phas_tol),' deg !!!\n'])
end
fprintf('***********************************\n')

%% Update the GUI handles, STOP > START button, set handles.Return=0
handles.Return = 0;
set(findobj('Tag','start_program'),'string','START')
guidata(handles.output,handles);