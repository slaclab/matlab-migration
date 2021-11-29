%watchdog_run.m

function W = watchdog_run(W)
 W.count = W.count + 1;
if ~mod(W.count, W.modulo)  % Increment PV
   W.inc = W.inc + 1;
  try
    old = lcaGet(W.PV); % Get the previous count.
    if old < 0
      W.error = old;
      return;
    end
    if W.inc ~= old+1
      W.error = 1; % Someone else is using this PV
      if W.inc > old
        lcaPut(W.PV, W.inc)  % Higher count wins
        W.relative_count = 1;
      else
        W.inc = old; % Used the other guy's value
        W.relative_count = -1;
      end
    else
      W.error = 0;
      lcaPut(W.PV, W.inc)
    end
  catch
    W.error = 2; % Could not write some PV
  end
end
end