  function FELp = util_LCLS_FEL_Performance_Estimate ( Energy, eps, Ipk, L_B, dgamma, varargin )
% util_LCLS_FEL_Performance_Estimate estimates FEL performance based on the Ming Xie's 3D theory.
%                                
%     INPUTS:   Energy:     Electron beam energy in GeV.
%               eps:        Effective beam emittance in microns: 
%                                  eps = sqrt ( Eps_x * eps_y)
%               Ipk:        Peak bunch current in A.
%               L_B:        Bunch Length (rms) in microns.
%               dgamma:     Gamma spread (absolute)
%                                  Dp / p = dgamma * gamma
%
%     OUTPUTS:  FELp:       FEL parameter structure.
%
%       Usage:
%       const  = util_UndulatorConstants
%       Energy = 13.64;
%       gamma  = Energy / const.mc2_e;
%       Brho   = Energy / const.c;
%       eps    = 1.2;
%       Ipk    = 3000;
%       dgamma = 2.8;
%       L_B    = 7;
%
%       Method A (no optional parameters):
%
%       FELp   = util_LCLS_FEL_Performance_Estimate ( Energy, eps, Ipk, L_B, dgamma )
%
%       Method B (optional parameters as name and value pairs):
%
%       FELp   = util_LCLS_FEL_Performance_Estimate ( Energy, eps, Ipk, L_B, dgamma, 'beta_ext', 30.0 )
%
%       Method C (optional parameters in Parms struct):
%
%       Parms.beta_ext = 30.0;
%
%       FELp   = util_LCLS_FEL_Performance_Estimate ( Energy, eps, Ipk, L_B, dgamma, Parms )
%       
%       If Method C is used, exactly 3 of the the four resonance parameters
%       must be specified: ( K_nominal, lambda_u, gamma, lambda_r )
%
%     LIST OF OPTIONAL PARAMETERS (including defaults):
%       'beta_ext'              30.0
%       'betax'                 33.15
%       'betay'                 27.15
%       'beta'                  'fixed'; (D) Use eta_ext as beta function
%                               'optimized'; Find the eta function that
%                               gives the shortest gain length.
%       'llinear'               true
%       'K_nominal'             util_UndulatorConstants.K_nominal (3.5)
%       'lambda_u'              util_UndulatorConstants.lambda_u  (0.03 m)
%       'gammma'                electron energy; This parameter will overwrite
%                               the first required parameter.
%       'lambda_r'              resonant value [m]
%       'taprPIncr'             0
%       'UndType'               'KHhybrid_Nd_Fe_B'
%                               'KHpure_Nd_Fe_B'
%                               'SC_Helical'
%       'gap'                   6.8; % gap height [m].
%       'useEnergy'             true
%       'PostSat'               false; % if true, use optimum post saturation taper
%       'longShape'            'Flat-Top'
%
% Function last edited Feb 24, 2010 by HDN

global PhysicsConsts;
global UndulatorConsts;

PhysicsConsts   = util_PhysicsConstants;
UndulatorConsts = util_UndulatorConstants;

nreqargin       = 5;
gotParms        = false;

Method          = 1;

% Include required parameters
clear FELp;

FELp.epsilon_n_descr = 'Effective beam emittance';
FELp.epsilon_n       = eps * 1e-6;
FELp.epsilon_n_egu   = 'm';

FELp.Ipk_descr       = 'Peak current';
FELp.Ipk             = Ipk;
FELp.Ipk_egu         = 'A';

FELp.L_B_descr       = 'rms bunch length';
FELp.L_B             = L_B * 1e-6;
FELp.L_B_egu         = 'm';

if ( FELp.L_B ~= 0 )
    FELp.Charge          = FELp.Ipk * FELp.L_B * sqrt ( 12 ) / PhysicsConsts.c;
else
    FELp.Charge          = 250e-12;
    FELp.L_B             = FELp.Charge * PhysicsConsts.c / ( FELp.Ipk * sqrt ( 12 ) );
end

FELp.dgamma_descr    = 'Energy spread (dgamma = dp/p * gamma)';
FELp.dgamma          = dgamma;
FELp.dgamma_egu      = '';

% Set defaults for optional parameters

FELp.betax_descr     = 'Average horizontal (quad) beta function along undulator';
FELp.betax           = 33.15 * Energy * 1e9 / PhysicsConsts.mc2_e / 26692.896;
FELp.betax_egu       = 'm';

FELp.betay_descr     = 'Average vertical (quad) beta function along undulator';
FELp.betay           = 27.15 * Energy * 1e9 / PhysicsConsts.mc2_e / 26692.896;
FELp.betay_egu       = 'm';

FELp.beta_ext_descr  = 'Average beta function from quadrupole lattice along undulator';
FELp.beta_ext        = sqrt ( FELp.betax * FELp.betay );
FELp.beta_ext_egu    = 'm';

FELp.beta_descr      = 'Input switch: specifying if beta_ext should be constant ("non optimized") or ("optimized")';
FELp.beta            = 'not optimized';
FELp.beta_egu        = '';

FELp.llinear_descr   = 'Undulator type (1: linear; 0: helical)';
FELp.llinear         = true;
FELp.llinear_egu     = '';

FELp.taprPIncr_descr = 'relative increase in FEL power due to after-saturation tapering';
FELp.taprPIncr       = 0.0;
FELp.taprPIncr_egu   = '';

FELp.UndType_descr   = 'Undulator magnet type';
FELp.UndType         = 'KHhybrid_Nd_Fe_B';
FELp.UndType_egu     = '';

