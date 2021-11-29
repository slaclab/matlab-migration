function und1PointSrv()
% und1PointSrv() implements Undulator Point Server to let other
% applications, including hutch user requests repoint the undulator line.
% See http://ad-ops.slac.stanford.edu/wiki/index.php/Undulator_Pointing_Server_(Dev)
%

% William Colocho, December 2017
accelerator = 'LCLS';
N = {'1' '2' '3' '4'};
switch accelerator
    case 'LCLS'
        watcherpv = 'PHYS:UND1:POINT:WATCHER';
        rootName = 'PHYS:UND1:POINT';
        acrReqName = 'PHYS:UND1:POINT:REQUEST';
        pointStatus = 'PHYS:UND1:POINT:STATUS';
        pv.pointVals  = {...
            'PHYS:UND1:POINT:DX_START';
            'PHYS:UND1:POINT:DY_START';
            'PHYS:UND1:POINT:DX_END';
            'PHYS:UND1:POINT:DX_END'};
        pv.messageStr = 'PHYS:UND1:POINT:STAT_STRING';
        pv.rootName = rootName;
%         opsPVs.loc = strcat([rootName ':USEGLOC'],N)';
%         opsPVs.dx = strcat([rootName ':DX'],N(1:3))';
%         opsPVs.dy = strcat([rootName ':DY'],N(1:3))'; 
        
        lcaPut([rootName ':ALLOWHUTCH'], 'Allow Hutch NO');
        lcaPut(acrReqName, 'Idle')
        lcaPut([rootName ':STATUS'], 'POINTING IDLE')
        lcaPut([rootName ':REQUESTER'], 'ACR')
        setPointingLimits(pv, 2000)
    otherwise
        %Please teach me other accelerators
end

loopPause = 0.2; % intra loop pause between checks

W = watchdog(watcherpv,10,['undPointSrv: ' rootName]);
if get_watchdog_error(W)
   error('Could not start watchdog. Dog required for entry.')
end

dispLog(' Undulator point server started ',pv.messageStr)

% Get the name and number of hutches available 
 mmbo = {'ZR','ON','TW','TH','FR','FV','SX','SV','EI','NI','TE','EL','TV','TT','FT','FF'}.';
 requestLoc = lcaGetSmart(strcat(rootName, ':REQUESTER.', mmbo, 'ST'));
 requestNum = find(~cellfun(@isempty,requestLoc))-1;
 requestLoc = requestLoc(requestNum+1);

% PVs we monitor for changes
lcaSetMonitor([rootName ':REQUEST'])
lcaGet([rootName ':REQUEST'])
listenPv = [rootName ':REQUESTER']; 

          

lcaSetMonitor(listenPv,1,'int');
lcaGetSmart(listenPv);
lastPointTime = now;
while(1)
    pause(loopPause);

    % Watchdog update
    W = watchdog_run(W);
    if get_watchdog_error(W)
        error('%s Watchdog lost. I quit.', datestr(now))
    end
    if (now > lastPointTime + 1/24/60),  
        lcaPutSmart([rootName ':ALLOWHUTCH'], 'Allow Hutch NO'); 
        lastPointTime = now;
    end
     
    try
        newRequestMon = lcaNewMonitorValue([rootName ':REQUEST']);
        if ~newRequestMon, continue, end
        newRequest = lcaGetSmart([rootName ':REQUEST']);
        if strcmp(newRequest, 'Idle'), continue, end
        
        requester = lcaGetSmart(listenPv); requester = requester{:};
        switch requester
            case 'ACR', 
                pointOK = 1;
                setPointingLimits(pv, 2000)
            otherwise           
                hutchAllow = lcaGetSmart([rootName ':ALLOWHUTCH']);
                if strcmp(hutchAllow, 'Allow Hutch YES')
                    pointOK = 1;
                    setPointingLimits(pv, 500)
                else
                    dispLog([' Pointing request not granted for ' requester ], pv.messageStr);
                    pause(3)
                    lcaPutSmart('PHYS:UND1:POINT:REQUEST', 'Idle');
                    continue
                    
                end
        end
        if pointOK,  doPointing(requester, pv), lastPointTime = now; end
        
    catch ex
        if any(strfind(ex.message,'no channel for PV')) || ...
                any(strfind(ex.message,'invalid process variable name'))
        else
            rethrow(ex)
        end
    end
    
    lcaPutSmart('PHYS:UND1:POINT:REQUEST', 'Idle');
end
end

function setPointingLimits(pv, limit)
limits = [limit limit -limit -limit]';
drvStartPvsH = strcat(pv.pointVals(3:4), '.DRVH');
drvStartPvsL = strcat(pv.pointVals(3:4), '.DRVL');

lcaPutSmart([drvStartPvsH; drvStartPvsL], limits);

end
 

function doPointing(requester, pv)
lcaPutSmart([pv.rootName ':STATUS'], 'POINTING IN PROGRESS');
dispLog(sprintf(' Starting pointing request from %s', requester), pv.messageStr );
pause(5) % simulate pointing

v = lcaGetSmart(pv.pointVals); % v is values short for ease 
        
dispLog([' Pointing request from ' requester ' started'], pv.messageStr)
lcaPutSmart([pv.rootName ':STATUS'],  'POINTING IN PROGRESS' );

try
    %repointUndulatorLine(v(1), v(2), v(3),  v(4));
    pause(3)
    lcaPutSmart([pv.rootName ':STATUS'],  'POINTING SUCCESS' );
    pause(3)
    lcaPutSmart([pv.rootName ':STATUS'],  'POINTING IDLE' );
    dispLog([' Pointing request from ' requester ' ended'], pv.messageStr)

catch ex
    dispLog(ex.message)
    lcaPutSmart([pv.rootName ':STATUS'], 'POINTING FAILED');
    return
end

end

function dispLog(message, strPV)
disp_log(message);
%lcaPutSmart(strPV,double(int8(strcat(datestr(now),message))));
N = min(39,length(message));
lcaPutSmart(strPV, message(1:N));
end









