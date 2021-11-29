function [isok, BDES1, BDES2] = E200_calc_QS_2(z_ob, z_im, QS, m12_req, m34_req)

E0 = 20.35;
isok = 1;
if(nargin < 4); m12_req = 0; end;
if(nargin < 5); m34_req = 0; end;

% initial guesses (2012 values)
KQS1_0 = 0.3;
KQS2_0 = -0.23;
mytol = (0.01^2 + 0.01^2);

% linac z locations of QS1 and QS2
z_QS1 = 1999.206665; % [m], middle of quad
z_QS2 = 2004.206665; % [m], middle of quad
LEFF_QS1 = 1; % [m]
LEFF_QS2 = 1; % [m]

OO = zeros(2,2);

d1 = (z_QS1-LEFF_QS1/2) - z_ob ;
d2 = (z_QS2-LEFF_QS2/2) - (z_QS1+LEFF_QS1/2);
d3 = z_im - (z_QS2+LEFF_QS2/2);

M_01 = [1 d1; 0 1];
M4_01 = [M_01 OO; OO M_01];
M_02 = [1 d2; 0 1];
M4_02 = [M_02 OO; OO M_02];
M_03 = [1 d3; 0 1];
M4_03 = [M_03 OO; OO M_03];

[fit_result, chi2] = fminsearch(@transportError, [KQS1_0 KQS2_0]);

BDES1 =  fit_result(1) * (E0+QS) * LEFF_QS1 / 0.0299792;
BDES2 =  fit_result(2) * (E0+QS) * LEFF_QS2 / 0.0299792;

if(chi2 > mytol)
    isok = 0;
    warning('could not converge to solution');
    BDES1 = NaN;
    BDES2 = NaN;
end

BMAX = 385; % max value, from SCP
if(abs(BDES1) > BMAX || abs(BDES2) > BMAX)
    isok = 0;
    warning('solution is outside QS range');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function chi2 = transportError(K)
        % QS1 transport matrix
        k = abs(K(1));
        phi = LEFF_QS1*sqrt(k);
        M_F = [cos(phi)             (1/sqrt(k))*sin(phi)
            -sqrt(k)*sin(phi)    cos(phi)];
        M_D = [cosh(phi)             (1/sqrt(k))*sinh(phi)
            sqrt(k)*sinh(phi)    cosh(phi)];
        M4_F = [M_F OO; OO M_D];
        
        % QS2 transport matrix
        k = abs(K(2));
        phi = LEFF_QS2*sqrt(k);
        M_F = [cos(phi)             (1/sqrt(k))*sin(phi)
            -sqrt(k)*sin(phi)    cos(phi)];
        M_D = [cosh(phi)             (1/sqrt(k))*sinh(phi)
            sqrt(k)*sinh(phi)    cosh(phi)];
        M4_D = [M_D OO; OO M_F];

        % dump line optics
        M4 = M4_03*M4_D*M4_02*M4_F*M4_01;
        
        chi2 = (M4(1,2)-m12_req)^2 + (M4(3,4)-m34_req)^2;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