FELp.gap_descr       = 'Undulator gap';
FELp.gap             = 0.0068;
FELp.gap_egu         = 'm';    

FELp.useEnergy_descr = 'Use or ignore required input parameter "Energy"';
FELp.useEnergy       = true;
FELp.useEnergy_egu   = '';

FELp.PostSat_descr   = 'If true, assume optimum Saturation Taper';
FELp.PostSat         = false;
FELp.PostSat_egu     = '';

FELp.longShape_descr = 'Longitunidnal bunch shape "Flat-Top"(D) or "Gaussian"';
FELp.longShape       = 'Flat-Top';
FELp.longShape_egu   = '';

% Parse and accept optional parameters.

if ( nargin == nreqargin + 1 )
    Parms = varargin { 1 };
    
    if ( ~isstruct ( Parms ) )
        error ( 'Argument #6 needs to be of type struct!' );
    end
    
    gotParms = true;
    Method   = 3;
elseif ( nargin > nreqargin + 1 )
    Method   = 2;
    n        = 0;
        
    while ( true )
        if ( nargin >= nreqargin + n + 2 )
            n1 = n + 1;
            n2 = n + 2;
            t1 = varargin { n1 };
            t2 = varargin { n2 };
            
            if ( ischar ( t1 ) )
                Parms.(t1) = t2;
                gotParms   = true;
            else
                error ( 'Optional parameter %d need to be a character string.', n1 );
            end
            
            n = n2;
        else
            if ( nargin == nreqargin + n + 1 )
                error ( 'Optional parameter %d ("%s") has no matching argument!', n + 1, varargin { n + 1 } );
            else
                break
            end
        end        
    end
    
end

% Include optional parameters

optionalParms = { 'beta_ext', 'betax', 'betay', 'beta', 'llinear', 'K_nominal', 'lambda_u', 'gamma', 'lambda_r', 'taprPIncr', 'UndType', 'gap', 'useEnergy', 'PostSat', 'longShape' };

K_nominal_given = false;
lambda_u_given  = false;
gamma_given     = false;
lambda_r_given  = false;

gap_given       = false;

if ( gotParms )
    if ( isfield ( Parms, 'beta_ext' ) )
        FELp.beta_ext = Parms.beta_ext;

        FELp.betax    = FELp.beta_ext;
        FELp.betay    = FELp.beta_ext;
        
        FELp.betaxy   = FELp.beta_ext;
        
%        fprintf ( 'A: FELp.beta_ext is %f\n', FELp.beta_ext );
    end

    if ( isfield ( Parms, 'gap' ) )
        gap_given = true;
    end
    
    for j = 2 : length ( optionalParms )
        field = optionalParms { j };
        
        if ( isfield ( Parms, field ) )
            FELp.( field )  = Parms.( field );

            if ( strcmp ( field, 'K_nominal' ) )
                K_nominal_given = true;
            elseif ( strcmp ( field, 'lambda_u' ) )
                lambda_u_given = true;
            elseif ( strcmp ( field, 'gamma' ) )
                gamma_given = true;
            elseif ( strcmp ( field, 'lambda_r' ) )
                lambda_r_given = true;
            end
        end
    end
end

if ( FELp.useEnergy )
    FELp.gamma       = Energy * 1e9 / PhysicsConsts.mc2_e;
    
    if ( gamma_given )
        fprintf ( 'Ignoring input parameter parameter.\n' );
    else
        gamma_given = true;
    end
end

FELp.gamma_descr     = 'Electron energy / energy mass';
FELp.gamma_egu       = '';

FELp.K_nominal_descr = 'Undulator parameter';
FELp.K_nominal_egu   = '';

FELp.lambda_u_descr  = 'Undulator period';
FELp.lambda_u_egu    = 'm';

FELp.lambda_r_descr  = 'Resonant radiation wavelength (Fundamental)';
FELp.lambda_r_egu    = 'm';

FELp.h_block_descr   = 'Height (perpendicular to wiggle plane) of PM blocks for pure PM devices.';  
FELp.h_block         = 0.060; 
FELp.h_block_egu     = 'm'; 

if ( gap_given )
    if ( lambda_u_given )
        if ( K_nominal_given )
            fprintf ( 'Ignoring gap information due to presence of K_nominal.\n' );
        else
            FELp.K_nominal  = f_Bu ( FELp ) * PhysicsConsts.c / ( PhysicsConsts.mc2_e * ( 2 * pi / FELp.lambda_u ) );
            K_nominal_given = true;
        end
    else
        fprintf ( 'Ignoring gap information due to absence of lambda_u.\n' );
    end
end

if ( Method == 1 || Method == 2 )
    if ( ~K_nominal_given )
        FELp.K_nominal       = UndulatorConsts.K_nominal;
    end
    
    if ( ~lambda_u_given )
        FELp.lambda_u        = UndulatorConsts.lambda_u;
    end
    
    if ( ~lambda_r_given )
        if ( FELp.llinear )
            FELp.lambda_r        = FELp.lambda_u * ( 1 + FELp.K_nominal^2 / 2 ) / ( 2 * FELp.gamma^2 );
        else
            FELp.lambda_r        = FELp.lambda_u * ( 1 + FELp.K_nominal^2 ) / ( 2 * FELp.gamma^2 );
        end
    end
end

res_parms_given = 0;

if ( K_nominal_given )
    res_parms_given = res_parms_given + 1;
end

if ( lambda_u_given )
    res_parms_given = res_parms_given + 1;
end

