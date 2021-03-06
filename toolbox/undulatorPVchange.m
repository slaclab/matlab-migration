function newpvs = undulatorPVchange( oldpvs )
%
% newpvs = undulatorPVchange( oldpvs )
%
% replace old undulator pvs with new
%
% old and new are cell arrays of strings of pv names
%
% old names are nonconforming APS names, new names conform to the SLAC
% control system standards.

translation = {
    'U??:CAL:cam1C', 'USEG:UND1:??50:CALCAM1C'; ...
    'U??:CAL:cam2C', 'USEG:UND1:??50:CALCAM2C'; ...
    'U??:CAL:cam3C', 'USEG:UND1:??50:CALCAM3C'; ...
    'U??:CAL:cam4C', 'USEG:UND1:??50:CALCAM4C'; ...
    'U??:CAL:cam5C', 'USEG:UND1:??50:CALCAM5C'; ...
    'U??:CAL:msg1', 'USEG:UND1:??50:CALMSG1'; ...
    'U??:CAL:msg2', 'USEG:UND1:??50:CALMSG2'; ...
    'U??:CAL:camAngle', 'USEG:UND1:??50:CALCAMANGLE'; ...
    'U??:CAL:camPot', 'USEG:UND1:??50:CALCAMPOT'; ...
    'U??:CAL:gdrPot1', 'USEG:UND1:??50:CALGDRPOT1'; ...
    'U??:CAL:gdrPot2', 'USEG:UND1:??50:CALGDRPOT2'; ...
    'U??:CAL:gdrPot3', 'USEG:UND1:??50:CALGDRPOT3'; ...
    'U??:CAL:msg3', 'USEG:UND1:??50:CALMSG3'; ...
    'U??:CAL:abort', 'USEG:UND1:??50:CALABORT'; ...
    'U??:CAL:gdrPot7', 'USEG:UND1:??50:CALGDRPOT7'; ...
    'U??:CAL:gdrPot6', 'USEG:UND1:??50:CALGDRPOT6'; ...
    'U??:CAL:gdrPot5', 'USEG:UND1:??50:CALGDRPOT5'; ...
    'U??:CAL:cam1M', 'USEG:UND1:??50:CALCAM1M'; ...
    'U??:CAL:cam2M', 'USEG:UND1:??50:CALCAM2M'; ...
    'U??:CAL:cam3M', 'USEG:UND1:??50:CALCAM3M'; ...
    'U??:CAL:cam4M', 'USEG:UND1:??50:CALCAM4M'; ...
    'U??:CAL:cam5M', 'USEG:UND1:??50:CALCAM5M'; ...
    'U??:CAL:voltageAvg', 'USEG:UND1:??50:CALVOLTAVG'; ...
    'U??:CALIBDATE', 'USEG:UND1:??50:CALIBDATE'; ...
    'U??:KACT', 'USEG:UND1:??50:KACT'; ...
    'U??:KDES', 'USEG:UND1:??50:KDES'; ...
    'U??:Quad_X_ReadCALC', 'USEG:UND1:??50:QXREADCALC'; ...
    'U??:Quad_Y_ReadCALC', 'USEG:UND1:??50:QYREADCALC'; ...
    'U??:CM1:ReadCALC', 'USEG:UND1:??50:CM1READCALC'; ...
    'U??:CM2:ReadCALC', 'USEG:UND1:??50:CM2READCALC'; ...
    'U??:CM3:ReadCALC', 'USEG:UND1:??50:CM3READCALC'; ...
    'U??:CM4:ReadCALC', 'USEG:UND1:??50:CM4READCALC'; ...
    'U??:CM5:ReadCALC', 'USEG:UND1:??50:CM5READCALC'; ...
    'U??:fanout1', 'USEG:UND1:??50:FANOUT1'; ...
    'U??:fanout2', 'USEG:UND1:??50:FANOUT2'; ...
    'U??:CM1:NormCALC', 'USEG:UND1:??50:CM1NORMCALC'; ...
    'U??:CM2:NormCALC', 'USEG:UND1:??50:CM2NORMCALC'; ...
    'U??:CM3:NormCALC', 'USEG:UND1:??50:CM3NORMCALC'; ...
    'U??:CM4:NormCALC', 'USEG:UND1:??50:CM4NORMCALC'; ...
    'U??:CM5:NormCALC', 'USEG:UND1:??50:CM5NORMCALC'; ...
    'U??:CM2:moveAngle', 'USEG:UND1:??50:CM2MOVEANGLE'; ...
    'U??:radius1', 'USEG:UND1:??50:RADIUS1'; ...
    'U??:radius4', 'USEG:UND1:??50:RADIUS2'; ...
    'U??:radius2', 'USEG:UND1:??50:RADIUS3'; ...
    'U??:radius5', 'USEG:UND1:??50:RADIUS4'; ...
    'U??:radius3', 'USEG:UND1:??50:RADIUS5'; ...
    'U??:beta1', 'USEG:UND1:??50:BETA1'; ...
    'U??:beta3', 'USEG:UND1:??50:BETA2'; ...
    'U??:beta4', 'USEG:UND1:??50:BETA3'; ...
    'U??:beta5', 'USEG:UND1:??50:BETA4'; ...
    'U??:CM3:moveAngle', 'USEG:UND1:??50:CM3MOVEANGLE'; ...
    'U??:CM4:moveAngle', 'USEG:UND1:??50:CM4MOVEANGLE'; ...
    'U??:CM5:moveAngle', 'USEG:UND1:??50:CM5MOVEANGLE'; ...
    'U??:beta1rad', 'USEG:UND1:??50:BETA1RAD'; ...
    'U??:beta3rad', 'USEG:UND1:??50:BETA3RAD'; ...
    'U??:beta4rad', 'USEG:UND1:??50:BETA4RAD'; ...
    'U??:beta5rad', 'USEG:UND1:??50:BETA5RAD'; ...
    'U??:QUAD:jogUpC', 'USEG:UND1:??50:QUADJOGUPC'; ...
    'U??:QUAD:jogDownC', 'USEG:UND1:??50:QUADJOGDNC'; ...
    'U??:QUAD:jogLeftC', 'USEG:UND1:??50:QUADJOGLFC'; ...
    'U??:QUAD:jogRightC', 'USEG:UND1:??50:QUADJOGRTC'; ...
    'U??:US:jogUpC', 'USEG:UND1:??50:USJOGUPC'; ...
    'U??:US:jogDownC', 'USEG:UND1:??50:USJOGDNC'; ...
    'U??:US:jogLeftC', 'USEG:UND1:??50:USJOGLFC'; ...
    'U??:US:jogRightC', 'USEG:UND1:??50:USJOGRTC'; ...
    'U??:DS:jogUpC', 'USEG:UND1:??50:DSJOGUPC'; ...
    'U??:DS:jogDownC', 'USEG:UND1:??50:DSJOGDNC'; ...
    'U??:DS:jogLeftC', 'USEG:UND1:??50:DSJOGLFC'; ...
    'U??:DS:jogRightC', 'USEG:UND1:??50:DSJOGRTC'; ...
    'U??:QUAD:jogDistC', 'USEG:UND1:??50:QJOGDISTC'; ...
    'U??:QUAD:jogUpCalc', 'USEG:UND1:??50:QUADJOGUPCLC'; ...
    'U??:QUAD:jogDownCalc', 'USEG:UND1:??50:QUADJOGDNCLC'; ...
    'U??:QUAD:jogLeftCalc', 'USEG:UND1:??50:QUADJOGLFCLC'; ...
    'U??:US:jogUpCalc', 'USEG:UND1:??50:USJOGUPCLC'; ...
    'U??:US:jogDownCalc', 'USEG:UND1:??50:USJOGDNCLC'; ...
    'U??:US:jogLeftCalc', 'USEG:UND1:??50:USJOGLFCLC'; ...
    'U??:QUAD:jogRightCalc', 'USEG:UND1:??50:QUADJOGRTCLC'; ...
    'U??:US:jogRightCalc', 'USEG:UND1:??50:USJOGRTCLC'; ...
    'U??:DS:jogUpCalc', 'USEG:UND1:??50:DSJOGUPCLC'; ...
    'U??:DS:jogDownCalc', 'USEG:UND1:??50:DSJOGDNCLC'; ...
    'U??:DS:jogLeftCalc', 'USEG:UND1:??50:DSJOGLFCLC'; ...
    'U??:DS:jogRightCalc', 'USEG:UND1:??50:DSJOGRTCLC'; ...
    'U??:camsMovingM', 'USEG:UND1:??50:CAMSMOVINGM'; ...
    'U??:CM1:moveM', 'USEG:UND1:??50:CM1MOVEM'; ...
    'U??:CM2:moveM', 'USEG:UND1:??50:CM2MOVEM'; ...
    'U??:CM3:moveM', 'USEG:UND1:??50:CM3MOVEM'; ...
    'U??:CM4:moveM', 'USEG:UND1:??50:CM4MOVEM'; ...
    'U??:CM5:moveM', 'USEG:UND1:??50:CM5MOVEM'; ...
    'U??:CM1:ZeroOffsetC', 'USEG:UND1:??50:CM1OFFSETC'; ...
    'U??:CM1:GainC', 'USEG:UND1:??50:CM1GAINC'; ...
    'U??:CM2:ZeroOffsetC', 'USEG:UND1:??50:CM2OFFSETC'; ...
    'U??:CM2:GainC', 'USEG:UND1:??50:CM2GAINC'; ...
    'U??:CM3:ZeroOffsetC', 'USEG:UND1:??50:CM3OFFSETC'; ...
    'U??:CM3:GainC', 'USEG:UND1:??50:CM3GAINC'; ...
    'U??:CM4:ZeroOffsetC', 'USEG:UND1:??50:CM4OFFSETC'; ...
    'U??:CM4:GainC', 'USEG:UND1:??50:CM4GAINC'; ...
    'U??:CM5:ZeroOffsetC', 'USEG:UND1:??50:CM5OFFSETC'; ...
    'U??:CM5:GainC', 'USEG:UND1:??50:CM5GAINC'; ...
    'U??:CM1:deltaMov', 'USEG:UND1:??50:CM1DELTAMOV'; ...
    'U??:CM2:deltaMov', 'USEG:UND1:??50:CM2DELTAMOV'; ...
    'U??:CM3:deltaMov', 'USEG:UND1:??50:CM3DELTAMOV'; ...
    'U??:CM4:deltaMov', 'USEG:UND1:??50:CM4DELTAMOV'; ...
    'U??:CM5:deltaMov', 'USEG:UND1:??50:CM5DELTAMOV'; ...
    'U??:camMaxMov', 'USEG:UND1:??50:CAMMAXMOV'; ...
    'U??:CM1:velocityC', 'USEG:UND1:??50:CM1VELOCITYC'; ...
    'U??:CM2:velocityC', 'USEG:UND1:??50:CM2VELOCITYC'; ...
    'U??:CM3:velocityC', 'USEG:UND1:??50:CM3VELOCITYC'; ...
    'U??:CM4:velocityC', 'USEG:UND1:??50:CM4VELOCITYC'; ...
    'U??:CM5:velocityC', 'USEG:UND1:??50:CM5VELOCITYC'; ...
    'U??:camMinMovC', 'USEG:UND1:??50:CAMMINMOVC'; ...
    'U??:moveCams', 'USEG:UND1:??50:MOVECAMS'; ...
    'U??:takeOffEh', 'USEG:UND1:??50:TAKEOFFEH'; ...
    'U??:US_Y:curPosC', 'USEG:UND1:??50:USYCURPOSC'; ...
    'U??:DS_Y:curPosC', 'USEG:UND1:??50:DSYCURPOSC'; ...
    'U??:DS_X:curPosC', 'USEG:UND1:??50:DSXCURPOSC'; ...
    'U??:US_Y:setC', 'USEG:UND1:??50:USYSETC'; ...
    'U??:DS_Y:setC', 'USEG:UND1:??50:DSYSETC'; ...
    'U??:US_X:setC', 'USEG:UND1:??50:USXSETC'; ...
    'U??:DS_X:setC', 'USEG:UND1:??50:DSXSETC'; ...
    'U??:DS:jogValueC', 'USEG:UND1:??50:DSJOGVALUEC'; ...
    'U??:US:jogValueC', 'USEG:UND1:??50:USJOGVALUEC'; ...
    'U??:US:jogDist', 'USEG:UND1:??50:USJOGDIST'; ...
    'U??:DS:jogDist', 'USEG:UND1:??50:DSJOGDIST'; ...
    'U??:CMx:enabledM', 'USEG:UND1:??50:CMXENABLEDM'; ...
    'U??:CMx:statusM', 'USEG:UND1:??50:CMXSTATUSM'; ...
    'U??:X1', 'USEG:UND1:??50:X1'; ...
    'U??:X23', 'USEG:UND1:??50:X23'; ...
    'U??:beta2', 'USEG:UND1:??50:BETA2'; ...
    'U??:beta2rad', 'USEG:UND1:??50:BETA2RAD'; ...
    'U??:US_X:readCalcM', 'USEG:UND1:??50:USXREADCALCM'; ...
    'U??:US_Y:readCalcM', 'USEG:UND1:??50:USYREADCALCM'; ...
    'U??:DS_X:readCalcM', 'USEG:UND1:??50:DSXREADCALCM'; ...
    'U??:DS_Y:readCalcM', 'USEG:UND1:??50:DSYREADCALCM'; ...
    'U??:rollCalc', 'USEG:UND1:??50:ROLLCALC'; ...
    'U??:resetCamVelM', 'USEG:UND1:??50:RESETCAMVELM'; ...
    'U??:resetCamVel', 'USEG:UND1:??50:RESETCAMVEL'; ...
    'U??:CM1:adcM', 'USEG:UND1:??50:CM1ADCM'; ...
    'U??:CM2:adcM', 'USEG:UND1:??50:CM2ADCM'; ...
    'U??:CM3:adcM', 'USEG:UND1:??50:CM3ADCM'; ...
    'U??:CM4:adcM', 'USEG:UND1:??50:CM4ADCM'; ...
    'U??:CM5:adcM', 'USEG:UND1:??50:CM5ADCM'; ...
    'U??:Excitation:adcM', 'USEG:UND1:??50:EXCTTNADCM'; ...
    'U??:CM1:stopMotor', 'USEG:UND1:??50:CM1STOPMOTOR'; ...
    'U??:CM2:stopMotor', 'USEG:UND1:??50:CM2STOPMOTOR'; ...
    'U??:CM3:stopMotor', 'USEG:UND1:??50:CM3STOPMOTOR'; ...
    'U??:CM4:stopMotor', 'USEG:UND1:??50:CM4STOPMOTOR'; ...
    'U??:CM5:stopMotor', 'USEG:UND1:??50:CM5STOPMOTOR'; ...
    'U??:CM1:readDeg', 'USEG:UND1:??50:CM1READDEG'; ...
    'U??:CM2:readDeg', 'USEG:UND1:??50:CM2READDEG'; ...
    'U??:CM3:readDeg', 'USEG:UND1:??50:CM3READDEG'; ...
    'U??:CM4:readDeg', 'USEG:UND1:??50:CM4READDEG'; ...
    'U??:CM5:readDeg', 'USEG:UND1:??50:CM5READDEG'; ...
    'U??:CMx:stopMotorsC', 'USEG:UND1:??50:CMXSTPMOTRSC'; ...
    'U??:CM1:moveAngle', 'USEG:UND1:??50:CM1MOVEANGLE'; ...
    'U??:BFW_X:setC', 'USEG:UND1:??50:BFWXSETC'; ...
    'U??:BFW_Y:setC', 'USEG:UND1:??50:BFWYSETC'; ...
    'U??:QUAD_X:setC', 'USEG:UND1:??50:QUADXSETC'; ...
    'U??:QUAD_Y:setC', 'USEG:UND1:??50:QUADYSETC'; ...
    'U??:Unified_Y_SetC', 'USEG:UND1:??50:UNIFIEDYSETC'; ...
    'U??:Unified_X_SetC', 'USEG:UND1:??50:UNIFIEDXSETC'; ...
    'U??:Unified:moveY', 'USEG:UND1:??50:UNIFIEDMOVEY'; ...
    'U??:Unified:moveX', 'USEG:UND1:??50:UNIFIEDMOVEX'; ...
    'U??:Bfw_X_ReadCALC', 'USEG:UND1:??50:BFWXREADCALC'; ...
    'U??:Bfw_Y_ReadCALC', 'USEG:UND1:??50:BFWYREADCALC'; ...
    'U??:CMx:startMotion', 'USEG:UND1:??50:CMXSTRTMTION'; ...
    'U??:CMx:altMotionStart', 'USEG:UND1:??50:CMXALTMTNSTR'; ...
    'U??:BFW_QUAD:posC', 'USEG:UND1:??50:BFWQUADPOSC'; ...
    'U??:BFW_QUAD:moveC', 'USEG:UND1:??50:BFWQUADMOVEC'; ...
    'U??:L', 'USEG:UND1:??50:L'; ...
    'U??:Q', 'USEG:UND1:??50:Q'; ...
    'U??:B', 'USEG:UND1:??50:B'; ...
    'U??:rollSetC', 'USEG:UND1:??50:ROLLSETC'; ...
    'U??:CM1:ERROR', 'USEG:UND1:??50:CM1ERROR'; ...
    'U??:CM2:ERROR', 'USEG:UND1:??50:CM2ERROR'; ...
    'U??:CM3:ERROR', 'USEG:UND1:??50:CM3ERROR'; ...
    'U??:CM4:ERROR', 'USEG:UND1:??50:CM4ERROR'; ...
    'U??:CM5:ERROR', 'USEG:UND1:??50:CM5ERROR'; ...
    'U??:$(M):motor', 'USEG:UND1:??50:$(M)MOTOR'; ...
    'U??:CM1:motor', 'USEG:UND1:??50:CM1MOTOR'; ... % JJW edit
    'U??:CM2:motor', 'USEG:UND1:??50:CM2MOTOR'; ... % JJW edit
    'U??:CM3:motor', 'USEG:UND1:??50:CM3MOTOR'; ... % JJW edit
    'U??:CM4:motor', 'USEG:UND1:??50:CM4MOTOR'; ... % JJW edit
    'U??:CM5:motor', 'USEG:UND1:??50:CM5MOTOR'; ... % JJW edit
    'U??:fanoutLP', 'USEG:UND1:??50:FANOUTLP'; ...
    'U??:fanoutLP2', 'USEG:UND1:??50:FANOUTLP2'; ...
    'U??:LP1:normCalc', 'USEG:UND1:??50:LP1NORMCALC'; ...
    'U??:LP1:zeroOffsetC', 'USEG:UND1:??50:LP1OFFSETC'; ...
    'U??:LP1:gainC', 'USEG:UND1:??50:LP1GAINC'; ...
    'U??:LP2:normCalc', 'USEG:UND1:??50:LP2NORMCALC'; ...
    'U??:LP2:zeroOffsetC', 'USEG:UND1:??50:LP2OFFSETC'; ...
    'U??:LP2:gainC', 'USEG:UND1:??50:LP2GAINC'; ...
    'U??:LP3:normCalc', 'USEG:UND1:??50:LP3NORMCALC'; ...
    'U??:LP3:zeroOffsetC', 'USEG:UND1:??50:LP3OFFSETC'; ...
    'U??:LP3:gainC', 'USEG:UND1:??50:LP3GAINC'; ...
    'U??:LP4:normCalc', 'USEG:UND1:??50:LP4NORMCALC'; ...
    'U??:LP4:zeroOffsetC', 'USEG:UND1:??50:LP4OFFSETC'; ...
    'U??:LP4:gainC', 'USEG:UND1:??50:LP4GAINC'; ...
    'U??:LP5:normCalc', 'USEG:UND1:??50:LP5NORMCALC'; ...
    'U??:LP5:zeroOffsetC', 'USEG:UND1:??50:LP5OFFSETC'; ...
    'U??:LP5:gainC', 'USEG:UND1:??50:LP5GAINC'; ...
    'U??:LP6:normCalc', 'USEG:UND1:??50:LP6NORMCALC'; ...
    'U??:LP6:zeroOffsetC', 'USEG:UND1:??50:LP6OFFSETC'; ...
    'U??:LP6:gainC', 'USEG:UND1:??50:LP6GAINC'; ...
    'U??:LP7:normCalc', 'USEG:UND1:??50:LP7NORMCALC'; ...
    'U??:LP7:zeroOffsetC', 'USEG:UND1:??50:LP7OFFSETC'; ...
    'U??:LP7:gainC', 'USEG:UND1:??50:LP7GAINC'; ...
    'U??:LP8:normCalc', 'USEG:UND1:??50:LP8NORMCALC'; ...
    'U??:LP8:zeroOffsetC', 'USEG:UND1:??50:LP8OFFSETC'; ...
    'U??:LP8:gainC', 'USEG:UND1:??50:LP8GAINC'; ...
    'U??:LP9:normCalc', 'USEG:UND1:??50:LP9NORMCALC'; ...
    'U??:LP9:zeroOffsetC', 'USEG:UND1:??50:LP9OFFSETC'; ...
    'U??:LP9:gainC', 'USEG:UND1:??50:LP9GAINC'; ...
    'U??:TM1:stopMotor', 'USEG:UND1:??50:TM1STOPMOTOR'; ...
    'U??:TM2:stopMotor', 'USEG:UND1:??50:TM2STOPMOTOR'; ...
    'U??:LP1:positionCalc', 'USEG:UND1:??50:LP1POSCALC'; ...
    'U??:LP2:positionCalc', 'USEG:UND1:??50:LP2POSCALC'; ...
    'U??:LP3:positionCalc', 'USEG:UND1:??50:LP3POSCALC'; ...
    'U??:LP4:positionCalc', 'USEG:UND1:??50:LP4POSCALC'; ...
    'U??:LP5:positionCalc', 'USEG:UND1:??50:LP5POSCALC'; ...
    'U??:LP6:positionCalc', 'USEG:UND1:??50:LP6POSCALC'; ...
    'U??:LP7:positionCalc', 'USEG:UND1:??50:LP7POSCALC'; ...
    'U??:LP8:positionCalc', 'USEG:UND1:??50:LP8POSCALC'; ...
    'U??:LP9:positionCalc', 'USEG:UND1:??50:LP9POSCALC'; ...
    'U??:TMx:posC', 'USEG:UND1:??50:TMXPOSC'; ...
    'U??:TMx:transMov', 'USEG:UND1:??50:TMXTRANSMOV'; ...
    'U??:LP1:adcM', 'USEG:UND1:??50:LP1ADCM'; ...
    'U??:LP2:adcM', 'USEG:UND1:??50:LP2ADCM'; ...
    'U??:LP3:adcM', 'USEG:UND1:??50:LP3ADCM'; ...
    'U??:LP4:adcM', 'USEG:UND1:??50:LP4ADCM'; ...
    'U??:LP5:adcM', 'USEG:UND1:??50:LP5ADCM'; ...
    'U??:LP6:adcM', 'USEG:UND1:??50:LP6ADCM'; ...
    'U??:LP7:adcM', 'USEG:UND1:??50:LP7ADCM'; ...
    'U??:LP8:adcM', 'USEG:UND1:??50:LP8ADCM'; ...
    'U??:LP9:adcM', 'USEG:UND1:??50:LP9ADCM'; ...
    'U??:TMx:ReadCALC', 'USEG:UND1:??50:TMXREADCALC'; ...
    'U??:transMovingM', 'USEG:UND1:??50:TRANSMOVINGM'; ...
    'U??:TM1:moveM', 'USEG:UND1:??50:TM1MOVINGM'; ...
    'U??:TM2:limitSwitchM', 'USEG:UND1:??50:TM2LMTSWTCHM'; ...
    'U??:TM1:limitSwitchM', 'USEG:UND1:??50:TM1LMTSWTCHM'; ...
    'U??:TMx:stopMotorsC', 'USEG:UND1:??50:TMXSTOPMTRSC'; ...
    'U??:TM2:moveM', 'USEG:UND1:??50:TM2MOVEM'; ...
    'U??:TMx:savedPosC', 'USEG:UND1:??50:TMXSVDPOSC'; ...
    'U??:TMx:savedPosIn', 'USEG:UND1:??50:TMXSVDPOSIN'; ...
    'U??:TMx:savedPosOut', 'USEG:UND1:??50:TMXSVDPOSOUT'; ...
    'U??:TMx:savedPos1', 'USEG:UND1:??50:TMXSVDPOS1'; ...
    'U??:TMx:savedPos2', 'USEG:UND1:??50:TMXSVDPOS2'; ...
    'U??:TMx:savedPos3', 'USEG:UND1:??50:TMXSVDPOS3'; ...
    'U??:TMx:savedPos4', 'USEG:UND1:??50:TMXSVDPOS4'; ...
    'U??:TMx:pos1Desc', 'USEG:UND1:??50:TMXPOS1DESC'; ...
    'U??:TMx:pos2Desc', 'USEG:UND1:??50:TMXPOS2DESC'; ...
    'U??:TMx:pos3Desc', 'USEG:UND1:??50:TMXPOS3DESC'; ...
    'U??:TMx:pos4Desc', 'USEG:UND1:??50:TMXPOS4DESC'; ...
    'U??:TM1:motor', 'USEG:UND1:??50:TM1MOTOR'; ... % jjw edit
    'U??:TM2:motor', 'USEG:UND1:??50:TM2MOTOR'; ... % jjw edit
    'U??:BFW:actInM', 'BFW:UND1:??10:ACTINM'; ...
    'U??:BFW:actOutM', 'BFW:UND1:??10:ACTOUTM'; ...
    'U??:BFW:actPosCalc', 'BFW:UND1:??10:ACTPOSCALC'; ...
    'U??:BFW:actC', 'BFW:UND1:??10:ACTC'; ...
    'U??:BFW:actPosM', 'BFW:UND1:??10:ACTPOSM'; ...
    'U??:T01', 'USEG:UND1:??50:RTD01'; ...
    'U??:T02', 'USEG:UND1:??50:RTD02'; ...
    'U??:T03', 'USEG:UND1:??50:RTD03'; ...
    'U??:T04', 'USEG:UND1:??50:RTD04'; ...
    'U??:T05', 'USEG:UND1:??50:RTD05'; ...
    'U??:T06', 'USEG:UND1:??50:RTD06'; ...
    'U??:T07', 'USEG:UND1:??50:RTD07'; ...
    'U??:T08', 'USEG:UND1:??50:RTD08'; ...
    'U??:T09', 'USEG:UND1:??50:RTD09'; ...
    'U??:T10', 'USEG:UND1:??50:RTD10'; ...
    'U??:T11', 'USEG:UND1:??50:RTD11'; ...
    'U??:T12', 'USEG:UND1:??50:RTD12'; ...
    'U??:stopMotorsC', 'USEG:UND1:??50:STOPMOTORSC'; ...
    'U??:bfwStatusM', 'BFW:UND1:??10:STATUSM'; ... % jjw edit
    'U??:eStopStatusM', 'USEG:UND1:??50:ESTOPSTATUSM'; ...
    'U??:level1FaultM', 'USEG:UND1:??50:LEVEL1FAULTM'; ...
    'U??:level2FaultM', 'USEG:UND1:??50:LEVEL2FAULTM'; ...
    'U??:24voltM', 'USEG:UND1:??50:24VOLTM'; ...
    'U??:42voltM', 'USEG:UND1:??50:42VOLTM'; ...
    'U??:transDiffZeroM', 'USEG:UND1:??50:TRANSDIFZERM'; ...
    'U??:transDiffOneM', 'USEG:UND1:??50:TRANSDIFONEM'; ...
    'U??:level1Stop', 'USEG:UND1:??50:LEVEL1STOP'; ...
    'U??:CMx:posTolerance', 'USEG:UND1:??50:CMXPOSTOLRNC'; ...
    'U??:TMx:posTolerance', 'USEG:UND1:??50:TMXPOSTOLRNC'; ...
    'U??:smartMonitorC', 'USEG:UND1:??50:SMRTMONITORC'; ...
    'U??:motorError', 'USEG:UND1:??50:MOTORERROR'; ...
    'U??:smartMonitorM', 'USEG:UND1:??50:SMRTMONITORM'; ...
    'U??:CM1:motorStatus', 'USEG:UND1:??50:CM1MOTORSTAT'; ...
    'U??:CM2:motorStatus', 'USEG:UND1:??50:CM2MOTORSTAT'; ...
    'U??:CM3:motorStatus', 'USEG:UND1:??50:CM3MOTORSTAT'; ...
    'U??:CM4:motorStatus', 'USEG:UND1:??50:CM4MOTORSTAT'; ...
    'U??:CM5:motorStatus', 'USEG:UND1:??50:CM5MOTORSTAT'; ...
    'U??:TM1:motorStatus', 'USEG:UND1:??50:TM1MOTORSTAT'; ...
    'U??:TM2:motorStatus', 'USEG:UND1:??50:TM2MOTORSTAT'; ...
    'U??:CM1:motorAlarm', 'USEG:UND1:??50:CM1MOTORALRM'; ...
    'U??:CM2:motorAlarm', 'USEG:UND1:??50:CM2MOTORALRM'; ...
    'U??:CM3:motorAlarm', 'USEG:UND1:??50:CM3MOTORALRM'; ...
    'U??:CM4:motorAlarm', 'USEG:UND1:??50:CM4MOTORALRM'; ...
    'U??:CM5:motorAlarm', 'USEG:UND1:??50:CM5MOTORALRM'; ...
    'U??:TM1:motorAlarm', 'USEG:UND1:??50:TM1MOTORALRM'; ...
    'U??:TM2:motorAlarm', 'USEG:UND1:??50:TM2MOTORALRM'; ...
    'U??:recoverMtrPos', 'USEG:UND1:??50:RCOVRMOTRPOS'; ...
    'U??:CM1:motionOverrideC', 'USEG:UND1:??50:CM1MTNOVRRDC'; ...
    'U??:CM2:motionOverrideC', 'USEG:UND1:??50:CM2MTNOVRRDC'; ...
    'U??:CM3:motionOverrideC', 'USEG:UND1:??50:CM3MTNOVRRDC'; ...
    'U??:CM4:motionOverrideC', 'USEG:UND1:??50:CM4MTNOVRRDC'; ...
    'U??:CM5:motionOverrideC', 'USEG:UND1:??50:CM5MTNOVRRDC'; ...
    'U??:TM1:motionOverrideC', 'USEG:UND1:??50:TM1MTNOVRRDC'; ...
    'U??:TM2:motionOverrideC', 'USEG:UND1:??50:TM2MTNOVRRDC'; ...
    'U??:motorCommM', 'USEG:UND1:??50:MOTORCOMMMNT'; ...
    'U??:motorPosM', 'USEG:UND1:??50:MOTORPOSM'; ...
    'U??:motorM', 'USEG:UND1:??50:MOTORM'; ...
    'U??:motorStatusM', 'USEG:UND1:??50:MOTORSTATUSM'; ...
    'U??:BFW:posTolerance', 'BFW:UND1:??10:POSTOLERANCE'; ...
    'U??:BFW:inPos', 'BFW:UND1:??10:INPOS'; ...
    'U??:BFW:outPos', 'BFW:UND1:??10:OUTPOS'; ...
    'U??:recoverLevel1', 'USEG:UND1:??50:RECOVERLEVL1'; ...
    'U??:recoverLevel2', 'USEG:UND1:??50:RECOVERLEVL2'; ...
    'U??:rtdStatusM', 'USEG:UND1:??50:RTDSTATUSM' ...
    };

