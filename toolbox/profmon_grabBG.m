function [data, ts] = profmon_grabBG(pv, nBG, varargin)
%PROFMON_GRABBG
%  PROFMON_GRABBG() grabs a background image with darkcurrent from cameras
%  PV, but no photoelectrons. It inhibits the Pockels cell trigger for the
%  laser, takes a set of images NBG and reestablishes the trigger again.

% Features: It uses the PATT:SYS0:1:POCKCTRL (formerly TRIG:LR20:LS01:TCTL)
% state to toggle the pockels cell trigger from enable to disable and back
% to enable after the background image has been taken.

% Input arguments:
%    PV: Base name(s) of camera PV, e.i. YAGS:IN20:211
%    NBG: number of background images to acquire (default 1)
%    OPTS: options struct
%          BUFD: get buffered images, default is 0
%          DOPLOT: show image if set to 1, default is 0

% Output arguments:
%    DATA: Structure array of background image and camera properties, if NBG is
%          0, only the IMG field is returned and set to 0.
%        IMG:        Image data as uint16 or uint8 array, depending on bit depth
%        TS:         Time stamp of image in Matlab time units
%        PULSEID:    Pulse Id of image
%        NCOL, NROW: Number of columns and rows of full image
%        BITDEPTH:   Bit depth of image
%        RES:        Screen resolution in um/pixel
%        ROIX, Y:    Offset x and y of partial image
%        ROIXN, YN:  Number of columns and rows of actual (partial) image
%        ORIENTX, Y: Camera orientation, 1 means image has to be flipped
%        CENTERX, Y: Screen center in pixels
%        ISRAW:      Indicates raw image, 0 means flipped, 1 raw
%    TS: Time stamp of enabled trigger time

% Compatibility: Version 2007b, 2012a
% Called functions: lcaPut, profmon_grab

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'spontBG', 0, ...
    'bufd',0, ...
    'doPlot',0, ...
    'figure',2, ...
    'axes',[], ...
    'title','Background #%d');

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Check input arguments.
if nargin < 2, nBG=1;end

[n,is]=profmon_names(pv);
if ~nBG
    [data(1,1:numel(n)).img]=deal([]);
    ts=0;
    return
end

% Wait longer for popin cameras
wait=4;

% Inhibit trigger.
if ~all(is.NLCTA | is.FACET | is.XTA | is.ASTA)
    lcaPut('PATT:SYS0:1:POCKCNTMAX',nBG*50);
end
%trigPV='PATT:SYS0:1:POCKCTRL';
trigPV='IOC:BSY0:MP01:PCELLCTL';
if any(ismember(n,{'YAGS:IN20:211' 'YAGS:IN20:241'}))
    trigPV='TRIG:LR20:LS01:TCTL';
end
% For XTCAV classic, go on axis if not already there
if all(strcmp(n,'OTRS:DMPH:695')) % if it's the only one
    trigPV='SIOC:SYS0:ML02:AO185';
    oldVal = lcaGetSmart(trigPV);
end
% For XTCAV-B, go on axis if not already there
if all(strcmp(n,'OTRS:DMPS:695')) % if it's the only one
    trigPV='SIOC:SYS0:ML05:AO177';
    oldVal = lcaGetSmart(trigPV);
end
% For laser heater OTRs, also block the heater beam.
if any(ismember(n,{'OTRS:IN20:465' 'OTRS:IN20:471'}))
    trigPV={trigPV; 'TRIG:LR20:LS01:TCTL'};
end
trigVal=0;
if opts.spontBG
    % disable UND launch FB for spontaneous BG 9/20/11 nate
    trigPV={'FBCK:UND0:1:ENABLE'; 'FBCK:FB03:TR04:MODE'};    
    oldTrig=lcaGetSmart(trigPV);
end
if any(is.Laser), trigPV={trigPV;'TRIG:LR20:LS01:TCTL'};end
if any(is.Popin), trigPV='IOC:BSY0:MP01:BYKIKCTL';end
if any(is.NLCTA)
    trigPV='ESB:BO:2124-7:BIT1';
    lcaPut(trigPV,0);
    pause(0.1);
    lcaPut(trigPV,1);
    pause(0.1);
    lcaPut(trigPV,0);
    pause(0.1);
