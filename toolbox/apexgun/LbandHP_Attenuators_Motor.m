function [ MotorSet ] = LbandHP_Attenuators_Motor(HP_AttID,Attn_dB)
% Calculate the setting for the motor for a given attenuation for the high power L-band attenuators. 
% Return Motor set.
% SINTAX: [ MotorSet ] = LbandHP_Attenuators_MotorSet(HP_AttID,Attn_dB)
% If HP_AttID is different from 0,1,2,3 it assumes ID= 1
% HP_AttID=0 refers to the T-Cav attenuator. 
% Fit parameters from Slawek measurements on June 3, 2015.


if HP_AttID==0
    %T-Cav (Slawek ID 2)
    AtMax=40;
    Atmin=22;
    
    y0 	= -61743;
    AA  =  48398;
    x0 	= -11158;
    nn  =  0.0061148;
    BB  =  34358;
    x1 	= -21.463;
    mm  =  0.18113;
elseif HP_AttID==2
    %Linac 2 (Slawek ID 3)
    AtMax=25;
    Atmin=5.1;

    y0 	= -52035;
    AA  =  56649;
    x0 	= -4.9;
    nn  =  0.027593;
    BB  =  27293;
    x1 	= -0.060002;
    mm  =  0.62279;
elseif HP_AttID==3
    %Linac 3 (Slawek ID 4)
    AtMax=25;
    Atmin=5;
    
    y0 	= -69871;
    AA  =  57939;
    x0 	= -4.1;
    nn  =  0.067886;
    BB  =  28584;
    x1 	= -4.9;
    mm  =  0.027197;
else
    if HP_AttID~=1
        ['WARNING: wrong attenuator ID. Assumed Attenuator 1']
    end
    % Linac 1 (Slawek ID 1)
    AtMax=25;
    Atmin=5;
    
    y0= -61997;
    AA=  48132;
    x0= -4.8845;
    nn=  0.0095947;
    BB=  32891;
    x1= -3.1212;
    mm=  0.19616;
end

Attn_dB=abs(Attn_dB);

Size_Attn=size(Attn_dB);
for jj=1:Size_Attn(2)
    if Attn_dB(jj) > AtMax
        %Attn_dB=AtMax;
        ['ERROR: Attenuation > ',num2str(AtMax),' dB']
        Attn_dB(jj)=NaN;
    end
    if Attn_dB(jj) < Atmin
        %Attn_dB=Atmin;
        ['ERROR: Attenuation < ',num2str(Atmin),' dB']
        Attn_dB(jj)=NaN;
    end
end
Size_Attn=size(Attn_dB);

MotorSet=zeros(1,Size_Attn(2));
for ii=1:Size_Attn(2)
    At=-Attn_dB(ii);
    MotorSet(ii)= y0+AA/abs((At-x0))^nn+BB/abs((At-x1))^mm;
end

end

