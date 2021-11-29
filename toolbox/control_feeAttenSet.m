function ract = control_feeAttenSet(r1, r2)

% feeAttenSet takes up to two arguments for desired FEE transmission.
%
% if both arguments are supplied, they are the transmission ratios of the gas
% and solid attenuators respectively.
%
% if only one argument is supplied, it is interpreted as a desired total
% FEE attenuation, and some boneheaded logic is used to choose relative
% amounts of gas and solid attenuation.  For now it uses a simple cut, if
% the photon energy is below 2 keV, it uses all gas, otherwise uses all
% solids.

% get current photon energy eV
photonE = lcaGetSmart('SIOC:SYS0:ML00:AO627');

if nargin == 2
    gtrans = r1;
    strans = r2;
elseif nargin == 1
    % simple "smarts" just uses solids for high energy, gas for low energy
    if photonE > 2000
        gtrans = 1;
        strans = r1;
    else
        gtrans = r1;
        strans = 1;
    end
else
    error('Not enough input parameters');
end

% set "energy for desired atten" to current energy and make sure both
% attenuators are in "auto" mode
lcaPutSmart({'SATT:FEE1:320:EDES', 'GATT:FEE1:310:E_DES'}, photonE);
lcaPutSmart({'SATT:FEE1:320:EACT.SCAN', 'GATT:FEE1:310:EACT.SCAN'}, 6);  % 6 is "auto"

% set gas attenuator setpoint
lcaPutSmart('GATT:FEE1:310:R_DES', gtrans);
pause(0.25);
pdes = lcaGetSmart('GATT:FEE1:310:P_DES_ATT');          % get pressure from lookup table
max_p = 0.95 * lcaGetSmart('GATT:FEE1:310:P_DES.DRVH'); % find max pressure (.DRVH)

flow_status = lcaGetSmart('GFFSM:FEE1:310:ATT_FLOW_STATUS');

if pdes < 0.1                                           % if desired pressure too low,
    lcaPutSmart('GFFSM:FEE1:310:FLOW_ATT', 'OFF');      % just turn off the gas flow
    pause(0.25);
    lcaPutSmart('GATT:FEE1:310:P_DES', 0);              % set pressure setpoint to zero,
    
elseif pdes > max_p                                     % if desired pressure too high
    lcaPutSmart('GFFSM:FEE1:310:FLOW_ATT', 'ON');       % turn on the gas flow
    pause(0.25);
    lcaPutSmart('GATT:FEE1:310:P_DES', max_p);          % set pressure setpoint to max,
    
else                                                    % otherise, pressure is within range
    lcaPutSmart('GFFSM:FEE1:310:FLOW_ATT', 'ON');       % turn on the gas flow
    pause(0.25);
    lcaPutSmart('GATT:FEE1:310:P_ATT_USE.PROC', 1)      % click the "use" button

end

% set solid attenuator setpoint
lcaPutSmart('SATT:FEE1:320:RDES', strans);
pause(0.25);

% get floor and ceiling options
opt = lcaGetSmart({'SATT:FEE1:320:R_CEIL', 'SATT:FEE1:320:R_FLOOR'});

% see which option is closest to the desired transmission and use that one
diff = strans - opt;
[ruse, best] = min(abs(diff)); % best is 1 for ceiling, 2 for floor

% press "use" button - set to 2 for ceiling, 3 for floor
lcaPutSmart('SATT:FEE1:320:GO', best + 1);
% wait for them to start moving
pause(1);

% wait up to 5 seconds for attenuators to finish move
for ix = 1:5
    [ract, gatt, satt] = control_feeAttenGet();
    ismoving = strcmp(satt.state, 'XSTN');
    if ~any(ismoving)
        break;
    end
    pause(1);
end