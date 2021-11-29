function [K,N,L,P,A,T,E,FDN,S,rmat,twss]=xalModel(accFile,seqIdList,syncMode,Ei,Twissi,kName,kStat,kAmpl,kPhas,kFudge,kPower)
%
% [K,N,L,P,A,T,E,FDN,S,rmat,twss]=xalModel(accFile,seqIdList,syncMode,Ei,Twissi,kName,kStat,kAmpl,kPhas,kFudge,kPower);
%
% INPUTs:
%
%   accFile   = name of XAL input file
%   seqIdList = contiguous list of LCLS sequences to be combined:
%
%     seqId  sequenceName
%     -----  ---------------------------
%        1   CATHODE TO BXG
%        2   BXG TO BX01
%        3   BX01 TO BX02
%        4   BX02 TO QM15
%        5   QM15 TO FV2
%        6   FV2 TO 50B1
%        7   50B1 TO BX31
%        8   BX31 TO WS31
%        9   WS31 TO UNDSTART
%       10   UNDSTART TO DUMP
%       11   BXG TO GUN SPECT DUMP
%       12   BX01 TO 135-MEV SPECT DUMP
%       13   50B1 TO 52SL2
%
%   syncMode  = XAL Synchronization Mode
%
%     syncMode  sequenceName         explanation
%     --------  -------------------  -------------------------------------------
%         1     SYNC_MODE_DESIGN     design values for everything
%         2     SYNC_MODE_RF_DESIGN  design values for LCAVs, "live" values for
%                                    everything else
%         3     SYNC_MODE_LIVE       "live" values for everything
%
% OPTIONAL INPUTs (used for running the extant machine model ...
%                  if syncMode>1 all must be provided):
%
%   Ei        = initial energy (GeV)
%   Twissi    = initial Twiss
%   kName     = KLYS root names
%   kStat     = KLYS trigger status values (0=OFF,1=ON)
%   kAmpl     = KLYS on-crest no-load energy gain values (MeV)
%   kPhas     = KLYS RF phase values [KLYS,SBST] (degrees)
%   kFudge    = KLYS LEM fudge factor values
%   kPower    = KLYS power factors for [a,b,c,d] sections (E ~ sqrt(P))
%
% OPTIONAL OUTPUTs (for each element):
%
%   K         = MAD keyword      [Nelement,4]
%   N         = name             [Nelement,*]
%   L         = length           [Nelement,1]
%   P         = parameter list   [Nelement,9]
%   A         = aperture         [Nelement,1]
%   T         = XAL type         [Nelement,*]
%   E         = total energy     [Nelement,1]
%   FDN       = EPICS name       [Nelement,*]
%   S         = suml             [Nelement,1]
%   rmat      = 6x6 R-matrix     [6*Nelement,6]
%   twss      = Twiss parameters [Nelement,10]

% ------------------------------------------------------------------------------
% 30-JAN-2008, M. Woodley
%    50Q1-3 now under EPICS control (50Q2 is master, others are slaves)
% 16-JAN-2008, M. Woodley
%    Collect pre-run steps for extant machine model into one place (just before
%    resync); write energy profile values (Bnch amplitude and phase) directly
%    into XAL java objects; switch from getTransferMatrix method to
%    getResponseMatrix method for faster execution; use JAMA method getArray to
%    extract R-matrix from java object; construct line name for comboSeq from
%    first and last sequence names
% 06-DEC-2008, M. Woodley
%    Fix FDN (database name) for LRfGap (LCAV) elements
% ------------------------------------------------------------------------------

global scenario % until the XML writer is faster ...

useBDES=1;
debug=0;

% input arguments and defaults

if (nargin<3)
  error('xalModel requires (at least) three arguments')
end
extant=(syncMode>1);
if (extant&&(nargin<11))
  error('xalModel requires 11 arguments for extant')
end

% java initialization for XAL

xalImport

% some parameter definitions

pETL=char(RfGapPropertyAccessor.PROPERTY_ETL);
pPHASE=char(RfGapPropertyAccessor.PROPERTY_PHASE);
pFREQ=char(RfGapPropertyAccessor.PROPERTY_FREQUENCY);
pFIELD=char(ElectromagnetPropertyAccessor.PROPERTY_FIELD);
deg2rad=pi/180; % radian/degree
twopi=2*pi;

