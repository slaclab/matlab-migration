function [BDES, BACT] = set_QS0_position_energy_2015(z_OB, z_IM, QS_setting, E0, m12, m34)

if(nargin < 2)
  z_ELANEX = 2015.22;
  z_IM = z_ELANEX ;
end% if
if(nargin < 3)
  QS_setting = 0;
end% if
if(nargin < 4)
  E0 = 20.35;
end% if
if(nargin < 5);
  m12_req = 0;
end% if
if(nargin < 6)
  m34_req = 0;
end% if


% use robust minimization (position alone)
do_robust_QS_min = 1;
if(do_robust_QS_min)
   QS_setting_opt_calc = 0; % for robust calc, we minimize for QS=0, and then scale
   [isok, BDESQS0, BDESQS1, BDESQS2, KQS0, KQS1, KQS2, m12, m34, M4] = E200_calc_QS0_pos_energy_2015(z_OB, z_IM, 0, E0);
   BDESQS0 =BDESQS0 * ((E0+QS_setting) / E0)
   BDESQS1 =BDESQS1 * ((E0+QS_setting) / E0)
   BDESQS2 =BDESQS2 * ((E0+QS_setting) / E0)
   KQS0 =KQS0 * ((E0+QS_setting) / E0)
   KQS1 =KQS1 * ((E0+QS_setting) / E0)
   KQS2 =KQS2 * ((E0+QS_setting) / E0)
else
  [isok, BDESQS0, BDESQS1, BDESQS2, KQS0, KQS1, KQS2, m12, m34, M4] = E200_calc_QS0_pos_energy_2015(z_OB, z_IM, QS_setting, E0);
end% if

if ~isok
    disp(sprintf('\nQS calculation failed.  QS magnets not set.\n'));
else
    disp(sprintf('\nSetting QS quads to the requested energy.\n'));
    VAL = [BDESQS0, BDESQS1, BDESQS2];
do_force_QS0_to_zero = 0;
if( do_force_QS0_to_zero )
  control_magnetSet({'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL(2:3),  'action', 'TRIM')
  disp('NB: QS0 BDES is untouched; no value is written in order not to wake QS0 from DAC0.');
  else
    control_magnetSet({'LGPS:LI20:3204', 'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM')
end% if
end

pause(1);

[BACT, BDES] = control_magnetGet({'LGPS:LI20:3204',  'LGPS:LI20:3261', 'LGPS:LI20:3311'});
disp(sprintf('\nQS0:\nBDES = %.4f\nBACT = %.4f\n\nQS1:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2), BDES(3), BACT(3)));

%disp(sprintf('\nPress the "any" key to continue.\n'));
%pause;
