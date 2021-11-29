function stat=LEM_UpdatePS()
%
% Prepare values in PS structure for scaling

% ------------------------------------------------------------------------------
% 01-APR-2009, M. Woodley
%    Don't scale magnets to zero
% 30-JAN-2009, M. Woodley
%    50Q1-3 now under EPICS control (50Q2 is master, others are slaves)
% ------------------------------------------------------------------------------

global controlFlags
K2B=controlFlags(4);

global lemRegions lemGroups

global lemConstants
Er=lemConstants(1); % electron rest mass (GeV)
clight=lemConstants(2); % speed of light (m/s)

global MAGNET PS

% compute new BDES values (bnew) and set "scaleNow" flags

for n=1:length(MAGNET)
  if (MAGNET(n).scaleFlag==0),continue,end % never scale these
  id=MAGNET(n).region;
  scaleNow=lemRegions(id);
  id=MAGNET(n).scaleGroup;
  scaleNow=(scaleNow&&lemGroups(id));
  MAGNET(n).scaleNow=scaleNow;
  if (~scaleNow),continue,end
  energy0=MAGNET(n).energy0; % GeV
  energy=MAGNET(n).energy; % GeV
  bdes=MAGNET(n).bdes;
  kl=MAGNET(n).kl;
  brho=1e10*sqrt(energy^2-Er^2)/clight; % kG-m
  if (MAGNET(n).ivbType==1)
    if (K2B)
      bnew=brho*MAGNET(n).kl0;
    else
      bnew=(energy/energy0)*bdes;
    end
  else
    bnew=energy;
  end
  MAGNET(n).bnew=bnew; % LEM-scaled value
  if (MAGNET(n).bnew==0)
    MAGNET(n).scaleNow=0; % don't scale magnets to zero
  end
end

% compute new power supply BDES values (bnew); check for out-of-range

[PS.bdes]=deal(0);
[PS.bnew]=deal(0);
[PS.setNow]=deal(0);
[PS.bad]=deal(0);

for n=1:length(MAGNET)
  if (~MAGNET(n).scaleNow),continue,end
  name=MAGNET(n).name;
  id=strmatch(name,char(PS.name),'exact');
  if (isempty(id)),continue,end
  bdes=MAGNET(n).bdes; % present value
  bnew=MAGNET(n).bnew; % LEM-scaled value
  bmin=MAGNET(n).bmin;
  bmax=MAGNET(n).bmax;
  PS(id).bdes=bdes;
  PS(id).bnew=bnew;
  PS(id).setNow=1;
  PS(id).bad=((bnew<bmin)|(bnew>bmax));
end

stat=1;
if (lemRegions(4))
  stat=[stat,LEM_LinacBoosterCheck()];
  stat=[stat,LEM_Set30Q()];
end
if (lemRegions(5))
  stat=[stat,LEM_SetLTUBend()];
end
stat=all(stat);

end
