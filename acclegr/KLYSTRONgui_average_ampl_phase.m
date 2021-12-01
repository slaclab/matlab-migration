%% Sample the amplitude and phase of the selected Klystron signals

% Program name: KLYSTRONgui_average_ampl_phase.m
% Written:      Vojtech Pacak
% Development started:    Jan-11-2008
% First version finished: Jan-15-2008
% Second version, Oct 2008: Major overhaul of the program. Added
%   combined plot of all four klystron signals. Also, data  format was
%   changed into the column vectors rather than the row vectors.
% ***
% Version 14, Jul 2012: Added check for missing pulses when sampling at
%   10Hz. This problem was causing phase jump between two different values.
% Version 15, Aug 3, 2012: Added check for an empty data buffer to avoid
% program to hang. Keep previous graphs open.

%% Updates
%           Mar 21, 2008
%           Oct 23, 2008
%           Dec  1, 2008
%           May 25, 2011
%           Aug 10, 2011
%           Aug 12, 2011
%           Jul 19, 2012 ver 14
%           Aug  3, 2012 ver 15
%           Sep 27, 2012 ver 16
%           Sep 28, 2012 ver 17
%           Jan 23, 2013 ver 18
%           Apr 25, 2013 ver 19

%% Program Name
function KLYSTRONgui_average_ampl_phase(hObject, eventdata, handles)

%% Get selected Klystron, Signal and Width from the GUI
KLY = handles.klystron; %selected klystron
SIG = handles.signal; % selected signal from the PAD
TIME=str2double(handles.aver_time);

%% Definition of PV's
GUN{1}={'KLYS:LI20:K6:GUN_0_AACT','KLYS:LI20:K6:GUN_0_PACT'};
GUN{2}={'KLYS:LI20:K6:GUN_1_AACT','KLYS:LI20:K6:GUN_1_PACT'};
GUN{3}={'KLYS:LI20:K6:GUN_2_SACT'};
GUN{4}={'KLYS:LI20:K6:GUN_3_AACT','KLYS:LI20:K6:GUN_3_PACT'};

L0A{1}={'KLYS:LI20:K7:L0A_0_AACT','KLYS:LI20:K7:L0A_0_PACT'};
L0A{2}={'KLYS:LI20:K7:L0A_1_AACT','KLYS:LI20:K7:L0A_1_PACT'};
L0A{3}={'KLYS:LI20:K7:L0A_2_SACT'};
L0A{4}={'KLYS:LI20:K7:L0A_3_AACT','KLYS:LI20:K7:L0A_3_PACT'};

L0B{1}={'KLYS:LI20:K8:L0B_0_AACT','KLYS:LI20:K8:L0B_0_PACT'};
L0B{2}={'KLYS:LI20:K8:L0B_1_AACT','KLYS:LI20:K8:L0B_1_PACT'};
L0B{3}={'KLYS:LI20:K8:L0B_2_SACT'};
L0B{4}={'KLYS:LI20:K8:L0B_3_AACT','KLYS:LI20:K8:L0B_3_PACT'};

TR_CAV0{1}={'KLYS:LI20:K5:TC0_0_AACT','KLYS:LI20:K5:TC0_0_PACT'};
TR_CAV0{2}={'KLYS:LI20:K5:TC0_1_AACT','KLYS:LI20:K5:TC0_1_PACT'};
TR_CAV0{3}={'KLYS:LI20:K5:TC0_2_SACT'};
TR_CAV0{4}={'KLYS:LI20:K5:TC0_3_AACT','KLYS:LI20:K5:TC0_3_PACT'};

L1S{1}={'KLYS:LI21:K1:L1S_0_AACT','KLYS:LI21:K1:L1S_0_PACT'};
L1S{2}={'KLYS:LI21:K1:L1S_1_AACT','KLYS:LI21:K1:L1S_1_PACT'};
L1S{3}={'KLYS:LI21:K1:L1S_2_SACT'};
L1S{4}={'KLYS:LI21:K1:L1S_3_AACT','KLYS:LI21:K1:L1S_3_PACT'};

L1X{1}={'KLYS:LI21:K2:L1X_0_AACT','KLYS:LI21:K2:L1X_0_PACT'};
L1X{2}={'KLYS:LI21:K2:L1X_1_AACT','KLYS:LI21:K2:L1X_1_PACT'};
L1X{3}={'KLYS:LI21:K2:L1X_2_SACT'};
L1X{4}={'KLYS:LI21:K2:L1X_3_AACT','KLYS:LI21:K2:L1X_3_PACT'};

