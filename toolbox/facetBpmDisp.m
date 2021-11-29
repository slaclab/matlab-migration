function facetBpmDisp ()
% function facetBpmDisp()
% calculate estimated dispersion from jitter.

% W. Colocho based on JFD's ~decker/matlab/toolbox/disp_orbit.m
load /home/fphysics/decker/matlab/toolbox/BPM_Lpv
load /home/fphysics/decker/matlab/toolbox/BPM_DR13

%limits for edm plot
lcaPutSmart('CUD:MCC1:BPMSWF:WAVEFORM1.LOPR', 49);
lcaPutSmart('CUD:MCC1:BPMSWF:WAVEFORM1.HOPR', 2010);
lcaPutSmart('CUD:MCC1:BPMSWF:WAVEFORM2.LOPR', -60);
lcaPutSmart('CUD:MCC1:BPMSWF:WAVEFORM2.HOPR', 60);
lcaPutSmart('CUD:MCC1:BPMSWF:WAVEFORM4.LOPR', 0);
lcaPutSmart('CUD:MCC1:BPMSWF:WAVEFORM4.HOPR', 0.5);


pvall=[BPM_DR13 ;BPM_Lpv];
[X,Y,TM,PID]=control_bpmAidaGet(pvall, 20, '57');
nBpms = length(X);
%pFitX=zeros(1,nBpms);
dispIndx = strmatch( 'BPMS:LI10:3448', pvall);
zP = 1:nBpms; 
zBpmsVect = zeros(1,10000);
zBpms = model_rMatGet(pvall,[],[],'Z');
%zBpms = zBpms - zBpms(1);

bpmNs = zeros(1,10000);

%xyDisp = zeros(1,10000);
%bpmNs(1:2*nBpms) = [zP zP+nBpms]; 
%zBpmsVect(1:2*nBpms) = [zBpms zBpms];
lcaPutSmart('CUD:MCC1:BPMSWF:WAVEFORM1', zBpms);
%lcaPutSmart('SIOC:SYS1:ML00:FWF13', bpmNs);
%lcaPutSmart('SIOC:SYS1:ML00:FWF13', zBpmsVect);
imAlive = 1;
fprintf('%s BPM Dispersion from Jitter Started\n',datestr(now));
while 1;
    imAlive = imAlive +1;
    lcaPutSmart('SIOC:SYS1:ML00:AO014', imAlive);
    pauseTime = lcaGetSmart('SIOC:SYS1:ML00:AO015');
    try
       [X,Y,TM,PID]=control_bpmAidaGet(pvall, 10, '57');
    catch
    end
    
    if(sum(TM(dispIndx,:)) < 1), pause(pauseTime); continue, end

    for i = 1:nBpms
        pFitX(:,i)= polyfit(X(dispIndx,:),X(i,:),1);
        pFitY(:,i)= polyfit(X(dispIndx,:),Y(i,:),1);
    end
    xStd = std(X,0,2);
    yStd = std(X,0,2);
    tStd = std(TM,0,2);
    tMean = mean(TM,2);
    tJit =  tStd ./ tMean;
    %xyDisp([zP zP+nBpms]) = [pFitX(1,:) pFitY(1,:)];
    %lcaPutSmart('SIOC:SYS1:ML00:FWF15', 450 * xyDisp);
    %lcaPutSmart('SIOC:SYS1:ML00:SO1007',datestr(now));
    

    
    %Output To EPICS

     lcaPutSmart('CUD:MCC1:BPMSWF:WAVEFORM2', 450 * pFitX(1,:));
     lcaPutSmart('CUD:MCC1:BPMSWF:WAVEFORM3', 450 * pFitY(1,:));
     lcaPutSmart('CUD:MCC1:BPMSWF:WAVEFORM4', xStd');
     lcaPutSmart('CUD:MCC1:BPMSWF:WAVEFORM5', yStd');
     lcaPutSmart('CUD:MCC1:BPMSWF:WAVEFORM6', mean(X,2)');
     lcaPutSmart('CUD:MCC1:BPMSWF:WAVEFORM7', mean(Y,2)');        
    % lcaPutSmart('CUD:MCC1:BPMSWF:WAVEFORM6', [tJit' 2*ones(1,480-length(tJit))]);
    
    pause(pauseTime);
end
%SIOC:SYS1:ML00:FWF13