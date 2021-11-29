function Beam2und_checklist


%DEFINE LTU LAUNCH FEEDBACK BPMs that must be within +/- 0.25 mm

BPM_X_620 =  lcaGet('BPMS:LTU1:620:XLTL0_S'); %#ok<NASGU>
BPM_X_640 =  lcaGet('BPMS:LTU1:640:XLTL0_S'); %#ok<NASGU>
BPM_X_660 =  lcaGet('BPMS:LTU1:660:XLTL0_S'); %#ok<NASGU>
BPM_X_680 =  lcaGet('BPMS:LTU1:680:XLTL0_S'); %#ok<NASGU>
BPM_X_720 =  lcaGet('BPMS:LTU1:720:XLTL0_S'); %#ok<NASGU>
BPM_X_730 =  lcaGet('BPMS:LTU1:730:XLTL0_S'); %#ok<NASGU>
BPM_X_740 =  lcaGet('BPMS:LTU1:740:XLTL0_S'); %#ok<NASGU>
BPM_X_750 =  lcaGet('BPMS:LTU1:750:XLTL0_S'); %#ok<NASGU>
BPM_X_760 =  lcaGet('BPMS:LTU1:760:XLTL0_S'); %#ok<NASGU>
BPM_X_770 = lcaGet('BPMS:LTU1:770:XLTL0_S'); %#ok<NASGU>

BPM_Y_620 = lcaGet('BPMS:LTU1:620:YLTL0_S'); %#ok<NASGU>
BPM_Y_640 = lcaGet('BPMS:LTU1:640:YLTL0_S'); %#ok<NASGU>
BPM_Y_660 = lcaGet('BPMS:LTU1:660:YLTL0_S'); %#ok<NASGU>
BPM_Y_680 = lcaGet('BPMS:LTU1:680:YLTL0_S'); %#ok<NASGU>
BPM_Y_720 = lcaGet('BPMS:LTU1:720:YLTL0_S'); %#ok<NASGU>
BPM_Y_730 = lcaGet('BPMS:LTU1:730:YLTL0_S'); %#ok<NASGU>
BPM_Y_740 = lcaGet('BPMS:LTU1:740:YLTL0_S'); %#ok<NASGU>
BPM_Y_750 = lcaGet('BPMS:LTU1:750:YLTL0_S'); %#ok<NASGU>
BPM_Y_760 = lcaGet('BPMS:LTU1:760:YLTL0_S'); %#ok<NASGU>
BPM_Y_770 = lcaGet('BPMS:LTU1:770:YLTL0_S'); %#ok<NASGU>

B = [BPM_X_620, BPM_X_640, BPM_X_660, BPM_X_680, BPM_X_720, BPM_X_730, BPM_X_740, BPM_X_750, BPM_X_760, BPM_X_770; BPM_Y_620, BPM_Y_640, BPM_Y_660, BPM_Y_680, BPM_Y_720, BPM_Y_730, BPM_Y_740, BPM_Y_750, BPM_Y_760, BPM_Y_770];
pvlistB = {'BPM_X_620', 'BPM_X_640', 'BPM_X_660', 'BPM_X_680', 'BPM_X_720', 'BPM_X_730', 'BPM_X_740', 'BPM_X_750', 'BPM_X_760', 'BPM_X_770'; 'BPM_Y_620', 'BPM_Y_640', 'BPM_Y_660', 'BPM_Y_680', 'BPM_Y_720', 'BPM_Y_730', 'BPM_Y_740', 'BPM_Y_750', 'BPM_Y_760', 'BPM_Y_770'};


%DEFINE LTU BPMs that must be within +/- 0.25 mm

BPM_X_860 = lcaGet('BPMS:LTU1:860:X1H'); %#ok<NASGU>
BPM_X_880 = lcaGet('BPMS:LTU1:880:X1H'); %#ok<NASGU>
BPM_X_910 = lcaGet('BPMS:LTU1:910:X'); %#ok<NASGU>
BPM_X_960 = lcaGet('BPMS:LTU1:960:X'); %#ok<NASGU>

