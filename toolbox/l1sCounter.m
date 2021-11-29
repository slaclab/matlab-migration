function l1sCounter(plotFlag)
% function l1sCounter(plotFlag)
% plotFlag = 1 plots waveforms.
% ssh physics@lcls-srv03 Matlab_startup l1sCounter
% xterm -e tail -f /u1/lcls/physics/log/matlab/l1sCounter.log
% ssh physics@lcls-srv03 Matlab_stop  l1sCounter&

% William Colocho, sometime in 2010
if nargin < 1, plotFlag = 0; end
outPvs = {'SIOC:SYS0:ML01:AO051';'SIOC:SYS0:ML01:AO052';'SIOC:SYS0:ML01:AO053';'SIOC:SYS0:ML01:AO054';...
                'SIOC:SYS0:ML01:AO055';'SIOC:SYS0:ML01:AO056'};
monitorPvs = { 'SIOC:SYS0:ML01:AO066'; 'SIOC:SYS0:ML01:AO067'};           
lcaSetMonitor(monitorPvs) 
monitorValues = lcaGetSmart(monitorPvs);  %#ok<NASGU>
stdCut = monitorValues(1); 
beamVoltsCut = monitorValues(2);

imAliveCounter = 0;
while(1) 
    pause(5)
    monitorFlags = lcaNewMonitorValue(monitorPvs);
    if sum(monitorFlags)
        monitorValues = lcaGetSmart(monitorPvs); 
        stdCut = monitorValues(1)
        beamVoltsCut = monitorValues(2)
    end
    
   
    imAliveCounter = imAliveCounter + 1;
    lcaPutSmart('SIOC:SYS0:ML01:AO059', imAliveCounter);
   %beamVolts = lcaGet('KLYS:LI21:K1:VOLTHSTBR');
   %phase = lcaGet('ACCL:LI21:1:L1S_PHSTBR');
   %ampl = lcaGet('ACCL:LI21:1:L1S_AHSTBR');
   values = lcaGetSmart({'KLYS:LI21:K1:VOLTHSTBR'; 'ACCL:LI21:1:L1S_PHSTBR'; 'ACCL:LI21:1:L1S_AHSTBR'});
   meanVal = mean(values,2);
   stdVal = std(values,0,2);
   for ii = 1:3
       H(ii) = sum(values( ii,:) > (meanVal(ii) + stdCut * stdVal(ii)));
       L(ii) = sum(values( ii,:) < (meanVal(ii) - stdCut * stdVal(ii)));
   end
   
   if plotFlag
       subplot(311), plot(values(1,:)),title(sprintf('Beam volts: %.2f high = %i and  low = %i',meanVal(1),H(1), L(1)))
       subplot(312), plot(values(2,:)), title(sprintf('Phase:  %.2f high = %i and low = %i',meanVal,(2),H(2), L(2)))
       subplot(313), plot(values(3,:)), title(sprintf('Amplitude:  %.2f high = %i and low = %i',meanVal(3),H(3), L(3)))
   end
   
   %Do not write to outPvs if beam volts mean less than beam volts cut.
   if meanVal(1) < beamVoltsCut, continue, end 
   lcaPutSmart(outPvs,[H L]');

end

