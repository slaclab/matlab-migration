function pau_sync(ds)

if nargin < 1, ds=0:3;end

% Zero LTU1 MUX offsets.
[nameLTU,stateLTU]=pau_toggle('FBCK:FB03:TR01:MODE');
pau_offsetZero({'XCQT32' 'XCDL4' 'YCQT32' 'YCQT42'},ds,':BCTRL');
pau_toggle(nameLTU,stateLTU);

%Disable 6x6 feedback.
[name6x6,state6x6]=pau_toggle('FBCK:FB04:LG01:MODE');

% Zero IN20 MUX offsets.
pau_offsetZero({'GUN' 'L0A' 'L0B' 'L1S' 'L1X'},ds);

% Zero abstraction layer MUX offsets.
pau_offsetZero({'ACCL:LI22:1:' 'ACCL:LI25:1:'},ds);

% Zero abstraction layer controlled MUX offsets.
[nameAbstr,stateAbstr]=pau_toggle('ACCL:LI22:1:ABSTR_ACTIVATE');
pau_offsetZero({'L2REF' '24-1' '24-2' '24-3' '29-0' '30-0'},ds);
pau_toggle(nameAbstr,stateAbstr);

%Resync PAU data slots.
lcaPut(strcat('LLRF:IN20:1:RESYNC_DS',cellstr(num2str(setdiff(ds(:),0)))),1);

%Restore 6x6 feedback.
pau_toggle(name6x6,state6x6);


function [name, state] = pau_toggle(name, state)

if nargin < 2
    state=lcaGet(name,0,'double');
    lcaPut(name,0);
else
    lcaPut(name,state);
end
pause(1);
