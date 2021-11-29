function [setok, result_phase] = schottky_scan(name, phase_offset, initial_phase_shift, navg, rate, tag, handles)

disp('Schottky starting');

max_phase_change    = 10;       % maximum phase change before warning [degS]
min_initial_charge  = 0.015;    % at least this much charge to start [nC]
phase_step_big      = 3;        % degrees S band (set >0
                                % Dec. 18,'07 - was <0) ZIMMER
                                % changed 7/2/2020 was 5
% Okay. Doing this 10% more smartly...
inj_bpm_charge_set = lcaGetSmart('IOC:IN20:BP01:QANN'); % nC
if inj_bpm_charge_set >= 0.1 %nC
    charge_not_changing = .0036;    %Zimmer threshold for determining
                                    %zero charge delta between two
                                    %phases, nC. .0009 -> .0032
                                    %5/3/21. Raised .0032->.0036 8/1/21
    
    charge_below_threshold = 0.024; % used in one place below
else % low charge
    charge_not_changing = .0009;
    charge_below_threshold = 0.005;
end
phase_step_small    = 1.0;      % degrees S band (set >0 Dec. 18,'0 - was <0).
phase_steps         = 50;       % max number of big phase steps
                                % ZIMMER changed 7/2/20 was 30
phase_steps2        = 30;   	% max number of small phase steps
delay0              = 5;        % delay time before first big or small step [sec]
delay1              = 2;        % time delay between big steps [sec]
delay2              = 1;        % time delay between small steps [sec]
if epicsSimul_status, [delay0,delay1,delay2]=deal(0);end

screen_pv = 'YAGS:IN20:241:PNEUMATIC';

initial_phase  = control_phaseGet(name,'PDES');
result_phase = initial_phase; % Default to initial phase
initial_screen = lcaGet(screen_pv);
lcaPut(screen_pv, 'IN');

j=100;
while j && ~any(lcaGetSmart(strcat('MPS:IN20:200:MSHT1_',{'IN';'OUT'},'_MPS'),0,'double'))
    j=j-1;pause(.1);
end
pause(5); % as per Joe Frisch & Franz-Joseph

bpm_pv    = 'BPMS:IN20:221';
laser_energy_pv = 'LASR:IN20:196:PWR';

qe_pv = 'SIOC:SYS0:ML00:AO937';

lcaPut([qe_pv, '.DESC'], 'Schottky peak QE');
lcaPut([qe_pv, '.EGU'], 'PPB');

setok = 0;

disp('Getting initial conditions...');

T = lcaGet([bpm_pv, ':TMIT1H']); 
charge = 1.602E-10*T;   % [nC]

if ~lcaGet('YAGS:IN20:241:TGT_STS',0,'double')
    errordlg('YAG02 not inserting.','YAG02 FAILURE');
    lcaPut(screen_pv, initial_screen);
    control_phaseSet(name,result_phase);
    return;
end

disp(['Initial charge = ' num2str(charge) ' nC']);
if charge < min_initial_charge
    errordlg('Charge too low, aborting.','INSUFFICIENT CHARGE');
    lcaPut(screen_pv, initial_screen);
    control_phaseSet(name,result_phase);
    return;
end

phase  = zeros(phase_steps,1);  % phase setting [degS]
phaseR = zeros(phase_steps,1);  % phase readback [degS]
[c,dc,lasengy] = deal(zeros(phase_steps,1));

disp('Starting big steps...');

for j = 1:phase_steps
    if ~gui_acquireStatusGet([],handles), break, end
    set(handles.(tag),'String',sprintf('big-step:%3.0f...',j));
    phase(j) = initial_phase + j*phase_step_big + initial_phase_shift; % new phase
    control_phaseSet(name,phase(j));        % set new phase
    if j == 1
        pause(delay0);
    else
        pause(delay1);
    end

    phaseR(j)  = control_phaseGet(name,'PDES'); % read phase [degS]
    lasengy(j) = lcaGet(laser_energy_pv);
    [X,Y,T,dX,dY,dT,iok] = read_BPMs({bpm_pv},navg,rate);
    if epicsSimul_status
        pAct=phaseR(j)+.1*randn;off=4;
        T=1.6e9*(max(0,-sind(pAct(1)+off)+1e-2*randn));dT=1.6e7;
        if T < 1.6e9*.1, T=0;end
        X=T;
    end
    c(j)  = T*1.602E-10;                  % mean charge [nC]
    dc(j) = dT*1.602e-10;                 % std charge [nC]
    if X == 0, break, end  %Old condition for BPM TMIT ~0
    if isnan(X), break, end        
end

if ~gui_acquireStatusGet([],handles)
    disp('Schottky scan aborted');
    return
end

jlast = j;
%if jlast <=3
%    errordlg('Missed Schottky peak on first phase steps - try full range scan - quitting','BAD SCAN');
%    lcaPut(screen_pv, initial_screen);
%    control_phaseSet(name,result_phase);
%    return       % quit
%end

%start_scan = phase(jlast-2) - phase_step_small; % phase to start fine scan at
start_scan = phase(jlast-1) - (4*phase_step_small); % phase to start
                                                % fine scan at (try
                                                % backing up less -
                                                % 11/23/08 - PE)
                                                % Zimmer 7/2/20
                                                % change from
                                                % phase_step_small. 8/1/21
                                                % change from 2*big_step


% Start fine scan around zero-crossing phase...
ph2  = zeros(phase_steps2, 1);  % phase setting [degS]
ph2R = zeros(phase_steps2, 1);  % phase readback [degS]
[ch2,dch2] = deal(zeros(phase_steps2,1));
disp('Starting small steps...');

% restore charge attn setting back to intial value (high sensitivity) for Schottky scan small steps
lcaPut(handles.BPM_attn_pv,handles.BPM_attn);

for j = 1:phase_steps2
    if ~gui_acquireStatusGet([],handles), break, end
    set(handles.(tag),'String',sprintf('small-step:%3.0f...',j));
    ph2(j) = start_scan + (j-1)*phase_step_small;
    control_phaseSet(name,ph2(j));
    if j == 1
        pause(delay0);
    else
      pause(delay2);
    end
    ph2R(j) = control_phaseGet(name,'PDES'); % read phase [degS]
    [X,Y,T,dX,dY,dT,iok] = read_BPMs({bpm_pv},navg,rate);
    if epicsSimul_status
        pAct=ph2R(j)+.1*randn;off=4;
        T=1.6e9*(max(0,-sind(pAct(1)+off)+1e-3*randn));dT=1.6e7;
        X=T;
    end
    ch2(j)  = T*1.602E-10                % mean charge [nC]
    dch2(j) = dT*1.602e-10;               % std charge [nC]
    if X == 0, break, end  % old condition for BPM TMIT ~0
    if isnan(X), break, end % new condition
    
    try
        if ((ch2(j-1) - ch2(j)) < charge_not_changing);
            if (ch2(j) < charge_below_threshold); % Make sure low charge
                display('Terminating scan, charge detected as minimum (last two points very close).')
                break
            end
        end
    catch
        display(['Skipping alternate minimum charge detection, not enough ' ...
                 'points yet'])
    end
    
end

if ~gui_acquireStatusGet([],handles)
    disp('Schottky scan aborted');
    return
end

if j<=2                                 % insufficient data on small-steps
    errordlg('Not enough small steps to find zero-crossing phase - try again.','INSUFFICIENT DATA');
    lcaPut(screen_pv, initial_screen);
    control_phaseSet(name,result_phase);
    return
end
%phfit  = [ph2R(1:(j-1));  phaseR((jlast-2):(jlast-1))];
%chfit  = [ ch2(1:(j-1));       c((jlast-2):(jlast-1))];
%dchfit = [dch2(1:(j-1));      dc((jlast-2):(jlast-1))];
phfit  = [ph2R(1:(j-1));  phaseR((jlast-1):(jlast-1))]; % remove one "big-step" point from fit
chfit  = [ ch2(1:(j-1));       c((jlast-1):(jlast-1))]; % remove one "big-step" point from fit
dchfit = [dch2(1:(j-1));      dc((jlast-1):(jlast-1))]; % remove one "big-step" point from fit
i0 = find(dchfit==0);
if ~isempty(i0)
    dchfit(i0) = chfit(i0)/10;
end
[q,dq,xf,yf] = plot_polyfit(phfit,chfit,dchfit,1,' ',' ',' ',' ',1);    % linear fit of tail end
phase0 = -q(1)/q(2);                                    % solve zero-crossing phase with linear solution
new_phase = phase0 + phase_offset;

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
    lcaPut(screen_pv, initial_screen);
    control_phaseSet(name,result_phase);
    return;
end

txt = [datestr(now) '; {\it\phi}(old)=' sprintf('%5.2f',initial_phase) '\circ, {\it\phi}(calc)=' ...
       sprintf('%5.2f',new_phase) '\circ, {\it\phi}(set)='];
if abs(new_phase - initial_phase) < max_phase_change
    setok = 1;
else
    title([txt '?']);
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
        disp('Phase is valid but "No changes" toggle is selected on GUI panel');
    else
        result_phase = new_phase;
        disp('Phase is valid - setting');
    end
else
    disp('Phase invalid - no change');
end

txt = [txt sprintf('%5.2f',result_phase) '\circ'];
title(txt);
hold off

disp(['new phase = ', num2str(new_phase)]);
control_phaseSet(name,result_phase);
lcaPut(screen_pv, initial_screen);         % return screen to initial state

j=100;
while j && ~any(lcaGetSmart(strcat('MPS:IN20:200:MSHT1_',{'IN';'OUT'},'_MPS'),0,'double'))
    j=j-1;pause(.1);
end

% now calculate peak charge
% phase(j) is phase during big steps scan
% c(j) is charge during big steps scan
laser_ev = 4.86;            % electron volts laser energy
electrons = c/1.602e-10;    % convert back to num electrons
energy = lasengy*1e-6;      % 100% on power meter (*100 = Dec. 12, '07)
photons = energy/(laser_ev*1.602e-19);
qe = electrons./photons;    % qe at each point. 
[qm, nm] = max(qe);

if nm < 2
    return;
elseif nm > phase_steps -1
    return;
end
tmpy = qe((nm-1):(nm+1))';
tmpx = [nm-1, nm, nm+1];

P = polyfit(tmpx, tmpy, 2); % fit to peak
nmax = -P(2)/(2*P(1));
qmax = polyval(P, nmax);
disp(['nm = ', num2str(nm), '  nmax = ', num2str(nmax),...
      '  qm = ', num2str(qm), '  qmax = ', num2str(qmax)]);
lcaPutSmart(qe_pv, qmax*1e9);
