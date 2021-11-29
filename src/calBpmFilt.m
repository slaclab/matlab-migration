function[status] = calBpmFilt(bpm, method, sim, corpair, E)

%   calBpmFilt.m
%   
%   This function is used during cavity BPM initial setup to set 
%   the filter, phase, and delay settings used by BPM software.
%   Steps:
%    1. Move the position of the beam in the BPM to be offset
%       in the X plane and centered in Y
%    2. Cause the BPM software to auto-calculate the filter frequency
%       center and bandwidth
%    3. Pause and prompt the user to manually adjust the reference
%       and X sampling times
%    4. Cause the BPM software to auto-calculate the X phase to
%       set all signal in the real plane
%    5. Perform above steps, switching to the Y plane. Note that in 
%       step 3, it should not be necessary to adjust the reference
%       sampling time.
%
%   	Arguments:
%                   bpm         BPM name, eg 'BPMS:UNDH:2190'
%                               If girder BPM, name must be of form
%                               BPMS:UND{Y}:{XX}90
%                               where Y = H or S, XX = 1 or 2-digit girder
%                               number 
%                               (BPMS:UNDH:1305 handled as special case)
%                   method      0 == girder, 1 == corrector magnet   
%                   xcor        XCOR magnet name
%                   ycor        YCOR magnet name 
%                   
%
%       Return:
%                   status      0 if completed all steps without errors
%                               else non-zero
%

addpath(genpath('/home/physics/nuhn/wrk/matlab/cams'))
addpath(genpath('/home/physics/sonya/bpmcommissioning/matlab/toolbox'))

close all;

status = -1;

DEBUG = 0;

% define constants

c.GIRDER = 0;
c.COR    = 1;

c.XPLANE = 1;
c.YPLANE = 2;
c.REF = 3; % Ref/X/Y indices must match RMS PV order

c.SIGSTR = { 'X', 'Y', 'Ref' };
c.RMS_THRES = 0.1; % Minimum signal to set filters, etc.

c.RMS_DELTA = 0.01;  % Delta to determine effect of step
c.STEP_SIZE = 0.05;  % 50 microns in units of mm ; rmat values use m, BPMMove uses mm
c.MAX_MOVE  = 0.5;   % +/- 500 microns

c.RMS_DELTA_FINE = 0.002;
c.STEP_SIZE_FINE = 0.01; % 10 microns
c.MAX_MOVE_FINE  = 0.05; % within coarse step size

% end define constants

bpmst.debug = DEBUG;

bpmst.bpm = bpm;
bpmst.method = method;
bpmst.vals = zeros(3,1);
bpmst.mean = bpmst.vals;
bpmst.sevr = bpmst.vals;
bpmst.stat = bpmst.vals;
bpmst.ts   = bpmst.vals;

if ( bpmst.method == c.COR )    
    if ( exist('corpair', 'var') )
        if ( ~isempty( corpair ) )
            bpmst.xcor = corpair.xcor;
            bpmst.ycor = corpair.ycor;
            bpmst.xcor = corpair.xcorpv;
            bpmst.ycor = corpair.ycorpv;
            bpmst.rx = corpair.rx;
            bpmst.ry = corpair.ry;
        else
            disp([bpm ': Empty corpair struct. Quitting.']);
            return;
        end
    else
        disp([bpm ': Empty corpair argument. Quitting.']);
        return;
    end
    if ( exist('E', 'var') )
        if ( E > 0 )
            bpmst.E = E;
        else
            disp([bpm ': Illegal energy ' num2str(E) '. Quitting.']);
            return;
        end
    else
        disp([bpm ': Empty energy argument. Quitting.']);
        return;
    end
end

status = 0;

% measured offsets 
% index is for the plane the offset is in 
% (not necessarily the plane being set up)
bpmst.offset = zeros(2,1);
bpmst.center = bpmst.offset; 
       
if ( exist('sim', 'var') ~= 1 )
    bpmst.sim = 0;
else
    bpmst.sim = sim;
end

disp( ['calBpmFilt: Begin setup for ' bpmst.bpm] );

if ( bpmst.sim == 0 )
    status = calBpmFiltSetup( bpmst, c );
else
    disp('calBpmFilt: RUNNING IN SIMULATION MODE');
    disp('');
    bpmst.sim = sim;
    bpmst = setSimData( bpmst, c );
    status = calBpmFiltRun( bpmst, c );
