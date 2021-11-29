function imgAcq_epics_putFit(camera, beamlist, tsAsString)
if ~camera.features.fitSave
    return;
end

if isempty(beamlist) || isempty(tsAsString)
    return;
end
pvPrefix = camera.pvPrefix;
try
   lcaPutNoWait([pvPrefix ':FIT_TS'], tsAsString);
   lcaPutNoWait([pvPrefix ':FIT_XMEAN'], beamlist(1).stats(1));
   lcaPutNoWait([pvPrefix ':FIT_YMEAN'], beamlist(1).stats(2));
   lcaPutNoWait([pvPrefix ':FIT_XRMS'], beamlist(1).stats(3));
   lcaPutNoWait([pvPrefix ':FIT_YRMS'], beamlist(1).stats(4));
   lcaPutNoWait([pvPrefix ':FIT_CORR'], beamlist(1).stats(5));
   lcaPutNoWait([pvPrefix ':FIT_SUM'], beamlist(1).stats(6));
catch
    imgUtil_notifyLastError();
end