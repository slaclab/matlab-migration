function [tolArray, E_GeV] = energyJitterTol(E_GeV)
% function [tolArray, E_GeV] = energyJitterTol(E_GeV)
%
%  Compute LCLS energy jitter alarm tolerances. Function only flags based
%  on upper limit for local jitters that satisfies meeting the DL2 jitter
%  goal at end of linac under ideal linear compression.
%
%  Inputs:
%   E_GeV = Electron beam energy in GeV
%     - If NaN, present value is looked up and PVs are NOT updated.
%     - If a number, calculates all tolArray values (all except DL2 are
%       estimates based on fixed machine config).
%     - IF NO ARGUMENT PASSED this function behaves as a watcher
%       process loop, updating the CUD alarm levels.
%
%  Outputs:
%   tolArray = [%] 4x2 array of alarm threshhold for energy jitters.
%     Values are [YELLOW, RED] alarm values.
%   E_GeV = Electron beam energy used for calculation

% By T. Maxwell, 2015-Jun-02

% [yellow, red] ALARMS are set based on the (theoretical) fraction of
% average brightness due to jitter is reduced by some fraction ALARMS of
% the 'frozen beam' case.

% Higher is better performance with 1 = zero jitter, harder to reach.
% Set as 25% and ~60% performance loss marks, with some wiggle room.
defalarms = [0.75, 0.575];
limitPVs = {...
    'SIOC:SYS0:ML01:AO536',... % HIGH level
    'SIOC:SYS0:ML01:AO537'}; % HIHI level
[alarms,~,ispv] = lcaGetSmart(limitPVs);
if any(~ispv) || any(isnan(alarms))
    warning('energyJitterTol: Can''t get desired level, using defaults.')
    alarms = defalarms; % fraction reduction in range [0, 1]
end
if any(alarms >= 1)
    warning('energyJitterTol: An input alarm is >= 1! Clamping.')
    alarms(alarms >= 1) = 1-1e-9;
end
if any(alarms <= 0)
    warning('energyJitterTol: An input alarm is <= 0! [0,1] Clamping.')
    alarms(alarms <= 0) = 1e-9;
end

assumeCurrents = [2.5e3, 3e3]; % A, current to use for [SXR, HXR] cases
assumeEmit = 0.4; % um, assumed slice emittance
% hard and soft independent lines, always calculate using hard for now, 
% until fully updated to reflect operating modes. this is the more
% stringent of the two:
softBelow = -1; % GeV, highest energy considered SXR 
assumegunphijit = .03;%.04; % degS (really ps), some gun phase jitter allowance, typ. .03-.05 diurnally

failans = [.05,.075; 0.05, 0.075; .1,.15; .12,.17]; % SXR solution to use if elements have weirdness
failans(:,:,2) = [.05,.075;.05,.075;.1,.15;.04,.06]; % HXR solution to use if elements have weirdness

% Config PVs, needed to sort out stuff before DL2:
PVnames = {...
    'SIOC:SYS0:ML00:AO513';...   % 1- MeV, energy after L0 (DL1)
    'SIOC:SYS0:ML00:AO478';...   % 2- MV, L1S amp
    'SIOC:SYS0:ML00:AO479';...   % 3- degS, L1S phase
    'SIOC:SYS0:ML00:AO480';...   % 4- MV, L1X amp
    'SIOC:SYS0:ML00:AO481';...   % 5- degX, L1X phase
    'SIOC:SYS0:ML00:AO484';...   % 6- mm, BC1 R56 PV
    'SIOC:SYS0:ML00:AO483';...   % 7- MeV, energy after L1
    'SIOC:SYS0:ML00:CALC204';... % 8- degS, L2 phase
    'SIOC:SYS0:ML00:AO489';...   % 9- GeV, energy after L2
    'SIOC:SYS0:ML00:AO490';...   % 10- mm, BC2 R56 PV
    'SIOC:SYS0:ML00:AO499';      % 11- degS, L3 phase
    'SIOC:SYS0:ML00:AO500'};     % 12- GeV, energy after L3 (DL2)
f = 2.856e9; % rf frequency

