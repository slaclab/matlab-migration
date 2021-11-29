function set_grating_position(value)

lcaPut('XPS:LI20:PWFA:M8.VAL',value);

pos = lcaGet('XPS:LI20:PWFA:M8.RBV');

while abs(value - pos) > 0.01
    
    display(['Moving grating to ' num2str(value) ' mm. Current position is ' num2str(pos) ' mm.']);
    pos = lcaGet('XPS:LI20:PWFA:M8.RBV');
    pause(0.3);
    
end

