function [] = setbunchercavitypower( buncherProbe1power_AU )
% Perpetual loop that keeps Buncher Probe 1 RF power level at the value in buncherProbe1power_AU
% Sintax: setbunchercavitypower( buncherProbe1power_AU )
% To exit the loop use ctrl+c
maxpower=1.;
buncherProbe1power_AU=abs(buncherProbe1power_AU);
if buncherProbe1power_AU >maxpower
    buncherProbe1power_AU=maxpower;
    ['WARNING: Probe 1 power set to ',num2str(maxpower),' kW'] 
    pause(15)
end
['Entering perpetual loop with Buncher Probe 1 at :',num2str(buncherProbe1power_AU),' kW. Ctrl+c to exit']
while 1
    powerfeedback_buncherprobe(buncherProbe1power_AU,0.005,0.02)
end

end

