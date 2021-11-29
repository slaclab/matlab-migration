function [sigE_E0,meanE_E0] = und_esprd(E0,K,lamu,L);

%   [sigE_E0,meanE_E0] = und_esprd(E0,K,lamu,L);
%
%   Function to calculate the rms relative energy spread of a planar undulator
%   at energy E0, with undulator parameter K (peak value, not rms), and period lamu.
%
%   INPUTS:     E0:         Electron energy [GeV]
%               K:          Undulator peak-parameter (K = 0.93373*Bpk[T]*lamu[cm])
%               lamu:       Planar undulator period [m]
%               L:          Length of undulator [m]
%
%   OUTPUTS:    sigE_E0:    RMS relative energy spread [ ]
%               meanE_E0:   Mean relative energy loss [ ]

%=========================================================================

mc2 = 510.99906E-6;         % e- rest mass [GeV]
lamc_bar = 3.86159323e-13;  % Compton reduced wavelength [m]
re = 2.81794092E-15;        % classical e- radius [m]
gam0 = E0/mc2;
ku = 2*pi/lamu;
Krms = K/sqrt(2);
F = 1.70*Krms + 1/(1 + 1.88*Krms + 0.80*Krms^2);

sigE_E0 = sqrt(L*14/15*lamc_bar*re*gam0^4*ku^3*Krms^2*F)/gam0;
meanE_E0 = re*mc2*gam0^2*K^2*ku^2*L/E0/3;