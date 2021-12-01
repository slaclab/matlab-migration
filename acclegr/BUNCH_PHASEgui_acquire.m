%% Sample the response of the phase cavity
% Development started:    second half of 2007
% First version:   .....-2007
% Second version:  Apr-8-2008
% Third version:  May 2, 2008 Program plots all data points for Phase,
%         Charge and Cav. Detuning. Graphing of each measurement can be
%         suppressed.
% Fourth version:  June 4, 2008 Program first acquire all selected waveforms
%         from the "RAW" fast refreshing waveform PVs. Fitting of the
%         amplitude curves and final plots are done afterwards. The
%         reference point for phase linear regression was changed and it is
%         in the approximate center of the amplitude raising edge. The time
%         to processed 2x5000 waveforms is about 130 seconds.
%         
%         
% Program name: BUNCH_PHASEgui_acquire.m
% Written:          Vojtech Pacak
% Last updated: May 2, 2008
% Major program update: June 4, 2010

%% Program Name
function BUNCH_PHASEgui_acquire(hObject, eventdata, handles)

%% Import the selected input values, define PVs and some variables
N_Of_R = str2double(handles.NumOfReading); % number of readings
T = N_Of_R + round(1*N_Of_R);                                % max time of reading
CavSelection = handles.cavity;             % selected cavity
char_corr = [25288;21961;25171];% [28350;23665;27125]% charge correction factors
size_PV = {
    'GUN:IN20:1:GN2_3_SIZE'
    'GUN:IN20:1:GN2_2_SIZE'
    'KLYS:LI24:K8:TC3_1_SIZE'
    };

switch CavSelection
    case 1
        pvNames = {'GUN:IN20:1:GN2_3_RAW_WF'}; %GUN:IN20:1:GN2_3_RAW_WF
        NofC = 1; % this is Number of Columns for allocated data storage
        a = 9;
        heading = 'PH_CAV #1';
        Size = lcaGet(size_PV(1));
    case 2
        pvNames = {'GUN:IN20:1:GN2_2_RAW_WF'};
        NofC = 1;
        a = 10;
        heading = 'PH_CAV #2';
        Size = lcaGet(size_PV(2));
    case 3
        pvNames = {'KLYS:LI24:K8:TC3_1_RAW_WF'};
        NofC = 1;
        a = 11;
        heading = 'PH_CAV #3';
        Size = lcaGet(size_PV(3));
    case 4
        pvNames = {
            'GUN:IN20:1:GN2_3_RAW_WF'   % Cav 1
            'GUN:IN20:1:GN2_2_RAW_WF'   % Cav 2
            };
        NofC = 2;
        a = 9;
        heading = 'PH_CAV #1    PH_CAV #2';
        Size = lcaGet(size_PV(1:2));
    case 5
        pvNames = {
            'GUN:IN20:1:GN2_3_RAW_WF'   % Cav 1
            'GUN:IN20:1:GN2_2_RAW_WF'   % Cav 2
            'KLYS:LI24:K8:TC3_1_RAW_WF' % Cav 3
            };
        NofC = 3;
        a =9;
        heading = 'PH_CAV #1    PH_CAV #2    PH_CAV #3';
        Size = lcaGet(size_PV(1:3));
end

%% Check the Size of the waveform window is equal to 512
size_check = (Size == 512);
if all(size_check)
else
    display('***** Set the waveform window Size to 512! *****')
    display(' ')
    set(findobj('Tag','Start'),'string','START')
    guidata(handles.output,handles); %updates handles inside the GUI
    return
end

% First clear the monitor and figure and select the cavity
try
    lcaClear(pvNames);
catch
    fprintf(1,['\nunable to clear monitor for %s\n',...
        'not an error if monitor did yet not exist\n'],char(pvNames(1)));
end  %% try

drawnow

%% Prepare the monitor for the I_Q waveform, allocate memory space
lcaSetMonitor(pvNames);


