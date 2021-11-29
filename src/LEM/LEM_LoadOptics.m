function stat=LEM_LoadOptics()
%
% stat=LEM_LoadOptics();
%
% Load reference values (energy/bdes/kl) for selected MAGNETs
%
% OUTPUT:
%
%   stat = completion status

global debugFlags
showTime=debugFlags(2);

global lemRegions
global MAGNET
global lemEdesChannels
global lemEref

% generate the extant energy profile

tic
[oldFudge,newFudge]=LEM_EnergyProfile();
if (showTime)
  disp(sprintf('    LEM_LoadOptics: compute energy profile (t= %.3f)',toc))
end

% run the XAL model for the selected LEM regions (to get BDES and EACT)

tic
stat=1;
if (lemRegions(5))
  seqIdList=(7:10)'; % 50B1 to DUMP
  Ei=lemEref(5);
  stat=[stat,LEM_RunXAL(seqIdList,Ei)];
end
if (lemRegions(6))
  seqIdList=11; % BXG TO GUN SPECT DUMP
  Ei=lemEref(1);
  stat=[stat,LEM_RunXAL(seqIdList,Ei)];
end
if (lemRegions(7))
  seqIdList=12; % BX01 TO 135-MEV SPECT DUMP
  Ei=lemEref(2);
  stat=[stat,LEM_RunXAL(seqIdList,Ei)];
end
if (lemRegions(8))
  seqIdList=13; % 50B1 TO 52SL2
  Ei=lemEref(5);
  stat=[stat,LEM_RunXAL(seqIdList,Ei)];
end
if (any(lemRegions(1:4)))
  seqIdList=(1:6)'; % CATHODE to 50B1
  Ei=lemEref(1);
  stat=[stat,LEM_RunXAL(seqIdList,Ei)];
end
stat=all(stat);
if (~stat),return,end
if (showTime)
  disp(sprintf('    LEM_LoadOptics: run XAL (t= %.3f)',toc))
end

% get pointers to MAGNETs that are in the selected LEM region(s)/groups

id=LEM_SelectedMagnets();

% load reference values (energy/bdes/kl) for selected MAGNETs
% (NOTE: if a magnet's EDES is zero, use it's present energy as it's reference
%        energy)

tic
for m=1:length(id)
  n=id(m);
  try
    energy=lemEdesChannels(n).getValDbl;
  catch
    error('*** %s',char(lemEdesChannels(n).getId))
  end
  if (energy==0)
    MAGNET(n).energy0=MAGNET(n).energy;
  else
    MAGNET(n).energy0=energy;
  end
  MAGNET(n).bdes0=MAGNET(n).bdes;
  MAGNET(n).kl0=MAGNET(n).kl*(MAGNET(n).energy/MAGNET(n).energy0);
end
if (showTime)
  disp(sprintf('    LEM_LoadOptics: get EPICS EDES (t= %.3f)',toc))
end

stat=1;

end
