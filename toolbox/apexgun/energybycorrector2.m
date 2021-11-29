function [ En_eV sEn_eV B0_T sB0_T M A sigR] = energybycorrector2(I_A,X_m,Y_m, PlotFlag)
%Perform the energy measurement using Corrector 2 Horizontal and Screen 1.
%Sintax: [ En_eV sEn_eV B0_T sB0_T M A sigR] = energybycorrector2(I_A,X_m,Y_m, PlotFlag)
%I_A, X_m, Y_m are vectors with the corrector current in A, the data point
%hor coordinate in m, and the vert coordinate in m respectively. 
%A PlotFlag different than zero will generate a plot of the results.
%En_eV and sEn_eV are the measured energy and standard deviation in eV,
%and B0_T and sB0_T are the average enviroment field and standard
%deviation in T.
%M is the fit slope in m/A, A is the fit intercept in m, 
%and sigR is the centroid translation standard deviation used by the fit in m
%(FS - April 11, 2012)
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

    K1=correctorfield(2,0,0,-.5); %Calculate the corrector calibration factor
    K2=correctorfield(2,0,0,.5); %Calculate the corrector calibration factor
    K=K2-K1;%Calculate the corrector calibration factor 
    sK=0.1/sqrt(12)*K; % rms accuracy in corrector field calibration
    D=0.44316;% Distance corrector 2 screen 1 in m
    %Calculate corrector equivalent lenght
    [trash1 trash2 trash3 L]=correctorproperties(2,0,1,1);

    En_eV=mm*cc^2*(sqrt(1+ee^2/mm^2/cc^2*(K*L*D/M)^2)-1)/ee;
    sEn_eV=ee^2/mm*(L*D/M)^2*K/sqrt(1+ee^2/mm^2/cc^2*(K*L*D/M)^2)*sqrt(K^2/M^2*sM^2+sK^2)/ee;

    B0_T=2*K*L/D*A/M;
    sB0_T=2*L/D/M*sqrt(A^2*K^2/M^2*sM^2+K^2*sA^2-2*K^2*A/M*sAM+A^2*sK^2);

    [M A sM sA sAM]=linearfit(I_A,DeltaR,sigR,PlotFlag);
    xlabel('\fontsize{12}Corrector Current [A]')
    ylabel('\fontsize{12}Centroid Displacement [m]')
    title1='\fontsize{13}Hor. Corrector 2/Screen1 Beam Energy Measurement.';
    title2='\fontsize{6} ';
    title3=['\fontsize{12}Energy = ',num2str(En_eV/1e3),' keV, \sigma_E = ',num2str(sEn_eV/1e3),' keV.'];
    title({title1,title2,title3})

    ErrorFlg=1;
end


end

