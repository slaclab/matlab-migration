function [ FinalAccuracy, RF_Freq_MHz, AccuracyWindow, Gain ] = gunfrequencyfeedback( RF_Freq_MHz, AccuracyWindow, Gain) % FS April 2, 2014
% Set RF frequency at the RF_Freq_MHz target value in MHz.
%Sintax:[ FinalAccuracy, RF_Freq_MHz, AccuracyWindow, Gain ] = gunfrequencyfeedback( RF_Freq_MHz, AccuracyWindow, Gain).
% AccuracyWindow sets the feedback intervention relative thershold. Operates if the relative difference between actual and target value is less than Accuracy Window
% Gain sets the feedback gain

% Returns the relative difference between actual and target value

% Remark: if AccuracyWindow is set >= 1 the function performs a single loop and exits (regardless of the actual accuracy achieved)
  
GunTunerCal=19.1; %Calibration factor the gun tuner in Hz/Newton. R. Wells measurements in 2013.
CyclePause_s=1;

  RF_Freq_MHz=abs(RF_Freq_MHz);
  AccuracyWindow=abs(AccuracyWindow);
  Gain=abs(Gain);

  if AccuracyWindow>=1 % if Accuracy window is > 1 do a single loop
      ActAccuracy=1;
  else
      ActAccuracy=AccuracyWindow;
  end
  
  NRFSamp=10; % Number of samples
  RF_deltat=0.03; % Sampling period [s]
  
  %Set tuner mode.
  %setpvonline('CavityTuner:ModeReq',2,'float',1);% Motor only mode
  setpvonline('CavityTuner:ModeReq',3,'float',1);% Motor+piezo mode

  setpvonline('CavityTuner:LoadReq.OMSL',0,'float',1);% Tuner in supervisory mode (PLC feedback open)

  %Check if Tuner set and readback values are aligned. If not exit the function.
  TunerAlignTolerance=0.05;
  TunerAlignTolerance=abs(TunerAlignTolerance);
  TunerSet_N = getpv('CavityTuner:LoadReq');
  TunerRead_N= getpv('CavityTuner:LoadAvg');
  ifhlp2=abs((TunerSet_N-TunerRead_N)/TunerSet_N);
  if ifhlp2 > 2*TunerAlignTolerance
      ['Returning']
      return;
  end
  ['ENTERING GUN FREQUENCY FEEDBACK']
  loopind=1;
  while loopind==1
      
      RF0=0;
      for jj=1:1:NRFSamp
          RF0= getpvonline('llrf1:freq_cav')/NRFSamp+RF0;
      end
  
      %compare actual gun RF frequency value with target value and perform consequent action
      loopind=0.;
      ifhlp=(RF0-RF_Freq_MHz)/RF_Freq_MHz;
      if  abs(ifhlp)>ActAccuracy | ActAccuracy==1
          loopind=1;
          % Read present cavity tuner setting
          
%          loopflag=1;
%          while loopflag==1
%              TunerSet_N = getpv('CavityTuner:LoadReq');
%              TunerRead_N= (getpv('CavityTuner:Load1')+getpv('CavityTuner:Load1')+getpv('CavityTuner:Load1')+getpv('CavityTuner:Load1'))/4;
%              ifhlp2=abs((TunerSet_N-TunerRead_N)/TunerSet_N);
%              if ifhlp2 < 0.02
%                  loopflag=0;
%              end
%          end

          TunerSet_N=0;
          TunerRead_N=0;
          for jj=1:NRFSamp 
              TunerSet_N = TunerSet_N+ getpv('CavityTuner:LoadReq')/NRFSamp;
              TunerRead_N= TunerRead_N+getpv('CavityTuner:LoadAvg')/NRFSamp;
              pause(RF_deltat)  
          end

          %read present gun RF frequency in MHz
          RF0=0;
          for jj=1:1:NRFSamp
              RF0= getpvonline('llrf1:freq_cav')/NRFSamp+RF0;
              pause(RF_deltat);
          end
        
          % Calculate new tuner pressures 
          DeltaFreq_Hz=(RF0-RF_Freq_MHz)*1e6;
          DeltaForce_N=DeltaFreq_Hz/GunTunerCal;
          NewTunerSet_N = TunerSet_N+DeltaForce_N*Gain
          
          MaxTunerSet_N=4500;
          if NewTunerSet_N > MaxTunerSet_N
              NewTunerSet_N = MaxTunerSet_N;
          end

          MinTunerSet=100;
          if NewTunerSet_N < MinTunerSet
              NewTunerSet_N = MinTunerSet;
          end
          
          TunerSet_hlp =getpv('CavityTuner:LoadReq');
          TunerRead_hlp=getpv('CavityTuner:LoadAvg');
          ifhlp2=abs((TunerSet_hlp-TunerRead_hlp)/TunerSet_hlp);
          if TunerSet_hlp <= 150.
              TunerAlignHlp=TunerAlignTolerance*2;
          else
              TunerAlignHlp=TunerAlignTolerance;
          end
          while ifhlp2 > TunerAlignHlp % wait for tuner force set and read to align
              TunerSet_hlp =getpv('CavityTuner:LoadReq');
              TunerRead_hlp=getpv('CavityTuner:LoadAvg');
              ifhlp2=abs((TunerSet_hlp-TunerRead_hlp)/TunerSet_hlp);
              pause(CyclePause_s)
          end
          pause(CyclePause_s)
          % Set Tuner
          setpvonline('CavityTuner:LoadReq',NewTunerSet_N,'float',1);% fast writing option          
      end
      
      
      if ActAccuracy==1 % if Accuracy window is > 1 do a single loop
          loopind=0;      
      end
      
      Phase_diff= getpvonline('llrf1:phase_diff');
      % if phase control is lost go to emergency recovery routine
      if abs(Phase_diff) >15
          Emergencygunrftuningrecovery
      end

  end
  pause(CyclePause_s)
  FinalAccuracy=ifhlp;
  
      

end


