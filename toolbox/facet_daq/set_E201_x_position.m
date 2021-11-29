function set_E201_x_position(value)

lcaPut('XPS:LI20:MC03:M7.VAL',value);

pos = lcaGet('XPS:LI20:MC03:M7.RBV');

while abs(value - pos) > 0.01
    
    display(['Moving BLIS to ' num2str(value) ' mm. Current position is ' num2str(pos) ' mm.']);
    pos = lcaGet('XPS:LI20:MC03:M7.RBV');
    pause(0.2);
    
end