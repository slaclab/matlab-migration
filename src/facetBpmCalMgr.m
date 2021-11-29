function [] = facetBpmCalMgr
%
%   facetBpmCalMgr.m
%
%   Script to enable/disable LI20 FACET EPICS BPM calibration.
%
%   This is a workaround for the fact that the BPM CAMAC processors
%   "think" the EPICS calibration pulse is beam and we are unable to 
%   interleave calibration and beam pulses, as the system is designed to
%   do.
%   
%   When the FACET beam rate is zero or beam is on 2-9 dump,                 
%   enable calibration of EPICS BPMs. Otherwise, disable it and associated
%   alarms. Loop forever, doing this check every 2 seconds. 
%   Increment counter for use by 'Watcher'.
%

% For error logging
facility = 'MATLAB';

% Use e- rate PV until we have both e- and e+ again
e_ratepv  = {'EVNT:SYS1:1:RFACCRATE'};
%p_ratepv  = {'EVNT:SYS1:1:RFACCRATE'};
counterpv = {'SIOC:SYS1:ML00:AO048'};
statepv   = {'SIOC:SYS1:ML00:CA048'};
permitpv  = {'SIOC:SYS1:ML00:CALC008'};
dumppv    = {'DUMP:LI11:390:TGT_STS'};
lcaPut( counterpv, 0 ); % Start counter at 0

loca    = 'LI20';
evr     = [ 'EVR:' loca ':BP01' ];
disable = 0;
enable  = 1;
first_pass = 1; % Disable calibration on first pass
state = enable; % Set initial state to enable so that first pass is logged

units = { '2445'; '3156'; '3265'; '3315' };
n = length( units );

for i = 1:n
    bpms{i} = [ 'BPMS:' loca ':' units{i} ];
end

pvs = {}; alhpvs = {}; alhvals_en = {}; alhvals_dis = {};

for i = 1:n
    caltrigpv = [ bpms{i} ':CALBTCTL' ];
    daqcalpv1 = [ evr ':EVENT3CTRL.OUT' num2str( i-1 ) ];
    daqcalpv2 = [ evr ':EVENT4CTRL.OUT' num2str( i-1 ) ];
    pvs    = [ pvs; caltrigpv; daqcalpv1; daqcalpv2 ];
    alhpvs = [ alhpvs; bpms{i} ':STA_ALH.INPB'; bpms{i} ':STA_ALH.INPC' ];
    alhvals_en  = [ alhvals_en; bpms{i} ':GRU.SEVR MS'; bpms{i} ':GRV.SEVR MS'];
    alhvals_dis = [ alhvals_dis; ' '; ' '];
end

npvs = length( pvs );

while ( 1 )
    skip = 0;
    try
        permit = 1; % Hard-code permit to true until new permit PV %lcaGet( permitpv );
        e_rate = lcaGet( e_ratepv );
        %p_rate = lcaGet( p_ratepv );
        e_two_nine = lcaGet( dumppv );
        %p_two_nine = e_two_nine;
        e_on_two_nine = ~strcmp(e_two_nine, 'OUT'); % 0 = moving, 1 = out, 2 = in
        %p_on_two_nine = e_on_two_nine
        e_present = (e_rate > 0) && ~e_on_two_nine;
        %p_present = (p_rate > 0) && ~p_on_two_nine;
        beam   = (permit)  && ( e_present );   % There might be beam in LI20
        %beam   = (permit)  && ( e_present || p_present);   % There might be beam in LI20
        nobeam = (~permit) || e_on_two_nine; % No beam is in LI20
        %nobeam = (~permit) || e_on_two_nine || (~e_present && ~p_present); % No beam is in LI20
    catch
        disp('lcaGet or aidaget error');
        skip = 1;
    end

    if ( skip && ~first_pass )
    else
        if ( first_pass || beam )
            first_pass = 0;
            
            vals = zeros( 1, npvs )';
            try
                lcaPut( pvs, vals );
                lcaPut( alhpvs, alhvals_dis );
                lcaPut( statepv, double(int8('Disabled')) );
                if ( state == enable )
                    logMsg(facility,'facetBpmCalMgr.m: Disabling FACET EPICS BPM calibration');
                end
                state = disable;
            catch
                logMsg(facility,'facetBpmCalMgr.m: lcaPut error while disabling FACET EPICS BPM calibration');
            end

        else if ( nobeam )
                vals = ones( 1, npvs )';
                try
                    lcaPut( pvs, vals );
                    lcaPut( alhpvs, alhvals_en );
                    lcaPut( statepv, double(int8('Enabled')) );
                    if ( state == disable )
                        logMsg(facility,'facetBpmCalMgr.m: Enabling FACET EPICS BPM calibration');
                    end
                    state = enable;
                catch
                    logMsg(facility,'facetBpmCalMgr.m: lcaPut error while enabling FACET EPICS BPM calibration');
                end
            end
        end
    end
    c = lcaGet( counterpv );
    lcaPut( counterpv, c+1);
    pause( 5 );
end
end

function[] = logMsg(facility,message)

myErrInstance = getLogger(facility);
put2log(message);

end

    

