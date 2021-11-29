function gunBake2020Interlock()
% Read load lock RTDs and turn off bake system if limits are met.

interlockPvs= {'SIOC:SYS0:ML01:CALC007'; 'SIOC:SYS0:ML01:CALC008'; ...
               'SIOC:SYS0:ML01:CALC009';  'SIOC:SYS0:ML01:CALC010'; ...
              'SIOC:SYS0:ML01:CALC012'; 'SIOC:SYS0:ML01:CALC013'};
theReason = {'Coupler Temperatures', 'Gun Body Cu Temperatures', ...
             'Components Temperatures', 'Gun Body SS Temperatures', ...
            'Vacuum Level', 'Air Temperatures'};
isReadyPV = 'SIOC:SYS0:ML02:AO134';
isRunnigPV = 'SIOC:SYS0:ML01:CALC007.LOW';
lcaPutSmart(isReadyPV, 1); %enable in case it was not.
counter = 0;
while 1
    pause(1)
    counter = counter+1;
    lcaPutSmart(isRunnigPV, counter);
    isReady = lcaGetSmart(isReadyPV);
    if isReady,
        vals = lcaGetSmart(interlockPvs);
        if all(vals)
            fireEmergencyStop = 0;
        else
            fireEmergencyStop = 1;
            indx = find(~vals);
        end
        
        if fireEmergencyStop,
            %system('bash /usr/local/lcls/tools/edm/display/temp/EICbakeEstopLoadLock.bash')
            lcaPutSmart('ACCL:LLOK:500:BAKE_ESTOP', 1)
            lcaPutSmart(isReadyPV, 0);
            msgStr = sprintf('%s Sending Emergency Stop command: %s fault', datestr(now), theReason{indx});
            disp(msgStr)
            lcaPutSmart('SIOC:SYS0:ML00:CA019',double(int8(msgStr)));         
        else
            if ~mod(counter, 60), 
                msgStr = sprintf('%s All is well', datestr(now)); 
                disp(msgStr)
                lcaPutSmart('SIOC:SYS0:ML00:CA019',double(int8(msgStr)));
            end
        end
    end
    

end


        
    
    