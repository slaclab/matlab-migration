function TF=PickLastEvents(AbsCounter, HowMany)
[~,b]=sort(AbsCounter,'descend');
if(length(b)<HowMany)
    TF=true(size(AbsCounter));
else
    TF=false(size(AbsCounter));
    TF(b(1:HowMany))=true;
end