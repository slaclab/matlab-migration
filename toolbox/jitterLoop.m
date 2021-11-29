function jitterLoop()
% Adapted from D. Ratner's Jitter GUI by W. Colocho
global modelSource
modelSource = 'MATLAB'
lcaSetSeverityWarnLevel(4) %Don't warn about INVALID severity for BPMS
handles.numavg =50; %++20 %+get from epics
RunNum = handles.numavg;
navg = handles.numavg;
nCalc = navg;
handles.wait = 1.5; %+ get from epics        
lowChargeCounter = 0;
% Energy BPMs
EBPM_pvs =  {'BPMS:IN20:221'; 'BPMS:IN20:731';  'BPMS:LI21:233'; 'BPMS:LI24:801'; 'BPMS:LTUH:250'; 'BPMS:LTUH:450' };
% Injector Jitter BPMs
XYInjBPM_pvs =        {'BPMS:IN20:771'; 'BPMS:IN20:781'; 'BPMS:LI21:131'; 'BPMS:LI21:161'; 'BPMS:LI21:201'; 'BPMS:LI21:278'; 'BPMS:LI21:301'};  
                                    
% Sector 28 Jitter BPMs
XY28BPM_pvs =        {'BPMS:LI27:301'; 'BPMS:LI27:401'; 'BPMS:LI27:701'; 'BPMS:LI27:801'; 'BPMS:LI28:301'; 'BPMS:LI28:401'; 'BPMS:LI28:701'; 'BPMS:LI28:801' };  

% Undulator Jitter BPMs
XYUndBPM_pvs =        {'BPMS:UNDH:1305'; 'BPMS:UNDH:1590'; 'BPMS:UNDH:1890' ; 'BPMS:UNDH:2190' ; 'BPMS:UNDH:2490'; 'BPMS:UNDH:2790'; 'BPMS:UNDH:3090';  ...
                       'BPMS:UNDH:3390'; 'BPMS:UNDH:3690'; 'BPMS:UNDH:3990';  'BPMS:UNDH:4290' };  

 % LTU Jitter BPMs
XYLTUBPM_pvs = {'BPMS:LTUH:720'; 'BPMS:LTUH:730'; 'BPMS:LTUH:740'; 'BPMS:LTUH:750'; 'BPMS:LTUH:760'; 'BPMS:LTUH:770'};  
                                    
BSY_mag = 2;
                   

% Number of Energy BPMs
NE = size((EBPM_pvs),1);
NxyInj = length(XYInjBPM_pvs); 
Nxy28 = length(XY28BPM_pvs);  
NxyUnd = length(XYUndBPM_pvs);
NxyLTU = length(XYLTUBPM_pvs);

% Injector BPMs initialization                                  
XsInj = zeros(RunNum,NxyInj);
YsInj = zeros(RunNum,NxyInj);
ioksInj = zeros(RunNum,NxyInj);
               
% Sector 28 BPMs initialization                                  
Xs28 = zeros(RunNum,Nxy28);
Ys28 = zeros(RunNum,Nxy28);
ioks28 = zeros(RunNum,Nxy28);

% Undulator BPMs initialization                                  
XsUnd = zeros(RunNum,NxyUnd);
YsUnd = zeros(RunNum,NxyUnd);
ioksUnd = zeros(RunNum,NxyUnd);

% LTU BPMs initialization                                  
XsLTU = zeros(RunNum,NxyLTU);
YsLTU = zeros(RunNum,NxyLTU);
ioksLTU = zeros(RunNum,NxyLTU);
                  
for j = 1:(NE)
    %--handles.output = hObject; 
    %BPM_SLC_name = model_nameConvert(EBPM_pvs{j},'SLC');
    % handles.BPM_micrs(j,:) = BPM_SLC_name(6:9);
    % handles.BPM_units(j)   = str2int(BPM_SLC_name(11:end));
    try
      %twiss = aidaget([BPM_SLC_name '//twiss'],'doublea',{'TYPE=DATABASE'});
      [r, z, l, twiss] = model_rMatGet(EBPM_pvs{j}, [], {'TYPE=DESIGN' 'BEAMPATH=CU_HXR'});
      %twiss = aidaget([EBPM_pvs{j} '//twiss'],'doublea',{'TYPE=DESIGN'});      
    catch
      dispStr (sprintf('%s model_rMatGet failed for %s//twiss', datestr(now), BPM_SLC_name));
    end
    handles.twiss(:,j) = twiss(1:11);
end

handles.etax  = abs(handles.twiss(5,:))*1000;       % factor of 1000 conv m to mm
handles.etax(end) = -handles.etax(end);
for i=2:size(handles.etax,2);
    if handles.etax(i) == 0
        fprintf('%s Error on aidaget for twiss values\n',datestr(now));
        return;
    end
end                   
    
% Hard code LTU dispersion value  (is this in model yet?)
%BSY_eta = 84.6158;
%handles.etax(NE-1) = 125;
%handles.etax(NE) = -125;
etax = handles.etax

% Initialize Histories.5
ERun = zeros(NE-1,RunNum);
EHist = zeros(NE-1,RunNum);
TRun = zeros(1,RunNum);
THist = zeros(1,RunNum);
LBC1Run = zeros(1,RunNum);
LBC2Run = zeros(1,RunNum);
LBC1Hist = zeros(1,RunNum);
LBC2Hist = zeros(1,RunNum);
FEEGD1Run = zeros(1,RunNum); % Gas detector 1
FEEGD2Run = zeros(1,RunNum);
PhotonEngyRun = zeros(1,RunNum); %Photon energy

XHistInj = zeros(1,RunNum);
YHistInj = zeros(1,RunNum);
XHist28Und = zeros(1,RunNum);
YHist28Und = zeros(1,RunNum);


XUVLasRun = zeros(1,RunNum);
YUVLasRun = zeros(1,RunNum);
UVLasPowRun = zeros(1,RunNum);
XUVLasHist = zeros(1,RunNum);
YUVLasHist = zeros(1,RunNum);
UVLasPowHist = zeros(1,RunNum);

XIRLasRun = zeros(1,RunNum);
YIRLasRun = zeros(1,RunNum);
IRLasPowRun = zeros(1,RunNum);
XIRLasHist = zeros(1,RunNum);
YIRLasHist = zeros(1,RunNum);
IRLasPowHist = zeros(1,RunNum);

% initialize counts (tracks when averaging buffer is full)
count = 0;
count28Und = 0;
countUnd = 0; 
countLTU = 0;
count28 = 0;


% setup for XY jitter
JSetInj = XYJitter_Setup(XYInjBPM_pvs,NxyInj, 'INJ_SET');
JSet28 = XYJitter_Setup(XY28BPM_pvs,Nxy28, 'BSY_SET');
JSetUnd = XYJitter_Setup(XYUndBPM_pvs,NxyUnd, 'BSY_SET');
JSetLTU = XYJitter_Setup(XYLTUBPM_pvs,NxyLTU, 'BSY_SET');

% plot handles for XY jitter
JSetInj.X_AX = 'XJITTERAX_INJ';
JSetInj.Y_AX = 'YJITTERAX_INJ';
JSet28.X_AX =  'XJITTERAX_28';
JSet28.Y_AX =  'YJITTERAX_28';
JSetUnd.X_AX =  'XJITTERAX_28';
JSetUnd.Y_AX =  'YJITTERAX_28';
JSetLTU.X_AX =  'XJITTERAX_28';
JSetLTU.Y_AX =  'YJITTERAX_28';

lastBpmToFit = '';

% Incrementor to show gui is alive
JoesInc = 0;

