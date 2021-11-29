close all
sh=Steering_Functions();

ARC=ARC_Steering_Class;

ARC.loadModelFromFile('DSNUMMER1');
ARC.loadStaticFromFile('DSNUMMER1');

ARC.loadOrbitFromFile(1,'DSNUMMER1');
ARC.loadOrbitFromFile(2,'DSNUMMER2');

ARC.evaluate_avg_trajectory(1,10^8,6);

[CorrMatrix_S,CorrMatrixAngles_S]=sh.CorrectorOrbitMatrix_Fast(ARC.staticS,ARC.D(1).MODEL_S.rMat,ARC.D(1).MODEL_S.Pos,ARC.D(1).MODEL_S.energy);
[CorrMatrix_H,CorrMatrixAngles_H]=sh.CorrectorOrbitMatrix_Fast(ARC.staticH,ARC.D(1).MODEL_H.rMat,ARC.D(1).MODEL_H.Pos,ARC.D(1).MODEL_H.energy);

Difference_CorrectorsH=ARC.D(2).CorrectorStrengths_H-ARC.D(1).CorrectorStrengths_H;
Difference_CorrectorsS=ARC.D(2).CorrectorStrengths_S-ARC.D(1).CorrectorStrengths_S;

InducedOrbitH=CorrMatrix_H*Difference_CorrectorsH;
InducedOrbitS=CorrMatrix_S*Difference_CorrectorsS;

InducedOrbitH_X=InducedOrbitH(1:2:end);
InducedOrbitH_Y=InducedOrbitH(2:2:end);

InducedOrbitS_X=InducedOrbitS(1:2:end);
InducedOrbitS_Y=InducedOrbitS(2:2:end);

DifferenceOrbitS_X=ARC.D(2).MS_X-ARC.D(1).MS_X;
DifferenceOrbitS_Y=ARC.D(2).MS_Y-ARC.D(1).MS_Y;

DifferenceOrbitH_X=ARC.D(2).MH_X-ARC.D(1).MH_X;
DifferenceOrbitH_Y=ARC.D(2).MH_Y-ARC.D(1).MH_Y;

figure
plot(ARC.staticS.zBPM,InducedOrbitS_X*1000,'k')
hold on
plot(ARC.staticS.zBPM,DifferenceOrbitS_X,'r');
legend('Model','Measured');
title('Soft Line X');

figure
plot(ARC.staticS.zBPM,InducedOrbitS_Y*1000,'k')
hold on
plot(ARC.staticS.zBPM,DifferenceOrbitS_Y,'r');
legend('Model','Measured');
title('Soft Line Y');

figure
plot(ARC.staticH.zBPM,InducedOrbitH_X*1000,'k')
hold on
plot(ARC.staticH.zBPM,DifferenceOrbitH_X,'r');
legend('Model','Measured');
title('Hard Line X');

figure
plot(ARC.staticH.zBPM,InducedOrbitH_Y*1000,'k')
hold on
plot(ARC.staticH.zBPM,DifferenceOrbitH_Y,'r');
legend('Model','Measured');
title('Hard Line Y');

MatchOn=ARC.static.bpmList_e(46:51);
Weight.X=ones(size(MatchOn));
Weight.Y=ones(size(MatchOn));
Weight.T=ones(size(MatchOn))/10^11;
Sigma=3;

MatchSeparate=0;

Indices=ARC.match_entrance(sh, [1,2], MatchOn, Weight, Sigma, MatchSeparate);
%Difference_CorrectorsH(1:49)=0; Difference_CorrectorsS(1:49)=0;
InducedOrbitH=CorrMatrix_H*Difference_CorrectorsH;
InducedOrbitS=CorrMatrix_S*Difference_CorrectorsS;

InducedOrbitH_X=InducedOrbitH(1:2:end);
InducedOrbitH_Y=InducedOrbitH(2:2:end);

InducedOrbitS_X=InducedOrbitS(1:2:end);
InducedOrbitS_Y=InducedOrbitS(2:2:end);

DifferenceOrbitS_X=ARC.D(2).MSF_X-ARC.D(1).MSF_X;
DifferenceOrbitS_Y=ARC.D(2).MSF_Y-ARC.D(1).MSF_Y;

