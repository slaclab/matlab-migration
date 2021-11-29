function stat=LEM_Initialize(force)
%
% Check for the existence of a pre-generated LEM data structures file (contains
% the LCAV, MAGNET, and PS structures).  If the file exists and the creation
% date is later than the creation date of the XAL beamline definitions file
% (lcls.xdxf), load it.  Otherwise, create the structures and save a new file.

% ------------------------------------------------------------------------------
% 16-JAN-2009, M. Woodley
%   Use jca to connect to EDES and EACT PVs; optional input flag to force
%   rebuilding of structures (Reinitialize)
% ------------------------------------------------------------------------------

import gov.sns.ca.ChannelFactory

global debugFlags
showTime=debugFlags(2);

global xalDir accFile structFile
global LCAV MAGNET PS % to be saved in structures file
global lemEdesChannels lemEactChannels

if (nargin==0),force=0;end

d1=dir(structFile);
if (isempty(d1)||force)
  newFile=1;
else
  cmd=['grep "<optics_source" ',accFile];
  [s,r]=system(cmd);
  ic=strfind(r,'"');
  ic1=ic(end-1)+1;
  ic2=ic(end)-1;
  xdxfFile=r(ic1:ic2);
  xdxfFile=strcat(xalDir,xdxfFile);
  d2=dir(xdxfFile);
  newFile=(d2.datenum>d1.datenum);
end

if (newFile)

% LCAV structure

  tic
  stat=LEM_LcavInfo();
  if (showTime)
    disp(sprintf('    LEM_Initialize: create LCAV structure (t= %.3f)',toc))
  end

% MAGNET structure

  tic
  stat=LEM_MagnetInfo();
  if (showTime)
    disp(sprintf('    LEM_Initialize: create MAGNET structure (t= %.3f)',toc))
  end

% PS structure

  tic
  stat=LEM_PowerSupplyInfo();
  if (showTime)
    disp(sprintf('    LEM_Initialize: create PS structure (t= %.3f)',toc))
  end

% save the new structures file

  save(structFile,'LCAV','MAGNET','PS')
else
  load(structFile)
  stat=1;
end

if (~stat),return,end

% set up jca connections to EDES and EACT PVs

tic
cf=ChannelFactory.defaultFactory;
lemEdesChannels=javaArray('gov.sns.ca.Channel',length(MAGNET));
lemEactChannels=javaArray('gov.sns.ca.Channel',length(MAGNET));
for n=1:length(MAGNET)
  dbname=MAGNET(n).dbname;
  if (~MAGNET(n).epics)
    ic=strfind(dbname,':');ic1=ic(1);ic2=ic(2);
    dbname=strcat(dbname(ic1+1:ic2),dbname(1:ic1),dbname(ic2+1:end)); % unmunge
  end
  try
    lemEdesChannels(n)=cf.getChannel(strcat(dbname,':EDES'));
    lemEdesChannels(n).connectAndWait;
    lemEactChannels(n)=cf.getChannel(strcat(dbname,':EACT'));
    lemEactChannels(n).connectAndWait;
  catch
    error('*** %s EDES/EACT PV connect',dbname)
  end
end
if (showTime)
  disp(sprintf('    LEM_Initialize: connect to EDES/EACT PVs (t= %.3f)',toc))
end

end
