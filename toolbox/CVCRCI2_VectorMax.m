function OUT=VectorMax(IN)
if(isrow(IN))
    [OUT(1,1),OUT(1,2)]=max(IN);
else
    [OUT(:,1),OUT(:,2)]=max(IN,[],2);  
end
    