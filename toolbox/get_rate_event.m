function rate_event=get_rate_event(rate)
switch rate 
    case 0.5
        rate_event = 226;
%         order=1;
    case 1
        rate_event = 225;
%         order=2;
    case 5
        rate_event = 224;
%         order=3;
    case 10
        rate_event = 223;
%         order=4;
    otherwise
        error('event code is unknown')
end
    