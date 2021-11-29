%% function used in double gaussian profile fit
% input:
%       args, which consists of:
%         args(1) = A    = amplitude 1
%         args(2) = mu   = center 1
%         args(3) = sig  = sigma 1
%         args(4) = A    = amplitude 2
%         args(5) = mu   = center 2
%         args(6) = sig  = sigma 2
%         args(7) = base = baseline
%       prof = profile to compare against function
%       x    = x values of profile
function [ diffsq ] = d2gauss2( args, prof, x )

[pk_val, pk_idx] = max(prof);
x_size = abs(x(end)-x(1));

% limit range of fit
l_idx = find(prof>0.01*pk_val,1,'first');
r_idx = find(prof>0.01*pk_val,1,'last');
prof  = prof(l_idx:r_idx);
x     = x(l_idx:r_idx);

% constrain variables to reasonable values
if args(1)<0 || args(3)<0 || args(4)<0 || args(6)<0 ...
        || args(5)>args(2) ...
        || args(7)>0.25*args(1)
%         || args(4)>args(1) || args(6)<args(3) ...
%         || args(7)<0 || args(7)>0.05*pk_val ...
%         || args(3)>0.5*x_size || args(6)>0.5*x_size ...
%         || args(6)>10*args(3) ...
%         || abs(args(5)-args(2))>2*args(3) %...
%         || (args(4)<0.05*args(1) && abs(args(5)-args(2))>0.5*args(3))
    diffsq = 1e32;
    return;
end

diff = prof - doublegauss(args,x);
diffsq = sum(diff.^2);

end
