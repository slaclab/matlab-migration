function out = BAT_calc(static, data)

%% calculate crude and fit windows

% truncated data - start/stop points and time vector (for plotting)

crude.points   = round(static.crude.time * static.freq.clock);
crude.timevec  = static.raw.timevec(crude.points(1):crude.points(2));

% further truncated for fitting 
fit.points   = round(static.fit.time * static.freq.clock);
fit.timevec  = crude.timevec((fit.points(1) - crude.points(1)):...
                             (fit.points(2) - crude.points(1)));


%% copy over input

out.raw.data = data.raw;
out.raw.time = static.raw.timevec;

%% background subtraction

out.bgsub.data = out.raw.data - repmat(static.background, length(out.raw.data), 1);
out.bgsub.time = static.raw.timevec;

%% downconvert

out.I_u.data = out.bgsub.data .* static.if.sin;
out.Q_u.data = out.bgsub.data .* static.if.cos;

out.I_u.time = static.raw.timevec;
out.Q_u.time = static.raw.timevec;

%% truncate to "crude" window

out.I_x.data = out.I_u.data(crude.points(1):crude.points(2), :, :);
out.Q_x.data = out.Q_u.data(crude.points(1):crude.points(2), :, :);

out.I_x.time = crude.timevec;
out.Q_x.time = crude.timevec;

%% phase rotation

% there is probably a more matlab-y way to do this

for n = 1:static.num.cavities
    % calculate rotation
    out.rotation(n) = (data.in.cav.offset(n) + ...                          % cav offset
                       static.atten.phase(data.ctrl.atten(n), n)) * ...  % attenuator phase
                       static.freq.cav(n) * 2 * pi * 1e-12;
    % rotate
    out.I.data(:, n) =  out.I_x.data(:, n) * cos(out.rotation(n)) + ...
                        out.Q_x.data(:, n) * sin(out.rotation(n));
    out.Q.data(:, n) =  out.Q_x.data(:, n) * cos(out.rotation(n)) - ...
                        out.I_x.data(:, n) * sin(out.rotation(n));
end

out.I.time = crude.timevec;
out.Q.time = crude.timevec;

%% filter

out.I_f.data = filtfilt(static.filter.B, static.filter.A, out.I.data);
out.Q_f.data = filtfilt(static.filter.B, static.filter.A, out.Q.data);

out.I_f.time = crude.timevec;
out.Q_f.time = crude.timevec;

%% calculate phase

out.T_f.data = atan2(out.I_f.data, out.Q_f.data);           % phase
out.P_f.data = (out.I_f.data .^ 2) + (out.Q_f.data .^ 2);   % power ( = ampl^2, so no sqrt)

out.T_f.time = crude.timevec;
out.P_f.time = crude.timevec;

%% truncate data again, to "fit" window

out.T_f_fit.data = out.T_f.data((fit.points(1)-crude.points(1)): ...
                                (fit.points(2)-crude.points(1)), :, :);
out.P_f_fit.data = out.P_f.data((fit.points(1)-crude.points(1)): ...
                                (fit.points(2)-crude.points(1)), :, :);

out.T_f_fit.time = fit.timevec;
out.P_f_fit.time = fit.timevec;

%% calculate power

out.totalpower = sum(out.P_f.data);
out.power = log(out.P_f_fit.data);

%% linear fit

for n = 1:static.num.cavities
    out.chargescale(n)      = data.in.cav.scale(n) / 1000 / static.atten.gain(data.ctrl.atten(n));
    out.fit.poly(:, n)      = polyfit(out.T_f_fit.time, out.T_f_fit.data(:,n), 1);          % fit to linear
    out.fit.charge(:, n)    = sqrt(out.totalpower(:, n)) * out.chargescale(n);              % measured power
    out.fit.phase(:, n)     = polyval(out.fit.poly(:, n), ...
                              (data.in.cav.starttime(n) * 1e-6));                           % phase at "precision start" time
    out.fit.time(:, n)      = out.fit.phase(:, n) / (2 * pi * static.freq.cav(n)) * 1e12;   % phase converted to ps

    % this stuff from main loop
    out.fit.powerpoly(:, n) = polyfit(out.P_f_fit.time, out.power(:, n), 1);                % linear fit of power
    out.fit.freq(:, n)      = (-out.fit.poly(1, n) / (2 * pi) + static.freq.cav(n)) / 1e6;  % freq = dphi/dt = slope of phase fit
    out.fit.q(:, n)         = -2 * pi * 1e6 * out.fit.freq(:, n) / out.fit.powerpoly(1, n); % cavity Q
    out.fit.maxcounts(:, n) = max(abs(out.raw.data(:, n)));                                 % maximum raw counts
    out.fit.maxnobg(:, n)   = max(abs(out.bgsub.data(:, n)));                               % max counts, bg subtracted
end

%% calculate differences between all cavities

out.fit.diffs = repmat(out.fit.time', 1, static.num.cavities) - ...
                repmat(out.fit.time, static.num.cavities, 1);
            
out.fit.diffs = reshape(out.fit.diffs, 1, []);

%% set up plots for GUI

out.plot.raw = out.raw;
out.plot.bgsub = out.bgsub;
out.plot.I_u = out.I_u;
out.plot.Q_u = out.Q_u;
out.plot.I_x = out.I_x;
out.plot.Q_x = out.Q_x;
out.plot.I = out.I;
out.plot.Q = out.Q;
out.plot.I_f = out.I_f;
out.plot.Q_f = out.Q_f;
out.plot.T_f = out.T_f;
out.plot.P_f = out.P_f;
out.plot.T_f_fit = out.T_f_fit;
out.plot.P_f_fit = out.P_f_fit;
