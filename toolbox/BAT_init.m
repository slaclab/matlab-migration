function static = BAT_init()

% BAT_init sends back a data structure full of goodies used for the beam
% arrival time calculations.  all this stuff is PV names, constants, etc and
% should be unchanged at runtime.

% matlab PV prefix
pre = 'SIOC:SYS0:ML00:AO';
disp('BAT_init, 11/9/17');

%% basic stuff
static.num.cavities = 4;                                    % number of cavities
static.num.chans = 4;                                       % number of channels
static.num.points = 1024;                                   % data values per channel
static.length = static.num.chans * static.num.points;       % total length of waveform (4096)

%% PV names

% everything in static.pv is an input for BAT_mon.m
% everything in static.pv.out, static.pv.ctrl, and static.pv.bld (?) is output

% waveform/array PVs
static.array.waveform = 'UND:R02:IOC:16:dig1:WAV';

% This is a subset of the full waveform. Could have all 4 ch, but sometimes just 1
% static.array.waveform = 'UND:R02:IOC:16:dig1:WAV1';

% digitizer PV names
%static.pv.dig.waveform  = 'UND:R02:IOC:16:dig1:WAV';        % digitizer waveform PV
static.pv.dig.trigger   = 'UND:R02:EVR:16:CTRL.DG0D';         % digitizer trigger delay PV
static.pv.dig.arm       = 'UND:R02:IOC:16:dig1:ARM';        % digitizer trigger arm
static.pv.digclockmode = 'UND:R02:IOC:16:dig1:CLK';         % digitizer clock mode, 0 = internal, 1 = external

% cavity PV names
static.pv.cavity.heater    = {'UND:R02:IOC:16:Cavity1:HeaterOn' 'UND:R02:IOC:16:Cavity2:HeaterOn'};
static.pv.cavity.temps     = {'UND:R01:BHC:05:KL3314:SLOT2:TEMP5' 'UND:R01:BHC:05:KL3314:SLOT2:TEMP6'};

% control PV names
static.pv.ctrl.dac      = {'LAS:UND:MMS:02' 'LAS:UND:MMS:01'};  % new stepper motor style phase shifter 4/2/2013
static.pv.ctrl.time     = {'UND:R02:IOC:16:PhaseShifter2:Q' 'UND:R02:IOC:16:PhaseShifter2:I'}; % phase shifter #2 I & Q
static.pv.ctrl.atten    = {'UND:R02:IOC:16:BTAM1:Attenuator', 'UND:R02:IOC:16:BTAM2:Attenuator', ...
                           'UND:R02:IOC:16:BTAM3:Attenuator', 'UND:R02:IOC:16:BTAM4:Attenuator'};
static.pv.ctrl.amp      = {'UND:R02:IOC:16:BTAM1:RF:Switch', 'UND:R02:IOC:16:BTAM2:RF:Switch', ...
                           'UND:R02:IOC:16:BTAM3:RF:Switch', 'UND:R02:IOC:16:BTAM4:RF:Switch'};

% chassis status bits
static.pv.status = {'UND:R02:IOC:16:DigIn0:Port0:In0', 'UND:R02:IOC:16:DigIn0:Port0:In1', ... 
                    'UND:R02:IOC:16:DigIn0:Port0:In2', 'UND:R02:IOC:16:DigIn0:Port0:In3'};
                       
% beamline data PV names
static.pv.bld.phase_rotation    = {'UND:R02:IOC:10:BAT:PhaseRotation1' 'UND:R02:IOC:10:BAT:PhaseRotation2'};
static.pv.bld.charge_scale      = {'UND:R02:IOC:10:BAT:ChargeScale1'   'UND:R02:IOC:10:BAT:ChargeScale2'};
static.pv.bld.cav_freq          = {'UND:R02:IOC:10:BAT:CavityFreq1'    'UND:R02:IOC:10:BAT:CavityFreq2'};
static.pv.bld.prec_start        = {'UND:R02:IOC:10:BAT:PrecStart1'     'UND:R02:IOC:10:BAT:PrecStart2'};

% digitizer trigger PVs
static.pv.trig.enable{1}                   = ['UND:R02:EVR:16:TRIG0:EVENTCTRL.OUT0'];
static.pv.trig.eventcode{1}                   = ['UND:R02:EVR:16:TRIG0:EVENTCTRL.ENM'];
static.pv.trig.eventcode_enable{1}                   = ['UND:R02:EVR:16:TRIG0:EVENTCTRL.ENAB'];
for index = 1:14
    static.pv.trig.enable{index+1}           = ['UND:R02:EVR:16:EVENT' num2str(index) 'CTRL.OUT0'];
    static.pv.trig.eventcode{index+1}        = ['UND:R02:EVR:16:EVENT' num2str(index) 'CTRL.ENM'];
    static.pv.trig.eventcode_enable{index+1} = ['UND:R02:EVR:16:EVENT' num2str(index) 'CTRL.ENAB'];
