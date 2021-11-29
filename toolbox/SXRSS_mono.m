function [output]=SXRSS_mono(input,mode) 

%   [output] = SXRSS_mono(energy,mode);
%
%   Function to calculate the pitch of M1 (mrad) for the SXRSS
%   Monochromator given the photon energy (eV)
%   
%
%   INPUTS:    energy:     The photon energy (eV) (or pitch in mrad)
%              mode:       1 or 2 
%
%   OUTPUTS:   pitch:      The pitch of M1 (mrad) if mode ==1
%              energy:     The photon energy (eV) if mode ==2
%
%   AUTHOR:    Dorian K. Bohler 11/19/13 
% ======================================================================= 

offset = 18; %mrad

if mode==1
    
    A=1;
    B=-18.1514;
    C=-1.39235;
    D=0.999835267;
    G=input;
    
        output = -(B+(acos(A*C/G+D))*1e3)/2+B;
        
        output=output+offset;
        
        
        
 elseif mode==2      
            A=1;
    B=-18.1514;
    C=-1.39235;
    D=0.999835267;
    G=input-offset ;
    
    output = -(A*C)/(D-cos(B/1000-G/500));
        
end