end
end

function[ret] = calBpmFiltSetup(bpmst,c)
ret = -1; % initialize to unsuccessful

expression = 'BPMS:UND(?<und>\w):(?<girder>\d+)90';
s = regexp( bpmst.bpm, expression, 'names' );

if ( isempty(s) )
    disp('Failed to extract beamline/girder info. See help for bpm argument requirements.')
    return;
end

if ( s.und == 'H' )
    bpmst.beamline = 'HXR';
elseif ( s.und == 'S' )
    bpmst.beamline = 'SXR';
else
    disp( 'Illegal area for girder BPM. Must be UNDH or UNDS' );
    return;
end

if ( bpmst.method == c.GIRDER )
    if ( strcmp( bpmst.bpm, 'BPMS:UNDH:1305') )
        bpmst.beamline = 'HXR';
        bpmst.girder = 12;
        disp( 'Special case BPMS:UNDH:1305' );
    else
        bpmst.girder = str2num( s.girder );
    end
    
    if ( ~bpmst.sim )
        bpmst.cam_i = readCamAngles ( bpmst.beamline, bpmst.girder );
    end
    disp( ['calBpmFilt: set up ' bpmst.bpm ' girder ' num2str(bpmst.girder) ' beamline ' bpmst.beamline ] );
    
elseif ( bpmst.method == c.COR )
    try
        bpmst.xcor_i = lcaGet( bpmst.xcorpv );
        bpmst.ycor_i = lcaGet( bpmst.ycorpv );
    catch
        disp( ['Failed to read ' bpmst.xcorpv ' and/or ' bpmst.ycorpv '. Abort.'] );
        return;
    end
else
    fprintf('Illegal method %i. Must be girder (0) or corrector (1)\n', bpmst.method);
    return;
end

bpmst.pvs = { [bpmst.bpm ':URMS'] ; [bpmst.bpm ':VRMS'] ; [bpmst.bpm ':RRMS'] };
bpmst.statpvs = { [bpmst.bpm ':URMS.STAT'] ; [bpmst.bpm ':VRMS.STAT'] ; [bpmst.bpm ':RRMS.STAT'] };
bpmst.priopv = [bpmst.bpm ':RRMS.PRIO'];

try
    bpmst.prio_i = lcaGet( [bpmst.priopv] );
    lcaPut( bpmst.priopv, 'HIGH' );
    lcaSetMonitor ( bpmst.pvs );
catch ME
    disp( 'Error during lca operation' );
    return;
end

s = calBpmFiltRun( bpmst, c );

try
str = ['BPMSetup_',bpmst.bpm,'_',date(1:10),'_',date(12:13),'_',date(15:16)];
save(fullfile('.',str));
catch
end

if ( s )
    disp( 'Error in calBpmFiltRun' );
    return;
end
end

function[ret] = calBpmFiltRun(bpmst,c)

ret = -1; % initialize to unsuccessful
bpmst.fig = 10;
    
for m = c.XPLANE:c.YPLANE
    
    [bpmst, s] = moveBeamCheckData( bpmst, c, m ) ;
    if ( s )
        disp('Error setting up beam offsets. Abort.')
        restore( bpmst, c );
        return;
    end
    
    % If x plane, also set reference signal filter
    s = setFilter( bpmst, c, m );
    if ( s )
        disp('Error setting filters. Abort.')
        restore( bpmst, c );
        return;
    end
    
    % If x plane, user must also set up reference sampling time
    s = setSamplingTimes( bpmst, c, m );
    if ( s )
        disp('Error setting sampling times. Abort.')
        restore( bpmst, c );
        return;
    end
    
    s = setPhase( bpmst, c, m );
    if ( s )
        disp('Error setting phase. Abort.')
        restore( bpmst, c );
        return;
    end
    
    if ( m == c.XPLANE )
        % Restore beam position before beginning next plane
        restore( bpmst, c, 1 );
    end
end

restore( bpmst, c);
disp ( 'Done' );
ret = 0;

end

