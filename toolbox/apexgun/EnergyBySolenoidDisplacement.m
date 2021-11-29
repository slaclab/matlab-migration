function [ Ek_eV, sigEk_eV] = EnergyBySolenoidDisplacement( Max_Dw_mm, Nsteps, horvertFlag)
%Perform a beam energy measurement in eV and related rms error by translating SOL1 and measuring the
%beam centroid motion on SCAM1.
%Syntax:[ Ek_eV sigEk_eV ] = EnergyBySolenoidDisplacement( Max_Dw_mm, Nsteps, horvertFlag)
%where Max_Dw_mm defines the maximum translation for SOL1 in mm; 
%Nsteps indicates the number of translation steps from 0 to Max_Dw_mm
%horvertFlag selects the translation plane (0 = horizontal; 1 = vertical)
%FS. February 15, 2016


me=9.1095*10^(-31);
qe=1.6022*10^(-19);
cc=2.9979*10^8;

solsettlingtime_s=3;% solenoid motor settling time in seconds
Navg=3;% number of averages for centroid position measurement
SolPosAccuracy=0.001; %Solenoid position accuracy in mm
CamSelector=1;%Select SCam1 CCD
ZeroFinderAccuracy=1e-10;% Absolute accuracy in finding trascendent function zeros
DSS=1.157961;% Length of drift in m from solenoid center and First screen
jumpflag=1;% for values other than 0 skip solenoid motion and uses the hardwared values for the calculation (for debugging)
if jumpflag~=0
    IS=4.25;% Set solenoid 1 current in A (for no solenoid motion - debugging purpose)
else
    IS=getpv('Sol1:Setpoint');% Read solenoid 1 current in A
end

    

BBact=solenoidfield(1,0,IS);% Calculate solenoid 1 peak field
[junk, junk, LS, B_HD_coeff]=solenoidproperties(1,IS,0.75);% Calculate Sol1 effective length in m
DD=DSS-LS/2;% Distance between sol1 downstream edge and an screen 1
BB=BBact*B_HD_coeff;% calculate the effective B field for the solenoid Hard Edge model

if horvertFlag==0
    ['Horizontal displacement selected']
    horvstr='horizontal';
else
    horvertFlag=1;
	horvstr='vertical';
    ['Vertical displacement selected']
end

dx_limit_mm=5.;% Max solenoid displacement
dx_limit_mm=abs(dx_limit_mm);
if abs(Max_Dw_mm)> dx_limit_mm
    Max_Dw_mm=Max_Dw_mm/abs(Max_Dw_mm)*dx_limit_mm;
	['WARNING:Max solenoid displacement set to :',num2str(Max_Dw_mm),' mm in the ',horvstr,' plane']

else
    ['Max solenoid displacement is :',num2str(Max_Dw_mm),' mm in the ',horvstr,' plane']
end

