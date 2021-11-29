function [ ] = scangunrf_llrfloopclosed(PhInit_deg,PhFinal_deg,NumSteps,WaitTime_s)
%To be used when the gun llrf amp/phase loop is closed
%SINTAX: scangunrf_llrfloopclosed(PhInit_deg,PhFinal_deg,NumSteps,WaitTime_s)
%Scan the gun RF phase (in degs) from PhInit_deg to PhFinal_deg in NumSteps.
%At each phase value it stay for WaitTime_s seconds.
%If WaitTime_s is negative a prompt will appear asking for advancing to the next step.


NumSteps=abs(NumSteps);
deltaPh=(PhFinal_deg-PhInit_deg)/(NumSteps-1);



PowRealIn=getpv('llrf1:set_iloop_re_ao');
PowImagIn=getpv('llrf1:set_iloop_im_ao');

PowRealIngui=getpv('llrf1:source_re_ao');
PowImagIngui=getpv('llrf1:source_im_ao');

for PhAct=PhInit_deg:deltaPh:PhFinal_deg
    
    
    PhAct
    
    setgunRFphaseLLRFloopClosed(PhAct)


    if WaitTime_s<0
      
        prompt = {'Next step?                     .'};
        dlg_title = 'Select Input Mode';
        num_lines = 1;
        def = {''};
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        InputMode=answer{1}; % Input Mode
        
    else
        pause(WaitTime_s)
    end
    
end

setpvonline('llrf1:set_iloop_re_ao',PowRealIn,'float',1); % use this version for quick refresh
setpvonline('llrf1:set_iloop_im_ao',PowImagIn,'float',1); % use this version for quick refresh

setpvonline('llrf1:source_re_ao',PowRealIngui,'float',1); % use this version for quick refresh
setpvonline('llrf1:source_im_ao',PowImagIngui,'float',1); % use this version for quick refresh

end

