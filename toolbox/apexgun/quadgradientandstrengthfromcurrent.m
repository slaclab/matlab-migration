function [ IntGrad, IntStrength] = quadgradientandstrengthfromcurrent(Current_A, Energy_MeV, quadID, IntFlag)
% Sintax: [ IntGrad_T, IntStrength] = quadgradientandstrengthfromcurrent(Current_A, Energy_MeV, quadID, IntFlag)
% 
% If "IntFlag" is different from 1: calculate the quad integrated gradient GL and the integrated 
% strength at the given energy and current for APEX quadrupoles. 
% Return GL in T and IntStrength_m in m^-1 when a current I in A is applied to the quadrupole.
% 
% If "IntFlag"=1: calculate the quad gradient G and the  
% strength at the given energy and current for APEX quadrupoles. 
% Return G in T/m and IntStrength in m^-2 when a current I in A is applied to the quadrupole.
%
% quadID=1: quad 005, first of triplet
% quadID=2: quad 035, center of triplet
% quadID=3: quad 052, third of triplet
% quadID=4: quad 014
% quadID=5: quad 047
% 
% Current_I can be a vector. If that is the case also InTGrad and
% IntStrenght will be same size vectors.
% 
% Based on LBNL measurements by J. Doyle

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

Current_A=abs(Current_A);
if Current_A > 30
    Current_A=30;
    ['WARNING: Current too high. Current set to 30 A'] 
end

Gamma=1.957*Energy_MeV+1;
Betagamma=(Gamma^2-1)^(.5);
Brho=Betagamma*9.1095e-31*2.9979e8/1.6022e-19;

% Quad effective length in m
LeffQuad=0.0634;

% Quad gradient coefficients
K(1)= 0.11675; %T/A/m. Quad 005 (first in triplet)
K(2)= 0.11665; %T/A/m. Quad 035 (center in triplet)
K(3)= 0.11675; %T/A/m. Quad 052 (third in triplet)
K(4)= 0.11658; %T/A/m. Quad 014
K(5)= 0.11597; %T/A/m. Quad 047


Size_I=size(Current_A);
IntGrad=Current_A;
IntStrength=Current_A;

for ii=1:1:Size_I(2)
    Ic=Current_A(ii);
    IntGrad(ii)=K(ID)*Ic*LeffQuad;
end

if IntFlag==1
    IntGrad=IntGrad/LeffQuad;
end

IntStrength=IntGrad/Brho;


end

