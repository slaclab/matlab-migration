function [BDES,Ib] = Bucking_Coil_BDES(SOL1_BDES,gun_number)

%   [BDES,Ib] = Bucking_Coil_BDES(SOL1_BDES[,gun_number])
%
%   Function to calculate the solenoid gun bucking coil BDES setting needed to achieve
%   zero longitudinal field on the cathode, based on magnetic measurements.
%
%   INPUTS:     SOL1_BDES:  The BDES setting of the main solenoid (SOL1) [kG-m]
%               gun_number: [Optional, DEF=1] The RG gun version (gun #: 1 or 2)
%
%   OUTPUTS:    BDES:       The bucking coil BDES setting needed for no B_z field
%                           on cathode [kG]
%               Ib:         The associated bucking coil current setting [A]
%                           (Note that SOL1_BDES > 0 requires BDES < 0 to buck)

%=====================================================================================

if ~exist('gun_number')
  gun_number = 1;           % default to RF gun-1 (SOL1 #001099, SOL1BK #002413, gun #002411)
end

if gun_number==1                                            % For RG-Gun-1...
  p  = [-0.2484 357.16 -120.66 716.5 -2081 2845.9 -1377.1]; % SOL1 (#001099) polynomial for RF gun-1 (SOL1 current vs. SOL1 integrated Bz, A/(kG-m)^i)
  pb = [3.009E-1 1.466E-2 -1.514E-4 7.056E-7];              % SOL1BK (#002413) polynomial for RF gun-1 (BK current vs. SOL1 current, A/A)
  pB = 57.247;                                              % SOL1BK current vs SOL1BK Bz field [A/kG]
elseif gun_number==2                                        % For RG-Gun-2 (SOL1 #002201, SOL1BK #002203, gun #002412)
  p  = [-0.3120 355.62 -121.53 719.0 -2081 2830.0 -1361.8]; % SOL1 (#002201) polynomial for RF gun-1 (SOL1 current vs. SOL1 integrated Bz, A/(kG-m)^i)
  pb = [-1.964E-1 2.252E-2 -1.996E-4 7.876E-7];             % SOL1BK (#002203) polynomial for RF gun-1 (BK current vs. SOL1 current, A/A)
  pB = 56.104;                                              % SOL1BK current vs SOL1BK Bz field [A/kG]
else
  error('RF Gun number can only be 1 or 2 - try again.')
end

v  = [1 SOL1_BDES SOL1_BDES.^2 SOL1_BDES.^3 SOL1_BDES.^4 SOL1_BDES.^5 SOL1_BDES.^6]';
I  =  p*v;
vb = [1 I I.^2 I.^3]';
Ib =  -pb*vb;           % SOL1BK current for zero Bz at cathode [A]
BDES = Ib/pB;           % SOL1BK BDES for zero Bz at cathode [kG]