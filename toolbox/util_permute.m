function B = util_permute(A, order)
% B = PERMUTE(A, ORDER)

order=int8(order);
nd=numel(order);
s=size(A);
if nd < numel(s)
    error('util_permute:orderWrong','ORDER must have at least N elements for an N-D array.');
end

if nd > numel(unique(order))
    error('util_permute:orderRep','ORDER cannot contain repeated permutation indices.');
end

if numel(setdiff(order,1:nd))
    error('util_permute:orderRep','ORDER contains an invalid permutation index.');
end

s(end+1:nd)=1;

newSize=s(order);

idList=1;

for j=1:nd
    idx=prod(s(1:j-1))*(0:s(j)-1);

    jn=find(j == order);
    nS1=ones(1,nd);nS1(jn)=s(j);
    nS2=newSize;nS2(jn)=1;

    idList=idList+repmat(reshape(idx,nS1),nS2);
end

B=reshape(A(idList),newSize);
