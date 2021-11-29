function [] = phaseMonitorHTCal(loc)
%
%   phaseMonitorHTCal.m
%
%   This function calibrates a Linac head-tail phase monitor
%   (also known as PH_N_N-1), with input from user. Ported from
%   VMS files:
%       REF_:[STANDALONE]NEW_SCAL.FOR
%       CTRL_DISK:[PROD_SYS.BUTTON_MACRO]PDETLI16.TPU
%
%
%   	Arguments:
%                   sector      Linac sector name string
%                                 for example 'LI28'
%
%       Return:
%                   None
%
%
%   The head-tail phase monitor system in each Linac sector measures the 
%   phase difference between the Phase Reference Line (PRL) of its own
%   sector and that of the previous sector.
%   
%   There is a DAC/SAM controlled phase shifter and a SAM readout channel
%   for the phase difference measurement.
%
%   The SAM voltage readout as a function of phase shifter position is a
%   sine wave. We want to be on the linear (zero-crossing) part of this
%   curve. This program does the following:
%
%       - Perform correlation plot of phase shifter setting with
%         head-tail phase monitor readout
%       - Set phase-shifter to linear range
%       - Update linear conversion factor for head-tail monitor
%       - Update alarm limits for head-tail monitor
%
%   At the beginning of the program, we take the "lock" for this sector, so
%   that multiple clients do not simultaneously attempt to calibrate. Then
%   we release the "lock" at the end.
%
%   Some terms used in program:
%       slope (m) - slope from linear fit of head-tail monitor SAM
%                   channel voltage vs phase shifter value
%       scale     - linear conversion factor used to convert head-tail
%                   monitor SAM channel voltage to units of phase
%       offset    - offset in conversion from SAM voltage to units of phase
%
%       raw       - raw SAM voltage readback of head-tail monitor
%       pact      - phase shifter readback
%

loc=num2str(loc);

% For error logging
facility = 'LCLS';
msgheader = sprintf('%s HT Monitor Cal: ',loc);

% First let user know we're starting and set up display
try 
    pvs.msg = sprintf('LLRF:%s:1:PH_N-1_N_MSG',loc);
    pvs.msgts = sprintf('LLRF:%s:1:PH_N-1_N_MSGTS',loc);
    pvs.lck = sprintf('LLRF:%s:1:PH_N-1_N_LCK',loc);
    lcaPut(pvs.msg,'Initializing...');
    ts = sprintf('%s %s',datestr(now,23),datestr(now,13));
    lcaPut(pvs.msgts,ts);
    pvs.vis = sprintf('LLRF:%s:1:PH_N-1_N_VIS',loc);
    lcaPut(pvs.vis,0);
catch
    e = lcaLastError;
    if ( e == 3 )
        str = 'No PV write permission.';
    else
        str = 'Error during lcaPut/lcaGet.';
    end
    phaseMonitorHTCalError(lasterror,str,facility,msgheader,pvs);
end

str = 'Start scan';
gpLogMsg(facility,[msgheader str]);

% Define remaining PV names
pvs.pctrl = sprintf('PHAS:%s:1:PCTRL',loc);
pvs.pact = sprintf('PHAS:%s:1:PACT',loc);
pvs.vctrl = sprintf('PHAS:%s:1:VCTRL',loc);
pvs.vact = sprintf('PHAS:%s:1:VACT',loc);
pvs.pdes = sprintf('PHAS:%s:1:PDES',loc);
pvs.pdes_drvh = sprintf('PHAS:%s:1:PDES.DRVH',loc);
pvs.pdes_drvl = sprintf('PHAS:%s:1:PDES.DRVL',loc);
pvs.scale = sprintf('LLRF:%s:1:PH_N-1_N.D',loc);
pvs.offs = sprintf('LLRF:%s:1:PH_N-1_N.C',loc);
pvs.raw = sprintf('LLRF:%s:1:PH_N-1_N.B',loc);
pvs.ht = sprintf('LLRF:%s:1:PH_N-1_N',loc);
pvs.hh = sprintf('LLRF:%s:1:PH_N-1_N.HIHI',loc);
pvs.h = sprintf('LLRF:%s:1:PH_N-1_N.HIGH',loc);
pvs.ll = sprintf('LLRF:%s:1:PH_N-1_N.LOLO',loc);
pvs.l = sprintf('LLRF:%s:1:PH_N-1_N.LOW',loc);
pvs.input = sprintf('LLRF:%s:1:PH_N-1_N_INPUT',loc);
pvs.calts = sprintf('LLRF:%s:1:PH_N-1_N_CALTS',loc);
pvs.lscl = sprintf('LLRF:%s:1:PH_N-1_N_LSCL',loc);
pvs.loff = sprintf('LLRF:%s:1:PH_N-1_N_LOFF',loc);

