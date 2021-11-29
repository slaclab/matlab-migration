function set_E201_y_position(value)

lcaPut('XPS:LI20:MC03:M8.VAL',value);

pos = lcaGet('XPS:LI20:MC03:M8.RBV');

while abs(value - pos) > 0.01
    
    display(['Moving E201 Y motor to ' num2str(value) ' mm. Current position is ' num2str(pos) ' mm.']);
    pos = lcaGet('XPS:LI20:MC03:M8.RBV');
    pause(0.2);
    
end