%% Create the time array, sample frequency 25.5MHz, close old graph
time_step = 1/25.5e6;  %
Time = 0:time_step:((512/4)-1)*time_step;
Time = Time'; %Change into column array to be the same as the read data
close(figure(1)) % has to be done this way....???
close(figure(2))
close(figure(3))
close(figure(4))
fig_Num = 0;

%% Resize the Figure size according the number of cavities plotted
PlotGraph = get(findobj('Tag','PlotGraph'),'Value');
if PlotGraph == 1
    fig_Num = fig_Num +1;
    Fig = figure(fig_Num);
    if NofC > 1
        p = get(Fig,'Position');
        set(Fig,'position',[p(1),p(2),NofC*330,p(4)])
        drawnow
    end
    handles.exportFig(1) = figure(1);
    guidata(handles.output,handles); %updates handles inside the GUI
end

%% Main loop reading the phase cavity response signal
Info = findobj('Tag','text21');
n=1; % while loop counter
m=1; % data indexing  M
M = zeros(N_Of_R*NofC,512); % prepare memory storage for the waveforms
tic
t=toc;
flag = true; % flag for "Waiting for bunch" warning
while n <= N_Of_R   && t <= T
    set(findobj('Tag','text20'),'string',num2str(n)) %update counter
    try
        lcaNewMonitorWait(pvNames); % wait for the new PV value
        %toc
        M_buffer = lcaGet(pvNames);        % acquire PV
    catch
        disp('Failure to get new PV')
        err = lasterror;
        fprintf('%s\n%s\n\n',datestr(now),err.message);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     load M_1; %THIS IS ADDED ONLY FOR OFF_LINE TEST
    %     load M_2
    %     M=M_1;
    %     M=[M_1;M_2]; %THIS IS ADDED ONLY FOR OFF_LINE TEST
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    MAX= abs(max(M_buffer,[],2) - mean(M_buffer,2));

    % MAX(2)=MAX(2)/100; %this line was for testing  only

    if abs(MAX) > 50 %new data and plot only if there is a bunch signal
        %l = logical(1); %logical variable for signal from the Phase cav.
        set(Info,'string','Acquiring Data') % info 
        flag = true; %reset flag for "Waiting for bunch" warning
        M(m:m+NofC-1,:)=M_buffer;
        n=n+1;
        m=m+NofC;
    else
        if flag
            %Bunch_present;
            disp(' ')
            disp(['Waiting for the signal from (at least one of) the ',...
                'selected cavity'])
            toc
            %disp('Push the "STOP" red button to cancel')
            disp(' ')
            flag = false;
            set(Info,'string','Program running - waiting for the signal') 
        end
    end % if max(M)>250

    t=toc; %update time t to exit from the while loop after preset time

    handles = guidata(handles.output); % update handles to check for STOP
    drawnow % this had to be added for program to accept STOP
    if handles.Return
        break
    end
end %>>>>>>WHILE n <= N_Of_R   && t <= T

%exit without plot, there are no data
if t>= T
    disp(' ')
    disp('PROGRAM TERMINATING, NO SIGNAL')
    disp(' ')
    set(Info,'string','Program terminated, no signal within the time limit') 
    return
end

Toc=toc; % total time to take N_Of_R readings
M=M'; % change the data into the column array
set(Info,'String','Program is processing the measured data')
drawnow


% re-arrange the raw data so the waveforms for the same phase cavity are
% together
if NofC==1
elseif NofC==2
    M(:,[1:N_Of_R,N_Of_R+1:2*N_Of_R]) = M(:,[1:2:end,2:2:end]);
else
    M(:,[1:N_Of_R,N_Of_R+1:2*N_Of_R,2*N_Of_R+1:3*N_Of_R]) = ...
        M(:,[1:3:end,2:3:end,3:3:end]);
end


%call Function "CalcAndPlot" ,                                 FUNCTION #1
[ampl,phas,c,fig_Num,handles] = CalcAndPlot(Time,M,NofC,N_Of_R,n,...
    char_corr,fig_Num,handles);

