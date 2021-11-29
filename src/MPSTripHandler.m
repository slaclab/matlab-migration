% Waits for MPS to trip then saves BSA buffers
% Mike Zelazny

[ sys , accelerator ] = getSystem();
if isequal('LCLS',accelerator) % LCLS only
    ok = 1;
else
    s = 'Sorry, this MPS trip handler only works for LCLS';
    put2log(s);
    ok = 0;
end

if (ok)
    
    W = watchdog('SIOC:SYS0:ML00:AO440', 1, 'MPS Trip Handler counter' );
    if get_watchdog_error(W)
        put2log('Another MPSTripHandler.m is running, exiting');
        exit
    end
    
    % BSA specific parameters
    myName = 'Wait For MPS Trip';
    myNAVG = 1;   % no averaging
    myNRPOS = -1; % go forever
    
    % Labels all cmLog messages with this name
    Logger = getLogger(myName);
    
    % Count how many times this program saves a dataset
    count_pv = 'SIOC:SYS0:ML00:CALC700.PROC';
    
    % Write status messages here:
    status_pv = 'SIOC:SYS0:ML00:CA699';
    s = 'Initialize';
    lcaPutSmart(status_pv,zeros(1000));
    lcaPutSmart(status_pv,double(uint8(s)));
    put2log(s);
    
    try
        % MPS Trips when all three of these PVs go to zero [herhz] - Sonya (June 2015)
        mps_pvs = cell(0);
        mps_pvs{end+1} = 'IOC:BSY0:MP01:PC_RATE';
        mps_pvs{end+1} = 'IOC:BSY0:MP01:MS_RATE';
        mps_pvs{end+1} = 'IOC:BSY0:MP01:BYKIK_RATE';
        lcaSetMonitor(mps_pvs');
    catch
        ok = 0;
        s = sprintf('lcaSetMonitor failed for %s',mps_pvs{end});
        lcaPutSmart(status_pv,zeros(1000));
        lcaPutSmart(status_pv,double(uint8(s)));
        put2log(s);
    end
    
    try
        % Keep track of the last file names saved by Jim Turner's BSA GUI
        fileName_pv = 'SIOC:SYS0:ML00:CA700';
        lcaSetMonitor(fileName_pv);
    catch
        ok = 0;
        s = sprintf('lcaSetMonitor failed for %s',fileName_pv);
        lcaPutSmart(status_pv,zeros(1000));
        lcaPutSmart(status_pv,double(uint8(s)));
        put2log(s);
    end
    
    try
        % Monitor EDEF PVs due to repeated network (re)connections
        edef_pvs = cell(0);
        for i = 1:15
            edef_pvs{end+1} = sprintf('EDEF:SYS0:%d:NAME',i);
            edef_pvs{end+1} = sprintf('EDEF:SYS0:%d:AVGCNT.LOPR',i);
            edef_pvs{end+1} = sprintf('EDEF:SYS0:%d:AVGCNT.LOPR',i);
            edef_pvs{end+1} = sprintf('EDEF:SYS0:%d:MEASCNT.LOPR',i);
            edef_pvs{end+1} = sprintf('EDEF:SYS0:%d:MEASCNT.LOPR',i);
        end
        lcaSetMonitor(edef_pvs');
    catch
        ok = 0;
        s = 'lcaSetMonitor failed for EDEF PVs';
        lcaPutSmart(status_pv,zeros(1000));
        lcaPutSmart(status_pv,double(uint8(s)));
        put2log(s);
    end
    
    try
        % Force save of BSA buffers when this PV is 1
        force_pv = 'SIOC:SYS0:ML03:AO700';
        lcaSetMonitor(force_pv);
    catch
        ok = 0;
        s = sprintf('lcaSetMonitor failed for %s',force_pv);
        lcaPutSmart(status_pv,zeros(1000));
        lcaPutSmart(status_pv,double(uint8(s)));
        put2log(s);
    end
    
    s = 'Waiting for MPS to trip...';
    lcaPutSmart(status_pv,zeros(1000));
    lcaPutSmart(status_pv,double(uint8(s)));
    put2log(s)
    
    tic;
    while ok
        
        W = watchdog_run(W); % run watchdog counter
        if get_watchdog_error(W)
            s = 'Some sort of watchdog timer error';
            lcaPutSmart(status_pv,zeros(1000));
            lcaPutSmart(status_pv,double(uint8(s)));
            put2log(s);
        end
        pause(1);
        
        % Get my event definition number. This done in a loop in case OPS
        % decides to release my event definition inappropriately.
        try
            myeDefNumber = eDefReserve(myName);
        catch
            myeDefNumber = 0;
        end
        if isequal (myeDefNumber, 0)
            s = sprintf('Sorry, event definition unavailable for %s', myName);
            lcaPutSmart(status_pv,zeros(1000));
            lcaPutSmart(status_pv,double(uint8(s)));
            put2log(s);
            ok = 0;
        else
            ok = 1; % could clear up later
        end
        
        if ok
            % Set my number of pulses to average, etc...
            eDefParams (myeDefNumber, myNAVG, myNRPOS, {''},{''},{''},{''});
            
            % Make sure my eDef is running
            eDefOn(myeDefNumber);
        end
        
        if ok
            % Check beam rate(s)
            for i = 1 : length(mps_pvs)
                try
                    if lcaNewMonitorValue(mps_pvs{i})
                        [mps_rate_s, lcaTS] = lcaGetSmart(mps_pvs{i});
                        disp(sprintf('%s %s %s', datestr(lca2matlabTime(lcaTS)), char(mps_pvs{i}), char(mps_rate_s)));
                        mps_rate(i) = lcaGetSmart(sprintf('%s.ORAW',mps_pvs{i})) - 1; % enum 1==0Hz
                    end
                catch
                    s = sprintf('IOC probably rebooted, try to reestablish monitor to %s', mps_pvs{i});
                    lcaPutSmart(status_pv,zeros(1000));
                    lcaPutSmart(status_pv,double(uint8(s)));
                    put2log(s);
                    lcaSetMonitor(mps_pvs');
                end
            end
            
            if isempty(whos('global','prev_rate'))
                global prev_rate;
                prev_rate = sum(mps_rate);
            else
                
                % Check for user request to save BSA buffers
                try
                    if lcaNewMonitorValue(force_pv)
                        force = lcaGetSmart(force_pv);
                    end
                    if force
                        prev_rate = 1;
                        for i = 1 : length(mps_pvs)
                            mps_rate(i) = 0;
                        end
                    end
                catch
                    force = 0;
                end
                
                if toc > 600 % 10 minutes since last trip
                    
                    if isequal(sum(mps_rate), 0)
                        
                        if ~isequal(sum(mps_rate), prev_rate)
                            
                            try
                                
                                s = sprintf('MPS Tripped! Saving BSA data... eDefOff(%d)', myeDefNumber);
                                lcaPutSmart(status_pv,zeros(1000));
                                lcaPutSmart(status_pv,double(uint8(s)));
                                put2log(s);
                                
                                % Pause the eDef
                                eDefOff(myeDefNumber);
                                
                                s = 'MPS Tripped! Saving BSA data... About to load previously saved BSA data set';
                                lcaPutSmart(status_pv,zeros(1000));
                                lcaPutSmart(status_pv,double(uint8(s)));
                                put2log(s);
                                
                                % Load an old dataset
                                fileName = char(lcaGet(fileName_pv));
                                data = load(fileName,'data');
                                handles = data.data;
                                
                                s = 'MPS Tripped! Saving BSA data... Grab the data from the BSA buffers';
                                lcaPutSmart(status_pv,zeros(1000));
                                lcaPutSmart(status_pv,double(uint8(s)));
                                put2log(s);
                                
                                % Grab the data from the BSA buffers
                                new_name = strcat(handles.ROOT_NAME, {'HST'}, {num2str(myeDefNumber)});
                                pause(5); % Copied this from Jim Yurner's code, not sure why its needed
                                [the_matrix, t_stamp, isPV] = lcaGetSmart( new_name, 2800 );
                                indx_time = strmatch(sprintf('PATT:%s:1:PULSEID',sys),handles.ROOT_NAME);
                                matlabTS = lca2matlabTime(t_stamp(indx_time));
                                handles.num_points = 2800;
                                handles.the_matrix = the_matrix;
                                handles.time_stamps = t_stamp;
                                handles.t_stamp = datestr(matlabTS);
                                handles.isPV = isPV;
                                
                                s = 'MPS Tripped! Saving BSA data... Save new dataset';
                                lcaPutSmart(status_pv,zeros(1000));
                                lcaPutSmart(status_pv,double(uint8(s)));
                                put2log(s);
                                
                                % Save new dataset
                                data = handles;
                                data.MPSTrip = 1;
                                fileName=util_dataSave(data,'BSA','data',handles.t_stamp,0);
                                tic;
                                
                                s = 'MPS Tripped! Saving BSA data... Increment counter';
                                lcaPutSmart(status_pv,zeros(1000));
                                lcaPutSmart(status_pv,double(uint8(s)));
                                put2log(s);
                                
                                % Increment counter
                                lcaPutSmart(count_pv,1);
                                
                                % reset force
                                lcaPutSmart(force_pv, 0);
                                
                                s = 'MPS Tripped! Saved BSA data set.';
                                lcaPutSmart(status_pv,zeros(1000));
                                lcaPutSmart(status_pv,double(uint8(s)));
                                put2log(s);
                                
                            catch
                                
                                s = 'MPS Tripped, but had trouble saving the data.';
                                lcaPutSmart(status_pv,zeros(1000));
                                lcaPutSmart(status_pv,double(uint8(s)));
                                put2log(s);
                                
                            end
                            
                            s = 'Waiting for MPS to trip...';
                            lcaPutSmart(status_pv,zeros(1000));
                            lcaPutSmart(status_pv,double(uint8(s)));
                            put2log(s);
                            
                        end % rate changed
                        
                    end % MPS rate is 0 Hz
                    
                end % It's been 30 minutes since last data saved
                
                % Save the rate
                prev_rate = sum(mps_rate);
                
            end % If not first iteration through loop
            
            global eDefQuiet; % Stop eDef messages after one good iteration
            
        end % if ok
        
        ok = 1; % try again on eDef failure
        
    end % while ok
    
end % if ok

s = 'MPS Trip handler exit';
lcaPutSmart(status_pv,zeros(1000));
lcaPutSmart(status_pv,double(uint8(s)));
put2log(s);
