function [] = setguncavitypower( gunProbe1power_kW )
% Perpetual loop that keeps gun Probe 1 RF power level at the value in gunProbe1power_kW
% Sintax: setguncavitypower( gunProbe1power_kW )
% To exit the loop use ctrl+c
gunProbe1power_kW=abs(gunProbe1power_kW);
if gunProbe1power_kW >95.
    gunProbe1power_kW=95.;
    ['WARNING: Probe 1 power set to 90 kW'] 
    pause(15)
end
['Entering perpetual loop with Gun Probe 1 at :',num2str(gunProbe1power_kW),' kW. Ctrl+c to exit']
while 1
    powerfeedback_cavityprobe(gunProbe1power_kW*1000,0.005,0.005)
end

end

