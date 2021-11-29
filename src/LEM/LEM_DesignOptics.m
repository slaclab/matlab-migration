function stat=LEM_DesignOptics()
%
% Run XAL design model; load bdes0, energy0, and kl0 values for MAGNETs in the
% selected LEM regions

% ------------------------------------------------------------------------------
% 01-APR-2009, M. Woodley
%    Separate storage of values for quadrupole Bmag displays
% ------------------------------------------------------------------------------

global controlFlags
useDesign=controlFlags(3);

global debugFlags
showTime=debugFlags(2);

global lemRegions
global MAGNET

% set controlFlag(3) to use design optics

controlFlags(3)=1;

% run the XAL model for the selected LEM regions (to get BDES and EACT)

tic
stat=1;
if (lemRegions(5))
  seqIdList=(7:10); % 50B1 to DUMP
  stat=[stat,LEM_RunXAL(seqIdList,0)];
  id=find([MAGNET.region]==5);
% for scaling
  [MAGNET(id).energy0]=MAGNET(id).energy;
  [MAGNET(id).bdes0]=MAGNET(id).bdes;
  [MAGNET(id).kl0]=MAGNET(id).kl;
% for quadrupole Bmag display
  [MAGNET(id).design_energy]=MAGNET(id).energy;
  [MAGNET(id).design_bdes]=MAGNET(id).bdes;
  [MAGNET(id).design_kl]=MAGNET(id).kl;
end
if (lemRegions(6))
  seqIdList=11; % BXG TO GUN SPECT DUMP
  stat=[stat,LEM_RunXAL(seqIdList,0)];
  id=find([MAGNET.region]==6);
% for scaling
  [MAGNET(id).energy0]=MAGNET(id).energy;
  [MAGNET(id).bdes0]=MAGNET(id).bdes;
  [MAGNET(id).kl0]=MAGNET(id).kl;
% for quadrupole Bmag display
  [MAGNET(id).design_energy]=MAGNET(id).energy;
  [MAGNET(id).design_bdes]=MAGNET(id).bdes;
  [MAGNET(id).design_kl]=MAGNET(id).kl;
end
if (lemRegions(7))
  seqIdList=12; % BX01 TO 135-MEV SPECT DUMP
  stat=[stat,LEM_RunXAL(seqIdList,0)];
  id=find([MAGNET.region]==7);
% for scaling
  [MAGNET(id).energy0]=MAGNET(id).energy;
  [MAGNET(id).bdes0]=MAGNET(id).bdes;
  [MAGNET(id).kl0]=MAGNET(id).kl;
% for quadrupole Bmag display
  [MAGNET(id).design_energy]=MAGNET(id).energy;
  [MAGNET(id).design_bdes]=MAGNET(id).bdes;
  [MAGNET(id).design_kl]=MAGNET(id).kl;
end
if (lemRegions(8))
  seqIdList=13; % 50B1 TO 52SL2
  stat=[stat,LEM_RunXAL(seqIdList,0)];
  id=find([MAGNET.region]==8);
% for scaling
  [MAGNET(id).energy0]=MAGNET(id).energy;
  [MAGNET(id).bdes0]=MAGNET(id).bdes;
  [MAGNET(id).kl0]=MAGNET(id).kl;
% for quadrupole Bmag display
  [MAGNET(id).design_energy]=MAGNET(id).energy;
  [MAGNET(id).design_bdes]=MAGNET(id).bdes;
  [MAGNET(id).design_kl]=MAGNET(id).kl;
end
if (any(lemRegions(1:4)))
  seqIdList=(1:6); % CATHODE to 50B1
  stat=[stat,LEM_RunXAL(seqIdList,0)];
  idr=find(lemRegions(1:4));
  for m=1:length(idr)
    n=idr(m);
    id=find([MAGNET.region]==n);
%   for scaling
    [MAGNET(id).energy0]=MAGNET(id).energy;
    [MAGNET(id).bdes0]=MAGNET(id).bdes;
    [MAGNET(id).kl0]=MAGNET(id).kl;
%   for quadrupole Bmag display
    [MAGNET(id).design_energy]=MAGNET(id).energy;
    [MAGNET(id).design_bdes]=MAGNET(id).bdes;
    [MAGNET(id).design_kl]=MAGNET(id).kl;
  end
end
stat=all(stat);
if (showTime)
  disp(sprintf('    LEM_DesignOptics: run XAL (t= %.3f)',toc))
end

% reset controlFlag(3) to its initial state

controlFlags(3)=useDesign;

end
