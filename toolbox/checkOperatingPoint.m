function newOP = checkOperatingPoint ( varargin )
%      the existing singleton*.
% CHECKOPERATINGPOINT M-file for checkOperatingPoint.fig
%      CHECKOPERATINGPOINT initializes the Operating Point (OP)
%      structure and updates it with the readbacks from the
%      LCLS control system. It can be called with the following
%      three parameter configurations:
%
%      OP = CHECKOPERATINGPOINT ( logbook ) lists the operating
%      point information to the terminal screen in one of two
%      formats:
%          (1) logbook = true:  in wiki logbook format
%          (2) logbook = false: in plain text format
%
%      OP = CHECKOPERATINGPOINT returns the initialized
%      OperatingPoint structure OP.
%
%      OP = CHECKOPERATINGPOINT ( OP ) refreshes the readbacks in the
%      OperatingPoint structure OP.
%
% Last Modified by WSC on 23-June-2010
% Last Modified by HDN on 11-July-2014 

global OP;
global OPctrl;
global PhysicsConsts;
global UndulatorConsts;

debug            = false;
verbose          = false;
initialize       = false;
formatForLogbook = false;
useSIOCvalues    = true;

if ( ~useSIOCvalues )
    fprintf ( 'Not using or updating SIOC fields for parameters and tolerances.\n' );
end

% Do not update .Parameter until EPICS 4.0 when .DESC field has
% sufficient number of bytes.
updateParameter  = false;
SIOC_ID.String   = 'OP-SP:';

if ( nargin )
    if ( nargin > 1 )
        fprintf ( 'Extra arguments in call to %s ignored.\n', mfilename );
    end
        
    if ( iscell ( varargin { 1 } ) )
        OP         = varargin { 1 };
        option     = 3;
    else
        option           = 1;
        verbose          = true;
        initialize       = true;
        formatForLogbook = varargin { 1 };
    end
else
    option     = 2;
    initialize = true;
end

if ( debug )
    fprintf ( '%s called with option %d [initialize: %d]\n', mfilename, option, initialize );
end


if ( initialize )
    PhysicsConsts   = util_PhysicsConstants;
    UndulatorConsts = util_UndulatorConstants;
    OP              = cell  ( 1, 1 );
    OPctrl.saved    = false;
    OPctrl.bufSize  = 20;                           % Number of integration samples for peak current averaging.
    OPctrl.IpkBuf   = zeros ( 1, OPctrl.bufSize );
    OPctrl.Ipklvl   = 0;
end

% NOTE 1: The display order of the parameters is determined after the
% definition. Parameters are only displayed if they are given a display
% order.

% NOTE 2: Some of the callback functions rely on the the order of the
% parameter definition. Do not alter the order unless confirmed that
% it will not break the code.

if ( initialize )
    [sys,accelerator]=getSystem();
    j                       = 1;
    OPctrl.ID.BeamRate      = j;

    OP { j }.Parameter = 'Machine repetition rate';
    OP { j }.ParamCode = 'BeamRate';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO467';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 30;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%2.0f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0;
    OP { j }.Tfmt      = '%s%1.0f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'Hz';
    OP { j }.Comment   = '10 Hz is also fine, if needed';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = ['EVNT:' sys ':1:' accelerator 'BEAMRATE'];
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO101';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO126';
    OP { j }.PREC      = 0;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.LaserPlsLen     = j;

    OP { j }.Parameter = 'Laser pulse length (FWHM)';
    OP { j }.ParamCode = 'LaserPlsLen';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO468';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 6.5;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 3.1f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0.3;
    OP { j }.Tfmt      = '%s%3.1f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'ps';
    OP { j }.Comment   = 'Measured on cross-correlator';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'SIOC:SYS0:ML00:AO021';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO102';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO127';
    OP { j }.PREC      = 1;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';
 
    j                         = j + 1;
    OPctrl.ID.LasrIrisDia     = j;

    OP { j }.Parameter = 'Laser iris diameter';
    OP { j }.ParamCode = 'LasrIrisDia';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO469';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 1.2;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%3.2f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0;
    OP { j }.Tfmt      = '%s%1.0f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'mm';
    OP { j }.Comment   = 'Iris Wheel Angle = 236º';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'IRIS:LR20:130:CONFG_SEL';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO103';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO128';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'IrisAngle2Diameter_Actual';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.BunchCharge     = j;

    OP { j }.Parameter = 'Bunch charge';
    OP { j }.ParamCode = 'BunchCharge';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO470';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 0.25;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%4.2f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0.01;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'nC';
    OP { j }.Comment   = 'Leave charge feedback set here';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'BPMS:IN20:221:TMIT';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO104';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO129';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'conv2nC_Actual';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.GunVoltage      = j;

    OP { j }.Parameter = 'Gun voltage (energy gain)';
    OP { j }.ParamCode = 'GunVoltage';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO471';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 6.00;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%4.2f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0.05;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'MeV';
    OP { j }.Comment   = 'Leave gun voltage feedback set here';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
%    OP { j }.PV        = 'GUN:IN20:1:GN1_ADES';
    OP { j }.PV        = 'GUN:IN20:1:GN1_S_AV';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO105';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO130';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.GunPhase        = j;

    OP { j }.Parameter = 'Gun phase (w.r.t. laser)';
    OP { j }.ParamCode = 'GunPhase';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO472';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 0;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%1.0f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0;
    OP { j }.Tfmt      = '%s%1.0f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'degS';
    OP { j }.Comment   = 'Leave gun phase set point at zero';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'GUN:IN20:1:GN1_PDES';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO106';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO131';
    OP { j }.PREC      = 0;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.LaserPhase      = j;

    OP { j }.Parameter = 'Laser phase';
    OP { j }.ParamCode = 'LaserPhase';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO473';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = -30.0;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 5.1f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 2.0;
    OP { j }.Tfmt      = '%s%3.1f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'degS';
    OP { j }.Comment   = 'Assuming offset is set correctly';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'LASR:IN20:1:LSR_0_S_PA';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO107';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO132';
    OP { j }.PREC      = 1;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.L0aVoltage      = j;

    OP { j }.Parameter = 'L0a voltage (energy gain)';
    OP { j }.ParamCode = 'L0aVoltage';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO474';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 57.5;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%4.1f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 2.0;
    OP { j }.Tfmt      = '%s%3.1f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'MeV';
    OP { j }.Comment   = 'Leave L0A set point at this value';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'ACCL:IN20:300:L0A_ADES';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO108';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO133';
    OP { j }.PREC      = 1;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.L0aPhase        = j;

    OP { j }.Parameter = 'L0a phase';
    OP { j }.ParamCode = 'L0aPhase';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO475';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 0.0;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%3.1f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 2.0;
    OP { j }.Tfmt      = '%s%3.1f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'degS';
    OP { j }.Comment   = 'Assuming offset is set correctly';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'ACCL:IN20:300:L0A_PDES';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO109';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO134';
    OP { j }.PREC      = 0;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.L0bVoltage      = j;

    OP { j }.Parameter = 'L0b voltage (energy gain)';
    OP { j }.ParamCode = 'L0bVoltage';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO476';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 71.5;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%4.1f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 2.0;
    OP { j }.Tfmt      = '%s%3.1f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'MeV';
    OP { j }.Comment   = 'Set for 135 MeV in DL1';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'ACCL:IN20:400:L0B_ADES';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO110';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO135';
    OP { j }.PREC      = 0;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.L0bPhase        = j;

    OP { j }.Parameter = 'L0b phase';
    OP { j }.ParamCode = 'L0bPhase';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO477';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = -2.5;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 5.1f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 2.0;
    OP { j }.Tfmt      = '%s%3.1f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'degS';
    OP { j }.Comment   = 'Assuming offset is set correctly';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'ACCL:IN20:400:L0B_PDES';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO111';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO136';
    OP { j }.PREC      = 1;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.L1SVoltage      = j;

    OP { j }.Parameter = 'L1S voltage (energy gain)';
    OP { j }.ParamCode = 'L1SVoltage';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO478';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 144;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%3.0f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 3;
    OP { j }.Tfmt      = '%s%2.0f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'MeV';
    OP { j }.Comment   = 'Set L1S for 250 MeV in BC1';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'ACCL:LI21:1:L1S_ADES';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO112';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO137';
    OP { j }.PREC      = 0;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.L1SPhase        = j;

    OP { j }.Parameter = 'L1S phase';
    OP { j }.ParamCode = 'L1SPhase';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO479';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = -22.0;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 5.1f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 2.0;
    OP { j }.Tfmt      = '%s%3.1f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'degS';
    OP { j }.Comment   = 'ON or OFF crest (-180º or this)';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'ACCL:LI21:1:L1S_PDES';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO113';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO138';
    OP { j }.PREC      = 1;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.L1XVoltage      = j;

    OP { j }.Parameter = 'L1X voltage (energy loss)';
    OP { j }.ParamCode = 'L1XVoltage';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO480';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 20;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%2.0f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 1;
    OP { j }.Tfmt      = '%s%1.0f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'MeV';
    OP { j }.Comment   = 'Sometimes turned off for studies';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'ACCL:LI21:180:L1X_ADES';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO114';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO139';
    OP { j }.PREC      = 0;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.L1XPhase        = j;

    OP { j }.Parameter = 'L1X phase';
    OP { j }.ParamCode = 'L1XPhase';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO481';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = -160;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 4.0f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 6;
    OP { j }.Tfmt      = '%s%2.0f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'degX';
    OP { j }.Comment   = 'ON or OFF crest ( -180º or this)';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'ACCL:LI21:180:L1X_PDES';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO115';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO140';
    OP { j }.PREC      = 0;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.BC1offset       = j;

    OP { j }.Parameter = 'BC1 x-offset';
    OP { j }.ParamCode = 'BC1offset';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO482';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = NaN;    % Will be overwritten by "calTarget" function.
    OP { j }.Tar_editbl = false;                  % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%5.1f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0.3;
    OP { j }.Tfmt      = '%s%3.1f';
    OP { j }.Toleditbl = true;                   % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'mm';
    OP { j }.Comment   = 'Set with BC1 GUI & R56 choice';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'BMLN:LI21:235:MOTR.VAL';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO117';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO142';
    OP { j }.PREC      = 1;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = 'calBC1offset_Target';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.BC1_E0          = j;

    OP { j }.Parameter = 'BC1 E0';
    OP { j }.ParamCode = 'BC1_E0';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO483';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 250;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%3.0f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       =    2;
    OP { j }.Tfmt      = '%s%1.0f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'MeV';
    OP { j }.Comment   = 'Actual calculated from BX12 BACT';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'BEND:LI21:231:BACT';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO123';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO148';
    OP { j }.PREC      = 0;
    OP { j }.calActual = 'getBC1_E0_Actual';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.BC1_R56         = j;

    OP { j }.Parameter = 'BC1 R56';
    OP { j }.ParamCode = 'BC1_R56';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO484';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = -45.5;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%5.1f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0.1;
    OP { j }.Tfmt      = '%s%3.1f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'mm';
    OP { j }.Comment   = 'Set with BC1 GUI';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'BEND:LI21:231:BACT';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO116';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO141';
    OP { j }.PREC      = 1;
    OP { j }.calActual = 'getBC1_R56_Actual';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.BC1_IPK         = j;

    OP { j }.Parameter = 'Peak current after BC1';
    OP { j }.ParamCode = 'BC1_IPK';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO485';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 234;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%3.0f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 5;
    OP { j }.Tfmt      = '%s%3.0f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'A';
    OP { j }.Comment   = 'Currently using feedback setpoint';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