% Get data indefinitely 
counter = 0;
while(1)
    counter = counter + 1;
    lcaPutSmart('SIOC:SYS0:ML00:AO516',counter);
    tic
    %'Laser Mark'
    % Laser shape RMS (completely flat is 0)
    try LasRMS = lcaGetSmart('SIOC:SYS0:ML00:AO071'); catch dispStr('Error on lcaGet for Laser RMS SIOC:SYS0:ML00:AO071');  end         
    
    % Laser aperture
    try UVLasAp = lcaGetSmart('SIOC:SYS0:ML00:AO072'); catch dispStr('Error on lcaGet for Laser Aperture SIOC:SYS0:ML00:AO072'); end  
   % UV Laser X position
    XUVLasRun = circshift(XUVLasRun,[0,-1]);                
    try  XUVLasRun(:,RunNum) = lcaGetSmart('CAMR:IN20:186:CTRD_H'); catch dispStr('Error on lcaGet for Laser XPos CAMR:IN20:186:CTRD_H'); end 
    % X variation relative to measured aperture diameter divided by 4
    % (approx RMS)
    XUVLasRMS = util_stdNan(XUVLasRun)/(UVLasAp/4);       
    
    % UV Laser Y Position
    YUVLasRun = circshift(YUVLasRun,[0,-1]);    
    try YUVLasRun(:,RunNum) = lcaGetSmart('CAMR:IN20:186:CTRD_V');
    catch dispStr('Error on lcaGet for Laser YPos CAMR:IN20:186:CTRD_V'); end 
    % X variation relative to measured aperture diameter divided by 4 (approx RMS)    
    YUVLasRMS = util_stdNan(YUVLasRun)/(UVLasAp/4);  

    % UV Laser Power
    UVLasPowRun = circshift(UVLasPowRun,[0,-1]);  
    try UVLasPowRun(:,RunNum) = lcaGetSmart('LASR:IN20:196:PWRTH'); catch dispStr('Error on lcaGet for Laser Power LASR:IN20:196:PWRTH'); end       
    UVLasPowMean = mean(UVLasPowRun);
    UVLasPowRMS = util_stdNan(UVLasPowRun)/UVLasPowMean;    
    
    % hard coded IR laser size in mm
    IRLasAp = 0.2;
    
    % IR Laser X position
    XIRLasRun = circshift(XIRLasRun,[0,-1]);                
    try XIRLasRun(:,RunNum) = lcaGetSmart('CAMR:IN20:469:CTRD_H'); catch dispStr('Error on lcaGet for Laser XPos CAMR:IN20:469:CTRD_H'); end 
    % X variation relative to 200um approx RMS
    % (approx RMS)
    XIRLasRMS = util_stdNan(XIRLasRun)/(IRLasAp);       
  
     % IR Laser Y Position
    YIRLasRun = circshift(YIRLasRun,[0,-1]);    
    try YIRLasRun(:,RunNum) = lcaGetSmart('CAMR:IN20:469:CTRD_V');
    catch dispStr('Error on lcaGet for Laser YPos CAMR:IN20:469:CTRD_V'); end 
    % X variation relative to 200um approx RMS    
    YIRLasRMS = util_stdNan(YIRLasRun)/(IRLasAp);  

    % IR Laser Power
    IRLasPowRun = circshift(IRLasPowRun,[0,-1]);  
    try IRLasPowRun(:,RunNum) = lcaGetSmart('LASR:IN20:475:PWRTH');       
    catch dispStr('Error on lcaGet for Laser Power LASR:IN20:475:PWRTH'); end       
    IRLasPowMean = mean(IRLasPowRun);
    IRLasPowRMS = util_stdNan(IRLasPowRun)/IRLasPowMean;        
   
    
    % default status of beam in sector 28
    status28Und = 1;    

    
    %'Beamrate Mark'
    handles.tstr = get_time;    
    [sys,accelerator]=getSystem();
    try rate = lcaGet(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);  % rep. rate [Hz]
    catch dispStr(['Error on lcaGet for EVNT:' sys ':1:' accelerator 'BEAMRATE - defaulting to 1 Hz rate.']); rate = 1; end
    
    % Some old programs die on rate=0
    if rate < 1, rate = 1;  end
    
     %'YAG02 Mark'    
    
    % Skip scan if YAG02 is in.  (Schottky scan will mess up RMS)
    try
        YAG02 = lcaGetSmart('YAGS:IN20:241:PNEUMATIC');
    catch
        dispStr('Error on lcaGet for YAGS:IN20:241:PNEUMATIC.  Assume YAG02 not in')     
    end
    if (strcmp(YAG02,'IN'))
        dispStr('YAG02 is in.  Wait for scan to finish');
        logStatus('YAG02 is in.  Waiting for scan to finish...'); 
        dispStr(handles.tstr);
        pause(handles.wait + 15);
        continue;
    end    
    

    % Check LTU status and adjust energy BPMs accordingly
    BSY_mag = 0;
    if BSY_mag < 1
        statusLTU = 1;
        handles.statusLTU = 1;
        %--set(handles.RMS4,'String','LTU dE/E RMS (%) =');         
    else
        statusLTU = 0;        
        handles.statusLTU = 0;
        %--set(handles.RMS4,'String','BSY dE/E RMS (%) =');         
    end                 
    
    % Check TDUND status and adjust XY Jitter BPMs accordingly
    try
        TDUND = lcaGetSmart('DUMP:LTUH:970:TDUND_PNEU');
    catch
        dispStr('Error on lcaGet for DUMP:LTUH:970:TDUND_PNEU. Assume TDUND in.')
        TDUND = 'IN';
    end

    % For now, assume 'IN'
    %TDUND = 'IN';
    if strcmp(TDUND,'OUT')
        statusUnd = 1;
        handles.statusUnd = 1;        
    else
        statusUnd = 0;
        handles.statusUnd = 0;
    end
    
    
    if statusUnd;
        TotBPM_pvs = cat(1,EBPM_pvs,XYInjBPM_pvs,XYUndBPM_pvs); 
        bpmToFit = 'BPM UNDH 190';
    elseif statusLTU
        
        TotBPM_pvs = cat(1,EBPM_pvs,XYInjBPM_pvs,XYLTUBPM_pvs);    
        bpmToFit = 'BPM LTUH 720';
    else
           
        TotBPM_pvs = cat(1,EBPM_pvs,XYInjBPM_pvs,XY28BPM_pvs); 
        bpmToFit = 'BPM LI27 301';
    end
    
    if ~strcmp(lastBpmToFit, bpmToFit), 
        lcaPutSmart('SIOC:SYS0:ML00:CA007' ,double(int8(bpmToFit)));  end
        lcaPutSmart('SIOC:SYS0:ML00:AO178.DESC',['X RMS Jitter at ' bpmToFit]);
        lcaPutSmart('SIOC:SYS0:ML00:AO179.DESC',['Y RMS Jitter at ' bpmToFit]);
    lastBpmToFit = bpmToFit;
  
    %'All BPMs Mark'        
    %lcaPut('SIOC:SYS0:ML00:AO186',1); 
    % Read in all BPMs
    try
        [TotX,TotY,TotT,TotdX,TotdY,TotdT,Totiok] = read_BPMsBSA(TotBPM_pvs,1,rate, nCalc);  % read first BPM, X, Y, & TMIT with averaging
        TotX(isnan(TotX)) = 0;
        TotY(isnan(TotY)) = 0;
    catch
        dispStr('Error with read_BPMsSmart')
    end

    %'Done Reading BPMs'
    %lcaPut('SIOC:SYS0:ML00:AO186',3);
    % Separate out Energy, Injector and Sector 28 BPMs
    EX = TotX(1:NE,:);
    ET = TotT(1:NE,:);
    XInj = TotX(NE+1:NE+NxyInj,:);
    YInj = TotY(NE+1:NE+NxyInj,:);
    iokInj = Totiok(NE+1:NE+NxyInj,:);
    X28Und = TotX(NE+NxyInj+1:end,:);
    Y28Und = TotY(NE+NxyInj+1:end,:);
    iok28Und = Totiok(NE+NxyInj+1:end,:);        




    % Check if beam is down
    %if 1.602E-10*ET(1,:) < 1e-3
    if sum(iokInj(1,:)+0) < nCalc    
        lowChargeCounter = lowChargeCounter + 1;
        if (lowChargeCounter < 2)
           msgStr = [handles.tstr ' No Charge: Waiting for beam...'];
           logStatus(msgStr);
