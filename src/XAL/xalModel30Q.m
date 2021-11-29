function xalModel30Q(comboSeq,scenario)
%
% stat=xalModel30Q(comboSeq,scenario);
%
% Compute and set XAL Field property for LI30 QUAD/QTRM pairs

debug=0;

% initialize

aidainit
try
  da=DaObject();
catch
  error('xalModel30Q: DaObject creation failed')
end

xalImport
pFIELD=char(ElectromagnetPropertyAccessor.PROPERTY_FIELD);

% set up lists

name=[{'Q30201'};{'Q30301'};{'Q30401'};{'Q30501'};{'Q30601'};{'Q30701'};{'Q30801'}];
unit=[201;301;401;501;601;701;801];

% select BDES or BACT

QUAD=comboSeq.getNodeWithId(name(1));
if (QUAD.useFieldReadback)
  secn='BACT';
else
  secn='BDES';
end

% so let it be written ...

if (debug)
  disp('name     bquad     iquad      bqtrm      iqtrm      bmin       bmax       imod       bmod       bxal')
end

for n=1:length(unit)
  if (n>1)
    QUAD=comboSeq.getNodeWithId(name(n));
  end

% get QTRM IVBU polynomial

  query=sprintf('QTRM:LI30:%d//IVBU',unit(n));
  try
    d=da.getDaValue(query);
  catch
    error('xalModel30Q: failed to get %s',query)
  end
  ivb=flipud(d.getFloats);

% compute QTRM current

  query=sprintf('QTRM:LI30:%d//%s',unit(n),secn);
  try
    d=da.getDaValue(query);
  catch
    error('xalModel30Q: failed to get %s',query)
  end
  bqtrm=d.getFloat;
  iqtrm=polyval(ivb,bqtrm);

% get QUAD IVBU polynomial

  query=sprintf('QUAD:LI30:%d//IVBU',unit(n));
  try
    d=da.getDaValue(query);
  catch
    error('xalModel30Q: failed to get %s',query)
  end
  ivb=flipud(d.getFloats);

% compute QUAD current

  query=sprintf('QUAD:LI30:%d//%s',unit(n),secn);
  try
    d=da.getDaValue(query);
  catch
    error('xalModel30Q: failed to get %s',query)
  end
  bquad=d.getFloat;
  iquad=polyval(ivb,bquad);

% set polynomial inversion limits

  query=sprintf('QUAD:LI30:%d//BMAX',unit(n));
  try
    d=da.getDaValue(query);
  catch
    error('xalModel30Q: failed to get %s',query)
  end
  bmax=d.getFloat;
  if (bmax>0)
    bmin=0;
  else
    bmin=bmax;
    bmax=0;
  end

% invert IVBU polynomial to get total integrated gradient

  imod=iquad+iqtrm;
  c=ivb;
  c(end)=c(end)-imod;
  r=roots(c);
  rr=real(r);
  ri=imag(r);
  id=find((ri==0)&(rr>=bmin)&(rr<=bmax));
  if (isempty(id))
    error('xalModel30Q: bad IMOD (%f) for QUAD:LI30:%d',imod,unit(n))
  end
  bmod=r(id);

% convert integrated gradient (kG) to gradient (T/m) with polarity

  kG2T_Gdl2G=0.1/QUAD.getLength;
  bxal=QUAD.getPolarity*kG2T_Gdl2G*bmod;

% poke it

  scenario.setModelInput(QUAD,pFIELD,bxal);

  if (debug)
    disp(sprintf('%s %+f %+f %+f %+f %+f %+f %+f %+f %+f',char(name(n)), ...
      bquad,iquad,bqtrm,iqtrm,bmin,bmax,imod,bmod,bxal))
  end
end

end
