function [] =  calBpmLogMsg(message)

% This function writes messages to the error-logging facility for BPM
% calibration routines.

facility = 'BPMCAL';
myErrInstance = getLogger(facility);
put2log(message);