%            dispStr(msgStr);
%            try lcaPut('SIOC:SYS0:ML00:CA003' ,double(int8(msgStr))); 
%            catch fprintf('%s Failed to write to SIOC:SYS0:ML00:CA003\n', datestr(now)); end
        end
        pause(handles.wait);
        continue;
    else
        lowChargeCounter = 0;
    end

    % Running Average of energy and TMIT
    % There are NE BPMs being read, but we only use NE-2 dispersive regions.
    % Use BPM NE-2 for the BSY, and BPMs NE,NE-1 for LTU.
    %1 ERun = circshift(ERun,[0,-1]);      % Shift register of energy values from last iteration
    for ii = 1:NE-1
    %ERun(:,RunNum) = EX(1:NE-2)./etax(1:NE-2);      % convert X to energy and add to last value in ERun register
        ERun(ii,:) = EX(ii,:)./etax(ii); 
    end
    % Check if in LTU. In this case, use LTU BPMs for final energy jitter
    if statusLTU         
        % Check beam reaches end of DL2.  If not, just use first LTU BPM
        if ET(NE,:) > ET(NE-1,:)/2          
            ERun(NE-1,:) = (EX(NE-1,:)/etax(NE-1)+EX(NE,:)/etax(NE))/2;
        else
            ERun(NE-1,:) = EX(NE-1,:)/etax(NE-1);            
        end
    end
    ERMS = util_stdNan(ERun,0,2);               % Calculate new standard deviation


    
    %TRun = circshift(TRun,[0,-1]);      % Shift register of TMIT values
    %1TRun(1,RunNum) = ET(1);              % update last value of register to TMIT from BPM2
    TRun(1,:) = ET(1,:);              % update last value of register to TMIT from BPM2
    handles.Tmean = mean(TRun);        % Calc mean value of charge
    TRMS = util_stdNan(TRun)/abs(handles.Tmean);    % Calc rms variation of charge



    %'Bunch Length Mark'

    % Bunch Length Measurements
    %1LBC1Run = circshift(LBC1Run,[0,-1]);
    try
         val = lcaGetSmart('BLEN:LI21:265:AIMAXHSTBR');
    catch
        dispStr('Error on lcaGet for BC monitor BLEN:LI21:265:AIMAXHSTBR')
        val = zeros(1,nCalc);
    end  
    try
    LBC1Run(:,:) = val(end-nCalc+1:end);
    catch
        fprintf('%s problem with LBC1Run, %i\n', datestr(now), size(LBC1Run));
    end
    LBC1Mean = mean(LBC1Run); 
    LBC1RMS = util_stdNan(LBC1Run)/abs(LBC1Mean);

    %1LBC2Run = circshift(LBC2Run,[0,-1]);
    try
         val = lcaGet('BLEN:LI24:886:BIMAXHSTBR');  
    catch
        dispStr('Error on lcaGet for BC Monitor BLEN:LI24:886:BIMAX')
         val = zeros(1,nCalc);
    end  
    
    LBC2Run(:,:) = val(end-nCalc+1:end);
    LBC2Mean = mean(LBC2Run); 
    LBC2RMS = util_stdNan(LBC2Run)/abs(LBC2Mean); 
    
    %'Gas Detector mark'
    %1FEEGD1Run = circshift(FEEGD1Run,[0,-1]);
    try
        val = (lcaGet('GDET:FEE1:241:ENRCHSTBR') + lcaGet('GDET:FEE1:242:ENRCHSTBR'))/2 ;
    catch
        dispStr('Error on lcaGet for GDET:FEE1:241:ENRCHSTBR or GDET:FEE1:242:ENRCHSTBR')
        val = zeros(1,nCalc);
    end        
    FEEGD1Run(:,:) = val(end-nCalc+1:end);
    FEEGD1Mean = mean(FEEGD1Run); 
    FEEGD1RMS = util_stdNan(FEEGD1Run)/abs(FEEGD1Mean);
    
    %1FEEGD2Run = circshift(FEEGD2Run,[0,-1]);
    try
         val = (lcaGet('GDET:FEE1:361:ENRCHSTBR') + lcaGet('GDET:FEE1:362:ENRCHSTBR'))/2 ;
    catch
        dispStr('Error on lcaGet for GDET:FEE1:361:ENRCHSTBR or GDET:FEE1:362:ENRCHSTBR')
        val = zeros(1,nCalc);
    end        
    FEEGD2Run(:,:) = val(end-nCalc+1:end);
    FEEGD2Mean = mean(FEEGD2Run); 
    FEEGD2RMS = util_stdNan(FEEGD2Run)/abs(FEEGD2Mean);
        

    %Photon energy
    PhotonEngyRun = circshift(PhotonEngyRun,[0,-1]);
    try PhotonEngyRun(:,RunNum) = lcaGetSmart('SIOC:SYS0:ML00:AO627'); %Was 625 but that one is broken
    catch fprintf('%s Error on lcaGet of Photon Energy PV: SIOC:SYS0:ML00:AO625\n',datestr(now))
    end
    PhotonEngyMean = mean(PhotonEngyRun);
    PhotonEngyRMS =  util_stdNan(PhotonEngyRun)/abs(PhotonEngyMean);
    
    % Check for beam at all injector BPMs
    if ~(all(iokInj))                       
        logStatus('Error reading Injector BPMs');
        %--dips(handles.tstr);
        pause(handles.wait);
        msgStr = 'No Inj BPM Signal: Waiting for beam...';
        try lcaPut('SIOC:SYS0:ML00:CA003' ,double(int8(msgStr))); 
           catch fprintf('%s Failed to write to SIOC:SYS0:ML00:CA003\n', datestr(now));
        end
        logStatus('No Inj BPM Signal: Waiting for beam...');
        continue
    end

    % Count successful run in injector
    count = count+1;    

    % Check for beam at all sector 28/Und BPMs
    if ~(all(iok28Und))                       
        %dispStr('Error reading Sector 28/Und BPMs');
        %dispStr(handles.tstr);
        %logStatus('No beam in sector 28/Und'); 
        status28Und = 0;
        countUnd = 0;
        countLTU = 0;
        count28 = 0;        
    end


 

    % Update register with new inj XY jitter values
    %1 XsInj = circshift(XsInj,[-1,0]);
    %1 YsInj = circshift(YsInj,[-1,0]);      
    %1 ioksInj = circshift(ioksInj,[-1,0]);        
    XsInj  =  XInj';                
    YsInj  =  YInj';                
    ioksInj = iokInj';  

    % Update sector 28/Und jitters only if beam seen there
    if status28Und
        if statusUnd
            %1 XsUnd = circshift(XsUnd,[-1,0]);
            %1 YsUnd = circshift(YsUnd,[-1,0]);      
            %1 ioksUnd = circshift(ioksUnd,[-1,0]);        
            XsUnd  =  X28Und';                
            YsUnd  =  Y28Und';                
            ioksUnd = iok28Und'; 
            % Count successful run in sector 28/Und
            countUnd = RunNum; %Using BSA! countUnd + status28Und;   
        elseif statusLTU
            %1 XsLTU = circshift(XsLTU,[-1,0]);
            %1 YsLTU = circshift(YsLTU,[-1,0]);      
            %1 ioksLTU = circshift(ioksLTU,[-1,0]);        
            XsLTU  =  X28Und';                
            YsLTU  =  Y28Und';                
            ioksLTU = iok28Und';         
            % Count successful run in sector 28/Und
            countLTU = RunNum; % Using BSA! countLTU + status28Und;             
        else   
            %1Xs28 = circshift(Xs28,[-1,0]);
            %1 Ys28 = circshift(Ys28,[-1,0]);      
            %1 ioks28 = circshift(ioks28,[-1,0]);        
            Xs28  =  X28Und';                
            Ys28  =  Y28Und';                
            ioks28 = iok28Und';  
            % Count successful run in sector 28/Und
            count28 = RunNum; %1 Using BSA! count28 + status28Und;             
        end
    end


    %dat_time1 = toc;
    
    % If register not full yet, restart loop
    count = RunNum; %Using BSA!
    if count < RunNum
        dispStr(RunNum - count)
        logStatus(['Loading buffer. Runs left: ',num2str(RunNum-count)]);            
        pause(handles.wait)
        pause(1/rate)        
        continue
    else
        pause(handles.wait + 1/(rate+1))
    end

    % Update status in GUI
    if ~status28Und
        logStatus('Running in injector, no beam in sector 28/Und'); 
    elseif count28Und<RunNum 
        logStatus('Running in injector, buffering in sector 28/Und');    
    else
        logStatus('Running...');             
    end

    %'Inj XY Mark'

    % Calculate injector XY jitter
    try
    [XInjRMS,YInjRMS,uvxInj,duxInj,dvxInj,uvyInj,duyInj,dvyInj] = XYJitter_loop(XYInjBPM_pvs,RunNum,XsInj,YsInj,ioksInj,JSetInj);  
    catch 
        keyboard
    end


    %'28Und XY Mark'

    % If buffer full in sector 28/Und, calculate 28/Und jitter        

    if statusUnd && countUnd>= RunNum
        [X28UndRMS,Y28UndRMS,uvx28Und,dux28Und,dvx28Und,uvy28Und,duy28Und,dvy28Und] = ...
            XYJitter_loop(XYUndBPM_pvs,RunNum,XsUnd,YsUnd,ioksUnd,JSetUnd);
        count28Und = RunNum;
    elseif statusLTU && countLTU>= RunNum
        [X28UndRMS,Y28UndRMS,uvx28Und,dux28Und,dvx28Und,uvy28Und,duy28Und,dvy28Und] = ...
            XYJitter_loop(XYLTUBPM_pvs,RunNum,XsLTU,YsLTU,ioksLTU,JSetLTU);
        count28Und = RunNum;
    elseif count28>= RunNum
        [X28UndRMS,Y28UndRMS,uvx28Und,dux28Und,dvx28Und,uvy28Und,duy28Und,dvy28Und] = ...
            XYJitter_loop(XY28BPM_pvs,RunNum,Xs28,Ys28,ioks28,JSet28);            
        count28Und = RunNum;          
    end



    % total time to read BPMs, etc.
    %dat_time = toc;

    % times for measurements in register 
    %mytime = (-(RunNum-1)*(handles.wait+dat_time):(handles.wait+dat_time):0);           
    mytime = (-(RunNum-1)*handles.wait:handles.wait:0);       



    %'Data Formatting Mark'

    ERMS = ERMS*100;    % Convert ERMS to percent
    TRMS = TRMS*100;    % Convert TRMS to percent
    XUVLasRMS = XUVLasRMS*100;
    YUVLasRMS = YUVLasRMS*100;
    UVLasPowRMS = UVLasPowRMS*100;    
    XIRLasRMS = XIRLasRMS*100;
    YIRLasRMS = YIRLasRMS*100;    
    IRLasPowRMS = IRLasPowRMS*100;        
    XInjRMS = XInjRMS*100;
    YInjRMS = YInjRMS*100;
    LBC1RMS = LBC1RMS*100;
    LBC2RMS = LBC2RMS*100;
    FEEGD1RMS = FEEGD1RMS*100;
    FEEGD2RMS = FEEGD2RMS*100;
    PhotonEngyRMS = PhotonEngyRMS*100;
    
    if count28Und>=RunNum 
        X28UndRMS = X28UndRMS*100;
        Y28UndRMS = Y28UndRMS*100;
    end
    % History register used to make strip chart          
    EHist = circshift(EHist,[0,-1]);        % shift history register of Energy RMS values
    EHist(:,RunNum) = ERMS;                 % update latest ERMS value in register
    THist = circshift(THist,[0,-1]);        % shift history register of Charge RMS values
    THist(RunNum) = TRMS;                   % update latest TRMS value in register
    XUVLasHist = circshift(XUVLasHist,[0,-1]);       
    XUVLasHist(:,RunNum) = XUVLasRMS;   
    YUVLasHist = circshift(YUVLasHist,[0,-1]);       
    YUVLasHist(:,RunNum) = YUVLasRMS;        
    UVLasPowHist = circshift(UVLasPowHist,[0,-1]);       
    UVLasPowHist(:,RunNum) = UVLasPowRMS;   
    XIRLasHist = circshift(XIRLasHist,[0,-1]);       
    XIRLasHist(:,RunNum) = XIRLasRMS;   
    YIRLasHist = circshift(YIRLasHist,[0,-1]);       
    YIRLasHist(:,RunNum) = YIRLasRMS;        
    IRLasPowHist = circshift(IRLasPowHist,[0,-1]);       
    IRLasPowHist(:,RunNum) = IRLasPowRMS;       
    LBC1Hist = circshift(LBC1Hist,[0,-1]);
    LBC1Hist(RunNum) = LBC1RMS;
    LBC2Hist = circshift(LBC2Hist,[0,-1]);
    LBC2Hist(RunNum) = LBC2RMS;
    XHistInj = circshift(XHistInj,[0,-1]);
    XHistInj(RunNum) = XInjRMS;
    YHistInj = circshift(YHistInj,[0,-1]);
    YHistInj(RunNum) = YInjRMS;    
    if count28Und>=RunNum 
        XHist28Und = circshift(XHist28Und,[0,-1]);
        XHist28Und(RunNum) = X28UndRMS;
        YHist28Und = circshift(YHist28Und,[0,-1]);
        YHist28Und(RunNum) = Y28UndRMS;    
    end
    
 
    handles.mytime = mytime; 
    handles.EHist = EHist;
    handles.THist = THist;
    handles.XUVLasHist = XUVLasHist;
    handles.YUVLasHist = YUVLasHist; 
    handles.UVLasPowHist = UVLasPowHist;   
    handles.XIRLasHist = XIRLasHist;
    handles.YIRLasHist = YIRLasHist; 
    handles.IRLasPowHist = IRLasPowHist;       
    handles.LBC1Hist = LBC1Hist;
    handles.XHistInj = XHistInj;
    handles.YHistInj = YHistInj;
    handles.XHist28Und = XHist28Und;
    handles.YHist28Und = YHist28Und;    
    handles.uvxInj = uvxInj;
    handles.duxInj = duxInj;
    handles.dvxInj = dvxInj;
    handles.uvyInj = uvyInj;
    handles.duyInj = duyInj;
    handles.dvyInj = dvyInj;
        handles.LBC2Hist = LBC2Hist;     
    if count28Und>=RunNum 
        handles.uvx28Und = uvx28Und;
        handles.dux28Und = dux28Und;
        handles.dvx28Und = dvx28Und;
        handles.uvy28Und = uvy28Und;
        handles.duy28Und = duy28Und;
        handles.dvy28Und = dvy28Und;    
   
    end

    % Add to handles (all digits used for PV)
    handles.ERMS = ERMS;     
    handles.TRMS = TRMS;   
    if isnan(XUVLasRMS), XUVLasRMS = 0; end
    handles.XUVLasRMS = XUVLasRMS;
    if isnan(YUVLasRMS), YUVLasRMS = 0; end
    handles.YUVLasRMS = YUVLasRMS;
    
    handles.UVLasPowRMS = UVLasPowRMS;
    handles.UVLasPowMean = UVLasPowMean;
    if isnan(XIRLasRMS), XIRLasRMS = 0; end
    handles.XIRLasRMS = XIRLasRMS;
    if isnan(YIRLasRMS), YIRLasRMS = 0; end
    handles.YIRLasRMS = YIRLasRMS;
    handles.IRLasPowRMS = IRLasPowRMS;
    handles.IRLasPowMean = IRLasPowMean;       
    handles.XInjRMS = XInjRMS;
    handles.YInjRMS = YInjRMS;
    handles.LBC1RMS = LBC1RMS;
    handles.LBC2RMS = LBC2RMS;
    handles.LBC1Mean = LBC1Mean; 
    handles.LBC2Mean = LBC2Mean;      
    handles.FEEGD1RMS = FEEGD1RMS;
    handles.FEEGD2RMS = FEEGD2RMS;
    handles.PhotonEngyRMS = PhotonEngyRMS; 
    if count28Und>=RunNum 
        handles.X28UndRMS = X28UndRMS;
        handles.Y28UndRMS = Y28UndRMS;
 
    end
    
    handles.count28Und = count28Und;
    handles.RunNum = RunNum;
    %SetWarnings(hObject, eventdata, handles)
    
    
    % Pare down digits for GUI
    ERMS = round(ERMS*1000)/1000;
    TRMS = round(TRMS*100)/100;
    LasRMS = round(LasRMS*1000)/1000;    
    XUVLasRMS = round(XUVLasRMS*100)/100;
    YUVLasRMS = round(YUVLasRMS*100)/100;
    UVLasPowRMS = round(UVLasPowRMS*100)/100; 
    XIRLasRMS = round(XIRLasRMS*100)/100;
    YIRLasRMS = round(YIRLasRMS*100)/100;
    IRLasPowRMS = round(IRLasPowRMS*100)/100;     
    XInjRMS = round(XInjRMS*100)/100;
    YInjRMS = round(YInjRMS*100)/100;
    LBC1RMS = round(LBC1RMS*100)/100; 
    LBC1Mean = round(LBC1Mean);
        LBC2RMS = round(LBC2RMS*100)/100;
        LBC2Mean = round(LBC2Mean);
    if count28Und>=RunNum     
        X28UndRMS = round(X28UndRMS*100)/100;
        Y28UndRMS = round(Y28UndRMS*100)/100;    

    end
    
