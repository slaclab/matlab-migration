function [ Bfield_T ] = correctorfield(CorrectorID,HorVertFlag,z,I)
% Calculate the Corrector field for APEX Solenoids. 
% Return Bfield in T at position z in m when a current I in A is applied to the corrector.
% The center of the corrector is located at z=0
% Sintax: correctorfield(corrector ID, Hor. or vert. flag, long. posit. in m, PS current in A)
%HorVrtFlag: 0= horizontal corrector; 1= vertical corrector
% If Corrector ID is different from 1,2,3,4,5,6 it assumes ID= 0

if CorrectorID==1
    %Corrector 1 *******Calibrations to be updated********
    if HorVertFlag==1 %vertical corrector
        L1=0.016477;% Half length aircoil first solenoid in m
        L2=0.0064138;% Half length aircoil second solenoid in m
        R1=0.21453;%Radius of aircoil first solenoid in m
        R2=0.080277;%Radius of aircoil second solenoid in m
        CalFct=1;%current calibration factor
        Im=2010.0/4.231;%Upper hysteresis curve linear fit slope
        Iq=0;%Upper hysteresis curve linear fit intercept
    else %horizontal corrector
        if HorVertFlag~=0
            ['WARNING: wrong hor/vert Flag ID. Assumed horizontal']
        end
        L1=0.025649;% Half length aircoil first solenoid in m
        L2=0.010069;% Half length aircoil second solenoid in m
        R1=0.26819;%Radius of aircoil first solenoid in m
        R2=0.084751;%Radius of aircoil second solenoid in m
        CalFct=4.78188/1.0405127e-9*1e-4;%current calibration factor
        Im=8.649e-4*CalFct;%Upper hysteresis curve linear fit slope in iterval +/- 1.288 A for a +/- 4.228 A cycle
        Iq=3.932e-4*CalFct;%Upper hysteresis curve linear fit intercept
    end
elseif CorrectorID==2
    %Corrector 2
    if HorVertFlag==1 %vertical corrector
        L1=0.016477;% Half length aircoil first solenoid in m
        L2=0.0064138;% Half length aircoil second solenoid in m
        R1=0.21453;%Radius of aircoil first solenoid in m
        R2=0.080277;%Radius of aircoil second solenoid in m
        CalFct=1;%current calibration factor
        Im=2010.0/4.231;%Upper hysteresis curve linear fit slope
        Iq=0;%Upper hysteresis curve linear fit intercept
    else %horizontal corrector
        if HorVertFlag~=0
            ['WARNING: wrong hor/vert Flag ID. Assumed horizontal']
        end
        L1=0.025649;% Half length aircoil first solenoid in m
        L2=0.010069;% Half length aircoil second solenoid in m
        R1=0.26819;%Radius of aircoil first solenoid in m
        R2=0.084751;%Radius of aircoil second solenoid in m
        CalFct=4.78188/1.0405127e-9*1e-4;%current calibration factor
        Im=8.649e-4*CalFct;%Upper hysteresis curve linear fit slope in iterval +/- 1.288 A for a +/- 4.228 A cycle
        Iq=3.932e-4*CalFct;%Upper hysteresis curve linear fit intercept
    end
elseif CorrectorID==3
    %Correcotor 3
    if HorVertFlag==1 %vertical corrector
        L1=0.013501;% Half length aircoil first solenoid in m
        L2=0.0042424;% Half length aircoil second solenoid in m
        R1=0.32069;%Radius of aircoil first solenoid in m
        R2=0.0859;%Radius of aircoil second solenoid in m
        CalFct=1;%current calibration factor
        Im=3770.0/4.231;%Upper hysteresis curve linear fit slope
        Iq=0;%Upper hysteresis curve linear fit intercept
    else %horizontal corrector
        if HorVertFlag~=0
            ['WARNING: wrong hor/vert Flag ID. Assumed horizontal']
        end
        L1=0.016389;% Half length aircoil first solenoid in m
        L2=0.0064622;% Half length aircoil second solenoid in m
        R1=0.28387;%Radius of aircoil first solenoid in m
        R2=0.086647;%Radius of aircoil second solenoid in m
        CalFct=1;%current calibration factor
        Im=2350.3/4.231;%Upper hysteresis curve linear fit slope
        Iq=0;%Upper hysteresis curve linear fit intercept
    end