elseif any(is.FACET)
    
    trigPV='IOC:SYS1:MP01:MSHUTCTL'; % MPS shutter
    oldTrig=lcaGetSmart(trigPV);
    lcaPutSmart(trigPV,trigVal);
    shut_stat = lcaGetSmart('SHUT:LT10:950:IN_MPS');
    count = 0;
    while ~strcmp(shut_stat,'IS_IN')
        shut_stat = lcaGetSmart('SHUT:LT10:950:IN_MPS');
        count = count + 1;
        pause(0.1);
        if count > 10
            warning('Could not insert MPS shutter');
            break;
        end
    end


elseif any(is.XTA)
    trigPV='APC:XT01:TM01:SHUT1';
    lcaPut(trigPV,trigVal);
    pause(.5);
    lcaPut(trigPV,trigVal);
    pause(.1);
elseif any(is.ASTA)
    trigPV='SHTR:AS01:1:CMD';
    lcaPut(trigPV,1);
    pause(.5);
elseif any(is.SCLinac & ...
        ~strcmp(n,'OTRS:DMPH:695') & ...
        ~strcmp(n,'OTRS:DMPS:695'))
    trigPV = 'SIOC:SYS0:MP01:DISABLE_AOM';
    oldVal = lcaGetSmart(trigPV,1,'double');
    lcaPutSmart(trigPV,1); % disable AOM
    pause(.5);
elseif strcmp(trigPV,'SIOC:SYS0:ML02:AO185')
    lcaPutSmart(trigPV,trigVal);
    pause(1);
elseif strcmp(trigPV,'SIOC:SYS0:ML05:AO177')
    lcaPutSmart(trigPV,trigVal);
    pause(1);
else
    lcaPut(trigPV,trigVal);
    pause(.5)
end

% Log beam blocking.
trigPV=cellstr(trigPV);
gui_statusDisp([],sprintf('Blocking beam with %s %s',trigPV{:}));

% Get time stamp of trigger disabled.
if is.ASTA
    ts=now;
else
    [val,ts]=lcaGet(trigPV);
    ts=lca2matlabTime(ts(1));
end
pause(0.2);

% Wait 3 sec longer for popin cameras
if any(is.Laser), ts=ts+wait/4/24/60/60;end
if any(is.Popin), ts=ts+wait/24/60/60;end

% kick FEL for spontaneous only 9/20/11 nate
if opts.spontBG
    old_xcor=lcaGetSmart('XCOR:UND1:180:BDES');
    lcaPutSmart('XCOR:UND1:180:BCTRL',-0.005);
    pause(0.5);
end

% Grab background image.
data=profmon_grabSeries(pv,nBG,ts,opts);

% un-kick FEL
if opts.spontBG
    lcaPutSmart('XCOR:UND1:180:BCTRL',old_xcor);
    pause(0.5);
end

% Enable trigger again.
if any(is.NLCTA)
    lcaPut(trigPV,0);
    pause(0.1);
    lcaPut(trigPV,1);
    pause(0.1);
    lcaPut(trigPV,0);
    pause(0.1);
elseif any(is.FACET)
    lcaPutSmart(trigPV,oldTrig);
    pause(1.5);
elseif any(is.XTA)
    lcaPutSmart(trigPV,trigVal+1);
    pause(1);
elseif any(is.ASTA)
    lcaPut(trigPV,0);
    pause(.5);
elseif opts.spontBG
    lcaPutSmart(trigPV,oldTrig);
elseif any(is.SCLinac & ~strcmp(n,'OTRS:DMPH:695'))
    lcaPutSmart(trigPV,oldVal); % Restore AOM to what it was
    pause(.5);
elseif all(strcmp(trigPV,'SIOC:SYS0:ML02:AO185'))
    lcaPutSmart(trigPV,oldVal);
    pause(1);
else
    lcaPutSmart(trigPV,trigVal+1);
end

% Get time stamp of trigger enabled.
if is.ASTA
    ts=now;
else
    [val,ts]=lcaGet(trigPV);
    ts=lca2matlabTime(ts(1));
end
pause(0.2);

% Wait 3 sec longer for popin cameras
if any(is.Popin), ts=ts+wait/24/60/60;end
