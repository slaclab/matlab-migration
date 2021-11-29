function Z = ZernFun(n,m,r,theta,nflag)
%   ZernFun evaluates the Zernike function of radial order n and circular
%   frequency m on the unit circle, at the position (r,theta) on the
%   unit circle.
%
%   The order "n" is a vector of nonnegative integers; "m" is a vector
%   the same number of elements as n, so that n(k) and m(k) form an n,m
%   pair. It may contain any integer from -n to +n in steps of 2 (so that
%   n-m is even).
%
%   The radius "r" is a vector of numbers between 0 and 1,and "theta" is a
%   vector of the same length containing angles.
%
%   The output "Z" is a matrix of Zernike values, with one column for
%   every (n,m) mode, and one row for every (r,theta) pair.
%
%   When the optional input argument "nflag" is set to 'norm', ZernFun
%   returns Zernike functions normalized with the factor
%       sqrt((2-delta(m,0))*(n+1)/pi),
%   chosen so that the integral of the square of one Zernike function Znm,
%   integrated over the unit circle (Znm(r,theta)^2*r*dr from r=0 to 1
%   and theta=0 to 2*pi) gives 1. The non-normalized polynomials are all
%   are defined to have a maximum of 1 for r=1 and some angle theta
%   (Znm(r=1,theta)=1 for all (n,m)).
%
%   The Zernike functions are an orthogonal basis on the unit circle.
%   They are used in disciplines such as astronomy, optics, and
%   optometry to describe functions on a circular domain.
%
%   The following table lists the first 15 Zernike functions.
%   {Neither Noll, nor Malacara}
%       n    m    Zernike function           Normalization
%       --------------------------------------------------
%       0    0    1                                 1
%       1   -1    r * cos(theta)                    2
%       1    1    r * sin(theta)                    2
%       2   -2    r^2 * cos(2*theta)             sqrt(6)
%       2    0    (2*r^2 - 1)                    sqrt(3)
%       2    2    r^2 * sin(2*theta)             sqrt(6)
%       3   -3    r^3 * cos(3*theta)             sqrt(8)
%       3   -1    (3*r^3 - 2*r) * cos(theta)     sqrt(8)
%       3    1    (3*r^3 - 2*r) * sin(theta)     sqrt(8)
%       3    3    r^3 * sin(3*theta)             sqrt(8)
%       4   -4    r^4 * cos(4*theta)             sqrt(10)
%       4   -2    (4*r^4 - 3*r^2) * cos(2*theta) sqrt(10)
%       4    0    6*r^4 - 6*r^2 + 1              sqrt(5)
%       4    2    (4*r^4 - 3*r^2) * cos(2*theta) sqrt(10)
%       4    4    r^4 * sin(4*theta)             sqrt(10)
%       --------------------------------------------------
%
%   Example 1:
%
%       % Display the Zernike function Z(n=5,m=1)
%       x = -1:0.01:1;
%       [X,Y] = meshgrid(x,x);
%       [theta,r] = cart2pol(X,Y);
%       idx = r<=1;
%       z = nan(size(X));
%       z(idx) = zernfun(5,1,r(idx),theta(idx));
%       figure
%       pcolor(x,x,z), shading interp
%       axis square, colorbar
%       title('Zernike function Z_5^1(r,\theta)')
%
%   Example 2:
%
%       % Display the first 10 Zernike functions
%       x = -1:0.01:1;
%       [X,Y] = meshgrid(x,x);
%       [theta,r] = cart2pol(X,Y);
%       idx = r<=1;
%       z = nan(size(X));
%       n = [0  1  1  2  2  2  3  3  3  3];
%       m = [0 -1  1 -2  0  2 -3 -1  1  3];
%       Nplot = [4 10 12 16 18 20 22 24 26 28];
%       y = zernfun(n,m,r(idx),theta(idx));
%       figure('Units','normalized')
%       for k = 1:10
%           z(idx) = y(:,k);
%           subplot(4,7,Nplot(k))
%           pcolor(x,x,z), shading interp
%           set(gca,'XTick',[],'YTick',[])
%           axis square
%           title(['Z_{' num2str(n(k)) '}^{' num2str(m(k)) '}'])
%       end
%
%   See also ZERNPOL, ZERNFUN2.

