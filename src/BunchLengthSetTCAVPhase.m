% Set TCAV phase and wait for settle time

function [ok] = BunchLengthSetTCAVPhase (PDES)

global gBunchLength;

ok = 1;

BunchLengthLogMsg (sprintf('Bunch Length attempting %s PDES=%.1f %s', gBunchLength.tcav.name, PDES, char(gBunchLength.tcav.pdes.egu{1})));
lcaPut (gBunchLength.tcav.pdes_pv.name, PDES);
% Pause TCAV phase settle time.
BunchLengthLogMsg(sprintf('Waiting up to %.1f seconds for %s Phase settle time.', gBunchLength.tcav.settle_time.value{1}, gBunchLength.tcav.name));
tic;
while toc < gBunchLength.tcav.settle_time.value{1}
    testValue = (gBunchLength.tcav.pact.value{1}+PDES)/2 - PDES;
    if abs(testValue) > 0.05
        pause(0.3);
    else
        return;
    end
    if gBunchLength.cancel
        return;
    end
end
