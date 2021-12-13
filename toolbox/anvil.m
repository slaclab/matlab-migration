function varargout = anvil(varargin)
% ANVIL M-file for anvil.fig
%
% Created: 24-JUL-2012
% Author: Chris Melton, SLAC AOSD Ops
%
% Anvil.m is a dumb beam reset program
% that will unlatch MPS faults when they are detected
% and use crude logic for beam loss to continue
% resetting until a number of resets have accumulated.
% At that time, Anvil.m will put in BYKIK and check for
% beam loss, regardless of other insertion devices
%
% Anvil.m IS NOT MEANT TO REPLACE MCC HAMMER
% It is a band-aid to prevent wasted operations time
% resetting nuissance trips. It will be turned off from
% the Ops LCLS Dashboard.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 25-Jul-2012 23:25:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @anvil_OpeningFcn, ...
                   'gui_OutputFcn',  @anvil_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before anvil is made visible.
function anvil_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to anvil (see VARARGIN)

% Choose default command line output for anvil
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(handles.progList,'String',' ');
broadcast('Anvil.m starting in TEST MODE - NO ACTIVE BEAM CHANGES.',handles);
lcaPut('SIOC:SYS0:ML01:AO699','1'); % 1 = running, 0 = stopped by user
curdat = datestr(floor(now));
set(handles.textDate,'String',curdat);
% UIWAIT makes anvil wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = anvil_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in toggleStart.
function toggleStart_Callback(hObject, eventdata, handles)
% hObject    handle to toggleStart (see GCBO)
Amask = get(hObject,'Value');
switch Amask
    case 1.0
       broadcast('Anvil started by user or operator',handles);
       resetcount = 0;
       msg('You know the rules, and so do I.',handles);
       set(handles.toggleStart,'BackgroundColor',[.690 .701 .381]);

       % INFINITE LOOP while certain conditions are met
       while Amask==1.0
           lcaPut('SIOC:SYS0:ML01:AO699','1'); % Tell Matlab Support PV that Anvil is ON
            totresets = lcaGet('SIOC:SYS0:ML01:AO700');
            newtot = resetcount + totresets;
            lcaPut('SIOC:SYS0:ML01:AO700',newtot);
            curdat = datestr(floor(now));
            set(handles.textDate,'String',curdat);
            set(handles.toggleStart','String','Running');

            % Check trip / no trip status of BIG RED
            bigred = lcaGet('SIOC:SYS0:ML00:CALC011.STAT',0,'String'); % 0 = ok, 4 = high / trip

            % Get stopper states and beam loss stats for logic
            %   this assumes the toroids are working.
            bcsok = lcaGet('BCS:IN20:1:BEAMPERM',0,'String');
            td11out = lcaGet('DUMP:LI21:305:TD11_PNEU',0,'String'); % 1 = allows beam (out), 0 = stops beam (in)
            im01_ = lcaGet('TORO:IN20:215:TMIT1H'); % IM01 TORO TMIT off the gun - reference for all beam losses
            imbc1I_ = lcaGet('TORO:LI21:205:TMIT1H'); % IMBC1 Input TORO TMIT to chicane BC1
            imbc2O_ = lcaGet('TORO:LI25:235:TMIT1H'); % IMBC2 Output TORO TMIT from chicane BC2
            imdl2O_ = lcaGet('TORO:LTU1:605:TMIT1H'); % IM36 Output TORO TMIT from DL2

            % Calc beam loss for logic
            DL1loss = (imbc1I_ - im01_)/imbc1I_;
            BC2loss = (imbc2O_ - imbc1I_)/imbc2O_;
            DL2loss = (imdl2O_ - imbc2O_)/imdl2O_;

            % Determine how to RESET BIG RED
            if bigred~=0&&resetcount==0&&bcsok
                lcaPut('IOC:BSY0:MP01:UNLATCHALL','1');

                % For debug mode
                % msg('I would have reset the beam here',handles);
                % fprintf('Reset count is %d \n',resetcount);

                resetcount = resetcount + 1;
                rickroll(resetcount,handles);
            elseif bigred~=0&&resetcount>0&&resetcount<4&&bcsok
                if abs(DL2loss)<.1
                    lcaPut('IOC:BSY0:MP01:UNLATCHALL','1');

                % For debug mode
                % msg('I would have reset the beam here',handles);
                % fprintf('Reset count is %d \n',resetcount);

                    resetcount = resetcount + 1;
                    rickroll(resetcount,handles);
                elseif abs(DL2loss)>=.1&&~td11out
                    broadcast('Excessive beam loss but TD11 in. Reset ok.',handles);
                    msg('TD11 is in. Gotta make you understand.',handles);
                    lcaPut('IOC:BSY0:MP01:UNLATCHALL','1');

                % For debug mode
                % msg('I would have reset the beam here',handles);
                % fprintf('Reset count is %d \n',resetcount);

                    resetcount = resetcount + 1;
                    rickroll(resetcount,handles);
                elseif abs(DL2loss)>=.1&&td11out
                    bykiknow = lcaGet('IOC:BSY0:MP01:BYKIKCTL',0,'String'); % where is BYKIK now?
                    lcaPut('IOC:BSY0:MP01:BYKIKCTL','0'); % Put BYKIK IN
                    lcaPut('IOC:BSY0:MP01:UNLATCHALL','1');
                    pause(1);
                    lcaPut('IOC:BSY0:MP01:BYKIKCTL',bykiknow); % BYKIK on whatever state it was before

                  % For debug mode
                  % msg('I would have reset the beam here',handles);

                    fprintf('Reset count is %d \n',resetcount);
                    resetcount = resetcount + 1;
                    rickroll(resetcount,handles);
                    pause(2);
                    % lcaPut('IOC:BSY0:MP01:BYKIKCTL','1'); % BYKIK OUT %
                    % turned off for A-line program
                end
            elseif bigred~=0&&resetcount>=0&&~bcsok&&bcsflatch==0
                msg('BCS tripped. Reset it!',handles);
                broadcast('BCS trip prevents Anvil from beam reset. Waiting 5 secs for reset.',handles);
                msg('Never gonna give, gonna give, give you up',handles);
                bcsflatch=1;
            elseif bigred~=0&&bcsok&&resetcount>=4
                msg('Out of resets! Inside we both know whats been going on',handles); pause(0.5);
                msg('Fix the beam! We know the game and were gonna play it.',handles);
            end

            % Check if beam recovered
            pause(1);
            bigred = lcaGet('SIOC:SYS0:ML00:CALC011.STAT',0,'String'); % 0 = ok, 4 = high / trip
            if bigred==0
                resetcount = 0;
                if bcsok
                    bcsflatch = 0;
                end
            end

            % If beam not recovered then check if Anvil still running then loop again
            Amask = get(hObject,'Value');

            % For debugging
            % msg('Still alive',handles);
            % fprintf('Reset count is %d \n',resetcount);

        end


    otherwise
        curdat = datestr(floor(now));
        set(handles.textDate,'String',curdat);
        set(handles.toggleStart','String','Stopped');
        lcaPut('SIOC:SYS0:ML01:AO699','0');
        set(handles.toggleStart,'BackgroundColor',[.526 .702 .586]);
        msg('But weve known each other for so long.',handles);
        broadcast('Anvil stopped by user or operator',handles);
end

end

% --- Executes on selection change in progList.
function progList_Callback(hObject, eventdata, handles)
% hObject    handle to progList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns progList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from progList
end

% --- Executes during object creation, after setting all properties.
function progList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to progList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% TESTED OK
function cmlog(msg) % Print global error messages to CM Log

% Store err variables in function memory
persistent err % This is the last thing we need
persistent da % Like the song...

% Initialize error instance
if(isempty(err))
    err=getLogger('anvil');  % Stutter, much?
end

% Print msg to cmLog
put2log(msg);

end

% TESTED OK
function msg(text,handles)


  ACT{2} = char(get(handles.progList,'String'));
  ACT{1} = char(text);

set(handles.progList,'String',ACT);

end

% TESTED OK
function broadcast(msgtext,handles)

fprintf([msgtext '\n']);
cmlog(msgtext);

end

function rickroll(resetcount,handles)

lcaPut('SIOC:SYS0:ML01:AO700',resetcount);

resetlyrics = {
                  'Never gonna give you up                              ',
                  'Never gonna let you down                            ',
                  'Never gonna run around and desert you   ',
                  'Never gonna make you cry                           ',
                  'Never gonna say goodbye                            ',
                  'Never gonna tell a lie and hurt you              ',
};

fullecho = [char(resetlyrics(resetcount)) datestr(rem(now,1))];
msg(fullecho,handles);

end


% --- Executes during object creation, after setting all properties.
function axesIMG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesIMG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesIMG

meltonlogo = imread('/home/physics/cmelton/images/anvil.jpg');
image(meltonlogo);
axis(axesIMG,'image');
axis off;

end


