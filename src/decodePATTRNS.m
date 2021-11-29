RG = 1 % [1..6]
RATE = 2 % [1..15]
pvname = sprintf('IOC:IN20:EV01:RG%2.2d_PATTRNS',RG);
pattern = lcaGet(pvname);
ts = 1;
t = 0;
bcs = zeros(1,100);
tss = zeros(4,100);
offset = 2880 * (RATE -1);
for j = 1:4:2880
    i = j + offset;
    t = t + 1;
    bc =  bitand(bitshift(pattern(i), -8), hex2dec('0000001f'));
    bcs(1+bc) = bcs(1+bc) + 1;
    tss(ts,1+bc) = 1;
    %if isequal(6,ts) && isequal(2,bc)
    disp(sprintf('%3.3d: %8.8X %8.8X %8.8X %8.8X ts=%d bc=%d',...
        t, pattern(3+i),pattern(2+i),pattern(1+i), pattern(i),...
        ts, bc));
    %end
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
