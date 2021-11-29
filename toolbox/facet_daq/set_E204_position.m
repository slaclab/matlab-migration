function set_grating_position(value)

lcaPut('XPS:LI20:DWFA:I.VAL',value);

pos = lcaGet('XPS:LI20:DWFA:I.RBV');

while abs(value - pos) > 0.01
    
    display(['Moving BLIS to ' num2str(value) ' mm. Current position is ' num2str(pos) ' mm.']);
    pos = lcaGet('XPS:LI20:DWFA:I.RBV');
    pause(0.2);
    
end