%    OP { j }.PV        = 'FBCK:LNG6:1:BC1BLSP';
    OP { j }.PV        = 'BLEN:LI21:265:AIMAX';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO167';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO168';
    OP { j }.PREC      = 0;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.BC1_InjPhase    = j;

    OP { j }.Parameter = 'BC1 Injector Phase';
    OP { j }.ParamCode = 'BC1_InjPhase';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO486';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = NaN; % Will be overwritten by "calTarget" function.
    OP { j }.Tar_editbl = false;                  % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 7.2f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0.30;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'degS';
    OP { j }.Comment   = 'Based on Actual R56';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'BEND:LI21:231:BACT';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO151';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO152';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'calBC1_InjectorPhase_Actual';
    OP { j }.calTarget = 'calBC1_InjectorPhase_Target';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.L2Phase         = j;

    OP { j }.Parameter = 'L2 phase (21-3 to 24-6)';
    OP { j }.ParamCode = 'L2Phase';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO487';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = -36.0;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 5.1f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 1.0;
    OP { j }.Tfmt      = '%s%3.1f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'degS';
    OP { j }.Comment   = 'ON or OFF crest (0º or this)';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    [name, is, PACT, PDES]=control_phaseNames('L2');
    OP { j }.PV        = PDES{:};
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO118';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO143';
    OP { j }.PREC      = 1;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.BC2offset       = j;

    OP { j }.Parameter = 'BC2 x-offset';
    OP { j }.ParamCode = 'BC2offset';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO488';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = NaN;      % Will be overwritten by "calTarget" function.
    OP { j }.Tar_editbl = false;                  % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%5.1f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0.6;
    OP { j }.Tfmt      = '%s%3.1f';
    OP { j }.Toleditbl = true;                   % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'mm';
    OP { j }.Comment   = 'Set with BC2 GUI & R56 choice';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'BMLN:LI24:805:MOTR.VAL';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO120';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO145';
    OP { j }.PREC      = 1;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = 'calBC2offset_Target';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.BC2_E0          = j;

    OP { j }.Parameter = 'BC2 E0';
    OP { j }.ParamCode = 'BC2_E0';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO489';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 4.30;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%4.2f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0.05;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'GeV';
    OP { j }.Comment   = 'Actual calculated from BX22 BACT';
    OP { j }.PV        = 'BEND:LI24:790:BACT';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO124';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO149';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'getBC2_EO_Actual';
    OP { j }.calTarget = '';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.BC2_R56         = j;

    OP { j }.Parameter = 'BC2 R56';
    OP { j }.ParamCode = 'BC2_R56';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO490';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = -24.7;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%5.1f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0.1;
    OP { j }.Tfmt      = '%s%3.1f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'mm';
    OP { j }.Comment   = 'Set with BC2 GUI';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'BEND:LI24:790:BACT';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO119';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO144';
    OP { j }.PREC      = 1;
    OP { j }.calActual = 'getBC2_R56_Actual';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.BC2_IPK         = j;

    OP { j }.Parameter = 'Peak current after BC2';
    OP { j }.ParamCode = 'BC2_IPK';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO195';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 3000;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%4.0f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 100;
    OP { j }.Tfmt      = '%s%4.0f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'A';
    OP { j }.Comment   = 'Using filtered bunch length signal';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
%    OP { j }.PV        = 'FBCK:LNG6:1:BC2BLSP';
%    OP { j }.PV        = 'SIOC:SYS0:FB00:BC2_BLEN_IPK';
    OP { j }.PV        = 'BLEN:LI24:886:BIMAXHSTCUHBR';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO188';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO189';
    OP { j }.PREC      = 0;
    OP { j }.calActual = 'calBC2_IPK_Actual';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.BC2_InjPhase    = j;

    OP { j }.Parameter = 'BC2 Injector Phase';
    OP { j }.ParamCode = 'BC2_InjPhase';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO491';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = NaN; % Will be overwritten by "calTarget" function.
    OP { j }.Tar_editbl = false;                  % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 7.2f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0.30;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = false;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'degS';
   OP { j }.Comment   = 'Based on Actual R56';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'BEND:LI24:790:BACT';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO153';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO154';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'calBC2_InjectorPhase_Actual';
    OP { j }.calTarget = 'calBC2_InjectorPhase_Target';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.BC1_2_InjPhase  = j;

    OP { j }.Parameter = 'Injector Phase';
    OP { j }.ParamCode = 'BC1_2_InjPhase';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO492';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = NaN;      % Will be overwritten by "calTarget" function.
    OP { j }.Tar_editbl = false;                  % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 7.2f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0.40;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = false;                   % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'degS';
    OP { j }.Comment   = 'Sum of phase delays in BC1 + BC2';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
