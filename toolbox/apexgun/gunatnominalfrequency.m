function [] = gunatnominalfrequency % FS April 4, 2014
% Set RF frequency at the RF_Freq_MHz nominal target value.
%Sintax: gunatnominalfrequency_byfrequency.
% The function enters a perpetual loop that can be interrupted by Ctrl+C.
  
NomFreq_MHz=1300/7;% 
NomAccur=1.e-6
NomGain=6.e-2

%Switch ON LLRF1 Phase Diff Frequency Feedback.
setpvonline('llrf1:freq_loop_close',1,'float',1);

while 1
    gunfrequencyfeedback(NomFreq_MHz,NomAccur,NomGain)
    ['Target frequency :', num2str(NomFreq_MHz),' MHz']
end

end


