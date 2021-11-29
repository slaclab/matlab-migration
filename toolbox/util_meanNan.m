function y = util_meanNan(x, dim)

if nargin < 2
    dim=find(size(x) ~= 1,1);
    if isempty(dim), dim=1;end
end
bad=isnan(x);
x(bad)=0;
y=sum(x,dim)./sum(~bad,dim);
