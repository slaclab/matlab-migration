function stat=LEM_Set30Q()
%
% Compute BDES values for LI30 QUAD/QTRM pairs

% ------------------------------------------------------------------------------
% 16-JAN-2009, M. Woodley
%    Compute out-of-range bdes value (rather than NaN)
% 12-JAN-2009, M. Woodley
%    Put new BDES into PS.bnew (rather than PS.bdes) for QUADs
% ------------------------------------------------------------------------------

debug=0;

global controlFlags
useBDES=controlFlags(1); % use BDES values ... otherwise use BACT
if (useBDES)
  secn='BDES';
else
  secn='BACT';
end

global MAGNET PS

% compute power supply BDES values
% (set each QUAD to 9 amps; the remaining desired current from QTRM)

idm=find([MAGNET.scaleType]'==2);
Iq=9.0;
for n=1:length(idm)
  m=idm(n);
  name=MAGNET(m).name;
  bdes=MAGNET(m).bnew; % LEM-scaled value
  idq=strmatch(name,char(PS.name),'exact');
  tname=strcat(name,'_QTRM');
  idt=strmatch(tname,char(PS.name),'exact');

% get QUAD IVBU polynomial

  Query=strcat(PS(idq).dbname,':IVBU');
  try
    d=pvaGet(Query);
  catch
    error('*** %s',Query)
  end
  ivb=flipud(toArray(d));

% use QUAD IVB to compute total desired current

  ides=polyval(ivb,bdes);

% invert QUAD IVBU polynomial at Iq to get QUAD BDES

  bmin=PS(idq).bmin;
  bmax=PS(idq).bmax;
  c=ivb;
  c(end)=c(end)-Iq;
  r=roots(c);
  rr=real(r);
  ri=imag(r);
  idr=find((ri==0)&(rr>=bmin)&(rr<=bmax));
  if (isempty(idr))
    Bq=NaN;
  else
    Bq=r(idr);
  end
  PS(idq).bnew=Bq;
  PS(idq).setNow=1;
  if (isnan(Bq))
    PS(idq).bad=1;
  else
    PS(idq).bad=((Bq<bmin)|(Bq>bmax));
  end

% get present QUAD setpoint (for PS BDES Values)

  Query=strcat(PS(idq).dbname,':',secn);
  try
    Bqnow=pvaGet(Query, AIDA_DOUBLE);
  catch
    error('*** %s',Query)
  end
  PS(idq).bdes=Bqnow;

% get QTRM IVBU polynomial

  Query=strcat(PS(idt).dbname,':IVBU');
  try
    d=pvaGet(Query);
  catch
    error('*** %s',Query)
  end
  ivb=flipud(toArray(d));

% invert QTRM IVBU polynomial to get QTRM BDES

  bmin=PS(idt).bmin;
  bmax=PS(idt).bmax;
  It=ides-Iq;
  c=ivb;
  c(end)=c(end)-It;
  r=roots(c);
  rr=real(r);
  ri=imag(r);
  idr=find((ri==0)&(rr>=bmin)&(rr<=bmax));
  if (isempty(idr))
    Bt=fixupBdes(r,PS(idt).bdes);
  else
    Bt=r(idr);
  end
  PS(idt).bnew=Bt;
  PS(idt).setNow=1;
  if (isnan(Bt))
    PS(idt).bad=1;
  else
    PS(idt).bad=((Bt<bmin)|(Bt>bmax));
  end

% get present QTRM setpoint (for PS BDES Values)

  Query=strcat(PS(idt).dbname,':',secn);
  try
    Btnow=pvaGet(Query, AIDA_DOUBLE);
  catch
    error('*** %s',Query)
  end
  PS(idt).bdes=Btnow;

  if (debug)
    disp(sprintf('%s %+f %+f %+f %+f %+f %+f (%+f)',name, ...
      bdes,ides,Bq,Iq,Bt,It,Bq+Bt))
  end
end

stat=1;

end

function bdes=fixupBdes(r,bnow)
%
% Find bdes that is closest to bnow from roots of polynomial inversion; bdes
% will be out-of-range

rr=real(r);
ri=imag(r);
idr=find(ri==0);
if (isempty(idr))
  bdes=NaN; % all roots are imaginary ... sorry
else
  rr=rr(idr); % select real roots
  [d,id]=min(abs(rr-bnow));
  bdes=rr(id);
end

end
