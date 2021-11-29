function set_E224_probe_delay(value)

lcaPut('XPS:LI20:MC05:M5',value);

pos = lcaGet('XPS:LI20:MC05:M5.RBV');

while abs(value - pos) > 0.01
    
    display(['Moving stage to ' num2str(value) ' mm. Current position is ' num2str(pos) ' mm.']);
    pos = lcaGet('XPS:LI20:MC05:M5.RBV');
    pause(0.3);
    
end

