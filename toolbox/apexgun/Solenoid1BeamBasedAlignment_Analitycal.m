function [Dx_m,Dy_m,Dxp_rad,Dyp_rad] = Solenoid1BeamBasedAlignment_Analitycal(Iinit_A,Ifinal_A, Energy_MeV)
% Calculate sol1 spatial and angular misalignment in m and rad
%SYNTAX:[Dx_m,Dy_m,Dxp_rad,Dyp_rad] = Solenoid1BeamBasedAlignment_Analitycal(Iinit_A,Ifinal_A, Energy_MeV)
%where Iinit_A is the initial sol1 current in A; Ifinal_A is the final in A;
%Energy_MeV is the beam energy in MeV.
% FS July 9, 2015.
%****TO BE DEBUGGED!!!*******

pixelsize=19.8e-6;%scam1 pixel size in m (April 3, 2015 calibration)

mm=9.1095e-31;
clight=2.9979e8;
ee=1.6022e-19;

if abs(Iinit_A)>10
    Iinit_A=10*Iinit_A/abs(Iinit_A);
    ['Initial current set to ', num2str(Iinit_A),' A']
end
if abs(Ifinal_A)>10
    Ifinal_A=10*Ifinal_A/abs(Ifinal_A);
    ['Final current set to ', num2str(Ifinal_A),' A']
end

Energy_MeV=abs(Energy_MeV);

DD=1.463689-0.305729;% Sol1 center to Screen1 distance; From April 21, 2015 APEX Phase-II lattice
[ trash1, trash2, Leff, B_HE_coeff]=solenoidproperties(1,1,1);%Sol1 effective length
gamma=1+1.957*Energy_MeV;
betagamma=sqrt(gamma^2-1);
Brho=betagamma*mm*clight/ee;

%measure centroid position on screen1
I0=getpv('Sol1:Setpoint');
Navg=10;
Istep_A=(Ifinal_A-Iinit_A)/2.;
CamSelector=1;% selects scam1 camera
for ii=1:3
    ['Reading centroid position on scam1. Step ',num2str(ii),' of 3']
    Iact=Iinit_A+(ii-1)*Istep_A;
    setpvonline('Sol1:Setpoint', Iact,'float',1);
    pause(1);
    [ww(ii), ww(ii+3), sigxc ,sigyc]=readcentroidposition(CamSelector,Navg);
    Irdbck(ii)=getpv('Sol1:Setpoint');
end
setpvonline('Sol1:Setpoint', I0,'float',1);% restore sol1 to initial value

%calculate 6-variable system coefficients
for ii=1:3
    ['Calculating system coefficients. Step ',num2str(ii),' of 3']

    Iact=Irdbck(ii);
    BBact=solenoidfield(1,0,Iact);
    BB=BBact*B_HE_coeff;
    theta=BB*Leff/Brho;
    CC=cos(theta/2.);
    SS=sin(theta/2.);
    alpha=BB/2./Brho;
    
    aa(ii,1)=CC^2-CC*SS*alpha*DD;
    aa(ii,2)=CC*SS/alpha+CC^2*DD;
    aa(ii,3)=CC*SS-SS^2*alpha*DD;
    aa(ii,4)=SS^2/alpha+CC*SS*DD;
    aa(ii,5)=-1.;
    aa(ii,6)=0;
    
    aa(ii+3,1)=-aa(ii,3);
    aa(ii+3,2)=-aa(ii,4);
    aa(ii+3,3)=aa(ii,1);
    aa(ii+3,4)=aa(ii,2);
    aa(ii+3,5)=0;
    aa(ii+3,6)=-1.;
end
xx=linsolve(aa,ww');
Dx_px=xx(1);
Dx_m=Dx_px*pixelsize
Dxp_rad=xx(2)
Dy_px=xx(3);
Dy_m=Dy_px*pixelsize
Dyp_rad=xx(4)
Xc_px=xx(5);
Yc_px=xx(6);
end

