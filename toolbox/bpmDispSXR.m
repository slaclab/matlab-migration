function bpmDispSXR

% Calculates correlation coefficient between all bpms and dispersion BPM and
% writes information to waveform PV for the CU_SXR beampath
    
% NOTE: Before starting Matlab, type this in the command line: export EPICS_CA_MAX_ARRAY_BYTES=80000 
                             
%---------------------------------------------------------------------------------------------                             
        
        warning('off', 'MATLAB:polyfit:RepeatedPointsOrRescale');

% Declaring PVs, cells with dispersion bpms, and WFs to be used 

 beampath_model= 'BEAMPATH=CU_SXR';
 disp_bpms_cellArray = {'BPMS:LI21:233', 'BPMS:LI24:801', 'BPMS:CLTS:420','BPMS:CLTS:620' 'BPMS:LTUS:235', 'BPMS:LTUS:370'};
 n=model_nameRegion('BPMS', 'CU_SXR'); % gets a list of all BPMS 

 % Remove units not in running mode.
 onlinePvs = strcat(n,':ACCESS');
 onlineVals = lcaGetSmart(onlinePvs);
 useIndx = strmatch('Running',onlineVals);
 n = n(useIndx);


 [oo, ooo,bpmIndx] = intersect({'BPMS:LI21:233:X', 'BPMS:LI24:801:X', 'BPMS:CLTS:420:X','BPMS:CLTS:620:X' 'BPMS:LTUS:235:X', 'BPMS:LTUS:370:X'},strcat(n,':X'))
 bpmIndx_sorted = sort(bpmIndx);
 
 % PVs variables
 PV_number_of_points = 'SIOC:SYS0:ML02:AO176';
 PV_beamrate = 'IOC:IN20:EV01:PABIG_BC2_RATE';
 PV_isRunning = 'SIOC:SYS0:ML02:AO177';
 PV_beamOnStatLTUS = {'BPMS:LTUS:235:STA_ALHFP', 'BPMS:LTUS:370:STA_ALHFP'};
 PV_beamOnStatCLTS = {'BPMS:CLTS:420:STA_ALHFP','BPMS:CLTS:620:STA_ALHFP',};
 PV_beamOnBC1 = 'BPMS:LI21:233:STA_ALHFP';
 PV_beamOnBC2 = 'BPMS:LI24:801:STA_ALHFP';

 % Output WF PV variables
 PV_symmetricPartLTUS = 'SIOC:SYS0:ML05:AO178'; 
 PV_symmetricPartCLTS = 'SIOC:SYS0:ML05:AO179';
 PV_symmetricPartCLTS_Y = 'SIOC:SYS0:ML05:AO180';
 zP_waveformPV = 'PHYS:SYS0:12:BPMS_Z';
 PV_dispersionWaveFromX_DL1 = 'PHYS:LTUS:12:ETAX_JITT';
 PV_dispersionWaveFromY_DL1 = 'PHYS:LTUS:12:ETAY_JITT';
 PV_dispersionWaveFromX_DL1_CLTS = 'PHYS:CLTS:12:ETAX_JITT';
 PV_dispersionWaveFromY_DL1_CLTS = 'PHYS:CLTS:12:ETAY_JITT';

 PV_dispersionWaveFromX_BC1 = 'PHYS:LI21:12:ETAX_JITT';
 PV_dispersionWaveFromY_BC1 = 'PHYS:LI21:12:ETAY_JITT';
 PV_dispersionWaveFromX_BC2 = 'PHYS:LI24:12:ETAX_JITT';
 PV_dispersionWaveFromY_BC2 = 'PHYS:LI24:12:ETAY_JITT';
        


% Getting dispersion, and Z values
z=model_rMatGet(n,[],beampath_model,'Z');
[z,sI] = sort(z);
n = n(sI)
nBpms = length(n)

[rMat, zPos, lEff, twiss, energy] = model_rMatGet(disp_bpms_cellArray,[],{'TYPE=DESIGN','BEAMPATH=CU_SXR'}); 
etaValAtBPM = 1000*twiss(5,:) % Eta in the model is in m, so we set it to mm
fprintf('\n%s bpmDispSXR Started\n',datestr(now))
nAll=[strcat(n,':X');strcat(n,':Y');strcat(n,':TMIT')];
        
