function varargout = schottky_scan_NLCTA(varargin)
% SCHOTTKY_SCAN_NLCTA M-file for schottky_scan_NLCTA.fig
%      SCHOTTKY_SCAN_NLCTA, by itself, creates a new SCHOTTKY_SCAN_NLCTA or raises the existing
%      singleton*.
%
%      H = SCHOTTKY_SCAN_NLCTA returns the handle to a new SCHOTTKY_SCAN_NLCTA or the handle to
%      the existing singleton*.
%
%      SCHOTTKY_SCAN_NLCTA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCHOTTKY_SCAN_NLCTA.M with the given input arguments.
%
%      SCHOTTKY_SCAN_NLCTA('Property','Value',...) creates a new SCHOTTKY_SCAN_NLCTA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before schottky_scan_NLCTA_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to schottky_scan_NLCTA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help schottky_scan_NLCTA

% Last Modified by GUIDE v2.5 01-Jun-2011 14:02:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @schottky_scan_NLCTA_OpeningFcn, ...
                   'gui_OutputFcn',  @schottky_scan_NLCTA_OutputFcn, ...
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


% --- Executes just before schottky_scan_NLCTA is made visible.
  function schottky_scan_NLCTA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to schottky_scan_NLCTA (see VARARGIN)

% Choose default command line output for schottky_scan_NLCTA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes schottky_scan_NLCTA wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = schottky_scan_NLCTA_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function handles = appInit(hObject, handles)
    guidata(hObject,handles);