TR_CAV3{1}={'KLYS:LI24:K8:TC3_0_AACT','KLYS:LI24:K8:TC3_0_PACT'};
TR_CAV3{2}={'KLYS:LI24:K8:TC3_1_AACT','KLYS:LI24:K8:TC3_1_PACT'};
TR_CAV3{3}={'KLYS:LI24:K8:TC3_2_SACT'};
TR_CAV3{4}={'KLYS:LI24:K8:TC3_3_AACT','KLYS:LI24:K8:TC3_3_PACT'};

XTCAV{1}={'KLYS:DMP1:K1:0:AACTUAL','KLYS:DMP1:K1:0:PACTUAL'};
XTCAV{2}={'KLYS:DMP1:K1:1:AACTUAL','KLYS:DMP1:K1:1:PACTUAL'};
XTCAV{3}={'KLYS:DMP1:K1:2:SACTUAL'};
XTCAV{4}={'KLYS:DMP1:K1:3:AACTUAL','KLYS:DMP1:K1:3:PACTUAL'};


TOTAL_PV={GUN,L0A,L0B,TR_CAV0,L1S,L1X,TR_CAV3,XTCAV};
if SIG ~= 5
    pvNames=TOTAL_PV{KLY}{SIG}(:)
else
    pvNames = [TOTAL_PV{KLY}{1}(:);TOTAL_PV{KLY}{2}(:);...
        TOTAL_PV{KLY}{4}(:);TOTAL_PV{KLY}{3}(:)]
end


%% Setting up monitor
% First clear the PV
try
    lcaClear(pvNames);
catch
    fprintf(1,['\n*unable to clear monitor for %s\n', ...
        '*This is not an error if monitor did not exist\n\n'],...
        char(pvNames(1)) );
end % try,

try
    lcaSetMonitor(pvNames);
catch
    disp('Failure to Set Monitor')
    err = lasterror;
    fprintf('%s\n%s\n\n',datestr(now),err.message);
    set(findobj('Tag','start_progr'),'string','START')
    return
end

%%get strength of the signal
ampl=zeros(1,5);
for l = 1:5
    lcaNewMonitorWait(pvNames)
    ampl(l)=lcaGet(pvNames{1}); %lcaGet(pvNames{1}); 
end

sig_ampl=max(ampl);
pause(1)

set(findobj('Tag','txt4'),'Visible','On')
set(findobj('Tag','txt5'),'Visible','On')
%set(findobj('Tag','txt5'),'String',num2str(handles.aver_time))

%% Prepare size of the buffer, averaging time
l1= length(pvNames); %limits for buffer size
l2= 2*l1; % total number of columns for multiple PVs
buffer=zeros(TIME*130,l2); % buffer for PV, Phase and Ampl
t = TIME;
set(findobj('Tag','txt5'),'String',num2str(round(TIME)))
drawnow
tic
Time=toc;
k=1;


%% Main body of the program data acquisition
while  Time<=TIME; %Time<=time;
    flag_new_monitor_value = lcaNewMonitorValue(pvNames);%wait for the next
    % value
    if  flag_new_monitor_value
        try
            [buffer(k,1:l1),buffer(k,l1+1:l2)] = lcaGet(pvNames);
            %columns 1:l1...values, columns l1+1:l2...time stamps
        catch
            disp('Channel Access Failed')
        end
        if buffer(k,1) > 0.75*sig_ampl
            k=k+1;
        end
    else
    end
    Time = toc;

%     if TIME-Time >= t-0.3 && TIME-Time <= t+0.3
%         set(findobj('Tag','txt5'),'String',num2str(round(TIME-Time)))
%         drawnow
%         t=t-1;
%     end

    % simpler and better way to control the countdown counter display
    set(findobj('Tag','txt5'),'String',num2str(floor(TIME-Time+1)))
    
    %update handles to check for "STOP"
    drawnow % this had to be added for program to accept STOP
    handles = guidata(handles.output); % get handles from GUI
    if handles.Return
        break
    end
end %while  Time<=TIME;

% Check for empty buffer
if k == 1
    set(findobj('Tag','start_progr'),'string','START')
    disp(' ')
    disp('Program stopped. The data buffer is empty.')
    disp('Amplitude value is negative, or PAD channel not updating.')
    set(findobj('Tag','txt4'),'Visible','Off')
    set(findobj('Tag','txt5'),'Visible','Off')
    drawnow
    return
end



