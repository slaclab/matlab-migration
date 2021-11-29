function [Current_A ] = quadcurrentfromgradient(IntGrad,quadID,IntFlag)
% Sintax: [Current_A ] = quadcurrentfromgradient(IntGrad, quadID, IntFlag)
% 
% If "IntFlag" is different from 1: Calculate the quad current to obtain the integrated gradient IntGrad for APEX quadrupoles. 
% Return current I in A when IntGrad in T is required to the quadrupole with ID = quadID.
% 
% If "IntFlag"=1: Calculate the quad current to obtain the gradient IntGrad for APEX quadrupoles. 
% Return current I in A when IntGrad in T/m is required to the quadrupole with ID = quadID.
%
% quadID=1: quad 005, first of triplet
% quadID=2: quad 035, center of triplet
% quadID=3: quad 052, third of triplet
% quadID=4: quad 014
% quadID=5: quad 047
%
% IntGrad can be a vector. If that is the case also Current_I and will be a same size vector.
%
% Based on LBNL measurements by J.Doyle

if IntFlag==1
    IntFlag=1;
else
    IntFlag=0;
end

IntGrad=abs(IntGrad);
ID=floor(abs(quadID));
if ID < 1
    ID=1;
    ['WARNING: QuadID set to 1']
end
if ID >5
    ID=5;
    ['WARNING: QuadID set to 5']
end


% Quad effective length in m
LeffQuad=0.0634;

% Quad gradient coefficients
K(1)= 0.11675; %T/A/m. Quad 005 (first in triplet)
K(2)= 0.11665; %T/A/m. Quad 035 (center in triplet)
K(3)= 0.11675; %T/A/m. Quad 052 (third in triplet)
K(4)= 0.11658; %T/A/m. Quad 014
K(5)= 0.11597; %T/A/m. Quad 047


Size_Str=size(IntGrad);
Current_A=IntGrad;

for ii=1:1:Size_Str(2)
    if IntFlag==1
        GLact=IntGrad(ii)
    else
        GLact=IntGrad(ii)/LeffQuad;
    end
    Current_A(ii)=GLact/K(ID);
end
end

