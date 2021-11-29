function fastOrbit()
%fastOrbit.m will measure BPMs at beam rate and update the waveforms on cuds
%disp('export EPICS_CA_MAX_ARRAY_BYTES=800000');

%William Colocho
workingCounter = 0;
fprintf('\n%s Starting BPMS averager...\n',datestr(now))
while 1
    workingCounter = workingCounter + 1;
    if mod(workingCounter,2)
        orbit('CU_HXR')
    else
        % orbit('CU_SXR')
    end
    lcaPutSmart('SIOC:SYS0:ML01:AO003',workingCounter);
end


function orbit(beamPath)
% Calculate mean of last 12 pulses for undulator cud
[n,d,isSLC]=model_nameRegion('BPMS',beamPath);
N = length(n);
eDefS = ['CU' beamPath(4) 'BR'];
nAll=[strcat(n,[':X']);strcat(n,[':Y'])];
try
    [data,ts1]=lcaGetSyncHST(nAll,12,eDefS);
    pause(1);
catch
    fprintf('%s Failed lcaGetSyncHST(nAll,12,%s), skip it.',datestr(now),eDefs);
    pause(2)
end
x = data(1:N,end-12:end);
y = data(N+1:2*N,end-12:end);
xMean = 1000 * mean(x,2);
yMean = 1000 * mean(y,2);
%xStd = std(x,0,2);
%yStd = std(y,0,2);

switch beamPath
  case 'CU_HXR'
    lcaPutSmart('CUD:MCC0:BPMSWF:WAVEFORM11', xMean');
    lcaPutSmart('CUD:MCC0:BPMSWF:WAVEFORM12', yMean');
  case 'CU_SXR'
    lcaPutSmart('CUD:MCC0:BPMSWF:WAVEFORM4', [xMean nan]');
    lcaPutSmart('CUD:MCC0:BPMSWF:WAVEFORM5', [yMean nan]');      
end
end