%     %MMM
%     loop_time = toc;
%     
%     % Pause before taking more data.  Subtract off read time from total
%     % wait time
%     pause(handles.wait-loop_time);   
% continue  %MMM

    %----------------------- write values to GUImytime,XUVLasHist,mytime,YUVLasHist,
%     set(handles.DLRMS,'String',num2str(ERMS(2)));
%     set(handles.BC1RMS,'String',num2str(ERMS(3)));    
%     set(handles.BC2RMS,'String',num2str(ERMS(4)));
%     set(handles.BSYRMS,'String',num2str(ERMS(5)));
%     set(handles.DLTMIT,'String',num2str(TRMS));  
%     set(handles.LASRMS,'String',num2str(LasRMS));      
%     set(handles.XUV_RMS,'String',num2str(XUVLasRMS));  
%     set(handles.YUV_RMS,'String',num2str(YUVLasRMS)); 
%     set(handles.UVLASPOWRMS,'String',num2str(UVLasPowRMS));   
%     set(handles.XIR_RMS,'String',num2str(XIRLasRMS));  
%     set(handles.YIR_RMS,'String',num2str(YIRLasRMS)); 
%     set(handles.IRLASPOWRMS,'String',num2str(IRLasPowRMS));       
%     set(handles.XINJ_RMS,'String',num2str(XInjRMS));
%     set(handles.YINJ_RMS,'String',num2str(YInjRMS));    
%     set(handles.LBC1_RMS,'String',num2str(LBC1RMS));    
%     set(handles.LBC1MEAN,'String',num2str(LBC1Mean));        
%         set(handles.LBC2_RMS,'String',num2str(LBC2RMS));
%         set(handles.LBC2MEAN,'String',num2str(LBC2Mean));  
%     if count28Und>=RunNum 
%         set(handles.X28_RMS,'String',num2str(X28UndRMS));
%         set(handles.Y28_RMS,'String',num2str(Y28UndRMS));         
%        
%     end

   
    %'lcaPut Mark'

    % write Energy RMS and TMIT with corresponding times to PVs
    % Change PV precision in MATLAB using, for example: 
    % lcaPut('SIOC:SYS0:ML00:AO170.PREC',3)
    try  lcaPut('SIOC:SYS0:ML00:AO170',handles.ERMS(2));
    catch dispStr('Error writing to PV: SIOC:SYS0:ML00:AO170');
          dispStr(['Val: ',num2str(handles.ERMS(2))]);         
    end
    try lcaPut('SIOC:SYS0:ML00:SO0170',handles.tstr)
    catch dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0170');        
    end
    try lcaPut('SIOC:SYS0:ML00:AO171',handles.ERMS(3));
    catch  dispStr('Error writing to PV: SIOC:SYS0:ML00:AO171');
           dispStr(['Val: ',num2str(handles.ERMS(3))]);           
    end
    try lcaPut('SIOC:SYS0:ML00:SO0171',handles.tstr)    
    catch dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0171');
    end
    try lcaPut('SIOC:SYS0:ML00:AO172',handles.ERMS(4));
    catch  dispStr('Error writing to PV: SIOC:SYS0:ML00:AO172');
           dispStr(['Val: ',num2str(handles.ERMS(4))]);           
    end
    try lcaPut('SIOC:SYS0:ML00:SO0172',handles.tstr)
    catch  dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0172');
    end        
    try lcaPut('SIOC:SYS0:ML00:AO173',handles.ERMS(5));  
    catch  dispStr('Error writing to PV: SIOC:SYS0:ML00:AO173');
           dispStr(['Val: ',num2str(handles.ERMS(5))]);         
    end
    try lcaPut('SIOC:SYS0:ML00:SO0173',handles.tstr)
    catch dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0173');
    end
    try lcaPut('SIOC:SYS0:ML00:AO174',handles.TRMS);   
    catch  dispStr('Error writing to PV: SIOC:SYS0:ML00:AO174');
          dispStr(['Val: ',num2str(handles.TRMS)]);         
    end
    try lcaPut('SIOC:SYS0:ML00:SO0174',handles.tstr)    
    catch  dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0174');
    end
    try lcaPut('SIOC:SYS0:ML00:AO175',1.602E-10*handles.Tmean)    % Charge in pC         
    catch dispStr('Error writing to PV: SIOC:SYS0:ML00:AO175');
          dispStr(['Val: ',num2str(handles.Tmean)]);         
    end
    try lcaPut('SIOC:SYS0:ML00:SO0175',handles.tstr)    
    catch dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0175');
    end
    try  lcaPut('SIOC:SYS0:ML00:AO176',handles.XInjRMS);   
    catch dispStr('Error writing to PV: SIOC:SYS0:ML00:AO176');
          dispStr(['Val: ',num2str(handles.XInjRMS)]);          
    end
    try lcaPut('SIOC:SYS0:ML00:SO0176',handles.tstr)    
    catch dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0176');
    end
    try  lcaPut('SIOC:SYS0:ML00:AO177',handles.YInjRMS);   
    catch dispStr('Error writing to PV: SIOC:SYS0:ML00:AO177');
          dispStr(['Val: ',num2str(handles.YInjRMS)]);  
    end
    try lcaPut('SIOC:SYS0:ML00:SO0177',handles.tstr)    
    catch  dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0177');
    end    
    if count28Und>=RunNum 
        try lcaPut('SIOC:SYS0:ML00:AO178',min(handles.X28UndRMS,123.45));   
        catch dispStr('Error writing to PV: SIOC:SYS0:ML00:AO178');
              dispStr(['Val: ',num2str(handles.X28UndRMS)]);
        end
        try lcaPut('SIOC:SYS0:ML00:SO0178',handles.tstr), catch dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0178');  end
        try  lcaPut('SIOC:SYS0:ML00:AO179',min(handles.Y28UndRMS,123.45));   
        catch dispStr('Error writing to PV: SIOC:SYS0:ML00:AO179');
              dispStr(['Val: ',num2str(handles.Y28UndRMS)]);
        end
        try lcaPut('SIOC:SYS0:ML00:SO0179',handles.tstr) ,catch  dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0179'); end    
    end
    try lcaPut('SIOC:SYS0:ML00:AO180',handles.LBC1RMS);   
    catch dispStr('Error writing to PV: SIOC:SYS0:ML00:AO180');
          dispStr(['Val: ',num2str(handles.LBC1RMS)]);
    end
    try  lcaPut('SIOC:SYS0:ML00:SO0180',handles.tstr), catch dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0180');  end  
    try  lcaPut('SIOC:SYS0:ML00:AO181',handles.LBC1Mean);   
    catch dispStr('Error writing to PV: SIOC:SYS0:ML00:AO181');
          dispStr(['Val: ',num2str(handles.LBC1Mean)]);
    end
    try lcaPut('SIOC:SYS0:ML00:SO0181',handles.tstr), catch dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0181');  end
