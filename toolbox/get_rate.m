function [rate,order]=get_rate(rate_event)
switch rate_event 
    case 226
        rate = 0.5;
        order=1;
    case 225
        rate = 1;
        order=2;
    case 224
        rate = 5;
        order=3;
    case 223
        rate = 10;
        order=4;
    otherwise
        error('event code is unknown')
end
    