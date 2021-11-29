function set_laser_phase(value)

initial_10Hz_trig_state = lcaGet('EVR:LA20:LS21:EVENT9CTRL.OUT3');

lcaPut('OSC:LA20:10:FS_TGT_TIME',value);
lcaPut('EVR:LA20:LS21:EVENT9CTRL.OUT3',1);
x = lcaGet('UTIC:LA20:10:GetOffsetInvMeasMean_ns');



while abs(value - x) > 0.1
    x = lcaGet('UTIC:LA20:10:GetOffsetInvMeasMean_ns');
    display(['Waiting for timing to track. Difference is ' num2str(value-x,'%0.2f') ' ns.']);
    pause(0.5);
end

lcaPut('EVR:LA20:LS21:EVENT9CTRL.OUT3',initial_10Hz_trig_state);
    
display(['Changed OSC:LA20:10:FS_TGT_TIME to ' num2str(value)]);