function[bpmst,ret] = moveBeamCheckData(bpmst, c, m)
 
    ret = -1; % initialize to unsuccessful
    
    if ( m == c.XPLANE )
        o = c.YPLANE;
    else
        o = c.XPLANE;
    end

    if ( ~bpmst.sim )
        % Verify usable reference signal
        [bpmst, s] = getDataMean( bpmst, c );
        if ( s )
            return;
        end
    end

	% Center beam in other plane, first coarse, then fine
    disp( ['Coarse scan for ' c.SIGSTR{o} ' beam center'] );
    [bpmst, steps, rms, s] = moveBeamCenter( bpmst, c, o, c.STEP_SIZE, c.RMS_DELTA, c.MAX_MOVE );
    try
        bpmst.coarsecentersteps(o,:) = steps;
        bpmst.coarsecenterrms(o,:) = rms;
        mplot = figure( bpmst.fig );
        set( mplot, 'Position', [100,100,800,700] )
        bpmst.fig = bpmst.fig + 1;
        subplot(2,2,1)
        scatter( bpmst.coarsecentersteps(o,:), bpmst.coarsecenterrms(o,:) );
        plotSettings( [c.SIGSTR{o} ' coarse center scan'] );
    catch
    end
    if ( s ) 
        return;
    end
    annotation('textbox',[.25 .7 .1 .2],'String',['Center ' num2str(bpmst.center(o)) ],'EdgeColor','none')
    
    disp( ['Fine scan for beam center about ' num2str(bpmst.center(o))] ); 
    [bpmst, steps, rms, s] = moveBeamCenter( bpmst, c, o, c.STEP_SIZE_FINE, c.RMS_DELTA_FINE, c.MAX_MOVE_FINE );
    try
        bpmst.finecentersteps(o,:) = steps;
        bpmst.finecenterrms(o,:) = rms;
        subplot(2,2,2)
        scatter( bpmst.finecentersteps(o,:), bpmst.finecenterrms(o,:) );
        plotSettings( [c.SIGSTR{o} ' fine center scan'] );
    catch
    end
    if ( s ) 
        disp( ['Failed to refine ' c.SIGSTR{o} ' center. Using position from coarse scan.'] );
    else
        annotation('textbox',[.7 .7 .1 .2],'String',['Center ' num2str(bpmst.center(o)) ],'EdgeColor','none')       
    end

	% Create offset in this plane
    disp( ['Scan for ' c.SIGSTR{m} ' offset'] );
    [steps, rms, s] = moveBeamOffset( bpmst, c, m );
    try
        bpmst.offsetsteps(m,:) = steps;
        bpmst.offsetrms(m,:) = rms;
        subplot(2,2,3)
        scatter( bpmst.offsetsteps(m,:), bpmst.offsetrms(m,:) );
        plotSettings( [c.SIGSTR{m} ' offset scan'] );
    catch
    end
    if ( s ) 
        return;
    end
    annotation('textbox',[.25 .2 .1 .2],'String',['Offset ' num2str(bpmst.offset(m)) ],'EdgeColor','none')
    ret = 0;
end

function[] = plotSettings(titlestr)
title( titlestr );
xlabel( 'Offset [mm]');
ylabel( 'RMS (mm)' );
grid;
end
        
function[bpmst, steps, rms, ret] = moveBeamCenter(bpmst,c,m,stepsize,delta,max)

    ret = -1; % initialize to unsuccessful
    
    if ( bpmst.debug )
        disp( ['moveBeamCenter: step size ' num2str(stepsize) ' mm, delta ' num2str(delta) ' mm, max ' num2str(max) ' mm'] );
    end
        
    dirs = [1.0, -1.0];
    steps = [];
    rms = [];
    
    for i = size(dirs)
        [bpmst, steps, rms, total, s] = moveBeamCenterDir( bpmst, c, m, stepsize, delta, max, dirs(i), steps, rms );
        if ( s == -1 )
            return;
        elseif ( s == 0 )
            ret = 0;
            return;
        elseif ( s == 1 ) 
            if (i == size(dirs) )
                return;
            end
        else
            disp( ['    Move girder ' num2str(-total) ' before next direction '] ); 
            moveBeam( bpmst, c, m, -total );
        end
    end
end
   

