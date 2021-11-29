function stat=LEM_CollectData()
%
% stat=LEM_CollectData();
%
% Generate extant energy profile and run XAL to get magnet energy values
%
% OUTPUT:
%
%   stat = completion status

import gov.sns.ca.ChannelFactory
cf=ChannelFactory.defaultFactory;

global controlFlags
useIdeal=controlFlags(2);

global debugFlags
showTime=debugFlags(2);

global lemRegions
global MAGNET
global lemDataTime lemDataTimeout lemDataOld
global lemEref noFudgeCalc

% generate the extant energy profile

tic
[oldFudge,newFudge]=LEM_EnergyProfile();
lemDataTime=now;
v=datevec(lemDataTime);
v(5)=v(5)+lemDataTimeout; % timeout is in minutes
lemDataOld=datenum(v);
if (showTime)
  disp(sprintf('    LEM_CollectData: compute energy profile (t= %.3f)',toc))
end

% display the energy profile information

figure(1) % energy profile information always displays in Figure 1
if (noFudgeCalc)
  txt=[ ...
    {[' LEM Data Collected: ',datestr(lemDataTime)]}; ...
    {' '}; ...
    {' LEM reference energy values:'}; ...
    {' '}; ...
    {' Loc    Energy '}; ...
    {'        (GeV)  '}; ...
    {' ---  ---------'}; ...
    {sprintf(' Gun  %9.6f',lemEref(1))}; ...
    {sprintf(' BX0  %9.6f',lemEref(2))}; ...
    {sprintf(' BC1  %9.6f',lemEref(3))}; ...
    {sprintf(' BC2  %9.6f',lemEref(4))}; ...
    {sprintf(' BSY  %9.6f',lemEref(5))}; ...
    {' '}];
else
  txt=[ ...
    {[' LEM Data Collected: ',datestr(lemDataTime)]}; ...
    {' '}; ...
    {' Computed LEM fudge factors:'}; ...
    {' '}; ...
    {' Loc    Energy      Ideal      Current'}; ...
    {'        (GeV)       Fudge       Fudge'}; ...
    {' ---  ---------  ----------  ----------'}; ...
    {sprintf(' Gun  %9.6f',lemEref(1))}; ...
    {sprintf(' BX0  %9.6f  %10.6f  %10.6f',lemEref(2),newFudge(1),oldFudge(1))}; ...
    {sprintf(' BC1  %9.6f  %10.6f  %10.6f',lemEref(3),newFudge(2),oldFudge(2))}; ...
    {sprintf(' BC2  %9.6f  %10.6f  %10.6f',lemEref(4),newFudge(3),oldFudge(3))}; ...
    {sprintf(' BSY  %9.6f  %10.6f  %10.6f',lemEref(5),newFudge(4),oldFudge(4))}; ...
    {' '}];
  if (useIdeal)
    txt=[txt;{' NOTE: Ideal Fudge will be used to generate energy profile'}];
  else
    txt=[txt;{' NOTE: Current Fudge will be used to generate energy profile'}];
  end
end
plot(0,'w')
set(gca,'Position',[0,0,1,1],'XTick',[],'YTick',[])
text(0,0,txt,'HorizontalAlignment','left','VerticalAlignment','bottom','FontName','courier','FontSize',12);

% get pointers to MAGNETs that are in the selected LEM region(s)/groups

id=LEM_SelectedMagnets();

% zero energy/bdes/kl values

for m=1:length(id)
  n=id(m);
  MAGNET(n).energy=0;
  MAGNET(n).bdes=0;
  MAGNET(n).kl=0;
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
  disp(sprintf('    LEM_CollectData: run xal (t= %.3f)',toc))
end

% prepare PS structure for scaling

tic
stat=LEM_UpdatePS();
if (showTime)
  disp(sprintf('    LEM_CollectData: update PS (t= %.3f)',toc))
end

% load EACT PVs for selected MAGNETs

tic
for m=1:length(id)
  n=id(m);
  dbname=MAGNET(n).dbname;
  if (~MAGNET(n).epics)
    ic=strfind(dbname,':');ic1=ic(1);ic2=ic(2);
    dbname=strcat(dbname(ic1+1:ic2),dbname(1:ic1),dbname(ic2+1:end)); % unmunge
  end
  Query=strcat(dbname,':EACT');
  try
    ch=cf.getChannel(Query);
    ch.putVal(MAGNET(n).energy)
  catch
    error('*** %s',Query)
  end
end
if (showTime)
  disp(sprintf('    LEM_CollectData: put EPICS EACT (t= %.3f)',toc))
end

end