% Get initial values
ivals = phaseMonitorHTCalVals(pvs);

% Set up display and take "lock". Get phase shifter range
try 
    % If lock is not available (taken by other user), exit
    if strcmp(lcaGet(pvs.lck),'Free')
        lcaPut(pvs.lck,1);  
    else
        lcaPut(pvs.msg,'Cal already in use. Quitting.');
        ts = sprintf('%s %s',datestr(now,23),datestr(now,13));
        lcaPut(pvs.msgts,ts);
        return;
    end        
    lcaPut(pvs.input,0);
    pmax = lcaGet(pvs.pdes_drvh);
    pmin = lcaGet(pvs.pdes_drvl);
catch
    str = 'Error during lcaPut/lcaGet.';
    phaseMonitorHTCalError(lasterror,str,facility,msgheader,pvs);
end

% Build corrPlot config for our scan
n = 60; % Number of steps
config = phaseMonitorHTCalConfig(n,pmax,pmin,pvs);

try
    lcaPut(pvs.msg,'Start correlation plot (3 min)...');  
    ts = sprintf('%s %s',datestr(now,23),datestr(now,13));
    lcaPut(pvs.msgts,ts);
catch
    str = 'Error during lcaPut/lcaGet.';
    phaseMonitorHTCalError(lasterror,str,facility,msgheader,pvs);
end

% Execute correlation plot and acquire data
try
    data = corrPlot_gui('appRemote',0,config,1);  
catch
    str = 'Error running CorrPlot.';
    phaseMonitorHTCalError(lasterror,str,facility,msgheader,pvs);
end

try
    lcaPut(pvs.msg,'Fitting data...');  
    ts = sprintf('%s %s',datestr(now,23),datestr(now,13));
    lcaPut(pvs.msgts,ts);
catch
    str = 'Error during lcaPut/lcaGet.';
    phaseMonitorHTCalError(lasterror,str,facility,msgheader,pvs);
end

% Check data status
if ~any(data.status)
    str = 'Bad status from corrPlot. Quitting.';
    gpLogMsg(facility,[msgheader str]);
    lcaPut(pvs.msg,str);
    ts = sprintf('%s %s',datestr(now,23),datestr(now,13));
    lcaPut(pvs.msgts,ts);
    lcaPut(pvs.lck,0);
    return;
end

% Extract data into vectors
 for k = 1:n
    pact(k) = data.readPV(2,k).val;
    raw(k)  = data.readPV(6,k).val;
end

% Find x-intercept of raw vs pact
for k = 2:n
    if (raw(k) * raw(k-1)) < 0
        i = k;
        break;
    end
    % If no x-intercept (zero-crossing) was found, exit
    if k == n
        str = 'No zero-crossing found. Quitting.';
        gpLogMsg(facility,[msgheader str]);
        lcaPut(pvs.msg,str);  
        ts = sprintf('%s %s',datestr(now,23),datestr(now,13));
        lcaPut(pvs.msgts,ts);
        lcaPut(pvs.lck,0);
        return;
    end
end

% For linear fit, use ~20 degree range about x-intercept
s = (pmax -pmin)/(n - 1); % step size
d = ceil(10/s); % +/- this number of steps about x-intercept 
if ((i-d) < 1)
    x=pact(1:(d*2+1));
    y=raw(1:(d*2+1));
elseif ((i+d) > n)
    x=pact((n-2*d):n);
    y=raw((n-2*d):n);
else
    x=pact(i-d:i+d);
    y=raw(i-d:i+d);
end

% Call util_polyFit to perform linear fit
try
    [u,v] = util_polyFit(x,y,1);  
catch
    str = 'Error calling fit function.';
    phaseMonitorHTCalError(lasterror,str,facility,msgheader,pvs);    
end
% Extract y-intercept and slope
m = u(1);
b = u(2);

% Choose x-intercept to be new setpoint of phase shifter
pdes = -b/m;

% Calculate new scale factor and offset for phase monitor
if m ~= 0
    scale = -1/m;
    if scale >= 0
        offs = -180;
    else
        offs = 0;
    end
else
    str = 'Invalid scale calculated. Quitting.';
    gpLogMsg(facility,[msgheader str]);
    lcaPut(pvs.msg,str);
    ts = sprintf('%s %s',datestr(now,23),datestr(now,13));
    lcaPut(pvs.msgts,ts);
    lcaPut(pvs.lck,0);
    return;
end