DifferenceOrbitH_X=ARC.D(2).MHF_X-ARC.D(1).MHF_X;
DifferenceOrbitH_Y=ARC.D(2).MHF_Y-ARC.D(1).MHF_Y;

figure
plot(ARC.staticS.zBPM,InducedOrbitS_X*1000,'k.-')
hold on
plot(ARC.staticS.zBPM,DifferenceOrbitS_X,'r.-');
legend('Model','Measured');
title('MATCH Soft Line X');

figure
plot(ARC.staticS.zBPM,InducedOrbitS_Y*1000,'k.-')
hold on
plot(ARC.staticS.zBPM,DifferenceOrbitS_Y,'r.-');
legend('Model','Measured');
title('MATCH Soft Line Y');

figure
plot(ARC.staticH.zBPM,InducedOrbitH_X*1000,'k.-')
hold on
plot(ARC.staticH.zBPM,DifferenceOrbitH_X,'r.-');
legend('Model','Measured');
title('MATCH Hard Line X');

figure
plot(ARC.staticH.zBPM,InducedOrbitH_Y*1000,'k.-')
hold on
plot(ARC.staticH.zBPM,DifferenceOrbitH_Y,'r.-');
legend('Model','Measured');
title('MATCH Hard Line Y');

figure
plot(ARC.staticH.zCorr,Difference_CorrectorsH,'xk')
plot(ARC.staticS.zCorr,Difference_CorrectorsS,'or')

FCOR=find((ARC.static.zCorr>410) & (ARC.static.zCorr<500));
UseCorrectors=ARC.static.corrList_e(FCOR);
FBPM=find((ARC.static.zBPM>500) & (ARC.static.zBPM<520));
UseBPMs=ARC.static.bpmList_e(FBPM);

[~,CorrLinesInSoftSystem,CorrLinesInProblemMatrix_FormSoft]=intersect(ARC.staticS.corrList_e,UseCorrectors);
[~,CorrLinesInHardSystem,CorrLinesInProblemMatrix_FromHard]=intersect(ARC.staticH.corrList_e,UseCorrectors);
[~,BpmLinesInSoftSystem,BpmXIndexInProblemMatrix_FromSoft]=intersect(ARC.staticS.bpmList_e,UseBPMs);
[~,BpmLinesInHardSystem,BpmXIndexInProblemMatrix_FromHard]=intersect(ARC.staticH.bpmList_e,UseBPMs);

AllBPMMatrix=zeros(2*length(ARC.staticS.bpmList)+ 2*length(ARC.staticH.bpmList), length(UseCorrectors));
AllBPMMatrix(1:2*length(ARC.staticS.bpmList),CorrLinesInProblemMatrix_FormSoft) = CorrMatrix_S(:,CorrLinesInSoftSystem);
AllBPMMatrix(2*length(ARC.staticS.bpmList) + (1:(2*length(ARC.staticH.bpmList))),CorrLinesInProblemMatrix_FormSoft) = CorrMatrix_H(:,CorrLinesInHardSystem);

RecordedOrbits_XS= ARC.D(2).MSF_X;
RecordedOrbits_YS= ARC.D(2).MSF_Y;
RecordedOrbits_XH= ARC.D(2).MHF_X;
RecordedOrbits_YH= ARC.D(2).MHF_Y;

KeepBPMLines_X_Soft=2*(BpmLinesInSoftSystem)-1;
KeepBPMLines_Y_Soft=2*(BpmLinesInSoftSystem);
KeepBPMLines_X_Hard=2*(BpmLinesInHardSystem)-1;
KeepBPMLines_Y_Hard=2*(BpmLinesInHardSystem);

