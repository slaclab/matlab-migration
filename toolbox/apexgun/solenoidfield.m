function [ Bfield ] = solenoidfield(SolenoidID,z,I)
% Calculate the solenoidal field for APEX Solenoids. 
% Return Bfield in T at position z in m when a current I in A is applied to the solenoid.
% The center of the solenoid is located at z=0
% SINTAX: solenoidfield(Solenoid ID, longitudinal position in m, PS current in A)
% If SolenoidID is different from 0,1,2,3 it assumes ID= 1
% SolenoidID=0 refers to the Bucking coil. 
% REMARK: for the Bucking coil case, z=0 gives the field at the cathode plane.

if SolenoidID==0
    %Bucking Coil
    R1=0.032447;%Radius of aircoil first solenoid in m
    R2=0.032447;%Radius of aircoil second solenoid in m
    L1=0.047243;% Half length aircoil first solenoid in m
    L2=0.047243;% Half length aircoil second solenoid in m
    Ifct=192.352/2.;
    d1=0.062274;%displacement of aircoil first solenoid in m
    d2=0.062274;%displacement of aircoil second solenoid in m 
elseif SolenoidID==2
    %Solenoid 2
    R1=0.01451;%Radius of aircoil first solenoid in m
    R2=0.029052;%Radius of aircoil second solenoid in m
    L1=0.10808;% Half length aircoil first solenoid in m
    L2=0.081847;% Half length aircoil second solenoid in m
    Ifct=706.67;
    d1=-.003437;%displacement of aircoil first solenoid in m
    d2=-.0025476;%displacement of aircoil second solenoid in m
elseif SolenoidID==3
    %Solenoid 3
    R1=0.01331;%Radius of aircoil first solenoid in m
    R2=0.026767;%Radius of aircoil second solenoid in m
    L1=0.10351;% Half length aircoil first solenoid in m
    L2=0.07822;% Half length aircoil second solenoid in m
    Ifct=608.81;
    d1=-.001893;%displacement of aircoil first solenoid in m
    d2=-0.0012917;%displacement of aircoil second solenoid in m
else
    if SolenoidID~=1
        ['WARNING: wrong solenoid ID. Assumed Solenoid 1']
    end
    % Solenoid 1
    % Fit parameters from measurements of Solenoid 1 (D. Arbelaez EN Note
    % FL0102-10644A, Sept1, 2011).
    R1=0.013674;%Radius of aircoil first solenoid in m
    R2=0.027198;%Radius of aircoil second solenoid in m
    L1=0.10732;% Half length aircoil first solenoid in m
    L2=0.081126;% Half length aircoil second solenoid in m
    Ifct=653.7;
    d1=0;%displacement of aircoil first solenoid in m
    d2=0.0012136;%displacement of aircoil second solenoid in m
    % Current calibration factor from Solenoid 1 measurements (D. Arbelaez EN 
    % Note FL0102-10644A, Sept1, 2011).
end

Size_z=size(z);
Size_I=size(I);

if Size_z==Size_I
    if Size_z(2)>1
        for ii=1:1:Size_z(2)
            zz=z(ii);
            Ic=I(ii)*Ifct;
            Bfield(ii)=4*pi*10^-7*Ic/4.*(((zz+d1)/L1+1)/sqrt(R1^2+(L1+zz+d1)^2)- ...
            ((zz+d1)/L1-1)/sqrt(R1^2+(L1-zz-d1)^2)+((zz+d2)/L2+1)/sqrt(R2^2+ ...
            (L2+zz+d2)^2)-((zz+d2)/L2-1)/sqrt(R2^2+(L2-zz-d2)^2));
        end
    else
        zz=z;
        Ic=I*Ifct;
        Bfield=4*pi*10^-7*Ic/4.*(((zz+d1)/L1+1)/sqrt(R1^2+(L1+zz+d1)^2)- ...
        ((zz+d1)/L1-1)/sqrt(R1^2+(L1-zz-d1)^2)+((zz+d2)/L2+1)/sqrt(R2^2+ ...
        (L2+zz+d2)^2)-((zz+d2)/L2-1)/sqrt(R2^2+(L2-zz-d2)^2));
    end
else
    if Size_I==[1 1]
        for ii=1:1:Size_z(2)
            zz=z(ii);
            Ic=I*Ifct;
            Bfield(ii)=4*pi*10^-7*Ic/4.*(((zz+d1)/L1+1)/sqrt(R1^2+(L1+zz+d1)^2)- ...
            ((zz+d1)/L1-1)/sqrt(R1^2+(L1-zz-d1)^2)+((zz+d2)/L2+1)/sqrt(R2^2+ ...
            (L2+zz+d2)^2)-((zz+d2)/L2-1)/sqrt(R2^2+(L2-zz-d2)^2));
        end
    else 
        ['ERROR: Input variables have different sizes']
        Bfield=NaN;
    end
end
end

