
fprintf('%s starting\n',datestr(now))
lcaSetMonitor('SIOC:SYS0:ML00:SO1059');


while 1
    
    readPV = lcaGet('SIOC:SYS0:ML00:SO1059');
    lcaNewMonitorValue('SIOC:SYS0:ML00:SO1059');
    n = 10000;
    nH = 500;
    
    lcaPutSmart('SIOC:SYS0:ML00:FWF59', zeros(1,n));
    waveform = lcaGetSmart('SIOC:SYS0:ML00:FWF59');
    nOut = zeros(1,n);
    xOut = zeros(1,n);
    
    ii = 1;
    fprintf('%s Processing %s\n',datestr(now),readPV{:})
    counter = 0;
    
    % find dedicated PV for archived histogram
    %PHYS:XRAY:%:PULSEINTENSITY
    
    switch readPV{:}
        case 'XPP:MON:IPM:02:SUM',
            nPV = 'PHYS:XRAY:1:PULSEINTENSITY';
            xPV = 'PHYS:XRAY:2:PULSEINTENSITY';
        otherwise
            nPV = '';
    end
    
    while 1
        v = lcaGetSmart(readPV);
        waveform = circshift(waveform,[1 -1]);
        waveform(end) = v;
        lcaPutSmart('SIOC:SYS0:ML00:FWF59', waveform);
        [n,x] = hist(waveform,nH);
        nOut(1:nH) = n;
        xOut(1:nH) = x;
        
        lcaPutSmart('SIOC:SYS0:ML00:FWF60', nOut);
        lcaPutSmart('SIOC:SYS0:ML00:FWF61', xOut);
        if ii == n; ii = 1; end
        ii  = ii +1;
        pause(0.02)
        isNewPV = lcaNewMonitorValue('SIOC:SYS0:ML00:SO1059');
        if isNewPV, break, end
        if ~mod(ii,100), counter = counter +1;end
        lcaPutSmart('SIOC:SYS0:ML01:AO026', counter);
        
        if any(nPV)
            lcaPutSmart(nPV, n);
            lcaPutSmart(xPV, x);
        end
            
        
        
    end
    
    
end