%    OP { j }.PV        = 'LLRF:IN20:RH:REF_1_S_PA';
    OP { j }.PV        = 'SIOC:SYS0:ML00:AO002';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO125';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO150';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = 'calBC1_BC2_InjectorPhase_Target';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.OTR2_P_EMITN_X  = j;

    OP { j }.Parameter = 'Proj. Norm. x emittance @OTR2';
    OP { j }.ParamCode = 'OTR2_P_EMITN_X';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO493';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 1.20;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 4.2f';
    OP { j }.Tolmode   = '<';
    OP { j }.Tol       = 1.25;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'microns';
    OP { j }.Comment   = '';                      % Will be overwritten by "calComnt" function.
    OP { j }.Comeditbl = false;                   % Comment field can be edited by GUI.
    OP { j }.PV        = 'OTRS:IN20:571:EMITN_X';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO155';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO156';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = 'dateComment';

    j                         = j + 1;
    OPctrl.ID.OTR2_P_EMITN_Y  = j;

    OP { j }.Parameter = 'Proj. Norm. y emittance @OTR2';
    OP { j }.ParamCode = 'OTR2_P_EMITN_Y';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO494';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 1.20;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 4.2f';
    OP { j }.Tolmode   = '<';
    OP { j }.Tol       = 1.25;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'microns';
    OP { j }.Comment   = '';                      % Will be overwritten by "calComnt" function.
    OP { j }.Comeditbl = false;                   % Comment field can be edited by GUI.
    OP { j }.PV        = 'OTRS:IN20:571:EMITN_Y';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO157';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO158';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = 'dateComment';

    j                         = j + 1;
    OPctrl.ID.WS12_P_EMITN_X  = j;

    OP { j }.Parameter = 'Proj. Norm. x emittance @WS12';
    OP { j }.ParamCode = 'WS12_P_EMITN_X';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO495';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 1.20;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 4.2f';
    OP { j }.Tolmode   = '<';
    OP { j }.Tol       = 1.25;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'microns';
    OP { j }.Comment   = '';                      % Will be overwritten by "calComnt" function.
    OP { j }.Comeditbl = false;                   % Comment field can be edited by GUI.
    OP { j }.PV        = 'WIRE:LI21:293:EMITN_X';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO159';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO160';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = 'dateComment';

    j                         = j + 1;
    OPctrl.ID.WS12_P_EMITN_Y  = j;

    OP { j }.Parameter = 'Proj. Norm. y emittance @WS12';
    OP { j }.ParamCode = 'WS12_P_EMITN_Y';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO496';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 1.20;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 4.2f';
    OP { j }.Tolmode   = '<';
    OP { j }.Tol       = 1.25;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'microns';
    OP { j }.Comment   = '';                      % Will be overwritten by "calComnt" function.
    OP { j }.Comeditbl = false;                   % Comment field can be edited by GUI.
    OP { j }.PV        = 'WIRE:LI21:293:EMITN_Y';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO161';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO162';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = 'dateComment';

    j                         = j + 1;
    OPctrl.ID.LI28_P_EMITN_X  = j;

    OP { j }.Parameter = 'Proj. Norm. x emit*Bmag@LI28';
    OP { j }.ParamCode = 'LI28_P_EMITN_X';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO497';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 1.50;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 4.2f';
    OP { j }.Tolmode   = '<';
    OP { j }.Tol       = 2.00;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'microns';
    OP { j }.Comment   = '';                      % Will be overwritten by "calComnt" function.
    OP { j }.Comeditbl = false;                   % Comment field can be edited by GUI.
    OP { j }.PV        = 'WIRE:LI28:144:EMITN_X';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO163';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO164';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'getBmagEmittanceActual';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = 'dateComment';

    j                         = j + 1;
    OPctrl.ID.LI28_P_EMITN_Y  = j;

    OP { j }.Parameter = 'Proj. Norm. y emit*Bmag@LI28';
    OP { j }.ParamCode = 'LI28_P_EMITN_Y';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO498';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 1.50;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 4.2f';
    OP { j }.Tolmode   = '<';
    OP { j }.Tol       = 2.0;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'µm';
    OP { j }.Comment   = '';                      % Will be overwritten by "calComnt" function.
    OP { j }.Comeditbl = false;                   % Comment field can be edited by GUI.
    OP { j }.PV        = 'WIRE:LI28:144:EMITN_Y';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO165';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO166';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'getBmagEmittanceActual';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = 'dateComment';

    j                         = j + 1;
    OPctrl.ID.L3Phase         = j;

    OP { j }.Parameter = 'L3 phase (25-1 to 30-8)';
    OP { j }.ParamCode = 'L3Phase';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO499';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 0.0;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%3.1f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 5.0;
    OP { j }.Tfmt      = '%s%3.1f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'degS';
    OP { j }.Comment   = 'No reason to run off crest';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'ACCL:LI25:1:PDES';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO121';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO146';
    OP { j }.PREC      = 1;
    OP { j }.calActual = 'lcaGet';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.FinalEnergy     = j;

    beamDestPV = 'BEND:DMPH:400:BDES';	 

    OP { j }.Parameter = 'Final electron energy';
    OP { j }.ParamCode = 'FinalEnergy';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO500';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 13.64;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%5.2f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0.10;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'GeV';
    OP { j }.Comment   = 'based on BYD1';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = beamDestPV;
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO122';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO147';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'getFinalEnergy_Actual';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.BC2_BLEN        = j;

    OP { j }.Parameter = 'rms Bunch Length';
    OP { j }.ParamCode = 'BC2_BLEN';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO196';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 15;
    OP { j }.Tar_editbl = false;                  % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%2.1f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 10;
    OP { j }.Tfmt      = '%s%4.1f';
    OP { j }.Toleditbl = false;                   % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'µm';
    OP { j }.Comment   = 'Using peak current and charge.';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = OP { OPctrl.ID.BC2_IPK }.PV;
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO190';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO191';
    OP { j }.PREC      = 1;
    OP { j }.calActual = 'getBunchLength_Actual';
    OP { j }.calTarget = 'getBunchLength_Target';
    OP { j }.calTol    = 'getBunchLength_Tol';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.FEL_Charge      = j;

    OP { j }.Parameter = 'FEL charge';
    OP { j }.ParamCode = 'FELCharge';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = '';                      % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = 0.25;
    OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%4.2f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0.01;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'nC';
    OP { j }.Comment   = 'Used to estimate FEL output';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = 'BPMS:BSYH:465:TMIT'; %'BPMS:UND1:190:TMIT';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = '';
    OP { j }.OPT_PV    = '';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'conv2nC_Actual';
    OP { j }.calTarget = '';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.FEL_P_EMITN     = j;

    OP { j }.Parameter = 'Proj. Norm. FEL emittance';  % Parameter only for archival purposes
    OP { j }.ParamCode = 'FEL_P_EMITN';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO197';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = .5;
    OP { j }.Tar_editbl = false;                  % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '% 4.2f';
    OP { j }.Tolmode   = '<';
    OP { j }.Tol       = 2.0;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'µm';
    OP { j }.Comment   = '';                      % Will be overwritten by "calComnt" function.
    OP { j }.Comeditbl = false;                   % Comment field can be edited by GUI.
    OP { j }.PV        = 'WIRE:LI28:144:EMITN_X';
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO725';
    OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO726';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'getFEL_Emittance_Actual';
    OP { j }.calTarget = 'getFEL_Emittance_Target';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = 'dateComment';

    j                         = j + 1;
    OPctrl.ID.FEL_LAMBDA_R    = j;

    OP { j }.Parameter = 'estimated FEL Wavelength';
    OP { j }.ParamCode = 'FEL_LAMBDA_R';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO192';   % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = NaN;
    OP { j }.Tar_editbl = false;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%4.2f';
    OP { j }.Tolmode   = '±';
    OP { j }.Tol       = 0.01;
    OP { j }.Tfmt      = '%s%4.2f';
    OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'nm';
    OP { j }.Comment   = 'Based on Final electron energy';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = OP { OPctrl.ID.FinalEnergy }.PV;
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = ''; %SIOC:SYS0:ML00:AO190';
    OP { j }.OPT_PV    = ''; %SIOC:SYS0:ML00:AO191';
    OP { j }.PREC      = 2;
    OP { j }.calActual = 'get_lambda_r_Actual';
    OP { j }.calTarget = 'get_lambda_r_Target';
    OP { j }.calTol    = '';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.FEL_L_SAT_C     = j;

    OP { j }.Parameter = 'estimated FEL L_sat';
    OP { j }.ParamCode = 'FEL_L_SAT_C';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO193';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = NaN;
    OP { j }.Tar_editbl = false;                  % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%3.0f';
    OP { j }.Tolmode   = '<';
    OP { j }.Tol       = NaN;
    OP { j }.Tfmt      = '%s%3.0f';
    OP { j }.Toleditbl = false;                    % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'm';
    OP { j }.Comment   = 'Based on bunch length signal';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = OP { OPctrl.ID.FinalEnergy }.PV;
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = ''; %SIOC:SYS0:ML00:AO190';
    OP { j }.OPT_PV    = ''; %SIOC:SYS0:ML00:AO191';
    OP { j }.PREC      = 0;
    OP { j }.calActual = 'get_L_sat_Actual';
    OP { j }.calTarget = 'get_L_sat_Target';
    OP { j }.calTol    = 'get_L_sat_Tolerance';
    OP { j }.calComnt  = '';

    j                         = j + 1;
    OPctrl.ID.FEL_P_OUT_C     = j;

    OP { j }.Parameter = 'estimated FEL P_out';
    OP { j }.ParamCode = 'FEL_P_OUT_C';
    OP { j }.Actual    = NaN;                     % Actual value
    OP { j }.TS        = NaN;                     % Actual timestamp
    OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO194';  % If set, Actuals will be recorded to specified PV.    
    OP { j }.Target    = NaN;
    OP { j }.Tar_editbl = false;                  % If false, Target will not be settable by GUI but calculated by ".calTarget"
    OP { j }.Vfmt      = '%3.1f';
    OP { j }.Tolmode   = '>';
    OP { j }.Tol       = NaN;
    OP { j }.Tfmt      = '%s%3.1f';
    OP { j }.Toleditbl  = false;                   % Tolerance field can be edited by GUI.    
    OP { j }.Unit      = 'GW';
    OP { j }.Comment   = 'Based on bunch length signal';
    OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
    OP { j }.PV        = OP { OPctrl.ID.FinalEnergy }.PV;
    OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
    OP { j }.OPV_PV    = ''; %SIOC:SYS0:ML00:AO190';
    OP { j }.OPT_PV    = ''; %SIOC:SYS0:ML00:AO191';
    OP { j }.PREC      = 1;
    OP { j }.calActual = 'get_P_out_Actual';
    OP { j }.calTarget = 'get_P_out_Target';
    OP { j }.calTol    = 'get_P_out_Tolerance';
    OP { j }.calComnt  = '';
    
        j                         = j + 1;	 
     OPctrl.ID.LTUH_P_EMITN_X  = j;	 
 	 
     OP { j }.Parameter = 'Proj. Norm. x emit*Bmag@LTUH';	 
     OP { j }.ParamCode = 'LTUH_P_EMITN_X';	 
     OP { j }.Actual    = NaN;                     % Actual value	 
     OP { j }.TS        = NaN;                     % Actual timestamp	 
     OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO505';  % If set, Actuals will be recorded to specified PV.    	 
     OP { j }.Target    = 1.50;	 
     OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"	 
     OP { j }.Vfmt      = '% 4.2f';	 
     OP { j }.Tolmode   = '<';	 
     OP { j }.Tol       = 2.00;	 
     OP { j }.Tfmt      = '%s%4.2f';	 
     OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    	 
     OP { j }.Unit      = 'µm';	 
     OP { j }.Comment   = '';                      % Will be overwritten by "calComnt" function.	 
     OP { j }.Comeditbl = false;                   % Comment field can be edited by GUI.	 
     OP { j }.PV        = 'WIRE:LTUH:735:EMITN_X';	 
     OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.	 
     OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO507';	 
     OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO508';	 
     OP { j }.PREC      = 2;	 
     OP { j }.calActual = 'getBmagEmittanceActual';	 
     OP { j }.calTarget = '';	 
     OP { j }.calTol    = '';	 
     OP { j }.calComnt  = 'dateComment';	 
 	 
     j                         = j + 1;	 
     OPctrl.ID.LTUH_P_EMITN_Y  = j;	 
 	 
     OP { j }.Parameter = 'Proj. Norm. y emit*Bmag@LTUH';	 
     OP { j }.ParamCode = 'LTUH_P_EMITN_Y';	 
     OP { j }.Actual    = NaN;                     % Actual value	 
     OP { j }.TS        = NaN;                     % Actual timestamp	 
     OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO506';  % If set, Actuals will be recorded to specified PV.    	 
     OP { j }.Target    = 1.50;	 
     OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"	 
     OP { j }.Vfmt      = '% 4.2f';	 
     OP { j }.Tolmode   = '<';	 
     OP { j }.Tol       = 2.0;	 
     OP { j }.Tfmt      = '%s%4.2f';	 
     OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    	 
     OP { j }.Unit      = 'µm';	 
     OP { j }.Comment   = '';                      % Will be overwritten by "calComnt" function.	 
     OP { j }.Comeditbl = false;                   % Comment field can be edited by GUI.	 
     OP { j }.PV        = 'WIRE:LTUH:735:EMITN_Y';	 
     OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.	 
     OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO509';	 
     OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO510';	 
     OP { j }.PREC      = 2;	 
     OP { j }.calActual = 'getBmagEmittanceActual';	 
     OP { j }.calTarget = '';	 
     OP { j }.calTol    = '';	 
     OP { j }.calComnt  = 'dateComment';	 
 	 
     j                         = j + 1;	 
     OPctrl.ID.DL1_E0          = j;	 
 	 
     OP { j }.Parameter = 'DL1 E0';	 
     OP { j }.ParamCode = 'DL1_E0';	 
     OP { j }.Actual    = NaN;                     % Actual value	 
     OP { j }.TS        = NaN;                     % Actual timestamp	 
     OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO513';  % If set, Actuals will be recorded to specified PV.    	 
     OP { j }.Target    = 135;	 
     OP { j }.Tar_editbl = true;                   % If false, Target will not be settable by GUI but calculated by ".calTarget"	 
     OP { j }.Vfmt      = '%3.0f';	 
     OP { j }.Tolmode   = '±';	 
     OP { j }.Tol       =    2;	 
     OP { j }.Tfmt      = '%s%1.0f';	 
     OP { j }.Toleditbl = true;                    % Tolerance field can be edited by GUI.    	 
     OP { j }.Unit      = 'MeV';	 
     OP { j }.Comment   = 'Actual calculated from BX01 BACT';	 
     OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.	 
     OP { j }.PV        = 'BEND:IN20:661:BACT';	 
     OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.	 
     OP { j }.OPV_PV    = 'SIOC:SYS0:ML00:AO514';	 
     OP { j }.OPT_PV    = 'SIOC:SYS0:ML00:AO515';	 
     OP { j }.PREC      = 0;	 
     OP { j }.calActual = 'getDL1Energy_Actual';	 
     OP { j }.calTarget = '';	 
     OP { j }.calTol    = '';	 
     OP { j }.calComnt  = '';
     
     j                         = j + 1;
     OPctrl.ID.FEL_PULSE_LEN_FS     = j;

     OP { j }.Parameter = 'estimated FEL Pulse Duration (FWHM)';
     OP { j }.ParamCode = 'FEL_PULSE_LEN_FS';
     OP { j }.Actual    = NaN;                     % Actual value
     OP { j }.TS        = NaN;                     % Actual timestamp
     OP { j }.savActPV  = 'SIOC:SYS0:ML00:AO820';  % If set, Actuals will be recorded to specified PV.    
     OP { j }.Target    = NaN;
     OP { j }.Tar_editbl = false;                  % If false, Target will not be settable by GUI but calculated by ".calTarget"
     OP { j }.Vfmt      = '%3.1f';
     OP { j }.Tolmode   = '>';
     OP { j }.Tol       = NaN;
     OP { j }.Tfmt      = '%s%3.1f';
     OP { j }.Toleditbl  = false;                   % Tolerance field can be edited by GUI.    
     OP { j }.Unit      = 'fs';
     OP { j }.Comment   = 'Based on bunch length and charge signals';
     OP { j }.Comeditbl = true;                    % Comment field can be edited by GUI.
     %OP { j }.PV        = 'BPMS:UND1:190:TMIT';
     OP { j }.PV        = 'SIOC:SYS0:ML00:CALC252'; % Charge in pC at BSYH:465
     OP { j }.INI_SIOC  = false;                   % Inititalize SIOC fields once.
     OP { j }.OPV_PV    = ''; %SIOC:SYS0:ML00:AO190';
     OP { j }.OPT_PV    = ''; %SIOC:SYS0:ML00:AO191';
     OP { j }.PREC      = 1;
     OP { j }.calActual = 'get_Pulse_Len_Actual';
     OP { j }.calTarget = ''; %'get_Pulse_Len_Target';
     OP { j }.calTol    = ''; %'get_Pulse_Len_Tolerance';
     OP { j }.calComnt  = '';