KeepBPMLines=[KeepBPMLines_X_Soft(:);KeepBPMLines_Y_Soft(:);KeepBPMLines_X_Hard(:)+2*length(ARC.staticS.bpmList_e);KeepBPMLines_Y_Hard(:)+2*length(ARC.staticS.bpmList_e)];
MeasurementColumn=NaN*ones(length(KeepBPMLines),1);
MeasurementColumn(1:length(KeepBPMLines_X_Soft)) = RecordedOrbits_XS(BpmLinesInSoftSystem);
MeasurementColumn(length(KeepBPMLines_X_Soft) + (1:length(KeepBPMLines_Y_Soft))) = RecordedOrbits_YS(BpmLinesInSoftSystem);
MeasurementColumn(length(KeepBPMLines_X_Soft)+length(KeepBPMLines_Y_Soft)+(1:length(KeepBPMLines_X_Hard))) = RecordedOrbits_XH(BpmLinesInHardSystem);
MeasurementColumn(length(KeepBPMLines_X_Soft)+length(KeepBPMLines_Y_Soft)+length(KeepBPMLines_X_Hard)+(1:length(KeepBPMLines_Y_Hard))) = RecordedOrbits_YH(BpmLinesInHardSystem);

SystemMatrix=AllBPMMatrix(KeepBPMLines,:);

fitSVDRatio=10^-4;
[SystemSolution,SystemSolution_Std] = util_lssvd(SystemMatrix, MeasurementColumn, ones(size(MeasurementColumn))/10^6, fitSVDRatio);

% Old_Corrector_Values_Soft = ARC.D(2).CorrectorStrengths_S(CorrLinesInSoftSystem);
% Old_Corrector_Values_Hard = ARC.D(2).CorrectorStrengths_H(CorrLinesInHardSystem);
% Old_Corrector_Values(CorrLinesInProblemMatrix_FormSoft) = Old_Corrector_Values_Soft;
% Old_Corrector_Values(CorrLinesInProblemMatrix_FromHard) = Old_Corrector_Values_Hard;

AllCorrectorsHard_new=zeros(length(ARC.staticH.corrList),1);
AllCorrectorsSoft_new=zeros(length(ARC.staticS.corrList),1);

AllCorrectorsHard_new(CorrLinesInHardSystem) = SystemSolution(CorrLinesInProblemMatrix_FromHard)/1000;
AllCorrectorsSoft_new(CorrLinesInSoftSystem) = SystemSolution(CorrLinesInProblemMatrix_FormSoft)/1000;

InducedOrbitH_FIT=CorrMatrix_H*AllCorrectorsHard_new;
InducedOrbitS_FIT=CorrMatrix_S*AllCorrectorsSoft_new;

InducedOrbitH_XFIT=InducedOrbitH_FIT(1:2:end);
InducedOrbitH_YFIT=InducedOrbitH_FIT(2:2:end);

InducedOrbitS_XFIT=InducedOrbitS_FIT(1:2:end);
InducedOrbitS_YFIT=InducedOrbitS_FIT(2:2:end);

figure
plot(ARC.staticS.zBPM,InducedOrbitS_X*1000,'k.-')
hold on
plot(ARC.staticS.zBPM,InducedOrbitS_XFIT*1000,'b.-')
plot(ARC.staticS.zBPM,DifferenceOrbitS_X,'r.-');
legend('Model','Fitted','Measured');
title('MATCH Soft Line X');

figure
plot(ARC.staticS.zBPM,InducedOrbitS_Y*1000,'k.-')
hold on
plot(ARC.staticS.zBPM,InducedOrbitS_YFIT*1000,'b.-')
plot(ARC.staticS.zBPM,DifferenceOrbitS_Y,'r.-');
legend('Model','Fitted','Measured');
title('MATCH Soft Line Y');

figure
plot(ARC.staticH.zBPM,InducedOrbitH_X*1000,'k.-')
hold on
plot(ARC.staticH.zBPM,InducedOrbitH_XFIT*1000,'b.-')
plot(ARC.staticH.zBPM,DifferenceOrbitH_X,'r.-');
legend('Model','Fitted','Measured');
title('MATCH Hard Line X');

figure
plot(ARC.staticH.zBPM,InducedOrbitH_Y*1000,'k.-')
hold on
plot(ARC.staticH.zBPM,InducedOrbitH_YFIT*1000,'b.-')
plot(ARC.staticH.zBPM,DifferenceOrbitH_Y,'r.-');
legend('Model','Fitted','Measured');
title('MATCH Hard Line Y');
