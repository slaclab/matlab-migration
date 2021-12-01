%% Program plots the ampl. and phase of selected pulses
%  Program belongs to the group of programs selected from the LLRFgui.
%  Operator selects the signal whose pulse to check.
%  The width and the offset of the pulse can be controlled from the GUI.
%  Amplite and the phase of the pulse is plotted.
%  
%  Written:     Vojtech Pacak       2007/2008
%  Last update: 6-Mar-2008
function LLRFgui_pulse_shape(hObject, eventdata, handles)

% *****************************************

%% Updating the handles, define variables, PV's and Legend for plot title
handles=guidata(handles.output);
SIG = handles.pvNamesSel;   % selected signal from the PAD
PAD = handles.pvNamesSel_2; % selected PAD panel
width=str2double(handles.pulse_width);
% Definition of PV's
FEEDBACK{1}={'GUN:IN20:1:GN1_AMPL_FB','GUN:IN20:1:GN1_PHAS_FB'};
FEEDBACK{2}={'',''};
FEEDBACK{3}={'ACCL:IN20:300:L0A_AMPL_FB','ACCL:IN20:300:L0A_PHAS_FB'};
FEEDBACK{4}={'ACCL:IN20:400:L0B_AMPL_FB','ACCL:IN20:400:L0B_PHAS_FB'};
FEEDBACK{5}={'ACCL:LI21:1:L1S_AMPL_FB','ACCL:LI21:1:L1S_PHAS_FB'};
FEEDBACK{6}={'ACCL:LI21:180:L1X_AMPL_FB','ACCL:LI21:180:L1X_PHAS_FB'};
FEEDBACK{7}={'TCAV:IN20:490:TC0_AMPL_FB','TCAV:IN20:490:TC0_PHAS_FB'};
FEEDBACK{8}={'TCAV:LI24:800:TC3_AMPL_FB','TCAV:LI24:800:TC3_PHAS_FB'};

GUN{1}={'GUN:IN20:1:GN1_0_OFST','GUN:IN20:1:GN1_0_SIZE',...
    'GUN:IN20:1:GN1_0_S_R_WF'};
GUN{2}={'GUN:IN20:1:GN1_1_OFST','GUN:IN20:1:GN1_1_SIZE',...
    'GUN:IN20:1:GN1_1_S_R_WF'};
GUN{3}={'GUN:IN20:1:GN1_2_OFST','GUN:IN20:1:GN1_2_SIZE',...
    'GUN:IN20:1:GN1_2_S_R_WF'};
GUN{4}={'GUN:IN20:1:GN1_3_OFST','GUN:IN20:1:GN1_3_SIZE',...
    'GUN:IN20:1:GN1_3_S_R_WF'};

GUN_TUNE{1}={'GUN:IN20:1:GN2_0_OFST','GUN:IN20:1:GN2_0_SIZE',...
    'GUN:IN20:1:GN2_0_S_R_WF'};
GUN_TUNE{2}={'GUN:IN20:1:GN2_1_OFST','GUN:IN20:1:GN2_1_SIZE',...
    'GUN:IN20:1:GN2_1_S_R_WF'};
GUN_TUNE{3}={'GUN:IN20:1:GN2_2_OFST','GUN:IN20:1:GN2_2_SIZE',...
    'GUN:IN20:1:GN2_2_S_R_WF'};
GUN_TUNE{4}={'GUN:IN20:1:GN2_3_OFST','GUN:IN20:1:GN2_3_SIZE',...
    'GUN:IN20:1:GN2_3_S_R_WF'};

L0A_B{1}={'ACCL:IN20:350:L0_0_OFST','ACCL:IN20:350:L0_0_SIZE',...
    'ACCL:IN20:350:L0_0_S_R_WF'};
L0A_B{2}={'ACCL:IN20:350:L0_1_OFST','ACCL:IN20:350:L0_1_SIZE',...
    'ACCL:IN20:350:L0_1_S_R_WF'};
L0A_B{3}={'ACCL:IN20:350:L0_2_OFST','ACCL:IN20:350:L0_2_SIZE',...
    'ACCL:IN20:350:L0_2_S_R_WF'};