end

n = length ( OP );

if ( n < 1 )
    newOP = OP;
    return;
end

if ( initialize )
    
    % The following statement determines if and at which position
    % a parameter will be displayed.
    
    OPctrl.order = [                            ...
                     OPctrl.ID.BeamRate,        ...
                     OPctrl.ID.LaserPlsLen,     ...
                     OPctrl.ID.LasrIrisDia,     ...
                     OPctrl.ID.BunchCharge,     ...
                     OPctrl.ID.GunVoltage,      ...
                     OPctrl.ID.LaserPhase,      ...
                     OPctrl.ID.L0aVoltage,      ...
                     OPctrl.ID.L0aPhase,        ...
                     OPctrl.ID.L0bVoltage,      ...
                     OPctrl.ID.L0bPhase,        ...
                     OPctrl.ID.L1SVoltage,      ...
                     OPctrl.ID.L1SPhase,        ...
                     OPctrl.ID.L1XVoltage,      ...
                     OPctrl.ID.L1XPhase,        ...
                     OPctrl.ID.BC1offset,       ...
                     OPctrl.ID.BC1_E0,          ...
                     OPctrl.ID.BC1_R56,         ...
                     OPctrl.ID.BC1_IPK,         ...
                     OPctrl.ID.L2Phase,         ...
                     OPctrl.ID.BC2offset,       ...
                     OPctrl.ID.BC2_E0,          ...
                     OPctrl.ID.BC2_R56,         ...
                     OPctrl.ID.BC2_IPK,         ...
                     OPctrl.ID.BC1_InjPhase,    ...
                     OPctrl.ID.BC2_InjPhase,    ...
                     OPctrl.ID.BC1_2_InjPhase,  ...
                     OPctrl.ID.L3Phase,         ...
                     OPctrl.ID.FinalEnergy,     ...
                     OPctrl.ID.BC2_BLEN,        ...
                     OPctrl.ID.OTR2_P_EMITN_X,  ...
                     OPctrl.ID.OTR2_P_EMITN_Y,  ...
                     OPctrl.ID.WS12_P_EMITN_X,  ...
                     OPctrl.ID.WS12_P_EMITN_Y,  ...
                     OPctrl.ID.LI28_P_EMITN_X,  ...
                     OPctrl.ID.LI28_P_EMITN_Y,  ...
                     OPctrl.ID.LTUH_P_EMITN_X,  ...	 
                     OPctrl.ID.LTUH_P_EMITN_Y,  ...	 
                     OPctrl.ID.FEL_LAMBDA_R,    ...
                     OPctrl.ID.FEL_L_SAT_C,     ...
                     OPctrl.ID.FEL_P_OUT_C      ...
                   ];