end
static.pv.trig.delay = 'UND:R02:EVR:16:CTRL.DG0D';         % digitizer trigger delay PV

% matlab PVs for the feedback process
static.pv.in.charge         = 'IOC:IN20:BP01:QANN';         % beam charge estimate
static.pv.in.charge_max     = [pre '742'];       % for choosing attenuation (pC)
%static.pv.out.mon_119       = [pre '743'];       % Channel 3&4 119 MHz (rad 119?)
static.pv.in.time_ctrl      = [pre '744'];       % time control (?) (ps)
static.pv.in.dac_scale      = [pre '746'];       % DAC I/Q scale (V)
static.pv.in.phase_jump_tol = [pre '747'];       % limit for RF resync (ps)
% static.pv.out.phase_shift_ps= [pre '748'];       % phase shift (ps)
static.pv.out.phase_shift_ps= {[pre '748'] [pre '718']};       % phase shift (ps)
static.pv.out.diff_noise    = [pre '749'];       % rms(cav1 - cav2)
% static.pv.out.phase_shifter = [pre '750'];       % phase shift (deg476)
static.pv.out.phase_shifter = {[pre '750'] [pre '717']};       % phase shift (deg476)
static.pv.out.diffs         = strcat(pre, cellstr(num2str((701:716)')));
static.pv.in.amp_threshold  = [pre '745'];       % charge threshold (pC) for new high gain amp

% cavity specific matlab PVs
                                % cavity 1      % cavity 2
static.pv.in.cav.scale      = { [pre '752'] [pre '764'] [pre '777'] [pre '789']};    % scale (a.u.) - what does this do?
static.pv.in.cav.offset     = { [pre '753'] [pre '765'] [pre '778'] [pre '790']};    % phase offset (ps)
static.pv.out.cav.charge    = { [pre '754'] [pre '766'] [pre '779'] [pre '791']};    % measured charge from analysis   
static.pv.out.cav.time      = { [pre '755'] [pre '767'] [pre '780'] [pre '792']};    % measured arrival time (ps)
static.pv.out.cav.freq      = { [pre '756'] [pre '768'] [pre '781'] [pre '793']};    % measured cavity freq (MHz - 2805 MHz)
static.pv.out.cav.maxcounts = { [pre '757'] [pre '769'] [pre '782'] [pre '794']};    % max cavity counts
static.pv.in.cav.gain       = { [pre '758'] [pre '770'] [pre '783'] [pre '795']};    % attenuator setting - what does this do?
static.pv.out.cav.std       = { [pre '759'] [pre '771'] [pre '784'] [pre '796']};    % measured arrival time stdev (ps)
static.pv.out.cav.diff      = { [pre '760'] [pre '772'] [pre '785'] [pre '797']};    % (cavN - cav1) measured arrival time (ps)
static.pv.in.cav.fbgain     = { [pre '761'] [pre '773'] [pre '786'] [pre '798']};    % gain for feedback
static.pv.in.cav.starttime  = { [pre '762'] [pre '774'] [pre '787'] [pre '799']};    % arrival time offset (us) - from calibration
static.pv.out.cav.q         = { [pre '763'] [pre '775'] [pre '788'] [pre '800']};    % measured cavity Q (a.u.)

% miscellaneous stuff
static.pv.evr       = 'UND:R02:EVR:16:STATUS';                % EVR link status
static.pv.resync    = 'UND:R02:IOC:16:BTAM2:Resync';        % divide-by-4 resync PV
static.pv.charge    = 'IOC:IN20:BP01:QANN';                 % charge setpoint
static.pv.watchdog = [pre '751'];                           % watchdog counter
static.pv.humidity  = 'UND:R02:IOC:16:Humidity';            % humidity sensor
static.pv.rate      = 'EVNT:SYS0:1:LCLSBEAMRATE';           % beam rate

%% frequency parameters

static.freq.cav = [2805e6, 2805e6, 2805e6, 2805e6];                         % cavity frequencies
static.freq.lo  = 2856e6;                                   % mixer LO frequency
static.freq.clock = static.freq.lo / 24;                    % digitizer clock = 119 MHz
static.freq.if  = static.freq.cav - static.freq.lo;         % intermediate freq

%% feedback parameters

static.fbck.delay = 1;                                    % feedback rate (1/Hz)
static.fbck.gain_multiplier = 2 * pi * 476e6 * 1e-12;       % 0.00299 rad476 per picosecond
static.fbck.maxstep = 20;                                   % feedback maximum change per step, in picoseconds
static.fbck.q_threshold = 10;                               % measured charge must be higher for fbck actuation
static.fbck.dig_threshold = 500;                            % digitizer signal must be higher for fbck actuation

%% filter parameters

static.filter.poles = 3;                                    % filter order
static.filter.w     = 0.12;                                 % filter cutoff frequency
static.filter.type  = 'butter';                             % name of matlab filter function

%% window sizes for trimming data

% shift crude and fit time windows by 1 and 2 ticks respectively, to match old
% definitions

static.crude.time = [2e-6; 8e-6];     % in seconds after digitizer start
static.fit.time   = [3.05e-6; 5e-6];  % was 3.2, 3.05 for previoues
%static.fit.time   = [3.05e-6; 4.042e-6];  % was 3.2, 3.05 for previoues
%static.prec.time  = [2.9259e-6, 2.9259e-6; 5e-6, 5e-6];  	% after first cavity calibration 6/4
static.prec.time  = [2.9259e-6, 2.9259e-6; 2.9259e-6, 2.9259e-6];  	% changed 7/16/13

%% amplifier/attenuator parameters

% range of usable attenuators
static.atten.start = [9 9];                                     % use only 9 through 15
static.atten.end   = [15 15];

% default attenuator
static.atten.default = [12 12];                                  % 12 is default, defined with gain = 1 and dphi = 0

% measured phase shifts (#12 = 0 by definition)
static.atten.phase = zeros(15, static.num.cavities);
static.atten.phase(static.atten.start:static.atten.end, 1) = deal([0, 0, 0, 0, 0, 0, 0]);
static.atten.phase(static.atten.start:static.atten.end, 2) = deal([0, 0, 0, 0, 0, 0, 0]);
static.atten.phase(static.atten.start:static.atten.end, 3) = deal([7.75, 4.6, 13.9, 0, 9.7, 4.8, 11]);
static.atten.phase(static.atten.start:static.atten.end, 4) = deal([6.35, 5.8, 13.3, 0, 6.7, 6.4, 11.3]);

% measured gains, measured May 2011 (#12 = 1 by definition)
static.atten.gain = zeros(16, static.num.cavities);
static.atten.gain(static.atten.start:static.atten.end, 1) = deal([0.1877, 0.3236, 0.5663, 1.0000, 1.7702, 3.1294, 5.6230]);
static.atten.gain(static.atten.start:static.atten.end, 2) = deal([0.2387, 0.3714, 0.6063, 1.0000, 1.7079, 3.1206, 5.4714]);
static.atten.gain(static.atten.start:static.atten.end, 3) = deal([0.1939, 0.3305, 0.5767, 1.0000, 1.7723, 3.0995, 5.4857]);
static.atten.gain(static.atten.start:static.atten.end, 4) = deal([0.1835, 0.3218, 0.5624, 1.0000, 1.7624, 3.1579, 5.5128]);

% amplifier gain
static.amp.gain = [1, 1, 1, 1];

%% measured backgrounds

static.background = [-21, 157, 38, -3];

%% set up all the various processing vectors

% for raw data, back-calculate the start and end times
static.raw.points   = [1; static.num.points];
static.raw.time     = (static.raw.points - 1) / static.freq.clock;
static.raw.timevec     = (cumsum(ones(static.num.points, 1)) - 1) / static.freq.clock;

% all this now lives in BAT_calc

% truncated data - start/stop points and time vector (for plotting)
% 
% static.crude.points   = round(static.crude.time * static.freq.clock);
% static.crude.timevec  = static.raw.timevec(static.crude.points(1):static.crude.points(2));
% 
% % further truncated for fitting 
% static.fit.points   = round(static.fit.time * static.freq.clock);
% static.fit.timevec  = static.crude.timevec((static.fit.points(1) - static.crude.points(1)):...
%                                            (static.fit.points(2) - static.crude.points(1)));
% IF vectors for downconversion
for index = 1:static.num.cavities
    static.if.sin(:, index) = sin(2 * pi * static.raw.timevec * static.freq.if(index));
    static.if.cos(:, index) = cos(2 * pi * static.raw.timevec * static.freq.if(index));
end

%% calculate filter coefficients

eval(['[static.filter.B, static.filter.A] = ' static.filter.type ...
      '(' num2str(static.filter.poles) ', ' num2str(static.filter.w) ');']);

%% setup trigger controls for matlab process

% correct trigger timing for various event codes - add more as needed
static.trig.delay(:, 1) = [140, 106030];                       % 107685 EVR ticks delay for event code 140 (beam full)
static.trig.delay(:, 2) = [150, 106020];                       % delay for event code 150 - burst mode
static.trig.delay(:, 3) = [43,  107578];                       % event code 43 is 10 Hz free-running, for testing

% TODO this should really go in BAT_mon
% initialize enable bits to zero
static.trig.enable = zeros(size(static.pv.trig.enable));
static.trig.eventcode = zeros(size(static.pv.trig.eventcode));
static.trig.eventcode_enable = zeros(size(static.pv.trig.eventcode_enable));

%% start digitizer monitor

% lcaSetMonitor(static.array.waveform);

end
