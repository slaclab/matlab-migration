function [ output_args ] = ResetGunHPA()
%Reset the gun high power amplifier (HPA) and set it to RF mode
%Syntax:ResetGunHPA()
RFstatus=getpv('Gun:HPA:RFModeOn');
if RFstatus==0
    setpv('Gun:HPA:Reset',1)% Reset Gun HPA
    resetflag=getpv('Gun:HPA:StandByModeOn');
    while resetflag==0
        resetflag=getpv('Gun:HPA:StandByModeOn');
        ['Waiting for the HPA going in Standby mode']
        pause (2);
        setpv('Gun:HPA:Reset',1)% Reset Gun HPA
    end
    ['HPA in standby mode']
    HVflag=getpv('Gun:HPA:HVModeOn');
    pause(15)
    if HVflag==0
        setpv('Gun:HPA:HVOnMode',1);% Enable Gun HPA HV mode
        pause(5);
        setpv('Gun:HPA:Reset',1)% Reset Gun HPA
        HVflag=getpv('Gun:HPA:HVModeOn');
        while HVflag==0
            HVflag=getpv('Gun:HPA:HVModeOn');
            ['Waiting for the HPA going in HV mode']
            pause(3);        
            setpv('Gun:HPA:Reset',1)% Reset Gun HPA
        end
    end
    ['HPA in HV mode']
    RFflag=getpv('Gun:HPA:RFModeOn');
    pause(5)
    if RFflag==0
        setpv('Gun:HPA:RFOnMode',1)% Enable Gun HPA RF mode
        RFflag=getpv('Gun:HPA:RFModeOn');
        while RFflag==0
            RFflag=getpv('Gun:HPA:RFModeOn');
            ['Waiting for the HPA going in RF mode']
            pause(1);
        end
    end
    ['HPA in RF mode']
else
    ['The HPA is already in RF mode']
end

end