function[bpmst, steps, rms, total, ret] = moveBeamCenterDir(bpmst,c,m,stepsize,delta,max,dir,steps,rms)    
        
    total = 0;
    switchdir = 0;
    nsteps = 0;
    
    % For print statements and sim data request,
    % add coarse scan total move to total. 
    % If we are in the coarse scan, this is zero.
    if ( bpmst.sim )
        val = getSimData( bpmst, total+bpmst.center(m) );
    else
        [bpmst, s] = getDataMean( bpmst, c );
        if ( s )
            return;
        end        
        val = bpmst.mean( m );
    end
    
    steps = [steps,total];
    rms = [rms,val];
    
    while ( abs(total+dir*stepsize) < max )
        moveBeam( bpmst, c, m, dir*stepsize );
        nsteps = nsteps + 1;
        total = total + dir*stepsize;
        if ( bpmst.debug )
            disp( ['    moveBeamCenter: ' c.SIGSTR{m} ' total move ' num2str(total) ' mm, dir ' num2str(dir) ', nsteps ' num2str(nsteps)]);
        end
        if ( nsteps > 1 )
            val = bpmst.mean(m); % if not the first iteration, store the last value
        end   
        if ( bpmst.sim )
           
            bpmst.mean(m) = getSimData( bpmst, total+bpmst.center(m) );
        else
            [bpmst, s] = getDataMean( bpmst, c );
            if ( s )
                return;
            end
        end    
        steps = [steps, total];
        rms = [rms, bpmst.mean(m)];
        diff = bpmst.mean(m) - val;
        if ( bpmst.debug )
            disp( ['    moveBeamCenter: new val ' num2str(bpmst.mean(m)) ' prev val ' num2str(val) ' diff ' num2str(diff)] );
        end
        if ( diff > delta )
            % switch direction; if we are on our second switch,
            % assume the last point was the center
            dir = dir * -1.0;
            if ( switchdir == 1 )
                moveBeam( bpmst, c, m, dir*stepsize );
                nsteps = nsteps + 1;
                total = total + dir*stepsize;
                bpmst.center(m) = total + bpmst.center(m);
                disp(['    moveBeamCenter: found ' c.SIGSTR{m} ' center at ' num2str(bpmst.center(m)) ' mm, nsteps ' num2str(nsteps)])
                ret = 0;
                return;
            end
            switchdir = 1;
        end
    end
    ret = 1; % indicate not found but no error  
    disp( ['    moveBeamCenter: failed to find center within ' num2str(total) ' mm'] );
end

function[steps,rms,ret] = moveBeamOffset(bpmst,c,m)

ret = -1; % initialize to unsuccessful

stepsize = c.STEP_SIZE;
if ( bpmst.debug )
    disp( ['moveBeamOffset: step size ' num2str(stepsize) ' mm'] );
end
        
nsteps = 0;
total = 0;
dir = 1.0;
switchdir = 0;

if ( bpmst.sim )
    val = getSimData( bpmst, total );
else
    [bpmst, s] = getDataMean( bpmst, c );
    if ( s )
        return;
    end
    val = bpmst.mean( m );
end

steps= total;
rms = val;
    
rms_low = ( val < c.RMS_THRES );

while ( (abs(total+dir*stepsize) < c.MAX_MOVE) && rms_low )
    moveBeam( bpmst, c, m, dir*stepsize );
    nsteps = nsteps + 1;
    total = total + dir*stepsize;
    if ( bpmst.debug )
        disp( ['    moveBeamOffset: total move ' num2str(total) ' mm, dir ' num2str(dir) ', nsteps ' num2str(nsteps)]);
    end
    if ( nsteps > 1 )
        val = bpmst.mean(m); % if not the first iteration, store the last value
    end
    if ( bpmst.sim )
        bpmst.mean(m) = getSimData( bpmst, total );
    else
        [bpmst, s] = getDataMean( bpmst, c );
        if ( s )
            return;
        end
    end
    steps = [steps, total];
    rms = [rms, bpmst.mean(m)];
    rms_low = ( bpmst.mean(m) < c.RMS_THRES );
    diff = val - bpmst.mean(m);
    if ( bpmst.debug )
        disp( ['    moveBeamOffset: new val ' num2str(bpmst.mean(m)) ' prev val ' num2str(val) ' diff ' num2str(diff) ' rms_low ' num2str(rms_low)] );
    end
    if ( rms_low && (diff > c.RMS_DELTA) )
        % switch direction
        dir = dir * -1.0;
        if ( switchdir == 1 )
            disp( '    moveBeamOffset: failed to find sufficient offset signal' );
            return;
        end
        switchdir = 1;
    end
end
if ( rms_low )
    disp( ['    moveBeamOffset: failed to find offset signal within ' num2str(total) ' mm, nsteps ' num2str(nsteps)] );
    return;