if ( gamma_given )
    res_parms_given = res_parms_given + 1;
end
    
if ( lambda_r_given )
    res_parms_given = res_parms_given + 1;
end

if ( Method == 3 && res_parms_given < 3 )
    fprintf ( 'K given (%d), lambda_u given (%d), lambda_r given (%d), gamma given (%d).\n', K_nominal_given, lambda_u_given, lambda_r_given, gamma_given );
    error ( 'Problem is underdetermined. Only %d resonance parameters given', res_parms_given );
end

if ( ~isfield ( FELp, 'gamma' ) )
    if ( FELp.llinear )
        FELp.gamma     = sqrt ( FELp.lambda_u / ( 2 * FELp.lambda_r ) * ( 1 + FELp.K_nominal^2 /2 ) );
    else
        FELp.gamma     = sqrt ( FELp.lambda_u / ( 2 * FELp.lambda_r ) * ( 1 + FELp.K_nominal^2 ) );
    end
end

if ( ( Method == 2 && K_nominal_given && lambda_u_given && lambda_r_given ) || ( Method == 3 && res_parms_given > 3 ) )
    fprintf ( 'Warning: Problem is overdetermined. Ignoring Energy value.\n' ); %Energy is a required parameter
elseif ( ~K_nominal_given )
    if ( FELp.llinear )
        Ksqr = 2 * ( FELp.lambda_r / FELp.lambda_u * ( 2 * FELp.gamma^2 ) - 1 ) ;
    else
        Ksqr =     ( FELp.lambda_r / FELp.lambda_u * ( 2 * FELp.gamma^2 ) - 1 ) ;
    end
    
    if ( Ksqr > 0 )
        FELp.K_nominal = sqrt ( Ksqr );
    else
%        fprintf ( 'Did not find real solution for K for lambda_r = %f nm, gamma = %f; lambda_u = %f cm.\n', FELp.lambda_r * 1e9, FELp.gamma, FELp.lambda_u * 1e2 );
        FELp.K_nominal = 0;
    end
    
 %   K_nominal = FELp.K_nominal
elseif ( ~lambda_u_given  )
    if ( FELp.llinear )
        FELp.lambda_u  = FELp.lambda_r * ( 2 * FELp.gamma^2 ) /  ( 1 + FELp.K_nominal^2 /2 );
    else
        FELp.lambda_u  = FELp.lambda_r * ( 2 * FELp.gamma^2 ) /  ( 1 + FELp.K_nominal^2 );
    end
%    lambda_u = FELp.lambda_u
%    fprintf ( 'lambda_r: %f nm, gamma: %f, K: %f -> lambda_u: %f cm\n', FELp.lambda_r * 10^9, FELp.gamma, FELp.K_nominal, FELp.lambda_u * 10^2 );
elseif ( ~lambda_r_given  )
    if ( FELp.llinear )
        FELp.lambda_r  = FELp.lambda_u * ( 1 + FELp.K_nominal^2 /2 ) / ( 2 * FELp.gamma^2 );
    else
        FELp.lambda_r  = FELp.lambda_u * ( 1 + FELp.K_nominal^2 ) / ( 2 * FELp.gamma^2 );
    end
%    lambda_r = FELp.lambda_r
end

%fprintf ( 'K: %4.2f; E: %4.2f; lr: %4.2f; lu: %4.1f\n', ...
%    FELp.K_nominal, ...
%    FELp.gamma * PhysicsConsts.mc2_e * 1e-9, ...
%    FELp.lambda_r * 1e9, ...
%    FELp.lambda_u * 1e3  ...
%    );

FELp = f_L_G3D ( FELp ); %%%

%FELp.aw0            = FELp.K_nominal / sqrt ( 2 );

if ( FELp.K_nominal > 0 )
    if ( strcmp ( FELp.beta, 'optimized' ) )
%        fprintf ( 'B: FELp.beta_ext is %f\n', FELp.beta_ext );

    	FELp.beta_ext = f_minimum_beta_ext ( FELp );

        FELp.betax    = FELp.beta_ext * 1.1;
        FELp.betay    = FELp.beta_ext^2 / FELp.betax;
    
        FELp          = f_L_G3D ( FELp ); %%%
    end

    FELp.gap             = f_getUndulatorGap ( FELp );
else
    FELp.gap             = 0;
end

FELp.Eph_descr       = 'FEL photon Energy';
FELp.Eph             = 2 * pi * PhysicsConsts.h_bar * PhysicsConsts.c / FELp.lambda_r / PhysicsConsts.echarge;
FELp.Eph_egu         = 'eV';

FELp.Bu_descr        = 'Peak on-axis magnetic undulator field';
FELp.Bu              = FELp.K_nominal * 2 * pi / FELp.lambda_u * PhysicsConsts.mc2_e / PhysicsConsts.c;
FELp.Bu_egu          = 'T';

FELp.Charge_descr    = 'Total bunch charge';
FELp.Charge_egu      = 'C';

%%------------------------------------------------------------------------

end


function FELp = f_L_G3D ( FELi )
%==============================================================================
%
% ABSTRACT:
%
%       This function calculates the 3D FEL paramters gain length, saturation
%       length and saturation power. The FEL parameters are taken from the
%       structure FELparameters, which is passed to the function by reference.
%       The function returns the 3D gain length as function value and sets all
%       output variables in the structure FELparamters. The function does not
%       modify any of the input parameters.
%       The parameters are only set if no inconsistancy in the input parameters
%       is detected. Otherwise a funcion value of zero is returned an the
%       structure is not modified.
%
% DESIGN CONSIDERATIONS:
%
%       The function can run in four different tions depening on which
%       of the four resonance parameters, lambda_r, lambda_u, aw0 and gammar0
%       are given. The program expects and checks that one and only one of these
%       four parameters is set to a value less or equal to zero. The program
%       will then calculate that parameter using the resonance condition.
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       14-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 14-MAR-1999     |  HDN  | Program creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
global UndulatorConsts;
global PhysicsConsts;

