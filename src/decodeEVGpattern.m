lcaPut('IOC:IN20:EV01:PATTERN_OUT.RARM',1);
while(1)
    pause(0.5);
    if isequal(0,lcaGet('IOC:IN20:EV01:PATTERN_OUT.RARM'))
        break;
    end
end
pattern = lcaGet('IOC:IN20:EV01:PATTERN_OUT');
ts = 1;
t = 0;
bcs = zeros(1,100);
tss = zeros(6,100);
for i = 1:6:length(pattern)
    bc =  bitand(bitshift(pattern(i), -8), hex2dec('0000001f'));
    bcs(1+bc) = bcs(1+bc) + 1;
    tss(ts,1+bc) = 1;
    t = t + 1;
%    if isequal(1,ts) || isequal(4,ts)
    disp(sprintf('%3.3d: %8.8X %8.8X %8.8X %8.8X %8.8X %8.8X ts=%d bc=%d',...
        t, pattern(5+i),pattern(4+i),pattern(3+i),pattern(2+i),pattern(1+i), pattern(i),...
        ts, bc));
%    end
    ts = ts + 1;
    if (7 == ts)
        ts = 1;
    end
end
for i = 1:100
    if bcs(i)>0
        s = sprintf('beam code %d %d Hz', i-1, bcs(i)/2);
        for j = 1:6
            if isequal(1,tss(j,i))
                s = sprintf('%s ts %d',s,j);
            end
        end
        disp(s);
    end
end