%     if (count28Und>=RunNum && isfinite(LBC2RMS))  
    try
        lcaPut('SIOC:SYS0:ML00:AO182',handles.LBC2RMS);   
    catch
        dispStr('Error writing to PV: SIOC:SYS0:ML00:AO182');
        dispStr(['Val: ',num2str(handles.LBC2RMS)]);
    end
    try  lcaPut('SIOC:SYS0:ML00:SO0182',handles.tstr); catch dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0182');  end  
    try lcaPut('SIOC:SYS0:ML00:AO183',handles.LBC2Mean);   
    catch dispStr('Error writing to PV: SIOC:SYS0:ML00:AO183');
          dispStr(['Val: ',num2str(handles.LBC2Mean)]); 
    end
    try lcaPut('SIOC:SYS0:ML00:SO0183',handles.tstr) ; catch  dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0183');  end         
%     end
    
    % FEE gas detectors
    try lcaPut('SIOC:SYS0:ML00:AO640',FEEGD1RMS), catch dispStr('Error writing to PV: SIOC:SYS0:ML00:AO640 FEEGD1RMS'), end
    try lcaPut('SIOC:SYS0:ML00:AO641',FEEGD2RMS), catch dispStr('Error writing to PV: SIOC:SYS0:ML00:AO641 FEEGD2RMS'), end
    % Photon Energy
    try lcaPut('SIOC:SYS0:ML00:AO642',PhotonEngyRMS), catch dispStr('Error writing to PV: SIOC:SYS0:ML00:AO642 PhotonEngyRMS) '), end
    % Laser
    try lcaPut('SIOC:SYS0:ML00:AO184',handles.XUVLasRMS);   
    catch
        dispStr('Error writing to PV: SIOC:SYS0:ML00:AO184');
        dispStr(['Val: ',num2str(handles.XUVLasRMS)]);
    end
    try lcaPut('SIOC:SYS0:ML00:SO0184',handles.tstr), catch dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0184'); end
    try lcaPut('SIOC:SYS0:ML00:AO185',handles.YUVLasRMS);  
    catch dispStr('Error writing to PV: SIOC:SYS0:ML00:AO185');
          dispStr(['Val: ',num2str(handles.YUVLasRMS)]);
    end
    try  lcaPut('SIOC:SYS0:ML00:SO0185',handles.tstr),  catch dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0185'); end      
    try lcaPut('SIOC:SYS0:ML00:AO186',handles.UVLasPowRMS); 
    catch dispStr('Error writing to PV: SIOC:SYS0:ML00:AO186');
          dispStr(['Val: ',num2str(handles.UVLasPowRMS)]);
    end
    try  lcaPut('SIOC:SYS0:ML00:SO0186',handles.tstr) ; catch dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0186');end    
    try  lcaPut('SIOC:SYS0:ML00:AO187',handles.UVLasPowMean);   
    catch
        dispStr('Error writing to PV: SIOC:SYS0:ML00:AO187');
        dispStr(['Val: ',num2str(handles.UVLasPowMean)]);
    end
    try lcaPut('SIOC:SYS0:ML00:SO0187',handles.tstr); catch  dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0187'); end      
    try lcaPut('SIOC:SYS0:ML00:AO501',handles.XIRLasRMS);   
    catch
        dispStr('Error writing to PV: SIOC:SYS0:ML00:AO501');
        dispStr(['Val: ',num2str(handles.XIRLasRMS)]);
    end
    try lcaPut('SIOC:SYS0:ML00:SO0501',handles.tstr); catch dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0501');  end
    try lcaPut('SIOC:SYS0:ML00:AO502',handles.YIRLasRMS);   
    catch
        dispStr('Error writing to PV: SIOC:SYS0:ML00:AO502');
        dispStr(['Val: ',num2str(handles.YIRLasRMS)]);
    end
    try lcaPut('SIOC:SYS0:ML00:SO0502',handles.tstr); catch  dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0502'); end      
    try lcaPut('SIOC:SYS0:ML00:AO503',handles.IRLasPowRMS);   
    catch
        dispStr('Error writing to PV: SIOC:SYS0:ML00:AO503');
        dispStr(['Val: ',num2str(handles.IRLasPowRMS)]);
    end
    try lcaPut('SIOC:SYS0:ML00:SO0503',handles.tstr); catch  dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0503');  end    
    try lcaPut('SIOC:SYS0:ML00:AO504',handles.IRLasPowMean);   
    catch
        dispStr('Error writing to PV: SIOC:SYS0:ML00:AO504');
        dispStr(['Val: ',num2str(handles.IRLasPowMean)]);
    end
    try lcaPut('SIOC:SYS0:ML00:SO0504',handles.tstr); catch  dispStr('Error writing to PV: SIOC:SYS0:ML00:SO0504'); end      
    
    
    %--guidata(hObject, handles);    
    
    loop_time = toc;
    
    % Pause before taking more data.  Subtract off read time from total
    % wait time
    pause(handles.wait-loop_time);   
    

    %'finished loop'
