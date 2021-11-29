function set_picnic_delay(value)

lcaPut('XPS:LI20:PWFA:M1.VAL',value);

pos = lcaGet('XPS:LI20:PWFA:M1.RBV');

while abs(value - pos) > 0.1
    
    display(['Moving grating to ' num2str(value) ' mm. Current position is ' num2str(pos) ' mm.']);
    pos = lcaGet('XPS:LI20:PWFA:M1.RBV');
    pause(0.3);
    
end

