function OUT=ImageMax(IN)
[SA,SB,SC]=size(IN);
OUT=zeros(SC,3);
for TT=1:SC
    [OUT(TT,1),ind]=max(reshape(IN(:,:,TT),[SA*SB,1]));
    [OUT(TT,2),OUT(TT,3)]=ind2sub([SA,SB],ind);
end