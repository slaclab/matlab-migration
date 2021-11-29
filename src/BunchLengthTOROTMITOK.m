% Is TORO TMIT within specified percentage of each other?
% Mike Zelazny (zelazny@stanford.edu)
% Assumes data collected with BunchLengthDataAcq

function [ok] = BunchLengthTOROTMITOK (toro, percentage)

global gBunchLength;

ok = 0; % Assume there are no good readings
found = 0; % Is there at least one good reading?
% find the first good TORO TMIT
for each_toro = 1:size(toro,2)
    for each_tmit = 1:size(toro{each_toro}.tmit,2)
        if toro{each_toro}.goodmeas(each_tmit) > 0
            if ~found
                found = 1;
                tmit_low = toro{each_toro}.tmit(each_tmit);
                tmit_high = tmit_low;
                break;
            end
        end
    end
end

if found
    ok = 1; % So far so good
    for each_toro = 1:size(toro,2)
        for each_tmit = 1:size(toro{each_toro}.tmit,2)
            if toro{each_toro}.goodmeas(each_tmit) > 0
                tmit_low = min(tmit_low, toro{each_toro}.tmit(each_tmit));
                tmit_high = max(tmit_high, toro{each_toro}.tmit(each_tmit));
            end
        end
    end
    if tmit_high > (tmit_low * (1+(percentage / 100)))
        ok = 0;
        % Dump TORO TMITs to error log
        BunchLengthLogMsg(sprintf('%s TMIT check failed.  Low TMIT=%.3f  High TMIT=%.3f', gBunchLength.toro.desc, tmit_low, tmit_high));
        for each_toro = 1:size(toro,2)
            for each_tmit = 1:size(toro{each_toro}.tmit,2)
                BunchLengthLogMsg(sprintf('   %s TMIT=%.3f', gBunchLength.toro.desc, toro{each_toro}.tmit(each_tmit)));
            end
        end
    end
else
    BunchLengthLogMsg(sprintf('%s failed to read any good values.', gBunchLength.toro.desc));
end