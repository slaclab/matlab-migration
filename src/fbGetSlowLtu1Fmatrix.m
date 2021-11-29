function fmat = fbGetSlowLtu1Fmatrix()
%
% This function calculates the G and F matrices for the SlowLTU1
% feedback and set the FBCK:FB02:TR03 Matrix PVs (GMATRIX/FMATRIX)
% 

% This is Matlab code to get the presently used G & F matrices:
% r=model_rMatGet({'XCDL3' 'XCQT32' 'YCDL3' 'YCQT32'},'BPMT32');
% G=r(1:4,[2 8 16 22]);
%
% r=permute(model_rMatGet('BPMT32',{'BPMT32' 'BPMDL4'}),[2 1 3]);
% F= r(1:5,[1 7 3 9])';
%
% And this is to get the matrices for the BPMDL4 states location:
r=model_rMatGet({'XCDL3' 'XCQT32' 'YCDL3' 'YCQT32'},'BPMDL4');
G=r(1:4,[2 8 16 22]);

r=permute(model_rMatGet('BPMDL4',{'BPMT32' 'BPMDL4'}),[2 1 3]);
F=r(1:5,[1 7 3 9]);

msg=sprintf('Matrices calculated using BPMDL4 as reference:\n\n');
msg=sprintf('%sGMatrix: %s\n\n', msg, mat2str(G));
msg=sprintf('%sFMatrix: %s\n\n', msg, mat2str(F));
msg=sprintf(['%sDo you want to update the matrices? Please ' ...
             'stop/start feedback after the update.'], msg);

button = questdlg(msg,['Slow LTU1 ' ...
                    'Matrices'],'Yes','No','No');

switch button
  case 'Yes',  
    
    G2=reshape(G,1,numel(G));
    F2=reshape(F,1,numel(F));
    
    lcaPut('FBCK:FB02:TR03:GMATRIX',G2);
    lcaPut('FBCK:FB02:TR03:FMATRIX',F2);
end

exit;