% Gathering data          
while (1)   
             
        val  = lcaGetSmart({PV_number_of_points; PV_beamrate}); 
        nMeas = val(1);
        tic
        
        try
            isRunning = str2double(datestr(now,'MM')) + 60 * str2double(datestr(now,'HH'));
            lcaPutSmart(PV_isRunning, isRunning);

            beamRate = val(2);
            
           if beamRate < 2, pause(5), continue, end
           
           bpmDl1_eta_CLTS = etaValAtBPM(3);
           bpmDl1_eta_LTUS = etaValAtBPM(5);

           beamOnStatLTUS = lcaGetSmart(PV_beamOnStatLTUS);

           beamOnBothLTUS = all(strcmp('On',beamOnStatLTUS));
           beamOnStatCLTS = lcaGetSmart(PV_beamOnStatCLTS);
           beamOnBothCLTS = all(strcmp('On',beamOnStatCLTS));

           beamOnFirstLTUS = strcmp('On',beamOnStatLTUS(1));% We only need one BPM for the calc. on the dispersion areas
           beamOnFirstCLTS = strcmp('On',beamOnStatCLTS(1));
           beamOnBC1 = strcmp('On', lcaGetSmart(PV_beamOnBC1));
           beamOnBC2 = strcmp('On', lcaGetSmart(PV_beamOnBC2));

           if ~beamOnFirstCLTS, pause(5), continue, end


               for k = 1:6
                   data = [];
                   try
                       [data,ts1]=lcaGetSyncHST(nAll, nMeas, 'CUSBR');
                       if length(ts1) >= nMeas*0.8 
                           break
                       end
                       pause(nMeas/beamRate);
                   catch
                       fprintf('%s Failed lcaGetSyncHST(nAll), pausing...',datestr(now));
                       pause(30)
                    end

              end
        % Figure could not  get the data, bail out of loop and try again.
        if isempty(data), fprintf('%s BPMbut  data is empty. Will try again',datestr(now)); continue; end
        if k == 6, fprintf('%s Poor data, got %i sync pulses from %i requested',datestr(now), length(ts1), nMeas);end
        derp = 1+mod(length(ts1),4);
        data = data(:,derp:end);
        ts1 = ts1(derp:end);
        nPtsAvail = size(data,2);
        data =  reshape(data,[],3,nPtsAvail);

        isRunning = str2double(datestr(now,'MM')) + 60 * str2double(datestr(now,'HH'));
        lcaPutSmart(PV_isRunning, isRunning);
        bufRange = 1:min(nMeas,nPtsAvail);

        try
            x = squeeze(data(:,1,:) );  x = x(:,bufRange);
            y = squeeze(data(:,2,:) );  y = y(:,bufRange);
            t = squeeze(data(:,3,:) );  t = t(:,bufRange);
        catch
            fprintf('%s Failed to generate x,y,t values near line 77',datestr(now))
            keyboard
        end
            
          % Calculating WFs 
         
                  bpmBC1x = x(bpmIndx_sorted(1),:);
                  bpmBC2x = x(bpmIndx_sorted(2),:);
                  bpmCLTS_D1x = x(bpmIndx_sorted(3),:);
                  bpmCLTS_D2x = x(bpmIndx_sorted(4),:);
                  bpmDl1x = x(bpmIndx_sorted(5),:);
                  bpmDl2x = x(bpmIndx_sorted(6),:);
                  bpmCLTS_Dl1y = y(bpmIndx_sorted(3),:);
                  bpmCLTS_Dl2y = y(bpmIndx_sorted(4),:);
                  
                  for ii = 1:nBpms % nBpms will change with the beampath
                      
                      % ******** For LTUS dispersion bpms *****************
                      pFitX_DL1(ii,:) = nanToZero(polyfit(bpmDl1x,x(ii,:),1)); 
                      pFitY_DL1(ii,:) = nanToZero(polyfit(bpmDl1x,y(ii,:),1));
                      
                      % For the CLTS dispersion bpms
                      pFitX_CLTS_D1(ii,:) = nanToZero(polyfit(bpmCLTS_D1x,x(ii,:),1));
                      pFitY_CLTS_D1(ii,:) = nanToZero(polyfit(bpmCLTS_D1x,y(ii,:),1));
                    
                     
                      %**************For BC1 and BC2 areas ***********
                      pFitX_BC1(ii,:) = nanToZero(polyfit(bpmBC1x,x(ii,:),1));
                      pFitY_BC1(ii,:) = nanToZero(polyfit(bpmBC1x,y(ii,:),1));
                      pFitX_BC2(ii,:) = nanToZero(polyfit(bpmBC2x,x(ii,:),1));
                      pFitY_BC2(ii,:) = nanToZero(polyfit(bpmBC2x,y(ii,:),1));
                  end
           
 
                  %% Look for Burst mode DL2 BPM energy symetry problem
                  %For soft line we will need two symmetricParts for CLTS and LTUS
                  
                  % LTUS symmetric part
                  
                  bpmDl1Mean = 1000 * mean(bpmDl1x);
                  bpmDl2Mean = 1000 * mean(bpmDl2x); 
                  symmetricPartLTUS = (bpmDl1Mean + bpmDl2Mean) / 2;
                  
                  % CLTS symmetric part in X
                  
                  bpmCLTS_D1Mean = 1000 * mean(bpmCLTS_D1x);
                  bpmCLTS_D2Mean = 1000 * mean(bpmCLTS_D2x);
                  symmetricPartCLTS = (bpmCLTS_D1Mean + bpmCLTS_D2Mean) / 2;
                  
                  % CLTS symmetric part in Y
  
                  bpmCLTS_D1MeanY = 1000 * mean(bpmCLTS_Dl1y);
                  bpmCLTS_D2MeanY = 1000 * mean(bpmCLTS_Dl2y);
                  
                  symmetricPartCLTS_Y = (bpmCLTS_D1MeanY + bpmCLTS_D2MeanY)/2;
                  
                    
                 % Writing output to waveform PVs

                zP = 3000 * ones(1,176); % 176 is nBpms
                zP(1:length(z)) = z; % the real z values are replaced and the remaining ones are unvisible on the EPICs display
                if beamOnBothLTUS, lcaPutSmart(PV_symmetricPartLTUS,symmetricPartLTUS); end 
                if beamOnBothCLTS 
                    lcaPutSmart(PV_symmetricPartCLTS, symmetricPartCLTS);
                    lcaPutSmart(PV_symmetricPartCLTS_Y, symmetricPartCLTS_Y);
                
                end
                lcaPutSmart(zP_waveformPV, zP);
               
                if beamOnFirstLTUS
                    lcaPutSmart(PV_dispersionWaveFromX_DL1,  bpmDl1_eta_LTUS* pFitX_DL1(:,1)');
                    lcaPutSmart(PV_dispersionWaveFromY_DL1,  bpmDl1_eta_LTUS* pFitY_DL1(:,1)');

                end
                if beamOnFirstCLTS
                    lcaPutSmart(PV_dispersionWaveFromX_DL1_CLTS,  bpmDl1_eta_CLTS* pFitX_CLTS_D1(:,1)');
                    lcaPutSmart(PV_dispersionWaveFromY_DL1_CLTS,  bpmDl1_eta_CLTS* pFitY_CLTS_D1(:,1)');

                end
        
                if beamOnBC1
                    lcaPutSmart(PV_dispersionWaveFromX_BC1,   etaValAtBPM(1)* pFitX_BC1(:,1)');
                    lcaPutSmart(PV_dispersionWaveFromY_BC1,   etaValAtBPM(1)* pFitY_BC1(:,1)');
                end
                if beamOnBC2
                    lcaPutSmart(PV_dispersionWaveFromX_BC2,   etaValAtBPM(2)* pFitX_BC2(:,1)');
                    lcaPutSmart(PV_dispersionWaveFromY_BC2,   etaValAtBPM(2)* pFitY_BC2(:,1)');
                end
                
                % Plots
%                 figure(1)
%                plot(z,bpmDl1_eta_LTUS* pFitX_DL1(:,1)')
%               xlabel('z')
%                ylabel('LTUS dispersion wave X')
%                 
     
              beamRate = lcaGetSmart(PV_beamrate);
                
                theToc = toc;
                if beamRate < 9; beamRate = 10; end
                pause( max( (nMeas/beamRate) - theToc, 0) )
                
      
            continue
            

         catch
            disp('Error in loop...')
            rethrow(lasterror)
            keyboard
        end
end
    
        
end
      
% Function to make NaNs into zeros
function x = nanToZero(x)
x(isnan(x)) = 0;
end
