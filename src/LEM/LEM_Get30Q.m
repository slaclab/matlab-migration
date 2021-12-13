function stat=LEM_Get30Q(scenario)
%
% Compute and set XAL Field property for LI30 QUAD/QTRM pairs

debug=0;

xalImport

global controlFlags
useBDES=controlFlags(1);

global theAccelerator
global MAGNET

% set up lists

id=find([MAGNET.scaleType]'==2);
name=char(MAGNET(id).name);
dbname=char(MAGNET(id).dbname);
dbname=[dbname(:,6:10),dbname(:,1:5),dbname(:,11:end)]; % unmunge
bmin=[MAGNET(id).bmin]';
bmax=[MAGNET(id).bmax]';

% select BDES or BACT

if (useBDES)
  secn='BDES';
else
  secn='BACT';
end

% so let it be written ...

pFIELD=char(ElectromagnetPropertyAccessor.PROPERTY_FIELD);
for n=1:length(id)

% get QTRM IVBU polynomial

  Query=strcat(strrep(dbname(n,:),'QUAD','QTRM'),':IVBU');
  d=pvaGet(Query);
  ivb=flipud(toArray(d));

% compute QTRM current

  Query=strcat(strrep(dbname(n,:),'QUAD','QTRM'),':',secn);
  bqtrm=pvaGet(Query, AIDA_DOUBLE);
  iqtrm=polyval(ivb,bqtrm);

% get QUAD IVBU polynomial

  Query=strcat(dbname(n,:),':IVBU');
  d=pvaGet(Query);
  ivb=flipud(toArray(d));

% compute QUAD current

  Query=strcat(dbname(n,:),':',secn);
  bquad=pvaGet(Query,AIDA_DOUBLE);
  iquad=polyval(ivb,bquad);

% invert IVBU polynomial to get total integrated gradient

  imod=iquad+iqtrm;
  c=ivb;
  c(end)=c(end)-imod;
  r=roots(c);
  rr=real(r);
  ri=imag(r);
  idr=logical((ri==0)&(rr>=bmin(n))&(rr<=bmax(n)));
  bmod=r(idr);

% convert integrated gradient (kG) to gradient (T/m) with polarity

  QUAD=theAccelerator.getNodeWithId(name(n,:));
  kG2T_Gdl2G=QUAD.getPolarity*(0.1/QUAD.getEffLength);
  bxal=kG2T_Gdl2G*bmod;

% poke it

  scenario.setModelInput(QUAD,pFIELD,bxal);

  if (debug)
    disp(sprintf('%s %+f %+f %+f %+f %+f %+f %+f %+f %+f (%+f)',name(n,:), ...
      bquad,iquad,bqtrm,iqtrm,bmin(n),bmax(n),imod,bmod,bxal,bquad+bqtrm))
  end
end

stat=1;

end
