function[] = calBpmLoadFileWriteParms(beamline)
%   calBpmLoadFileWriteParms
%
%   This script is used to load a saved .mat file of cavity BPM calibration data 
%   and call calBpmWriteParms, which implements the new calibration parameters, 
%   and calBpmPlotScale, which plots the scale changes. The purpose is to
%   implement a calibration from saved data.
%
%   This script is launched by an edm display shell command from bpm_cal_load_plot.edl.

path = pwd;

% Default to UNDH for backward-compatibility
if ( exist('beamline', 'var') ~= 1 )
    beamline = 'HXR'; % overridden by loaded .mat file
    cd /u1/lcls/physics/cavityBPM/calibration/data/prodCal/HXR
elseif ( strcmp(beamline, 'HXR') )
    cd /u1/lcls/physics/cavityBPM/calibration/data/prodCal/HXR
elseif ( strcmp(beamline, 'SXR') )
    cd /u1/lcls/physics/cavityBPM/calibration/data/prodCal/SXR
else
    disp( ['Invalid beamline argument ' beamline 'must be HXR or SXR'] ); 
end

uiopen('LOAD')

cd(path)

chk=1;

if ( exist('xsel','var') ~= 0 )
    bpmparms.sel = xsel;
    wsel = xwsel;
end

calBpmSummary(bpms, nbpms, bpmparms);
bpmsim = 0;
[rval, bpmparms] = calBpmWriteParms( bpms, bpmpvs, bpmparms, wsel, bpmsim, scanpvs, c );

if ( rval == 0 )
    msg = 'Implemented calibration and printed plot of scale changes to logbook';
elseif ( rval > 0 )
    msg = 'Calibration completed with errors (see EDM screens).';
    util_printLog_wComments( 1000, 'BPMCAL', 'Cavity BPM CalibrationScale Changes ', ' ', [1100 650] );
else
    msg = 'Failed to implement calibration';
end

calBpmLogMsg( msg );

calBpmPlotScale( bpmparms, nbpms, wsel );