end
end

    
function JSet = XYJitter_Setup(BPM_pvs,Nsamp, destinationFlag)
if ~exist('rate','var')
  try
    [sys,accelerator]=getSystem();
    rate = lcaGetSmart(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);  % rep. rate [Hz]
  catch
    dispStr(['Error on lcaGet for EVNT:' sys ':1:' accelerator 'BEAMRATE - defaulting to 1 Hz rate.'])
    rate = 1;
  end
  if rate < 1
    rate = 1;
  end
end

if ~exist('norbit','var')
  norbit = 1;
end

JSet.ifit = [1 1 1 1 0];                     % fit x0, x0', y0, y0'
gex  = 1.2E-6;
gey  = 1.2E-6;
mc2  = 511E-6;

nbpms = length(BPM_pvs);
BPM_micrs = zeros(nbpms,4);
BPM_units = zeros(nbpms,1);
energy = zeros(nbpms,1);
betax  = zeros(nbpms,1);
alfax  = zeros(nbpms,1);
betay  = zeros(nbpms,1);
alfay  = zeros(nbpms,1);
etax   = zeros(nbpms,1);

% % Prayers to the aida Gods
%aidainit;
%err = Err.getInstance('xalModelDemo');
%d = DaObject();
%d.setParam('TYPE','DATABASE');
  
