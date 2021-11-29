function [s, sl, st] = slope(a,b)
% 
% this will give a vector the size of a (or b), with a variation of the error
% of the slope.
% F.-J. Decker
%
s0=ones(size(a,2),size(a,3));
for i=1:size(a,2)
  [p0, yf, p0std] = util_polyFit(a(:,i,:),b(:,i,:),1);
  sl(i)=p0(1);
  st(i)=p0std(1);
end
sl1 = s0.*(sl'*ones(1,size(a,3)));
dd=randn(size(sl1));
r=dd-mean(dd')'*ones(1,size(a,3));
rr= r ./ (std(r')' *ones(1,size(a,3)));
sl2=(st' *ones(1,size(a,3))) .*  rr;
s = reshape(sl1 +sl2,size(a));