function [] = closegunllrfloop
% Close the gun llrf amplitude and phase loop
% Syntax:[] = closegunllrfloop

['****Please answer to the WARNING window questions.****']

prompt = {'MatLab gun Amp. Feedback is OFF?                       .','Gun llrf amp/phase feedback initialized? '};
dlg_title = '*****WARNING******';
num_lines = 1;
def = {'Y','N'};
options.Resize='on';
answer = inputdlg(prompt,dlg_title,num_lines,def,options);
MatFeedFlag=answer{1}; 
InitFlag=answer{2}; 

if MatFeedFlag~='Y'
    ['WARNING: Turn OFF MatLab Amplitude Feedback.']
    return
end

if InitFlag~='Y'
    setgunllrfamppahseloopparameters
end

%Calculates RF ampl and phase for the llrf gui value
Reigui=getpv('llrf1:source_re_ao');
Imigui=getpv('llrf1:source_im_ao');

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

%!python /remote/apex/acct/ghuang/git/software_firmware//projects/apex/close_loop.py
!python /home/physics/apexgun/close_loop.py

%Set phase for the LLRF amp/phase loop
Rei=getpv('llrf1:set_iloop_re_ao');
Imi=getpv('llrf1:set_iloop_im_ao');

Amp=sqrt(Rei^2+Imi^2);
Phase_rad=Phase1gui+pi/2;
if Phase_rad>2*pi
    Phase_rad=Phase_rad-2*pi;
end
AmpComplex=Amp*exp(1i*Phase_rad);
Ref=real(AmpComplex);
Imf=imag(AmpComplex);

setpv('llrf1:set_iloop_re_ao',Ref)
setpv('llrf1:set_iloop_im_ao',Imf)

 

end

