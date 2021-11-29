function [ Bfield_T ] = spectrometerfield(z,I)
% Calculate the field for the APEX Spectrometer Magnet along the nominal trajectory. 
% Return Bfield in T at position z in m when a current I in A is applied to the corrector.
% The center of the dipole is located at z=0
% Sintax: [ Bfield_T ] = spectrometerfield(z,I)
% Based on J. Doyle December 2012 measurements

F=110.5586;%current calibration factor
R(1)=0.059608;%Radius of first aircoil in m
L(1)=0.28546;% Half length first aircoil in m
A(1)=1.3106;% Coil 1 amplitude factor 
R(2)=0.026248;%Radius of second aircoil in m
L(2)=0.25131;% Half length of second aircoil in m
A(2)=1;% Coil 2 amplitude factor
R(3)=0.16939;% Radius of third aircoil in m
L(3)=0.29994;% Half length of third aircoil in m
A(3)=2.567;% Coil 3 amplitude factor

Br=26.276e-4;% Residual Field in Tesla

Size_z=size(z);
Size_I=size(I);

if Size_z==Size_I
    if Size_z(2)>1
        for ii=1:1:Size_z(2)
            zz=z(ii);
            Ic=I(ii);
            Bfield_T(ii)=calc_spectr_field(Ic,zz,R,L,A,F,Br);
        end
    else
        zz=z;
        Ic=I;
        Bfield_T=calc_spectr_field(Ic,zz,R,L,A,F,Br);
    end
else
    if Size_I==[1 1]
        for ii=1:1:Size_z(2)
            zz=z(ii);
            Ic=I;
            Bfield_T(ii)=calc_spectr_field(Ic,zz,R,L,A,F,Br);
        end
    else
        if Size_z==[1 1]
            for ii=1:1:Size_I(2)
                Ih=I(ii);
                zz=z;
                Ic=Ih;
            Bfield_T(ii)=calc_spectr_field(Ic,zz,R,L,A,F,Br);
            end
        else
            ['ERROR: Input variables have different sizes']
            Bfield_T=NaN;
        end
    end
end
end

function [Bf] = calc_spectr_field(Ic,zz,R,L,A,F,Br)

Hlp=0;
for jj=1:3
    H1=2*(zz+L(jj))/sqrt(R(jj)^2+(zz+L(jj))^2);
    H2=2*(zz-L(jj))/sqrt(R(jj)^2+(zz-L(jj))^2);
    H3=(zz+L(jj))^3/(R(jj)^2+(zz+L(jj))^2)^(3/2);
    H4=(zz-L(jj))^3/(R(jj)^2+(zz-L(jj))^2)^(3/2);
    
    Hlp=Hlp+A(jj)/R(jj)*(H1-H2-H3+H4);
end
Bf=Ic*4e-7*pi*F/4.*Hlp+Br;

end

