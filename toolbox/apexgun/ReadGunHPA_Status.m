function [] = ReadGunHPA_Status()
%Reset and Read the gun high power amplifier (HPA) status (operational mode)
%Syntax:ReadGunHPA_Status
UnitONstatus=getpv('Gun:HPA:SystemOn');
BlackHeatingStatus=getpv('Gun:HPA:BlackHeatingOn');
StandbyStatus=getpv('Gun:HPA:StandByModeOn');
HV_Status=getpv('Gun:HPA:HVModeOn');
RF_Status=getpv('Gun:HPA:RFModeOn');

setpv('Gun:HPA:Reset',1);
['PLEASE WAIT: Gun HPA being reset (10 s)']
pause(10);

if UnitONstatus==0
    ['Gun HPA is OFF']
    return
end
if RF_Status==1
    ['Gun HPA is in RF mode']
    return
end
if HV_Status==1
    ['Gun HPA is in HV mode']
    return
end
if StandbyStatus==1
    ['Gun HPA is in Standby mode']
    return
end
if BlackHeatingStatus==1
    ['Gun HPA is in Black Heating mode']
    return
end
['Error reading HPA mode']

end

