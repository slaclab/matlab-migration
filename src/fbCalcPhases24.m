function [ph24_1, ph24_2] = fbCalcPhases24(eene, echp)
%
% ph24_1, ph24_2 = fbCalcPhases24(loop, curr_act)
%
% function to calculate the phase settings for klystrons 24-1 and 24-2, 
% given the requested energy and chirp values
%
% we have energy and chirp, now calculate the phases in radians
   dcap = eene - echp*sqrt(-1);
   xi = 2.0*acos(abs(dcap/250)/2.0);
   q2 = -sqrt(-1)*log((dcap/250)/(1 + exp(xi*sqrt(-1))));
   q1 = xi + q2;
   eenetest = 250*(cos(q1)+cos(q2));
   if (eenetest - eene > 0.5)
      xi = -2.0*acos(abs(dcap/250)/2.0);
      q2 = -sqrt(-1)*log((dcap/250)/(1 + exp(xi*sqrt(-1))));
      q1 = xi + q2;
      eenetest = 250*(cos(q1)+cos(q2));
      if (eenetest - eene > 0.5)
         xi = 2.0*acos(-abs(dcap/250)/2.0);
         q2 = -sqrt(-1)*log((dcap/250)/(1 + exp(xi*sqrt(-1))));
         q1 = xi + q2;
         eenetest = 250*(cos(q1)+cos(q2));
         if (eenetest - eene > 0.5)
            xi = - 2.0*acos(-abs(dcap/250)/2.0);
            q2 = -sqrt(-1)*log((dcap/250)/(1 + exp(xi*sqrt(-1))));
            q1 = xi + q2;
         end
      end
   end

   % phases must remain between +/-180 for LNG4,5,6
   ph24_1 = mod((real(q1)*180/pi)+180, 360) - 180;
   ph24_2 = mod((real(q2)*180/pi)+180, 360) - 180;