BPM_Y_860 = lcaGet('BPMS:LTU1:860:Y1H'); %#ok<NASGU>
BPM_Y_880 = lcaGet('BPMS:LTU1:880:Y1H'); %#ok<NASGU>
BPM_Y_910 = lcaGet('BPMS:LTU1:910:Y'); %#ok<NASGU>
BPM_Y_960 = lcaGet('BPMS:LTU1:960:Y'); %#ok<NASGU>

A = [BPM_X_860, BPM_X_880, BPM_X_910, BPM_X_960, BPM_Y_860, BPM_Y_880, BPM_Y_910, BPM_Y_960];
pvlistA = {'BPM_X_860', 'BPM_X_880', 'BPM_X_910', 'BPM_X_960', 'BPM_Y_860', 'BPM_Y_880', 'BPM_Y_910', 'BPM_Y_960'};


%Checking that beam rate, charge, TDUND and LTU feedback are in good states


TDUND =  strcmp(lcaGet('DUMP:LTU1:970:TDUND_OUT'), 'Inactive');
while TDUND == 0;
  fprintf('A.)TDUND is OUT, Please insert TDUND and press enter to continue\n')
  pause
  TDUND =  strcmp(lcaGet('DUMP:LTU1:970:TDUND_OUT'), 'Inactive');
end
fprintf('A.)TDUND is IN.\n')



LTUstate = strcmp(Lcaget('FBCK:FB03:TR01:STATE'),'ON');
while LTUstate == 0
  fprintf('B.)LTU LAUNCH FEEDBACK is OFF, please turn ON and press enter to continue.\n')
  pause
  LTUstate = strcmp(Lcaget('FBCK:FB03:TR01:STATE'),'ON');
end
fprintf('B.)LTU LAUNCH FEEDBACK is ON ')



LTUstate2 = strcmp(Lcaget('FBCK:FB03:TR01:MODE'),'Enable');
while LTUstate2 == 0
  fprintf('LTU LAUNCH FEEDBACK is DISABLED, please enable and press enter to continue.\n')
  pause
  LTUstate2 = strcmp(Lcaget('FBCK:FB03:TR01:MODE'),'Enable');
end
fprintf('and ENABLED\n')



pockel = lcaGet('IOC:LR20:LS02:LCLSPOCKRATE');
mechanical = lcaGet('IOC:IN20:MP01:LCLSSHUTRATE');
rate = min(pockel, mechanical);
while rate ~= 1
  fprintf('C.)Beam Rep Rate is not 1Hz, please change rep rate to 1Hz and press enter to continue.\n')
  pause
  pockel = lcaGet('IOC:LR20:LS02:LCLSPOCKRATE');
  mechanical = lcaGet('IOC:IN20:MP01:LCLSSHUTRATE');
  rate = min(pockel, mechanical);
end
fprintf('C.)Beam rep rate is 1Hz\n')



Q = lcaGet('BPMS:IN20:221:TMIT1H')/6.24e6; %pC;
while Q > 250.00
  fprintf('D.)Beam Charge is greater than 250 pC, please decrease and press enter to continue.\n')
  pause
  Q = lcaGet('BPMS:IN20:221:TMIT1H')/6.24e6;
end
fprintf('D.)Beam Charge is less than 250 pC.\n')


disp('____________________________________________________________________________')

%Checking ALL BPM are with in +/- 0.25mmtolerances
%those used by LTU launch feedback.

