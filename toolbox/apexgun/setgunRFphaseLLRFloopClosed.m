
function [RFphase_out_RFdeg] = setgunRFphaseLLRFloopClosed(RFphase_RFdeg)
% Set the gun RF phase when the LLRF phase/amp loop is closed.
% It also updates the phase value in the llrf.m Matlab GUI
% SINTAX: [RFphase_out_RFdeg] = setgunRFphaseLLRFloopClosed(RFphase_RFdeg)
%Remark: accepts only values between -360 and 360
%

if RFphase_RFdeg<0 
    if RFphase_RFdeg>=-360
        RFphase_RFdeg=360+RFphase_RFdeg;
    else
       ['ERROR: Not allowed phase value. Command ignored!!']
       RFphase_out_RFdeg=NaN;
       return
    end
else
    if RFphase_RFdeg<=360
        RFphase_RFdeg=RFphase_RFdeg;
    else
        ['ERROR: Not allowed phase value. Command ignored!!']
        RFphase_out_RFdeg=NaN;
        return
    end
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
if Phase1gui>2*pi
    Phase1gui=Phase1gui-2*pi
end
if Phase1gui<0
    Phase1gui=Phase1gui+2*pi
end
Phase1gui/pi*180;
Ampgui=sqrt(Reigui^2+Imigui^2);



%Set phase for the LLRF amp/phase loop
Rei=getpv('llrf1:set_iloop_re_ao');
Imi=getpv('llrf1:set_iloop_im_ao');

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
if Phase1>2*pi
    Phase1=Phase1-2*pi
end
if Phase1<0
    Phase1=Phase1+2*pi
end
Phase1/pi*180;
Amp=sqrt(Rei^2+Imi^2);
PhaseGuiCom=Phase1gui+pi/2;
if PhaseGuiCom>2*pi
    PhaseGuiCom=PhaseGuiCom-2*pi;
end
if abs(Phase1-PhaseGuiCom)>0.001
    ['llrf GUI and llrf loop phase mismatch']
    return
end


Phase_rad=RFphase_RFdeg/180*pi+pi/2;
if Phase_rad>2*pi
    Phase_rad=Phase_rad-2*pi;
end
AmpComplex=Amp*exp(1i*Phase_rad);
Ref=real(AmpComplex);
Imf=imag(AmpComplex);

setpvonline('llrf1:set_iloop_re_ao',  Ref,'float',1);
setpvonline('llrf1:set_iloop_im_ao',  Imf,'float',1);

%Set phase for the llrf.m GUI

Phase_radgui=Phase_rad-pi/2;
if Phase_radgui<0
    Phase_radgui=Phase_radgui+2*pi;
end
AmpComplexgui=Ampgui*exp(1i*Phase_radgui);
Refgui=real(AmpComplexgui);
Imfgui=imag(AmpComplexgui);

setpvonline('llrf1:source_re_ao',  Refgui,'float',1);
setpvonline('llrf1:source_im_ao',  Imfgui,'float',1);

RFphase_out_RFdeg=RFphase_RFdeg;

end

