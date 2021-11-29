function loadLockBakeInterlock()
% Read load lock RTDs and turn off bake system if limits are met.

interlockPvs= {'SIOC:SYS0:ML01:CALC003'; 'SIOC:SYS0:ML01:CALC004'};
theReason = {'RTD Temperature', 'Gauge Pressure'};
isReadyPV = 'SIOC:SYS0:ML01:CALC003.HIGH';
isRunnigPV = 'SIOC:SYS0:ML01:CALC003.LOW';
lcaPutSmart(isReadyPV, 1); %enable in case it was not.
counter = 0;
while 1
    pause(1)
    counter = counter+1;
    lcaPutSmart(isRunnigPV, counter);
    isReady = lcaGetSmart(isReadyPV);
    if isReady,
        vals = lcaGetSmart(interlockPvs);
        if vals(1)==0,
            fireEmergencyStop = 1; indx = 1;
        elseif vals(2)==0,
            fireEmergencyStop = 1; indx = 2;
        else
            fireEmergencyStop = 0;
        end
        
        if fireEmergencyStop,
            system('bash /usr/local/lcls/tools/edm/display/temp/EICbakeEstopLoadLock.bash')
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


        
    
    