% LIST OF NEW SIGNALS TO BE ADDED.
%                     OPctrl.ID.GunPhase,        ...
% ---- END OF LIST OF NEW SIGNALS ----

    OPctrl.items = length ( OPctrl.order );

    for j = 1 : n
        OP { j }.aquired            = false;    

        OP { j }.Parameter_modified = OP { j }.INI_SIOC;
        OP { j }.Target_modified    = OP { j }.INI_SIOC;
        OP { j }.Tol_modified       = OP { j }.INI_SIOC;
        OP { j }.Unit_modified      = OP { j }.INI_SIOC;
        OP { j }.Comment_modified   = OP { j }.INI_SIOC;
        OP { j }.PREC_modified      = OP { j }.INI_SIOC;
    end
end

dateString = sprintf ( '%s', datestr ( now,'yyyy-mm-dd HH:MM:SS' ) );

if ( initialize )
    if ( useSIOCvalues )        % Initialize fields from SIOCs
        for j = 1 : n
            if ( ~OP { j }.INI_SIOC )              
                PV = OP { j }.OPV_PV;
                
                if ( OP { j }.Tar_editbl && any ( PV ) )                      
                    try
                        OP { j }.Target    = lcaGet ( PV );
                    catch
                        fprintf ( '%s: %s problem fetching Target PV "%s" from SIOC for parameter "%s\n', ...
                            dateString, mfilename, PV, OP { j }.Parameter );
                    end
                end
            
                PV = OP { j }.OPT_PV;
                
                if ( OP { j }.Toleditbl && any ( PV ) )
                    try
                        OP { j }.Tol       = lcaGet ( PV );
                    catch
                        fprintf ( '%s: %s problem fetching Tolerance PV "%s" from SIOC for parameter "%s\n', ...
                            dateString, mfilename, PV, OP { j }.Parameter );
                    end        
                end
                
                PV = regexprep ( OP { j }.OPV_PV, ':AO', ':SO0' );
                
                if ( OP { j }.Comeditbl && any ( PV ) )            
                    try
                        OP { j }.Comment   = char ( lcaGet ( PV ) );
                    catch
                        fprintf ( '%s: %s problem fetching Comment PV "%s" from SIOC for parameter "%s\n', ...
                            dateString, mfilename, PV, OP { j }.Parameter );
                    end        
                end
            end
        end     
    end
        
    if ( option > 1 )
        newOP = OP;
        return;
    end
end

% Remove name prefix that are used in the SIOC parameter name

if ( updateParameter )
    for j = 1 : n
        OP { j }.Parameter = regexprep ( OP { j }.Parameter, SIOC_ID.String, '' );
%        fprintf ( 'got %s\n', OP { j }.Parameter )
    end
end

% Calculate Target values for dependent parameters.

for j = 1 : n
    if ( any ( OP { j }.calTarget ) )
        success = true;

        try
            TargetCallback  = str2func       ( OP { j }.calTarget );
            Target          = TargetCallback ( OP { j }.PV );
        catch
            OP { j }.Target = NaN;
            success         = false;
        end
    
        if ( success )
            if ( OP { j }.Target ~=  Target )
                OP { j }.Target_modified  = true;
                OP { j }.Target           = Target;
            end     
        else
            fprintf ( '%s: %s failed to get Target PV %s (%2.2d) from routine.\n', ...
                dateString, mfilename, OP { j }.PV, j );
        end
    end
end

% Take a new reading of the Actual values.

for j = 1 : n
    if ( any ( OP { j }.PV ) && any ( OP { j }.calActual ) )
        success = true;
%        fprintf ( 'Trying to get PV from CA...\n' );
  
        try
            ActualCallback = str2func ( OP { j }.calActual ); 
            [ a, t ]       = ActualCallback ( OP { j }.PV );
        catch
            success          = false;
        end

        if ( isnan ( a ) )
            success = false;
        end
    
        if ( success )
%            fprintf ( 'Succeeded.\n' );
            OP { j }.aquired = true;
            OP { j }.Actual  = a;
            OP { j }.TS      = datestr ( lca2matlabTime ( t ) );
             
        else
            fprintf ( '%s: %s failed to get PV %s (%2.2d) from %s.\n', ...
                dateString, mfilename, OP { j }.PV, j, OP { j }.calActual );
            OP { j }.aquired = false;
            OP { j }.Actual  = NaN;
            OP { j }.TS      = NaN;
        end
    end
end

% Calculate Tolerance fields.

for j = 1 : n
    if ( any ( OP { j }.calTol ) )
        try
            ToleranceCallback  = str2func ( OP { j }.calTol );
            OP { j }.Tol = ToleranceCallback ( j );
        catch
            OP { j }.Tol = ' ';
        end
    end
end


% Calculate Comment fields.

for j = 1 : n
    if ( any ( OP { j }.calComnt ) )
        try
            CommentCallback  = str2func ( OP { j }.calComnt );
            OP { j }.Comment = char ( CommentCallback ( j ) );
        catch
            OP { j }.Comment = ' ';
        end
    end
end

