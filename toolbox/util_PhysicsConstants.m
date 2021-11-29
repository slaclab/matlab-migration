function const = util_PhysicsConstants
% util_PhysicsConstants provides reference values for the most commonly
%       physics constants.
%
%       Usage:
%       const  = util_PhysicsConstants
%       Energy = 13.64e09;
%       gamma  = Energy / const.mc2_e;
%       Brho   = Energy / const.c;
%
%       Function last edited March 10, 2008 by HDN

const.c                  = 299792458;                                                            % m/s
const.mc2_e              = 510998.918;                                                           % eV
const.echarge            = 1.60217653e-19;                                                       % C
const.mu_0               = 4 * pi * 1e-7;                                                        % V s / A m
const.eps_0              = 1 / const.mu_0 / const.c^2;                                           % A s / V m
const.r_e                = const.echarge * const.c^2 * 1e-7 / ( const.mc2_e );                   % m
const.Z_0                = const.c * const.mu_0;                                                 % V / A
const.h_bar              = 6.6260693e-34 / 2 / pi;                                               % J s
const.alpha              = const.echarge^2 / ( 4 * pi * const.eps_0 * const.h_bar * const.c );
const.Avogadro           = 6.0221415e23;                                                         % 1 / mol
const.k_Boltzmann        = 1.3806505e-23;                                                        % J / K
const.Stefan_Boltzmann   = ( pi^2 / 60 ) * const.k_Boltzmann^4 / ( const.h_bar^3 * const.c^2 );  % W / ( m^2 K^4 )

end