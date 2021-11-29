function [] = openlaserloop( )
%Opens the laser llrf laser feedback
% 

%main parameters
laser3_kp=0;% laser feedback proportional gain
laser3_ki=0;% laser feedback integral gain

setpv('llrf1:laser3_ki_ao',laser3_ki)
setpv('llrf1:laser3_kp_ao',laser3_kp)

['Laser feedback open']


end

