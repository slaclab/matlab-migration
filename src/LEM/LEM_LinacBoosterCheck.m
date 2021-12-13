function stat=LEM_LinacBoosterCheck()
%
% Compute BDES values for 50-LINE QUADs

debug=0;

global MAGNET PS

% set up list of micros

id=find([MAGNET.scaleType]>=20)';
isect=unique([MAGNET(id).scaleType])';

% compute desired booster current values

for n=1:length(isect)
  imicr=isect(n);
  idm=find([MAGNET.scaleType]==imicr)';
  Iquad=zeros(size(idm));
  for m=1:length(idm)
    id=idm(m);
    dbname=MAGNET(id).dbname;
    dbname=[dbname(6:10),dbname(1:5),dbname(11:end)]; % unmunge
    bdes=MAGNET(id).bnew; % LEM-scaled value

  % get QUAD IVBU polynomial

    Query=strcat(dbname,':IVBU');
    try
      d=pvaGet(Query);
    catch
      error('*** %s',Query)
    end
    ivb=flipud(toArray(d));

  % evaluate the IVBU polynomial to get desired current

    Iquad(m)=polyval(ivb,bdes);
  end

% LGPS current is lowest QUAD current (boosters provide the rest ... one
% booster is always, by definition, zero)

  Ilgps=min(Iquad);

% check the LGPS current

  Query=sprintf('LGPS:LI%02d:1:IMMO',imicr);
  try
    d=pvaGet(Query);
  catch
    error('*** %s',Query)
  end
  immo=toArray(d);
  bad=((Ilgps<min(immo))|(Ilgps>max(immo)));

  if (debug)
    disp(sprintf('LGPS:LI%02d:1 %+f %+f %+f',imicr, ...
      Ilgps,min(immo),max(immo)))
  end

% check the booster currents and set status

  for m=1:length(idm)
    id=idm(m);
    name=MAGNET(id).name;
    dbname=MAGNET(id).dbname;
    dbname=[dbname(6:10),dbname(1:5),dbname(11:end)]; % unmunge
    Query=strcat(dbname,':IMMO');
    try
      d=pvaGet(Query);
    catch
      error('*** %s',Query)
    end
    immo=toArray(d);
    Iboost=Iquad(m)-Ilgps;
    bad=(bad&&(Iboost>max(immo))); % if the LGPS is bad, QUADs are bad as well
    idps=strmatch(name,char(PS.name));
    PS(idps).bad=bad;

    if (debug)
      bdes=MAGNET(id).bnew; % LEM-scaled value
      disp(sprintf('%s %+f %+f %+f %+f',name, ...
        bdes,Iboost,min(immo),max(immo)))
    end
  end
end

stat=1;

end