for n =1:numel(B)
  while abs(B(n)>0.25)
    fprintf('E.)%s is %5.3f mm which exceeds +/- 0.25mm TOLS, fix with LTU setpoint correctors and press enter to continue\n',pvlistB{n},B(n))
    disp('DO NOT PULL TDUND!!!')
    pause;
    BPM_X_620 =  lcaGet('BPMS:LTU1:620:XLTL0_S'); %#ok<NASGU>
    BPM_X_640 =  lcaGet('BPMS:LTU1:640:XLTL0_S'); %#ok<NASGU>
    BPM_X_660 =  lcaGet('BPMS:LTU1:660:XLTL0_S'); %#ok<NASGU>
    BPM_X_680 =  lcaGet('BPMS:LTU1:680:XLTL0_S'); %#ok<NASGU>
    BPM_X_720 =  lcaGet('BPMS:LTU1:720:XLTL0_S'); %#ok<NASGU>
    BPM_X_730 =  lcaGet('BPMS:LTU1:730:XLTL0_S'); %#ok<NASGU>
    BPM_X_740 =  lcaGet('BPMS:LTU1:740:XLTL0_S'); %#ok<NASGU>
    BPM_X_750 =  lcaGet('BPMS:LTU1:750:XLTL0_S'); %#ok<NASGU>
    BPM_X_760 =  lcaGet('BPMS:LTU1:760:XLTL0_S'); %#ok<NASGU>
    BPM_X_770 = lcaGet('BPMS:LTU1:770:XLTL0_S'); %#ok<NASGU>

    BPM_Y_620 = lcaGet('BPMS:LTU1:620:YLTL0_S'); %#ok<NASGU>
    BPM_Y_640 = lcaGet('BPMS:LTU1:640:YLTL0_S'); %#ok<NASGU>
    BPM_Y_660 = lcaGet('BPMS:LTU1:660:YLTL0_S'); %#ok<NASGU>
    BPM_Y_680 = lcaGet('BPMS:LTU1:680:YLTL0_S'); %#ok<NASGU>
    BPM_Y_720 = lcaGet('BPMS:LTU1:720:YLTL0_S'); %#ok<NASGU>
    BPM_Y_730 = lcaGet('BPMS:LTU1:730:YLTL0_S'); %#ok<NASGU>
    BPM_Y_740 = lcaGet('BPMS:LTU1:740:YLTL0_S'); %#ok<NASGU>
    BPM_Y_750 = lcaGet('BPMS:LTU1:750:YLTL0_S'); %#ok<NASGU>
    BPM_Y_760 = lcaGet('BPMS:LTU1:760:YLTL0_S'); %#ok<NASGU>
    BPM_Y_770 = lcaGet('BPMS:LTU1:770:YLTL0_S'); %#ok<NASGU>
  end
  fprintf('E.)LTU FEEDBACK %s signal is %5.3f mm which is within +/- 0.25mm TOLS\n',pvlistB{n},B(n))
end


disp('_____________________________________________________________________________')

% those used at the end of the LTU.

for m =1:numel(A)
  while abs(A(m)>0.25)
    fprintf('\nF.)End of LTU %s signal is %5.3f mm which exceeds +/- 0.25mm TOLS.\nFix with XCUM1, XCUM4, YCUM2, & YCUM3 correctors and press enter to continue\n',pvlistA{m}, A(m))
    disp('DO NOT PULL TDUND!!!')
    pause;
    BPM_X_860 = lcaGet('BPMS:LTU1:860:X1H'); %#ok<NASGU>
    BPM_X_880 = lcaGet('BPMS:LTU1:880:X1H'); %#ok<NASGU>
    BPM_X_910 = lcaGet('BPMS:LTU1:910:X'); %#ok<NASGU>
    BPM_X_960 = lcaGet('BPMS:LTU1:960:X'); %#ok<NASGU>

    BPM_Y_860 = lcaGet('BPMS:LTU1:860:Y1H'); %#ok<NASGU>
    BPM_Y_880 = lcaGet('BPMS:LTU1:880:Y1H'); %#ok<NASGU>
    BPM_Y_910 = lcaGet('BPMS:LTU1:910:Y'); %#ok<NASGU>
    BPM_Y_960 = lcaGet('BPMS:LTU1:960:Y'); %#ok<NASGU>
  end
  fprintf('F.)End of LTU %s signal is %5.3f mm which is within +/- 0.25mm TOLS\n',pvlistA{m}, A(m))
end
disp('______________________________________________________________________________')

fprintf('Its all good, please proceed to the next steps...\n')
fprintf('\n1.)Launch BPM GUI to monitor beam trajectory through the Undulator.\n\n2.)Pull TDUND with caution.\n\n3.)If the UND BPMs are within +/-0.50mm you may proceed...\nIf not you must steer the beam to achieve BPM readings within +/- 0.5mm.')



%	If the undulator orbit is OK, the rate can be increased to 10 or 30 Hz, within the limits of the existing BAS.
%	If the undulator or LTU orbit is bad, and slight had steering cannot adequately correct, please inspect alarms
%for magnet errors and compare configurations, as usual when unexpected
%results arise.  If the problem persists,
%please call in for help from the program deputy or the shift physicist (or Heinz-Dieter Nuhn or Paul Emma).