if nargin > 0 % user call (not watcher process)
    if ~isnan(E_GeV)
        if E_GeV > softBelow
            % Imagined HXR config
            machstate = [135, 110, -23.4, 20, -160, -45.5, 220, -36, 5, -28, 0, E_GeV];
        else
            % Imagined SXR config
            machstate = [135, 110, -23.4, 20, -160, -45.5, 220, -32, 3, -28, 0, E_GeV];
        end
    else
        machstate = lcaGetSmart(PVnames);
        E_GeV = machstate(12);
    end
    % Compute DL2 values
    tolArray = zeros(4,2);
    saseBW = calcRho(E_GeV,...
        assumeCurrents(1+(E_GeV >= softBelow)),...
        assumeEmit);
    tolArray(4,:) = jitterForAvgBrightness(saseBW,alarms);
    % Build linear model. This is done in t-E units of ps and MeV
    % Matrix for L1S
    M(:,:,1) = [1,0;calcR65(machstate(2),machstate(3),f),1];
    % L1X
    M(:,:,2) = [1,0;calcR65(machstate(4),machstate(5),4*f),1];
    % BC1
    M(:,:,3) = [1,convR56(machstate(6),machstate(7));0,1];
    % L2
    L2amp = (machstate(9)*1e3-machstate(7))/cosd(machstate(8));
    M(:,:,4) = [1,0;calcR65(L2amp,machstate(8),f),1];
    % BC2
    M(:,:,5) = [1,convR56(machstate(10),machstate(9)*1e3);0,1];
    % L3
    L3amp = (machstate(12)*1e3-machstate(9)*1e3)/cosd(machstate(11));
    M(:,:,6) = [1,0;calcR65(L3amp,machstate(11),f),1];

    % Figure out the limits at DL1 assuming we know the energy jitter limits at
    % the end, some initial phase jitter driven by gun, and ~0 t-E correlation

    % DL1 to DL2 matrix:
    Mtot = M(:,:,1);
    for k = 2:size(M,3)
        Mtot = M(:,:,k)*Mtot;
    end
    % Rescale our energy jitter to MeV^2 (covariance matrix units):
    tolArray(4,:) = (tolArray(4,:)*machstate(12)*1e3).^2;
    % Solution for DL1 jitter:
    tolArray(1,:) = (tolArray(4,:) - assumegunphijit^2*Mtot(2,1)^2) / Mtot(2,2)^2;
    % Forward calculate BC1/2 values
    for k = 1:2
        SIG = [assumegunphijit^2,0;0,tolArray(1,k)];
        SIG = M(:,:,2)*M(:,:,1)*SIG*M(:,:,1).'*M(:,:,2).';
        tolArray(2,k) = SIG(2,2);
        SIG = M(:,:,4)*M(:,:,3)*SIG*M(:,:,3).'*M(:,:,4).';
        tolArray(3,k) = SIG(2,2);
        %SIG = M(:,:,5)*SIG*M(:,:,5).';
        %sqrt(SIG(2,2))/(E_GeV*1e3)*100 %this was here to check self consistent
    end
    % Rescale from absolute covariance values
    tolArray(1,:) = sqrt(tolArray(1,:))/machstate(1);
    tolArray(2,:) = sqrt(tolArray(2,:))/machstate(7);
    tolArray(3,:) = sqrt(tolArray(3,:))/(machstate(9)*1e3);
    tolArray(4,:) = sqrt(tolArray(4,:))/(machstate(12)*1e3);
    tolArray = 100*tolArray;
    % Sanity checking
    repl = isnan(tolArray) | (imag(tolArray) > 0) | ...
        (tolArray < 1e-3) | (tolArray > .3);
    use = failans(:,:,1+(E_GeV >= softBelow));
    tolArray(repl) = use(repl);
    return 
end
% If no argument, setup watchdog counter and proceed with loop.

POSTnames = {... % PV names we're updating.
    'SIOC:SYS0:ML00:AO170.HIGH','SIOC:SYS0:ML00:AO170.HIHI';...
    'SIOC:SYS0:ML00:AO171.HIGH','SIOC:SYS0:ML00:AO171.HIHI';...
    'SIOC:SYS0:ML00:AO172.HIGH','SIOC:SYS0:ML00:AO172.HIHI';...
    'SIOC:SYS0:ML00:AO173.HIGH','SIOC:SYS0:ML00:AO173.HIHI'};
POSTnames = reshape(POSTnames,8,1);
WDPV = 'SIOC:SYS0:ML01:AO535';
[system_status host] = system('hostname');
whoami = getenv('USER');
disp([datestr(now) ' energyJitterTol.m running as ' whoami ' on ' host]);
delay = 2;
lcaSetSeverityWarnLevel(5);  % disables unwanted warnings.
W = watchdog(WDPV,1, 'energyJitterTol' );
if get_watchdog_error(W)
    disp([datestr(now) 'energyJitterTol already running']);
    return
end