if jumpflag==0
    Nsteps=floor(abs(Nsteps));
    ['Number of steps :',num2str(Nsteps)]

    motorset{1}='Sol1:M1:PCMD';
    motorread{1}='Sol1:M1:PNOW';
    motorset{2}='Sol1:M2:PCMD';
    motorread{2}='Sol1:M2:PNOW';
    motorset{3}='Sol1:M3:PCMD';
    motorread{3}='Sol1:M3:PNOW';
    motorset{4}='Sol1:M4:PCMD';
    motorread{4}='Sol1:M4:PNOW';
    motorset{5}='Sol1:M5:PCMD';
    motorread{5}='Sol1:M5:PNOW';

    % Check solenoid actuators initial position and status
    for ii=1:5
        MotPos0(ii)=getpv(motorread{ii});
        MotSet0(ii)=getpv(motorset{ii});
        if abs(MotPos0(ii)-MotSet0(ii))<SolPosAccuracy
            ['Motor ',num2str(ii),' initial position is ',num2str(MotPos0(ii)),' mm'] 
        else
            ['ERROR. Check motor ', num2str(ii),' status']
            return
        end
    end

    % Check solenoid power supply initial current and status
    SolCurr0_A=getpv('Sol1:Setpoint');

    if SolCurr0_A==0
        SolCurr0_A=-0.0009;
    end

    SolCurrRB0_A=getpv('Sol1:CurrentRBV');
    accSol=0.01;
    SolRelError=abs((SolCurr0_A-SolCurrRB0_A)/SolCurr0_A);
    if SolRelError>accSol
        ['ERROR. Current mismatch. Check solenoid 1 PS status']
        return
    end

    %**** Start main cycle *****
    dw=Max_Dw_mm/Nsteps
    for ii=1:Nsteps

        %Set motors at initial position
        for jj=1:5
            setpvonline(motorset{jj},MotSet0(jj),'float',1);%move actuators
        end
        pause(solsettlingtime_s)

        %Check solenoid motor position
        for jj=1:5
            posi(jj)=getpvonline(motorread{jj});
            if abs(MotSet0(jj)-posi(jj))<SolPosAccuracy
            else
                ['ERROR. Check motor ', num2str(jj),' status']
                return
            end
        end

        %read initial beam centroid position
        [xi, yi, sigxi, sigyi]=readcentroidposition(CamSelector,Navg);

        % prepare to move solenoid
        if horvertFlag==0
            setposf(1)=MotSet0(1);
            setposf(2)=MotSet0(2);
            setposf(3)=MotSet0(3);
            setposf(4)=MotSet0(4)+ii*dw;
            setposf(5)=MotSet0(5)+ii*dw;
        else
            setposf(1)=MotSet0(1)+ii*dw;
            setposf(2)=MotSet0(2)+ii*dw;
            setposf(3)=MotSet0(3)+ii*dw;
            setposf(4)=MotSet0(4);
            setposf(5)=MotSet0(5);
        end

        % move solenoid
        for jj=1:5
            setpvonline(motorset{jj},setposf(jj),'float',1);
        end
        pause(solsettlingtime_s)

        % check solenoid position
        for jj=1:5
            posf(jj)=getpvonline(motorread{jj});
            if abs(setposf(jj)-posf(jj))<SolPosAccuracy
            else
                ['ERROR. Check motor ', num2str(jj),' status']
                return
            end
        end

        %read beam centroid position after solenoid motion
        [xf, yf, sigxf, sigyf]=readcentroidposition(CamSelector,Navg);

        % Calculate beam centroid displacement and rms errors
        Dy(ii)=yf-yi;
        Dx(ii)=xf-xi;
        sigDy(ii)=sqrt(sigxi^2+sigyi^2+sigxf^2+sigyf^2);
    end

    % Calculate average and standard deviation
    DyDxavg=0;
    DyDx2=0;
    for ii=1:Nsteps
        DyDxavg=DyDxavg+Dy(ii)/Dx(ii);
        DyDx2=DyDx2+(Dy(ii)/Dx(ii))^2;
    end
    DyDxavg=DyDxavg/Nsteps;
    DyDx2=DyDx2/Nsteps;
    DyDxsig=sqrt(DyDx2-DyDxavg^2);
else
    if horvertFlag==0
        D(1)=-1.0416;%Horizontal displacement (0.2 mm step 5 steps) measurement done with IS=4.25 A
        D(2)=-.9874;
        D(3)=-.9530;
        D(4)=-1.013;
        D(5)=-.9631;
    else
        D(1)=1.1147;%Vertical displacement (0.2 mm step 5 steps)measurement done with IS=4.25 A
        D(2)=1.0300;
        D(3)=0.9657;
        D(4)=1.1302;
        D(5)=1.2547;
    end
    DyDxavg=0;
    DyDx2=0;
    for kk=1:5
        DyDxavg=DyDxavg+D(kk)/5;
        DyDx2=DyDx2+(D(kk)^2)/5;
    end
end
DyDxavg
DyDxsig=sqrt(DyDx2-DyDxavg^2)

RR=DD/LS;
sigRR=abs(2e-3*RR);
sigBL=abs(2e-3*BB*LS);

% Calculate rotation angle,beam energy and related rms errors
if horvertFlag==0
    mPoint=-DyDxavg/RR;
    if mPoint>0
        fct=1.01;
    else
        fct=0.99;
    end
else
    mPoint=1/DyDxavg/RR;
    if mPoint>0
        fct=1.01;
    else
        fct=0.99;
    end
end

zi=-pi/2*.99;
zf=mPoint/fct;
z01=FindZerosForEnerBySolDispl(RR,DyDxavg,zi,zf,ZeroFinderAccuracy,horvertFlag);
zi=mPoint*fct;
zf=pi/2*.99;
z02=FindZerosForEnerBySolDispl(RR,DyDxavg,zi,zf,ZeroFinderAccuracy,horvertFlag);

theta1=2*z01;
theta2=2*z02;

BetaGamma1=abs(qe/me/cc*BB*LS/theta1);
BetaGamma2=abs(qe/me/cc*BB*LS/theta2);
Gamma1=sqrt(1+BetaGamma1^2);
Gamma2=sqrt(1+BetaGamma2^2);
Ek_eV1=me*cc^2*(Gamma1-1)/qe;
Ek_eV2=me*cc^2*(Gamma2-1)/qe;

