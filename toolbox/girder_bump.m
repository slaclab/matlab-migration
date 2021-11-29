function [X,xpos,iok] = girder_bump(girder_number,amplitude,x_or_y)

%   [X,xpos,iok] = girder_bump(girder_number,amplitude,x_or_y);
%
%   Function to calculate an undulator 3-girder bump in X or Y at any
%   girder centered on numbers 2-32 (1 & 33 border girders are not
%   allowed).
%
%   INPUTS:
%               girder_number:  2-32 (integer).
%               amplitude:      The peak girder (quad) movement (mm) for the
%                               center girder (of 3) - (+-1 mm max).
%               x_or_y:         'x' or 'y' plane (upper or lower case OK)
%   OUTPUTS:
%               X:              3-vector of girder movements needed (mm)
%               xpos:           The accompanying beam position change at
%                               the center quad (mm).
%               iok:            =1 if all OK, or =0 if quad BDES too low
%                               (off?)

%========================================================================

if girder_number < 2 || girder_number > 32
  error('girder number is out of range (2-32)')
end

if abs(amplitude) > 1
  error('girder bump amplitude is out of range (-1 to +1 mm)')
end

if iscell(x_or_y)
  x_or_y = cell2mat(x_or_y);
end

if ~strcmp(lowcase(x_or_y),'x') && ~strcmp(lowcase(x_or_y),'y') 
  error('x_or_y can only be ''x'' or ''y''')
end

global modelSource modelOnline
modelSource='EPICS';
modelOnline=0;
Q1 = ['QUAD:UND1:' num2str(girder_number-1) '80'];
Q2 = ['QUAD:UND1:' num2str(girder_number)   '80'];
Q3 = ['QUAD:UND1:' num2str(girder_number+1) '80'];

R = model_rMatGet([{Q1};{Q1};{Q2};{Q3}],[{Q2};{Q3};{Q3};{Q3}],{'POS=MID', 'POSB=MID';'POS=MID','POSB=END';'POS=MID','POSB=END';'POS=MID','POSB=END'});
R12=R(:,:,1);
R13=R(:,:,2);
R23=R(:,:,3);
R33=R(:,:,4);
BDES1 = lcaGetSmart([Q1 ':BDES']);
BDES2 = lcaGetSmart([Q2 ':BDES']);
BDES3 = lcaGetSmart([Q3 ':BDES']);
iok = 1;
if abs(BDES1)<10 || abs(BDES2)<10 || abs(BDES3)<10
  disp('QUAD BDES values are less than 10 kG - too low.')
  X = [0 0 0]';
  xpos = 0;
  iok = 0;
  return
end
Energy = lcaGetSmart('BEND:DMP1:400:BDES'); % beam energy in GeV
Brho = Energy*1E10/2.99792458E8;

if strcmp(lowcase(x_or_y),'x')
  kk = 0;
  quad_sign = 1;
else
  kk = 2;
  quad_sign = -1;
end

A = [R12(1+kk,2+kk) 0              0
     R13(1+kk,2+kk) R23(1+kk,2+kk) R33(1+kk,2+kk)
     R13(2+kk,2+kk) R23(2+kk,2+kk) R33(2+kk,2+kk)];

Xn = inv(A)*[1 0 0]';
Xu = quad_sign*Brho*Xn./[BDES1 BDES2 BDES3]';
X  = Xu*amplitude/Xu(2);                            % movers required on consecutive quads to make this bump (mm)
xpos = R12(1+kk,2+kk)*Xn(1)*amplitude/Xu(2);        % beam position change at center quad (mm)
