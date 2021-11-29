function stat=LEM_LcavInfo()

global theAccelerator
global LCAV

allBnch=theAccelerator.getAllNodesOfType('Bnch');
nBnch=allBnch.size;
nLCAV=0;
for n=1:nBnch
  Bnch=allBnch.get(n-1);
  name=char(Bnch.getId);
  if (strmatch('TCAV',name)),continue,end
  nLCAV=nLCAV+1;
  LCAV(nLCAV).name=name;
  LCAV(nLCAV).dbname=char(Bnch.getEId);
  LCAV(nLCAV).seq=char(Bnch.getParent);
  LCAV(nLCAV).length=Bnch.getLength;
end
LCAV=LCAV';

stat=1;

end
