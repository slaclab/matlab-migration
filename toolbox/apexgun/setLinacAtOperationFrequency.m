function [] = setLinacAtOperationFrequency()
% Set linac and deflecting cavity at the operating frequency hardwired in this code

format long;
clock = 1300e6*11/20/7;

vh=round(getpv('llrf1:ddsa_phstep_h_ao'));
setpv('llrf1:ddsa_phstep_h_ao',vh);

vl=getpv('llrf1:ddsa_phstep_l_ao');
%if vl ~= 744 %value from Larry Nov 2016 with vh=190650 and module 4 give 1.3/7 GHz
if vl ~= 4092
    setpv('llrf1:ddsa_phstep_l_ao',4092);
    ['The Gun ddsa low was set to 744']
end
vl;
vm=getpv('llrf1:ddsa_modulo_ao');
if vm ~= 4
    setpv('llrf1:ddsa_modulo_ao',4);
    ['The Gun ddsa modulo was set to 4']
end

lm=getpv('L2llrf:ddsa_modulo_ao');
if lm ~= 4
    setpv('L2llrf:ddsa_modulo_ao',4);
    ['The Linac ddsa low was set to 4']
end

ll=4092;% DO NOT CHANGE THIS VALUE (1116 value from Larry Nov 2016)
lh=(-7*(2-(vh+vl/(4096-vm))/2^20)+13)*2^20-ll/(4096-lm);

fv = clock * (2  - (vh + vl/(4096-vm))/2^20)
fl = clock * (13 - (lh + ll/(4096-lm))/2^20)
fl/fv
lh

setpv('L2llrf:ddsa_phstep_h_ao',lh);
setpv('L2llrf:ddsa_phstep_l_ao',ll);

end

