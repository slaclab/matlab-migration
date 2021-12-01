function LLRFgui_phase_rotation(hObject, eventdata, handles)
% program rotates the phase of reference MDL PAC

%update handles
handles=guidata(handles.output);

% first select the correct PAC
pv = handles.pvNamesSel;
switch pv
    case 1
        pvNames = {
            'LLRF:IN20:RH:MDL_I_ADJUST'
            'LLRF:IN20:RH:MDL_Q_ADJUST'
            }
        tag='text11';
        counter = str2double(get(findobj('Tag','text11'),'String'));
    case 2
        pvNames = {
            'LLRF:IN20:RH:LCL_I_ADJUST'
            'LLRF:IN20:RH:LCL_Q_ADJUST'
            }
        tag='text12';
        counter = str2double(get(findobj('Tag','text12'),'String'));
    case 3
        pvNames = {
            'LLRF:IN20:RH:CLK_I_ADJUST'
            'LLRF:IN20:RH:CLK_Q_ADJUST'
            }
        tag='text13';
        counter = str2double(get(findobj('Tag','text13'),'String'));
    case 4
        pvNames = {
            'LASR:IN20:1:LSR_I_ADJUST'
            'LASR:IN20:1:LSR_Q_ADJUST'
            }
        tag='text14';
        counter = str2double(get(findobj('Tag','text14'),'String'));
    case 5
        pvNames = {
            'LLRF:IN20:RH:RFR_I_ADJUST'
            'LLRF:IN20:RH:RFR_Q_ADJUST'
            }
        tag='text15';
        counter = str2double(get(findobj('Tag','text15'),'String'))
    case 6
        pvNames = {
            'LLRF:LI24:0:REF_I_ADJUST'
            'LLRF:LI24:0:REF_Q_ADJUST'
            }
        tag='text21';
        counter = str2double(get(findobj('Tag','text21'),'String'))
end
step = str2double(handles.phase_step);
rotation = str2double(handles.full_rotation);
sense_rot = handles.rotation_direction;

%Initial_I_Q = [1,0]; %[sqrt(3),sqrt(5)];
Initial_I_Q = lcaGet(pvNames);

%calculate the initial amplitude and phase
Ampl=sqrt(Initial_I_Q(1)^2+Initial_I_Q(2)^2);
Phase= atan2(Initial_I_Q(2),Initial_I_Q(1))*180/pi;
%activate the polar plot graph on GUI
[x1,y1]=pol2cart(Phase*pi/180,1);
set(gca,'FontSize',1);

%Bring the polar plot back on to GUI
c=get(gcf,'children');
t=get(c,'type');
index=find(strcmp('axes',t));
set(c(index),'position',handles.graph_position);

%plot initial phase vector
hold off
f=compass(x1,y1,'r');
set(f,'LineWidth',3);
hold on




%define Phase array [in degrees] from selected handles
if rotation < 1 %%Setup the rotation history counter
    Phase_step=step:step:rotation*360;
    multiplic=rotation;
else
    Phase_step=step:step:360;
    multiplic=1;
end
%multiplic = 1; % adding or subtracting the finished rotations to the counter
if sense_rot == 0
else
    Phase_step = -Phase_step;
    multiplic = -multiplic;
end

%Modify Phase Array by the initial phase
Phase = Phase+Phase_step; % in degrees
Phase_rad = Phase*pi/180; % in radians
[x,y]=pol2cart(Phase_rad,1); % coordinates to plot rotating arrow

%Express new phase array in I and Q (as an imaginary number)
New_phase = Ampl*exp(i*pi*Phase/180);


%Rotate the phase
numofrot=0;
set(findobj('Tag','text5'),'String',num2str(numofrot))
incr=ceil(length(Phase_step));
for r=1:ceil(rotation) %%total number of rotation
    for k=1:length(New_phase) %%  single full rotation
        lcaPut(pvNames,[real(New_phase(k));imag(New_phase(k))]);
        if mod(k,incr)==0
            if rotation <1
                set(findobj('Tag','text5'),'String',num2str(rotation))
                numofrot=1;
            else
                numofrot=numofrot+1;
                set(findobj('Tag','text5'),'String',num2str(numofrot))
            end
        end

        pause(0.05)
        f=  compass(x(k),y(k));
        set(f,'LineWidth',1);
        pause(0.01)
    end %% for single full rotation

    %update handles to check for "STOP" button
    handles=guidata(handles.output);
    %exit from rotation at the end of nearest completed 360
    if handles.Return
        break %%exit at the end of next finished rotation
    end
    if rotation ~= 1 & r*k ~= ceil(rotation)*length(New_phase)
        hold off
        f=compass(x1,y1,'r');
        set(f,'LineWidth',3);
        hold on
    end
end %%for total number of rotation
%Update the counter
counter = counter + multiplic*numofrot;
set(findobj('Tag',tag),'String',num2str(counter))
%Update handles in the GUI - STOP button (set handles.Return = 0)
handles.Return = 0;
h1 = findobj('Tag','start_program');
set(h1,'string','START');
guidata(handles.output,handles);
%*****************

fprintf(1,['Phase rotated by ',num2str(r*Phase_step(k)),' degree\n'])
set(f,'LineStyle','-','color','r','LineWidth',3)
