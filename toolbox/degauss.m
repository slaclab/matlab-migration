function degauss(MagnetName,factor,NCycles)
%
% degauss(MagnetName,factor,NCycles)
%
% FUNCTION : Degaussing procedure for the QG02 and QG03 magnet 
%           the procedure follows the steps established in  LCLS-TN-06-03
% 
%
%  INPUT:   
%           MagnetName  : 'QG02' or 'QG03'
%           factor      : fraction of field for next step  (default = 0.9)
%           NCycles     :  number of cycles (default = 25)
%

if nargin <2,
    factor = 0.9;
    NCycles = 25;
end
    
switch MagnetName
    case  'QG02'
        PVName = 'QUAD:IN20:811';
    case  'QG03'
        PVName = 'QUAD:IN20:831';
    otherwise
        disp('aborted ... you have to choose between QG02 and QG03');
       return;
end

Bmax = 4.8;  
for i = 1:NCycles,
    BRun = (-1)^i*factor^(i-1)*Bmax;
    [BACT,BDESnew] = trim_magnet(PVName,BRun);
    %[BACT,BDESnew] = perturb_magnet(PVName,BRun);
    str = sprintf('%2.2f',BDESnew);
    disp([ 'step ' num2str(i) ' out of ' num2str(NCycles) ' completed;  BDesNew = ' str]);
    end
[BACT,BDESnew] = trim_magnet(PVName,-.15);