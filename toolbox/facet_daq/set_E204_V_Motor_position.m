function set_E204_V_Motor_position(value)

lcaPut('XPS:LI20:MC03:M8',value);

pos = lcaGet('XPS:LI20:MC03:M8');

while abs(value - pos) > 0.01
    
    display(['Moving XPS:LI20:MC03:M8 to ' num2str(value) ' mm. Current position is ' num2str(pos) ' mm.']);
    pos = lcaGet('XPS:LI20:MC03:M8');
    pause(0.2);
    
end

