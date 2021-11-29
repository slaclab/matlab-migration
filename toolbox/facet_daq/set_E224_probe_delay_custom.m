% usage: set value to [0, 1, 2, 3.....] and program desired delay to map to each number
% E. Adli, 2015-05-29
function set_E224_probe_delay(value)

t0 = 56; %[mm] - this is the approx. delay after laser beam
% ADJUST t0 for relative to ebeam

if( value == 0)
  ddelay = 0;
elseif( value == 1)
  ddelay = -1e-3;
elseif( value == 2)
  ddelay = -3e-3;
elseif( value == 3)
  ddelay = -10e-3;
elseif( value == 4)
  ddelay = -30e-3;
elseif( value == 5)
  ddelay = -100e-3;
elseif( value == 6)
  ddelay = -300e-3;
elseif( value == 7)
  ddelay = -1;
elseif( value == 8)
  ddelay = -3;
elseif( value == 9)
  ddelay = -10;
elseif( value == 10)
  ddelay = -30;
elseif( value == 11)
  ddelay = -100;
elseif( value == 12)
  % max out
  ddelay = -74-t0;;
else
  ddelay = -74-t0;
end% if

total_delay = t0 + ddelay;

lcaPut('XPS:LI20:MC05:M5', total_delay);

pos = lcaGet('XPS:LI20:MC05:M5.RBV');

while abs(total_delay - pos) > 0.01
    
    display(['Moving stage to ' num2str(total_delay) ' mm. Current position is ' num2str(pos) ' mm.']);
    pos = lcaGet('XPS:LI20:MC05:M5.RBV');
    pause(0.3);
    
end

