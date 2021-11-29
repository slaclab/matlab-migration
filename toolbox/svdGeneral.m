static = bba_simulInit('sector',sectorselection,'noEPlusCorr',1);
appMode = 1; %Production
opts.useInit=0;
opts.iInit=1:4;
opts.use=struct('init',opts.useInit,'quad',0,'BPM',0,'corr',1,'nfit',1);
[R, en]=bba_responseMatGet(static,1);
for n=1:15%Secure EDEF
	disp(n)
    test=lcaGet(strcat('EDEF:SYS0:',num2str(n),':NAME'))
	strcmp(test,'')
    if strcmp(test,'')
        freeEDef=n;
        lcaPut(strcat('EDEF:SYS0:',num2str(freeEDef),':FREE'),1);%Release EDEF
        lcaPut(strcat('EDEF:SYS0:',num2str(n),':NAME'),'BBA Acquisition');
        lcaPut(strcat('EDEF:SYS0:',num2str(n),':USERNAME'),'PySteer'); 
        lcaPut(strcat('EDEF:SYS0:',num2str(n),':INCMS1'),'pockcel_perm')
        lcaPut(strcat('EDEF:SYS0:',num2str(n),':EXCMS1'),'TS2 TS3 TS5 TS6')
        break
    end
end
if ~exist('freeEDef')%If no free EDEFS, exit and inform user.
    success='No free EDEFS.  Aborted!'
    return
end
xMeas = bba_bpmDataGet(static, R, appMode, nSamples,'eDefNum', freeEDef);
lcaPut(strcat('EDEF:SYS0:',num2str(freeEDef),':FREE'),1)%Release EDEF
xMeasStd=util_stdNan(xMeas,0,3)./sqrt(sum(~isnan(xMeas),3));
xMeas=util_meanNan(xMeas,3);
[result, opts] = bba_fitOrbit(static, R, xMeas, xMeasStd, opts);
bba_corrSet(static,-result.corrOff*gain,1,'wait',0)
success='Steering Applied'