FELp = FELi;    
    
%------------------------------------------------------------------------

if ( FELp.K_nominal > 0 )
    calculate = true;
else
    calculate = false;
    fprintf ( 'Not calculating FEL parameters.\n' );
end

if ( FELp.llinear )
    FELp.rkxkw       = 1 / sqrt ( 2 );
else
    FELp.rkxkw       = 1;
end

FELp.aw0_descr       = 'Undulator Parameter';
FELp.aw0_egu         = '';

if ( FELp.llinear )
    FELp.aw0             = FELp.K_nominal / sqrt ( 2 );
else
    FELp.aw0             = FELp.K_nominal;
end

if ( calculate )
    FELp.beta_xy     = f_beta_total ( FELp.aw0, FELp.lambda_u, FELp.gamma, FELp.betax, FELp.betay, FELp.llinear, FELp.rkxkw );
else
    FELp.beta_xy     = 0;
end

FELp.d_omega_descr   = 'Radiation frequency spread equivalent to dgamma';
FELp.d_omega         = f_d_omega ( FELp.lambda_r, FELp.dgamma, FELp.gamma );
FELp.d_omega_egu     = '1/sec';

FELp.Omega_p_descr   = 'Plasma frequency';
if ( calculate )
    FELp.Omega_p     = f_Omega_p ( FELp.epsilon_n, FELp.gamma, FELp.L_B, FELp.Ipk, FELp.beta_xy );
else
    FELp.Omega_p     = 0;
end

FELp.Omega_p_egu     = '1/sec';

FELp.rho_descr       = 'FEL parameter (1D)';
%fprintf ( 'FELp.lambda_u = %f\n', FELp.lambda_u );
%fprintf ( 'FELp.aw0      = %f\n', FELp.aw0 );
%fprintf ( 'FELp.lambda_r = %e\n', FELp.lambda_r );

if ( calculate )
    FELp.rho         = f_rho ( FELp.llinear, FELp.lambda_u, FELp.aw0, FELp.gamma, FELp.Omega_p );
else
    FELp.rho         = 0;
end

FELp.rho_egu         = '';

FELp.L_G1D_descr     = 'FEL power gain length (1D)';
if ( calculate )
    FELp.L_G1D       = FELp.lambda_u / ( 4 * pi * sqrt ( 3 ) * FELp.rho );
else
    FELp.L_G1D       = 0;
end

FELp.L_G1D_egu       = 'm';

FELp.P_B_descr       = 'Total beam power';
FELp.P_B             = f_P_B ( FELp.Ipk, FELp.gamma );
FELp.P_B_egu         = 'W';

FELp.L_R_descr       = 'Raleigh Length (1D)';
FELp.L_R             = f_L_R ( FELp.L_G1D, FELp.lambda_r, FELp.beta_xy, FELp.epsilon_n / FELp.gamma );
FELp.L_R_egu         = 'm';

FELp.eta_d_descr     = 'Ming Xie dispersion parameter';
FELp.eta_d           = f_eta_d ( FELp.L_G1D, FELp.L_R );
FELp.eta_d_egu       = '';

FELp.eta_e_descr     = 'Ming Xie emittance parameter';
FELp.eta_e           = f_eta_e ( FELp.L_G1D, FELp.lambda_r, FELp.beta_xy, FELp.epsilon_n / FELp.gamma );
FELp.eta_e_egu       = '';

FELp.eta_g_descr     = 'Ming Xie energy spread parameter';
FELp.eta_g           = f_eta_g ( FELp.L_G1D, FELp.lambda_u, FELp.dgamma / FELp.gamma );
FELp.eta_g_egu       = '';

FELp.eta_descr       = 'Ming Xie 3D correction';
FELp.eta             = f_eta ( FELp.eta_d, FELp.eta_e, FELp.eta_g );
FELp.eta_egu         = '';

FELp.L_G3D           = FELp.L_G1D * ( 1D0 + FELp.eta );

FELp.empRedu_descr   = 'empirical relative reduction of FEL gain';
%FELp.empRedu         = max ( 0, 0.53365 * max ( 1, ( FELp.actReg / 100 ) ) * ( FELp.Ipk / 3400 )^1.5 + 0.02635 );
FELp.empRedu         = ( 0.0025 * FELp.Ipk )^3.5 * FELp.L_G1D / FELp.gamma;
FELp.empRedu_egu     = '';

FELp.L_G3D_descr     = 'FEL power gain length based on Ming Xie (uncorrected)';
FELp.L_G3D           = FELp.L_G1D * ( 1D0 + FELp.eta ) * ( 1D0 + FELp.empRedu );
FELp.L_G3D_egu       = 'm';

FELp.rho_3D_descr     = 'FEL parameter (3D)';
FELp.rho_3D           = FELp.lambda_u / ( 4 * pi * sqrt ( 3 ) * FELp.L_G3D );
FELp.rho_3D_egu       = '';

FELp.P_sat_descr     = 'FEL saturation power based on Ming Xie (uncorrected)';
%FELp.P_sat           = 1.6 * FELp.rho * FELp.P_B / ( 1 + FELp.eta )^2;
FELp.P_sat           = FELp.rho_3D * FELp.P_B / ( 1 + FELp.eta )^2;
FELp.P_sat_egu       = 'W';

