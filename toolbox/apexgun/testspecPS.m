function [ output_args ] = testspecPS(i0,iend,NSteps)
% Measures spectrometer PS current set value vs. readback and measured B field 
%   

dI=(iend-i0)/(NSteps-1);
%Iact=zeros(NSteps);
%Irdbck=zeros(NSteps);
%Bfield=zeros(NSteps);
for ii=1:NSteps
    Iact(ii)=(ii-1)*dI;
    setpvonline('SpecBend1:Setpoint',Iact(ii),'float',1)
    pause(4);
    Irdbck(ii)=getpv('SpecBend1:CurrentRBV');
    Bfield(ii)=getpv('Bell6010:1:MeasFlux');
    
    figure(70)
    hold
    plot(Iact,Irdbck)
    xlabel('I set [A]')
    ylabel('I readback')
   
    figure(71)
    hold
    plot(Iact, Bfield)
    xlabel('I set [A]')
    ylabel('B [Gauss]')
    
    figure(72);
    hold
    plot(Irdbck, Bfield)
    xlabel('I readback [A]')
    ylabel('B [Gauss]')
    
    figure(73)
    hold
    plot(Iact,Iact-Irdbck)
    xlabel('I set [A]')
    ylabel('I set minus I readback [A]')
    
end

    setpvonline('SpecBend1:Setpoint',0,'float',1)

    

end