L0A_B{4}={'ACCL:IN20:350:L0_3_OFST','ACCL:IN20:350:L0_3_SIZE',...
    'ACCL:IN20:350:L0_3_S_R_WF'};

L1S{1}={'ACCL:LI21:1:L1S_0_OFST','ACCL:LI21:1:L1S_0_SIZE',...
    'ACCL:LI21:1:L1S_0_S_R_WF'};
L1S{2}={'ACCL:LI21:1:L1S_1_OFST','ACCL:LI21:1:L1S_1_SIZE',...
    'ACCL:LI21:1:L1S_1_S_R_WF'};
L1S{3}={'ACCL:LI21:1:L1S_2_OFST','ACCL:LI21:1:L1S_2_SIZE',...
    'ACCL:LI21:1:L1S_2_S_R_WF'};
L1S{4}={'ACCL:LI21:1:L1S_3_OFST','ACCL:LI21:1:L1S_3_SIZE',...
    'ACCL:LI21:1:L1S_3_S_R_WF'};

L1X{1}={'ACCL:LI21:180:L1X_0_OFST','ACCL:LI21:180:L1X_0_SIZE',...
    'ACCL:LI21:180:L1X_0_S_R_WF'};
L1X{2}={'ACCL:LI21:180:L1X_1_OFST','ACCL:LI21:180:L1X_1_SIZE',...
    'ACCL:LI21:180:L1X_1_S_R_WF'};
L1X{3}={'ACCL:LI21:180:L1X_2_OFST','ACCL:LI21:180:L1X_2_SIZE',...
    'ACCL:LI21:180:L1X_2_S_R_WF'};
L1X{4}={'ACCL:LI21:180:L1X_3_OFST','ACCL:LI21:180:L1X_3_SIZE',...
    'ACCL:LI21:180:L1X_3_S_R_WF'};

TC0{1}={'TCAV:IN20:490:TC0_0_OFST','TCAV:IN20:490:TC0_0_SIZE',...
    'TCAV:IN20:490:TC0_0_S_R_WF'};
TC0{2}={'TCAV:IN20:490:TC0_1_OFST','TCAV:IN20:490:TC0_1_SIZE',...
    'TCAV:IN20:490:TC0_1_S_R_WF'};
TC0{3}={'TCAV:IN20:490:TC0_2_OFST','TCAV:IN20:490:TC0_2_SIZE',...
    'TCAV:IN20:490:TC0_2_S_R_WF'};
TC0{4}={'TCAV:IN20:490:TC0_3_OFST','TCAV:IN20:490:TC0_3_SIZE',...
    'TCAV:IN20:490:TC0_3_S_R_WF'};

TC3{1}={'TCAV:LI24:800:TC3_0_OFST','TCAV:LI24:800:TC3_0_SIZE',...
    'TCAV:LI24:800:TC3_0_S_R_WF'};
TC3{2}={'TCAV:LI24:800:TC3_1_OFST','TCAV:LI24:800:TC3_1_SIZE',...
    'TCAV:LI24:800:TC3_1_S_R_WF'};
TC3{3}={'TCAV:LI24:800:TC3_2_OFST','TCAV:LI24:800:TC3_2_SIZE',...
    'TCAV:LI24:800:TC3_2_S_R_WF'};
TC3{4}={'TCAV:LI24:800:TC3_3_OFST','TCAV:LI24:800:TC3_3_SIZE',...
    'TCAV:LI24:800:TC3_3_S_R_WF'};

%prepare legend for title
Legend_1{1}={'Gun, '};
Legend_1{2}={'Gun Tune, '};
Legend_1{3}={'L0, '};
Legend_1{4}={'L1S-21, '};
Legend_1{5}={'L1X, '};
Legend_1{6}={'T-CAV 0, '};
Legend_1{7}={'T-CAV 3, '};

