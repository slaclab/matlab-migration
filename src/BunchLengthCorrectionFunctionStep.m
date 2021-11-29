% Perform Bunch Length Measurement Correction Function Data Readings &
% Anaylsis for one TCAV phase.

% Assumes you have reserved an eDef slot

% Mike Zelazny, zelazny@stanford.edu

function [ok, converged, newPDES, bpm, toro, tcav] = BunchLengthCorrectionFunctionStep(PDES, eDefNumber, gainFactor)

global gBunchLength;
global gDACFS;

% Hi Mike,
%
% It is <device_name>:<secn><ed>.M (ie, BPMS:LI21:xxx:X1.M).
%
% Steph
%
% > -----Original Message-----
% > From: Zelazny, Michael S.
% > Sent: Thursday, April 12, 2007 2:11 PM
% > To: Rogind, Debbie; Allison, Stephanie; Krejcik, Patrick
% > Subject: RE: BSA
% >
% > Where can I find the CNTHST for nrpos==1?  I really don't want to read
% > a 2800 deep waveform for one value.

ok = 1; % Good status
converged = 0; % Not converged
bpm.x = NaN;
bpm.y = NaN;
bpm.tmit = NaN;
bpm.goodmeas = NaN;
toro.tmit = NaN;
toro.goodmeas = NaN;
tcav.pdes = PDES;
tcav.pact = NaN;
tcav.goodmeas = NaN;
tcav.aact = NaN;
newPDES = PDES;

ok = BunchLengthSetTCAVPhase (PDES);
if ~ok
    return;
end

try
    % Start event definition
    eDefParams (eDefNumber, 1, 5); % one pulse, average 5 pulses/reading
    eDefOn (eDefNumber);
    if gBunchLength.cancel
        return;
    end
catch
    ok = 0;
    BunchLengthLogMsg('Event Definition failed to start.');
    return;
end

% Wait until event definition completes, or user presses cancel
while (true)
    try
        if (eDefDone(eDefNumber))
            break;
        else
            pause(gBunchLength.gui_pause_time); % allow time for the GUI to respond
            if gBunchLength.cancel
                return;
            end
        end
    catch
        ok = 0;
        BunchLengthLogMsg(sprintf('Event Definition %d Failed.',eDefNumber));
        return;
    end
end

try
    pv = cell(0);
    % Read the TORO
    pv{end+1} = sprintf('%s%d', gBunchLength.toro.pv.name{1}, eDefNumber);
    pv{end+1} = sprintf('%s%d.M', gBunchLength.toro.pv.name{1}, eDefNumber);
    % Read the BPM
    if gBunchLength.bpm.slc
        pv{end+1} = sprintf(gBunchLength.bpm.pv.fmtslc{gBunchLength.bpm.i},'X');
        pv{end+1} = sprintf(gBunchLength.bpm.pv.fmtslc{gBunchLength.bpm.i},'Y');
        pv{end+1} = sprintf(gBunchLength.bpm.pv.fmtslc{gBunchLength.bpm.i},'TMIT');
    else
        pv{end+1} = sprintf('%s%d',sprintf(gBunchLength.bpm.pv.format{gBunchLength.bpm.i},'X'),eDefNumber);
        pv{end+1} = sprintf('%s%d',sprintf(gBunchLength.bpm.pv.format{gBunchLength.bpm.i},'Y'),eDefNumber);
        pv{end+1} = sprintf('%s%d',sprintf(gBunchLength.bpm.pv.format{gBunchLength.bpm.i},'TMIT'),eDefNumber);
        pv{end+1} = sprintf('%s%d.M',sprintf(gBunchLength.bpm.pv.format{gBunchLength.bpm.i},'TMIT'),eDefNumber);
    end
    vals = lcaGet(pv');
    toro.tmit = vals(1);
    toro.goodmeas = vals(2);
    if isequal(0,toro.goodmeas)
        ok = 0;
        BunchLengthLogMsg(sprintf('Sorry, bad status from %s', gBunchLength.toro.desc));
        return;
    end
    bpm.x = vals(3);
    bpm.y = vals(4);
    bpm.tmit = vals(5);
    if gBunchLength.bpm.slc
        bpm.goodmeas = 1;
    else
        bpm.goodmeas = vals(6);
    end
catch
    ok = 0;
    BunchLengthLogMsg(sprintf('Sorry, unable to read %s or %s', gBunchLength.bpm.desc, gBunchLength.toro.desc));
    return;
end

if gBunchLength.cancel
    return;
end

%Read the TCAV
%pv = sprintf('%s%d', sprintf(gBunchLength.tcav.pv.format,'P'), eDefNumber);
try
    %tcav.pact = lcaGet(pv);
    tcav.pact = gBunchLength.tcav.pact.value{1};
catch
    ok = 0;
    BunchLengthLogMsg(sprintf('Sorry, unable to read TCAV. PV=%s', pv));
    return;
end

if gBunchLength.cancel
    return;
end

pv = sprintf('%s%d.M', sprintf(gBunchLength.tcav.pv.format,'P'), eDefNumber);
try
    %tcav.goodmeas = lcaGet(pv);
    tcav.goodmeas = 1;
    if isequal(0,tcav.goodmeas)
        ok = 0;
        BunchLengthLogMsg(sprintf('Sorry, bad status from TCAV.  PV=%s', pv));
        return;
    end
catch
    ok = 0;
    BunchLengthLogMsg(sprintf('Sorry, unable to read TCAV. PV=%s', pv));
    return;
end

if gBunchLength.cancel
    return;
end

%pv = sprintf('%s%d', sprintf(gBunchLength.tcav.pv.format,'A'), eDefNumber);
try
    %tcav.aact = lcaGet(pv);
    tcav.aact = gBunchLength.tcav.aact.value{1};
catch
    ok = 0;
    BunchLengthLogMsg(sprintf('Sorry, unable to read TCAV. PV=%s', pv));
    return;
end

if gBunchLength.cancel
    return;
end

% Does the BPM y read sufficiently close to zero?
if bpm.y > (gBunchLength.bpm.blen_phase.y_ref.value{1} - gBunchLength.bpm.blen_phase.y_tol.value{1})
    if bpm.y < (gBunchLength.bpm.blen_phase.y_ref.value{1} + gBunchLength.bpm.blen_phase.y_tol.value{1})
        BunchLengthLogMsg('Bunch Length Correction Function converged.');
        BunchLengthLogMsg(sprintf('%s y reads %.2f %s when TCAV PACT reads %.2f %s', gBunchLength.bpm.desc, ...
            bpm.y, char(gBunchLength.bpm.blen_phase.y_ref.egu{1}), tcav.pact, char(gBunchLength.tcav.pact.egu{1})));
        converged = 1;
        return;
    end
end

% Suggest new PDES
dy = (bpm.y - gBunchLength.bpm.blen_phase.y_ref.value{1});
s = gBunchLength.bpm.blen_phase.value{1};
if isequal(s,0)
    dp = 0;
else
    dp = dy/s;
end

newPDES = PDES + gainFactor*dp;
