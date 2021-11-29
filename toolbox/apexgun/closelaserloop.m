function [] = closelaserloop( )
%Sets and closes the laser llrf laser feedback
% 

%main parameters
laser3_kp=3000;% laser feedback proportional gain
laser3_ki=200;% laser feedback integral gain


%Additional parameters
laser3_pole=0;
laser3_ki2=0;
laser3_static_1=385;
laser3_static_2=-32768;

laser_ki=0;
laser_kp=0;
laser_static=0;
laser3_mdac_1=4;
laser3_mdac_2=0;
laser3_excite_1=0;
laser3_excite_2=0;


setpv('llrf1:laser_reverse_bo',1)
setpv('llrf1:laser3_reverse2_bo',1)

setpv('llrf1:laser3_pole_ao',laser3_pole)
setpv('llrf1:laser3_ki2_ao',laser3_ki2)
setpv('llrf1:laser3_static_ao',laser3_static_1)
setpv('llrf1:laser3_static2_ao',laser3_static_2)
setpv('llrf1:laser_ki_ao',laser_ki)
setpv('llrf1:laser_kp_ao',laser_kp)
setpv('llrf1:laser_static_ao',laser_static)
setpv('llrf1:laser3_mdac_addr1_ao',laser3_mdac_1)
setpv('llrf1:laser3_mdac_addr2_ao',laser3_mdac_2)
setpv('llrf1:laser3_excite_v_ao',laser3_excite_1)
setpv('llrf1:laser3_excite_per_ao',laser3_excite_2)

rfile_2=abs(getpv('llrf1:rfile_2'));
if rfile_2>10000
    ['WARNING: Set abs(rfile_2) < 10000 by adjusting the cavity mirror position']
    return
end

laser_freq=abs(getpv('llrf1:laser_freq'));
if laser_freq>10
    ['WARNING: Set abs(laser freq) < 5 by adjusting the gun frequency']
    return
end

nsteps=5;
kpstep=laser3_kp/nsteps;
for nn=1:nsteps
    kpact=nn*kpstep;
    setpv('llrf1:laser3_kp_ao',kpact)
    pause(2)
end

nsteps=5;
kistep=laser3_ki/nsteps;
for nn=1:nsteps
    kiact=nn*kistep;
    setpv('llrf1:laser3_ki_ao',kiact)
    pause(2)
end

['Laser feedback closed']


end