while 1 % Main loop
    pause(delay);
    W = watchdog_run(W); % Run watchdogcounter
    try 
        % Compute DL2 values
        machstate = lcaGetSmart(PVnames);
        E_GeV = machstate(12);
        tolArray = zeros(4,2);
        saseBW = calcRho(E_GeV,...
            assumeCurrents(1+(E_GeV >= softBelow)),...
            assumeEmit);
        tolArray(4,:) = jitterForAvgBrightness(saseBW,alarms);
        % Build linear model. This is done in t-E units of ps and MeV
        % Matrix for L1S
        M(:,:,1) = [1,0;calcR65(machstate(2),machstate(3),f),1];
        % L1X
        M(:,:,2) = [1,0;calcR65(machstate(4),machstate(5),4*f),1];
        % BC1
        M(:,:,3) = [1,convR56(machstate(6),machstate(7));0,1];
        % L2
        L2amp = (machstate(9)*1e3-machstate(7))/cosd(machstate(8));
        M(:,:,4) = [1,0;calcR65(L2amp,machstate(8),f),1];
        % BC2
        M(:,:,5) = [1,convR56(machstate(10),machstate(9)*1e3);0,1];
        % L3
        L3amp = (machstate(12)*1e3-machstate(9)*1e3)/cosd(machstate(11));
        M(:,:,6) = [1,0;calcR65(L3amp,machstate(11),f),1];

        % Figure out the limits at DL1 assuming we know the energy jitter limits at
        % the end, some initial phase jitter driven by gun, and ~0 t-E correlation

        % DL1 to DL2 matrix:
        Mtot = M(:,:,1);
        for k = 2:size(M,3)
            Mtot = M(:,:,k)*Mtot;
        end
        % Rescale our energy jitter to MeV^2 (covariance matrix units):
        tolArray(4,:) = (tolArray(4,:)*machstate(12)*1e3).^2;
        % Solution for DL1 jitter:
        tolArray(1,:) = (tolArray(4,:) - assumegunphijit^2*Mtot(2,1)^2) / Mtot(2,2)^2;
        % Forward calculate BC1/2 values
        for k = 1:2
            SIG = [assumegunphijit^2,0;0,tolArray(1,k)];
            SIG = M(:,:,2)*M(:,:,1)*SIG*M(:,:,1).'*M(:,:,2).';
            tolArray(2,k) = SIG(2,2);
            SIG = M(:,:,4)*M(:,:,3)*SIG*M(:,:,3).'*M(:,:,4).';
            tolArray(3,k) = SIG(2,2);
            %SIG = M(:,:,5)*SIG*M(:,:,5).';
            %sqrt(SIG(2,2))/(E_GeV*1e3)*100 %this was here to check self consistent
        end
        % Rescale from absolute covariance values
        tolArray(1,:) = sqrt(tolArray(1,:))/machstate(1);
        tolArray(2,:) = sqrt(tolArray(2,:))/machstate(7);
        tolArray(3,:) = sqrt(tolArray(3,:))/(machstate(9)*1e3);
        tolArray(4,:) = sqrt(tolArray(4,:))/(machstate(12)*1e3);
        tolArray = 100*tolArray;
        % Sanity checking
        repl = isnan(tolArray) | (imag(tolArray) > 0) | ...
            (tolArray < 1e-3) | (tolArray > .3);
        use = failans(:,:,1+(E_GeV >= softBelow));
        tolArray(repl) = use(repl);
        % Post results
        lcaPutSmart(POSTnames,reshape(tolArray,8,1));
        % Tacked on: Also post jitter-reduced brightness through a mono
        % (this is percent of average brightness of a jittery beam to a
        % perfectly stable beam)
        DL2jit = lcaGetSmart('SIOC:SYS0:ML00:AO173');
        if ~isnan(DL2jit)
            DL2jit = DL2jit/100;
            jitReducedB = saseBW/sqrt(4*DL2jit^2+saseBW^2);
            lcaPutSmart('SIOC:SYS0:ML01:AO538',jitReducedB);
        end
    catch ex
        disp([datestr(now) ' Error in energyJitterTol.m main loop:'])
        disp(ex.message)
    end
end



function rho = calcRho(energy,currentMax,emitN)
% energy in GeV, current in A, emitN in um.
unduK = 2.55; % hard undulator max K
emitN = 1e-6*emitN;
beta = 30*energy/13.6; % average beta, per Yuantao Ding
unduPeriod = 0.026; % hard undulator period
alfvenCurrent = 17045.0;
mc2 = 0.51099906E-3;
c   = 2.99792458E8;
e   = 1.60217733E-19;
unduJJ  = besselj(0,unduK^2/(4+2*unduK^2))-besselj(1,unduK^2/(4+2*unduK^2));
unduK1  = unduK*unduJJ;
gamma0  = energy/mc2;
sigmaX2 = emitN.*beta./gamma0;
rho     = (0.5./gamma0).*((currentMax./alfvenCurrent).*(unduPeriod*unduK*unduJJ/(2*pi)).^2./(2.*sigmaX2)).^(1/3);


function sigE = jitterForAvgBrightness(saseBW, fraction)
%  function sigE = jitterForAvgBrightness(saseBW, fraction)
%
%    For given SASE BW, compute beam energy jitter required to reduce average
%    brightness by FRACTION. Answer is in same units as saseBW.
sigE = saseBW/2*sqrt(1-fraction.^2)./fraction;

function r65 = calcR65(amp, phi, f)
% amp in MV, phi in deg, f in Hz
r65 = -2*pi*f*amp*sind(phi)*1e-12; %MeV/ps

function r56 = convR56(r56, E)
% input r56 in mm, E in MeV
r56 = r56/2.99792458*1e1./E; % ps/MeV