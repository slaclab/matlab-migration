function [dt]=SXRSS_delay(h1,h2,hs,theta, gamma)

%   [dt]=SXRSS_delay(h1,h2,hs,theta, gamma);
%
%   Function to calculate the difference in time (delay) for SXRSS. The
%   delay is dependent on the path difference which is calculated by
%   comparing the path traveled by a beam crossing the SXRSS undulator
%   section undeflected and one diffracted by the grating an passing through
%   M1, M2, and M3. 
%
%   INPUTS:     h1:     Height from G1 to M1 (mm) - constant
%               h2:     Height from M2 to M3 (mm) - depend on horiz. steer 
%               hs:     Height assoc. w/ horiz. steering (mm)
%               theta:  Pitch of M1 (mrad)
%               gamma:  Pitch of M3 (mrad)
%
%   OUTPUTS:    dt:     Time delay (fs)
%
%   WRITTEN BY: Dorian K. Bohler 11/18/13
% =========================================================================


offset=100; %fs

theta=theta/-1000+18/1000; gamma=gamma/1000;

c=2.99*10^-4; % light speed (mm/fs)


p1=(h1*(1-cos(2*theta)))/(sin(2*theta));


p2=((h2+hs)*(1-cos(2*gamma)))/(sin(2*gamma));

dt=(p1+p2)/c;

dt=dt-offset;


