% assumes E = E0 = 20.35 GeV
   % s = 0 is MIP from last year, d_OB is delta from this position, +d is downstream
   % s = 0 is CHER_FAR , d_IM is delta from this position, +d is downstream
function [BDES, BACT] = set_QS_pos(d_OB, d_IM)

E0 = 20.35;
QS_energy = +0;
[isok, BDES1, BDES2, K1, K2, m12, m34, M4] = E200_calc_QS(QS_energy, 0.28 + d_OB, d_IM, E0);
BDES1
BDES2
VAL = [BDES1, BDES2]
%%% TEMP control_magnetSet({'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM');

pause(1);

[BACT, BDES] = control_magnetGet({'LGPS:LI20:3261', 'LGPS:LI20:3311'});
disp(sprintf('\nQS1:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2)));


