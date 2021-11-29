function [ FinalAccuracy, BuncherProb1Power_AU, AccuracyWindow, Gain] = powerfeedback_buncherprobe( BuncherProb1Power_AU, AccuracyWindow, Gain) % FS Jan 13, 2016
% Set Buncher probe 1 RF power at the BuncherProb1Power_AU target value in AU.
%Sintax:[ FinalAccuracy, BuncherProb1Power_AU, AccuracyWindow, Gain] = powerfeedback_buncherprobe( BuncherProb1Power_AU, AccuracyWindow, Gain).
% AccuracyWindow sets the feedback intervention relative thershold. Operates if the relative difference between actual and 
% target value is less than Accuracy Window
% Gain sets the feedback gain
% Remark: if AccuracyWindow is set >= 1 the function performs a single loop and exits (regardless of the actual accuracy achieved)
  
BuncherProbe1CalFct=1; %Calibration factor 

TimeScaleCalFactor=1;%1.0177;%1.02143; %Time Calibration Factor required after March 2014 LLRF upgrade.

 BuncherProb1Power_AU=abs(BuncherProb1Power_AU);
  AccuracyWindow=abs(AccuracyWindow);
  Gain=abs(Gain);

  if AccuracyWindow>=1 % if Accuracy window is > 1 do a single loop
      ActAccuracy=1;
  else
      ActAccuracy=AccuracyWindow;
      ['ENTERING Buncher Probe 1 POWER FEEDBACK']
  end
  
  NRFSamp=10; % Number of samples
  RF_deltat=0.01; % Sampling period [s]

  %*****TO BE COMPLETED FROM HERE TO END*****
  
  %read Buncher Probe 1 RF power
  ii=1;%select l1lrf1 FPGA board
  LLRF_Prefix='L1llrf:';
  loopind=1;
  while loopind==1
  
      Wave1=0;
      Wave2=0;
      for jj=1:1:NRFSamp
          Wave1= getpvonline([LLRF_Prefix, 'w3'])/NRFSamp+Wave1;%CavProbe1 Real
          Wave2= getpvonline([LLRF_Prefix, 'w4'])/NRFSamp+Wave2;%CavProbe1 Im.
          
%          Wave3= getpvonline([LLRF_Prefix, 'w7'])/NRFSamp+Wave3;%A3 REV Real
%          Wave4= getpvonline([LLRF_Prefix, 'w8'])/NRFSamp+Wave4;%A3 REV Im
          pause(RF_deltat);
      end
  
      LLRFData{ii}.Inp2.Real.Data = Wave1;
      LLRFData{ii}.Inp2.Imag.Data = Wave2;

%      LLRFData{ii}.Inp3.Real.Data = Wave3;
%      LLRFData{ii}.Inp3.Imag.Data = Wave4;
      
      LLRFData{ii}.Inp2.ScaleFactor=BuncherProbe1CalFct; %Calibration Factor for Cav. Prob 1
      LLRFData{ii}.yscale = getpvonline([LLRF_Prefix, 'yscale']);
      y2 = LLRFData{ii}.Inp2.ScaleFactor * (LLRFData{ii}.Inp2.Real.Data/LLRFData{ii}.yscale + LLRFData{ii}.Inp2.Imag.Data/LLRFData{ii}.yscale * 1i);
      y2mag = abs(y2).^2;% Signal magnitude
      y2ph=180*angle(y2)/pi;% Signal phase
      
%      LLRFData{ii}.Inp3.ScaleFactor=264.8500; %Calibration Factor for A3 REV
%      LLRFData{ii}.yscale = getpvonline([LLRF_Prefix, 'yscale']);
%      y3 = LLRFData{ii}.Inp3.ScaleFactor * (LLRFData{ii}.Inp3.Real.Data/LLRFData{ii}.yscale + LLRFData{ii}.Inp3.Imag.Data/LLRFData{ii}.yscale * 1i);
%      y3mag = abs(y3).^2;% Signal magnitude
%      y3ph=180*angle(y3)/pi;% Signal phase
      
      LLRFData{ii}.t = getpvonline([LLRF_Prefix, 'xaxis']);  % ns (int)
      x2=LLRFData{ii}.t/(TimeScaleCalFactor*1e6); %time variable in ms
      
      %measure the average plateaux of y2mag (Cav. Probe 1)
      y2avg=mean(y2mag(find(y2mag>(.9*max(y2mag)))));
    
      %measure the average of y3mag (A3 REV)
%      A3REV=mean(y3mag);
      
      % ErrorFlag set to 1 on high RF reflected power occurrence
%      ErrorFlag=0;
%      if A3REV>15000*
%          ['WARNING: HIGH REFLECTED POWER!!']
%          ErrorFlag=1;
%      end

     
      %compare actual Buncher Probe 1 power value with target value and perform consequent action
      loopind=0.;
      ifhlp=(y2avg-BuncherProb1Power_AU)/BuncherProb1Power_AU;
      if  abs(ifhlp)>ActAccuracy || ActAccuracy==1
          loopind=1;
          
          % Present power settings
          PowerReal = getpv('L1llrf:source_re_ao');
          PowerImag = getpv('L1llrf:source_im_ao');
          
          % Compute the present phase
          PowerC = PowerReal + 1i*PowerImag;
          PowerPhase = angle(PowerC);
          PowerMag = abs(PowerC);

          % Increase the DAC mag 
          MaxNewMag=30000;
          NewMag = abs(round(PowerMag*(1-ifhlp*Gain)))

          if NewMag > MaxNewMag
              NewMag = MaxNewMag;
              ['WARNING: Max DAC setting of ',num2str(MaxNewMag),' achieved!']
          end

          % Change the DAC mag but keep the phase fixed
          Z = NewMag.*exp(1i*PowerPhase);
          PowerReal = real(Z);
          PowerImag = imag(Z);
          
          
          % Set DAC
          setpvonline('L1llrf:source_re_ao',PowerReal,'float',1);% fast writing option
          setpvonline('L1llrf:source_im_ao',PowerImag,'float',1);
          
      end
      
      
      if ActAccuracy==1 % if Accuracy window is > 1 do a single loop
          loopind=0;      
      end
  end
  FinalAccuracy=ifhlp;
  
      

end


