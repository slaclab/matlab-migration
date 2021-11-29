%function BUCKETLOCK2

%This script allows operators to lock the laser into the correct RF bucket
% when needed.    - Eric K Tse, EOIC 1-13-13


clear bucketlockfile.txt

%initializing table for showing script activity
begin = 'begin';
numcols = 'numCols 1';
align = 'align "l"';
e = 'end';
line0 = ' ';
fid = fopen('bucketlockfile.txt','wt');
fprintf(fid,'%s \n',begin,numcols,align,e,line0);
fclose(fid);

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));
pause(2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

%shutter the e- beam
 lcaPut('IOC:BSY0:MP01:MSHUTCTL', 0);



line1 = '1.) Inserting mechanical shutter';
fid = fopen('bucketlockfile.txt','wt');

fprintf(fid,'%s \n',begin,numcols,align,e,line1);
fclose(fid);

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));
pause(2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

%shutter the Drive Laser
 lcaPut('TRIG:LR20:LS01:TCTL', 0);

line2 = '2.) Inserting pockel cell';
fid = fopen('bucketlockfile.txt','wt');
fprintf(fid,'%s \n',begin,numcols,align,e,line1,line2);
fclose(fid);

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));
pause(2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

%Open piezo FB loop on vittara osc.
 lcaPut('OSC:LR20:20:PID_MODE', 0);


line3 = '3.) Open piezo FB loop on vittara osc.';
fid = fopen('bucketlockfile.txt','wt');
fprintf(fid,'%s \n',begin,numcols,align,e,line1,line2,line3);
fclose(fid);

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));
pause(2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

%get Vittara osc frequency output and the difference wrt the desired value.
DIFF_AVG =   lcaGetSmart('OSC:LR20:20:FREQ_ERR_AVG');
COUNTR   =   lcaGetSmart('OSC:LR20:20:FREQ_SP');
COARSE   =   lcaGetSmart('OSC:LR20:20:FREQ_RBCK');
LIMIT    =   2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Make Act equal Des frequency output from vittara osc.

lcaPut('OSC:LR20:20:FREQ_SP', COUNTR);
DIFF_AVG2 =  lcaGetSmart('OSC:LR20:20:FREQ_ERR_AVG');

line4 = '4.) Make Act=Des freq. for vittara osc';
fid = fopen('bucketlockfile.txt','wt');
fprintf(fid,'%s \n',begin,numcols,align,e,line1,line2,line3,line4);
fclose(fid);

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));
pause(2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = 0;
%verify Act = Des
while abs(DIFF_AVG2) > LIMIT;
    %sprintf('Actual freq. not eqaul to Desired')
    n = n + 1;
    line4a = '4a.) Actual freq. not eqaul to Desired';
    fid = fopen('bucketlockfile.txt','wt');
    fprintf(fid,'%s \n',begin,numcols,align,e,line1,line2,line3,line4,line4a);
    fclose(fid);

    lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

    lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));

    lcaPutSmart('OSC:LR20:20:FREQ_SP', COUNTR);
    DIFF_AVG2 =  lcaGetSmart('OSC:LR20:20:FREQ_ERR_AVG');
    pause(1);

    if n > 5;
        P = prompt('Actual Freq unable to match Desired, Enter by hand and re-run script. Would you like to Quit?');
        if P =='y';
            sprintf('halting script')
            lcaPutSmart('OSC:LR20:20:PID_MODE', 1);
            pause(5);
            quit
        else
            break
        end
        break
    end
    break
end
pause(1);

  %sprintf('Actual Freq equals Desired, closing PIEZO FB loop, re-locking')

