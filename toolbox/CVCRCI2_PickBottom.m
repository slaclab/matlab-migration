function TF=PickBottom(Input, HowMany)
if(HowMany<=0)
    TF=false(size(Input));
    return
end
[~,b]=sort(Input,'ascend');
KEPT=round(length(Input)*HowMany/100);
if(KEPT==0)
    KEPT=1;
end

if(length(b)<KEPT)
    TF=true(size(Input));
else
    TF=false(size(Input));
    TF(b(1:KEPT))=true;
end