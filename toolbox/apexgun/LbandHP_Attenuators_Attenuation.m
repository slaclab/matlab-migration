function [ Attn_dB,PhaseShift_RFdeg ] = LbandHP_Attenuators_Attenuation(HP_AttID,MotorSetting)
% Calculate the attenuation and phase shift for the high power L-band attenuators. 
% Return Attn_dB in dB with respect to the circulator output and
% PhaseShift_RFdeg in RF degrees at 1.3 GHz.
% SINTAX: [ Attn_dB,PhaseShift_RFdeg ] = LbandHP_Attenuators_Attenuation(HP_AttID,MotorSetting)
% If HP_AttID is different from 0,1,2,3 it assumes ID= 1
% HP_AttID=0 refers to the T-Cav attenuator. 
% Fit parameters from Slawek measurements on June 3, 2015.

MotSetMax=18500;
MotSetMin=3000;
MotorSetting=abs(MotorSetting);

if HP_AttID==0
    %T-Cav (Slawek ID 2)
    K0 	= -196.3;
    K1 	=  0.10028;
    K2 	= -2.7003e-05;
    K3 	=  4.0731e-09;
    K4 	= -3.6279e-13;
    K5 	=  1.8959e-17;
    K6 	= -5.3759e-22;
    K7 	=  6.3837e-27;
    
    P0 	=  1.377;
    P1 	= -0.0057255;
elseif HP_AttID==2
    %Linac 2 (Slawek ID 3)
    K0 	= -166.84;
    K1 	=  0.092565;
    K2 	= -2.4918e-05;
    K3 	=  3.7738e-09;
    K4 	= -3.3799e-13;
    K5 	=  1.7767e-17;
    K6 	= -5.0678e-22;
    K7 	=  6.0529e-27;
    
    P0 	= -0.24223;
    P1 	= -0.0056081;

elseif HP_AttID==3
    %Linac 3 (Slawek ID 4)
    K0 	= -143.8;
    K1 	=  0.07689;
    K2 	= -2.0391e-05;
    K3 	=  3.0639e-09;
    K4 	= -2.731e-13;
    K5 	=  1.4313e-17;
    K6 	= -4.0749e-22;
    K7 	=  4.8614e-27;
    
    P0 	= -0.49639;
    P1 	= -0.0056026;

else
    if HP_AttID~=1
        ['WARNING: wrong attenuator ID']
        return
    end
    % Linac 1 (Slawek ID 1)
    K0 	= -88.154;
    K1 	=  0.043302;
    K2 	= -1.1444e-05;
    K3 	=  1.7563e-09;
    K4 	= -1.6111e-13;
    K5 	=  8.7103e-18;
    K6 	= -2.5602e-22;
    K7 	=  3.1538e-27;
    
    P0 	=  88.942;
    P1 	= -0.0056436;
end

Size_motor=size(MotorSetting);

Attn_dB=zeros(1,Size_motor(2));
PhaseShift_RFdeg=zeros(1,Size_motor(2));
for ii=1:Size_motor(2)
    
    if MotorSetting(ii)>MotSetMax
        ['ERROR: Motor Setting > ',num2str(MotSetMax),' counts']
        MotorSetting(ii)=NaN;
    end
    if MotorSetting(ii)<MotSetMin
        ['ERROR: Motor Setting < ',num2str(MotSetMin),' counts']
        MotorSetting(ii)=NaN;
    end
        
    mt=MotorSetting(ii);
    Attn_dB(ii)=-(K0+K1*mt+K2*mt^2+K3*mt^3+K4*mt^4+K5*mt^5+K6*mt^6+K7*mt^7);
    PhaseShift_RFdeg(ii)=P0+P1*mt;
end

end