% Convert a single string to a 1x1 cell
if (~iscell(oldpvs))
    oldpvs = cellstr(oldpvs);
end

% Loop over pvs in cell array
for q=1:length(oldpvs)
    new = '';
    old =oldpvs{q};

    % check validity
    if strcmp(old, '') % blank input
        old = 'U99:BlankOldPV';
    end

    if ( old ( 1 ) ~= 'U' || ~isdigit ( old ( 2 ) ) || ~isdigit ( old ( 3 ) ) )
        new = old;
    else % treat as normal conversion

        % get girder number
        girderNumber = sscanf ( old ( 2 : 3 ), '%d' );

        if ( girderNumber < 1 || girderNumber > 33 )
            display(['Girder number ' num2str(girderNumber) ]);
            girderNumber=99;
        end


        % get epics field string
        fsStart = strfind(old, '.');
        fieldString =old(fsStart:end);% includes the dot


        % get template
        template = strcat ( 'U??', old ( 4 : end ) );
        template(strfind(old,'.'):end) = []; % strip field string from template

        n = length ( translation );

        generateTestProgram = false;

        if ( generateTestProgram )
            fid = fopen ( 'test_transPVs.m', 'w' );

            for  j = 1 : n
                for k = 1 : 33
                    oldPVstring = strrep ( translation { j, 1 }, '??', sprintf ( '%2.2d', k ) );
                    fprintf ( fid, 'fprintf (  ''transPVs ( ''''%%s'''' ) -> ''''%%s'''';\\n'', ''%s'', transPVs ( ''%s'' ) );\n', oldPVstring, oldPVstring );
                end
            end

            fclose ( fid );
        end

        for j = 1 : n
            if ( strcmp ( translation { j, 1 }, template ) )
                new = strrep ( translation { j, 2 }, '??', sprintf ( '%d', girderNumber ) );
                %need to add epics field
                new = [new fieldString];
                break;
            end
        end

    end % end else (normal conversion)


    newpvs{q,1} = new;

end % end of pv loop
end % end of undulatorPVchange


function L= isdigit ( d )

d = d - 48;

if ( d >=0 && d <=9 )
    L = true;
else
    L = false;
end

end