line4a = '4a.) verified: Act = Des';
fid = fopen('bucketlockfile.txt','wt');
fprintf(fid,'%s \n',begin,numcols,align,e,line1,line2,line3,line4,line4a);
fclose(fid);

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));
pause(2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%close Piezo Loop on vittara osc after Act=Des.
lcaPutSmart('OSC:LR20:20:PID_MODE',1);
pause(2);


line5 = '5.) Closing piezo FB loop on vittara osc.';
fid = fopen('bucketlockfile.txt','wt');
fprintf(fid,'%s \n',begin,numcols,align,e,line1,line2,line3,line4,line4a,line5);
fclose(fid);

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));
pause(2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Selects 68MHz PAD to be used in LLRF/laser FB loop.
lcaPutSmart('LASR:IN20:2:LSR_SOURCE',1);

line6 = '6.) Select 68MHz PAD for LLRF/laser FB loop.';
fid = fopen('bucketlockfile.txt','wt');
fprintf(fid,'%s \n',begin,numcols,align,e,line1,line2,line3,line4,line4a,line5,line6);
fclose(fid);

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));
pause(2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pause(1);
%Make 68MHz phase Act = Des to avoid phase jump when switching to 68MHz PAD
PAD68_PHASE_ACT  = lcaGetSmart('LASR:IN20:2:LSR_2_S_PA');
PAD68_PHASE_DES  = lcaGetSmart('LASR:IN20:2:LSR_PDES68');
lcaPutSmart('LASR:IN20:2:LSR_PDES68', PAD68_PHASE_ACT);


line6a = '6a.) Make 68MHz phase Act = Des';
fid = fopen('bucketlockfile.txt','wt');
fprintf(fid,'%s \n',begin,numcols,align,e,line1,line2,line3,line4,line4a,line5,line6,line6a);
fclose(fid);

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));
pause(2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%determine sign of error & which way to move the phase towards correct bucket
signphase = sign(PAD68_PHASE_ACT);

%creates array of step sizes from ACT to 0 Deg in steps of 10Deg.
steps = PAD68_PHASE_ACT:(-signphase*10):0;


line7 = '7.) cre8 array of steps from ACT to 0, steps of 10';
fid = fopen('bucketlockfile.txt','wt');
fprintf(fid,'%s \n',begin,numcols,align,e,line1,line2,line3,line4,line4a,line5,line6,line6a,line7);
fclose(fid);

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));
pause(2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %Selects 68MHz PAD to be used in LLRF/laser FB loop.
% lcaPutSmart('LASR:IN20:2:LSR_SOURCE',1);
% 
% line7 = '7.) Select 68MHz PAD for LLRF/laser FB loop.';
% fid = fopen('bucketlockfile.txt','wt');
% fprintf(fid,'%s \n',begin,numcols,align,e,line1,line2,line3,line4,line4a,line5,line6,line6a,line7);
% fclose(fid);
% 
% lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));
% 
% lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pause(1);

line8 = '8.) steping the DES&ACT phase towards zero Deg.';
fid = fopen('bucketlockfile.txt','wt');
fprintf(fid,'%s \n',begin,numcols,align,e,line1,line2,line3,line4,line4a,line5,line6,line6a,line7,line8);
fclose(fid);

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));
pause(2)
%steps the DES phase towards zero Deg. THis will get e- into correct bucket
for XX = steps;
    PAD68_PHASE_ACT =  XX;
    lcaPutSmart('LASR:IN20:2:LSR_PDES68', PAD68_PHASE_ACT);
    pause(1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%last step to ensure 68MHz phase equals zero Deg and e- are in Correct bucket
lcaPutSmart('LASR:IN20:2:LSR_PDES68', 0)
pause(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get final 68MHz phase
FINAL_PAD68 = lcaGetSmart('LASR:IN20:2:LSR_2_S_PA')
pause(2)


%if phase is not zero??






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Selects the 2856MHz PAD to be used in the LLRF/Laser FB loop.
lcaPutSmart('LASR:IN20:2:LSR_SOURCE',0);

line9 = '9.) Select 2856 PAD for LLRF/Laser FB loop';
fid = fopen('bucketlockfile.txt','wt');
fprintf(fid,'%s \n',begin,numcols,align,e,line1,line2,line3,line4,line4a,line5,line6,line6a,line7,line8,line9);
fclose(fid);

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));
pause(2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%need to find alarm limits causing red and calling for ampl change
BUCKET = lcaGetSmart('SIOC:SYS0:ML01:AO674');
PAC_AMPL = lcaGetSmart('LASR:IN20:2:LSR_ADES');
RF_POWER = lcaGetSmart('OSC:LR20:20:PD_CH1_RF_PWR_AVG');



%adjust RF ampl omn PD





line10 = '10.) Determine RF Ampl is sufficent';
fid = fopen('bucketlockfile.txt','wt');
fprintf(fid,'%s \n',begin,numcols,align,e,line1,line2,line3,line4,line4a,line5,line6,line6a,line7,line8,line9,line10);
fclose(fid);

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));
pause(2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pause(1);


line11 = '11.) Please run Shottky phase scan';
fid = fopen('bucketlockfile.txt','wt');
fprintf(fid,'%s \n',begin,numcols,align,e,line1,line2,line3,line4,line4a,line5,line6,line6a,line7,line8,line9,line10,line11);
fclose(fid);

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8(' ')));

lcaPutSmart('SIOC:SYS0:ML00:CA020', double(int8('bucketlockfile.txt')));
pause(2)

%reminder to run schottky phase, achieves correct phase in correct bucket.
sprintf('Run a Schottky scan to verify laser phase setting is correct')
pause(2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%








%end



