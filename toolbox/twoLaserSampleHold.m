function twoLaserSampleHold
% function twoLaserSampleHold
% this function updates calcualtion PVs that drive sample and hold
% values for single laser samples in two bucket mode.

% William Colocho 


wavePVs = {'CAMR:LR20:135:Stats:ProfileThresholdX_RBV';'CAMR:LR20:135:Stats:ProfileThresholdY_RBV'; ...
   'CAMR:IN20:186:PROJ_H';   'CAMR:IN20:186:PROJ_V' };

%titleStr = { 'C Iris Vertical'; 'C Iris Horizontal'; 'VCC Horizontlal'; 'VCC Vertical'};

sampHold = lcaGet('SIOC:SYS0:ML00:FWF74');
X = lcaGet('CUD:MCC0:BPMSWF:WAVEFORM11');
X = zeros(size(X)); Y = X;
[n,d,isSLC]=model_nameRegion('BPMS','CU_HXR');
iPkAvgPV = strrep('SIOC:SYS0:ML00:CALC29#','#',{'1','2','3','4'});
jj=0;
while 1
    pause(1)
    jj=jj+1;
    %Clear out nans from average peak current PVs
    if any(isnan( lcaGetSmart(iPkAvgPV))) && jj==10
        peakCurrents = lcaGetSmart({'BLEN:LI21:265:AIMAXCUH1H'; 'BLEN:LI21:265:AIMAXCUS1H'; ...
            'BLEN:LI24:886:BIMAXCUHTH'; 'BLEN:LI24:886:BIMAXCUS1H'})
        lcaPutSmart(iPkAvgPV, peakCurrents);
        jj=0;
    end

    waveVals =  lcaGet(wavePVs)';
    L = prod(size(waveVals));
    waveVals = reshape(waveVals,1,L);
    sampHold(1:L) = waveVals;
    sampHold(isnan(sampHold)) = 0;

    laserMode = lcaGet('LASR:LR20:1:UV_LASER_MODE');
    X(1:end) = 1000 * lcaGetSmart(strcat(n,':X1H')); X(isnan(X)) = 0;
    Y(1:end) = 1000 * lcaGetSmart(strcat(n,':Y1H')); Y(isnan(Y)) = 0;

    switch laserMode{:}
        case 'COHERENT #1', sampleHoldMode = 'C1';
        case 'COHERENT #2', sampleHoldMode = 'C2';
        case {'BOTH', 'BOTH (C1 Flipper)'}
            sampleHoldMode = calcDelayMode;
        case 'NONE', sampleHoldMode = 'NONE';
    end    
    switch sampleHoldMode
        case 'C1', 
            lcaPut('SIOC:SYS0:ML00:FWF74', sampHold);  
            lcaPut('CUD:MCC0:BPMSWF:WAVEFORM4', X);  
            lcaPut('CUD:MCC0:BPMSWF:WAVEFORM5', Y);  
            lcaPut('SIOC:SYS0:ML00:CALC286.CALC',1); 
            lcaPut('SIOC:SYS0:ML00:CALC285.CALC',0);

        case 'C2', 
            lcaPut('SIOC:SYS0:ML00:FWF75', sampHold);
            lcaPut('CUD:MCC0:BPMSWF:WAVEFORM11', X);  
            lcaPut('CUD:MCC0:BPMSWF:WAVEFORM12', Y);  
            lcaPut('SIOC:SYS0:ML00:CALC286.CALC',0); 
            lcaPut('SIOC:SYS0:ML00:CALC285.CALC',1);

  
        case {'BOTH', 'NONE'} %Do nothing  
            lcaPut('SIOC:SYS0:ML00:CALC286.CALC',0); 
            lcaPut('SIOC:SYS0:ML00:CALC285.CALC',0);
            
    end

    %disp(sampleHoldMode)
end

function delayMode = calcDelayMode()
bucketRequest = lcaGet({'SIOC:SYS0:ML03:AO126'; 'SIOC:SYS0:ML03:AO127'});
bucketRequest = [bucketRequest - fix(bucketRequest)]' == [0 0];
if bucketRequest == [1 1], delayMode = 'BOTH'; end
if bucketRequest == [1 0], delayMode = 'C1'; end  
if bucketRequest == [0 1], delayMode = 'C2'; end
if bucketRequest == [0 0], delayMode = 'NONE'; end






   