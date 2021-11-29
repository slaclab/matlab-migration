function [ HorDeflection_m, VertDeflection_m RotationAngle_deg] = emittancemeterbumpdeflection( SlitID, BumpType, Curr_A, BeamEnergy_MeV)
%Calculate the bunch horizontal and vertical deflections in m and the coil rotation angle in deg for the emittance meter bump magnets
%Sintax: [ HorDeflection_m, VertDeflection_m RotationAngle_deg] = emittancemeterbumpdeflection( SlitID, BumpType, Curr_A, BeamEnergy_MeV)
%SlitID: 1 for slit 1 and 2 for slit 2
%BumpType: 0 for horizontal; 1 for vertical
%Curr_A: the current in A applied to the bump magnets
%BeamEnergy_keV: beam energy in MeV
%FS May 22, 2014

Slit1_px_microns=34.5;% Feb 23, 2105
Slit2_px_microns=21.0;% Feb 23, 2105

if SlitID==1
    %Slit 1 bump
    if BumpType==0;% Hor. Bump
        mh=-10.905;%Fit coefficients at 780 keV in px/A
        mv=0.75757;%Fit coefficients at 780 keV in px/A
    elseif BumpType==1;% Vert. Bump
        mh=-1.4189;%Fit coefficients at 780 keV in px/A
        mv=-10.559;%Fit coefficients at 780 keV in px/A
    else    
        ['ERROR: wrong bump type. 0 for hor., 1 for vert.']
        HorDeflection_m=NaN;
        VertDeflection_m=NaN;
        RotationAngle_deg=NaN;
        return
    end
    SlitCal=Slit1_px_microns;
elseif SlitID==2
    %Slit 2 Bump
    if BumpType==0;% Hor. Bump
        mh=-16.435;%Fit coefficients at 780 keV in px/A
        mv=2.7899;%Fit coefficients at 780 keV in px/A
    elseif BumpType==1;% Vert. Bump
        mh=-1.4325;%Fit coefficients at 780 keV in px/A
        mv=-16.356;%Fit coefficients at 780 keV in px/A
    else    
        ['ERROR: wrong bump type. 0 for hor., 1 for vert.']
        HorDeflection_m=NaN;
        RotationAngle_deg=NaN;
        VertDeflection_m=NaN;
        return
    end
    SlitCal=Slit2_px_microns;
else
        ['ERROR: wrong slit ID. only 0 or 1 values allowed']
        HorDeflection_m=NaN;
        RotationAngle_deg=NaN;
        VertDeflection_m=NaN;
        return

end

Dx780_px=mh*Curr_A;
Dy780_px=mv*Curr_A;

betagamma780=sqrt((1+1.957*0.78)^2-1);
betagamma=sqrt((1+1.957*BeamEnergy_MeV)^2-1);

Dx_px=Dx780_px*betagamma780/betagamma;
Dy_px=Dy780_px*betagamma780/betagamma;

if Dy_px>Dx_px
    RotationAngle_deg=atan(Dx_px/Dy_px)/pi*180;
else
    RotationAngle_deg=atan(Dy_px/Dx_px)/pi*180;
end

HorDeflection_m=Dx_px*SlitCal*1e-6;
VertDeflection_m=Dy_px*SlitCal*1e-6;


end

