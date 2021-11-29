function [] = setGunAtOperationFrequency()
% Set Gun at the operating frequency hardwired in this code
['OBSOLETE. DO NOT USE THIS ROUTINE']
return

selector=0;
if selector==0
    ddsa_h=190652;% 185,714,286 Hz (for 1.3GHz)
    ddsa_l=3440;% 185,714,286 Hz (for 1.3GHz)
    ['Set Gun frequency at 185,714,286 Hz (for 1.3GHz)']
elseif selector==1
    ddsa_h=191230;% 185,657,993 Hz (for 1.299 605 951 GHz)
    ddsa_l=3000;% 185,657,993 Hz (for 1.299 605 951 GHz)
    ['Set Gun frequency at 185,657,993 Hz (for 1.299 605 951 GHz)']
end

setpv('llrf1:ddsa_phstep_h_ao',ddsa_h)
setpv('llrf1:ddsa_phstep_l_ao',ddsa_l)

end

