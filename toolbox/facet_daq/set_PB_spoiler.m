

function set_PB_spoiler(n)

spoiler = 'XPS:LI20:MC04:M2'; % EOS stage

switch n
    case 0
        VALUE = 84;
    case 1
        VALUE = 34;        
    case 2
        VALUE = 26.5;        
    case 3
        VALUE = 19.5;        
    case 4
        VALUE = 60;       
    case 5
        VALUE = 58;        
    case 6
        VALUE = 56;        
    case 7
        VALUE = 54;       
    case 8
        VALUE = 52;
    case 9
        VALUE = 50;
    case 10
        VALUE = 45;
    otherwise
        VALUE = 84;
        warning('Function can only take integer numbers between 0 and 10 as input. Moving stage to EOS crystal.');
end

% Move EOS stage to the desired position
lcaPutSmart(spoiler, VALUE);
wait_for_motor(spoiler, VALUE);