if ( useSIOCvalues )
    % Use soft IOCs to store the target values
    %  (and record some of the Actuals )
    
    for j = 1 : n        
        if ( any ( OP { j }.OPV_PV ) && ~isnan ( OP { j }.Target )  )
            Parameter_modified = OP { j }.Parameter_modified;
            Target_modified    = OP { j }.Target_modified;
            Unit_modified      = OP { j }.Unit_modified;
            Tol_modified       = OP { j }.Tol_modified;
            PREC_modified      = OP { j }.PREC_modified;
            Comment_modified   = OP { j }.Comment_modified;
  
            SIOC_V_DESC        = strcat ( SIOC_ID.String, OP { j }.Parameter ); 
            SIOC_T_DESC        = strcat ( 'TOL_', OP { j }.Parameter );         

            SIOC_V_DESC        = strrep ( SIOC_V_DESC, 'emittance', 'emit' );
            SIOC_V_DESC        = strrep ( SIOC_V_DESC, 'Proj. Norm.', 'Proj' );
            SIOC_T_DESC        = strrep ( SIOC_T_DESC, 'emittance', 'emit' );
            SIOC_T_DESC        = strrep ( SIOC_T_DESC, 'Proj. Norm.', 'Proj' );

            Parameter_V_PV     = strcat ( OP { j }.OPV_PV, '.DESC' );
            Parameter_T_PV     = strcat ( OP { j }.OPT_PV, '.DESC' );
            Target_V_PV        = OP { j }.OPV_PV;
            Unit_V_PV          = strcat ( OP { j }.OPV_PV, '.EGU' );
            Unit_T_PV          = strcat ( OP { j }.OPT_PV, '.EGU' );
            Tol_T_PV           = OP { j }.OPT_PV;
            PREC_V_PV          = strcat ( OP { j }.OPV_PV, '.PREC' );
            PREC_T_PV          = strcat ( OP { j }.OPT_PV, '.PREC' );
            Comment_V_PV       = regexprep ( OP { j }.OPV_PV, ':AO', ':SO0' );
            Comment_T_PV       = regexprep ( OP { j }.OPT_PV, ':AO', ':SO0' );        
            
            OP { j }.Parameter_modified = ~updateSIOC ( Parameter_V_PV, SIOC_V_DESC,        Parameter_modified, true  );
                                           updateSIOC ( Parameter_T_PV, SIOC_T_DESC,        Parameter_modified, false );
            OP { j }.Target_modified    = ~updateSIOC ( Target_V_PV,    OP { j }.Target,    Target_modified,    true, OP { j }.PREC );
            OP { j }.Unit_modified      = ~updateSIOC ( Unit_V_PV,      OP { j }.Unit,      Unit_modified,      true  );
                                           updateSIOC ( Unit_T_PV,      OP { j }.Unit,      Unit_modified,      false );
            OP { j }.Tol_modified       = ~updateSIOC ( Tol_T_PV,       OP { j }.Tol,       Tol_modified,       true  );
            OP { j }.PREC_modified      = ~updateSIOC ( PREC_V_PV,      OP { j }.PREC,      PREC_modified,      true  );
                                           updateSIOC ( PREC_T_PV,      OP { j }.PREC,      PREC_modified,      false );
            OP { j }.Comment_modified   = ~updateSIOC ( Comment_V_PV,   OP { j }.Comment,   Comment_modified,   true  );
                                           updateSIOC ( Comment_T_PV,   OP { j }.Comment,   Comment_modified,   false );
            PN = OP { j }.Parameter;
                                           
            OP { j }.Parameter = loadSIOC ( Parameter_V_PV, PN, OP { j }.Parameter, true,  updateParameter,     Parameter_modified, true );
            OP { j }.Target    = loadSIOC ( Target_V_PV,    PN, OP { j }.Target,    false, OP { j }.Tar_editbl, Target_modified,    true );
            OP { j }.Unit      = loadSIOC ( Unit_V_PV,      PN, OP { j }.Unit,      true,  true,                Unit_modified,      true );
            OP { j }.Tol       = loadSIOC ( Tol_T_PV,       PN, OP { j }.Tol,       false, OP { j }.Toleditbl,  Tol_modified,       true );
            OP { j }.PREC      = loadSIOC ( PREC_V_PV,      PN, OP { j }.PREC,      false, true,                PREC_modified,      true );
            OP { j }.Comment   = loadSIOC ( Comment_V_PV,   PN, OP { j }.Comment,   true,  OP { j }.Comeditbl,  Comment_modified,   true );
        end
         
        % Record Actuals to SIOC PV if requested (don't report success).

        if ( any ( OP { j }.savActPV ) )
            if ( ~isnan ( OP { j }.Actual ) )                
                updateSIOC ( OP { j }.savActPV,                              OP { j }.Actual,    true, false );
            else
                updateSIOC ( OP { j }.savActPV,                              0,                  true, false );
            end
            
            updateSIOC ( strcat    ( OP { j }.savActPV, '.DESC' ),       OP { j }.Parameter, true, false );
            updateSIOC ( strcat    ( OP { j }.savActPV, '.EGU'  ),       OP { j }.Unit,      true, false );
            updateSIOC ( strcat    ( OP { j }.savActPV, '.PREC' ),       OP { j }.PREC,      true, false );
            updateSIOC ( regexprep ( OP { j }.savActPV, ':AO', ':SO0' ), 'used by checkOP_gui',   true, false );
%            updateSIOC ( regexprep ( OP { j }.savActPV, ':AO', ':SO0' ), OP { j }.Comment,   true, false );
        end
    end
end

if ( verbose )
    % Produce terminal output.
    
    if ( formatForLogbook )
        fprintf ( '| Parameter                  |Actual | Target   |Tol. |Unit |Comment\n' );
    else
        fprintf ( ' Parameter                   Actual   Target    Tol.  Unit  Comment\n' );
    end

    for j    =  1 : OPctrl.items
        item = OPctrl.order ( j );
        
        if ( OP { item }.Tol == 0 )
            pm = '';
        else
            pm = OP { item }.Tolmode;
        end

        strV = util_stralign ( sprintf ( OP { item }.Vfmt,     OP { item }.Target ), 8, 'c' );
        strT = util_stralign ( sprintf ( OP { item }.Tfmt, pm, OP { item }.Tol   ),  6, 'c' );

        if ( OP { item }.aquired )
            strA = util_stralign ( sprintf ( OP { item }.Vfmt,     OP { item }.Actual), 8, 'c' );
        else
            strA = '????????';
        end

        if ( ~OP { item }.Tar_editbl )
            dep = '*';
        else
            dep = ' ';
        end
        
        if ( formatForLogbook )
            fmt = sprintf ( '|%s%%25.25s|%s|%s|%s|%%5.5s|%%35s\n', dep, strA, strV, strT );
        else
            fmt = sprintf ( '%s%%25.25s <%s> %s %s %%5.5s %%35s\n', dep, strA, strV, strT );
        end
    
        fprintf ( fmt, ...
            util_stralign ( OP { item }.Parameter, 25, 'l' ), ...
            util_stralign ( OP { item }.Unit,       5, 'l' ), ...
            util_stralign ( OP { item }.Comment,   35, 'l' ) );
    end
end

newOP = OP;

end


function success = updateSIOC ( PV, newValue, mod, successReport, varargin )

global OPctrl;

if ( nargin == 4 || nargin == 5 )
    success = true;
else
    success = false;
    return;
end

isString = false;
if strfind(PV,'.DESC') ; isString = true ; end
if strfind(PV,'.EGU') ;  isString = true ; end
if isString
    try
        oldValue = lcaGet ( PV );
    catch
        fprintf ( 'did not get PV .\n' );
        success = false;
        return;
    end
    if strcmp ( oldValue, newValue )
        return;
    end
end

if strfind(PV,'.PREC')
    try
        oldValue = lcaGet ( PV );
    catch
        fprintf ( 'did not get PV .\n' );
        success = false;
        return;
    end
    if isequal ( oldValue, newValue )
        return;
    end
end

if ( mod )
    if ( nargin == 5 )
        % Check if newValue changed significant from present PV value (oldValue).

        gotValue = true;
            
        try
            oldValue = lcaGet ( PV );
        catch
            gotValue = false;
        end
            
        if ( ~gotValue )
            fprintf ( 'did not get PV .\n' );
            success = false;
            return;
        end

        if ( precComp ( oldValue, newValue, varargin { 1 } ) == 0 )
            return;
        end
    end
    
    try
        lcaPut ( PV, newValue );
    catch
        success = false;
    end
    
    if ( ~success )
        fprintf ( 'Error using lcaPut command for PV "%s".\n', PV );
    else
%        if ( true )
        if ( successReport )
            fprintf ( '%s: Updated PV: "%s".\n', sprintf ( '%s', datestr ( now,'yyyy-mm-dd HH:MM:SS' ) ), PV );
        end
        
%        fprintf ( 'Setting OPctrl.saved = false, was %d\n', OPctrl.saved );                                                                                      
        OPctrl.saved = false;        
    end
end

end


function [ newValue, success ] = loadSIOC ( PV, name, oldValue, is_char, update, modified, successReport )

newValue = oldValue;
success  = false;

if ( update && ~modified && any ( PV ) )
    success = true;
    
	try
        data = lcaGet ( PV );
	catch
        success = false;
	end        
                
    if ( success )
        if ( is_char )
            newValue = char ( data );
            updated  = ~strcmp ( newValue, oldValue );
        else
            newValue = data;
            updated  = ( newValue ~= oldValue );
        end

        if ( successReport && updated)
            if ( is_char )
                fprintf ( '%s: Loaded "%s" [%s] %s -> %s\n', datestr ( now,'yyyy-mm-dd HH:MM:SS' ), name, PV, oldValue, newValue );
            else
                fprintf ( '%s: Loaded "%s" [%s] %f -> %f\n', datestr ( now,'yyyy-mm-dd HH:MM:SS' ), name, PV, oldValue, newValue );
            end
        end
    else
        fprintf ( '%s: Problem fetching PV "%s" from SIOC for "%s"\n', datestr ( now,'yyyy-mm-dd HH:MM:SS' ), PV, name );
    end
end

end


function c = precComp ( v1, v2, p )

c = round (  (v1 - v2 ) * 10^( p + 1 ) ) * 10^( -( p + 1 ) );

end

% Callback Functions for Actual and Target values.

function [ v, t ] = IrisAngle2Diameter_Actual ( PV )

%%Iris.angle = [  25.9,  56.0,  86.0, 116.0, 146.1, 176.1, 206.0, 236.0, 266.0, 296.0, 326.0, 256.0 ];
%%Iris.dia   = [   0.25,  0.5,   0.6,   0.7,   0.8,   0.9,   1.0,   1.2,   1.4,   1.6,   2.0,   0.0 ]; % last position is "LCLS"
%Iris.angle = [   9.6,  39.7,  69.8,  99.8, 129.8, 159.8, 189.8, 219.7, 249.7, 279.7, 309.7, 339.4 ];
%Iris.dia   = [   0.125, 0.25,  0.5,   0.6,   0.8,   1.0,   1.2,   1.4,   1.5,   1.6,   2.0,   0.0 ]; % last position is "LCLS"
%
%[ v, t ] = lcaGet ( PV );
%
%ix = find ( abs ( Iris.angle - v ) < 1 );
%
%if ( length ( ix ) == 1 && ix > 0 )
%    v    = Iris.dia ( ix ); 
%else
%    v = NaN;
%end

[ v, t ] = lcaGet ( PV );

v = sscanf ( v { 1 }, '%f' );

if ( isempty ( v ) )
    v = 0;
end

end


function [ v, t ] = conv2nC_Actual ( PV )

global PhysicsConsts;

[ v, t ]  = lcaGet ( PV );
v         = v * PhysicsConsts.echarge * 1e9; % nC

end


function v = calBC1offset_Target ( PV )

global OP;
global OPctrl;

R56_T             = OP { OPctrl.ID.BC1_R56 }.Target / 1000;
E0_T              = OP { OPctrl.ID.BC1_E0  }.Target / 1000;
%[ BDES1, xpos_1 ] = BC1_adjust ( R56_T, E0_T );
[ ~, xpos_1 ] = BC_adjust ( 'BC1', R56_T, E0_T );
v                 = xpos_1 * 1000;

end


function [ v, t ] = getBC1_R56_Actual ( PV )

global OP;
global OPctrl;
%global PhysicsConsts;

R56_T       = OP { OPctrl.ID.BC1_R56 }.Target / 1000;
E0_A        = OP { OPctrl.ID.BC1_E0  }.Actual / 1000;

[ BACT, t ] = lcaGet ( PV );
%BACT        = BACT / 10; % Tm

%[ BDES, xpos, dphi_BC, theta, eta, R560, Lm, dL ] = BC1_adjust ( R56_T, E0_A );
[ ~, ~, ~, ~, ~, R56] = BC_adjust ( 'BC1', R56_T, E0_A, BACT );

%t0          = asin ( PhysicsConsts.c * BACT / ( E0_A * 1e9 ) );
%gamsqr      = ( E0_A * 1e9 / PhysicsConsts.mc2_e )^2;
%R56         = 2 * gamsqr * sec ( t0 ) * ( 2 * Lm * ( t0 * cot ( t0 ) - 1 ) - dL * tan ( t0 )^2 ) / ( gamsqr - 1 );
v           = R56 * -1000;

end


function [ v, t ] = getBC1_E0_Actual ( PV )

% Calculate Actual

global OP;
global OPctrl;
global PhysicsConsts;

v       = NaN;
t       = NaN;

R56_T   = OP { OPctrl.ID.BC1_R56   }.Target / 1000;
E0_T    = OP { OPctrl.ID.BC1_E0    }.Target / 1000;

%[ BDES, xpos, dphi_BC, theta, eta, R560, Lm, dL ] = BC1_adjust ( R56_T, E0_T );
[ ~, ~, ~, ~, ~, ~, Lm, dL ] = BC_adjust ( 'BC1', R56_T, E0_T );

L = Lm + dL;

if ( L ~= 0 )
%    XPOS  = OP { OPctrl.ID.BC1offset }.Target / 1000;
    XPOS  = OP { OPctrl.ID.BC1offset }.Actual / 1000;
    theta = atan ( XPOS / L );
    
    if ( theta ~= 0 )
        [ BACT, t ] = lcaGet ( PV );
        E0          = BACT / sin ( theta ) * 1e-10 * PhysicsConsts.c;

        if ( E0 >= 0.010 && E0 <= 0.600)
            v = E0 * 1000; % MeV
        end
    end
end

end


function v = calBC1_InjectorPhase_Target ( PV )

global OP;
global OPctrl;

R56_T                   = OP { OPctrl.ID.BC1_R56 }.Target / 1000;
E0_T                    = OP { OPctrl.ID.BC1_E0  }.Target / 1000;
%[ BDES, xpos, dphi_BC ] = BC1_adjust ( R56_T, E0_T );
[ ~, ~, dphi_BC ]       = BC_adjust ( 'BC1', R56_T, E0_T );
v                       = - dphi_BC;

end


function [ v, t ] = calBC1_InjectorPhase_Actual ( PV )

% Calculate Actual

global OP;
global OPctrl;

[ R56_A, t ]            = getBC1_R56_Actual ( PV );
R56_A                   = R56_A / 1000;
E0_A                    = OP { OPctrl.ID.BC1_E0  }.Actual / 1000;
%[ BDES, xpos, dphi_BC ] = BC1_adjust ( R56_A, E0_A );
[ ~, ~, dphi_BC ]       = BC_adjust ( 'BC1', R56_A, E0_A );
v                       = - dphi_BC;

end


function v = calBC2offset_Target ( PV )

global OP;
global OPctrl;

R56_T              = OP { OPctrl.ID.BC2_R56 }.Target / 1000;
BC2_E0_T           = OP { OPctrl.ID.BC2_E0  }.Target;
%[ BDES_2, xpos_2 ] = BC2_adjust ( R56_T, BC2_E0_T );
[ ~,      xpos_2 ] = BC_adjust ( 'BC2', R56_T, BC2_E0_T );
v                  = xpos_2 * 1000;

end


function [ v, t ] = getBC2_R56_Actual ( PV )

global OP;
global OPctrl;
%global PhysicsConsts;

R56_T       = OP { OPctrl.ID.BC2_R56 }.Target / 1000;
BC2_E0_A    = OP { OPctrl.ID.BC2_E0  }.Actual;

[ BACT, t ] = lcaGet ( PV );
%BACT        = BACT / 10; % Tm

%[ BDES, xpos, dphi_BC, theta, eta, R560, Lm, dL ] = BC2_adjust ( R56_T, BC2_E0_A );
[ ~, ~, ~, ~, ~, R56] = BC_adjust ( 'BC2', R56_T, BC2_E0_A, BACT );


%t0          = asin ( PhysicsConsts.c * BACT / ( BC2_E0_A * 1e9 ) );
%gamsqr      = ( BC2_E0_A * 1e9 / PhysicsConsts.mc2_e )^2;
%R56         = 2 * gamsqr * sec ( t0 ) * ( 2 * Lm * ( t0 * cot ( t0 ) - 1 ) - dL * tan ( t0 )^2 ) / ( gamsqr - 1 );
v           = R56 * -1000;

end


function [ v, t ] = getBC2_EO_Actual ( PV )

% Calculate Actual

global OP;
global OPctrl;
global PhysicsConsts;

v       = NaN;
t       = NaN;

R56_T   = OP { OPctrl.ID.BC2_R56   }.Target / 1000;
E0_T    = OP { OPctrl.ID.BC2_E0    }.Target;

%[ BDES, xpos, dphi_BC, theta, eta, R560, Lm, dL ] = BC2_adjust ( R56_T, E0_T );
[ ~, ~, ~, ~, ~, ~, Lm, dL ] = BC_adjust ( 'BC2', R56_T, E0_T );

L = Lm + dL;

if ( L ~= 0 )
%    XPOS  = OP { OPctrl.ID.BC2offset }.Target / 1000;
    XPOS  = OP { OPctrl.ID.BC2offset }.Actual / 1000;
    theta = atan ( XPOS / L );
    
    if ( theta ~= 0 )
        [ BACT, t ] = lcaGet ( PV );
        E0          = BACT / sin ( theta ) * 1e-10 * PhysicsConsts.c;
        
        if ( E0 >= 0.1 && E0 <= 8)
            v = E0;
        end
    end
end

end


function v = calBC2_InjectorPhase_Target ( PV )

global OP;
global OPctrl;

R56_T                   = OP { OPctrl.ID.BC2_R56 }.Target / 1000;
E0_T                    = OP { OPctrl.ID.BC2_E0  }.Target;
%[ BDES, xpos, dphi_BC ] = BC2_adjust ( R56_T, E0_T );
[ ~, ~, dphi_BC ]       = BC_adjust ( 'BC2', R56_T, E0_T );
v                       = - dphi_BC;

end


function [ v, t ] = calBC2_InjectorPhase_Actual ( PV )

% Calculate Actual

global OP;
global OPctrl;

[ R56_A, t ]            = getBC2_R56_Actual ( PV );
R56_A                   = R56_A / 1000;
E0_A                    = OP { OPctrl.ID.BC2_E0  }.Actual;
%[ BDES, xpos, dphi_BC ] = BC2_adjust ( R56_A, E0_A );
[ ~, ~, dphi_BC ]       = BC_adjust ( 'BC2', R56_A, E0_A );
v                       = - dphi_BC;

end


function v = calBC1_BC2_InjectorPhase_Target ( PV )

global OP;
global OPctrl;

v = OP { OPctrl.ID.BC1_InjPhase }.Target + OP { OPctrl.ID.BC2_InjPhase }.Target;

end


function [ v, t ] = getFinalEnergy_Actual ( PV )

[ v, t ]= lcaGet ( PV ); 


end

function [ v, t ] = getDL1Energy_Actual ( PV )	 
 	 
 [ v, t ]= lcaGet ( PV ); 	 
 v = v*1000;                     % MeV	 
 end

function c = dateComment ( j )

global OP;

c = sprintf ( 'Aquired on %s', OP { j }.TS );

p = strfind ( OP { j }.PV, 'EMITN' );

if ( any ( p ) )
    success = true;

    methodPV = strcat ( OP { j }.PV ( 1 : p - 1 ), 'FIT_METHOD' );

    try
       fitMethod = char ( lcaGet ( methodPV ) );
    catch
        success = false;
    end
    
    if ( success )
        n = length ( fitMethod );
        fitMethod = strrep ( fitMethod, 'ssyme', 'symme' );
        c = sprintf ( '%s (%s)', OP { j }.TS, fitMethod ( 1 : min ( 5, n ) ) );
        
    else
        fprintf ('Failed to get method.\n' );
    end    
end

%c = 'From most recent emittance scan';

end

function [ v, t ] = calBC2_IPK_Actual ( PV )

% Calculate Actual

%global OPctrl;

v          = NaN;

[ IPK, t ] = lcaGet ( PV );                               % A
IPK        = IPK ( end - 35 : end );
indx       = find ( IPK == 0 );
L          = length ( indx );
if ( L >=1 && L <=3)
   IPK(indx(end-L+1:end)) = [];  % Remove upto 3 zeros
end 

if ( isnan ( IPK )  )
    return
end

if ( min(IPK) <= 0 || max(IPK) > 1e5 )
%    v = 0;
    return
end

% if ( OPctrl.Ipklvl < OPctrl.bufSize )
%     OPctrl.Ipklvl                            = OPctrl.Ipklvl + 1;
% else
%     OPctrl.IpkBuf ( 1 : OPctrl.bufSize - 1 ) = OPctrl.IpkBuf ( 2 : OPctrl.bufSize );
% end
% 
% OPctrl.IpkBuf ( OPctrl.Ipklvl )   = IPK;


%v                                 = mean ( OPctrl.IpkBuf ( 1 : OPctrl.Ipklvl ) );
v                                  = mean (IPK);
end


function [ v, t ] = getBunchLength_Actual ( PV )

% Calculate Actual

global OP;
global OPctrl;
global PhysicsConsts;

v         = NaN;
t         = NaN;
[ v, t ]  = lcaGet ( PV );                                % To get timestamp in correct format

IPK        = OP { OPctrl.ID.BC2_IPK       }.Actual;       % A
Q          = OP { OPctrl.ID.BunchCharge   }.Actual;       % nC

if ( IPK == 0 )
    return
end

v          = Q * PhysicsConsts.c / ( 1000 * sqrt ( 12 ) * IPK );  % microns

end


function v = getBunchLength_Target ( PV )

% Calculate Target

global OP;
global OPctrl;
global PhysicsConsts;

IPK        = OP { OPctrl.ID.BC2_IPK       }.Target;       % A
Q          = OP { OPctrl.ID.BunchCharge   }.Target;       % nC

v          = Q * PhysicsConsts.c / ( 1000 * sqrt ( 12 ) * IPK );  % microns

end


function v = getBunchLength_Tol ( PV )

% Calculate Tolerance

global OP;
global OPctrl;

v          = OP { OPctrl.ID.BC2_BLEN      }.Target * 0.1;       % microns

end


function [ v, t ] = getBmagEmittanceActual ( epsPV )

% Calculate Actual

BmagPV = strrep ( epsPV, 'EMITN', 'BMAG' );

v         = NaN;
t         = NaN;

[ Bmag, t ] = lcaGet ( BmagPV );
[ eps,  t ] = lcaGet ( epsPV  );                               % microns

v = Bmag * eps;

end


function [ v,t ] = getFEL_Emittance_Actual ( PV )

% Calculate Actual

global OP;
global OPctrl;

v         = NaN;
t         = NaN;

[ v,  t ] = lcaGet ( PV  );                               % microns; for timestamp retreval, only

eps_x       = OP { OPctrl.ID.OTR2_P_EMITN_X }.Actual;
eps_y       = OP { OPctrl.ID.OTR2_P_EMITN_Y }.Actual;

v = sqrt ( eps_x * eps_y );

end


function v = getFEL_Emittance_Target ( PV )

% Calculate Actual

global OP;
global OPctrl;

v         = NaN;

eps_x       = OP { OPctrl.ID.OTR2_P_EMITN_X }.Actual;
eps_y       = OP { OPctrl.ID.OTR2_P_EMITN_Y }.Actual;

v = sqrt ( eps_x * eps_y );

end


function v = get_lambda_r_Target ( PV )

% Calculate Actual

global OP;
global OPctrl;
global PhysicsConsts;
global UndulatorConsts;
global FELp_Target;

Ipk         = OP { OPctrl.ID.BC2_IPK }.Target;
eps         = OP { OPctrl.ID.FEL_P_EMITN }.Target;
Energy      = OP { OPctrl.ID.FinalEnergy }.Target;
gamma       = Energy / PhysicsConsts.mc2_e;
B_L         = OP { OPctrl.ID.BC2_BLEN }.Target;
dgamma      = 2.8;

FELp_Target = util_LCLS_FEL_Performance_Estimate ( Energy, eps, Ipk, B_L, dgamma );

v           = UndulatorConsts.lambda_u * ( 1 + UndulatorConsts.K_nominal^2 / 2 ) / ( 2 * gamma^2 ) / 1e9;  % nm

end


function [ v, t ] = get_lambda_r_Actual ( PV )

% Calculate Actual

global OP;
global OPctrl;
global PhysicsConsts;
global UndulatorConsts;
global FELp_Actual;

v         = NaN;
t         = NaN;
[ E, t ]  = getFinalEnergy_Actual ( PV );


% gamma      = E / PhysicsConsts.mc2_e;
% 
% 
 Ipk         = OP { OPctrl.ID.BC2_IPK }.Actual;
 eps         = OP { OPctrl.ID.FEL_P_EMITN }.Actual;
 Energy      = E;
 B_L         = OP { OPctrl.ID.BC2_BLEN }.Actual;
 dgamma      = 2.8;
% 
FELp_Actual = util_LCLS_FEL_Performance_Estimate ( Energy, eps, Ipk, B_L, dgamma );
% 
% v           = UndulatorConsts.lambda_u * ( 1 + UndulatorConsts.K_nominal^2 / 2 ) / ( 2 * gamma^2 ) / 1e9;  % nm

% William Colocho: Use Welch energy number to calculate lambda
[E t] = lcaGetSmart('SIOC:SYS0:ML00:AO627');

v           = 1/E *  PhysicsConsts.h_bar*2*pi*PhysicsConsts.c  / PhysicsConsts.echarge * 1e9;

end


function [ v, t ] = get_L_sat_Actual ( PV )

% Calculate Actual

global OP;
global OPctrl;
global FELp_Actual;

v         = NaN;
t         = NaN;

[ E, t ]  = lcaGet ( PV ); 
v         = FELp_Actual.L_sat_c;
Q         = OP{ OPctrl.ID.FEL_Charge }.Target;

if ( Q < 0.005 )
    v = NaN;
end


end


function v = get_L_sat_Target ( PV )

% Calculate Target

global FELp_Target;

v = FELp_Target.L_sat_c;

end


function v = get_L_sat_Tolerance ( j )

% Calculate Tolerance

global FELp_Target;

v = FELp_Target.L_sat_c * 1.2;

end


function [ v, t ] = get_P_out_Actual ( PV )

% Calculate Actual

global OP;
global OPctrl;
global FELp_Actual;

v         = NaN;
t         = NaN;

[ E, t ]   = lcaGet ( PV ); 
v          = FELp_Actual.P_out_c * 1E-9;   % GW

Q          = OP { OPctrl.ID.FEL_Charge }.Actual;

if ( Q < 0.005 )
    v = 0;
end

end


function v = get_P_out_Target ( PV )

% Calculate Target

global OP;
global OPctrl;
global FELp_Target;

v = FELp_Target.P_out_c * 1E-9;   % GW
Q = OP { OPctrl.ID.FEL_Charge }.Target;

if ( Q < 0.005 )
    v = 0;
end

end


function v = get_P_out_Tolerance ( j )

% Calculate Tolerance

global FELp_Target;

v = FELp_Target.P_out_c * 1E-9 * 0.8;   % GW

end


function [ v, t ] = get_Pulse_Len_Actual ( PV )

% Calculate Actual
% William: use ltuQ in case we use BC1 collimation to cut horns.

global OP;
global OPctrl;

v         = NaN;
t         = NaN;
[ ltuQ, t ]  = lcaGet ( PV );   % To get timestamp in correct format


Ipk        = OP { OPctrl.ID.BC2_IPK }.Actual;             % A
Q          = OP { OPctrl.ID.BunchCharge   }.Actual;       % nC

if Ipk == 0, return, end


if ( Q < 0.005 )
    v = 0;
else
    v = 1e6 * ltuQ/1e3 / Ipk;
end



end


% function v = get_Pulse_Len_Target ( PV )
% 
% % Calculate Target
% 
% global OP;
% global OPctrl;
% global FELp_Target;
% 
% v = FELp_Target.P_out_c * 1E-9;   % GW
% Q = OP { OPctrl.ID.FEL_Charge }.Target;
% 
% if ( Q < 0.005 )
%     v = 0;
% end
% 
% end
% 
% 
% function v = get_Pulse_Len_Tolerance ( j )
% 
% % Calculate Tolerance
% 
% global FELp_Target;
% 
% v = FELp_Target.P_out_c * 1E-9 * 0.8;   % GW
% 
% end
% 





