function SaveCAMACTimingBeamcode1ToSCORE()

[ sys, arg.accelerator ] = getSystem();
arg.fetchGold = 1;
arg.region = 'CAMAC Timing-Beamcode 1';

disp(' ');
disp(sprintf('Gathering PV list for %s', arg.region));
[data, comment, ts] = FromSCORE(arg);

disp(' ');
disp('Getting latest data from channel access');
shortCount = 0;
intCount = 0;
longCount = 0;
stringCount = 0;
byteCount = 0;
doubleCount = 0;
floatCount = 0;
scalarCount = 0;
failedCount = 0;

for i = 1 : length(data)
    disp(sprintf('%d/%d lcaGet-ing(''%s'')', i, length(data), data{i}.setpointName));
    try
        [ v , ts ] = lcaGet(data{i}.setpointName);
        if isequal(data{i}.waveformType,'short')
            shortCount = shortCount + 1;
            [ wf, ts ] = lcaGet(data{i}.setpointName,length(v),data{i}.waveformType);
            str = '';
            for j = 1 : length(v)
                str = sprintf('%s%d;',str,wf(j));
            end
            data{i}.setpointValStr = str;
            disp(sprintf('     short waveform is %s', data{i}.setpointValStr));
        elseif isequal(data{i}.waveformType,'int')
            intCount = intCount + 1;
        elseif isequal(data{i}.waveformType,'long')
            longCount = longCount + 1;
        elseif isequal(data{i}.waveformType,'String')
            stringCount = stringCount + 1;
            data{i}.setpointValStr = char(v);
            disp(sprintf('     string value is %s', data{i}.setpointValStr));
        elseif isequal(data{i}.waveformType,'byte')
            byteCount = byteCount + 1;
        elseif isequal(data{i}.waveformType,'double')
            doubleCount = doubleCount + 1;
        elseif isequal(data{i}.waveformType,'float')
            floatCount = floatCount + 1;
        else
            scalarCount = scalarCount + 1;
            [ data{i}.setpointVal , ts ] = lcaGet(data{i}.setpointName, 1, 'double');
            disp(sprintf('     scalar value is %f', data{i}.setpointVal));
        end
    catch
        failedCount = failedCount + 1;
        disp(sprintf('    lcaGet(''%s'') failed', data{i}.setpointName));
    end
end

disp(' ');
if failedCount > 0
    disp(sprintf('lcaGet failed %d times', failedCount));
end
if shortCount > 0
    disp(sprintf('%d PVs were short arrays', shortCount));
end
if intCount > 0
    disp(sprintf('%d PVs were int arrays', intCount));
end
if longCount > 0
    disp(sprintf('%d PVs were long arrays', longCount));
end
if stringCount > 0
    disp(sprintf('%d PVs were strings', stringCount));
end
if byteCount > 0
    disp(sprintf('%d PVs were byte arrays', byteCount));
end
if doubleCount > 0
    disp(sprintf('%d PVs were double arrays', doubleCount));
end
if floatCount > 0
    disp(sprintf('%d PVs were float arrays', floatCount));
end
if scalarCount > 0
    disp(sprintf('%d PVs were doubles', scalarCount));
end

disp(' ');
disp('Saving to SCORE');
arg.data = data;
arg.comment = 'Automatic Weekly Save';
[region, comment, ts] = Save2SCORE(arg);

if usejava('desktop')
    % don't exit from Matlab
else
    exit
end