elseif CorrectorID==4
    %Corrector 4
    if HorVertFlag==1 %vertical corrector
        L1=0.010411;% Half length aircoil first solenoid in m
        L2=0.0039119;% Half length aircoil second solenoid in m
        R1=0.30349;%Radius of aircoil first solenoid in m
        R2=0.087756;%Radius of aircoil second solenoid in m
        CalFct=1;%current calibration factor
        Im=4300.0/4.231;%Upper hysteresis curve linear fit slope
        Iq=0;%Upper hysteresis curve linear fit intercept
    else %horizontal corrector
        if HorVertFlag~=0
            ['WARNING: wrong hor/vert Flag ID. Assumed horizontal']
        end
        L1=0.0097831;% Half length aircoil first solenoid in m
        L2=0.0039632;% Half length aircoil second solenoid in m
        R1=0.27768;%Radius of aircoil first solenoid in m
        R2=0.087103;%Radius of aircoil second solenoid in m
        CalFct=1;%current calibration factor
        Im=3910.0/4.231;%Upper hysteresis curve linear fit slope
        Iq=0;%Upper hysteresis curve linear fit intercept
    end
elseif CorrectorID==5
    %Corrector 5 *******Calibrations to be updated********
    if HorVertFlag==1 %vertical corrector
        L1=0.010411;% Half length aircoil first solenoid in m
        L2=0.0039119;% Half length aircoil second solenoid in m
        R1=0.30349;%Radius of aircoil first solenoid in m
        R2=0.087756;%Radius of aircoil second solenoid in m
        CalFct=1;%current calibration factor
        Im=4300.0/4.231;%Upper hysteresis curve linear fit slope
        Iq=0;%Upper hysteresis curve linear fit intercept
    else %horizontal corrector
        if HorVertFlag~=0
            ['WARNING: wrong hor/vert Flag ID. Assumed horizontal']
        end
        L1=0.0097831;% Half length aircoil first solenoid in m
        L2=0.0039632;% Half length aircoil second solenoid in m
        R1=0.27768;%Radius of aircoil first solenoid in m
        R2=0.087103;%Radius of aircoil second solenoid in m
        CalFct=1;%current calibration factor
        Im=3910.0/4.231;%Upper hysteresis curve linear fit slope
        Iq=0;%Upper hysteresis curve linear fit intercept
    end
elseif CorrectorID==6
    %Corrector 6 *******Calibrations to be updated********
    if HorVertFlag==1 %vertical corrector
        L1=0.010411;% Half length aircoil first solenoid in m
        L2=0.0039119;% Half length aircoil second solenoid in m
        R1=0.30349;%Radius of aircoil first solenoid in m
        R2=0.087756;%Radius of aircoil second solenoid in m
        CalFct=1;%current calibration factor
        Im=4300.0/4.231;%Upper hysteresis curve linear fit slope
        Iq=0;%Upper hysteresis curve linear fit intercept
    else %horizontal corrector
        if HorVertFlag~=0
            ['WARNING: wrong hor/vert Flag ID. Assumed horizontal']
        end
        L1=0.0097831;% Half length aircoil first solenoid in m
        L2=0.0039632;% Half length aircoil second solenoid in m
        R1=0.27768;%Radius of aircoil first solenoid in m
        R2=0.087103;%Radius of aircoil second solenoid in m
        CalFct=1;%current calibration factor
        Im=3910.0/4.231;%Upper hysteresis curve linear fit slope
        Iq=0;%Upper hysteresis curve linear fit intercept
    end
