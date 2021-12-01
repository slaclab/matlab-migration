function gunBake2020Interlock()
% Read load lock RTDs and turn off bake system if limits are met.

interlockPvs= {'SIOC:SYS0:ML01:CALC007'; 'SIOC:SYS0:ML01:CALC008'; ...
               'SIOC:SYS0:ML01:CALC009';  'SIOC:SYS0:ML01:CALC010'; ...
              'SIOC:SYS0:ML01:CALC012'; 'SIOC:SYS0:ML01:CALC013'};
theReason = {'Coupler Temperatures', 'Gun Body Cu Temperatures', ...
             'Components Temperatures', 'Gun Body SS Temperatures', ...
            'Vacuum Level', 'Air Temperatures'};
        
ionPumpSeverityPvs = {'VPNI:GUNB:100:3:I_SIP.SEVR'; 'VPNI:GUNB:100:4:I_SIP.SEVR';...
    'VPNI:GUNB:436:I_SIP.SEVR'; 'VPNI:GUNB:390:I_SIP.SEVR'};


            %isReadyPV = 'SIOC:SYS0:ML02:AO134';
isRunnigPV = 'SIOC:SYS0:ML01:CALC007.LOW';
%lcaPutSmart(isReadyPV, 1); %enable in case it was not.
counter = 0;
            
msgStr = sprintf('%s Software Interlock Process Started...', datestr(now));
disp(msgStr)            
lcaPutSmart('SIOC:SYS0:ML00:CA031',double(int8(msgStr)));         

while 1
    pause(1)
    counter = counter+1;
    lcaPutSmart(isRunnigPV, counter);
    %    isReady = lcaGetSmart(isReadyPV);
    if 1 %isReady
        vals = lcaGetSmart(interlockPvs);
        if all(vals)
            fireEmergencyStop = 0;
        else
            fireEmergencyStop = 1;
            indx = find(~vals);
        end
        
        
        vacuumLevel = lcaGetSmart('VGHF:GUNB:519:P');
        vacuumLimit = lcaGetSmart('SIOC:SYS0:ML02:AO135');
        
        if vacuumLevel > vacuumLimit
            %Check for INVALID ion pump severity
            ionPumpSeverity = lcaGetSmart(ionPumpSeverityPvs);
            isInvalid = strcmp(ionPumpSeverity, 'INVALID');
            isFault = any(isInvalid(1:2)) & any(isInvalid(3:4));
            if isFault
                fireEmergencyStop = 1;
                indx = 5;
                msgStr = sprintf('%s Ion Pumps and %s fault', datestr(now), theReason{indx});
                disp(msgStr)
                lcaPutSmart('SIOC:SYS0:ML00:CA031',double(int8(msgStr)));  
            end
        end
                
       
        
        if fireEmergencyStop
            system('bash /usr/local/lcls/tools/edm/display/temp/EICbakeEstopLoadLock.bash')
            lcaPutSmart('ACCL:LLOK:500:BAKE_ESTOP', 1)
            %lcaPutSmart(isReadyPV, 0);
            msgStr = sprintf('%s Emergency Stop: %s fault', datestr(now), theReason{indx});
            disp(msgStr)
            lcaPutSmart('SIOC:SYS0:ML00:CA031',double(int8(msgStr)));         
        else
            if ~mod(counter, 300)
                msgStr = sprintf('%s Software Monitor Active', datestr(now)); 
                disp(msgStr)
                lcaPutSmart('SIOC:SYS0:ML00:CA031',double(int8(msgStr)));
            end
        end
    end
    

end


        
    
    