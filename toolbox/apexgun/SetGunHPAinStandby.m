function [] = SetGunHPAinStandby()
%Set the gun high power amplifier (HPA) to Standby mode
%Syntax:SetGunHPAinStandby()

ONstatus=getpv('Gun:HPA:SystemOn');
BHstatus=getpv('Gun:HPA:BlackHeatingOn');
HVflag=getpv('Gun:HPA:HVModeOn');
RFflag=getpv('Gun:HPA:RFModeOn');
SBflag=getpv('Gun:HPA:StandByModeOn');

if ONstatus==1 && BHstatus==0
    setpv('Gun:HPA:HVOnMode',1)% set gun Gun HPA in HV
    pause(2);
    setpv('Gun:HPA:StandbyMode',1)% set gun Gun HPA in standby    
    while RFflag==1 || HVflag==1 || SBflag==0
                HVflag=getpv('Gun:HPA:HVModeOn');
                RFflag=getpv('Gun:HPA:RFModeOn');
                SBflag=getpv('Gun:HPA:StandByModeOn');
            ['Waiting for the HPA going in Standby mode']
            pause(1);
    end
    ['HPA in standby mode']
else
    if ONstatus==0
        ['WARNING: The HPA is OFF']
    else
        ['WARNING: The HPA is in Black Heat']
    end
   
end

end

