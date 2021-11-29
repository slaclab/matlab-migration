function [R,dR,chisq_ndf,T] = fit_soft(Q,s,c,sc,sig,func_flag,func_str);  

%FIT
%       [R,dR,chisq_ndf,T] = fit_soft(Q,s,c,sc[,sig,func_flag,func_str]);
%
%       Function to fit the data in column vector "s" to the curve given by
%       the linear combination of the functions in "Q" with soft constraints
%       "const" of sigma "sig_const" on the fitted coefficients.  
%       The matrix "Q" is
%       made up of n column vectors, each of which is a separate function.
%       There are n such funtions each of which is evaluated at N points,
%       and so the matrix "Q" is N rows by n columns.  The
%       column vector "s" has N rows.  The column vector "R" is output with
%       n rows, each of which is a coefficient of the fit.  The "chisq_ndf"
%       is a scalar as a measure (per degree of freedom) of the goodness of
%       fit ( ~1 is good, but this scales with the inverse square of "sig", 
%       if "sig" is a constant).
%                        
%       (NOTE:    N       is the number of points to fit
%                 n       is the number of known functions)
%
%     e.g.      y1 = Q11*R1 + Q12*R2 + ... + Q1n*Rn
%               y2 = Q21*R1 + Q22*R2 + ... + Q2n*Rn
%               .       .       .               .
%               .       .       .               .
%               yN = QN1*R1 + QN2*R2 + ... + QNn*Rn,
%     or
%               for yi = m*xi + b,      then Q = [x' ones(N,1)],
%                                            s = [y1 y2 ... yN]',
%                                          sig = (guess at s resolutions)
%                                            R = [m b]', 
%
%
%     INPUTS:   Q:              Known functions matrix (N rows by n columns)
%               s:              Column vector of data to fit to (N rows)    
%               c:              The soft constraint vector (n rows)
%               sc:             The soft constraint sigma vector (n rows)
%               sig:            (Optional) Column vector of expected errors
%                               in fit with N rows, or a scalar which is
%                               assumed to be the actual errors at each 
%                               point.  If "sig" is not given, all errors
%                               at each fit point are assumed the same, and
%                               the dR errors are rescaled by renormalizing 
%                               "chisq_ndf" to 1.
%     OUTPUTS:  R:              Fit coefficients (column vector of n rows)
%               dR:             Errors on fitted coefficients (vector of n
%                               rows)
%               chisq_ndf:      Goodness of fit scalar of normalized to the
%                               number of degrees of freedom (NDF = N - n).

%==========================================================================

if ~exist('func_flag')
  func_flag = 0;
end

s  = s(:);
c  = c(:);
sc = sc(:);
i = find(sc==0);
if length(i) >= 1
  error('Constraint sigmas cannot be = 0')
end

sc2 = sc.^(-2);

if exist('sig')==0,
  sig = 1;
  renorm = 1;
else
  sig = sig(:);
  renorm = 0;
end

[N,n] = size(Q);
if n > N,
  error('Sorry, you don''t have enough points to fit to this curve')
end

n_sig = length(sig);

if n_sig == 1,
  sig = sig * ones(N,1);
elseif n_sig ~= N,
  disp(' ')
  disp('*** NUMBER OF SIGMAS MUST BE SAME AS NUMBER OF POINTS ***')
  disp(' ')
  return         
end

B = Q./(sig*ones(1,n));
NDF = N - n;                            % number of degrees of freedom
if n == N,
  NDF = 1;
end

z = s./sig;                             % normalize coordinates
T = inv( B'*B + diag(sc2) );
R = T*(B'*z + c.*sc2);   
dR = diag(sqrt(T));

if func_flag                            % if want some arbitrary function of R's
  if ~exist('func_str')                 % if function string not given...
    [R,dR] = f_of_u(R,T);               % ...you will be prompted
  else                                  % if function string IS given...
    [nr,nc] = size(func_str);           % ...each row is a new function string
    for j = 1:nr
      [R(j),dR(j)] = f_of_u(R,T,func_str(j,:)); % R(j) and dR(j) as f(u)
    end
  end
end

chisq_ndf = (z'*z - z'*B*T*B'*z)/NDF;   % calculate normalized chi squared

if renorm
  chi = sqrt(chisq_ndf);
  dR = dR*chi;
  chisq_ndf = 1;
end
