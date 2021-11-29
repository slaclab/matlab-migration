%profmon_read.m

%Script to characterize the distriubtion of the profile of VCC images.  
%Symmetric an Asymmetric Power values from zernike are calculated from
%polynomials. X and Y ratios of the gauss fit to lineout distributions 
%are calculated by comparing the pedestal to the peak amplitude of 
%the distribution. 

%Author: Dorian Bohler

delay = 0.25;
cutoff = 20000; 
savedata = 22000; %Debug the save getting file already exists 



COUNTER_PV ='SIOC:SYS0:ML01:AO719';
COEF_WFPV='CAMR:IN20:186:ZERNIKE_COEFF';
COEF_WFPV_GOLD='CAMR:IN20:186:ZERNIKE_COEFF_GOLD';
COEF_WFPV_IDEAL='CAMR:IN20:186:ZERNIKE_COEFF_IDEAL';
% COEF_WFPV_GOLD='CAMR:IN20:186:ZERNIKE_COEFF_GOLD_210';
% COEF_WFPV_IDEAL='CAMR:IN20:186:ZERNIKE_COEFF_IDEAL_210';
PWR_RADSYM_PV='SIOC:SYS0:ML01:AO852';
PWR_NONRADSYM_PV='SIOC:SYS0:ML01:AO853';
CIRCLE_PV='SIOC:SYS0:ML01:AO854';
NORMCOEF_PV='SIOC:SYS0:ML01:AO855';

X_RATIO_PV='SIOC:SYS0:ML02:AO066';
Y_RATIO_PV='SIOC:SYS0:ML02:AO067';
Z_RATIO_PV='SIOC:SYS0:ML02:AO092';
W_RATIO_PV='SIOC:SYS0:ML02:AO093';

X_BALANCE_PV='SIOC:SYS0:ML02:AO068';
Y_BALANCE_PV='SIOC:SYS0:ML02:AO069';
Z_BALANCE_PV='SIOC:SYS0:ML02:AO094';
W_BALANCE_PV='SIOC:SYS0:ML02:AO095';

lcaPutSmart([PWR_RADSYM_PV, '.DESC'], 'VCC radial power pv');
lcaPutSmart([PWR_NONRADSYM_PV, '.DESC'], 'VCC non-radial power pv');
lcaPutSmart([CIRCLE_PV, '.DESC'], 'VHC meas of Y/X');
lcaPutSmart([NORMCOEF_PV, '.DESC'], 'VHC meas norm coeff.');

lcaPutSmart([X_RATIO_PV, '.DESC'], 'Gauss Cut X-Ratio');
lcaPutSmart([Y_RATIO_PV, '.DESC'], 'Gauss Cut Y-Ratio');
lcaPutSmart([Z_RATIO_PV, '.DESC'], 'Gauss Cut Diag Ratio');
lcaPutSmart([W_RATIO_PV, '.DESC'], 'Gauss Cut Anti Diag Ratio');

lcaPutSmart([X_BALANCE_PV, '.DESC'], 'X Balance');
lcaPutSmart([Y_BALANCE_PV, '.DESC'], 'Y Balance');
lcaPutSmart([Z_BALANCE_PV, '.DESC'], 'Diagonal Balance');
lcaPutSmart([W_BALANCE_PV, '.DESC'], 'Anti-Diagonal Balance');

lcaPutSmart([PWR_RADSYM_PV, '.PREC'], 3);
lcaPutSmart([PWR_NONRADSYM_PV, '.PREC'], 3);
lcaPutSmart([CIRCLE_PV, '.PREC'], 3);
lcaPutSmart([NORMCOEF_PV, '.PREC'], 3);
lcaPutSmart([X_RATIO_PV, '.PREC'], 3);
lcaPutSmart([Y_RATIO_PV, '.PREC'], 3);
lcaPutSmart([X_BALANCE_PV, '.PREC'], 3);
lcaPutSmart([Y_BALANCE_PV, '.PREC'], 3);
lcaPutSmart([Z_RATIO_PV, '.PREC'], 3);
lcaPutSmart([W_RATIO_PV, '.PREC'], 3);
lcaPutSmart([Z_BALANCE_PV, '.PREC'], 3);
lcaPutSmart([W_BALANCE_PV, '.PREC'], 3);




ratios=[0 0 0 0];
psym=0;
pasym=0;
while 1;

    for i=1:cutoff
        lcaPutSmart(COUNTER_PV, i);
        disp(i)
        if i== cutoff 
            i=1;
        end

        if i==savedata;        
            try
                data=profmon_measure('VCC',1,'nBG',0,'doPlot',1,'saves',1);
                control_profDataSet('VCC',data.beam)
                pause(delay)
            end
            try
                data1=profmon_measure('VHC',1,'nBG',0,'doPlot',1,'saves',1);
                control_profDataSet('VHC',data1.beam)
            end
        end
        
        try
            data=profmon_measure('VCC',1,'nBG',0,'doPlot',0);
        catch err
            disp(err);
            pause(10)
            continue
        end
        control_profDataSet('VCC',data.beam)
        
        try
         %   [ratios, balance, x, y, z, w]= profmon_gaussRatio(data);
            [ratios, balance]= profmon_gaussRatio(data);

        catch err
            disp(err)
        end
        
        try
            close all % Moved out of beamAnalysis_imgCircleFit
            [coeff,imgB,imgC,pow]=beamAnalysis_imgCircleFit(data.img,45);  
            [coefs,psym, pasym,~] = beamAnalysis_Zernike(data.img);
        catch  err
            disp(err)
        end
        
        try 
            [coefs,psym, pasym,~] = beamAnalysis_Zernike(data.img);
        catch err
            disp(err)
        end
        
        %{
        disp('psym')
        disp(psym)
        disp('pasym')
        disp(pasym)
        %}
        lcaPutSmart('CAMR:IN20:186:ZERNIKE_COEFF_210', coefs)
        lcaPutSmart('SIOC:SYS0:ML02:AO241',psym);
        lcaPutSmart('SIOC:SYS0:ML02:AO242',pasym);
        
        lcaPutSmart(PWR_RADSYM_PV, pow(1));
        lcaPutSmart(PWR_NONRADSYM_PV, pow(2));
        lcaPutSmart(COEF_WFPV, coeff);
        lcaPutSmart(X_RATIO_PV, ratios(1));
        lcaPutSmart(Y_RATIO_PV, ratios(2));
        lcaPutSmart(Z_RATIO_PV, ratios(3));
        lcaPutSmart(W_RATIO_PV, ratios(4));
        
        lcaPutSmart(X_BALANCE_PV, balance(1));
        lcaPutSmart(Y_BALANCE_PV, balance(2));
        lcaPutSmart(Z_BALANCE_PV, balance(3));
        lcaPutSmart(W_BALANCE_PV, balance(4));

        try
            data1=profmon_measure('VHC',1,'nBG',0,'doPlot',0);
            control_profDataSet('VHC',data1.beam);
        catch err
            disp(err)
        end
        
        pause(delay)
        
    end
end






