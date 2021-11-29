%set_p_a.m
% sets rf phase and amplitude based on inputs
%rf is a structure that holds info on which pvs to use.
%n is which loop
%j is which rf sysetm


function set_p_a(rf, n, j)
allow_write = 1;
maxv = .1; % maximum amplitude change
maxp = 10; % maximum phase shift OBSOLETE

persistent amp_last;
persistent phase_last;
persistent done;
persistent amp; % target amplitude
persistent phase; % target phase
persistent amprf;
persistent phaserf;

maxp = rf.maxchange; % maximum phase chnage each time

if rf.use_rf_fb == 1 % this uses Dayle's feedbacks
     if n == 1
          phaserf(n) = lcaGet(rf.fb_pdes);
          amprf(n) = lcaGet(rf.fb_ades);
          lcaSetMonitor(rf.phase_pv); % sets up monitoring
          lcaSetMonitor(rf.amp_pv); %sets up monitoring
          disp('rffb');
          lcaPut(rf.phase_pv, phaserf(n));
          lcaPut(rf.amp_pv, amprf(n));
          return;
     end
    flag_p = lcaNewMonitorValue(rf.phase_pv);
    if flag_p < 0 % error
	disp([rf.phase_pv, ' error ', flag_p]);
    end
    flag_a = lcaNewMonitorValue(rf.amp_pv);
    if flag_p < 0 % error
	disp([rf.amp_pv, ' error ', flag_p]);
    end
    if  (flag_p == 1) || (flag_a ==1) %new Is and Qs	 
       amprf(j) = lcaGet(rf.amp_pv);
       phaserf(j) = lcaGet(rf.phase_pv)/rf.subharm;
       lcaPut(rf.fb_pdes, phaserf(j));
       lcaPut(rf.fb_ades, amprf(j));
       disp('rffb');
   end
   return;
end







if n == 1 % first loop
    txt = [rf.basename, ' phase'];
    lcaPut(rf.phase_desc_pv,txt);
    txt = [rf.basename, ' amplitude'];
    lcaPut(rf.amp_desc_pv, txt);
    lcaSetMonitor(rf.phase_pv); % sets up monitoring
    lcaSetMonitor(rf.amp_pv); %sets up monitoring
    I_init = lcaGet(rf.I_pv);
    Q_init = lcaGet(rf.Q_pv);
    amp_t = sqrt(Q_init^2+I_init^2); %target from pv
    phase_t = 360/(2*pi)*atan2(-Q_init, I_init); %target from pv
    lcaPut(rf.phase_pv, phase_t*rf.subharm);
    lcaPut(rf.amp_pv, amp_t);
    if j == 7 % x band cludge
        lcaPut(rf.phase_egu_pv, 'degX');
    else
        lcaPut(rf.phase_egu_pv, 'degS');
    end
    lcaPut(rf.amp_egu_pv, 'arb');
    amp_last(j) = amp_t;
    phase_last(j) = phase_t;
    amp(j) = amp_last(j);
    phase(j) = phase_last(j);
    done(j) = 0; % not done yet.
    amprf(j) = 0;
    phaserf(j) = 0;
end

flag_p = lcaNewMonitorValue(rf.phase_pv);
if flag_p < 0 % error
    disp([rf.phase_pv, ' error ', flag_p]);
end
flag_a = lcaNewMonitorValue(rf.amp_pv);
if flag_p < 0 % error
    disp([rf.amp_pv, ' error ', flag_p]);
end

if (flag_p == 1) || (flag_a ==1) %new Is and Qs
    done(j) = 0;
    amp(j) = lcaGet(rf.amp_pv);
    phase(j) = lcaGet(rf.phase_pv)/rf.subharm;
    I = amp(j) * cos(2*pi*phase(j)/360); % phases in degrees
    Q = -amp(j) * sin(2*pi*phase(j)/360); % phases in degrees
    if abs(I) > 32767
        I = round(sign(I)*32767);
    end
    if abs(Q) > 32767
        Q = round(sign(Q)*32767);
    end
    disp([rf.basename, '  p = ', num2str(phase(j)), '  a = ', num2str(amp(j)),...
        '  I = ', num2str(I), '  Q= ', num2str(Q)]);
end

if(phase_last(j) == phase(j)) && (amp_last(j) == amp(j))
    done(j) = 1;
end

if done(j)
    return;
end

if (phase_last(j) ~= phase(j)) % need to make a change
    if abs(phase(j) - phase_last(j)) < maxp % within range
        phasenew = phase(j);
    else
        phasenew = phase_last(j) + maxp * sign(phase(j) - phase_last(j));
    end
else
    phasenew = phase(j);
end
if (amp_last(j) ~= amp(j)) 
    if amp(j) < amp_last(j) % decrease amplitude
        if amp(j) > amp_last(j) * (1-maxv) % within range
            ampnew = amp(j);
        else
            ampnew = amp_last(j) * (1-maxv); % decrement
        end
    else % increasing amplitude
        if amp(j) < amp_last(j) * (1+maxv) % within range
            ampnew = amp(j);
	else
           ampnew = amp_last(j) + amp_last(j) * maxv; % increment maximum amont

        end
    end
else
    ampnew = amp(j);
end
Inew = ampnew * cos(2*pi*phasenew/360); % new values of I and Q
Qnew = -ampnew * sin(2*pi*phasenew/360);

Iold = amp_last(j) * cos(2*pi*phase_last(j)/360);
Qold = -amp_last(j) * sin(2*pi*phase_last(j)/360);

deltaI = Inew - Iold;
deltaQ = Qnew - Qold;

disp([rf.I_pv, '  ', rf.Q_pv]);

if deltaI > deltaQ % Change Q first to decrease
    if allow_write
        lcaPut(rf.Q_pv, Qnew);
        lcaPut(rf.I_pv, Inew);
    end
    A = sqrt(Qnew^2+Inew^2);
    P = (180/pi)*atan2(-Qnew, Inew);
    disp(['writing Q, then I  I = ', num2str(Inew), '  Q = ', num2str(Qnew),...
        '  A = ', num2str(A), '  P = ', num2str(P)]);
else
    if allow_write
        lcaPut(rf.I_pv, Inew);
        lcaPut(rf.Q_pv, Qnew);
    end
    A = sqrt(Qnew^2+Inew^2);
     P = (180/pi)*atan2(-Qnew, Inew);
    disp(['writing I, then Q  I = ', num2str(Inew), '  Q = ', num2str(Qnew), ...
        ' A = ', num2str(A), ' P = ', num2str(P)]);
end

amp_last(j) = ampnew;  
phase_last(j) = phasenew;
