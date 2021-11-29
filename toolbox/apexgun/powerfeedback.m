function [ FinalAccuracy, A3FWDPower_W, AccuracyWindow, Gain ] = powerfeedback( A3FWDPower_W, AccuracyWindow, Gain) % FS Dec. 8, 2011
% Set A3 FWD RF power at the A3FWDPower_W target value in W.
%Sintax:[ FinalAccuracy, A3FWDPower_W, AccuracyWindow, Gain ] = powerfeedback( A3FWDPower_W, AccuracyWindow, Gain).
% AccuracyWindow sets the feedback intervention relative thershold. Operates if the relative difference between actal and target value is less than Accuracy Window
% Gain sets the feedback gain

% Returns the relative difference between actual and target value

% Syntax: [ FinalAccuracy, A3FWDPower_W, AccuracyWindow, Gain ] = powerfeedback( A3FWDPower_W, AccuracyWindow, Gain)

% Remark: if AccuracyWindow is set >= 1 the function performs a single loop and exits (regardless of the actual accuracy achieved)
  
  A3FWDCalFct=246.0934; %Calibration factor from A3FWD Jan 5, 2015 matrix from llrf.m. Calculated as follow:
%  CableAttn = c(:,4)+c(:,5)+c(:,6);
%  dBsum = -c(:,15) + c(:,10) -30 - CableAttn;
%  Watts = 10.^(dBsum/10);
%  SqrtWatts = sqrt(Watts);
%  A3FWDCalFct=SqrtWatts(1)

TimeScaleCalFactor=1 %1.0177;%; %Time Calibration Factor required after March 2014 LLRF upgrade.
MaxDACset=18500;


  A3FWDPower_W=abs(A3FWDPower_W);
  AccuracyWindow=abs(AccuracyWindow);
  Gain=abs(Gain);

  if AccuracyWindow>=1 % if Accuracy window is > 1 do a single loop
      ActAccuracy=1;
  else
      ActAccuracy=AccuracyWindow;
      ['ENTERING A3 FWD POWER FEEDBACK']
  end
  
  NRFSamp=10; % Number of samples
  RF_deltat=0.03; % Sampling period [s]

  %read A3 FWD RF power
  ii=1;%select llrf1 FPGA board
  LLRF_Prefix='llrf1:';
  loopind=1;
  while loopind==1
  
      Wave1=0;
      Wave2=0;
      for jj=1:1:NRFSamp
          Wave1= getpvonline([LLRF_Prefix, 'w3'])/NRFSamp+Wave1;
          Wave2= getpvonline([LLRF_Prefix, 'w4'])/NRFSamp+Wave2;
          pause(RF_deltat);
      end
  
      LLRFData{ii}.Inp2.Real.Data = Wave1;
      
      LLRFData{ii}.Inp2.Imag.Data = Wave2;
      
      LLRFData{ii}.Inp2.ScaleFactor=A3FWDCalFct; %Calibration Factor
      LLRFData{ii}.yscale = getpvonline([LLRF_Prefix, 'yscale']);
      y2 = LLRFData{ii}.Inp2.ScaleFactor * (LLRFData{ii}.Inp2.Real.Data/LLRFData{ii}.yscale + LLRFData{ii}.Inp2.Imag.Data/LLRFData{ii}.yscale * 1i);
      y2mag = abs(y2).^2;% Signal magnitude
      y2ph=180*angle(y2)/pi;% Signal phase
      
      LLRFData{ii}.t = getpvonline([LLRF_Prefix, 'xaxis']);  % ns (int)
      x2=LLRFData{ii}.t/(TimeScaleCalFactor*1e6); %time variable in ms
      
      
      %measure the average plateaux of y2mag (A3 FWD)
      cnt=0.;
      y2avg=0.;
      y2magSize=size(y2mag);
      for jj=1:1:y2magSize(1,2)
          if y2mag(1,jj)<0.3*max(y2mag)
              y2avg=y2avg;
          else
              y2avg=y2avg+y2mag(1,jj);
              cnt=cnt+1;
          end
      end
      y2avg=y2avg/cnt;% A3 FWD average value
    
      
      %compare actual A3 FWD power value with target value and perform consequent action
      loopind=0.;
      ifhlp=(y2avg-A3FWDPower_W)/A3FWDPower_W;
      if  abs(ifhlp)>ActAccuracy | ActAccuracy==1
          loopind=1;
          
          % Present power settings
          PowerReal = getpv('llrf1:source_re_ao');
          PowerImag = getpv('llrf1:source_im_ao');
          
          % Compute the present phase
          PowerC = PowerReal + 1i*PowerImag;
          PowerPhase = angle(PowerC);
          PowerMag = abs(PowerC);

          % Increase the mag 
          NewMag = abs(round(PowerMag*(1-ifhlp*Gain)));

          % Control maximum DAC setting
          if NewMag > MaxDACset
              NewMag = MaxDACset;
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