%   Paul Fricker 11/13/2006


% Check and prepare the inputs:
% -----------------------------
if ( ~any(size(n)==1) ) || ( ~any(size(m)==1) )
    error('zernfun:NMvectors','N and M must be vectors.')
end

if length(n)~=length(m)
    error('zernfun:NMlength','N and M must be the same length.')
end

n = n(:);
m = m(:);
if any(mod(n-m,2))
    error('zernfun:NMmultiplesof2', ...
          'All N and M must differ by multiples of 2 (including 0).')
end

if any(m>n)
    error('zernfun:MlessthanN', ...
          'Each M must be less than or equal to its corresponding N.')
end

if any( r>1 | r<0 )
    disp(['min(r) = ',num2str(min(r)),'; max(r) = ',num2str(max(r))]);
    error('zernfun:Rlessthan1','All R must be between 0 and 1.')
end

if ( ~any(size(r)==1) ) || ( ~any(size(theta)==1) )
    error('zernfun:RTHvector','R and THETA must be vectors.')
end

r = r(:);
theta = theta(:);
length_r = length(r);
if length_r~=length(theta)
    error('zernfun:RTHlength', ...
          'The number of R- and THETA-values must be equal.')
end

% Check normalization:
% --------------------
if nargin==5 && ischar(nflag)
    isnorm = strcmpi(nflag,'norm');
    if ~isnorm
        error('zernfun:normalization','Unrecognized normalization flag.')
    end
else
    isnorm = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the Zernike Polynomials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine the required powers of r:
% -----------------------------------
m_abs = abs(m);
rpowers = [];
for j = 1:length(n)
    rpowers = [rpowers m_abs(j):2:n(j)];
end
rpowers = unique(rpowers);

% Pre-compute the values of r raised to the required powers,
% and compile them in a matrix:
% -----------------------------
if rpowers(1)==0
    rpowern = arrayfun(@(p)r.^p,rpowers(2:end),'UniformOutput',false);
    rpowern = cat(2,rpowern{:});
    rpowern = [ones(length_r,1) rpowern];
else
    rpowern = arrayfun(@(p)r.^p,rpowers,'UniformOutput',false);
    rpowern = cat(2,rpowern{:});
end

% Compute the values of the polynomials:
% --------------------------------------
y = zeros(length_r,length(n));
for j = 1:length(n)
    s = 0:(n(j)-m_abs(j))/2;
    pows = n(j):-2:m_abs(j);
    for k = length(s):-1:1
        p = (1-2*mod(s(k),2))* ...
                   prod(2:(n(j)-s(k)))/              ...
                   prod(2:s(k))/                     ...
                   prod(2:((n(j)-m_abs(j))/2-s(k)))/ ...
                   prod(2:((n(j)+m_abs(j))/2-s(k)));
        idx = (pows(k)==rpowers);
        y(:,j) = y(:,j) + p*rpowern(:,idx);
    end
    
    if isnorm
        y(:,j) = y(:,j)*sqrt((1+(m(j)~=0))*(n(j)+1)/pi);
    end
end
% END: Compute the Zernike Polynomials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute the Zernike functions:
% ------------------------------
idx_pos = m>0;
idx_neg = m<0;

Z = y;
if any(idx_pos)
    Z(:,idx_pos) = y(:,idx_pos).*sin(theta*m(idx_pos)');
end
if any(idx_neg)
    Z(:,idx_neg) = y(:,idx_neg).*cos(theta*m(idx_neg)');
end

% EOF zernfun