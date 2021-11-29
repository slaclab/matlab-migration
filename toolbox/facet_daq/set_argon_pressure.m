function set_argon_pressure(value)

if value > 40
    error('Maximum pressure is 40 Torr');
elseif value < 0.2
    error('Minimum pressure is 0.2 Torr');
end

pressure = lcaGet('VGCM:LI20:M3202:PMONRAW');

if pressure > value
    
    lcaPut('VVFL:LI20:M3202:DRAIN_CMD',1);

    while pressure - value > 0

        pressure = lcaGet('VGCM:LI20:M3202:PMONRAW');
        pause(0.5);
        display(['Draining argon. Pressure = ' num2str(pressure), ' Torr']);

    end
    
    lcaPut('VVFL:LI20:M3202:DRAIN_CMD',0);
    
end

if pressure < value
    
    lcaPut('VVFL:LI20:M3201:FILL_CMD',1);

    while value - pressure > 0

        pressure = lcaGet('VGCM:LI20:M3202:PMONRAW');
        pause(0.5);
        display(['Filling argon. Pressure = ' num2str(pressure), ' Torr']);

    end
    
    lcaPut('VVFL:LI20:M3201:FILL_CMD',0);
    
end
