%% Program plots the ampl. and phase of selected pulses waveforms.
%  Program belongs to the group of programs selected from the KLYSTRONgui.
%  Operator selects the signal whose pulse to check.
%  The width and the offset of the pulse can be controlled from the GUI.
%  Amplite and the phase of the pulse is plotted.
%
%  Written:     Vojtech Pacak       2007/2008
%  Last update: 21-Mar-2008
function KLYSTRONgui_pulse_shape(hObject, eventdata, handles)

% *****************************************

%% Updating the handles, define variables, PV's and Legend for plot title
%  Get selected Klystron, Signal and Width from the GUI
KLY = handles.klystron; %selected klystron
SIG = handles.signal; % selected signal from the PAD
WIDTH=str2double(handles.width);

%% Definition of PV's
GUN{1}={'KLYS:LI20:K6:GUN_0_OFST','KLYS:LI20:K6:GUN_0_SIZE',...
    'KLYS:LI20:K6:GUN_0_S_R_WF'};
GUN{2}={'KLYS:LI20:K6:GUN_1_OFST','KLYS:LI20:K6:GUN_1_SIZE',...
    'KLYS:LI20:K6:GUN_1_S_R_WF'};
GUN{3}={'KLYS:LI20:K6:GUN_2_OFST','KLYS:LI20:K6:GUN_2_SIZE',...
    'KLYS:LI20:K6:GUN_2_S_R_WF'};
GUN{4}={'KLYS:LI20:K6:GUN_3_OFST','KLYS:LI20:K6:GUN_3_SIZE',...
    'KLYS:LI20:K6:GUN_3_S_R_WF'};

L0A{1}={'KLYS:LI20:K7:L0A_0_OFST','KLYS:LI20:K7:L0A_0_SIZE',...
    'KLYS:LI20:K7:L0A_0_S_R_WF'};
L0A{2}={'KLYS:LI20:K7:L0A_1_OFST','KLYS:LI20:K7:L0A_1_SIZE',...
    'KLYS:LI20:K7:L0A_1_S_R_WF'};
L0A{3}={'KLYS:LI20:K7:L0A_2_OFST','KLYS:LI20:K7:L0A_2_SIZE',...
    'KLYS:LI20:K7:L0A_2_S_R_WF'};
L0A{4}={'KLYS:LI20:K7:L0A_3_OFST','KLYS:LI20:K7:L0A_3_SIZE',...
    'KLYS:LI20:K7:L0A_3_S_R_WF'};

L0B{1}={'KLYS:LI20:K8:L0B_0_OFST','KLYS:LI20:K8:L0B_0_SIZE',...
    'KLYS:LI20:K8:L0B_0_S_R_WF'};
L0B{2}={'KLYS:LI20:K8:L0B_1_OFST','KLYS:LI20:K8:L0B_1_SIZE',...
    'KLYS:LI20:K8:L0B_1_S_R_WF'};
L0B{3}={'KLYS:LI20:K8:L0B_2_OFST','KLYS:LI20:K8:L0B_2_SIZE',...
    'KLYS:LI20:K8:L0B_2_S_R_WF'};
L0B{4}={'KLYS:LI20:K8:L0B_3_OFST','KLYS:LI20:K8:L0B_3_SIZE',...
    'KLYS:LI20:K8:L0B_3_S_R_WF'};

TC0{1}={'KLYS:LI20:K5:TC0_0_OFST','KLYS:LI20:K5:TC0_0_SIZE',...
    'KLYS:LI20:K5:TC0_0_S_R_WF'};
TC0{2}={'KLYS:LI20:K5:TC0_1_OFST','KLYS:LI20:K5:TC0_1_SIZE',...
    'KLYS:LI20:K5:TC0_1_S_R_WF'};
TC0{3}={'KLYS:LI20:K5:TC0_2_OFST','KLYS:LI20:K5:TC0_2_SIZE',...
    'KLYS:LI20:K5:TC0_2_S_R_WF'};
TC0{4}={'KLYS:LI20:K5:TC0_3_OFST','KLYS:LI20:K5:TC0_3_SIZE',...
    'KLYS:LI20:K5:TC0_3_S_R_WF'};

L1S{1}={'KLYS:LI21:K1:L1S_0_OFST','KLYS:LI21:K1:L1S_0_SIZE',...
    'KLYS:LI21:K1:L1S_0_S_R_WF'};
L1S{2}={'KLYS:LI21:K1:L1S_1_OFST','KLYS:LI21:K1:L1S_1_SIZE',...
    'KLYS:LI21:K1:L1S_1_S_R_WF'};
L1S{3}={'KLYS:LI21:K1:L1S_2_OFST','KLYS:LI21:K1:L1S_2_SIZE',...
    'KLYS:LI21:K1:L1S_2_S_R_WF'};
L1S{4}={'KLYS:LI21:K1:L1S_3_OFST','KLYS:LI21:K1:L1S_3_SIZE',...
    'KLYS:LI21:K1:L1S_3_S_R_WF'};

L1X{1}={'KLYS:LI21:K2:L1X_0_OFST','KLYS:LI21:K2:L1X_0_SIZE',...
    'KLYS:LI21:K2:L1X_0_S_R_WF'};
L1X{2}={'KLYS:LI21:K2:L1X_1_OFST','KLYS:LI21:K2:L1X_1_SIZE',...
    'KLYS:LI21:K2:L1X_1_S_R_WF'};
L1X{3}={'KLYS:LI21:K2:L1X_2_OFST','KLYS:LI21:K2:L1X_2_SIZE',...
    'KLYS:LI21:K2:L1X_2_S_R_WF'};
