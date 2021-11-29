static = bba_simulInit('sector','UND');
appMode = 1; %Production
opts.useInit=0;
opts.use=struct('init',opts.useInit,'quad',0,'BPM',0,'corr',1,'nfit',1);
[R, en]=bba_responseMatGet(static,1);
for n=1:15%Secure EDEF
    test=lcaGet(strcat('EDEF:SYS0:',num2str(n),':NAME'));
    if strcmp(test,'')
        freeEDef=n;
        lcaPut(strcat('EDEF:SYS0:',num2str(freeEDef),':FREE'),1);%Release EDEF
        lcaPut(strcat('EDEF:SYS0:',num2str(n),':NAME'),'BBA Acquisition');
        lcaPut(strcat('EDEF:SYS0:',num2str(n),':USERNAME'),'PySteer');        
        break
    end
end
if ~exist('freeEDef')%If no free EDEFS, exit and inform user.
    disp('No Free EDEFS; exiting!  No SVD steering applied.  Please clear an EDEF and try again.')
    return
end
xMeas = bba_bpmDataGet(static, R, appMode, nSamples,'eDefNum', freeEDef);
lcaPut(strcat('EDEF:SYS0:',num2str(freeEDef),':FREE'),1)%Release EDEF
xMeasStd=std(xMeas,0,3)/sqrt(size(xMeas,3));
xMeas=mean(xMeas,3);
[result, opts] = bba_fitOrbit(static, R, xMeas, xMeasStd, opts);
bba_corrSet(static,-result.corrOff*gain,1,'wait',0)
clearvars