FELp.L_sat_descr     = 'FEL saturation length based on Ming Xie power gain length (magnet length, uncorrected)';
FELp.L_sat           = f_L_sat ( FELp.L_G3D, FELp.P_sat, FELp.rho_3D, FELp.lambda_r, FELp.dgamma, FELp.gamma );
FELp.L_sat_egu       = 'm';

FELp.actLength_descr = 'Magnetic length of undulator line';
FELp.actLength       = FELp.lambda_u * UndulatorConsts.UndulatorPeriods;
FELp.actLength_egu   = 'm';

FELp.packFact_descr  = 'Undulator Packing Factor (Ratio of magnetic to full Length)';
FELp.packFact        = FELp.actLength / UndulatorConsts.UndulatorLength;
FELp.packFact_egu    = '';

FELp.L_sat_c_descr   = 'estimated FEL saturation length';
%FELp.L_sat_c         = FELp.L_sat * ( 1 + FELp.wakeLIncr ) / FELp.packFact;
FELp.L_sat_c         = FELp.L_sat / FELp.packFact;
FELp.L_sat_c_egu     = 'm';

FELp.actReg_descr    = 'estimated length of active FEL gain region';
FELp.actReg          = min ( FELp.L_sat_c, UndulatorConsts.UndulatorLength );
FELp.actReg_egu      = 'm';

FELp.P_sat_c_descr   = 'estimated FEL saturation power';
FELp.P_sat_c         = FELp.P_sat * ( 1 + FELp.taprPIncr );
FELp.P_sat_c_egu     = 'W';

FELp.P_out_c_descr   = 'estimated FEL power at Undulator exit';
FELp.P_out_c         = FELp.P_sat_c * exp ( min ( 0, UndulatorConsts.UndulatorLength - FELp.L_sat_c ) / FELp.L_G3D ); 
FELp.P_out_c_egu     = 'W';

if ( FELp.PostSat )
    L_Post           = min ( max ( 0, UndulatorConsts.UndulatorLength - FELp.L_sat_c ), UndulatorConsts.UndulatorLength ) * FELp.packFact;
    FELp.P_out_c     = FELp.P_out_c * ( 1 + 0.0188 * L_Post );
end

FELp.E_xray_descr    = 'Total FEL xray energy content per pulse';

if ( strcmp ( FELp.longShape, 'Flat-Top' ) )
    FELp.E_xray          = FELp.P_out_c * sqrt ( 12 ) * FELp.L_B / PhysicsConsts.c;
else
    FELp.E_xray          = FELp.P_out_c * sqrt ( 2 * pi ) * FELp.L_B / PhysicsConsts.c;
end

FELp.E_xray_egu      ='J';

end % function f_L_G3D


function BuKHhybrid_Nd_Fe_B_lin = f_BuKHhybrid_Nd_Fe_B_lin ( gap, lambda_u )
%==============================================================================
%
% ABSTRACT:
%
%       ...
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       16-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 16-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
gl = gap / lambda_u;

if ( gl < 1 )
    BuKHhybrid_Nd_Fe_B_lin = 3.44 * exp ( -5.08 * gl + 1.54 * gl^2 );
else
    BuKHhybrid_Nd_Fe_B_lin = 3.44 * exp ( -5.08 * gl + 1.54 * gl );
end

%fprintf ( 'gap: %f mm, lambda_u = %f cm, Bu = %f T\n', gap * 10^3, lambda_u * 10^2, BuKHhybrid_Nd_Fe_B_lin );

end % function f_BuKHhybrid_Nd_Fe_B_lin


function BuKHpure_Nd_Fe_B_lin = f_BuKHpure_Nd_Fe_B_lin ( gap, lambda_u, h_block )
%==============================================================================
%
% ABSTRACT:
%
%       ...
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       16-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 16-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
k_u = 2 * pi / lambda_u;

BuKHpure_Nd_Fe_B_lin = 2 * 1.25 * exp ( -pi * gap / lambda_u ) * ( 1 - sin ( -h_block * k_u ) ) * sin ( pi / 4 ) / ( pi / 4 );

end % function f_BuKHpure_Nd_Fe_B_lin



function BuSC_hel = f_BuSC_hel ( diameter, lambda_u )

%==============================================================================
%
% ABSTRACT:
%
%       ...
%
% DESIGN CONSIDERATIONS:
%
%       Function linear fitted to graph from Shlomo Caspi.
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       23-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 23-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
global PhysicsConsts;

Aa       =     -3.3510;
Ba       =     43.3858;
Ab       =    422.1909;
Bb       = -16122.7626;

a        = Aa + Ba * diameter;
b        = Ab + Bb * diameter;

awSC_hel = a + b * lambda_u;

k_u      = 2 * pi / lambda_u;

BuSC_hel = ( awSC_hel * k_u * PhysicsConsts.mc2_e ) /  PhysicsConsts.c;

end  % function f_awSC_hel


function gap = f_getUndulatorGap ( FELp )
%==============================================================================
%
% ABSTRACT:
%
%       This function returns the undulator gap in [m]based on the undulator K
%       value, the period, labda_u in [m] and the undulator
%       type. Supported undulator types are the same as for f_Bu.
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), SLAC National Accelerator Laboratory.
%
% CREATION  DATE:
%
%       11-JAN-2010
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 11-JAN-2010     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
global PhysicsConsts;