% Plot zoomed fit and data 
x1=min(x);
x2=max(x);
y1 = m*x1 + b;
y2 = m*x2 +b;
Fit=figure;
set(Fit,'Name',[loc ' Head-tail monitor calibration']);
plot(x,y);
xlabel('Phase Shifter [DegS]');
ylabel('Head-Tail Raw [V]');
title('Fit Results');
%text(0.70,0.900,sprintf('%s %s',datestr(now,23),datestr(now,13)),'Units','normalized')
text(0.05,0.900,'Fit: y = mx +b','Units','normalized');
text(0.05,0.850,sprintf('m = %.2f',m),'Units','normalized');
text(0.05,0.800,sprintf('b = %.2f',b),'Units','normalized');
text(0.05,0.700,sprintf('y is LLRF:%s:1:PH_N-1_N.B',loc),'Units','normalized','interpreter','none');
text(0.05,0.650,sprintf('x is PHAS:%s:1:PACT',loc),'Units','normalized','interpreter','none');
text(0.60,0.350,'               Old    Calculated','Units','normalized','interpreter','none');
text(0.60,0.300,sprintf('   Scale:     %.2f    %.2f',ivals.scale,scale),'Units','normalized','interpreter','none');
text(0.60,0.250,sprintf('   Offset:       %i     %i',ivals.offs,offs),'Units','normalized','interpreter','none');
text(0.60,0.200,sprintf('P-shifter:     %.1f     %.1f',ivals.pctrl,pdes),'Units','normalized','interpreter','none');
text(0.70,0.130,('Return to edm screen'),'Units','normalized','interpreter','none');
text(0.70,0.080,('to accept/reject'),'Units','normalized','interpreter','none');
line([x1,x2],[y1,y2],'Color','r');

% Prompt user to approve changes, and wait for response
try
    lcaGet(pvs.input);   
    lcaSetMonitor(pvs.input);
    lcaPut(pvs.msg,'Awaiting response');
    ts = sprintf('%s %s',datestr(now,23),datestr(now,13));
    lcaPut(pvs.msgts,ts);
    lcaPut(pvs.vis,1);
    new = lcaNewMonitorValue(pvs.input);
    r = lcaGet(pvs.input);
    k = 0; % Counter for while loop timeout
    p = 0.1; % Pause in while loop [s]
    tmo = 7200; % 2 hour timeout 

    % Wait for new data and valid response
    while ~new || strcmp(r,'Unknown')
        pause(p);
        new = lcaNewMonitorValue(pvs.input);
        r = lcaGet(pvs.input);
        k = k+1; % Counter for timeout
        if k > tmo/p
            str = 'No response after 2 hours. Quitting.';
            gpLogMsg(facility,[msgheader str]);
            lcaPut(pvs.msg,str);  
            ts = sprintf('%s %s',datestr(now,23),datestr(now,13));
            lcaPut(pvs.msgts,ts);
            lcaPut(pvs.lck,0);
            lcaPut(pvs.vis,0);
            return;
        end
    end

    % Now that we're done with them, restore display and input PVs
    lcaPut(pvs.vis,0);
    lcaPut(pvs.input,0);
catch
    str = 'Error during lcaPut/lcaGet.';
    phaseMonitorHTCalError(lasterror,str,facility,msgheader,pvs);
end

try
    if strcmp('Yes',r)
        % Set new values
        lcaPut(pvs.msg,'Setting new values...');  
        ts = sprintf('%s %s',datestr(now,23),datestr(now,13));
        lcaPut(pvs.msgts,ts);
        cal=1;
        % If we change this to put to pdes and trim, may need
        % to wait for trim before reading new value
        lcaPut(pvs.pctrl,pdes);
        lcaPut(pvs.scale,scale);
        lcaPut(pvs.offs,offs);        
        % Pause, get new phase monitor reading, then modify alarm 
        % limits of phase monitor to be +/- 20 deg from new value.
        pause(3);
        e = round(lcaGet(pvs.ht));
        hh = e + 20;
        h  = e + 15;
        ll = e - 20;
        l  = e - 15;
        lcaPut(pvs.hh,hh);
        lcaPut(pvs.h,h);
        lcaPut(pvs.ll,ll);
        lcaPut(pvs.l,l);
        ts = sprintf('%s %s',datestr(now,23),datestr(now,13)); 
        lcaPut(pvs.calts,ts);
        % Copy previous settings to PVs
        lcaPut(pvs.lscl,ivals.lscl);
        lcaPut(pvs.loff,ivals.loff);
    else 
        lcaPut(pvs.msg,'Leaving settings unchanged'); 
        ts = sprintf('%s %s',datestr(now,23),datestr(now,13));
        lcaPut(pvs.msgts,ts);
        cal=0;
    end
catch
    str = 'Error during lcaPut/lcaGet.';
    phaseMonitorHTCalError(lasterror,str,facility,msgheader,pvs);
end

% Get final values
fvals = phaseMonitorHTCalVals(pvs);

