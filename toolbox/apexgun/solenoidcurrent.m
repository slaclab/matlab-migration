function [ Curr_A ] = solenoidcurrent(SolenoidID,B_T)
% Calculate the current to apply to APEX Solenoids to get a peak field B_T in T. 
% Return Curr_A in A.
% The center of the solenoid (peak field)is located at z=0
% Sintax: solenoidcurrent(Solenoid ID, Peak Field in T)
% If Solenoid ID is different from 0,1,2,3 it assumes ID= 1

if SolenoidID<0 | SolenoidID>3
    SolenoidID=1;
    ['WARNING: wrong solenoid ID. Assumed Solenoid 1']
end
Bh=solenoidfield(SolenoidID,0,1);
Curr_A=B_T/Bh;
end

