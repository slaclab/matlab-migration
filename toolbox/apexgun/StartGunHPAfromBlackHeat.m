function [ output_args ] = StartGunHPAfromBlackHeat()
%Start the gun high power amplifier (HPA) from Black Heat mode and set it to RF mode
%Syntax:StartGunHPAfromBlackHeat()
ONstatus=getpv('Gun:HPA:SystemOn');
if ONstatus==1
    setpv('Gun:HPA:Reset',1);% Reset Gun HPA
    ['Resetting Gun HPA']
    pause(15);
    setpv('Gun:HPA:StandbyMode',1);% set gun Gun HPA in standby
    pause(15);
    SBflag=getpv('Gun:HPA:StandByModeOn');
    while SBflag==0
            SBflag=getpv('Gun:HPA:StandByModeOn');
            ['Waiting for the HPA going in Standby mode']
            pause(5);
    end
    ['HPA in standby mode']
    HVflag=getpv('Gun:HPA:HVModeOn');
    if HVflag==0
        setpv('Gun:HPA:HVOnMode',1);% Enable Gun HPA HV mode
        pause(20);
        HVflag=getpv('Gun:HPA:HVModeOn');
        while HVflag==0
            if getpv('Gun:HPA:Screen2OverVoltage_Intlk')==1
                setpv('Gun:HPA:Reset',1);% Reset Gun HPA
                pause(10)
            end
            HVflag=getpv('Gun:HPA:HVModeOn');
            ['Waiting for the HPA going in HV mode']
            pause(1);
       end
   end
    ['HPA in HV mode']
    RFflag=getpv('Gun:HPA:RFModeOn');
    if RFflag==0
        setpv('Gun:HPA:RFOnMode',1);% Enable Gun HPA RF mode
        pause(15);
        RFflag=getpv('Gun:HPA:RFModeOn');
        while RFflag==0
            RFflag=getpv('Gun:HPA:RFModeOn');
            ['Waiting for the HPA going in RF mode']
            pause(1)
        end
    end
    ['HPA in RF mode']
else
    ['The HPA is OFF']
end

end

