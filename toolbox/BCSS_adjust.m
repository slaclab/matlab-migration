function [BDES,iMain,xpos,theta,R56] = BCSS_adjust(delay, energy, str)

%   [BDES,xpos,theta] = BCSS_adjust(delay,energy,str);
%
%   Function to calculate BDES of main HXRSS chicane supply and the three trims (BXSS1, BXSS3, BXSS4)
%   given the desired chicane delay (fs) and the elecron energy (GeV).
%
%    INPUTS:    delay:      The chicane delay value requested - always >0 here (fs)
%               energy:     The e- energy (GeV)
%
%   OUTPUTS:    BDES(1):    The main supply BDES - absolute BDES (kG-m)
%               BDES(2):    The BX*S1 BTRM BDES (in main-coil Amperes)
%               BDES(3):    The BX*S3 BTRM BDES (in main-coil Amperes)
%               BDES(4):    The BX*S4 BTRM BDES (in main-coil Amperes)
%               xpos:       The beam's x-position absolute displacement at chicane center (m)
%               theta:      Absolute value of bend angle of each dipole (rad)

% ========================================================================================

if nargin < 3, str='BCSS';end

if energy<=1
  error('Electron energy must be > 1 GeV - try again.')
end
c  = 2.99792458e8;  % light speed (m/s)
switch str
    case {'BCSS' 'HXRSS'}
        Lm = 0.3636;        % HXRSS nominal bend length - meas'd along linac "z" (m)
        dL = 0.5828;        % HXRSS nominal drift length BXHS1-BXHS2 (& BXHS3-BXHS4) - meas'd along linac "z" (m)
        dMax = 50;
        
    case {'SXRSS'}
        Lm = 0.3636;        % SXRSS nominal bend length - meas'd along linac "z" (m)
        dL = 0.8294;        % SXRSS nominal drift length BXSS1-BXSS2 (& BXSS3-BXSS4) - meas'd along linac "z" (m)
        dMax = 1450;
        try % Vain attempt to obey MPS limit to be more flexible.
            pvs = ...
                {'MPS:UND1:950:SX_SASE_X_CALC.C';... % SASE x pos limit
                'MPS:UND1:950:SX_SS_X_CALC.C';... % seeded x pos limit
                'MPS:UND1:950:SX_HRMNC_X_CALC.C';... % harmonic x pos limit
                'MPS:UND1:950:SXRSS_MODE'};... % present mode
            vals = lcaGetSmart(pvs,1,'double');
            if any(isnan(vals)),error('Failed to get PV.');end
            if vals(4)
                dxMax = abs(vals(vals(4)));
                if dxMax > 25,error('MPS limit on max x position suspiciously large; ignoring.');end
                dMax =  (dL+2*Lm/3)/(Lm+dL)^2/c*1e9*dxMax^2;
                dMax = dMax*.998; % room to breathe
            end
        catch ex
            disp('BCSS_adjust.m: Can''t get smart SXRSS chicane limit. Using default.')
            disp(ex.message)
        end
        
    case {'XLEAP'} 
        
        Lm = 0.3636;        % XLEAP nominal bend length - meas'd along linac "z" (m)
        dL = 0.8294;        % XLEAP nominal drift length BXSS1-BXSS2 (& BXSS3-BXSS4) - meas'd along linac "z" (m)
        dMax = 1450;

end

delay = abs(delay); % use positive delay here (fs)
if delay>dMax
  error('%s delay can only be set between 0 and %d fs - try again.',str,dMax)
end


theta  = sqrt(1E-15*c*delay/(dL+2*Lm/3));               % desired bend angle per chicane dipole (rad)
xpos   = 2*Lm*tan(theta/2) + dL*tan(theta);             % x-displacement of beam at chicane center (m)
R56    = abs(2*sec(theta)*(2*Lm*(theta+eps)*cot(theta+eps)-2*Lm-dL*(tan(theta))^2))*1e6;
% [BDES,Imain,Itrim] = BCSS_BDES(theta*180/pi,energy);    % gives chicane BDES of main and trim supplies
[BDES, iMain, iTrim]=model_energyBTrim(theta*180/pi,energy,str);
