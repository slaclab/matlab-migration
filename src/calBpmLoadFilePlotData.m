function[] = calBpmLoadFilePlotData(mode, beamline)
%
%   Load a .mat file of cavity BPM calibration data and either
%   print a summary or plot all data, depending on m
%   The purpose is to view saved calibration data.
%
%   Launched by an edm display shell command from bpm_cal_load_plot.edl.
%
%   Argument: 
%               m       0 to print summary data
%                       1 to plot all calibration data
%

% Decommission this
% To be backward-compatible
% define c first
% c=0;

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

if ( exist('xsel','var') ~= 0 )
    make_bc = 1; % Loading data set with different data structures; must make backward-compatible
    sel = xsel;
else
    make_bc = 0;
end

% More backward-compatibility:
c.PLOT_OFF = 0;
c.PLOT_SINGLE = 1;
c.PLOT_ALL = 2;

% Fix u/bpmparms.vscl orientation
[rows,cols] = size( bpmparms.uscl );
if ( cols > rows )
    bpmparms.uscl = bpmparms.uscl';
    bpmparms.vscl = bpmparms.vscl';
end

calBpmSummary(bpms, nbpms, bpmparms);

% Dummy variables to make calBpmCookData happy
xdone = 0; ydone = 0;

if ( mode == 1 )
    for j=1:nbpms
        if ( bpmparms.sel(j) == 1 )
            if ( make_bc == 1 )
                bpm(j).ntriesX = 1;
                bpm(j).ntriesY = 1;
            end
            calBpmCookData( j, bpm(j), bpms{j}, mode, bpmparms.uscl_i(j), bpmparms.vscl_i(j), xdone, ydone, bpmparms.uscl(j), bpmparms.vscl(j), bpmparms.uphas(j), bpmparms.vphas(j), bpmparms.uv(j), bpmparms.vu(j), c );
        end
    end
end

calBpmPlotScale( bpmparms, nbpms, bpmparms.sel );

end

