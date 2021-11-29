function [ FinalAccuracy, CavProb1Power_W, AccuracyWindow, Gain] = powerfeedback_cavityprobe( CavProb1Power_W, AccuracyWindow, Gain) % FS Nov. 5, 2012
% Set Cavity probe 1 RF power at the CavProb1Power_W target value in W.
%Sintax:[ FinalAccuracy, CavProb1Power_W, AccuracyWindow, Gain, ErroFlag] = powerfeedback_cavityprobe( CavProb1Power_W, AccuracyWindow, Gain).
% AccuracyWindow sets the feedback intervention relative thershold. Operates if the relative difference between actal and 
% target value is less than Accuracy Window
% Gain sets the feedback gain


% Returns the relative difference between actual and target value

% Syntax: [ FinalAccuracy, A3FWDPower_W, AccuracyWindow, Gain ] = powerfeedback( A3FWDPower_W, AccuracyWindow, Gain)

% Remark: if AccuracyWindow is set >= 1 the function performs a single loop and exits (regardless of the actual accuracy achieved)
  
   CavProbe1CalFct=349.0197; %Calibration factor from A3FWD from matrix c in llrf.m. Calculated as follow from Jan 5, 2015 matric in llrf.m:
%  CableAttn = c(:,4)+c(:,5)+c(:,6);
%  dBsum = -c(:,15) + c(:,10) -30 - CableAttn;
%  Watts = 10.^(dBsum/10);
%  SqrtWatts = sqrt(Watts);
%  CavProbe1CalFct=SqrtWatts(3)


TimeScaleCalFactor=1;%1.0177;%1.02143; %Time Calibration Factor required after March 2014 LLRF upgrade.

 CavProb1Power_W=abs(CavProb1Power_W);
  AccuracyWindow=abs(AccuracyWindow);
  Gain=abs(Gain);

  if AccuracyWindow>=1 % if Accuracy window is > 1 do a single loop
      ActAccuracy=1;
  else
      ActAccuracy=AccuracyWindow;
      ['ENTERING Cavity Probe 1 POWER FEEDBACK']
  end
  
  NRFSamp=10; % Number of samples
  RF_deltat=0.01; % Sampling period [s]

  %read Cav Probe 1 RF power
  ii=1;%select llrf1 FPGA board
  LLRF_Prefix='llrf1:';
  loopind=1;
  while loopind==1
  
      Wave1=0;
      Wave2=0;
      for jj=1:1:NRFSamp
          Wave1= getpvonline([LLRF_Prefix, 'w7'])/NRFSamp+Wave1;%CavProbe1 Real
          Wave2= getpvonline([LLRF_Prefix, 'w8'])/NRFSamp+Wave2;%CavProbe1 Im.
          
%          Wave3= getpvonline([LLRF_Prefix, 'w7'])/NRFSamp+Wave3;%A3 REV Real
%          Wave4= getpvonline([LLRF_Prefix, 'w8'])/NRFSamp+Wave4;%A3 REV Im
          pause(RF_deltat);
      end
  
      LLRFData{ii}.Inp2.Real.Data = Wave1;
      LLRFData{ii}.Inp2.Imag.Data = Wave2;

%      LLRFData{ii}.Inp3.Real.Data = Wave3;
%      LLRFData{ii}.Inp3.Imag.Data = Wave4;
      
      LLRFData{ii}.Inp2.ScaleFactor=CavProbe1CalFct; %Calibration Factor for Cav. Prob 1
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

     
      %compare actual Cav. Probe 1 power value with target value and perform consequent action
      loopind=0.;
      ifhlp=(y2avg-CavProb1Power_W)/CavProb1Power_W;
      if  abs(ifhlp)>ActAccuracy || ActAccuracy==1
          loopind=1;
          
          % Present power settings
          PowerReal = getpv('llrf1:source_re_ao');
          PowerImag = getpv('llrf1:source_im_ao');
          
          % Compute the present phase
          PowerC = PowerReal + 1i*PowerImag;
          PowerPhase = angle(PowerC);
          PowerMag = abs(PowerC);

          % Increase the mag 
          MaxNewMag=32000;
          NewMag = abs(round(PowerMag*(1-ifhlp*Gain)));

          if NewMag > MaxNewMag
              NewMag = MaxNewMag;
              ['WARNING: Max DAC setting of ',num2str(MaxNewMag),' achieved!']
          end

          % Change the mag but keep the phase fixed
          Z = NewMag.*exp(1i*PowerPhase);
          PowerReal = real(Z);
          PowerImag = imag(Z);
          
          
          % Set DAC
          setpvonline('llrf1:source_re_ao',PowerReal,'float',1);% fast writing option
          setpvonline('llrf1:source_im_ao',PowerImag,'float',1);
          
      end
      
      
      if ActAccuracy==1 % if Accuracy window is > 1 do a single loop
          loopind=0;      
      end
  end
  FinalAccuracy=ifhlp;
  


end


