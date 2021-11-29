function [ output_args ] = setbuncherfrequency( kHzforDegC,CycleDur_s )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
mmd=10218;
qqd=-1.2521e7;

mmf= 9.7857e-05;
qqf= 1225.4;


T0=getpv('Gun:RF:Temp13')
dd0=getpv('L1llrf:ddsa_phstep_h_ao')
Freq0=(dd0*mmf+qqf)-1300

MHzperDegC=kHzforDegC/1000;

while 1
    T1=getpv('Gun:RF:Temp13');
    DeltaT=T1-T0;
    Deltafreq=-DeltaT*MHzperDegC;
    Deltadd=mmd*Deltafreq;
    dd1=dd0+Deltadd
    setpvonline('L1llrf:ddsa_phstep_h_ao',dd1,'float',1);
    Freq=(dd1*mmf+qqf)-1300
    T0=getpv('Gun:RF:Temp13');
    dd0=dd1;
    pause(CycleDur_s);
end
    

end

