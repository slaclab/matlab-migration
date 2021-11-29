function control_launchFB(region, varargin)
%CONTROL_LAUNCHFB
%  CONTROL_LAUNCHFB(REGION, OPTS) setup and run feedback using BPMs and correctors specified by REGION.

% Features:

% Input arguments:
%    REGION: Area names or unit number ranges
%    OPTS:   Options struct
%            GAIN:    Feedback gain
%            NSAMPLE: Number of shots to average
%            WAIT:    Wait time between corrections
%            DOPLOT:  Plot fits
%            USEINIT: Fit initial launch
%            STATE:   Initial feedback state
%            PV:      Control PV for feedback (and gain)

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: util_parseOptions, gui_BSAControl, bba_simulInit,
%                   bba_responseMatGet, bba_bpmDataGet, bba_fitOrbit,
%                   bba_plotCorr, bba_plotOrbit, lcaGet, bba_corrGet,
%                   bba_corrSet, util_appClose

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'gain',.5, ...
    'nSample',10, ...
    'wait',1, ...
    'doPlot',1, ...
    'useInit',0, ...
    'state',1, ...
    'PV',[] ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Initialize BSA buffer.
handles=gui_BSAControl([],['LAUNCH_FB_' datestr(now,'HHMMSS_FFF')],1,opts.nSample);
if ~handles.eDefNumber, disp('No event definition available');return, end

% Initialize BBA.
handles.dataSample.nVal=opts.nSample;
handles.static=bba_simulInit('sector',region);
handles.data.en=0;

% Initialize feedback state PV.
state=opts.state;
statePV=opts.PV;
sys=getSystem;
if isnumeric(statePV), statePV=strcat('SIOC:',sys,':ML00:AO',num2str(opts.PV(:),'%03d'));end
statePV=cellstr(statePV);
if ~isempty(opts.PV)
    lcaPut(statePV(1),state);
    if numel(statePV) > 1
        lcaPut(statePV(2),opts.gain);
    end
end

% Main feedback loop.
while state ~= -1

    % Check energy.
    [d,en]=bba_responseMatGet(handles.static,1,1);
    if en ~= handles.data.en
        [handles.data.R,handles.data.en]=bba_responseMatGet(handles.static,1);
    end

    % Acquire BPM data.
    handles.data.xMeas=bba_bpmDataGet(handles.static,handles.data.R,1,handles,'tmit',1);
    handles.data.ts=now;

    % Fit orbit & plot
    xMeas=handles.data.xMeas(1:2,:,:);
    xMeasStd=std(xMeas,0,3)/sqrt(size(xMeas,3));
    xMeas=mean(xMeas,3);

    opts.use=struct('init',opts.useInit,'quad',0,'BPM',0,'corr',1);
    opts.fitSVDRatio=1e-6;
    f=bba_fitOrbit(handles.static,handles.data.R,xMeas,xMeasStd,opts);
    handles.data.xMeasF=xMeas-f.xMeasF;

    % Plot results.
    if opts.doPlot
        opts.figure=3;opts.axes={2 2 2;2 2 4};
        bba_plotCorr(handles.static,-f.corrOff,1,opts);
        opts.title=['BBA Scan Orbit ' datestr(handles.data.ts)];
        opts.figure=3;opts.axes={2 2 1;2 2 3};
        bba_plotOrbit(handles.static,xMeas,xMeasStd,handles.data.xMeasF,handles.data.en,opts);
    end

    % Read feedback state/gain PV
    if ~isempty(opts.PV)
        state=lcaGet(statePV(1));
        if numel(statePV) > 1
            opts.gain=lcaGet(statePV(2));
        end
    end
    
    % Check TMIT.
    if any(handles.data.xMeas(3,:) < 1e8), disp([datestr(now) ' TMIT too low']);continue, end

    % Check state PV
    if state < 1, pause(opts.wait);disp([datestr(now) ' Compute']);continue, end

    % Apply correction.
    bDes=bba_corrGet(handles.static,1);
    disp([datestr(now) ' Corrector changes:']);
    disp((bDes-f.corrOff*opts.gain)*1e3);
    bba_corrSet(handles.static,-f.corrOff*opts.gain,1,'wait',0);
    pause(opts.wait);
end

gui_BSAControl([],handles,0);
util_appClose([]);
