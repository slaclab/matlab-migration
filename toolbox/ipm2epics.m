function ipm2epics
%function ipm2epics plots time correlated energy bpm vs pulse intensity for
%selected device.
fprintf('%s starting\n',datestr(now))
lcaSetMonitor('SIOC:SYS0:ML00:SO1059');
cudPVs = strrep('PHYS:XRAY:#:PULSEINTENSITY', '#',{'3' '4'}); %for CUD
usePV = lcaGet('SIOC:SYS0:ML00:SO1059');
%engPV = {'BPMS:LTU1:250:X'};
engyPV = {'BLD:SYS0:500:PHOTONENERGY'};
bufflen = 500;


while 1
    readPV = lcaGet('SIOC:SYS0:ML00:SO1059');
    lcaNewMonitorValue('SIOC:SYS0:ML00:SO1059');
    
    switch readPV{:}
        case 'XPP:MON:IPM:02:SUM',
            historyPVs = strrep('PHYS:XRAY:#:PULSEINTENSITY', '#',{'5' '6'}); %for CUD
            saveHistory = 1;
        otherwise
            saveHistory = 0;
    end
    energy = nan(1,bufflen);
    pulseIntensity = nan(1,bufflen);
    while 1
        
        isNewPV = lcaNewMonitorValue('SIOC:SYS0:ML00:SO1059');
        if isNewPV, break, end
        
        
        for ii = 1:120
            [v(ii,:) t1(ii,:)] = lcaGetSmart([engyPV;usePV]);
            t = lcaTs2PulseId(t1);
            pause(0.005)
            
        end
        
        [C, ia, ib] = intersect(t(:,1), t(:,2));
        N = length(C);
        energy =  circshift(energy,[1 -N]);
        pulseIntensity = circshift(pulseIntensity,[1 -N]);
        energy(end-N+1:end) = v(ia,1);
        pulseIntensity(end-N+1:end) = v(ia,2);
        filt = ~isnan(energy);
        filt(filt) = filt(filt) & (abs(energy(filt)-median(energy(filt))) < 4 *std(energy(filt)));
        filtI = find(filt);
        filtI = filtI(1:min(length(filtI),500));
        engyOut = nan(1,500);
        pulseOut = nan(1,500);
        
        engyOut(1:length(filtI)) = energy(filtI);
        pulseOut(1:length(filtI)) = pulseIntensity(filtI);
        
        lcaPutSmart(cudPVs, [engyOut; pulseOut]);
        if saveHistory
            lcaPutSmart(historyPVs, [engyOut; pulseOut]);
        end
        
        
    end
    
    
end