K         = FELp.K_nominal;
lambda_u  = FELp.lambda_u;

ku        = 2 * pi / lambda_u;
reqBu     = K * ku * PhysicsConsts.mc2_e / PhysicsConsts.c;

gap_min   = 0.001;
gap_max   = 0.100;
gap_range = gap_min : 0.0001 : gap_max;

ngap = length ( gap_range );

Bu_range = zeros ( 1, ngap );

for jg = 1 : ngap
    FELp.gap        = gap_range ( jg );
    Bu_range ( jg ) = f_Bu ( FELp );
end

if ( length ( find ( Bu_range == 0 ) ) < 2 )
    gap = interp1 ( Bu_range, gap_range, reqBu );
else
    gap = gap_max;
end


FELp.gap = gap;
chkBu    = f_Bu ( FELp );

if ( abs ( chkBu - reqBu ) > 2e-3 * reqBu )
    gap = NaN;
    Bu_range
    gap_range
    reqBu
    chkBu
    error ('test')
end

end  % function f_getUndulatorGap


function Bu = f_Bu ( FELp )
%==============================================================================
%
% ABSTRACT:
%
%       This function returns the on-axis magnetic undulator field in units
%       of [T], as fundction of undulator period [m], gap [m] and undulator
%       type. Supported undulator types are:
%               'KHhybrid_Nd_Fe_B'
%               'KHpure_Nd_Fe_B'
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), SLAC National Accelerator Laboratory.
%
% CREATION  DATE:
%
%       11-JAN-2010
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 11-JAN-2010     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
Bu_Corr = 0.06034;
Bu_Degr = 0;
Bu_Shim = 0.001;
%                fprintf ( 'hin f_Bu: "%s"; lambda_u = %f cm, gap = %f mm\n', FELp.UndType, FELp.lambda_u * 10^2, FELp.gap * 10^3 );

if ( isnan ( FELp.gap ) )
    Bu = NaN;
    return
end

if ( isfield ( FELp, 'lambda_u' ) && FELp.lambda_u > 0 )
    if ( isfield ( FELp, 'gap' ) && FELp.gap > 0 )
        if ( strcmp ( FELp.UndType, 'KHhybrid_Nd_Fe_B' )  ) 
                Bu = f_BuKHhybrid_Nd_Fe_B_lin ( FELp.gap, FELp.lambda_u );
%                fprintf ( 'hybrid in f_Bu\n' );
        elseif ( strcmp ( FELp.UndType, 'KHpure_Nd_Fe_B' ) && FELp.h_block > 0 ) 
                Bu = f_BuKHpure_Nd_Fe_B_lin ( FELp.gap, FELp.lambda_u, FELp.h_block );
        elseif ( strcmp ( FELp.UndType, 'SC_Helical' ) && ~FELp.llinear ) 
                Bu = f_BuSC_hel ( FELp.gap, FELp.lambda_u );
        else
            error ( 'Unknown undulator type "%s"', FELp.UndType );
        end
    end
end

Bu = Bu * ( 1 + Bu_Corr ) * ( 1 - Bu_Degr ) * ( 1 + Bu_Shim );

end  % function f_Bu


function P_B = f_P_B ( Ipk, gamma )
%==============================================================================
%
% ABSTRACT:
%
%       This function returns the beam power in units of [W], which it
%       calculates from the peak current, Ipk, and the Lorentz factor, gamma.
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       14-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 14-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
global PhysicsConsts;

P_B = Ipk * gamma * PhysicsConsts.mc2_e;

end  % function f_P_B


function L_R = f_L_R ( L_G1D, lambda_r, beta_xy, epsilon )
%==============================================================================
%
% ABSTRACT:
%
%       This function returns the Rayleigh range in units of [m], which it
%       calculates from the 1D gain length, L_G1D, the radiation
%       wavelenth, lambda_r, the total beta function beta_xy and the
%       un-normalized emittance, epsilon.
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       14-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 14-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
sigma = sqrt ( beta_xy * epsilon );
%w_0   = sqrt ( 2D0 ) * sqrt ( sigma^2 + 2 * ( lambda_r * L_G1D ) / ( 4 * pi )^2 );
%L_R   = pi * w_0^2 / lambda_r;
eps_ph = lambda_r / ( 4 * pi );
L_R = sqrt ( 2 * L_G1D / eps_ph ) * sigma;

end   % function f_L_R


function rho = f_rho ( llinear, lambda_u, aw, gamma, Omega_p )
%==============================================================================
%
% ABSTRACT:
%
%       This function returns the Pierce or FEL parameter, rho, which it
%       calculates from the the undulator type, llinear, the undulator
%       period, lambda_u, the undulator field strength, aw, the Lorentz
%       factor, gamma, and the plasma frequency, Omega_p.
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       14-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 14-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
global PhysicsConsts;

Xi    = aw^2 / ( 1 + aw^2 );

if ( llinear )
	F1 = besselj ( 0, Xi / 2 ) - besselj ( 1, Xi / 2 ); 
else
	F1 = 1;
end

omega_u   = 2 * pi * PhysicsConsts.c / lambda_u;

rho = ( ( aw * Omega_p * F1 ) / ( 4 * gamma * omega_u ) )^( 2 / 3 );

end % function f_rho


function Omega_p = f_Omega_p ( epsilon_n, gamma, L_B, Ipk, beta )
%==============================================================================
%
% ABSTRACT:
%
%       ...
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       14-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 14-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
global PhysicsConsts;