guidata(handles.output,handles); %updates handles.exportFig in the GUI


%
%call fitting Function "fit_ampl"                              FUNCTION #2
[Charge,Phase,Cav_detun] = fit_ampl(Time,c,ampl,phas,NofC,N_Of_R,n,...
    char_corr,fig_Num);


% handles.Return = 0;
% set(findobj('Tag','Start'),'string','START')
% set(findobj('Tag','PlotGraph'),'String','No Graph','Value',0);
% guidata(handles.output,handles); %updates handles inside the GUI

LAST = find(Cav_detun(:,1),1,'last'); % find the last non-zero data value


%% Calculate the Mean and STD values for Charge, Phase and Cav detuning
s = size(Charge);
if s(1) == 1  % for only one reading, N_Of_R = 1
    Charge_Mean  = Charge;
    Charge_STD   = zeros(size(Charge));
    Phase_Mean   = Phase;
    Phase_STD    = zeros(size(Charge));
    Cav_det_Mean = Cav_detun;
    Cav_det_STD  = zeros(size(Charge));
else           % 2 or more readings, N_Of_R => 2
    Charge_Mean  = mean(Charge(1:LAST,:));
    Charge_STD   = std(Charge(1:LAST,:));
    Phase_Mean   = mean(Phase(1:LAST,:));
    Phase_STD    = std(Phase(1:LAST,:));
    Cav_det_Mean = mean(Cav_detun(1:LAST,:));
    Cav_det_STD  = std(Cav_detun(1:LAST,:));
end

%% Place the Mean Charge value on the plot
if PlotGraph == 1
    Fig = figure(fig_Num);
    h = get(gcf,'Children');
    set(h,'FontSize',9,'FontWeight','Bold')
    set(h(1:2:2*NofC),'YTick',[0 45 90 135 180 225 270 315 360])
    for k=1:NofC
        subplot(2,NofC,k)
        title(['Ph-Cav #',num2str(k),', Charge = ',...
                                        num2str(Charge_Mean(k),3),' nC'])
        subplot(2,NofC,NofC+k)
        title(['Ph-Cav #',num2str(k),', Phase = ',...
                                        num2str(Phase_Mean(k),4),' deg'])
    end
    set(gcf,'Name',datestr(now));
end

%% Print the results into the open Matlab window
fprintf(1,['\n**Number of readings ',num2str(n-1),'         ',heading,'\n'])

fprintf(1,['Phase Mean Value:               >>',num2str(Phase_Mean,4),...
                                                                ' deg.\n'])
fprintf(1,['Phase STD over ',num2str(n-1),' readings is:   >>',...
                                 num2str(Phase_STD,'%11.2f'),'  deg.\n\n'])
fprintf(1,['Charge Mean Value:              >>',num2str(Charge_Mean,3),...
                                                                 ' nC.\n'])
fprintf(1,['Charge STD over ',num2str(n-1),' readings is: >>',...
                                num2str(Charge_STD,'%11.3f'),'   nC.\n\n'])
fprintf(1,['Detuning Mean Value:            >>',num2str(Cav_det_Mean,6),...
                                                                 ' Hz.\n'])
fprintf(1,['Detuning STD over ',num2str(n-1),' readings is:>>',...
                           num2str(Cav_det_STD,'%13.0f'),'       Hz.\n\n'])

display(['Elapsed time = ',num2str(Toc,4),' seconds.'])
display(' ')

%% Display the data in the GUI data windows
for cav = 1:NofC
    txt = a + cav;
    set(findobj('Tag',['txt',num2str(txt)]),'String',...
         [num2str(Phase_Mean(cav),4),'/',num2str(Phase_STD(cav),'%4.2f')])
    set(findobj('Tag',['txt',num2str(txt+3)]),'String',...
       [num2str(Charge_Mean(cav),3),'/',num2str(Charge_STD(cav),'%4.3f')])
    set(findobj('Tag',['txt',num2str(txt+6)]),'String',...
     [num2str(Cav_det_Mean(cav),5),'/',num2str(Cav_det_STD(cav),'%15.0f')])
