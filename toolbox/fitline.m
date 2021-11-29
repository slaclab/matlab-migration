%
%fitline(x,y,[yerr])
%
%
%  [A,B,dA,dB,chisq] = fitline(x,y,[yerr])
%
%
%         Returns least squares fit parameters for the data
%         provided to match the form: 
%
%                 y = A*x + B
%
%         HVS 11/2007



function[A,B,dA,dB,chisq]=fitline(varargin)
  
%Initialize return values (just to be that way...)
A=0.0;
B=0.0;
dA=0.0;
dB=0.0;
chisq=0;

%Check the argument list
if nargin<=1
  errstring='too few arguments';
  disp(errstring);
  return;
elseif nargin>3;
  errstring='too many arguments';
  return;  
elseif nargin==2;
  yerr=ones(size(varargin{1}));
else
  yerr=varargin{3};
end;

x=varargin{1};
y=varargin{2};
  
% 11/07/09 fix problem of crash when given 
% zero for the yerr.
goodpoints=find(yerr~=0);
x=x(goodpoints);
y=y(goodpoints);
yerr=yerr(goodpoints);


temp=size(x);
sx=temp(2);
temp=size(y);
sy=temp(2);
temp=size(yerr);
syerr=temp(2);

if ~((sx==sy)&(sy==syerr))
   errstring='input vectors not of same length';
   disp(errstring);
   return;
end

N=sy;

% Build the matrix R representing the chisq minimization normal equations
% (simultaneous set of equations in A,B).

yerrsq=(yerr.*yerr);

X0=1;
X1=x;
X2=x.*x;


R(1,1)=sum(X2./yerrsq);
R(1,2)=sum(X1./yerrsq);  
R(2,1)=R(1,2);
R(2,2)=sum(X0./yerrsq);


% Build the K (known) vector which has our Y data in it.

K(1)=sum(y.*X1./yerrsq); 
K(2)=sum(y.*X0./yerrsq);
K=K';

% Invert R, apply it to K vector to get our U (unknown) vector
% of fit parameters. Diagonal elements of inv(R) are our 
% variances for each fit parameter.

INVR=inv(R);         %Invert R only once call it INVR
U=INVR*K;

A=U(1);
dA=sqrt(INVR(1,1));
B=U(2);
dB=sqrt(INVR(2,2));


chisq=sum((A.*x +B -y).^2)/(N-2);

