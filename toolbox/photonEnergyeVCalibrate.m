function eVCalc =  photonEnergyeVCalibrate(time)
%
% eVCalc =  photonEnergyeVCalibrate(time)
%
% Return the calculated photon energy from archived data at time. Use this
% to set the offset constant in photonEnergyeV


time = datestr(time);
config = configRecall(time);
bendEnergyGeVref = config.electron.beamEnergy;
peakCurrentRef = config.electron.BC2peakCurrentSetpoint;
chargeRef = 1000*config.electron.charge_nC;
taper.xact = config.undulator.taper.xAct;
taper.Kact =  config.undulator.taper.Kact;

activeSegments = find(taper.xact < 11); % these are active
activeSegments(activeSegments == 16) =[]; % eliminate HXRSS
activeSegments(activeSegments == 9) =[]; % eliminate SXRSS
Kref = taper.Kact(activeSegments(1));

xltu250Ref = config.electron.xltu250;
xltu450Ref = config.electron.xltu450;

xcorPV = {'XCOR:LTU1:288:BACT';...
    'XCOR:LTU1:348:BACT';...
    'XCOR:LTU1:388:BACT';...
    'XCOR:LTU1:448:BACT'};
[~,v] = history(xcorPV, {time; time});
for q=1:length(v)
    xcor_kGmRef(q) = mean(v{q});
end


 eVCalc = photonEnergyeV(bendEnergyGeVref,peakCurrentRef,chargeRef,Kref,xltu250Ref, xltu450Ref, xcor_kGmRef, 1);