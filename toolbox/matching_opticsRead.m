function optics = matching_opticsRead(FileName)
%
%
% USAGE: 
%   optics=matching_opticsRead([FileName])
%
% INPUT:
%   FileName    : FileName of ascii file describing elements
% 
% OUPUT :
%   optics      : Structure containing beamline elements info
%
% 
% FUNCTION:
%  reads configuration parameters and optics parameters
% creates MATLAB structure optics with following fields  
%  for configuration
%       optics.location     : location of quadrupoles 
%       optics.Energy       : Energy at end of beamline 
%       optics.zVect        : z at begining beamline (for absolute z)
%       optics.reference    : screen of reference 
%       optics.goals        : goal twiss parameters 
% for optics 
%     nel       : place in beamline 
%     type      : typically  bend , quad, drift , ....
%     name      : 'QA01', 'D1'
%     length    : in [m]
%     nseg      : number of segments
%     align     : x,y,z, th_x, th_y , th_z  with respect to axis  [m or rad]
%     pc        : energy of central particle
%
%    'quad' has one more fields KL (kG) 
%    'linac' has three more fields ampl (MV/m) , phase (deg), edges ('on' or 'off')
%    'bend' 
% 

%quads_location = [];

fid0=fopen(FileName,'r');
% first three lines give location of quads, energy in, reference screen
F = fgets(fid0,256);
F = fgets(fid0,256);
optics.location = sscanf(F,'%f');
F = fgets(fid0,256);
F = fgets(fid0,256);
read_=sscanf(F,'%f %f');
optics.Energy = read_(1);
optics.zVect = read_(2);
F = fgets(fid0,256);
F = fgets(fid0,256);
reference = sscanf(F,'%s %*s %*s');
[optics.reference,reference]=strtok(reference,':');
if ~isempty(reference)
    optics.reference=char({optics.reference;reference(2:end)});
end
optics.sector = sscanf(F,'%*s %s %*s');
optics.measured = sscanf(F,'%*s %*s %s');
if isempty(optics.measured), optics.measured=optics.reference(1,:);end
F = fgets(fid0,256);
F = fgets(fid0,256);
optics.goals = sscanf(F,'%f');
 
F = fgetl(fid0);F(256:end)=[];
nel = 0;
while F~=-1
    if length(F)>3 && F(1)~= '!'
        nel = nel+1;
        optics(nel).name = strtok(F,' ');
        optics(nel).type = '';
        optics(nel).length = 0;
        optics(nel).nsegment = 1;
        optics(nel).KL = 0;
        optics(nel).sign = 0;
        optics(nel).factorE1 = 0;
        optics(nel).factorE2 = 0;
        optics(nel).angle = 0;
        optics(nel).roll = 0;
        optics(nel).hgap = 0;
        optics(nel).FINT = 0.5;

        switch optics(nel).name
            case 'drift'
                A =sscanf(F,'%*s %f %f %f');
                optics(nel).type = 'drift';
                optics(nel).length = A(1)*1e-2;        % from cm to m 
            case 'quad'
                A =sscanf(F,'%*s %f %f %f');
                B =sscanf(F,'%*s %*s %*s %*s %s');
                optics(nel).type = B;
                optics(nel).length = A(1)*1e-2;        % from cm to m
                optics(nel).KL = A(2)*1e-3*A(1);        % in kG (integrated strength)
            case 'linac'
                A =sscanf(F,'%*s %f %f %f');
                B =sscanf(F,'%*s %*s %*s %*s %s');
                optics(nel).type = B;
                optics(nel).length = A(1)*1e-2;        % from cm to m
                optics(nel).ampl = A(2);
                optics(nel).phase = A(3)*pi/180;       % from degree to rad 
            case 'screen'
                B = sscanf(F,'%*s %s');       
                optics(nel).type = B;
                optics(nel).nsegment = 0;
            case 'bend'
                % bend L Ra OutputFlag Wr  ar  b1 b2 ps1 ps2 R1  R2 K1 g/2 K2
                A =sscanf(F,'%*s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %c');
                B =sscanf(F,'%*s %*s %*s %*s %*s %*s %*s %*s %*s %s');
                optics(nel).type = B;
                optics(nel).length = A(1)*1e-2;        % from cm to m
                optics(nel).sign = A(3);
                optics(nel).angle=A(2)/180*pi*A(3);
                optics(nel).factorE1 = A(4);
                optics(nel).factorE2 = A(5);
                optics(nel).hgap=A(6)*1e-2;            %half-gap
                optics(nel).FINT = A(7);
            case 'und'
                A =sscanf(F,'%*s %f %f %f');
                B =sscanf(F,'%*s %*s %*s %*s %s');
                optics(nel).type = B;
                optics(nel).length = A(1)*1e-2;        % from cm to m
                optics(nel).KL = -A(2)*1e-3*A(1);   % in kG (integrated strength), ky^2=-KL/Bp/L, A(2)=kqlh*Bp*10
                BRho = optics(1).Energy*1e-3/299.792458*1e4; % kG m
                optics(nel).angle=sqrt(-optics(nel).KL*optics(nel).length/BRho); % To make kx^2=0=k1+(alpha/L)^2
            case 'matrix'
                optics(nel).type = 'matrix';
        end   % switch    R = R_gen6(L,angle,k1,roll,dum,E1,E2,hgap);
    end   % if
    F = fgetl(fid0);F(256:end)=[];
end
fclose(fid0);
