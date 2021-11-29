function [ output_args ] = scangunrf(PhInit_deg,PhFinal_deg,NumSteps,WaitTime_s)
%Sintax: scangunrf(PhInit_deg,PhFinal_deg,NumSteps,WaitTime_s)
%Scan the gun RF phase (in degs) from PhInit_deg to PhFinal_deg in NumSteps.
%At each phase value it stay for WaitTime_s seconds.


NumSteps=abs(NumSteps);
deltaPh=(PhFinal_deg-PhInit_deg)/(NumSteps-1);



PowRealIn=getpv('llrf1:source_re_ao');
PowImagIn=getpv('llrf1:source_im_ao');

for PhAct=PhInit_deg:deltaPh:PhFinal_deg
    
    PowReal0=getpv('llrf1:source_re_ao');
    PowImag0=getpv('llrf1:source_im_ao');
    PowMod0=sqrt(PowReal0^2+PowImag0^2);
    PowPh0=acos(PowReal0/PowMod0);

    
    PhAct
    PhAct_rad=PhAct/180*pi;
    PowerReal=PowMod0*cos(PhAct_rad);
    PowerImag=PowMod0*sin(PhAct_rad);
    
    if PowerImag<0
        SignFct=-1;
    else
        SignFct=1;
    end
    PowMod=sqrt(PowerReal^2+PowerImag^2);
    PowPh=acos(PowerReal/PowMod)/pi*180*SignFct;


    
    setpvonline('llrf1:source_re_ao',PowerReal,'float',1); % use this version for quick refresh
    setpvonline('llrf1:source_im_ao',PowerImag,'float',1); % use this version for quick refresh

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

    setpvonline('llrf1:source_re_ao',PowRealIn,'float',1); % use this version for quick refresh
    setpvonline('llrf1:source_im_ao',PowImagIn,'float',1); % use this version for quick refresh

end