L1X{4}={'KLYS:LI21:K2:L1X_3_OFST','KLYS:LI21:K2:L1X_3_SIZE',...
    'KLYS:LI21:K2:L1X_3_S_R_WF'};

TC3{1}={'KLYS:LI24:K8:TC3_0_OFST','KLYS:LI24:K8:TC3_0_SIZE',...
    'KLYS:LI24:K8:TC3_0_S_R_WF'};
TC3{2}={'KLYS:LI24:K8:TC3_1_OFST','KLYS:LI24:K8:TC3_1_SIZE',...
    'KLYS:LI24:K8:TC3_1_S_R_WF'};
TC3{3}={'KLYS:LI24:K8:TC3_2_OFST','KLYS:LI24:K8:TC3_2_SIZE',...
    'KLYS:LI24:K8:TC3_2_S_R_WF'};
TC3{4}={'KLYS:LI24:K8:TC3_3_OFST','KLYS:LI24:K8:TC3_3_SIZE',...
    'KLYS:LI24:K8:TC3_3_S_R_WF'};

%prepare legend for title
Legend_1{1}={'Gun, '};
Legend_1{2}={'L0A, '};
Legend_1{3}={'L0B, '};
Legend_1{4}={'TC0, '};
Legend_1{5}={'L1S, '};
Legend_1{6}={'L1X, '};
Legend_1{7}={'TC3, '};

Legend_2{1}={'PAC-Out','KLY-Drive','KLY-Beam-Volt','KLY-Forw-Power'};
% Legend_2{2}={'Forward RF','Reflected RF','Spare 1','Spare 2'};
% Legend_2{3}={'L0A In','L0A Out','L0B In','L0B Out'};
% Legend_2{4}={'1B In','1B Out','1C Out','1D Out'};
% Legend_2{5}={'In','Out','Spare 1','Spare 2'};
% Legend_2{6}={'In','Out','Spare 1','Spare 2'};
% Legend_2{7}={'In','Out','Spare 1','S24-2856MHz'};

% return
%% Create the "PV Structure" from all PV's
TOTAL_PV={GUN,L0A,L0B,TC0,L1S,L1X,TC3};

%% Examples of the correct formatting of the PV's and of the Titles
% PV's:
% InitialOffset = TOTAL_PV{KLY}{SIG}(1);
% InitialSize   = TOTAL_PV{KLY}{SIG}(2);
% WaveForm      = TOTAL_PV{KLY}{SIG}(3)

% Title:
%"title([Legend_1{KLY}{1} Legend_2{1}{SIG}])"

%% Check and set the condition before acquiring the waveform
initial_offset = lcaGet(TOTAL_PV{KLY}{SIG}(1));
initial_size   = lcaGet(TOTAL_PV{KLY}{SIG}(2));

% %change offset setting to 0 and width to the selected width from GUI
% lcaPut(TOTAL_PV{KLY}{SIG}(1),0);
lcaPut(TOTAL_PV{KLY}{SIG}(2),WIDTH);

pause(1);  %wait 1 second to change the size of waveform window

%% Acquire the waveform
M = lcaGet(TOTAL_PV{KLY}{SIG}(3));
M=M'; % make a column array

% %% Return the original offset and width
% lcaPut(TOTAL_PV{KLY}{SIG}(1),initial_offset)
lcaPut(TOTAL_PV{KLY}{SIG}(2),initial_size)

%% Check if the signal is Beam Voltage, SIG = 3
if SIG ~= 3

    %% Extract the I and Q from the waveform
    I_Q_gun_cell=zeros(fix(WIDTH/4),1); %prepare space for the matrix

    k=1;
    for i=1:4:4*fix(WIDTH/4)
        I=(M(i,1)-M(i+2,1))/2;
        Q=(M(i+1,1)-M(i+3,1))/2;
        I_Q_gun_cell(k,1)=I+j*Q;
        k=k+1;
    end

    %% Create the time array, sampling frequency 25.5MHz
    time_step = 1/25.5e6;  %
    Time = 0:time_step:(fix(WIDTH/4)-1)*time_step;
    % %remove the DC
    % A=mean(I_Q_gun_cell);
    % B=ones(l_2/4,1);
    % C=B*A;
    % I_Q_L0A_B_mod=I_Q_L0A_B-C;

    %% Plot amplitude and phase
    handles.exportFig = figure;
    clf
    subplot(2,1,1)
    plot(Time,abs(I_Q_gun_cell(:,1)),'r.-');
    title([Legend_1{KLY}{1},Legend_2{1}{SIG},', Amplitude'])
    xlabel('time [s]')
    ylabel('amplitude, [a.u.]')
    grid on
    subplot(2,1,2)
    plot(Time,180*angle(I_Q_gun_cell(:,1))/pi,'b.-');
    title([Legend_1{KLY}{1},Legend_2{1}{SIG},', Phase'])
    xlabel('time [s]')
    ylabel('phase, [deg]')
    grid on
else
    %% Create the time array, sampling frequency 25.5MHz
    time_step = 1/102e6;  %
    Time = 0:time_step:(fix(WIDTH)-1)*time_step;
    handles.exportFig = figure;
    clf
    plot(Time,M,'r.-');
    title([Legend_1{KLY}{1},Legend_2{1}{SIG},', Kly-Beam-Voltage'])
    xlabel('time [s]')
    ylabel('voltage, [a.u.]')
    grid on
end

guidata(handles.output,handles); %update handles in the GUI