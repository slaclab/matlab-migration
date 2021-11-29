%linac_fb.m

%mx = 1e-3 * [.3857 -8.264; .5359 .1503];
%my = 1e-3 * [.2858 .4106; -1.2964 -.6754];

ymat = [-125 -1990 -1100 -1210 -361; 886 3820 1320 842 -140]; % measured slopes
xmat = [313 -293 -869 -695 -1030; 1640 603 505 -58 -280];
yctr = pinv(ymat'); 
xctr = pinv(xmat');



delay = 1;
gain = 0.3;


bpmxpv{1,1} = 'LI21:BPMS:401:X';
bpmxpv{2,1} = 'LI21:BPMS:501:X';
bpmxpv{3,1} = 'LI21:BPMS:601:X';
bpmxpv{4,1} = 'LI21:BPMS:701:X';
bpmxpv{5,1} = 'LI21:BPMS:801:X';
corxpv{1,1} = 'XCOR:LI21:275:BCTRL';
corxpv{2,1} = 'XCOR:LI21:325:BCTRL';

bpmypv{1,1} = 'LI21:BPMS:401:Y';
bpmypv{2,1} = 'LI21:BPMS:501:Y';
bpmypv{3,1} = 'LI21:BPMS:601:Y';
bpmypv{4,1} = 'LI21:BPMS:701:Y';
bpmypv{5,1} = 'LI21:BPMS:801:Y';
corypv{1,1} = 'YCOR:LI21:276:BCTRL';
corypv{2,1} = 'YCOR:LI21:325:BCTRL';

charge_pv = 'LI21:BPMS:901:TMIT';

overall_gain_pv = 'SIOC:SYS0:ML00:AO926';
lcaPut([overall_gain_pv, '.DESC'], 'linac feedback gain');
lcaPut([overall_gain_pv, '.PREC'], 3);

min_charge = 1.5e9;

refpv = 'SIOC:SYS0:ML00:AO938';
startnum = lcaGet(refpv);
disp('starting - please wait');
pause(10); %
endnum = lcaGet(refpv);
if startnum ~= endnum
    disp('Another copy of this program seems to be running, Exiting');
    return;
end
disp('running');
lcaPut([refpv, '.DESC'], 'linac_fb_running');
lcaPut ([refpv, '.EGU'], ' ');
lcaPut([refpv, '.PREC'], 0);
deltaxold = [0;0];
deltayold = [0;0];
j = 1;
while 1
    j = j + 1;
    if j > 999
        j = 1;
    end
    gain = lcaGet(overall_gain_pv);
    lcaPut(refpv, num2str(j));
    pause(delay);

    q = lcaGet(charge_pv);


    beamy = lcaGet(bpmypv);
    correctory = lcaGet(corypv);
    deltay = yctr * beamy;
    newcory = correctory - gain * deltay;
    %disp(newcory);

    beamx = lcaGet(bpmxpv);
    correctorx = lcaGet(corxpv);
    deltax = xctr * beamx;
    newcorx = correctorx - gain * deltax;
    %disp(newcorx);

    % check for duplicate corrections
    
    if gain == 0
        disp(' gain = 0, no change');
    elseif q < min_charge
        disp(['low charge ', num2str(q)]);
    elseif (sum(deltax-deltaxold) == 0) || (sum(deltay - deltayold) == 0)
        disp('duplicate correction');
    else
        lcaPut(corypv, newcory);
        lcaPut(corxpv, newcorx);
        deltaxold = deltax;
        deltayold = deltay;
        disp('x1, x2, y1, y2');
        disp(correctorx);
        disp(correctory);
    end
end
