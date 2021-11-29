function stat=LEM_RunXAL(seqIdList,Ei)
%
% Run XAL model; load bdes, energy, and kl values for MAGNETs in the
% selected LEM regions

% ------------------------------------------------------------------------------
% 01-APR-2009, M. Woodley
%    Use magnet effective length (if nonzero) in computation of BDES for
%    non-energy-polynomial magnets whose effective length is nonzero
% 31-MAR-2009, M. Woodley
%    Retain design values (computed at LEM initialization) for quadrupole Bmag
%    displays
% 30-JAN-2009, M. Woodley
%    50Q1-3 now under EPICS control (50Q2 is master, others are slaves)
% 21-JAN-2008, M. Woodley
%    Catch XAL run-time errors ... float bad status up the chain
% 16-JAN-2008, M. Woodley
%    Collect pre-run steps for extant machine model into one place (just before
%    resync); write energy profile values (Bnch amplitude and phase) directly
%    into XAL java objects; get MAGNET Twiss parameters when running design
% ------------------------------------------------------------------------------

xalImport
import gov.sns.tools.ArrayValue

global controlFlags
useBDES=controlFlags(1);
useDesign=controlFlags(3);

global lemConstants
Er=lemConstants(1); % electron rest mass (GeV)
clight=lemConstants(2); % speed of light (m/s)

global lemRegions
global accFile
global seqName
global theAccelerator
global MAGNET

if (useBDES)
  channelHandle='fieldSet';
else
  channelHandle='fieldRB';
end

if (useDesign)
  syncMode=1;
else
  syncMode=2;
end

pFIELD=char(ElectromagnetPropertyAccessor.PROPERTY_FIELD);

% regenerate the XAL accelerator object

theAccelerator=XMLDataManager.acceleratorWithPath(accFile);

% generate a combo sequence

seqList=ArrayList();
for n=1:length(seqIdList)
  seq=theAccelerator.getSequence(seqName{seqIdList(n)});
  seqList.add(seq);
end
comboSeq=AcceleratorSeqCombo('newLine',seqList);

% create the scenario

scenario=Scenario.newAndImprovedScenarioFor(comboSeq);

% create the probe object
% (NOTE: use an Envelope probe when running design since we need to extract
%        Twiss parameters; us a TransferMap probe when running extant since it's
%        slightly faster)

if (useDesign)
  probe=ProbeFactory.getEnvelopeProbe(comboSeq,EnvTrackerAdapt(comboSeq));
else
  probe=ProbeFactory.getTransferMapProbe(comboSeq,TransferMapTracker());
end

% assign the probe to the scenario

scenario.setProbe(probe)

% reset the probe object to it's initial state, i.e. before propagation

scenario.resetProbe

% set scenario data source

% SYNC_MODE_DESIGN    = design values from lcls.xdxf for everything
% SYNC_MODE_RF_DESIGN = design values from lcls.xdxf for LCAVs, "live" values
%                       for everything else
% SYNC_MODE_LIVE      = "live" values for everything

switch syncMode
  case 1
    scenario.setSynchronizationMode(Scenario.SYNC_MODE_DESIGN)
  case 2
    scenario.setSynchronizationMode(Scenario.SYNC_MODE_RF_DESIGN)
  case 3
    scenario.setSynchronizationMode(Scenario.SYNC_MODE_LIVE)
  otherwise
    error('LEM_RunXAL: invalid syncMode (%d)',syncMode)
end

% pre-run steps (when running the extant machine model)

if (syncMode>1)

% set Bnch amplitude and phase values

  stat=LEM_xalBnchWrite();

% use BDES rather than BACT (if selected)

  if (useBDES)
    allEmag=theAccelerator.getAllNodesOfType('emag');
    for n=1:allEmag.size
      emag=allEmag.get(n-1);
      emag.setUseFieldReadback(false)
    end
  end

% set values for LI30 QUAD/QTRM pairs (if required)

  stat=LEM_Get30Q(scenario);

% set the initial energy

  if (Ei>0)
    Wi=1e9*(Ei-Er); % initial kinetic energy (eV)
    probe.setKineticEnergy(Wi)
  end
end

% synchronize with the database

try
  scenario.resync
catch
  disp('*** XAL resync failed')
  stat=0;
  return
end

% run the model

scenario.run

% get result as trajectory object

traj=probe.getTrajectory;

% determine which LEM regions were included in this run

if (any(ismember(seqIdList,(1:6))))
  xalRegions=(1:4);
elseif (any(ismember(seqIdList,(7:10))))
  xalRegions=5;
elseif (seqIdList==11)
  xalRegions=6;
elseif (seqIdList==12)
  xalRegions=7;
elseif (seqIdList==13)
  xalRegions=8;
else
  error('Unknown seqId (%d)',seqId(1))
end

% extract energy, bdes, and kl values for MAGNETs in the selected LEM regions

T2kG=10; % kG/T
for n=1:length(MAGNET)
  region=MAGNET(n).region;
  if (~ismember(region,xalRegions)),continue,end % not in XAL run
  if (~lemRegions(region)),continue,end % not in selected LEM regions
  name=MAGNET(n).name;
  node=comboSeq.getNodeWithId(name);
  state=traj.stateForElement(name);
  W=state.getKineticEnergy;
  energy=(1e-9*W)+Er;
  brho=1e10*sqrt(energy^2-Er^2)/clight; % kG-m
  properties=scenario.propertiesForNode(node);
  field=properties.get(pFIELD);
  efflen=node.getEffLength;
  polarity=node.getPolarity;
  if ((efflen==0)||(MAGNET(n).ivbType==2))
    channel=node.getChannel(channelHandle);
    transform=channel.getValueTransform;
    value=doubleValue(transform.convertToRaw(ArrayValue.doubleStore(field)));
  else
    value=T2kG*field*efflen;
  end
  MAGNET(n).energy=energy;
  MAGNET(n).bdes=polarity*value;
  if (MAGNET(n).ivbType==2) % energy polynomial ... XBEND (or YBEND) only
    mBucket=node.getMagBucket;
    leng=mBucket.getPathLength;
    MAGNET(n).kl=T2kG*field*leng/brho;
  else
    MAGNET(n).kl=MAGNET(n).bdes/brho;
  end
  if (useDesign)
    Twiss=state.getTwiss;
    betax=Twiss(1).getBeta;
    betay=Twiss(2).getBeta;
    MAGNET(n).design_betax=betax;
    MAGNET(n).design_betay=betay;
  end
end

stat=1;

end
