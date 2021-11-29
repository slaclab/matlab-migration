function[] = calBpmPlotScale(bpmparms, nbpms, wsel)
%   Plot the X and Y scale changes for a batch of calibration data.
%   The top plot contains the ratio of new X scale : old X scale vs BPM number. 
%   The bottom plot contains the ratio of new Y scale : old Y scale vs BPM number. 
%   A value of 1 indicates no scale change.
%   A green data point indicates a BPM/plane not included in the scan. If a BPM/plane not
%   scanned, its ratio is set to 1 in the plot.

bpmNo=(-2:(nbpms-3));
C=zeros(nbpms,3);
C(:,1)=1;C(:,2)=0;C(:,3)=0;

for j=1:nbpms
    if ( (bpmparms.ur(j)==0) || (wsel(j) == 0) )
        bpmparms.uscl(j)=bpmparms.uscl_i(j);
        C(j,1)=0;C(j,2)=1;C(j,3)=0;
    end
end

scalePlot=figure(1000); set(scalePlot,'Position',[100,100,1000,600]); set(scalePlot,'Name','Cavity BPM Calibration - Scale Changes');
subplot(2,1,1); scatter(bpmNo,bpmparms.uscl./bpmparms.uscl_i,15,C); grid; axis tight; 
xlabel('Girder number'); ylabel('X scale ratio, new/old'); title('Cavity BPM Calibration Scale Changes'); 

C(:,1)=0;C(:,2)=0;C(:,3)=1;

for j=1:nbpms
    if ( (bpmparms.vr(j)==0) || (wsel(j) == 0) )
        bpmparms.vscl(j)=bpmparms.vscl_i(j);
        C(j,1)=0;C(j,2)=1;C(j,3)=0;
    end
end

subplot(2,1,2); scatter(bpmNo,bpmparms.vscl./bpmparms.vscl_i,15,C); grid; axis tight; 
xlabel('Girder number'); ylabel('Y scale ratio, new/old');

end
