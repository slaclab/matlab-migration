function [ Curr_A ] = correctorcurrent(CorrectorID,HorVertFlag,B_T)
% Calculate the current to apply to APEX Correctors to get a peak field B_T in T. 
% Return Curr_A in A.
% The center of the corrector (peak field)is located at z=0
% Sintax: correctorcurrent(Corrector ID, Hor./Vert. flag, Peak Field in T)
% If Corrector ID is different from 0,1,2,3,4,5,6 it assumes ID= 1
% HorVertFlag: hor.=0, vert.=1

if CorrectorID<1 | CorrectorID>6
    CorrectorID=1;
    ['WARNING: wrong corrector ID. Assumed corrector 1']
end
if HorVertFlag~=1 && HorVertFlag~=0
    HorVertFlag=0;
    ['WARNING: wrong HorVertFlag value. Assumed horizontal corrector']
end
Bh=correctorfield(CorrectorID,HorVertFlag,0,1);
Curr_A=B_T/Bh;
end

