% GUI handles

% MeasGUI - go to measurement screen
% MeasOptsGUI - go to measurement options screen
% CalGUI - go to calibration screen
% CalOptsGUI - go to calibration options screen

% Message - last issued cmlog message

% Save - saves bunch length measurement to soft IOC
% SaveToFile, SmallSaveToFile
% Restore - restores bunch length measurement
% ScreenIn - put screen in beam path
% ScreenOut - remove screen from beam path
% selScreen - menu of screens to select
% ScreenDesc - text name for selected screen

% Rate - beam rate
% RateEgu - beam rate engineering units
% RateDesc - beam rate description

% Measure - perform bunch length measurement
% mCancel - cancel Measure
% mImageAnalysis - go to image anaylsis of bunch length measurement data
% Measure1 - measure for one TCAV phase
% Measure2 - measure for second TCAV phase
% Measure3 - measure for third TCAV phase

% Calibrate - perform TCAV & BPM calibration
% cCancel - cancel calibration
% cImageAnalysis - go to image anaylsis of calibration data

% TCAVPDES, TCAVPDESDESC, TCAVPDESEGU
% TCAVPACT, TCAVPASTDESC, TCAVPACTEGU
% TCAVACTIVE

% IMGCNTOPTS
% NBI, NBIDESC - Number of background images
% NI, NIDESC - Number of foreground images

% TCAVCALOPTS
% STCAVPDES, STCAVPDESDESC, STCAVPDESEGU, STARTING - Starting TCAV calibration phase
% ETCAVPDES, ETCAVPDESDESC, ETCAVPDESEGU, ENDING - Ending TCAV calibration phase
% TCAVCN, TCAVCNDESC - Number of TCAV phase steps during calibration
% TPBZ, TPBZEGU, TPBZDESC - TCAV phase where BPM reads zero
% TPST, TPSTEGU, TPSTDESC - TCAV phase settle time

% selBPM - menu of BPMS to select

% PSCREEN - TCAV Phase to screen Calibration Panel
% screenCalConst, screenCalConstSign, screenCalconstSTD, screenCalConstEGU, screenCalConstDESC
% screenTCAVAACT, screenTCAVAACTEGU, screenTCAVAACTDESC
% selScreenCalConstAlg, screenCalConstTs
% CALIMGALG, CALIMGALGSEL

% BSCREEN - TCAV Phase to BPM Calibration Panel
% bpmCalConst, bpmCalConstEGU, bpmCalConstDESC
% bpmTCAVAACT, bpmTCAVAACTEGU, bpmTCAVAACTDESC
% bpmCalConstTs

% TCAVMEASOPTS - First Measurement Phase, Second Measurement Phase, and TORO TMIT Tolerance
% FPHASE, FPHASEEGU, FPHASEDESC1, FPHASEDESC2
% TPHASE, TPHASEEGU, TPHASEDESC1, TPHASEDESC2

% TOROOPTS
% TMITTOL, TMITTOLEGU, TMITTOLDESC

% CFOPANEL - Correction Function Options Panel
% CFOApply
% bpmMeasConst, bpmMeasConstEGU, bpmMeasConstDESC
% bpmMeasTCAVAACT, bpmMeasTCAVAACTEGU, bpmMeasTCAVAACTDESC
% bpmMeasConstTs
% bpmG, bpmGDESC
% bpmref, bpmrefEGU, bpmrefDESC
% bpmtol, bpmtolEGU, bpmtolDESC
% CFOMAXPULSES, CFOMAXPULSESDESC

% Calibration Results
% cplot - axes widget
% ctable - list box

% Measurement results, from tcav_bunchLength.m
% MM MMSTD MMEGU MMDESC
% SIGT SIGTSTD SIGTEGU SIGTDESC
% R35, R35STD, R35DESC
% MEAS_TS, table, plot, profile, NextProfile, PrevProfile, iProfile
% NEL, NELEGU, NELDESC
% MEASIMGALG, MEASIMGALGSEL

% Export - button to bring up figure suitable for printing to the eLog

% toTCAV0, toTCAV3
% Progress

% TCAVON, TCAVOFF
