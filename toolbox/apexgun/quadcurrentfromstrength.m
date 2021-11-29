function [Current_A ] = quadcurrentfromstrength(IntStrength, Energy_MeV, quadID, IntFlag)
% Sintax: [Current_A ] = quadcurrentfromstrength(IntStrength, Energy_MeV, quadID, IntFlag)
%
% 
% If "IntFlag" is different from 1: calculate the quad current to obtain the integrated 
% strength at the given energy for APEX quadrupoles. 
% Return current I in A when IntStrength in m^-1 at Energy_MeV in MeV is required to the quadrupole.
% 
% If "IntFlag"=1: calculate the quad current to obtain the
% strength at the given energy for APEX quadrupoles. 
% Return current I in A when IntStrength in m^-2 at Energy_MeV in MeV is required to the quadrupole.
%
% quadID=1: quad 005, first of triplet
% quadID=2: quad 035, center of triplet
% quadID=3: quad 052, third of triplet
% quadID=4: quad 014
% quadID=5: quad 047
%
% IntStrength_m can be a vector. If that is the case also Current_I and will be a same size vector.
%
% Based on LBNL measurements by J.Doyle

if IntFlag==1
    IntFlag=1;
else
    IntFlag=0;
end

ID=floor(abs(quadID));
if ID < 1
    ID=1;
    ['WARNING: QuadID set to 1']
end
if ID >5
    ID=5;
    ['WARNING: QuadID set to 5']
end

Energy_MeV=abs(Energy_MeV);
Esize=size(Energy_MeV);
if Esize(2)>1
    ['ERROR: Energy_MeV must be a scalar! Function aborted.']
    return
end

IntStrength=abs(IntStrength);

% Quad effective length in m
LeffQuad=0.0634;

% Quad gradient coefficients
K(1)= 0.11675; %T/A/m. Quad 005 (first in triplet)
K(2)= 0.11665; %T/A/m. Quad 035 (center in triplet)
K(3)= 0.11675; %T/A/m. Quad 052 (third in triplet)
K(4)= 0.11658; %T/A/m. Quad 014
K(5)= 0.11597; %T/A/m. Quad 047

Gamma=1.957*Energy_MeV+1;
Betagamma=(Gamma^2-1)^(.5);
Brho=Betagamma*9.1095e-31*2.9979e8/1.6022e-19;

GL_T=IntStrength*Brho;

Size_Str=size(IntStrength);
Current_A=IntStrength;

for ii=1:1:Size_Str(2)
    if IntFlag==1
        GLact=GL_T(ii);
    else
        GLact=GL_T(ii)/LeffQuad;
    end
    Current_A(ii)=GLact/K(ID);
end
end

