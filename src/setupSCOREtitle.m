function setupSCOREtitle
try
    titleAPI = edu.stanford.slac.score.api.SnapshotConfigTitleManager.getInstance();
    
    BunchChargeChannel = getBunchChargeChannel(titleAPI);
    BunchChargeChannelStr = char(BunchChargeChannel);
    BunchChargePV = BunchChargeChannelStr(24:end);
    BunchCharge = lcaGet(BunchChargePV);
    setValDbl(BunchChargeChannel, BunchCharge);

    ActBunchChargeChannel = getActBunchChargeChannel(titleAPI);
    ActBunchChargeChannelStr = char(ActBunchChargeChannel);
    ActBunchChargePV = ActBunchChargeChannelStr(24:end);
    ActBunchCharge = lcaGet(ActBunchChargePV);
    setValDbl(ActBunchChargeChannel, ActBunchCharge);
    
    EnergyChannel = getEnergyChannel(titleAPI);
    EnergyChannelStr = char(EnergyChannel);
    EnergyChannelPV = EnergyChannelStr(24:end);
    Energy = lcaGet(EnergyChannelPV);
    setValDbl(EnergyChannel, Energy);

    EdesChannel = getEdesChannel(titleAPI);
    EdesChannelStr = char(EdesChannel);
    EdesChannelPV = EdesChannelStr(24:end);
    Edes = lcaGet(EdesChannelPV);
    setValDbl(EdesChannel, Edes);
    
    EnergyVernierChannel = getEnergyVernierChannel(titleAPI);
    EnergyVernierChannelStr = char(EnergyVernierChannel);
    EnergyVernierChannelPV = EnergyVernierChannelStr(24:end);
    EnergyVernier = lcaGet(EnergyVernierChannelPV);
    setValDbl(EnergyVernierChannel, EnergyVernier);
    
    XrayChannel = getXrayChannel(titleAPI);
    XrayChannelStr = char(XrayChannel);
    XrayChannelPV = XrayChannelStr(24:end);
    Xray = lcaGet(XrayChannelPV);
    setValDbl(XrayChannel, Xray);
    
    Bc2PeakCurChannel = getBc2PeakCurChannel(titleAPI);
    Bc2PeakCurChannelStr = char(Bc2PeakCurChannel);
    Bc2PeakCurChannelPV = Bc2PeakCurChannelStr(24:end);
    Bc2PeakCur = lcaGet(Bc2PeakCurChannelPV);
    setValDbl(Bc2PeakCurChannel, Bc2PeakCur);
    
    ElossChannel = getElossChannel(titleAPI);
    ElossChannelStr = char(ElossChannel);
    ElossChannelPV = ElossChannelStr(24:end);
    Eloss = lcaGet(ElossChannelPV);
    setValDbl(ElossChannel, Eloss);
    
catch
    'Problem with setScoreTitle'
end