Legend_2{1}={'Cell 1A','Cell 1B','Cell 2A','Cell 2B'};
Legend_2{2}={'Forward RF','Reflected RF','Spare 1','Spare 2'};
Legend_2{3}={'L0A In','L0A Out','L0B In','L0B Out'};
Legend_2{4}={'1B In','1B Out','1C Out','1D Out'};
Legend_2{5}={'In','Out','Spare 1','Spare 2'};
Legend_2{6}={'In','Out','Spare 1','Spare 2'};
Legend_2{7}={'In','Out','Spare 1','S24-2856MHz'};

%correct formatting for the title:... 
%"title([Legend_1{3}{1} Legend_2{3}{3}])"

%% Create the "PV Structure" from all PV's
TOTAL_PV={GUN,GUN_TUNE,L0A_B,L1S,L1X,TC0,TC3};
% InitialOffset = TOTAL_PV{PAD}{SIG}(1);
% InitialSize   = TOTAL_PV{PAD}{SIG}(2);
% WaveForm      = TOTAL_PV{PAD}{SIG}(3)

%% Turn off the local feedback with the exception of GUN_TUNE PAD
switch PAD
    case 1
        PV_FDBK=FEEDBACK{PAD}(:)
        lcaPut(PV_FDBK,{'OFF';'OFF'});
    case {4 5 6 7}
        PV_FDBK=FEEDBACK{PAD+1}(:)
        lcaPut(PV_FDBK,{'OFF';'OFF'});
    case  3
        if SIG < 3
            PV_FDBK=FEEDBACK{PAD}(:)
            lcaPut(PV_FDBK,{'OFF';'OFF'});
        else
            PV_FDBK=FEEDBACK{PAD+1}(:)
            lcaPut(PV_FDBK,{'OFF';'OFF'});
        end
end

%% Check and set the condition before acquiring the waveform
initial_offset = lcaGet(TOTAL_PV{PAD}{SIG}(1));
initial_size   = lcaGet(TOTAL_PV{PAD}{SIG}(2));

%change offset setting to 0 and width to the selected width from GUI
lcaPut(TOTAL_PV{PAD}{SIG}(1),0);
lcaPut(TOTAL_PV{PAD}{SIG}(2),width);

pause(1);  %wait 1 second to change the size of waveform window

%% Acquire the waveform
M = lcaGet(TOTAL_PV{PAD}{SIG}(3));
M=M'; % make a column array

%% Return the setup to the orignal and re-activate the local feedback
lcaPut(TOTAL_PV{PAD}{SIG}(1),initial_offset)
lcaPut(TOTAL_PV{PAD}{SIG}(2),initial_size)
% activate the feedback 
if PAD ~= 2
lcaPut(PV_FDBK,{'ON';'ON'});
end

%% Extract the I and Q from the waveform
I_Q_gun_cell=zeros(fix(width/4),1); %prepare space for the matrix

k=1;
for i=1:4:4*fix(width/4)
    I=(M(i,1)-M(i+2,1))/2;
    Q=(M(i+1,1)-M(i+3,1))/2;
    I_Q_gun_cell(k,1)=I+j*Q;
    k=k+1;
end

%% Create the time array, sample frequency 25.5MHz
time_step = 1/25.5e6;  %
Time = 0:time_step:(fix(width/4)-1)*time_step;
% %remove the DC
% A=mean(I_Q_gun_cell);
% B=ones(l_2/4,1);
% C=B*A;
% I_Q_L0A_B_mod=I_Q_L0A_B-C;

%% Plot amplitude and phase
handles.exportFig = figure(1);
clf
subplot(2,1,1)
plot(Time,abs(I_Q_gun_cell(:,1)),'r.-');
title([Legend_1{PAD}{1},Legend_2{PAD}{SIG},', Amplitude'])
xlabel('time [s]')
ylabel('amplitude, [a.u.]')
grid on
subplot(2,1,2)
plot(Time,180*angle(I_Q_gun_cell(:,1))/pi,'b.-');
title([Legend_1{PAD}{1},Legend_2{PAD}{SIG},', Phase'])
xlabel('time [s]')
ylabel('phase, [deg]')
grid on

guidata(handles.output,handles); %update handles in the GUI