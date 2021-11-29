function [] = openbuncherllrfloop
% Open the buncher llrf amplitude and phase loop
% Syntax:[] = closebuncherllrfloop

%Calculates RF ampl and phase for the llrf value

Rei=getpv('L1llrf:set_iloop_re_ao');
Imi=getpv('L1llrf:set_iloop_im_ao');
if Rei==0
    if Imi>0
        Phase1=pi/2;
    else
        Phase1=3*pi/2;
    end
else
    if Imi>=0
        if Rei>0
            Phase1=atan(Imi/Rei);
        else
            Phase1=atan(Imi/Rei)+pi;
        end
    else
        if Rei>0
            Phase1=atan(Imi/Rei)+2*pi;
        else
            Phase1=atan(Imi/Rei)+pi;
        end
    end
end
Phase1;
Amp=sqrt(Rei^2+Imi^2);

Reigui=getpv('L1llrf:source_re_ao');
Imigui=getpv('L1llrf:source_im_ao');
Ampgui=sqrt(Reigui^2+Imigui^2);

Phase_rad=Phase1-pi/2;
if Phase_rad<2*pi
    Phase_rad=Phase_rad+2*pi;
end
AmpComplex=Ampgui*exp(1i*Phase_rad);
Ref=real(AmpComplex);
Imf=imag(AmpComplex);

% !python /remote/apex/acct/ghuang/git/software_firmware//projects/apex/open_loop_para.py L1llrf
!python /home/physics/apexgun/open_loop_para.py L1llrf

setpv('L1llrf:source_re_ao',Ref)
setpv('L1llrf:source_im_ao',Imf)

 

end