[ junk,Rot1,junk,junk]=solenoidproperties(1,IS,Ek_eV1*1e-6);
[ junk,Rot2,junk,junk]=solenoidproperties(1,IS,Ek_eV2*1e-6);

delta1=abs(theta1/2-Rot1);
delta2=abs(theta2/2-Rot2);

if delta1>delta2
    z0=z02;
    theta=theta2;
    BetaGamma=BetaGamma2;
    Gamma=Gamma2;
    Ek_eV=Ek_eV2;
else
    z0=z01;
    theta=theta1;
    BetaGamma=BetaGamma1;
    Gamma=Gamma1;
    Ek_eV=Ek_eV1;
end

acc=ZeroFinderAccuracy;
sigff=((DyDxavg^2+1)*(RR+1+RR^2*z0^2)*acc)^2;
sigff=sigff+(z0*(DyDxavg^2+1)*sigRR)^2;
sigff=sigff+((1+RR^2*z0^2)*DyDxsig)^2;
sigff=sqrt(sigff)/(RR*z0+DyDxavg)^2;

sigtheta=2*(RR*z0+DyDxavg)^2/abs((DyDxavg^2+1)*(RR+1+RR^2*z0^2))*sigff;
sigBetaGamma=BetaGamma*sqrt((sigBL/BB/LS)^2+(sigtheta/theta)^2);
sigGamma=sqrt(1-1/Gamma^2)*sigBetaGamma;
sigEk_eV=me*cc^2*sigGamma/qe;

if jumpflag==0% Skips solenoid motion for jumpflag different from 0 (for debugging)
    %Restore motors at initial position
    for jj=1:5
        setpvonline(motorset{jj},MotSet0(jj),'float',1);%move actuators
    end
    pause(solsettlingtime_s)

    %Check actuator position
    for jj=1:5
        posi(jj)=getpvonline(motorread{jj});
        if abs(MotSet0(jj)-posi(jj))<SolPosAccuracy
        else
            ['ERROR. Check motor ', num2str(jj),' status']
            return
        end
    end
end

end


function [ z01] = FindZerosForEnerBySolDispl(RR,DyDxavg,zi,zf, accuracy,hvflag)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

loopflag=1.;
actz1=zi;
actz2=zf;
dz=abs(actz2-actz1);

actz1old=actz1;
actz2old=actz2;

TT1=tan(actz1);
TT2=tan(actz2);
if hvflag==0
    FF1=(1.-RR*DyDxavg*actz1)/(RR*actz1+DyDxavg);
    FF2=(1.-RR*DyDxavg*actz2)/(RR*actz2+DyDxavg);
else
    FF1=-1/((1.-RR*DyDxavg*actz1)/(RR*actz1+DyDxavg));
    FF2=-1/((1.-RR*DyDxavg*actz2)/(RR*actz2+DyDxavg));
end

dist1=TT1-FF1;
sign01=abs(dist1)/dist1;
dist2=TT2-FF2;
sign02=abs(dist2)/dist2;

while loopflag==1.
    TT1=tan(actz1);
    TT2=tan(actz2);
    if hvflag==0
        FF1=(1.-RR*DyDxavg*actz1)/(RR*actz1+DyDxavg);
        FF2=(1.-RR*DyDxavg*actz2)/(RR*actz2+DyDxavg);
    else
        FF1=-1/((1.-RR*DyDxavg*actz1)/(RR*actz1+DyDxavg));
        FF2=-1/((1.-RR*DyDxavg*actz2)/(RR*actz2+DyDxavg));
    end

    dist1=TT1-FF1;
    sign1=abs(dist1)/dist1;
    sign1flag=sign1*sign01;
    
    dist2=TT2-FF2;
    sign2=abs(dist2)/dist2;
    sign2flag=sign2*sign02;

    if sign1flag*sign2flag==1
        if abs(dist2)<abs(dist1)
            actz1old=actz1;
            actz1=actz1+dz/2;
            dz=(actz2-actz1)/2;
        else
            actz2old=actz2;
            actz2=actz2-dz/2;
            dz=(actz2-actz1)/2;
        end
    else
        if sign1flag==-1
            actz1=actz1old;
            actz2=actz2-dz;
            dz=dz/2;
        else
            actz2=actz2old;
            actz1=actz1+dz;
            dz=dz/2;
        end
    end
    if abs(dist1)<accuracy
        z01=actz1;
        loopflag=0;
    end
    if abs(dist2)<accuracy
        z01=actz2;
        loopflag=0;
    end
end
end

