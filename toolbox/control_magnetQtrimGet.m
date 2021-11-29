function bDes = control_magnetQtrimGet(name, bDesQ, bDesT)

name=cellstr(name);
name=model_nameConvert(name(:));
nameQ=strrep(name,'QTRM','QUAD');
nameT=strrep(name,'QUAD','QTRM');

pQ=fliplr(control_magnetGet(nameQ,'IVBU'));
pT=fliplr(control_magnetGet(nameT,'IVBU'));

if nargin < 2
    bDesQ=control_magnetGet(nameQ,'BDES');
    bDesT=control_magnetGet(nameT,'BDES');
end

bDes=bDesQ*0;
for j=1:numel(nameQ)
    iQ=polyval(pQ(j,:),bDesQ(j));
    iT=polyval(pT(j,:),bDesT(j));
    iDes=iQ+iT;
    pQ(j,end)=pQ(j,end)-iDes;
    r=roots(pQ(j,:));
    bQ=[r(imag(r) == 0);NaN];bDes(j)=bQ(1);
end
