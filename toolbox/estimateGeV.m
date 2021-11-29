function [estE_GeV] = estimateGeV(desE_eV, startE_eV, startE_GeV, varargin)
% Calculates an estimate electron energy for a desired photon energy, given
% current electron and photon energies, using the fundamental wavelength
% approximation for FEL (a la Alsberg).
% 
% This calculation was developed with an eye towards changing energy from a
% specific config, where the starting electron and photon energies are
% known.
%
%   inputs:
%       - desE_eV: desired photon energy in eV
%       - startE_eV: starting point energy for photons in eV
%       - startE_GeV: starting point energy for electrons in GeV
%       - varargin: you can put an undulator K value here if you want to
%       try something other than 3.505
%
% 10 Oct 2016

% Some important values:

hc = 1.24e-6; % Planck's constant x speed of light in eV*m
m_rest = 0.000511; % Electron rest energy in GeV
lambda_u = 0.03; % Undulator period in m
K_u = 3.505; % Approximate undulator K

if nargin > 3
    K_u = varargin{1};
end

% Calculate energy change needed using fundamental wavelength approximation

deltaE_GeV = m_rest * sqrt((lambda_u/(2*hc))*(1+K_u^2/2)) * (sqrt(desE_eV) - sqrt(startE_eV));

% Add to find your final energy!

estE_GeV = startE_GeV + deltaE_GeV;

end

