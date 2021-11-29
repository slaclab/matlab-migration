function xalBnchWrite(theAccelerator,kName,kStat,kAmpl,kPhas,kFudge,kPower)
%
% xalBnchWrite(theAccelerator,kName,kStat,kAmpl,kPhas,kFudge,kPower)
%
% Overwrite Bnch amplitude and phase values

% ------------------------------------------------------------------------------
% 30-JAN-2009, M. Woodley
%    Fix bug in handling of fudge factors for decelerating structures
% ------------------------------------------------------------------------------

xalImport

debug=0;

% get current XAL Bnch element data

allBnch=theAccelerator.getAllNodesOfType('Bnch');
nBnch=allBnch.size;

BnchId=cell(nBnch,1);
BnchLength=zeros(nBnch,1);
for n=1:nBnch
  Bnch=allBnch.get(n-1);
  BnchId{n}=char(Bnch.getId);
  BnchLength(n)=Bnch.getLength;
end

% process

if (debug)
  BnchAmp=zeros(nBnch,1);
  BnchPhase=zeros(nBnch,1);
end
gc='ABCD';
for n=1:length(kName)
  name=deblank(kName(n,:));
  idB=strmatch(name,BnchId);
  if (length(find(kPower(n,:)))==1) % no segmentation
    len=BnchLength(idB);
    if (kStat(n)==0)
      grad=0;
      phase=0;
      dEraw=0;
    else
      ampl=kAmpl(n); % MeV
      grad=ampl/len; % MeV/m
      phase=sum(kPhas(n,:)); % degrees
      phase=1e-6*round(1e6*phase); % round off phases to 1e-6 degrees
      dEraw=ampl*cosd(phase);
    end
    Bnch=allBnch.get(idB-1);
    if (dEraw<0)
      Bnch.setDfltCavAmp(grad/kFudge(n))
      if (debug),BnchAmp(idB)=grad/kFudge(n);end
    else
      Bnch.setDfltCavAmp(grad*kFudge(n))
      if (debug),BnchAmp(idB)=grad*kFudge(n);end
    end
    Bnch.setDfltCavPhase(phase)
    if (debug),BnchPhase(idB)=phase;end
  else
    len=zeros(1,4); % girder lengths
    for m=1:4
      if (kPower(n,m)~=0)
        gname=strcat(name,gc(m));
        id=strmatch(gname,BnchId);
        len(m)=sum(BnchLength(id));
      end
    end
    if (kStat(n)==0)
      G=0;
      phase=0;
    else
      G=kAmpl(n)/sum(sqrt(kPower(n,:)).*len); % "base" gradient
      phase=sum(kPhas(n,:)); % degrees
      phase=1e-6*round(1e6*phase); % round off phases to 1e-6 degrees
    end
    for m=1:4
      if (kPower(n,m)~=0)
        gname=strcat(name,gc(m));
        ampl=sqrt(kPower(n,m))*G*len(m); % MeV
        grad=ampl/len(m); % MeV/m
        dEraw=ampl*cosd(phase);
        idB=strmatch(gname,BnchId);
        Bnch=allBnch.get(idB-1);
        if (dEraw<0)
          Bnch.setDfltCavAmp(grad/kFudge(n))
          if (debug),BnchAmp(idB)=grad/kFudge(n);end
        else
          Bnch.setDfltCavAmp(grad*kFudge(n))
          if (debug),BnchAmp(idB)=grad*kFudge(n);end
        end
        Bnch.setDfltCavPhase(phase)
        if (debug),BnchPhase(idB)=phase;end
      end
    end
  end
end

if (debug)
  save debugData BnchId BnchLength BnchAmp BnchPhase
end

end