% --- Executes on button press in acquireStart.
    function acquireStart_Callback(hObject, eventdata, handles)

        disp('NLCTA schottky starting');

        max_phase_change    = 10;       % maximum phase change before warning [degS]
        min_initial_charge  = 0.015;    % at least this much charge to start [nC]
        phase_step_big      = 5;        % degrees S band (set >0 Dec. 18, '07 - was <0)
        phase_step_small    = 1.0;      % degrees S band (set >0 Dec. 18, '0 - was <0)
        phase_steps         = 30;       % max number of big phase steps
        phase_steps2        = 20;   	% max number of small phase steps
        delay0              = 5;        % delay time before first big or small step [sec]
        delay1              = 2;        % time delay between big steps [sec]
        delay2              = 1;        % time delay between small steps [sec]

        phase_pv    = 'AMPL:TA02:121';          % laser phase feedback setpoint [degS]
        lshut_pv = 'ESB:BO:2124-7:BIT1';        % laser shutter (1=IN,0=OUT)
        fc_pv = 'TA01:MISC:671:FARC0340';       % Faraday cup PV (1=IN,2=OUT)

        navg=str2int(get(handles.nAvg,'String'));
        initial_phase_shift=str2double(get(handles.initPhaseShift,'String'));
        phase_offset = str2double(get(handles.phaseOffset,'String'));

        initial_fc = lcaGet(fc_pv);
        initial_phase  = lcaGet(phase_pv);
        if initial_fc == 2 % Faraday cup was out
            lcaPut(fc_pv, 1);
        end

        % laser_energy_pv = 'LASR:IN20:196:PWR';
        %
        % charge_feedback_pv = 'FBCK:BCI0:1:ENABLE';
        % qe_pv = 'SIOC:SYS0:ML00:AO937';

        % lcaPut([qe_pv, '.DESC'], 'Schottky peak QE');
        % lcaPut([qe_pv, '.EGU'], 'PPB');

        % last_q = lcaGet(charge_feedback_pv);
        % lcaPut(charge_feedback_pv, 0); % disables charge scanning feedback
        % pause(1); % wait for response

        setok = 0;

        disp('Getting initial conditions...');

        lcaPut(lshut_pv,1); %block laser
        pause (0.2);
        [vb, wform]=measureTEKSCOPE3(navg); %acquire bckg
        lcaPut(lshut_pv,0); %unblock laser
        pause (0.2);

        charge=measureNLCTAcharge(navg,vb);

        disp(['Initial charge = ', num2str(charge)]);
        if charge < min_initial_charge
            errordlg('Charge too low, aborting.','INSUFFICIENT CHARGE');
            if initial_fc == 2 % Faraday cup was out
                lcaPut(fc_pv, initial_fc);
            end
            result_phase = initial_phase;
            control_phaseSet(phase_pv,result_phase);% restore phase
            %  lcaPut(phase_pv, result_phase);
            %  lcaPut(charge_feedback_pv, last_q);
            return;
        end

        phase  = zeros(phase_steps,1);  % phase setting [degS]
        phaseR = zeros(phase_steps,1);  % phase readback [degS]
        c  = zeros(phase_steps,1);
        dc = zeros(phase_steps,1);
        % lasengy = zeros(phase_steps,1);
%         tagstr = ['handles.' tag];

        disp('Starting big steps...');

        for j = 1:phase_steps
            str = sprintf('big-step:%3.0f...',j);
            disp(str)
            phase(j) = initial_phase + j*phase_step_big + initial_phase_shift; % new phase
            %   control_phaseSet('LASER',phase(j));
            %     lcaPut(phase_pv, phase(j));           % set new phase
            control_phaseSet(phase_pv,phase(j));%  set new phase
            if j == 1
                pause(delay0);
            else
                pause(delay1);
            end

            phaseR(j)  = pvaGet([phase_pv ':VDES']);        % read phase [degS]
            %     lasengy(j) = lcaGet(laser_energy_pv);
            [c(j), dc(j)]=measureNLCTAcharge(navg,vb);
            %     [X,Y,T,dX,dY,dT,iok] = read_BPMs({bpm_pv},navg,rate);
            %     c(j)  = T*1.602E-10;                  % mean charge [nC]
            %     dc(j) = dT*1.602e-10;                 % std charge [nC]
        end

        jlast = j;
        if jlast <=3
            errordlg('Missed Schottky peak on first phase steps - try full range scan - quitting','BAD SCAN');
            if initial_fc == 2 % Faraday cup was out
                lcaPut(fc_pv, initial_fc);
            end
            result_phase = initial_phase;
            %  control_phaseSet('LASER',result_phase);
            %  lcaPut(phase_pv, result_phase);
            control_phaseSet(phase_pv,result_phase);% restore phase
            %  lcaPut(charge_feedback_pv, last_q);
            %  eDefRelease(eDefNumber);
            return       % quit
        end

        %start_scan = phase(jlast-2) - phase_step_small; % phase to start fine scan at
        start_scan = phase(jlast-1) - phase_step_small; % phase to start fine scan at (try backing up less - 11/23/08 - PE)

        % Start fine scan around zero-crossing phase...
        ph2  = zeros(phase_steps2, 1);  % phase setting [degS]
        ph2R = zeros(phase_steps2, 1);  % phase readback [degS]
        ch2  = zeros(phase_steps2, 1);
        dch2 = zeros(phase_steps2, 1);
        disp('Starting small steps...');

        % restore charge attn setting back to intial value (high sensitivity) for Schottky scan small steps
        % lcaPut(handles.BPM_attn_pv,handles.BPM_attn);

        for j = 1:phase_steps2
            str = sprintf('small-step:%3.0f...',j)';
            disp(str)
            ph2(j) = start_scan + (j-1)*phase_step_small;
            %   control_phaseSet('LASER',ph2(j));
            %     lcaPut(phase_pv, ph2(j));
            control_phaseSet(phase_pv,ph2(j));% set new phase
            if j == 1
                pause(delay0);
            else
                pause(delay2);
            end
            %  acqTime = eDefAcq(eDefNumber, timeout);
            %  tmp = lcaGet({[bpm_pv, ':TMIT', num2str(eDefNumber)]; [bpm_pv, ...
            %                ':TMIT', num2str(eDefNumber), '.H']});
            %  ch2(j)  = tmp(1)*1.602E-10;       % mean charge [nC]
            %  dch2(j) = tmp(2)*1.602e-10;       % std charge [nC]
            ph2R(j)  = aidaget([phase_pv ':VDES']);        % read phase [degS]
            %     ph2R(j) = lcaGet(phase_pv);       % read phase [degS]
            [ch2(j), dch2(j)]=measureNLCTAcharge(navg,vb);
            %     [X,Y,T,dX,dY,dT,iok] = read_BPMs({bpm_pv},navg,rate);
            %     ch2(j)  = T*1.602E-10;                % mean charge [nC]
            %     dch2(j) = dT*1.602e-10;               % std charge [nC]

            if j==2                                 % insufficient data on small-steps
                errordlg('Not enough small steps to find zero-crossing phase - try again.','INSUFFICIENT DATA');
                if initial_fc == 2 % Faraday cup was out
                    lcaPut(fc_pv, initial_fc);
                end
                result_phase = initial_phase;
                %             control_phaseSet('LASER',result_phase);
                %      lcaPut(phase_pv, result_phase);
                aidaset([phase_pv ':VDES'], result_phase); % restore phase
                %             lcaPut(charge_feedback_pv, last_q);
                %  eDefRelease(eDefNumber);
                return
            end
            %    phfit  = [ph2R(1:(j-1));  phaseR((jlast-2):(jlast-1))];
            %    chfit  = [ ch2(1:(j-1));       c((jlast-2):(jlast-1))];
            %    dchfit = [dch2(1:(j-1));      dc((jlast-2):(jlast-1))];
            phfit  = [ph2R(1:(j-1));  phaseR((jlast-1):(jlast-1))]; % remove one "big-step" point from fit
            chfit  = [ ch2(1:(j-1));       c((jlast-1):(jlast-1))]; % remove one "big-step" point from fit
            dchfit = [dch2(1:(j-1));      dc((jlast-1):(jlast-1))]; % remove one "big-step" point from fit
            i0 = find(dchfit==0);
            if length(i0)>0
                dchfit(i0) = chfit(i0)/10;
            end
            [q,dq,xf,yf] = plot_polyfit(phfit,chfit,dchfit,1,' ',' ',' ',' ',1);    % linear fit of tail end
            phase0 = -q(1)/q(2);                                    % solve zero-crossing phase with linear solution
            new_phase = phase0 + phase_offset;
            break
        end


        figure(100);
        plot_bars(ph2R(1:j),ch2(1:j),dch2(1:j),'or','r');
        hold on;
        plot_bars(phaseR(1:(jlast-1)),c(1:(jlast-1)),dc(1:(jlast-1)),'dr','b');
        plot(xf,yf,'g-',phase0,0,'gs')
        ver_line(new_phase,'b--')
        ver_line(initial_phase,'k:')
        vv = axis;
        ylim([0 vv(4)]);
        hold off;
        xlabel('Laser Phase (degS)')
        ylabel('Bunch Charge (nC)')
        enhance_plot('times',14,2,5)

        if j <=1
            errordlg('Not enough small steps to determine RF phase - try again.','INSUFFICIENT DATA');
            if initial_fc == 2 % Faraday cup was out
                lcaPut(fc_pv, initial_fc);
            end
            result_phase = initial_phase;
            %   control_phaseSet('LASER',result_phase);
            control_phaseSet(phase_pv,result_phase);% restore phase
            %  lcaPut(phase_pv, result_phase);
            %   lcaPut(charge_feedback_pv, last_q);
            %  eDefRelease(eDefNumber);
            return;
        end

        if abs(new_phase - initial_phase) < max_phase_change
            setok = 1;
        else
            txt = [datestr(now), '; {\it\phi}(old)=', sprintf('%5.2f',initial_phase) '\circ, {\it\phi}(calc)=', ...
                sprintf('%5.2f',new_phase), '\circ, {\it\phi}(set)=?'];
            title(txt);
            str = sprintf('Phase change is large (%5.1f deg).  Do you want to accept it?',new_phase - initial_phase);
            yn = questdlg(str,'LARGE PHASE CHANGE');
            if strcmp(yn,'Yes')
                setok = 1;
            else
                setok = 0;
            end
        end

        if setok
            if handles.nochanges               % if all net changes switched OFF on GUI panel
                result_phase = initial_phase;
                disp('Phase is valid but "No changes" toggle is selected on GUI panel');
            else
                result_phase = new_phase;
                disp('Phase is valid - setting');
            end
        else
            result_phase = initial_phase;    % kludge for now
            disp('Phase invalid - no change');
        end

        txt = [datestr(now), '; {\it\phi}(old)=', sprintf('%5.2f',initial_phase) '\circ, {\it\phi}(calc)=', ...
            sprintf('%5.2f',new_phase), '\circ, {\it\phi}(set)=', sprintf('%5.2f',result_phase) '\circ'];
        title(txt);
        hold off

        % control_phaseSet('LASER',result_phase);
        % lcaPut(phase_pv, result_phase);
        control_phaseSet(phase_pv,result_phase);% set phase
        disp(['new phase = ', num2str(new_phase)]);
        if initial_fc == 2 % Faraday cup was out
            lcaPut(fc_pv, initial_fc);
        end
        % lcaPut(charge_feedback_pv, last_q); % charge scanning feedback picks up old value

        % j=100;
        % while j && ~any(lcaGetSmart(strcat('MPS:IN20:200:MSHT1_',{'IN';'OUT'},'_MPS'),0,'double'))
        %     j=j-1;pause(.1);
        % end

        % % now calculate peak charge
        % % phase(j) is phase during big steps scan
        % % c(j) is charge during big steps scan
        % laser_ev = 4.86;            % electron volts laser energy
        % electrons = c/1.602e-10;    % convert back to num electrons
        % energy = lasengy*1e-6;      % 100% on power meter (*100 = Dec. 12, '07)
        % photons = energy/(laser_ev*1.602e-19);
        % qe = electrons./photons;    % qe at each point.
        % [qm, nm] = max(qe);
        %
        % if nm < 2
        % %  eDefRelease(eDefNumber);
        %   return;
        % elseif nm > phase_steps -1
        % %  eDefRelease(eDefNumber);
        %   return;
        % end
        % tmpy = qe((nm-1):(nm+1))';
        % tmpx = [nm-1, nm, nm+1];
        %
        % P = polyfit(tmpx, tmpy, 2); % fit to peak
        % nmax = -P(2)/(2*P(1));
        % qmax = polyval(P, nmax);
        % disp(['nm = ', num2str(nm), '  nmax = ', num2str(nmax),...
        %       '  qm = ', num2str(qm), '  qmax = ', num2str(qmax)]);
        % %eDefRelease(eDefNumber);
        % lcaPutSmart(qe_pv, qmax*1e9);


function [v,wform]=measureTEKSCOPE3(navg)

scope_PV='ESB:TDS';

offset=lcaGet([scope_PV ':R_CH1_POS']);
scale= lcaGet([scope_PV ':R_CH1_VDIV']);

for idx=1:navg
    wform(:,idx)=lcaGet([scope_PV ':GS_CH1_WFORM.VALA']);
end
wform=(wform-offset)*scale;
v=mean(wform,2);

function [charge, dCharge]=measureNLCTAcharge(navg,vb)

[v,wform]=measureTEKSCOPE3(navg);

scope_PV='ESB:TDS';
hScale=lcaGet([scope_PV ':R_TIME_DIV']);
nsec_pnt=length(v)./(hScale*10); %# of nsecs per point
window=50/nsec_pnt;% # of points for 50 ns
charge = zeros(1,navg);
for idx=1:navg
[vmin,minInd] = min(wform(:,idx)-vb);
wnd_start=int16(minInd-window/2);
wnd_end=int16(minInd+window/2);
charge(idx)=mean(wform(wnd_start:wnd_end,idx));
end
charge=mean(charge);
dCharge=std(charge);

function phaseOffset_Callback(hObject, eventdata, handles)
% hObject    handle to phaseOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phaseOffset as text
%        str2double(get(hObject,'String')) returns contents of phaseOffset as a double

function initPhaseShift_Callback(hObject, eventdata, handles)
% hObject    handle to initPhaseShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of initPhaseShift as text
%        str2double(get(hObject,'String')) returns contents of initPhaseShift as a double

function nAvg_Callback(hObject, eventdata, handles)
% hObject    handle to nAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nAvg as text
%        str2double(get(hObject,'String')) returns contents of nAvg as a double