% Final messages
try
    if ~cal
        str = 'Complete. No changes made.';
        lcaPut(pvs.msg,str);  
        ts = sprintf('%s %s',datestr(now,23),datestr(now,13));
        lcaPut(pvs.msgts,ts);
        gpLogMsg(facility,[msgheader str]);
    else
        str = 'Complete. Implemented changes.';
        lcaPut(pvs.msg,str);  
        ts = sprintf('%s %s',datestr(now,23),datestr(now,13));
        lcaPut(pvs.msgts,ts);
        gpLogMsg(facility,[msgheader str]);
    end
    % Free lock
    lcaPut(pvs.lck,0);
catch
    str = 'Error during lcaPut.';
    phaseMonitorHTCalError(lasterror,str,facility,msgheader,pvs);
end

% Copy config to 'data' structure for use by corrPlot_gui
data.config = config;

% Save all data to file 
data_path = '/u1/lcls/physics/phaseMonitorHT';
data_file = sprintf('PhaseMonitorHTCal_%s',loc);
date=datestr(now,31);
str = [data_file,'_',date(1:10),'_',date(12:13),'_',date(15:16),'.mat'];
save(fullfile(data_path,str));

% Save corrPlot data to file
data_path = [data_path '/corrData/'];
corrdata_file = sprintf('CorrelationPlot_%s',data_file);
str = [corrdata_file,'_',date(1:10),'_',date(12:13),'_',date(15:16),'.mat'];
save(fullfile(data_path,str),'data');

str = sprintf('Data saved to %s%s',data_path,str);
gpLogMsg(facility,[msgheader str]);


end

function [vals] = phaseMonitorHTCalVals(pvs)
%
%   phaseMonitorHTCalVals
%
%   This function does a lcaGet of selected PVs and returns the values in
%   a structure.
%
%
%                   -name-      -type-      -description-
%   	Arguments:
%                   pvs         structure   PV names
%
%       Return:
%                   vals        structure   selected PV values
%

vals.pctrl = lcaGet(pvs.pctrl);
vals.pact = lcaGet(pvs.pact);
vals.vctrl = lcaGet(pvs.vctrl);
vals.vact = lcaGet(pvs.vact);
vals.pdes = lcaGet(pvs.pdes);
vals.scale = lcaGet(pvs.scale);
vals.offs = lcaGet(pvs.offs);
vals.ht = lcaGet(pvs.ht);
vals.raw = lcaGet(pvs.raw);
vals.hh = lcaGet(pvs.hh);
vals.h = lcaGet(pvs.h);
vals.ll = lcaGet(pvs.ll);
vals.l = lcaGet(pvs.l);
vals.lscl = lcaGet(pvs.scale);
vals.loff = lcaGet(pvs.offs);

end

function [config] = phaseMonitorHTCalConfig(n,pmax,pmin,pvs)
%
%   phaseMonitorHTCalConfig
%
%   This function builds a Correlation Plot config for use by
%   phaseMonitorHTCal
%
%
%                   -name-      -type-      -description-
%       Arguments:
%                   n           int         number of steps
%                   pmax        double      Upper limit of PDES
%                   pmin        double      Lower limit of PDES
%                   pvs         struct      PVs for use by corrPlot
%
%       Return:
%                   config       structure for corrPlot
%
%

% Define step PV (2x1 cell)
config.ctrlPVName = {pvs.pctrl;''};

% Define measurement PVs (nx1 cell)
config.readPVNameList = {
    pvs.pctrl;
    pvs.pact;
    pvs.vctrl;
    pvs.vact;
    pvs.ht;
    pvs.raw;
    };

% Define step range (2x2 cell, unused elements are 0)
config.ctrlPVRange = {
    pmin, pmax;
    0, 0
    };

% Define remaining parameters
config.showFit = 0;
config.plotXAxisId = 3;
config.plotYAxisId = 6;
config.ctrlPVValNum = [n,1];
config.ctrlPVWwaitInit = 2;
config.ctrlPVWait = 3;

end

function [] = phaseMonitorHTCalError(lasterror,str,facility,msgheader,pvs)
%
%   phaseMonitorHTCalError
%
%   This function is called when an error is "caught". It then prints a
%   message to the log, writes to the message PV, frees up the cal lock, 
%   restores the display settings and throws the last error so it can be
%   viewed.
%
%                   -name-      -type-      -description-
%       Arguments:
%                   lasterror   structure   Exception info
%                   str         string      Message string
%                   facility    string      For log message
%                   msgheader   string      For log message
%                   pvs         structure   PV names
%
%       Return:
%                   none       
%
%
str = [str ' ' 'Quitting.'];
gpLogMsg(facility,[msgheader str]);
disp(str);
disp('Error trace below:');
dbstack;
lcaPut(pvs.msg,str);
ts = sprintf('%s %s',datestr(now,23),datestr(now,13));
lcaPut(pvs.msgts,ts);
lcaPut(pvs.lck,0); % Release lock
lcaPut(pvs.vis,0); % Restore display
rethrow(lasterror);

end