sigma   = sqrt ( epsilon_n / gamma * beta );
q_e     = sqrt ( 2 * pi ) * L_B * Ipk / PhysicsConsts.c;
n_e     = q_e / ( PhysicsConsts.echarge * ( 2 * pi )^1.5 * L_B * sigma^2 );

Omega_p = sqrt ( 4 * pi * PhysicsConsts.r_e * PhysicsConsts.c^2 * n_e / gamma );

end % function f_Omega_p


function beta_total = f_beta_total ( aw, lambda_u, gamma, betax, betay, llinear, rkxkw )
%==============================================================================
%
% ABSTRACT:
%
%       ...
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       14-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 14-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% 21-JUL-2008     |  HDN  | Replace argument beta_ext by betax, betay.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
if ( llinear && abs ( rkxkw ) <= 1 )
    rkykw = sqrt ( 1 - rkxkw^2 );
else
    rkykw = sqrt ( 0.5 );
end

if ( rkykw ~= 0 )
   K = aw / rkykw;
else
   K = 0;
end

if ( lambda_u ~= 0 )
    k_u = 2 * pi / lambda_u;
else
    k_u = 0;
end

if ( k_u ~= 0 && K ~= 0 )
    beta_nat = sqrt ( 2 ) * gamma / ( K * k_u );
else
    beta_nat = 0;
end

if ( betax > 0 )
    if ( beta_nat > 0 )
    	k_beta = sqrt ( ( 1 / betax )^2 + ( rkykw / beta_nat )^2 );
    else
        k_beta = 0;
    end
else
    if ( beta_nat > 0 )
        k_beta = rkykw / beta_nat;
    else
        k_beta = 0;
    end
end

if ( k_beta ~= 0 )
    beta_total = sqrt ( betay / k_beta );
else
    beta_total = 0;
end

end % function f_beta_total


function eta_d =  f_eta_d ( L_G1D, L_R )
%==============================================================================
%
% ABSTRACT:
%
%       ...
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       14-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 14-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
	eta_d = 0.5 * L_G1D / L_R;
end % FUNCTION f_eta_d


function eta_e = f_eta_e ( L_G1D, lambda_r, beta_xy, emittance )
%==============================================================================
%
% ABSTRACT:
%
%       ...
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       14-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 14-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
eta_e = 4 * pi * emittance * L_G1D / ( beta_xy * lambda_r );

end % function f_eta_e


function eta_g = f_eta_g ( L_G1D, lambda_u, dpp )
%==============================================================================
%
% ABSTRACT:
%
%       ...
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       14-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 14-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
eta_g = 4 * pi * L_G1D / lambda_u * dpp;

end   % function f_eta_g


function eta = f_eta ( eta_d, eta_e, eta_g )
%==============================================================================
%
% ABSTRACT:
%
%       ...
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       14-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 14-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
eta =   0.45 * eta_d^0.57                            + ...
        0.55 * eta_e^1.60                            + ...
        3.00 * eta_g^2.00                            + ...
	    0.35 * eta_e^2.90 * eta_g^2.40               + ...
	   51.00 * eta_d^0.95 * eta_g^3.00               + ...
	    5.40 * eta_d^0.70 * eta_e^1.90               + ...
	 1140.00 * eta_d^2.20 * eta_e^2.90 * eta_g^3.20;

end   % function f_eta



function d_omega = f_d_omega ( lambda_r, dgamma, gamma )
%==============================================================================
%
% ABSTRACT:
%
%       ...
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       14-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 14-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
global PhysicsConsts;

d_omega = 2D0 * PhysicsConsts.c / lambda_r * dgamma / gamma;

end    % function f_d_omega


function L_sat = f_L_sat ( L_G3D, P_sat, rho, lambda_r, dgamma, gamma )
%==============================================================================
%
% ABSTRACT:
%
%       ...
%
% DESIGN CONSIDERATIONS:
%
%       ...
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       14-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 14-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-
global PhysicsConsts;

L_sat = L_G3D * log ( P_sat / ( rho * gamma * PhysicsConsts.echarge * PhysicsConsts.mc2_e  * ...
            f_d_omega ( lambda_r, dgamma, gamma ) ) );
	
end    % function f_L_sat


function L_G3D_beta_ext = f_L_G3D_beta_ext ( beta_ext )

global FELparameters;

FELp           = FELparameters;

FELp.betax     = beta_ext * 1.1;
FELp.betay     = beta_ext^2 / FELp.betax;

%if ( FELp.llinear )
%    FELp.aw0   = FELp.K_nominal / sqrt ( 2 );
%else
%    FELp.aw0   = FELp.K_nominal;
%end

%FELp.betaxy    = f_beta_total ( FELp.aw0, FELp.lambda_u, FELp.gamma, FELp.betax, FELp.betay, FELp.llinear, FELp.rkxkw );
FELp.betaxy = sqrt ( FELp.betax * FELp.betay );

%fprintf ( 'f_L_G3D_beta_ext calling f_L_G3D\n' );
FELp           = f_L_G3D ( FELp );
L_G3D_beta_ext = FELp.L_G3D;

%fprintf ( 'leaving f_L_G3D_beta_ext L_G3D ( %f ) = %f)\n', beta_ext, L_G3D_beta_ext );

end