end

%% Plot Phase and Charge and Cavity_Detuning for all data
for k = 1:NofC
    figure(fig_Num+k)
    subplot(3,1,1)
    plot(Phase(1:LAST,k),'.-')
    title(['Ph-Cav #',num2str(k)]);
    grid on
    ylabel('Phase [deg]')
    subplot(3,1,2)
    plot(Charge(1:LAST,k),'.-')
    grid on
    ylabel('Charge [nC]')
    subplot(3,1,3)
    plot(Cav_detun(1:LAST,k),'.-')
    grid on
    ylabel('Cavity detuning [Hz]')
    xlabel(['Number of measurements over the ',num2str(Toc,4),' seconds'])
    handles.exportFig(fig_Num+k) = figure(fig_Num+k);
end


%% Update the GUI handles, STOP > START button, set handles.Return=0
handles.Return = 0;
set(findobj('Tag','Start'),'string','START')
set(findobj('Tag','PlotGraph'),'String','No Graph','Value',0);
set(Info,'string','End of Data Measurement') % info 
guidata(handles.output,handles); %updates handles inside the GUI
return  % end of the acquire program

%%%************************************************************************
%%%************************************************************************
%% FUNCTIONS  *************************************************************
%%%************************************************************************
%%%************************************************************************
%%  F U N C T I O N___1
%% Calculates ampl and phase and plots the graphs
function [ampl,phas,c,fig_Num,handles] = CalcAndPlot(Time,M,NofC,N_Of_R,n,...
    char_corr,fig_Num,handles)

%% Calculate I and Q from the raw waveform data
I_Q_complex=zeros(fix(512/4),NofC*N_Of_R); %% Prepare space for the matrix
k=1;
for r=1:4:4*fix(512/4)
    I=(M(r,:)-M(r+2,:))/2;
    Q=(M(r+1,:)-M(r+3,:))/2;
    I_Q_complex(k,:)=I+1j*Q;
    k=k+1;
end
PlotGraph = get(findobj('Tag','PlotGraph'),'Value'); %check for graphing
if PlotGraph == 1
    fig_Num = 1;
    Fig = figure(fig_Num);
    if NofC > 1
        p = get(Fig,'Position');
        set(Fig,'position',[p(1),p(2),NofC*330,p(4)])
        drawnow
    end
    handles.exportFig(1) = figure(1);
end
%% Calculate the Amplitude and Phase
ampl = abs(I_Q_complex);
phas = 180*unwrap(angle(I_Q_complex))/pi;
phas = mod(phas,360);

%% Plot amplitude and phase into figure(fig_Num)
for k=1:NofC
    % calculates the mean amplitude from N_Of_R waveforms in the next line
    MEAN_ampl=mean(ampl(:,(k-1)*N_Of_R+1:(k-1)*N_Of_R+(n-1)),2);
    c(k) = find(MEAN_ampl==max(MEAN_ampl));  %% Index of the MAX amplitude

    if PlotGraph == 1
        %Fig=figure(fig_Num);
        subplot(2,NofC,k)
        %,[Time(c(k)),Time(c(k))],[0,1],'b');
        %plot(Time,ampl(:,(k-1)*N_Of_R+1:k*N_Of_R)/char_corr(k),'b.')
        plot(Time,MEAN_ampl/char_corr(k),'b.-')
        ax=axis;
        axis([0,5e-6,ax(3),ax(4)]);
        hold on

        T=title(['Ph-Cav #',num2str(k),', Charge =']);
        set(T,'FontSize',10,'FontWeight','Bold')
        Y = ylabel('charge, [nC]');
        set(Y,'FontSize',9,'FontWeight','Bold')
        grid on

        MEAN_phas=mean(phas(:,(k-1)*N_Of_R+1:(k-1)*N_Of_R+(n-1)),2);
        subplot(2,NofC,NofC+k)
        %plot(Time,phas(:,(k-1)*N_Of_R+1:k*N_Of_R),'b.')
        %,[Time(c(k)),Time(c(k))],[-360,360],'r');
        %ax=axis;
        plot(Time,MEAN_phas,'b.-')
        axis([0,5e-6,0,360]);
        hold on
        T=title(['Ph-Cav #',num2str(k),', Phase =']);
        set(T,'FontSize',10,'FontWeight','Bold')
        X = xlabel('time [s]');
        Y = ylabel('phase, [deg]');
        set(X,'FontSize',9,'FontWeight','Bold')
        set(Y,'FontSize',9,'FontWeight','Bold')
        grid on
        hold on
        drawnow
    end
