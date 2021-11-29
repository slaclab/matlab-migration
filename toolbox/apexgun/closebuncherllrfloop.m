function [] = closebuncherllrfloop
% Close the buncher llrf amplitude and phase loop
% Syntax:[] = closebuncherllrfloop

%Calculates RF ampl and phase for the llrf gui value
Reigui=getpv('L1llrf:source_re_ao');
Imigui=getpv('L1llrf:source_im_ao');

if Reigui==0
    if Imigui>0
        Phase1gui=pi/2;
    else
        Phase1gui=3*pi/2;
    end
else
    if Imigui>=0
        if Reigui>0
            Phase1gui=atan(Imigui/Reigui);
        else
            Phase1gui=atan(Imigui/Reigui)+pi;
        end
    else
        if Reigui>0
            Phase1gui=atan(Imigui/Reigui)+2*pi;
        else
            Phase1gui=atan(Imigui/Reigui)+pi;
        end
    end
end
Phase1gui;
AmpGui=sqrt(Reigui^2+Imigui^2);

%!python /remote/apex/acct/ghuang/git/software_firmware//projects/apex/close_loop_para.py L1llrf
!python /home/physics/apexgun/close_loop_para.py L1llrf

%Set phase for the LLRF amp/phase loop
Rei=getpv('L1llrf:set_iloop_re_ao');
Imi=getpv('L1llrf:set_iloop_im_ao');

Amp=sqrt(Rei^2+Imi^2);
Phase_rad=Phase1gui+pi/2;
if Phase_rad>2*pi
    Phase_rad=Phase_rad-2*pi;
end
AmpComplex=Amp*exp(1i*Phase_rad);
Ref=real(AmpComplex);
Imf=imag(AmpComplex);

setpv('L1llrf:set_iloop_re_ao',Ref)
setpv('L1llrf:set_iloop_im_ao',Imf)

 

end