% get the XAL accelerator object

theAccelerator=XMLDataManager.acceleratorWithPath(accFile);

% define the sequence names

seqName=[ ...
  {'CATHODE TO BXG'}; ...
  {'BXG TO BX01'}; ...
  {'BX01 TO BX02'}; ...
  {'BX02 TO QM15'}; ...
  {'QM15 TO FV2'}; ...
  {'FV2 TO 50B1'}; ...
  {'50B1 TO BX31'}; ...
  {'BX31 TO WS31'}; ...
  {'WS31 TO UNDSTART'}; ...
  {'UNDSTART TO DUMP'}; ...
  {'BXG TO GUN SPECT DUMP'}; ...
  {'BX01 TO 135-MEV SPECT DUMP'}; ...
  {'50B1 TO 52SL2'}; ...
];

% generate the line name

sname1=char(seqName(seqIdList(1)));
ic1=strfind(sname1,' TO ');
sname2=char(seqName(seqIdList(end)));
ic2=strfind(sname2,' TO ');
lineName=[sname1(1:ic1+3),sname2(ic2+4:end)];

% generate a combo sequence

seqList=ArrayList();
for n=1:length(seqIdList)
  seq=theAccelerator.getSequence(seqName{seqIdList(n)});
  seqList.add(seq);
end
comboSeq=AcceleratorSeqCombo(lineName,seqList);

% create the scenario

scenario=Scenario.newAndImprovedScenarioFor(comboSeq);

% create an Envelope probe object

probe=ProbeFactory.getEnvelopeProbe(comboSeq,EnvTrackerAdapt(comboSeq));

% get some XAL constants from the probe object

clight=probe.LightSpeed; % speed of light (m/sec)
Er=probe.getSpeciesRestEnergy; % electron rest energy (eV)
charge=probe.getSpeciesCharge; % sign of electron charge (=-1)

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
    error(sprintf('xalModelRmat: invalid syncMode (%d)',syncMode))
end

% pre-run steps for extant

if (extant)

% set Bnch amplitude and phase values

  xalBnchWrite(theAccelerator,kName,kStat,kAmpl,kPhas,kFudge,kPower)

% use BDES rather than BACT (if selected)

  if (useBDES)
    allEmag=comboSeq.getNodesOfType('emag');
    for n=1:allEmag.size
      emag=allEmag.get(n-1);
      emag.setUseFieldReadback(false)
    end
  end

% set XCORs and YCORs to zero

  allXCOR=comboSeq.getAllNodesOfType('XCOR');
  for n=1:allXCOR.size
    XCOR=allXCOR.get(n-1);
    scenario.setModelInput(XCOR,pFIELD,0);
  end
  allYCOR=comboSeq.getAllNodesOfType('YCOR');
  for n=1:allYCOR.size
    YCOR=allYCOR.get(n-1);
    scenario.setModelInput(YCOR,pFIELD,0);
  end

% set values for chicanes (if required)
% set values for LI30 QUAD/QTRM pairs (if required)

  if (ismember(2,seqIdList)) % BXG TO BX01
    xalModelBXH(comboSeq,scenario) % laser heater chicane
  end
  if (ismember(4,seqIdList)) % BX02 TO QM15
    xalModelBX1(comboSeq,scenario) % BC1 chicane
  end
  if (ismember(5,seqIdList)) % QM15 TO FV2
    xalModelBX2(comboSeq,scenario) % BC2 chicane
    xalModel30Q(comboSeq,scenario) % LI30 QUADs
  end

% reset the initial energy and Twiss

  Wi=(1e9*Ei)-Er; % initial kinetic energy (eV)
  probe.setKineticEnergy(Wi)
  psi=probe.getBetatronPhase;
  psi.setx(Twissi(1))
  psi.sety(Twissi(6))
  probe.setBetatronPhase(psi)
  twiss=probe.getTwiss;
  twiss(1).setTwiss(Twissi(3),Twissi(2),twiss(1).getEmittance)
  twiss(2).setTwiss(Twissi(8),Twissi(7),twiss(2).getEmittance)
  probe.initFromTwiss(twiss)