end %For

%%%************************************************************************
%%%************************************************************************
%%  F U N C T I O N___2
% fitting the exponential decay curve to the cavity response
% Using the optimization function "fminsearch"
% takes about 0.013sec for one fitting cycle 
function [Charge,Phase,Cav_detun] = fit_ampl(Time,c,ampl,phas,NofC,...
                                         N_Of_R,n,char_corr,fig_Num)
% prepare memory
Charge      = zeros(N_Of_R,NofC); % buffer to store charge data
Cav_detun   = zeros(N_Of_R,NofC); % buffer to store detune frequency data
Phase       = zeros(N_Of_R,NofC); % buffer to store phase data
x0=[10000, -1e-6, 2e-6]; % initial parameters of exponential fitting estimate
for k=1:NofC
    for m = (k-1)*N_Of_R+1 : (k-1)*N_Of_R+(n-1)
        [x,fval,exitflag,output] = fminsearch(@fit_exponential,x0,[],...
                                       Time(c(k):end)',ampl(c(k):end,m)');
        Charge(m-(k-1)*N_Of_R,k) = (x(1)*exp((Time(c(k)-2)-x(3))/x(2)))/char_corr(k);
        PlotGraph = get(findobj('Tag','PlotGraph'),'Value');

        if PlotGraph == 1
            figure(fig_Num)
            subplot(2,NofC,k)
            ax=axis;
            FIT =  plot(Time(c(k)-2:end),(x(1)*exp((Time(c(k)-2:end)-x(3))/x(2)))/...
                char_corr(k),'r',[Time(c(k)-2),Time(c(k)-2)],[0,1],'r');
            axis([0,5e-6,ax(3),ax(4)]);
            %set(FIT,'linewidth',2)
            drawnow
            hold on
        end % if

        start_index = c(k)+4; %first point for the phase regression
        time_for_regr = 1.0e-6; %time duration for phase linear regression
        end_index = start_index + floor(time_for_regr*25.5e6); % last point for...
        p = polyfit(Time(start_index:end_index),phas(start_index:end_index,m),1);
        Phase(m-(k-1)*N_Of_R,k) = polyval(p,Time(c(k)-2)); %extrapolate phase ...
                                               %value to beam arrival time)                                       
        Cav_detun(m-(k-1)*N_Of_R,k)  = p(1)/360; %calculate cavity detuning
        if PlotGraph == 1
            subplot(2,NofC,NofC+k)
            %p
            FIT=plot(Time(c(k)-2:end_index),p(1)*Time(c(k)-2:end_index)+p(2),...
                                        'r',[Time(c(k)-2),Time(c(k)-2)],[0,360],'r');
            %set(FIT,'linewidth',2)
            drawnow
            hold on
        end % if
    end % m
end % for k
pause(0.2) % this has to be added in order to "STOP" works
return

%%%************************************************************************
%%%************************************************************************
%%  F U N C T I O N___3
% fitting function for the exponential decay of the cavity response
% called by the "fminsearch" function
function y = fit_exponential(x,Time,ampl)
f = x(1)*exp((Time-x(3))/(x(2))) - (ampl);
y=f*f';
return