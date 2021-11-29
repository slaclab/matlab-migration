function [out, ts, isPV] = BAT_collect(static) 

% collects BAT data and does some slight pre-processing
% static is the stuff output by BAT_init.m

%% handle inputs

if isempty(static)
    static = BAT_init();
    disp('Initializing with BAT_init');
    return
end

%% acquire PV data and waveform

[out, ts, isPV] = lcaGetStruct(static.pv, 0, 'double');
[out.raw, out.ts] = lcaGetSmart(static.array.waveform);

%% reshape 4096 x 1 to 1024 x 4
if numel(out.raw) == (static.num.points * static.num.chans)
    out.raw = reshape(out.raw, static.num.points, static.num.chans, []);
    out.raw = out.raw(:, 1:static.num.cavities, :);
else
    disp_log(strcat({'Some problem acquiring waveform: length = '}, num2str(numel(out.raw))));
    out.raw = zeros(static.num.points, static.num.chans);
end

return