else
    if CorrectorID~=0
        ['WARNING: wrong corrector ID. Assumed Corrector 0']
        CorrectorID=0;
    end
    % Corrector 0 (Air Coil)
    % Fit parameters from measurements of Corrector 1 (J. Doyle EN Note
    % XXXX-XXXX, March, 2013).
    if HorVertFlag==1 %vertical corrector
        L1=0.027059;% Half length aircoil first solenoid in m
        R1=0.033373;%Radius of aircoil first solenoid in m
        CalFct=1;%current calibration factor
        Im=8.1498;%Upper hysteresis curve linear fit slope
        Iq=0;%Upper hysteresis curve linear fit intercept
    else %horizontal corrector
        if HorVertFlag~=0
            ['WARNING: wrong hor/vert Flag ID. Assumed horizontal']
        end
        L1=0.027066;% Half length aircoil first solenoid in m
        R1=0.031734;%Radius of aircoil first solenoid in m
        CalFct=1;%current calibration factor
        Im=8.0788;%Upper hysteresis curve linear fit slope
        Iq=0;%Upper hysteresis curve linear fit intercept
    end
end

Size_z=size(z);
Size_I=size(I);

if Size_z==Size_I
    if Size_z(2)>1
        for ii=1:1:Size_z(2)
            zz=z(ii);
            Ic=I(ii)*Im+Iq;
            if CorrectorID==0
                Bfield_T(ii)=calc_corr1_field(Ic,zz,R1,L1);
            else
                Bfield_T(ii)=calc_corr_field(Ic,zz,R1,R2,L1,L2);
            end                
        end
    else
        zz=z;
        Ic=I*Im+Iq;
        if CorrectorID==0
            Bfield_T=calc_corr1_field(Ic,zz,R1,L1);
        else
            Bfield_T=calc_corr_field(Ic,zz,R1,R2,L1,L2);
        end                
    end
else
    if Size_I==[1 1]
        for ii=1:1:Size_z(2)
            zz=z(ii);
            Ic=I*Im+Iq;
            if CorrectorID==0
                Bfield_T(ii)=calc_corr1_field(Ic,zz,R1,L1);
            else
                Bfield_T(ii)=calc_corr_field(Ic,zz,R1,R2,L1,L2);
            end                
        end
    else
        if Size_z==[1 1]
            for ii=1:1:Size_I(2)
                Ih=I(ii);
                zz=z;
                Ic=Ih*Im+Iq;
                if CorrectorID==0
                    Bfield_T(ii)=calc_corr1_field(Ic,zz,R1,L1);
                else
                    Bfield_T(ii)=calc_corr_field(Ic,zz,R1,R2,L1,L2);
                end
            end
        else
            ['ERROR: Input variables have different sizes']
            Bfield_T=NaN;
        end
    end
end
end

function [Bf] = calc_corr1_field(Ic,zz,R1,L1)

Bf=4*pi*10^(-7)*Ic/4./R1*( 2*(zz+L1)/sqrt(R1^2+(L1+zz)^2)- ...
   2*(zz-L1)/sqrt(R1^2+(L1-zz)^2)-(zz+L1)^3/((R1^2+(zz+L1)^2)^1.5)+ ...
   (zz-L1)^3/((R1^2+(zz-L1)^2)^1.5) );

end

function [Bf] = calc_corr_field(Ic,zz,R1,R2,L1,L2)

Bf=4*pi*10^(-7)*Ic/4./R1*( 2*(zz+L1)/sqrt(R1^2+(L1+zz)^2)- ...
   2*(zz-L1)/sqrt(R1^2+(L1-zz)^2)-(zz+L1)^3/((R1^2+(zz+L1)^2)^1.5)+ ...
   (zz-L1)^3/((R1^2+(zz-L1)^2)^1.5) ) + 4*pi*10^(-7)*Ic/4./R2*( 2*(zz+L2)/ ...
   sqrt(R2^2+(L2+zz)^2)-2*(zz-L2)/sqrt(R2^2+(L2-zz)^2)-(zz+L2)^3/ ...
   ((R2^2+(zz+L2)^2)^1.5)+(zz-L2)^3/((R2^2+(zz-L2)^2)^1.5) );

end

