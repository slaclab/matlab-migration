function [ En_eV sEn_eV M A sigR] = energybyspectrometer(I_A,X_m,Y_m, PlotFlag)
%Perform the energy measurement using the spectrometer.
%Sintax: [ En_eV sEn_eV M A sigR] = spectrometer(I_A,X_m,Y_m, PlotFlag)
%I_A, X_m, Y_m are vectors with the dipole current in A, the data point
%hor coordinate in m, and the vert coordinate in m respectively. 
%A PlotFlag different than zero will generate a plot of the results.
%En_eV and sEn_eV are the measured energy and standard deviation in eV,
%M is the fit slope in m/A, A is the fit intercept in m, 
%and sigR is the centroid translation standard deviation used by the fit in m
%(FS - January 29, 2014)
% 

SizeI=size(I_A);    
SizeX=size(X_m);    
SizeY=size(Y_m);  

ErrorFlg=0.;
if SizeI(2)~=SizeX(2) || SizeI(2)~=SizeY(2)
    ErrorFlg=1;
    ['ERROR: Input vectors must have the same size']
end
if SizeI(1)>1 || SizeX(1)>1 || SizeY(1)>1
    ErrorFlg=1;
    ['ERROR: Input quantities must be vectors not matrixes']
end
if SizeI(2)<2
    ErrorFlg=1;
    ['ERROR: Input vectors must have at least 2 components']
end

if ErrorFlg==1
    En_eV=NaN;
    sEn_eV=NaN;
    B0_T=NaN;
    sB0_T=NaN;
end

while ErrorFlg==0
    
    for ii=1:1:SizeI(2) % Calculate Centroid translation
        DeltaR(ii)=sqrt((X_m(ii)-X_m(1))^2+(Y_m(ii)-Y_m(1))^2);
    end

    loopflag=1;
    sigR=1e-3;
    while loopflag==1 % Calculate best fit to data and iterate on fit errors
        [M A sM sA sAM]=linearfit(I_A,DeltaR,sigR,0);
        RFit=M*I_A+A;
        ErFit=abs(DeltaR-RFit);
        if max(ErFit)>1e-15
            RelDelta=(max(ErFit)-sigR)/sigR;
            if abs(RelDelta)>0.01
                sigR=sigR*(1+RelDelta/10.);
            else
                loopflag=0;
            end
        else
            sigR=1e-15;
            loopflag=0;
        end
    end
    
    ee=1.6022e-19;
    mm=9.1095e-31;
    cc=2.9979e8;

    K=52.515e-4; % in T/A
    sK=0.03/sqrt(12)*K; % rms accuracy in corrector field calibration
    D=0.875;% Distance dipole to spectrometer screen in m
    rho=0.5475/(pi/2);% 0.309;% Dipole effective radius in m
    alpha=20.*pi/180.;%Dipole edge angle
    
    GG=1+tan(alpha);    
    En_eV=mm*cc^2/ee*(sqrt(1+(ee/mm/cc*K/M*rho*(GG*D+(1-GG)*rho))^2)-1);
    sEn_eV=ee*rho^2*(GG*D+(1-GG)*rho)^2*K/mm/sqrt(1+(ee/mm/cc*K/M*rho*(GG*D+(1-GG)*rho))^2)/M^2*(sK+abs(K/M)*sM);
    %B0_T=K*A/M;
    %sB0_T=B0_T*(sK/K+sA/A+sM/M);

    [M A sM sA sAM]=linearfit(I_A,DeltaR,sigR,PlotFlag);
    xlabel('\fontsize{12}Spect. Dipole Current [A]')
    ylabel('\fontsize{12}Centroid Displacement [m]')
    title1='\fontsize{13}Spectrometer Beam Energy Measurement.';
    title2='\fontsize{6} ';
    title3=['\fontsize{12}Energy = ',num2str(En_eV/1e3),' keV, \sigma_E = ',num2str(sEn_eV/1e3),' keV.'];
    title({title1,title2,title3})

    ErrorFlg=1;
end


end