global modelSource;
modelSource='MATLAB';

lemEnergy = model_energySetPoints;lemEnergy=lemEnergy(5);
%lemEnergy = lcaGetSmart('SIOC:SYS0:ML00:AO409');
for j = 1:nbpms
  BPM_SLC_name = model_nameConvert(BPM_pvs{j},'SLC');
  BPM_micrs(j,:) = BPM_SLC_name(6:9);
  BPM_units(j)   = str2int(BPM_SLC_name(11:end));
  try
    %twiss2 = aidaget([BPM_SLC_name '//twiss'],'doublea',{'TYPE=DATABASE'});
    twiss = model_rMatGet(BPM_pvs{j},[],'TYPE=DESIGN','twiss');
  catch
    dispStr(['You have angered the EPICS Gods by asking for twiss params from ',BPM_pvs{j}]); 
  end
  %twiss = cell2mat(twiss); 
  switch destinationFlag
      case 'INJ_SET', energy(j) = twiss(1,:);
      case 'BSY_SET', energy(j) = lemEnergy; %twiss(1,:);
      otherwise fprintf('%s XYJitter_Setup: Wrong Destination Flag\n', datestr(now));
  end
 
  betax(j)  = twiss(3,:);
  alfax(j)  = twiss(4,:);
  betay(j)  = twiss(8,:);
  alfay(j)  = twiss(9,:);
  etax(j)   = twiss(5,:);
end




r=model_rMatGet(BPM_pvs{end},BPM_pvs);    
JSet.R1s = permute(r(1,[1 2 3 4 6],:),[3 2 1]);
JSet.R3s = permute(r(3,[1 2 3 4 6],:),[3 2 1]);



JSet.ex = gex*mc2/energy(end);
JSet.ey = gey*mc2/energy(end);
JSet.bx = betax(end);
JSet.by = betay(end);
JSet.ax = alfax(end);
JSet.ay = alfay(end);

% [JSet.R1s,JSet.R3s,JSet.Zs,JSet.Zs0] = ...
%         ('BPMS',BPM_micrs(end,1:4),BPM_units(end),BPM_micrs,BPM_units);





    
% JSet.R1s = zeros(nbpms,5);
% JSet.R3s = zeros(nbpms,5);
% d.setParam('TYPE','DATABASE');
% for j = 1:nbpms
%   try
%     R = d.geta([BPM_pvs{j} '//R'], 54);
%   catch
%     dispStr(['You have angered the AIDA Gods by asking for the R matrix from',BPM_pvs{j}]); 
%   end
%   Rm       = reshape(double(R),6,6);
%   Rm       = Rm';
%   JSet.R1s(j,:) = Rm(1,[1:4,6]);
%   JSet.R3s(j,:) = Rm(3,[1:4,6]);
% end
% d.reset();   


     
    
   
navg = 1;
% [X0,Y0,T0] = read_BPMsSmart(BPM_pvs,navg,rate);  % read all BPMs, X, Y, & TMIT with averaging
% %Xs0  =  X0;                 % mean X-position for all BPMs [mm]
% %Ys0  =  Y0;                 % mean Y-position for all BPMs [mm]
% %Ts0  =  1.602E-10*T0;       % mean charge for all BPMs [nC]
% if all(T0==0)
%   disp('No beam')
%   Xsf=0;
%   Ysf=0;
%   ps=0;
%   dps=0;
%   uvx=0;
%   uvy=0;
%   dux=0;
%   dvx=0;
%   duy=0;
%   dvy=0;
%   guidata(hObject, handles);
%   return
% end
%--guidata(hObject, handles);
end


function [Xstd,Ystd,uvx,dux,dvx,uvy,duy,dvy] = XYJitter_loop(BPM_pvs, Nsamp,Xs,Ys,ioks,JSet)


R1s = JSet.R1s;
R3s = JSet.R3s;
%Zs = JSet.Zs;
%Zs0 = JSet.Zs0;
ifit = JSet.ifit;
ex = JSet.ex;
ey = JSet.ey;
bx = JSet.bx;
by = JSet.by;
ax = JSet.ax;
ay = JSet.ay;


nbpms = length(BPM_pvs);
Xsf  = zeros(Nsamp,nbpms);
Ysf  = zeros(Nsamp,nbpms);
ps   = zeros(Nsamp,sum(ifit));
dps  = zeros(Nsamp,sum(ifit));
dps12= zeros(Nsamp,1);
dps34= zeros(Nsamp,1);


% tstr = get_time;

Xs0 = mean(Xs);
Ys0 = mean(Ys);

dXs = Xs - ones(Nsamp,1)*Xs0;
dYs = Ys - ones(Nsamp,1)*Ys0;


%Xs;
%Ys;
%BPM_pvs;

for j = 1:Nsamp
    try
    [Xf,Yf,p,dp,chisq,Q,Vv] = ...
      xy_traj_fit(dXs(j,ioks(j,:)&1),1,dYs(j,ioks(j,:)&1),1,0*dXs(j,ioks(j,:)&1),0*dYs(j,ioks(j,:)&1),R1s(ioks(j,:)&1,:),R3s(ioks(j,:)&1,:),ifit);	% fit trajectory
    
    Xsf(j,ioks(j,:)&1) = Xf;
    Ysf(j,ioks(j,:)&1) = Yf;
    ps(j,:)  = p;
    dps(j,:) = dp;
    V = reshape(Vv,sum(ifit),sum(ifit));
    dps12(j,:) = V(1,2);
    dps34(j,:) = V(3,4);
    catch
        %fprintf('%s bad fit in xy_traj_fit\n', datestr(now));
        
    end
    
end




Xax = JSet.X_AX;
ii = 1:Nsamp;
iQx = [1 0; ax bx]/sqrt(ex*bx);
uvx = 1E-3*iQx*[ps(ii,1)'; ps(ii,2)'];
dux = 1E-3*dps(ii,1)/sqrt(ex*bx);
dvx = 1E-3*sqrt(( ax^2*dps(ii,1).^2 + bx^2*dps(ii,2).^2 + ax*bx*dps12(ii) ))/sqrt(ex*bx);
%--plot_bars2_parent(uvx(1,:)',uvx(2,:)',dux,dvx,'.b',Xax)
%--hold(Xax,'on');
rx = sqrt(uvx(1,:).^2 + uvx(2,:).^2);



%--plot(uvx(1,:)',uvx(2,:)','.b','parent',Xax)
%title(Xax,'\it{x}')
%--xlabel(Xax,'\it{x}')
%--ylabel(Xax,'\it{x}''')
%--plot_ellipse_parent([1 0; 0 1],Xax)
%--hor_line_parent(Xax)
%--ver_line_parent(Xax)
% ver_line
% title(['RMS {\itA_{xN}}=' sprintf('%3.1f%%; ',100*util_stdNan(rx)) ' BPM ' BPM_micrs(end,1:4) ' ' int2str(BPM_units(end))])
% enhance_plot('times',16,1,15)
%--hold(Xax,'off')
%--axis(Xax,'equal');



