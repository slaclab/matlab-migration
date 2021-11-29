function bpmDispHXR

% Calculates correlation coefficient between all bpms and dispersion BPM and
% writes information to waveform PV for CU_HXR beampath
    
% NOTE: Before starting Matlab, type this in the command line: export EPICS_CA_MAX_ARRAY_BYTES=80000 
                             
%---------------------------------------------------------------------------------------------                             
 
        warning('off', 'MATLAB:polyfit:RepeatedPointsOrRescale');

% Declaring PVs, cells with dispersion bpms, and WFs to be used 

beampath_model = 'BEAMPATH=CU_HXR';
disp_bpms_cellArray = {'BPMS:LI21:233', 'BPMS:LI24:801', 'BPMS:LTUH:250', 'BPMS:LTUH:450'};
n=model_nameRegion('BPMS', 'CU_HXR');% gets a list of all BPMS for a specific beampath

% Remove units not in running mode.
onlinePvs = strcat(n,':ACCESS');
onlineVals = lcaGetSmart(onlinePvs);
useIndx = strmatch('Running',onlineVals);
n = n(useIndx);

[oo, ooo, bpmIndx] = intersect({'BPMS:LI21:233:X', 'BPMS:LI24:801:X', 'BPMS:LTUH:250:X', 'BPMS:LTUH:450:X'},strcat(n,':X'))
bpmIndx_sorted = sort(bpmIndx);

% PVs variables
PV_number_of_points = 'SIOC:SYS0:ML01:AO069';
PV_beamrate = 'IOC:IN20:EV01:PABIG_BC1_RATE';
PV_isRunning = 'SIOC:SYS0:ML01:AO071';
PV_beamOnStat = {'BPMS:LTUH:250:STA_ALHFP'; 'BPMS:LTUH:450:STA_ALHFP'};
PV_beamOnBC1 = 'BPMS:LI21:233:STA_ALHFP';
PV_beamOnBC2 = 'BPMS:LI24:801:STA_ALHFP'; 

% Output WF PV variables
PV_symetricPart = 'SIOC:SYS0:ML01:AO072';
zP_waveformPV = 'CUD:MCC0:BPMSWF:WAVEFORM1';
PV_dispersionWaveFromX_DL1 = 'CUD:MCC0:BPMSWF:WAVEFORM2';
PV_dispersionWaveFromY_DL1 = 'CUD:MCC0:BPMSWF:WAVEFORM3';
PV_dispersionWaveFromX_BC1 = 'CUD:MCC0:BPMSWF:WAVEFORM6';
PV_dispersionWaveFromY_BC1 = 'CUD:MCC0:BPMSWF:WAVEFORM7';
PV_dispersionWaveFromX_BC2 = 'CUD:MCC0:BPMSWF:WAVEFORM8';
PV_dispersionWaveFromY_BC2 = 'CUD:MCC0:BPMSWF:WAVEFORM9';
        

% Getting dispersion, and Z values
z=model_rMatGet(n,[],beampath_model,'Z');
[z,sI] = sort(z);
n = n(sI)
nBpms = length(n)

[rMat, zPos, lEff, twiss, energy] = model_rMatGet(disp_bpms_cellArray,[],{'TYPE=DESIGN','BEAMPATH=CU_HXR'}); 
etaValAtBPM = 1000*twiss(5,:) % Eta in the model is in m, so we set it to mm
fprintf('\n%s bpmDispHXR Started\n',datestr(now)) 
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
                              
                   beamOnStat = lcaGetSmart(PV_beamOnStat);
                   beamOnBoth = all(strcmp('On',beamOnStat));
                   beamOnFirst = strcmp('On',beamOnStat(1));
                   beamOnBC1 = strcmp('On', lcaGetSmart(PV_beamOnBC1));
                   beamOnBC2 = strcmp('On', lcaGetSmart(PV_beamOnBC2));

           if ~beamOnFirst, pause(5), continue, end
         
                for k = 1:6
                    data = [];
                    try
                        [data,ts1]=lcaGetSyncHST(nAll, nMeas, 'CUHBR');
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
                    t = squeeze(data(:,3,:) );  t = t(:,bufRange);% t is TMIT
                    
                catch
                    fprintf('%s Failed to generate x,y,t values near line 77',datestr(now))
                    keyboard
                end
 
             % Calculating WFs 
         
                  bpmBC1x = x(bpmIndx_sorted(1),:);
                  bpmBC2x = x(bpmIndx_sorted(2),:); 
                  bpmDl1x = x(bpmIndx_sorted(3),:);
                  bpmDl2x = x(bpmIndx_sorted(4),:);
                  
                  
            
                  for ii = 1:nBpms % nBpms will change with the beampath
                      pFitX_DL1(ii,:) = nanToZero(polyfit(bpmDl1x,x(ii,:),1));
                      pFitY_DL1(ii,:) = nanToZero(polyfit(bpmDl1x,y(ii,:),1));
                      pFitX_BC1(ii,:) = nanToZero(polyfit(bpmBC1x,x(ii,:),1));
                      pFitY_BC1(ii,:) = nanToZero(polyfit(bpmBC1x,y(ii,:),1));
                      pFitX_BC2(ii,:) = nanToZero(polyfit(bpmBC2x,x(ii,:),1));
                      pFitY_BC2(ii,:) = nanToZero(polyfit(bpmBC2x,y(ii,:),1));
                  end
           
 
                  %% Look for Burst mode DL2 BPM energy symetry problem
                  
                  % LTUH symmetric part
                  
                  % In microns
                  bpmDl1Mean = 1000 * mean(bpmDl1x);
                  bpmDl2Mean = 1000 * mean(bpmDl2x); 
                  
                  symetricPart = (bpmDl1Mean + bpmDl2Mean) / 2;
                  
                  % Writing output to waveform PVs

                  zP = 3000 * ones(1,175);
                  zP(1:length(z)) = z; % the real z values are replaced and the remaining ones are unvisible on the EPICs display
                  if beamOnBoth, lcaPutSmart(PV_symetricPart,symetricPart); end % Waveform size is of 175
                  lcaPutSmart(zP_waveformPV, zP);
                  if beamOnFirst
                      lcaPutSmart(PV_dispersionWaveFromX_DL1,  etaValAtBPM(3)* pFitX_DL1(:,1)');
                      lcaPutSmart(PV_dispersionWaveFromY_DL1,  etaValAtBPM(3)* pFitY_DL1(:,1)');
 
                  end
                if beamOnBC1
                    lcaPutSmart(PV_dispersionWaveFromX_BC1,   etaValAtBPM(1)* pFitX_BC1(:,1)');
                    lcaPutSmart(PV_dispersionWaveFromY_BC1,   etaValAtBPM(1)* pFitY_BC1(:,1)');
                end
                if beamOnBC2
                    lcaPutSmart(PV_dispersionWaveFromX_BC2,   etaValAtBPM(2)* pFitX_BC2(:,1)');
                    lcaPutSmart(PV_dispersionWaveFromY_BC2,   etaValAtBPM(2)* pFitY_BC2(:,1)');
                end

                beamRate = lcaGetSmart(PV_beamrate);
                  
             
                
                % Plots
%                 figure(1)
%                  plot(z,etaValAtBPM(3)* pFitX_DL1(:,1)')
%                 xlabel('z')
%                 ylabel('LTUS dispersion wave X')

      
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
      
% Function that makes NaNs into zeros
function x = nanToZero(x)
x(isnan(x)) = 0;
end
