function [bDesQ, bDesT] = control_magnetQtrimSet(name, bDes)

name=cellstr(name);
name=model_nameConvert(name(:));
nameQ=strrep(name,'QTRM','QUAD');
nameT=strrep(name,'QUAD','QTRM');

pQ=fliplr(control_magnetGet(nameQ,'IVBU'));
pT=fliplr(control_magnetGet(nameT,'IVBU'));

[bDesQ,bDesT]=deal(bDes*0);
iQ=9;
for j=1:numel(nameQ)
    iDes=polyval(pQ(j,:),bDes(j));
    iT=iDes-iQ;

    pQ(j,end)=pQ(j,end)-iQ;
    r=roots(pQ(j,:));
    bQ=[r(imag(r) == 0);NaN];bDesQ(j)=bQ(1);

    pT(j,end)=pT(j,end)-iT;
    r=roots(pT(j,:));
    bT=[r(imag(r) == 0);NaN];bDesT(j)=bT(1);
end