%% Processing of the accumulated data
disp(' ')
toc
fprintf(['\n*Number of data points = ',num2str(k-1),'\n'])
[r,c]=find(buffer,1,'last'); %find the last non-zero row and column indices
r=r-1;  % drop the last buffer that may be low amplitude
buffer_short=[buffer(1:r,1:l1),buffer(1:r,l1+1)]; %deleting zero values

% create the time scale, lca2matlabTime in /afs/slac/g/lcls/cvs/matlab/src
t1 = datestr(lca2matlabTime(buffer_short(1,  l1+1)),'HH:MM:SS.FFF');
t2 = datestr(lca2matlabTime(buffer_short(end,l1+1)),'HH:MM:SS.FFF');
t_second = real(buffer_short(:,l1+1)) + imag(buffer_short(:,l1+1))/1e9;
time_x = t_second - t_second(1); %time for x-axis of the plot
%calculate average and standard deviation values
MEAN=mean(buffer_short(:,1:l1));
STD = std(buffer_short(:,1:l1));
if r == 1
    MEAN = ones(1,l1)*MEAN; % This has to be done not to bomb program in l 141
    STD  = ones(1,l1)*STD;%and line 174
end
ampl_rel_err= 100*(STD(1:2:l1)./MEAN(1:2:l1));



%% Plot the amplitude and phase
%prepare Title for the plots
Title1={'GUN: ','L0A: ','L0B: ','TC0: ','L1S: ','L1X: ','TC3: ','XTC: '};
Title2={'PAC-Out','Kly-Drive','Kly-Beam-Volt','Kly-Forward'};