function minimum_beta_ext = f_minimum_beta_ext ( FELp )
%==============================================================================
%
% ABSTRACT:
%
%       ...
%
% DESIGN CONSIDERATIONS:
%
%       The function should leave FELp unchanged on exit. The calling routine
%       must arrange that only three of the four resonant paramters are
%       defined.
%
% AUTHOR(S):
%
%       Heinz-Dieter Nuhn (HDN), Stanford Synchrotron Radiation Laboratory.
%
% CREATION  DATE:
%
%       17-MAR-1999
%
%==============================================================================
%
% MODIFICATION HISTORY:
%
%        Date     | Name  | Description
% ----------------+-------+-----------------------------------------------------
% 17-MAR-1999     |  HDN  | Function creation.
% ----------------+-------+-----------------------------------------------------
% [change_entry]
%-

global FELparameters;

FELparameters = FELp;
TOL           = 1e-14;

%fprintf ( 'C: FELp.beta_ext is %f\n', FELp.beta_ext );

if ( FELparameters.beta_ext > 0 ) 
    x ( 1 ) = 0.000001;
    x ( 3 ) = 300;
    
    if ( FELparameters.beta_ext > x ( 1 ) && FELparameters.beta_ext < x ( 3 ) )
        x ( 2 ) = FELparameters.beta_ext;
    else
        x ( 2 ) = ( x ( 1 ) + x ( 3 ) ) / 2;
    end

    f1 = f_L_G3D_beta_ext ( x ( 1 ) );
    f2 = f_L_G3D_beta_ext ( x ( 2 ) );
    f3 = f_L_G3D_beta_ext ( x ( 3 ) );
    
    if ( f2 > f1 || f2 > f3 )
        fprintf ( 'f(%f)=%f; f(%f)=%f; f(%f)=%f\n', x ( 1 ), f1, x ( 2 ), f2, x ( 3 ), f3 );
        fprintf ( 'Error in bracketing minimum.\n' );
        minimum_beta_ext = x ( 3 );
        return;
    end
        
    if ( f2 > 0 )        
 %       fprintf ( 'x1: %f; x2: %f\n', x ( 1 ) , x ( 2 ) );
        

        [ xmin, fmin ] = BRENT ( x ( 1 ), x ( 2 ), x ( 3 ),   ...
                                   'f_L_G3D_beta_ext',          ...
                                   TOL                         ...
                                  );

        minimum_beta_ext = xmin;
%        fprintf ( 'f(%f)=%f; f(%f)=%f; f(%f)=%f. min@f(%f)=%f\n', x ( 1 ), f1, x ( 2 ), f2, x ( 3 ), f3, xmin, fmin  );
        
    else
        minimum_beta_ext = -1;
    end

else
    minimum_beta_ext = -1;
end

end % function f_minimum_beta_ext


function [ XMIN, FXMIN ] = BRENT ( AX, BX, CX, Fstr, TOL )
%
% Numerical Recipes: Minimum of a function, find by Brent's method
%
% Given a function Fstr, and given a bracketing triplet ob abscissas AX,
% BX, CX (such that BX is between AX and CX, and F(BX) is les than both
% F(AX) and F(CX)), this routine isolates the minimum to a fractional
% precision of about TOL using Brent's method. The abscissa of the minimum
% is returned as XMIN, and the minimum function value is returned as FXMIN.
%

ITMAX   = 100;
CGOLD   = 0.3819660;
ZEPS    = 1e-10;

F       = str2func ( Fstr );

A       = min ( AX, CX );
B       = max ( AX, CX );
V       = BX;
W       = V;
X       = V;
E       = 0; % Used for first iteration initialization indicator
FX      = F ( X );
FV      = FX;
FW      = FX;
success = false;

for ITER = 1 : ITMAX
	XM   = 0.5 * ( A + B );
    TOL1 = TOL * abs ( X ) + ZEPS;
    TOL2 = 2 * TOL1;
    
    if ( abs ( X - XM ) <= ( TOL2 - 0.5 * ( B - A ) ) )
        success = true;
        break;
    end

    if ( abs ( E ) > TOL1 )
        R = ( X - W ) * ( FX - FV );
        Q = ( X - V ) * ( FX - FW );
        P = ( X - V ) * Q - ( X - W ) * R;
        Q = 2 * ( Q - R );

        if ( Q > 0 )
            P = -P;
        end

        Q     = abs ( Q );
        ETEMP = E;
        E     = D;
        
        if ( abs ( P ) < abs ( .5 * Q * ETEMP ) && P > Q * ( A - X ) && P < Q * ( B - X ) )            
            D = P / Q;
            U = X + D;
                
            if ( U - A < TOL2 || B - U < TOL2 ) 
                D = TOL1 * sign ( XM - X );
            end
        else            
            if ( X >= XM )
                E = A - X;
            else
                E = B - X;
            end
            
            D = CGOLD * E;
        end
    else
        if ( X >= XM )
            E = A - X;
        else
            E = B - X;
        end
            
        D = CGOLD * E;        
    end

    if ( abs ( D ) >= TOL1 )
        U = X + D;
    else
        U = X + TOL1 * sign ( D );
    end
        
    FU = F ( U );
        
    if ( FU <= FX )
        if ( U >= X )
            A = X;
        else
            B = X;
        end
            
        V  = W;
        FV = FW;
        W  = X;
        FW = FX;
        X  = U;
        FX = FU;
    else
        if ( U < X )
            A = U;
        else
            B = U;
        end
            
       if ( FU <= FW || W == X )
            V  = W;
            FV = FW;
            W  = U;
            FW = FU;
        elseif ( FU <= FV || V == X || V == W)
            V  = U;
            FV = FU;
        end
    end
end  % CONTINUE

if ( ~success )
    error ( 'Brent exceed maximum iterations.' );
end

XMIN  = X;
FXMIN = FX;

end
