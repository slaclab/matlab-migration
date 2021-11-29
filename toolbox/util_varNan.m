function y = util_varNan(x, w, dim)

if nargin < 3
    dim=find(size(x) ~= 1,1);
    if isempty(dim), dim=1;end
end
if nargin < 2
    w=0;
end
xm=util_meanNan(x,dim);
bad=isnan(x);
x(bad)=0;
n=sum(~bad,dim);
if w == 0
    denom=n-(n > 1);
else
    denom=n;
end
y=abs(sum(x.^2,dim)-xm.^2.*n)./denom;