switch SIG
    case {1 2 4}    %plots amplitude and phase of the selected signal
        handles.exportFig = figure;
        subplot(2,1,1);
        p = plot(time_x,buffer_short(:,1),'.-');
        %         % Next 3 lines added to suppress scient. notation for value axis
        %         q = get(p,'parent');
        %         y_format = get(q,'yTick'); % Y-axis amplitude values
        %         set(q,'yTickLabel',y_format);
        % to stop the x-axis exactly at time_x=TIME
        V=axis;
        axis([0 TIME V(3) V(4)])
        grid on
        if SIG == 4 % Select correct amplitude units
            ylabel('amplitude [MV]')
        else
            ylabel('amplitude [V]')
        end
        T = title([Title1{KLY},Title2{SIG},', AMPL., Average = ',...
            num2str(MEAN(1),5),'. Relative error = ',...
            num2str(ampl_rel_err,2),' %.']);
        set(T,'FontSize',11,'Fontweight','bold')
        pause(0.05)
        subplot(2,1,2)
        plot(time_x,buffer_short(:,2),'.-')
        % to stop the x-axis exactly at time_x=TIME
        V=axis;
        axis([0 TIME V(3) V(4)])
        grid on
        xlabel('time [sec]');
        ylabel('phase [deg]');
        T = title([Title1{KLY},Title2{SIG},', PHASE, Average = ',...
            num2str(MEAN(2),5),'. Std. deviation = ',...
            num2str(STD(2),3),' deg.']);
        set(T,'FontSize',11,'Fontweight','bold')
        
        %place date&time at the top figure name and at the figure bottom
        set(gcf,'Name',datestr(now))
        text(-1,-1.2,datestr(now),'units','centimeters')
        
        %print final results
        %fprintf(['\n**********\nStarting time = ',t1,'\n'])
        %fprintf(['Ending time   = ',t2,'\n**********\n'])
        disp(' ')
        disp(['*****',Title1{KLY}(:)',Title2{SIG}(:)','*****'])
        fprintf(['\n*Average RF Amplitude = ',num2str(MEAN(1),5),...
            '\n*Standard Deviation   = ',num2str(STD(1),3),...
            '\n*Relative Error       = ',num2str(ampl_rel_err,2),' %%\n'])
        fprintf('******************************\n')
        fprintf(['\n*Average RF Phase     = ',num2str(MEAN(2),5),...
            ' deg','\n*Standard Deviation   = ',num2str(STD(2),3),...
            ' deg\n******************************\n\n'])
    case 3  % plots klystron beam voltage only
        handles.exportFig = figure;
        p = plot(time_x,buffer_short(:,1)/1e3,'.-');
        %         % Next 3 lines added to suppress scient. notation for value axis
        %         q = get(p,'parent');
        %         y_format = get(q,'yTick'); % Y-axis amplitude values
        %         set(q,'yTickLabel',y_format);
        %
        % to stop the x-axis exactly at time_x=TIME
        V=axis;
        axis([0 TIME V(3) V(4)])
        grid on
        xlabel('time [sec]')
        ylabel('amplitude [kV]')
        T = title([Title1{KLY},Title2{SIG},', Average = ',...
            num2str(MEAN,6),'. Relative error = ',...
            num2str(ampl_rel_err,2),' %.']);
        set(T,'FontSize',11,'Fontweight','bold')
        
        %place date&time at the top figure name and at the figure bottom
        set(gcf,'Name',datestr(now))
        text(-1,-1.2,datestr(now),'units','centimeters')
        pause(0.05)
        disp(' ')
        disp(['*****',Title1{KLY}(:)',Title2{SIG}(:)','*****'])
        fprintf(['\n*Average RF Amplitude = ',num2str(MEAN(1),5),...
            '\n*Standard Deviation   = ',num2str(STD(1),3),...
            '\n*Relative Error       = ',num2str(ampl_rel_err,2),...
            ' %%\n******************************\n\n'])
    case 5  % plots all amplitude and phases
        handles.exportFig = figure;
        s(1) = subplot(3,1,1);
        p = plot(time_x,buffer_short(:,1),'b.-',...
            time_x,buffer_short(:,3),'g.-',...
            time_x,buffer_short(:,5),'r.-');
        % to stop the x-axis exactly at time_x=TIME
        V=axis;
        axis([0 TIME V(3) V(4)])
        grid on
        ylabel('amplitude [V; MV]')
        T=title([Title1{KLY},'AMPL.   ','\color{blue}',Title2{1},...
            ',   \color{green}',Title2{2},',   \color{red}',Title2{4},' [MV]']);
        set(T,'FontSize',11,'Fontweight','bold')
        drawnow

        s(2) = subplot(3,1,2);
        p = plot(time_x,buffer_short(:,2),'b.-',...
            time_x,buffer_short(:,4),'g.-',...
            time_x,buffer_short(:,6),'r.-');
        % to stop the x-axis exactly at time_x=TIME
        V=axis;
        axis([0 TIME V(3) V(4)])
        grid on
        ylabel('phase [deg]')
        T=title([Title1{KLY},'PHAS.   ','\color{blue}',Title2{1},...
            ',   \color{green}',Title2{2},',   \color{red}',Title2{4}]);
        set(T,'FontSize',11,'Fontweight','bold')
        drawnow

        s(3) = subplot(3,1,3);
        p = plot(time_x,buffer_short(:,7)/1e3,'b.-');
        %         % Next 3 lines added to suppress scient. notation for value axis
        %         q = get(p,'parent');
        %         y_format = get(q,'yTick'); % Y-axis amplitude values
        %         set(q,'yTickLabel',y_format);
        %         %
        % to stop the x-axis exactly at time_x=TIME
        V=axis;
        axis([0 TIME V(3) V(4)])
        grid on
        ylabel('Beam Voltage [kV]')
        xlabel('time [sec]')
        T=title([Title1{KLY},'  ',Title2{3}]);
        set(T,'FontSize',11,'Fontweight','bold')
        drawnow
        %place date&time at the top figure name and at the figure bottom
        set(gcf,'Name',datestr(now))
        text(-1,-1.2,datestr(now),'units','centimeters')
        
        %print results
        disp(' ')
        disp(['*****',Title1{KLY}(:)','*****'])
        disp(['                     PAC-Out  Kly-Drive'...
            '  Kly-Forw-Power  Kly-Beam-Volt']);
        fprintf(['*Average RF Amplitude = ',num2str(MEAN(1,[1 3 5 7]),'%12.0f'),...
            '\n*Standard Deviation   = ',num2str(STD(1,[1 3 5 7]),'%12.2f'),...
            '\n*Relative Error       = ',num2str(ampl_rel_err,'%12.2f'),' %%\n'])
        fprintf('******************************\n')
        fprintf(['\n*Average RF Phase     = ',num2str(MEAN(1,[2 4 6]),'%12.0f'),...
            ' deg','\n*Standard Deviation   = ',num2str(STD(1,[2 4 6]),'%12.2f'),...
            ' deg\n******************************\n\n'])
end % case
%% Update the GUI handles, STOP > START button, set handles.Return=0
handles.Return = 0;
set(findobj('Tag','start_progr'),'string','START')
set(findobj('Tag','txt4'),'Visible','Off')
set(findobj('Tag','txt5'),'Visible','Off')
guidata(handles.output,handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%