%--Yax = JSet.Y_AX;
iQy = [1 0; ay by]/sqrt(ey*by);
uvy = 1E-3*iQy*[ps(ii,3)'; ps(ii,4)'];
duy = 1E-3*dps(ii,3)/sqrt(ey*by);
dvy = 1E-3*sqrt(( ay^2*dps(ii,3).^2 + by^2*dps(ii,4).^2 + ay*by*dps34(ii) ))/sqrt(ey*by);
%--plot_bars2_parent(uvy(1,:)',uvy(2,:)',duy,dvy,'.g',Yax)
%--hold(Yax,'on');
ry = sqrt(uvy(1,:).^2 + uvy(2,:).^2);
%--plot(uvy(1,:)',uvy(2,:)','.g','parent',Yax)
%title(Yax,'\it{y}')
%--xlabel(Yax,'\it{y}')
%--ylabel(Yax,'\it{y}''')
%--plot_ellipse_parent([1 0; 0 1],Yax)
%--hor_line_parent(Yax)
%--ver_line_parent(Yax)
% title(['RMS {\itA_{yN}}=' sprintf('%3.1f%%; ',100*util_stdNan(ry)) tstr])
% enhance_plot('times',16,1,15)
%--hold(Yax,'off')
%--axis(Yax,'equal')

switch Xax,
    case 'XJITTERAX_INJ', lcaPutSmart('CUD:MCC0:WFRM:JITTER1',uvx(1,1:20)); lcaPutSmart('CUD:MCC0:WFRM:JITTER2',uvx(2,1:20));
                          lcaPutSmart('CUD:MCC0:WFRM:JITTER3',uvy(1,1:20)); lcaPutSmart('CUD:MCC0:WFRM:JITTER4',uvy(2,1:20));
    case 'XJITTERAX_28' , lcaPutSmart('CUD:MCC0:WFRM:JITTER5',uvx(1,1:20)); lcaPutSmart('CUD:MCC0:WFRM:JITTER6',uvx(2,1:20));
                          lcaPutSmart('CUD:MCC0:WFRM:JITTER7',uvy(1,1:20)); lcaPutSmart('CUD:MCC0:WFRM:JITTER8',uvy(2,1:20));
    otherwise, logStatus(['Warning: Bad value for Xax: "', Xax, '" Ellipse plots not updated']); 
end


Xstd = util_stdNan(rx);
Ystd = util_stdNan(ry);


%if(Xstd > 100), keyboard, end
end

function logStatus(statString)
persistent oldStatString 
if (~exist('oldStatString','var')), oldStatString = 'none'; end

if (~strcmp(statString, oldStatString))
    msgStr = sprintf('%s %s',datestr(now), statString);
    disp(msgStr)
    lcaPutSmart('SIOC:SYS0:ML00:CA003' ,double(int8(msgStr))); 
end
oldStatString = statString;
end

function dispStr(aString)

  disp([datestr(now), ' ', num2str(aString)])
end

function [X,Y,T,dX,dY,dT,iok] = read_BPMsBSA(BPM_pv_list,navg,rate, nCalc)

%   [X,Y,T,dX,dY,dT,iok] = read_BPMsBSA(BPM_pv_list,navg,rate);
%
%   Function to read a list of BPMs in X, Y, and TMIT with averaging and
%   beam status returned.
%
%   INPUTS:     BPM_pv_list:    An array list of BPM PVs (cell or character array, transposed OK)
%                               (e.g., [{'BPMS:IN20:221'  'BPMS:IN20:731'}]')
%               navg:           Not used! and set to 1. Future: Number of shots to average (e.g., navg=5)
%               rate:           Pause 1/rate between BPM reads [Hz] (e.g., rate=10 Hz)
%
%   OUTPUTS:    X:              BPM X readings (nCalc per BPM) after averaging (YES incl. TMIT=0 pulses) [mm]
%               Y:              BPM Y readings (nCalc per BPM) after averaging (YES incl. TMIT=0 pulses) [mm]
%               T:              BPM TMIT readings (nCalc per BPM) after averaging (YES incl. TMIT=0 pulses) [ppb]
%               dX:             Standard error on mean of BPM X readings (1 per BPM) after averaging (YES incl. TMIT=0 pulses) [mm]
%               dY:             Standard error on mean of BPM Y readings (1 per BPM) after averaging (YES incl. TMIT=0 pulses) [mm]
%               dT:             Standard error on mean of BPM TMIT readings (1 per BPM) after averaging (YES incl. TMIT=0 pulses) [ppb]
%               iok:            iok always 1 for now. %Readback status based on TMIT (1 per BPM): (iok=0 per BPM if no beam on it)

%====================================================================================================
if navg ~= 1, fprintf('Warning: averages not implemented \n'); end


[nbpms,c] = size(BPM_pv_list);
if iscell(BPM_pv_list)          % if BPM pv list is a cell array...
  if c>1 && nbpms>1             % ...if cell is a matrix, quit
    error('Must use cell array for BPM PV input list')
  elseif c>1                    % if cell is transposed...
    nbpms = c;                  % ...fix it
    BPM_pv_list = BPM_pv_list';
  end
else                            % if NOT a cell...
  BPM_pv_list = {BPM_pv_list};  % ...make it a cell
end

pvlist = {};
for j = 1:nbpms
  pvlist{3*j-2,1} = [BPM_pv_list{j,:} ':XHSTBR'];
  pvlist{3*j-1,1} = [BPM_pv_list{j,:} ':YHSTBR'];
  pvlist{3*j  ,1} = [BPM_pv_list{j,:} ':TMITHSTBR'];
end

Xs  = zeros(navg,nbpms);
Ys  = zeros(navg,nbpms);
Ts  = zeros(navg,nbpms);
X   = zeros(1,nbpms);
Y   = zeros(1,nbpms);
T   = zeros(1,nbpms);
dX  = zeros(1,nbpms);
dY  = zeros(1,nbpms);
dT  = zeros(1,nbpms);
iok = zeros(1,nbpms);

% rate should be greater than 1
if rate < 1
    return;
end

%for jj = 1:navg
% Get BSA data
  try
    data = lcaGetSmart(pvlist,0,'double');    % read X, Y, and TMIT of all BPMs 
  catch
    disp('Error with lcaGetSmart in read_BPMsSmart')
  end

  %pause(1/rate);
  %pause(.02);
  X = data(1:3:end,end-nCalc+1:end) ; %uses last nCalc of buffer
  Y = data(2:3:end,end-nCalc+1:end) ;
  T = data(3:3:end,end-nCalc+1:end) ;
  dX = util_stdNan(X,0,2)/sqrt(nCalc); %std normalized by N-1
  dY = util_stdNan(Y,0,2)/sqrt(nCalc);
  dT = util_stdNan(T,0,2)/sqrt(nCalc);
  iok = T > 2e7;
%  for j = 1:nbpms
%    Xs(j) = data(3*j-2,end-navg+1:end);
%    Ys(j) = data(3*j-1,end-navg+1:end);
%    Ts(j) = data(3*j, end-navg+1:end);
%  end
  %end

% for j = 1:nbpms
%   i = find(Ts(:,j)>0);
%   if isempty(i)
%     iok(j) = 0;
%   else
%     iok(j) = 1;
%     X(j)  = mean(Xs(i,j));
%     Y(j)  = mean(Ys(i,j));
%     T(j)  = mean(Ts(i,j));
%     dX(j) = util_stdNan(Xs(i,j))/sqrt(navg);
%     dY(j) = util_stdNan(Ys(i,j))/sqrt(navg);
%     dT(j) = util_stdNan(Ts(i,j))/sqrt(navg);
%   end
% end

end