end
bpmst.offset = total;
disp(['    moveBeamOffset: found ' c.SIGSTR{m} ' offset at ' num2str(bpmst.offset) ' mm, nsteps ' num2str(nsteps)])

ret = 0;
end

function[ret] = moveBeam(bpmst, c, m, move)

if ( bpmst.sim )
    ret = 0;
    return;
end
        
ret = -1; % initialize to unsuccessful

if ( bpmst.method == c.GIRDER )
    s = moveBeamGirder( bpmst, c, m, move );
    if ( s )
        disp( 'Error from moveBeamGirder. Abort.' );
        return;
    end
else
    s = moveBeamCor( bpmst, c, m, move );
    if ( s )
        disp( 'Error from moveBeamCor. Abort.' );
        return;
    end
end

ret = 0;

end

function[ret] = moveBeamGirder(bpmst, c, m, move)

if ( m == c.XPLANE)
    xmove = move;
    ymove = 0.0;
else
    xmove = 0.0;
    ymove = move;
end

if ( bpmst.debug )
    disp( ['    Move ' bpmst.beamline ' ' num2str(bpmst.girder) ' ' num2str(move)] );
end
success = BPMMove( bpmst.beamline, bpmst.girder, xmove, ymove );

if ( success == true )
    ret = 0;
else
    disp( 'Error from BPMMove' );
    ret = -1;
end

end

function[ret] = moveBeamCor(bpmst, c, m, move)

ret = -1;

move = move / 1000; % convert mm to m

try
    if ( m == c.XPLANE )
        pv = bpmst.xcorpv;
        current = lcaGet( pv );
        new = current + (c.Cb*bpmst.E*move/bpmst.rx);
    else
        pv = bpmst.ycorpv;
        current = lcaGet( pv );
        new = current + (c.Cb*bpmst.E*move/bpmst.ry);
    end
    if ( bpmst.debug )
        disp( ['Move ' pv  ' from ' num2str(current) ' to ' num2str(new) ' kG-m]'] );
    end
    lcaPut( pv, new );
    pause(2); % wait for magnet to settle
catch
    disp( 'Error during moveBeamCor lcaGet/Put.' );
    return;
end
ret = 0;

end

% Wrapper for getData. Get NPOINTS of data with good status and return mean values
function[bpmst, ret] = getDataMean( bpmst, c )

    ret = -1; % initialize to unsuccessful
    vals = [];
    NPOINTS = 5;

    if ( clearData( bpmst ) )
        return;
    end

    i = 0;
    err = 0;
    while ( (i < NPOINTS) && (err < NPOINTS) )
        [bpmst, s] = getData( bpmst );
        if ( s )
            return;
        end
        % I think REF/U/V share status/severity
        if ( 0 == (bpmst.sevr(c.REF) + bpmst.sevr(c.XPLANE) + bpmst.sevr(c.YPLANE)) )
            i = i+1;
            vals = [vals,bpmst.vals];
        else
            err = err+1
        end
    end

    if ( err >= NPOINTS )
        disp( 'getDataMean: Failed to get good data. Check reference.' );
        return;
    end

    bpmst.mean = mean( vals, 2 );

    ret = 0;

end

function[bpmst, ret] = getData( bpmst )

    ret = -1; % initialize to unsuccessful

    newdata = 0;
    e = 0;
    while ( (e < 10) && (~newdata) )
        try lcaNewMonitorWait( bpmst.pvs )
            newdata = 1;
        catch ME
            disp( 'Timeout waiting for new data' );
            e = e + 1;
        end
    end
    if ( (e >= 10) && (~newdata) )
        disp( 'getData: No new data. Abort ' );
        return;
    end
    bpmst.vals = lcaGet( bpmst.pvs );
    [bpmst.sevr, bpmst.stat, bpmst.ts] = lcaGetStatus( bpmst.pvs );

    ret = 0;

end

% Clear monitor
function[ret] = clearData(bpmst)
    try
	    vals = lcaGet( bpmst.pvs ); % Clear old reading for monitored PVs
    catch ME
        disp( 'Cannot lcaGet PVs' );
        ret = -1;
        return;
    end
    ret = 0;
end

