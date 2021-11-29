function trim_magnet(pv,BDES,T_or_P, timeout_seconds)

% trim_magnet(pv[,BDES,T_or_P]);
%
% Function to TRIM or PERTURB a magnet setting to a particular BDES value.
%
%   INPUTS:     pv:         Process variable name (e.g. 'XCOR:LN20:721')
%               BDES:       (Optional,DEF=present BDES) The desired magnet
%                           setting, BDES (if not provided we TRIM to its
%                           present value of BDES)
%                           (BEND,XCOR,YCOR,SOLN: kG-m, QUAD: kG, BTRM: A)
%               T_or_P:     (Optional,DEF='T') 'T'=TRIM, 'P'=PERTURB
%   OUTPUTS:    (none)

%==========================================================================


% Example calling sequence:
%
% trim_magnet('XCOR:LN20:721');
% trim_magnet('XCOR:LN20:721',0.0123);
% trim_magnet('XCOR:LN20:721',0.0123,'T');
%
% trim_magnet({'XCOR:LN20:721' 'QUAD:LI21:221' 'QUAD:LI21:271'});
% trim_magnet({'XCOR:LN20:721' 'QUAD:LI21:221' 'QUAD:LI21:271'}, ...
%     [0.0123 0.0234 0.0345]);
% trim_magnet({'XCOR:LN20:721' 'QUAD:LI21:221' 'QUAD:LI21:271}', ...
%     [0.0123 0.0234 0.0345], 'T');
% trim_magnet({'XCOR:LN20:721' 'QUAD:LI21:221' 'QUAD:LI21:271}', ...
%     [0.0123 0.0234 0.0345], {'T' 'T' 'P'});

% NOTE: This function only supports EPICS controlled Magnets

%==========================================================================

tic;

if exist('timeout_seconds','var')
    to_secs = timeout_seconds;
else
    to_secs = 60;
end

pause_time = 0.25; % seconds

%
% Connect to message log
%
Logger = getLogger('trim_magnet.m');

%
% Determine caller (for later finger pointing)
%
stack = dbstack; % call stack
if length(stack) > 1
    caller = stack(2).file;
else
    caller = getenv('PHYSICS_USER');
end

%
% How many pv passed in?
%
if iscell(pv)
    num_pv_prefix = length(pv);
else
    num_pv_prefix = 1;
end

%
% Build list of pvs for channel access
%
pv_prefix = cell(0);
if iscell(pv)
    for each_pv = 1:num_pv_prefix
        pv_prefix{end+1} = pv(each_pv);
    end
else
    pv_prefix{end+1} = pv;
end

%
% Setup magnet BDES pvs
%
pvs = cell(0);
for each_pv = 1:num_pv_prefix
    pvs{end+1} = char(strcat(pv_prefix{each_pv},':BDES'));
end

%
% Specific BDES passed in?
%
if exist('BDES','var')
    if isequal (size(BDES,1), num_pv_prefix)
        lcaPut(pvs',BDES);               % set BDES value(s)
    else
        lcaPut(pvs',BDES');              % set BDES value(s)
    end
end

%
% Get magnet BDES(s)
%
bdes = lcaGet(pvs');

%
% Setup magnet control pvs
%
pvs = cell(0);
ctrlstatepvs = cell(0);
rampstatepvs = cell(0);
statuspvs = cell(0);
statmsgpvs = cell(0);
ctrlstate = cell(0);
rampstate = cell(0);
status = cell(0);
statmsg = cell(0);
for each_pv = 1:num_pv_prefix
    pvs{end+1} = char(strcat(pv_prefix{each_pv},':CTRL'));
    ctrlstatepvs{end+1} =  char(strcat(pv_prefix{each_pv},':CTRLSTATE'));
    ctrlstate{each_pv} = char(lcaGet(ctrlstatepvs{each_pv})); % initial value
    rampstatepvs{end+1} =  char(strcat(pv_prefix{each_pv},':RAMPSTATE'));
    rampstate{each_pv} = char(lcaGet(rampstatepvs{each_pv})); % innitial value
    statuspvs{end+1} = char(strcat(pv_prefix{each_pv},':STATMSG.SEVR'));
    status{each_pv} = char(lcaGet(statuspvs{each_pv})); % innitial value
    statmsgpvs{end+1} = char(strcat(pv_prefix{each_pv},':STATMSG'));
    statmsg{each_pv} = char(lcaGet(statmsgpvs{each_pv})); % innitial value
end

%
% Determine whether to TRIM or PRETURB
%
cmnd = cell(0);
if exist('T_or_P','var')
    if iscell(T_or_P) % One 'T' or 'P' for each pv
        for each_pv = 1:num_pv_prefix
            if 'T' == upper(char(T_or_P{each_pv}))
                cmnd{end+1} = 'TRIM';
            else
                if 'P' == upper(char(T_or_P{each_pv}))
                    cmnd{end+1} = 'PERTURB';
                else
                    put2log(sprintf('Error in %s''s call to trim_magnet.m',...
                        caller));
                    put2log(sprintf('%s incorrectly specified TRIM or PERTURB as "%s"',...
                        caller, T_or_P));
                    return;
                end
            end
        end
    else % only one value supplied
        for each_pv = 1:num_pv_prefix
            if 'T' == upper(T_or_P)
                cmnd{end+1} = 'TRIM';
            else
                if 'P' == upper(T_or_P)
                    cmnd{end+1} = 'PERTURB';
                else
                    put2log(sprintf('Error in %s''s call to trim_magnet.m',...
                        caller));
                    put2log(sprintf('%s incorrectly specified TRIM or PERTURB as "%s"',...
                        caller, T_or_P));
                    return;
                end
            end
        end
    end
else % no arg provided, assume TRIM
    for each_pv = 1:num_pv_prefix
        cmnd{end+1} = 'TRIM';
    end
end

%
% Issue message and TRIM
%
for each_pv = 1:num_pv_prefix
    put2log(sprintf('%s requesting %s of %s BDES=%f', caller, ...
        char(cmnd(each_pv)), char(pvs(each_pv)), bdes(each_pv)));
end
lcaPut(pvs',cmnd');         % TRIM magnet to BDES value

%
% Start monitoring control pvs
%
lcaSetMonitor(pvs');
lcaSetMonitor(ctrlstatepvs');
lcaSetMonitor(rampstatepvs');
lcaSetMonitor(statuspvs');
lcaSetMonitor(statmsgpvs');
for each_pv = 1:num_pv_prefix
    put2log(sprintf('trim_magnet.m waiting for %s to be "Ready"', ...
        char(pvs(each_pv))));
    put2log(sprintf('trim_magnet.m waiting for %s to be "Done"', ...
        char(ctrlstatepvs(each_pv))));
    put2log(sprintf('trim_magnet.m waiting for %s to be "OFF"', ...
        char(rampstatepvs(each_pv))));
end

%
% Wait for all magnets to be Ready, Done & OFF
%
while 1
    nv = lcaNewMonitorValue(pvs');
    nctrlstate = lcaNewMonitorValue(ctrlstatepvs');
    nrampstate = lcaNewMonitorValue(rampstatepvs');
    nstatus = lcaNewMonitorValue(statuspvs');
    nstatmsg = lcaNewMonitorValue(statmsgpvs');
    done = 1; % assume we're done unless discovered otherwise
    timed_out = 0;
    if toc > to_secs
        timed_out = 1;
        put2log(sprintf('***** IMPORTANT ***** trim_magnet.m timed out after %d seconds', to_secs));
    end
    for each_pv = 1:num_pv_prefix
        if 1 == nctrlstate(each_pv)
            ctrlstate{each_pv} = char(lcaGet(ctrlstatepvs{each_pv}));
            put2log(sprintf('trim_magnet.m found %s=%s', ...
                char(ctrlstatepvs{each_pv}), char(ctrlstate{each_pv})));
            if strcmp('Unavailable', char(ctrlstate{each_pv}))
                put2log(sprintf('***** IMPORTANT ***** trim_magnet.n request to %s %s but magnet is Unavailable',...
                    char(cmnd{each_pv}), char(ctrlstatepvs{each_pv})));
                ctrlstate{each_pv} = 'Done';
            end
        end
        if 1 == nv(each_pv)
            cmnd{each_pv} = char(lcaGet(pvs{each_pv}));
            put2log(sprintf('trim_magnet.m found %s=%s', ...
                char(pvs{each_pv}), char(cmnd{each_pv})));
        end
        if 1 == nrampstate(each_pv)
            rampstate{each_pv} = char(lcaGet(rampstatepvs{each_pv}));
            put2log(sprintf('trim_magnet.m found %s=%s', ...
                char(rampstatepvs{each_pv}), char(rampstate{each_pv})));
        end
        if 1 == nstatmsg(each_pv)
            statmsg{each_pv} = char(lcaGet(statmsgpvs{each_pv}));
            put2log(sprintf('trim_magnet.m found %s=%s', ...
                char(statmsgpvs{each_pv}), char(statmsg{each_pv})));
        end
        if 1 == nstatus(each_pv)
            status{each_pv} = char(lcaGet(statuspvs{each_pv}));
            put2log(sprintf('trim_magnet.m found %s=%s', ...
                char(statuspvs{each_pv}), char(status{each_pv})));
        end
    end
    for each_pv = 1:num_pv_prefix
        if strcmp ('Ready', char(cmnd{each_pv}))
            % So far so good
        else
            if timed_out
                put2log(sprintf('trim_magnet.m timed out with %s=%s, but expected %s="Ready"', ...
                    char(pvs{each_pv}), char(cmnd{each_pv}), char(pvs{each_pv})));
            else
                done = 0; % wait some more
            end
        end
        if strcmp ('Done', char(ctrlstate{each_pv}))
            % So far so good
        else
            if timed_out
                put2log(sprintf('trim_magnet.m timed out with %s=%s, but expected %s="Done"', ...
                    char(ctrlstatepvs{each_pv}), char(ctrlstate{each_pv}), char(ctrlstatepvs{each_pv})));
            else
                done = 0; % wait some more
            end
        end
        try
            rampstate{each_pv} = char(lcaGet(rampstatepvs{each_pv}));
            % this pv may not get set as advertised by the API
        catch
        end
        if strcmp ('OFF', char(rampstate{each_pv}))
            % So far so good
        else
            if isempty(rampstate{each_pv})
                % call it good
            else
                if timed_out
                    put2log(sprintf('trim_magnet.m timed out with %s=%s, but expected %s="OFF"', ...
                        char(rampstatepvs{each_pv}), char(rampstate{each_pv}), char(rampstatepvs{each_pv})));
                else
                    done = 0; % wait some more
                end
            end
        end
    end

    if done
        put2log(sprintf('%s call to trim_magnet.m complete.', caller));
        return;
    else
        pause(pause_time);
    end
end
