function loadLockBakeInterlock()
% Read load lock RTDs and turn off bake system if limits are met.

interlockPvs= {'SIOC:SYS0:ML01:CALC003'; 'SIOC:SYS0:ML01:CALC014'; ...
               'SIOC:SYS0:ML01:CALC015'; 'SIOC:SYS0:ML01:CALC004'; ...
             'SIOC:SYS0:ML01:CALC013' };


theReason = {'Arm and Chamber', 'Gate Valves', 'Window', 'Vacuum', ...
             'Air Temperatures'};
    
%isReadyPV = 'SIOC:SYS0:ML01:CALC003.HIGH';
isRunnigPV = 'SIOC:SYS0:ML01:CALC003.LOW';
%lcaPutSmart(isReadyPV, 1); %enable in case it was not.
counter = 0;

msgStr = sprintf('%s Software Interlock Process Started...', datestr(now));
disp(msgStr)            
lcaPutSmart('SIOC:SYS0:ML00:CA019',double(int8(msgStr)));         


while 1
    pause(1)
    counter = counter+1;
    lcaPutSmart(isRunnigPV, counter);
    %isReady = lcaGetSmart(isReadyPV);
    if 1 %Always isReady
        vals = lcaGetSmart(interlockPvs);
        if all(vals)
            fireEmergencyStop = 0;
        else
            fireEmergencyStop = 1;
            indx = find(~vals);
        end
        
        if fireEmergencyStop,
            
            system('bash /usr/local/lcls/tools/edm/display/temp/EICbakeEstopLoadLock.bash')
            lcaPutSmart('ACCL:LLOK:500:BAKE_ESTOP', 1)
            
            msgStr = sprintf('%s Sending Emergency Stop command: %s fault', datestr(now), theReason{indx});
            disp(msgStr)
            lcaPutSmart('SIOC:SYS0:ML00:CA019',double(int8(msgStr)));         
        else
            if ~mod(counter, 5), 
                msgStr = sprintf('%s Software Monitor Active ', datestr(now)); 
                lcaPutSmart('SIOC:SYS0:ML00:CA019',double(int8(msgStr)));
            end
        end
    end
    

end


        
    
    