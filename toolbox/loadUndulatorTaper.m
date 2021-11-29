%K is list of upstream undulator k, Kend is list of downstream Ks
function success=loadUndulatorTaper(undulatorLine, desCellList, K, Kend)
success=''
%addpath(genpath('/home/physics/nuhn/wrk/matlab'));
if (strcmp(undulatorLine, 'HXR') || strcmp(undulatorLine, 'SXR'))
    display(undulatorLine);    
else
    display (undulatorLine);
    error ( 'undulatorLine can only be ''HXR'' or ''SXR''.' );
end
desTaperMode='keep';
noPlot=1;
nowait=1;
desKValues(1,:) = K;
desKValues(2,:) = Kend;
UndSet(undulatorLine, desCellList, desKValues, desTaperMode, noPlot, nowait);
success='Taper Restored';