function[ret] = setFilter(bpmst, c, m)
    ret = -1;

    if ( ~bpmst.sim )
        if ( m == c.XPLANE )
            % reference center frequency
            lcaPut( [bpmst.bpm ':FILT.B'], 0 );
            pause(1);
            % reference bandwidth
            lcaPut( [bpmst.bpm ':FILT.C'], 0 );
            pause(1);
            % X center frequency
            lcaPut( [bpmst.bpm ':FILT.E'], 0 );
            pause(1);
            % X bandwidth
            lcaPut( [bpmst.bpm ':FILT.F'], 0 );
        else
            % Y center frequency
            lcaPut( [bpmst.bpm ':FILT.H'], 0 );
            pause(1);
            % Y bandwidth
            lcaPut( [bpmst.bpm ':FILT.I'], 0 );
        end
    end

    ret = 0;
end

function[ret] = setSamplingTimes(bpmst, c, m)
    ret = -1;

    if ( m == c.XPLANE )
        disp( 'Now go to the EDM display Envelope tab and set up the reference and X sampling times' );
    else
        disp( 'Now go to the EDM display Envelope tab and set up the Y sampling time' );
    end

    prompt = 'Were you successful? Y/N [Y]';
    str = input( prompt, 's' );

    if ( strcmp(str, 'N') || strcmp(str,'n') )
        return;
    end

    ret = 0;
end

function[ret] = setPhase(bpmst, c, m)
    ret = -1;

    if ( ~bpmst.sim )
        if ( m == c.XPLANE )
            lcaPut( [bpmst.bpm ':UPHAS'], 400 );
        else
            lcaPut( [bpmst.bpm ':VPHAS'], 400 );
        end
    end

    ret = 0;
end

function[ret] = restore(bpmst,c,flag)
    if ( bpmst.sim )
        return;
    end
    
    ret = -1;
    
    if ( exist('flag','var') ~= 1 )
        flag = 0;
    end
    
    % flag indicates only restore beam position (girder/magnet)
    % if not set, perform all restore functions
    if ( ~flag ) 
        lcaPut( bpmst.priopv, bpmst.prio_i );
    end

    if ( bpmst.method == c.GIRDER )
        disp( ['Restore girder ' num2str(bpmst.girder) ' position'] );
        success = setCamAngles( bpmst.beamline, bpmst.girder, bpmst.cam_i );
        if ( success == false )
            disp('Error during restore. Fix girder position manually.');
            return;
        end
    else
        disp( ['Restore ' bpmst.xcorpv ' to ' num2str(bpmst.xcor_i) ' and ' bpmst.ycorpv ' to ' num2str(bpmst.ycor_i)] ); 
        lcaPut( bpmst.xcorpv, bpmst.xcor_i);
        lcaPut( bpmst.ycorpv, bpmst.ycor_i);
    end

    ret = 0;
end

function[bpmst] = setSimData(bpmst,c)

range = 200;

switch bpmst.sim
    case 1
        offset = -30;
        slope = 1.2;
    case 2
        offset = -100;
        slope = 1.2;
    case 3
        offset = 150;
        slope = 1.2;
    case 4
        offset = -30;
        slope =3;
    case 5
        offset = -100;
        slope = 3;
    case 6
        offset = 150;
        slope = 3;
    case 7
        offset = -30;
        slope =3;
    case 8
        offset = -100;
        slope = 3;
    case 9
        offset = 150;
        slope = 3;
    otherwise
        offset = 15;
        slope = .5;
end

for i=1:range
    scale = i - 1 - range/2;
    bpmst.simdata(1,i) = scale * c.STEP_SIZE_FINE;
    bpmst.simdata(2,i) = abs(scale+offset)*(c.RMS_DELTA_FINE)*slope;
end
figure(1);
plot(1:range,bpmst.simdata(1,:),1:range,bpmst.simdata(2,:));
title('Simulation data')
end

function[val] = getSimData(bpmst,total)
[~,idx] = min( abs(bpmst.simdata(1,:) - total));
val = bpmst.simdata(2,idx);
end

function[rwav_ref, rwav_x, rwav_y] = splitRwav(rwav)
    bpmst.rwav_ref = rwav(385:512);
    bpmst.rwav_x   = rwav(257:384);
    bpmst.rwav_y   = rwav(129:256);
end

function[tdiff, nan] = checkData(ts, vals)
    time = mod(real(ts),60) + imag(ts)/1e9;
    tdiff = (max(max(time)) ~= min(min(time)));
    nan = max(max( isnan( vals ) ));
end












