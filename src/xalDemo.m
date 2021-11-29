%  xalDemo demonstrates how to load and run an XAL accelerator model from Matlab.
%
%  Usage: xalDemo
%
%  xalDemo is only intended as a template example from which users 
%  should create their own applications. Only the first 2 parts, 
%  "Import the relevant XAL java packages" and "get an XAL accelerator object"
%  should be considered common to all XAl apps.
%  
%
%  Side:  None
%
%  Auth:  Paul Chu
%  Rev:   31-Mar-2008, Greg White (greg)
%
%--------------------------------------------------------------
% Mods: (Latest to oldest)
%
%        31-Mar-2008, Greg White
%        Adapted for production model from standard directory.
%        Added header.
%
%============================================================== 

% XAL global initialization. 
xalsetup;

% get an XAL accelerator object
theAccelerator = XMLDataManager.acceleratorWithPath(XALMODEL_PROD);

% get a sequence
seq = theAccelerator.getSequence('BXG TO BX01');
seq2 = theAccelerator.getSequence('BX01 TO BX02');
% verify the sequence ID
%seq.getId

% put 2 sequences together
seqList = ArrayList();
seqList.add(seq);
seqList.add(seq2);
comboSeq = AcceleratorSeqCombo('newLine', seqList);

% create an online model "scenario"
scenario = Scenario.newAndImprovedScenarioFor(comboSeq);
% initiate a "probe" object for model calculation
%probe = ProbeFactory.getEnvelopeProbe(comboSeq, EnvTrackerAdapt(comboSeq));
probe = ProbeFactory.getTransferMapProbe(comboSeq, TransferMapTracker());
% assign the probe to the scenario
scenario.setProbe(probe);

% reset the probe object to initial state, i.e. the beginning
scenario.resetProbe;
% set scenario data source (default to 'design' lattice)
scenario.setSynchronizationMode(Scenario.SYNC_MODE_RF_DESIGN);
% synchronize with the data source
scenario.resync;

% run online model
scenario.run;

% get result as trajectory object
traj = probe.getTrajectory;

% get 'state' for a particular lattice element
state = traj.stateForElement('BPM5');
% print this element's longitudinal position
%pos = state.getPosition;
%pos

% get R-Matrix from one element to another
R_mat = traj.getTransferMatrix('XC04', 'XC07');
% R11
R_mat_11 = R_mat.getElem(0,0);
% R12
R_mat_12 = R_mat.getElem(0,1);

% get R-Matrix between 2 quads, QUAD:IN20:511 and QUAD:IN20:525
elem1 = traj.stateNearestPosition(seq.getNodeWithId('QE03').getPosition).getElementId;
elem2 = traj.stateNearestPosition(seq.getNodeWithId('QE04').getPosition).getElementId;
R_mat1 = traj.getTransferMatrix(elem1, elem2);
% R11
R_mat1_11 = R_mat1.getElem(0,0)

% get Twiss info from the state
twiss = state.getTwiss;
% get betaX
betaX = twiss(1).getBeta;

% use 'what-if'
% first, get a magnet
mag = seq.getNodeWithId('QM04');
% set a test value, e.g. increase the field by 1%
%testValue = mag.getDfltField()*1.01;
%scenario.setModelInput(mag, ElectromagnetPropertyAccessor.PROPERTY_FIELD, testValue);
% re-sync everything and re-run the model 
%scenario.resync;
%scenario.run;