end

% synchronize with the database

scenario.resync

% run the model

scenario.run

% (temporarily) fix up the dispersion and phase advances

xalTwissFromRmat(probe)

% generate output arrays, if required

if (nargout>0)

% get result as trajectory object

  traj=probe.getTrajectory;
  Nelement=traj.numStates; % number of elements ("probe states")

% get the data

  K=cell(Nelement,1);
  N=cell(Nelement,1);
  L=zeros(Nelement,1);
  P=zeros(Nelement,9);
  A=zeros(Nelement,1);
  T=cell(Nelement,1);
  E=zeros(Nelement,1);
  FDN=cell(Nelement,1);
  S=zeros(Nelement,1);
  rmat=zeros(6*Nelement,6);
  twss=zeros(Nelement,10);

  for n=1:Nelement

  % generic element processing

    state=traj.stateWithIndex(n-1);
    name=char(state.getElementId);
    N{n}=name;
    Wf=state.getKineticEnergy; % kinetic energy (eV)
    E(n)=1e-9*(Wf+Er); % total energy (GeV)
    brho=sqrt((Wf+Er)^2-Er^2)/clight; % magnetic rigidity (T-m)
    S(n)=state.getPosition;
    if (n>1)
      L(n)=S(n)-S(n-1);
    end

  % first-order R-matrix

    R=state.getResponseMatrix.getMatrix.getArray;
    R=R(1:6,1:6);
    rmat(6*n-5:6*n,:)=R;

  % Twiss parameters

    psi=state.getBetatronPhase;
    twiss=state.getTwiss;
    twss(n,1)=psi.getx;
    twss(n,2)=twiss(1).getBeta;
    twss(n,3)=twiss(1).getAlpha;
    twss(n,4)=state.getChromDispersionX;
    twss(n,5)=state.getChromDispersionSlopeX;
    twss(n,6)=psi.gety;
    twss(n,7)=twiss(2).getBeta;
    twss(n,8)=twiss(2).getAlpha;
    twss(n,9)=state.getChromDispersionY;
    twss(n,10)=state.getChromDispersionSlopeY;

  % determine element type

    K{n}='';T{n}='';FDN{n}=''; % initialize
    if (isempty(name))
      if (debug),disp(sprintf('element with no name (%d)',n)),end
      continue
    end
    element=comboSeq.getNodeWithId(name);
    if (isempty(element))
      ename=strrep(name,'x','');
      ename=strrep(ename,'y','');
      element=comboSeq.getNodeWithId(ename);
    end
    if (isempty(element))
      if (L(n)~=0)
        isDrift=1;
      else
        if (debug),disp(['element ',name,' not in comboSeq']),end
        continue
      end
    else
      isDrift=0;
    end
    if (isDrift)
      Class='Drift';
    else
      Type=char(element.getType);
      T{n}=Type;
      Class=char(element.getClass);
      idc=strfind(Class,'.');
      Class=Class(idc(end)+1:end); % strip off "gov.sns.xal.smf.impl."
    end

  % keyword element processing

    switch Class
      case 'LRfGap'
        K{n}='LCAV';
        properties=scenario.propertiesForNode(element);
        freq=properties.get(pFREQ); % Hz
        ampl=properties.get(pETL); % eV
        phas=properties.get(pPHASE); % rad
        P(n,5)=1e-6*freq; % MHz
        P(n,6)=1e-6*ampl; % MeV
        P(n,7)=phas/twopi; % rad/2pi
        aBucket=element.getAper;
        A(n)=aBucket.getAperX/2; % half-gap
        parent=element.getParent;
        id=char(parent.getEId);
        ic=strfind(id,':');
        if (length(ic)>2)
          id(ic(3):end)=[]; % remove trailing ":__" and ":0"
        end
        FDN{n}=id;
      case 'Bend'
        K{n}='SBEN';
        mBucket=element.getMagBucket;
        leng=mBucket.getPathLength;
        designAngle=mBucket.getBendAngle;
        properties=scenario.propertiesForNode(element);
        field=properties.get(pFIELD); % T
        angle=charge*(field*leng)/brho; % rad
        P(n,1)=(L(n)/leng)*angle; % rad
        if (strcmp('YBEND',Type))
          P(n,4)=pi/2; % rad
        end
        if (designAngle==0)
          fentr=0.5;
          fexit=0.5;
        else
          fentr=abs(element.getEntrRotAngle/designAngle);
          fexit=abs(element.getExitRotAngle/designAngle);
        end
        P(n,5)=fentr*angle; % rad
        P(n,6)=fexit*angle; % rad
        P(n,9)=mBucket.getFringeIntegral; % new column for "FINT"
        aBucket=element.getAper;
        A(n)=aBucket.getAperX/2; % m
        id=char(element.getEId);
        FDN{n}=id;
      case 'Quadrupole'
        K{n}='QUAD';
        properties=scenario.propertiesForNode(element);
        field=properties.get(pFIELD); % T/m
        P(n,2)=charge*field/brho; % 1/m^2
        if (element.isSkew)
          P(n,4)=pi/4; % rad
        end
        aBucket=element.getAper;
        A(n)=aBucket.getAperX/2; % m
        id=char(element.getEId);
        FDN{n}=id;
      case 'Solenoid'
        K{n}='SOLE';
        properties=scenario.propertiesForNode(element);
        field=properties.get(pFIELD); % T
        P(n,5)=charge*field/brho; % 1/m
        aBucket=element.getAper;
        A(n)=aBucket.getAperX/2; % m
        id=char(element.getEId);
        FDN{n}=id;
      case 'USEG'
        K{n}='UNDU';
        properties=scenario.propertiesForNode(element);
        kund=properties.get(pFIELD); % undulator K-value
        P(n,1)=kund; % 1
        klam=element.getDfltLaMu; % undulator period length
        P(n,2)=klam; % m
        aBucket=element.getAper;
        A(n)=aBucket.getAperX/2; % half-gap
        id=char(element.getEId);
        FDN{n}=id;
      case 'BPM'
        K{n}='MONI';
        aBucket=element.getAper;
        A(n)=aBucket.getAperX/2; % half-gap
        id=char(element.getEId);
        FDN{n}=id;
      case 'HDipoleCorr'
        K{n}='HKIC';
        mBucket=element.getMagBucket;
        P(n,4)=deg2rad*mBucket.getBendAngle;
        aBucket=element.getAper;
        A(n)=aBucket.getAperX/2; % half-gap
        id=char(element.getEId);
        FDN{n}=id;
      case 'VDipoleCorr'
        K{n}='VKIC';
        mBucket=element.getMagBucket;
        P(n,5)=deg2rad*mBucket.getBendAngle;
        aBucket=element.getAper;
        A(n)=aBucket.getAperX/2; % half-gap
        id=char(element.getEId);
        FDN{n}=id;
      case 'TORO'
        K{n}='IMON';
        aBucket=element.getAper;
        A(n)=aBucket.getAperX/2; % half-gap
        id=char(element.getEId);
        FDN{n}=id;
      case 'Marker'
        K{n}='MARK';
        L(n)=element.getLength; % dS=0 for Markers
      case 'Drift'
        K{n}='DRIF';
      otherwise
        error(sprintf('xalModelRmat: unsupported XAL Class (%s)',Class))
    end
  end

% convert cell arrays of strings to character arrays

  K=char(K);
  N=char(N);
  T=char(T);
  FDN=char(FDN);

% fix up SBEN edge angle definitions

  idb=strmatch('SBEN',K);
  for n=1:length(idb)
    m=idb(n);
    name=deblank(N(m,:));
    ename=strrep(name,'x','');
    ename=strrep(ename,'y','');
    id=strmatch(ename,N);
    if (m==id(1))
      P(m,6)=0;
    elseif (m==id(end))
      P(m,5)=0;
    else
      P(m,5)=0;
      P(m,6)=0;
      P(m,9)=0;
    end
  end
end

end
