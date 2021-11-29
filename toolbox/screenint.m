% screen.m
% integrates screen intensity

inpv = 'OTRS:LI25:920:IMAGE';
outpv = 'SIOC:SYS0:ML00:AO045';
avgpv = 'SIOC:SYS0:ML00:AO046';


lcaPut([outpv, '.DESC'], 'OTR TCAV Intensity');
lcaPut([outpv, '.PREC'], 3);

lcaPut([avgpv, '.DESC'], 'median TCAV Intensity');
lcaPut([avgpv, '.PREC'], 3);

numavg = 20;
firstloop = 1;
avpwr = 0;
intcnt = 1;
savedata = zeros(numavg,1);
while 1
    pause(.5);
    try
        screen = lcaGet(inpv);
        sm = sum(screen) / 1e6;
        if firstloop
            firstloop = 0;
            avgpwr = sm;
        else
            intcnt = intcnt + 1;
            savedata(intcnt) = sm;
        end
        if intcnt == numavg  
            avpwr = median(savedata);
            intcnt = 0;
            disp(['median = ', num2str(avpwr)]);
        end
        lcaPut({outpv; avgpv}, {num2str(sm); num2str(avpwr)});
        disp(['OTR TCAV integral ', num2str(sm)]);

    catch
        disp('error, try again');
    end
end
