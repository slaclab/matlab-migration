function fh=CVCRCI_ScanFunctions
    fh.Do_Nothing = @Do_Nothing;
    fh.Do_NothingVOM = @Do_Nothing_PassaTutto;
    fh.ResoreSetting = @RestoreSetting;
    fh.DontResoreSetting = @DontRestoreSetting;
    fh.No_ParseTable = @No_ParseTable;
    fh.CVCRCI5_StandardScanFunction = @CVCRCI5_StandardScanFunction;
    fh.CVCRCI5_StandardSetFunction = @CVCRCI5_StandardSetFunction;
    fh.CalculateKScanPoints=@CalculateKScanPoints;
    fh.CalculatePSScanPoints=@CalculatePSScanPoints;
    fh.CalculatePSScanPointsDEG=@CalculatePSScanPointsDEG;
    fh.CalculatePSScanPointsDEG_Range=@CalculatePSScanPointsDEG_Range;
    fh.CalculateKParallelScanPoints=@CalculateKParallelScanPoints;
    fh.UndulatorKSet=@UndulatorKSet;
    fh.PSGapSet=@PSGapSet;
    fh.PSGapSetRange=@PSGapSetRange;
    fh.Parse_TableKParallelScanPoints=@Parse_TableKParallelScanPoints;
    fh.CalculateGeneralizedScanPoints=@CalculateGeneralizedScanPoints;
    fh.Parse_TableGeneralizedKScanPoints=@Parse_TableGeneralizedKScanPoints;
    fh.UndulatorLineSteerFlat=@UndulatorLineSteerFlat;
    fh.WaitForOK=@WaitForOK;
    fh.ResetWaitForOk=@ResetWaitForOk;
    fh.MySetFunction=@MySetFunction;
    fh.MyCalculateScanPoints=@MyCalculateScanPoints;
    fh.HXRSS_Scan_SetFunction=@HXRSS_Scan_SetFunction;
    fh.HXRSS_StandardScanFunction=@HXRSS_StandardScanFunction;
    fh.CalculateXLEAP_Delay_andK_ScanPoints=@CalculateXLEAP_Delay_andK_ScanPoints;
    fh.Delay_andK_ScanPoints_Set=@Delay_andK_ScanPoints_Set;
    fh.CalculateBOD_WireScanPoints=@CalculateBOD_WireScanPoints;
    fh.SetBOD_Wire=@SetBOD_Wire;
    fh.ParseTableRange=@ParseTableRange;
    
end

function Table=ParseTableRange(Table)
    CentralValues=lcaGetSmart(Table(1,:));
    Table{2,1}=num2str(CentralValues(1)-0.003); Table{2,2}=num2str(CentralValues(2)-0.003);
    Table{3,1}=num2str(CentralValues(1)+0.003); Table{3,2}=num2str(CentralValues(2)+0.003);
end

function ScanSetting=SetBOD_Wire(ScanSetting,PositionOrValues, usePvValue)
    if(nargin<3)
       usePvValue=1; 
    end
    if(usePvValue)
       % Set the PVs and forget
       ScanSetting.OldDestination=lcaGetSmart(ScanSetting.LcaPutNoWaitList);
       Target=PositionOrValues;
       lcaPutSmart(ScanSetting.LcaPutNoWaitList,Target);
    else
       % Set the "Position within the scan"
       ScanSetting.OldDestinations=lcaGetSmart(ScanSetting.LcaPutNoWaitList);
       Target=ScanSetting.PVValues(:,PositionOrValues);
       lcaPutSmart(ScanSetting.LcaPutNoWaitList,Target);
    end
    %Manage destination arrival status and pause.
    CurrentValues=lcaGetSmart(ScanSetting.PvsWithReadOut); 
    Distance=abs(CurrentValues-Target); Re_Read=0;
    DoneMoving=lcaGetSmart(ScanSetting.ScanSetting.DoneMovingPV); 
    while((Distance>ScanSetting.Condition_TOLERANCE) || ~DoneMoving)
       pause(0.25);
       CurrentValues=lcaGetSmart(ScanSetting.PvsWithReadOut); DoneMoving=lcaGetSmart(ScanSetting.ScanSetting.DoneMovingPV); 
       NewDistance=abs(CurrentValues-Target);
       if((Distance>ScanSetting.Condition_TOLERANCE) && DoneMoving)
           lcaPutSmart(ScanSetting.KillProcPV{1},1);pause(0.05);
           lcaPutSmart(ScanSetting.LcaPutNoWaitList,Target);
           Re_Read=0;
       else
       Re_Read=Re_Read+1;
       if(any(NewDistance>=Distance) && Re_Read>5) %this seems stuck.
          Re_Read=0;
          lcaPutSmart(ScanSetting.LcaPutNoWaitList,Target); %issue command again
          disp(['Currently= ',num2str(CurrentValues),' * Target= ', num2str(Target),' * Distance = ',num2str(NewDistance)]);
       end
       end
       Distance=NewDistance;
    end
end

function [ScanSetting, ErrorString] =CalculateBOD_WireScanPoints(Table, Options)
    Options.Normal=1; Options.ZigZag=0;
    
    Table2{1,1}='SIOC:SYS0:ML02:AO314'; Table2{2,1}=Table{1,1}; Table2{2,1}=Table{1,1}; Table2{3,1}=Table{2,1};
    Table2{4,1}=Table{3,1}; Table2{5,1}='SIOC:SYS0:ML02:AO314'; Table2{6,1}='0.005'; Table2{7,1}='0'; Table2{8,1}='1'; Table2{9,1}='';
    
    [ScanSetting, ErrorString] = CVCRCI5_StandardScanFunction(Table2, Options);
    ScanSetting.ssh=SXRSS_functions();
    ScanSetting.SXRSS_Struct=ScanSetting.ssh.GetNames();
    if(any(strfind(Table{5},'BOD 1'))) %BOD1
        if(any(strfind(Table{6},'X')) || any(strfind(Table{6},'x')))
            ID=find(strcmp(ScanSetting.SXRSS_Struct.Names,'BOD1X'));
        elseif(any(strfind(Table{6},'Y')) || any(strfind(Table{6},'y')))
            ID=find(strcmp(ScanSetting.SXRSS_Struct.Names,'BOD1Y'));
        end
    elseif(any(strfind(Table{5},'BOD 2')))
        if(any(strfind(Table{6},'X')) || any(strfind(Table{6},'x')))
            ID=find(strcmp(ScanSetting.SXRSS_Struct.Names,'BOD2X'));
        elseif(any(strfind(Table{6},'Y')) || any(strfind(Table{6},'y')))
            ID=find(strcmp(ScanSetting.SXRSS_Struct.Names,'BOD2X'));
        end
    elseif(any(strfind(Table{5},'G1')))
        if(any(strfind(Table{6},'X')) || any(strfind(Table{6},'x')))
            ID=find(strcmp(ScanSetting.SXRSS_Struct.Names,'G1X'));
        elseif(any(strfind(Table{6},'Y')) || any(strfind(Table{6},'y')))
            ID=find(strcmp(ScanSetting.SXRSS_Struct.Names,'G1Y'));
        end
    elseif(any(strfind(Table{5},'M1')))
        if(any(strfind(Table{6},'X')) || any(strfind(Table{6},'x')))
            ID=find(strcmp(ScanSetting.SXRSS_Struct.Names,'M1X'));
        elseif(any(strfind(Table{6},'P')) || any(strfind(Table{6},'p')))
            ID=find(strcmp(ScanSetting.SXRSS_Struct.Names,'M1PITCH'));
        end
    elseif(any(strfind(Table{5},'M2')))
        if(any(strfind(Table{6},'X')) || any(strfind(Table{6},'x')))
            ID=find(strcmp(ScanSetting.SXRSS_Struct.Names,'M2X'));
        end
    elseif(any(strfind(Table{5},'M3')))
        if(any(strfind(Table{6},'X')) || any(strfind(Table{6},'x')))
            ID=find(strcmp(ScanSetting.SXRSS_Struct.Names,'M3X'));
        elseif(any(strfind(Table{6},'P')) || any(strfind(Table{6},'p')))
            ID=find(strcmp(ScanSetting.SXRSS_Struct.Names,'M3PITCH'));
        elseif(any(strfind(Table{6},'Y')) || any(strfind(Table{6},'y')))
            ID=find(strcmp(ScanSetting.SXRSS_Struct.Names,'M3YAW'));
        end
    elseif(any(strfind(Table{5},'Slit')))
        if(any(strfind(Table{6},'X')) || any(strfind(Table{6},'x')))
            ID=find(strcmp(ScanSetting.SXRSS_Struct.Names,'SLITX'));
        elseif(any(strfind(Table{6},'Y')) || any(strfind(Table{6},'y')))
            ID=find(strcmp(ScanSetting.SXRSS_Struct.Names,'IDY'));
        end
    end
    ScanSetting.PhysicalVariables=ScanSetting.SXRSS_Struct.Names;
    ScanSetting.PhysicalValues=NaN*ones(length(ScanSetting.PVValues),numel(ScanSetting.PhysicalVariables));
    
    SetPointPV=ScanSetting.SXRSS_Struct.PVSet{ID};
    ReadOutPV=ScanSetting.SXRSS_Struct.PVGet{ID};
    
    ScanSetting.LcaPutNoWaitList={SetPointPV};
    ScanSetting.PvsWithReadOut={ReadOutPV};
    ScanSetting.MovingPV=strcat(ScanSetting.LcaPutNoWaitList,'.MOVN');
    ScanSetting.DoneMovingPV=strcat(ScanSetting.LcaPutNoWaitList,'.DMOV');
    ScanSetting.KillProcPV=strcat(ScanSetting.LcaPutNoWaitList,':KILL.PROC');
end

function [ScanSetting, ErrorString] = CalculateXLEAP_Delay_andK_ScanPoints(Table, Options)
    PVList={'SIOC:SYS0:ML02:AO314'};
    persistent UL static fh sh
    if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
        ULT_ScriptToLoadAllFunctions
    end
    
    UndulatorRange=str2num(Table{1,1});
    StartKValue=str2double(Table{2,1});
    isKStartScan=str2double(Table{2,2});
    if(~isnan(isKStartScan)), EndKValue=isKStartScan ; isKStartScan = true; else isKStartScan=false; EndKValue=StartKValue; end
    
    LinearCoefficientStart=str2double(Table{3,1});
    isLinearScan=str2double(Table{3,2});
    if(~isnan(isLinearScan)), LinearCoefficientEnd=isLinearScan ; isLinearScan = true; else isLinearScan=false; LinearCoefficientEnd=LinearCoefficientStart ;end
    
    NonLinearPosStart=str2double(Table{4,1});
    isPosScan=str2double(Table{4,2});
    if(~isnan(isPosScan)),NonLinearPosEnd=isPosScan ; isPosScan = true; else isPosScan=false; NonLinearPosEnd=NonLinearPosStart ;end
    
    NonLinearAmplitudeStart=str2double(Table{5,1});
    isAmpScan=str2double(Table{5,2});
    if(~isnan(isAmpScan)),NonLinearAmplitudeEnd=isAmpScan ; isAmpScan = true; else isAmpScan=false; NonLinearAmplitudeEnd=NonLinearAmplitudeStart; end
    
    NonLinearPowerStart=str2double(Table{6,1});
    isPowerScan=str2double(Table{6,2});
    if(~isnan(isPowerScan)),NonLinearPowerEnd=isPowerScan ; isPowerScan = true; else isPowerScan=false; NonLinearPowerEnd = NonLinearPowerStart; end
    
    Continuous=~isempty(Table{7,1});
    STEPS=str2double(Table{8,1});
    SteerFlat=~isempty(Table{9,1});
    Line=Table{10,1};
    
    KSTART=linspace(StartKValue,EndKValue,STEPS);
    LinearCoefficient=linspace(LinearCoefficientStart,LinearCoefficientEnd,STEPS);
    NonLinearPos=linspace(NonLinearPosStart,NonLinearPosEnd,STEPS);
    NonLinearAmp=linspace(NonLinearAmplitudeStart,NonLinearAmplitudeEnd,STEPS);
    NonLinearPower=linspace(NonLinearPowerStart,NonLinearPowerEnd,STEPS);
    
    DelayPV=Table{11,1};
    DelayStart=str2num(Table{12,1});
    DelayEnd=str2num(Table{13,1});
    DelaySteps=str2num(Table{14,1});
    DelayWait=str2num(Table{15,1});
    DelayInnerLoop=str2num(Table{16,1});

    switch upper(Line)
        case 'HXR'
            ULID=1;
        case 'H'
            ULID=1;
        case 'SXR'
            ULID=2;
        case 'S'
            ULID=2;
    end
   
    S=0*(1:length(UL(ULID).slot)).';
    UndulatorRange(UndulatorRange>(length(S)))=[];
    S(UndulatorRange)=1;
    
    for ZZ=1:STEPS
        Parameters(1)=KSTART(ZZ); %Start K
        Parameters(2)=LinearCoefficient(ZZ); %Linear 
        Parameters(3)=NonLinearAmp(ZZ); %Power Term
        Parameters(5)=NonLinearPower(ZZ); %Power Coefficient;
        Parameters(4)=round(NonLinearPos(ZZ)); %Power start location;
        Parameters(6)=Continuous; %1 for Continuous taper;
        K{ZZ} = EvalTaperShaping(UL(ULID), logical(S), Parameters);
    end

    UniqueKnobs=1;
    NumberOfKnobs=length(UniqueKnobs);
    Condition_TOLERANCE=10^-3; Steps=STEPS;
    ConditionsTable=(1:Steps);
    
    Knob{1}.VAR{1}.Data = Table;
    Delta=1:STEPS;
    Knob{1}.VAR{1}.Values = 1:STEPS;
    Knob{1}.Steps=length(Delta);
    
    ScanSetting.UndulatorList=[]; PhysicalVariables={}; PhysicalValues=[];
    figure, hold on
    colors={'r','g','b','k','m','c'}
    for ZZ=1:STEPS
        ins=0;
    for II=1:length(UL(ULID).slot)
        if(UL(ULID).slot(II).USEG.present)
            if(S(II))
                ins=ins+1;
                if(ZZ==1)
                    ScanSetting.UndulatorList(end+1)=II;
                end
                
                PhysicalValues(ZZ,2*(ins-1)+1)=K{ZZ}(II,1);
                PhysicalValues(ZZ,2*(ins-1)+2)=K{ZZ}(II,2);
                
                plot([II,II+1],[K{ZZ}(II,1),K{ZZ}(II,2)],colors{1+mod(ZZ,5)})
                
                if(ZZ==1)
                    PhysicalVariables{end+1}=['K-seg. ',num2str(II),' ini'];
                    PhysicalVariables{end+1}=['K-seg. ',num2str(II),' end'];
                    %KValues(ZZ,2*(ins-1)+1)=K{ZZ}(II,1);
                    %KValues(ZZ,2*(ins-1)+2)=K{ZZ}(II,2);
                end
            else
            end
        else
        end
    end
    PhysicalValues(ZZ,2*ins+1)=KSTART(ZZ);
    PhysicalValues(ZZ,2*ins+2)=LinearCoefficient(ZZ);
    PhysicalValues(ZZ,2*ins+3)=NonLinearAmp(ZZ);
    PhysicalValues(ZZ,2*ins+4)=NonLinearPower(ZZ);
    PhysicalValues(ZZ,2*ins+5)=round(NonLinearPos(ZZ));
        if(ZZ==1)
            
            PhysicalVariables{end+1}='K-START';
            
            PhysicalVariables{end+1}='LinearCoefficient';
            
            PhysicalVariables{end+1}='Non Linear Amplitude';
            
            PhysicalVariables{end+1}='Non Linear Power Coefficient';
            
            PhysicalVariables{end+1}='Non Linear Start Position';
        end
    end
    
    DelayValues=linspace(DelayStart,DelayEnd,DelaySteps);
    
    if(DelayInnerLoop)
        PHYSCOND=[]; PhysicalVariables{end+1}='Chicane Delay [fs]'; PhysicalVariables{end+1}='New K'; PhysicalVariables{end+1}='New Delay';
        for AKs=1:Steps
            BasicPhisicalValues=PhysicalValues(AKs,:);
            for KK=1:DelaySteps
                PHYSCOND(end+1,:)=[BasicPhisicalValues,DelayValues(KK),1,0];
                if(KK==1)
                    PHYSCOND(end,end)=1;
                end
            end  
        end
    else
        BasicPhisicalValues=PhysicalValues;
        PHYSCOND=[]; PhysicalVariables{end+1}='Chicane Delay [fs]'; PhysicalVariables{end+1}='New K'; PhysicalVariables{end+1}='New Delay';
        for AKs=1:DelaySteps
            NewConditions=BasicPhisicalValues;
            NewConditions(:,end+1)=DelayValues(AKs);
            NewConditions(:,end+1)=1; NewConditions(:,end+1)=0; NewConditions(1,end)=1;
            PHYSCOND=[PHYSCOND;NewConditions];
        end
    end
    
    ConditionsTable=1:prod([Steps,DelaySteps]);
    
    Knob{1}.VAR{1}.Data = Table;
    Delta=1:prod([Steps,DelaySteps]);
    Knob{1}.VAR{1}.Values = 1:prod([Steps,DelaySteps]);
    Knob{1}.Steps=length(Delta);
    
    ScanSetting.PVValues=Delta;
    ScanSetting.PauseValue=ones(size(ConditionsTable))/120;
    ScanSetting.ReadOutTable=ConditionsTable;
    ScanSetting.LcaPutNoWaitList=PVList;
    ScanSetting.PvsWithReadOut=PVList;
    ScanSetting.ConditionsTable=ConditionsTable;
    ScanSetting.Knob=Knob;
    ScanSetting.Condition_TOLERANCE=Condition_TOLERANCE;
    ScanSetting.PhysicalVariables=PhysicalVariables;
    ScanSetting.PhysicalValues=PHYSCOND.';
    ScanSetting.Line=Line;
    ScanSetting.SteerFlat=SteerFlat;
    ScanSetting.DelayPause=DelayWait;
    ScanSetting.DelayPV=DelayPV;
    
    ErrorString={};
    ScanSetting.Success=0;
    
    %save Generalized ScanSetting
end

function ScanSetting=Delay_andK_ScanPoints_Set(ScanSetting,Condition, usePvValue)
persistent UL static fh sh XLEAPSteer
PhysicalValues=ScanSetting.PhysicalValues.';
    if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
        ULT_ScriptToLoadAllFunctions
        try
            load('/u1/lcls/matlab/VOM_Configs/XLEAP_ChicaneAndKSteeringProblem.mat','XLEAPSteer');
        end
    end
    
    if(nargin<3)
        usePvValue=0;
    end
    
switch upper(ScanSetting.Line)
    case 'HXR'
        ULID=1;
    case 'H'
        ULID=1;
    case 'SXR'
        ULID=2;
    case 'S'
        ULID=2;
end

if(isstruct(Condition)) %this is restoring an old setting.
    UL(ULID).f.UndulatorLine_K_set(UL(ULID),Condition);
    return
end

if(Condition==round(Condition))
    NewSetPoint=PhysicalValues(Condition,:);
end
SetNewDelay=NewSetPoint(end); SetNewK=NewSetPoint(end-1);

if(SetNewDelay)
    lcaPutSmart(ScanSetting.DelayPV,NewSetPoint(end-2)); tic; disp('Setting a new Delay in chicane.')
end

if(SetNewK)
LineReadout=UL(ULID).f.Read_all_K_values(UL(ULID));
Destination.Cell=[]; Destination.K=[]; Destination.Kend=[];
OldDestination.Cell=[];OldDestination.K=[]; OldDestination.Kend=[];
for II=1:length(LineReadout)
   if(UL(ULID).slot(II).USEG.present)
       if(any(II==ScanSetting.UndulatorList))
           Destination.Cell(end+1) = UL(ULID).slot(II).USEG.Cell_Number;
           OldDestination.Cell(end+1) = UL(ULID).slot(II).USEG.Cell_Number;
           ID=find(II==ScanSetting.UndulatorList);
           KstartPos=2*ID - 1;
           KendPos=2*ID;
           if(Condition==round(Condition))
               Destination.K(end+1) = NewSetPoint(KstartPos);
               Destination.Kend(end+1) = NewSetPoint(KendPos);
           else
               Destination.K(end+1) = interp1(1:length( NewSetPoint(KstartPos) ),NewSetPoint(KstartPos), Condition);
               Destination.Kend(end+1) = interp1(1:length( NewSetPoint(KendPos) ),NewSetPoint(KendPos), Condition);
           end
           OldDestination.K(end+1) = LineReadout(II).K;
           OldDestination.Kend(end+1) = LineReadout(II).Kend;
       else
           if(~isnan(LineReadout(II).K))
               Destination.Cell(end+1) = UL(ULID).slot(II).USEG.Cell_Number;
               Destination.K(end+1) = LineReadout(II).K;
               Destination.Kend(end+1) = LineReadout(II).Kend;
               OldDestination.Cell(end+1) = UL(ULID).slot(II).USEG.Cell_Number;
               OldDestination.K(end+1) = LineReadout(II).K;
               OldDestination.Kend(end+1) = LineReadout(II).Kend;
           else
               
           end
       end
   end
end
ScanSetting.OldDestination=OldDestination;
disp('Calling Und Set Function')
UL(ULID).f.UndulatorLine_K_set(UL(ULID),Destination,0);
disp('Undulators Have been set');
end

if(SetNewDelay)
    b=toc;
    while(b<ScanSetting.DelayPause)
        pause(0.25); disp(['Waiting for chicane delay be passed by ',num2str(b),' < ',num2str(ScanSetting.DelayPause)]);
    end
end

if(isempty(XLEAPSteer))
    try
        load('/u1/lcls/matlab/VOM_Configs/XLEAP_ChicaneAndKSteeringProblem.mat','XLEAPSteer');
    catch
        disp('XLEAP Steer problem failed to load');
    end
end

if(ScanSetting.SteerFlat)
    TimingBPM_CuLinacPV='BPMS:IN20:511:X';
    if(~isempty(XLEAPSteer))
        [~,XLEAPSteer.options.startTime]=lcaGetSmart(TimingBPM_CuLinacPV);
        Solution=handles.sf.steer(XLEAPSteer.s, XLEAPSteer.options, XLEAPSteer.target);
        disp('Steering orbit to Target');
        lcaPutSmart(strcat(Solution.UsedCorr_e,':BCTRL'),Solution.NewCorr);
    end
end

end 

function [ScanSetting, ErrorString] = HXRSS_StandardScanFunction(Table,Options)
    [ScanSetting, ErrorString] = CVCRCI5_StandardScanFunction(Table, Options);
    ScanSetting.PhysicalVariables={'Pitch','Yaw','X Stage','Y Stage'};
    ScanSetting.PhysicalValues=NaN*ones(length(ScanSetting.PhysicalVariables),length(ScanSetting.ConditionsTable));
    ScanSetting.ACK_PV=Table{10,1};
end

function [ScanSetting, ErrorString] = MyCalculateScanPoints(Table, Options)
persistent UL static fh sh
    if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
        ULT_ScriptToLoadAllFunctions
    end
    
    if(nargin<3)
        usePvValue=0;
    end
    
ErrorString={};ScanSetting=[];
PVList={'SIOC:SYS0:ML02:AO314'}; %this is a dummy PV, with the position within the scan.
Line=Table{6,1};
PSNumber=str2num(Table{1,1});
Gapstart=str2num(Table{2,1});
Gapend=str2num(Table{3,1});
Steps=str2num(Table{4,1});
UseInsertN=~isempty(Table{5,1});
UniqueKnobs=1;
NumberOfKnobs=length(UniqueKnobs);
Condition_TOLERANCE=10^-3;

switch upper(Line)
    case 'HXR'
        ULID=1;
    case 'H'
        ULID=1;
    case 'SXR'
        ULID=2;
    case 'S'
        ULID=2;
end

if(UseInsertN)
    CellN=PSNumber;
    PSNumber=find(UL(ULID).slotcell==PSNumber);
else
    CellN=UL(ULID).slotcell(PSNumber);
end

[CellN,PSNumber]

ConditionsTable=(1:Steps);
Knob{1}.VAR{1}.Data = Table;
%KValues=[linspace(Gapstart,18,round((Steps+1)/2)),linspace(18.25,Gapend,round((Steps-1)/2))];
% length(KValues)
% Steps
KValues=linspace(Gapstart,Gapend,Steps);

PSgap = DeltaPhase2PSgap ( Line,ones(size(KValues))*CellN,KValues).';

if(~any(isnan(PSgap)))
   Gaps=PSgap;
   Phases=KValues;
   KValues=PSgap; 
end

KValues

Knob{1}.VAR{1}.Values = KValues;
Knob{1}.Steps=length(KValues);
ScanSetting.PVValues=KValues;
ScanSetting.PauseValue=ones(size(KValues))/120;
ScanSetting.ReadOutTable=KValues;
ScanSetting.LcaPutNoWaitList=PVList;
ScanSetting.PvsWithReadOut=PVList;
ScanSetting.ConditionsTable=ConditionsTable;
ScanSetting.Knob=Knob;
ScanSetting.Condition_TOLERANCE=Condition_TOLERANCE;
ScanSetting.PhysicalVariables={['PS Phase ',Table{1,1}],['PS Gap ',Table{1,1}]};
ScanSetting.PhysicalValues=[Phases;Gaps];
ScanSetting.Line=Line;
ScanSetting.UndulatorList=PSNumber;

end

function ScanSetting=MySetFunction(ScanSetting,Condition, usePvValue)
persistent UL static fh sh
PhysicalValues=ScanSetting.PhysicalValues.';
    if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
        ULT_ScriptToLoadAllFunctions
    end
    
    if(nargin<3)
        usePvValue=0;
    end
    
switch upper(ScanSetting.Line)
    case 'HXR'
        ULID=1;
    case 'H'
        ULID=1;
    case 'SXR'
        ULID=2;
    case 'S'
        ULID=2;
end

% if(isstruct(Condition)) %this is restoring an old setting.
%     UL(ULID).f.UndulatorLine_K_set(UL(ULID),Condition);
%     return
% end
%ScanSetting.UndulatorList=20;
DEVICE=UL(ULID).slot(ScanSetting.UndulatorList).PHAS;

ScanSetting.OldDestination=DEVICE.f.Get_Gap(DEVICE);
disp('Calling Gap Set Function')
TARGET_GAP=ScanSetting.PVValues(Condition);
DEVICE.f.Set_Gap(DEVICE, TARGET_GAP);
THRESHOLD=0.005;

ActualValue=DEVICE.f.Get_Gap(DEVICE);
Distance=abs(ActualValue-TARGET_GAP);
COUNTER=0;
TARGET_GAP
while(Distance>THRESHOLD)
    pause(2);
    ActualValue=DEVICE.f.Get_Gap(DEVICE);
    NewDistance=abs(ActualValue-TARGET_GAP);
    if(NewDistance>=Distance)
        COUNTER=COUNTER+1;
        
        disp('I Believe you are stuck')
        %device seems stopped but not arrived.
        if(COUNTER==3)
            disp('I am confindent you are stuck')
            COUNTER=0;
            DEVICE.f.Set_Gap(DEVICE, TARGET_GAP);
            disp('Device seems stopped but not arrived')
        end
    end
    Distance=NewDistance;
    disp(Distance)
end

disp('Phase Shifters Have been set');
PSphase = getPSphase (ScanSetting.Line, DEVICE.Cell_Number);
lcaPutSmart('SIOC:SYS0:ML02:AO320',PSphase);
pause(0.25);
disp('Extra Wait Done (Quarter of a second)');
ActualValue=DEVICE.f.Get_Gap(DEVICE);
disp(['The Gap when taking data is: ',num2str(ActualValue)]);
end

function ScanSetting=ResetWaitForOk(ScanSetting)
    lcaPutSmart('SIOC:SYS0:ML02:AO325',0); 
end

function ScanSetting=WaitForOK(ScanSetting)
    DATA=lcaGetSmart('SIOC:SYS0:ML02:AO325');
    while(DATA~=1)
        pause(0.1);
        disp('Waiting for SIOC:SYS0:ML02:AO325 be set to 1')
        DATA=lcaGetSmart('SIOC:SYS0:ML02:AO325');
    end
    lcaPutSmart('SIOC:SYS0:ML02:AO325',0); 
end

function Do_Nothing
end

function Scan=RestoreSetting(Scan)

end

function Scan=DontRestoreSetting(Scan)

end

function ScanSetting=Do_Nothing_PassaTutto(ScanSetting)
end

function OUT=No_ParseTable(Table)
    OUT=Table;
end

function ScanSetting=CVCRCI5_StandardSetFunction(ScanSetting,PositionOrValues, usePvValue)
    %PositionOrValues if usePvValues = 1, it is going to consider it as target values
    %if usePvValues = 0, it is going to use it as position within scan
    %table, that's the typical use when running a scan.
    if(nargin<3)
       usePvValue=1; 
    end
    if(usePvValue)
       % Set the PVs and forget
       ScanSetting.OldDestination=lcaGetSmart(ScanSetting.LcaPutNoWaitList);
       Target=PositionOrValues;
       lcaPutSmart(ScanSetting.LcaPutNoWaitList,Target);
       PauseID=1;
    else
       % Set the "Position within the scan"
       ScanSetting.OldDestinations=lcaGetSmart(ScanSetting.LcaPutNoWaitList);
       Target=ScanSetting.PVValues(:,PositionOrValues);
       lcaPutSmart(ScanSetting.LcaPutNoWaitList,Target);
       PauseID=PositionOrValues;
    end
    
    %Manage destination arrival status and pause.
    [int_list, WPut, WReadout]=intersect(ScanSetting.LcaPutNoWaitList,ScanSetting.PvsWithReadOut,'stable');    
    CurrentValues=lcaGetSmart(ScanSetting.PvsWithReadOut(WReadout));
    ColumnTarget=Target(WPut); ColumnTarget=ColumnTarget(:);
    CurrentValues=CurrentValues(:); 
    Distance=abs(CurrentValues-ColumnTarget); Re_Read=0;
    while(any(Distance>ScanSetting.Condition_TOLERANCE(:)))
       pause(0.25);
       CurrentValues=lcaGetSmart(ScanSetting.PvsWithReadOut(WReadout));
       CurrentValues=CurrentValues(:);
       NewDistance=abs(CurrentValues-ColumnTarget);
       Re_Read=Re_Read+1;
       if(any(NewDistance>=Distance) && Re_Read>5) %this seems stuck.
          Re_Read=0;
          lcaPutSmart(ScanSetting.LcaPutNoWaitList,Target); %issue command again
       end
       Distance=NewDistance;
    end
    pause(ScanSetting.PauseValue(PauseID));
    
end

function [ScanSetting, ErrorString] = CVCRCI5_StandardScanFunction(Table, Options)
ErrorString={};
ScanSetting=[];
[SA,SB]=size(Table);
for II=1:SB
   if(isempty(Table{7,II}))
       ErrorString{end+1}=['Variable ',num2str(II),' had empty knob ID'];
       return
   else
   KnobIDs(II)=str2num(Table{8,II});
   end
end
UniqueKnobs=unique(KnobIDs);
UniqueKnobs=sort(UniqueKnobs,'ascend');
NumberOfKnobs=length(UniqueKnobs);
for II=1:numel(UniqueKnobs)
   SameID=find(KnobIDs==UniqueKnobs(II));
   for TT=1:numel(SameID)
        Knob{II}.VAR{TT}.Data=Table(:,SameID(TT));
   end
end

ConditionsTableLength=1;

for II=1:numel(Knob)  
       STEPS = str2double(Knob{II}.VAR{1}.Data{4});
       if(isnan(STEPS))
           ErrorString{end+1}=['Check number of steps, it is not a number'];
           return
       end
       if((STEPS<1) || (floor(STEPS)~=STEPS))
           ErrorString{end+1}=['Check step #, must be integer and positive'];
           return
       end
       Knob{II}.Steps=STEPS; 
       
       ConditionsTableLength=ConditionsTableLength*Knob{II}.Steps;
       for TT=1:numel(Knob{II}.VAR)
           STEPS = str2num(Knob{II}.VAR{TT}.Data{4});
           if(isnan(STEPS))
               ErrorString{end+1}=['Check number of steps, it is not a number'];
               return
           end
           START=str2double(Knob{II}.VAR{TT}.Data{2});
           if(isnan(START))
               ErrorString{end+1}=['Check start points, it is not a number'];
               return
           end
           END=str2double(Knob{II}.VAR{TT}.Data{3});
           if(isnan(END))
               ErrorString{end+1}=['Check end points, it is not a number'];
               return
           end
           Knob{II}.VAR{TT}.Values = linspace(START,END,STEPS);
          if(length(Knob{II}.VAR{TT}.Values) ~= Knob{II}.Steps)
              ErrorString{end+1}=['Check that variables on same knob must have # of steps'];
              return
          end
       end
end

ConditionsTable=zeros(NumberOfKnobs,ConditionsTableLength);

if(Options.Normal)
   CurrentSize=1;
   for II=1:numel(Knob)
       ToBeInserted=sort(repmat((1:Knob{II}.Steps).',[CurrentSize,1]),'ascend');
       CurrentSize=CurrentSize*Knob{II}.Steps;
       ResidualSize=ConditionsTableLength/CurrentSize;
       ConditionsTable(II,:)=repmat(ToBeInserted,[ResidualSize,1]);
   end
elseif(Options.ZigZag)
    CurrentSize=1;
    for II=1:numel(Knob)
       ToBeInserted=sort(repmat((1:Knob{II}.Steps).',[CurrentSize,1]),'ascend');
       CurrentSize=CurrentSize*Knob{II}.Steps;
       ResidualSize=ConditionsTableLength/CurrentSize;
       ConditionsTable(II,:)=repmat(ToBeInserted,[ResidualSize,1]);
    end
    for II=1:numel(Knob)
       LINE=ConditionsTable(II,:);
       Differences=diff(LINE);
       FirstTwo=find(abs(Differences)>1,2,'first');
       while(~isempty(FirstTwo))
           if(length(FirstTwo)==2)
              Segment=LINE((FirstTwo(1)+1):FirstTwo(2));
              Segment=Segment(end:-1:1);
              LINE((FirstTwo(1)+1):FirstTwo(2))=Segment;
              
           end
           if(length(FirstTwo)==1)
              Segment=LINE((FirstTwo(1)+1):end);
              Segment=Segment(end:-1:1);
              LINE((FirstTwo(1)+1):end)=Segment; 
           end
           Differences=diff(LINE);
           FirstTwo=find(abs(Differences)>1,2,'first');
       end
       ConditionsTable(II,:)=LINE;
    end
end

%Calculates actual values.
PVValues=zeros(SB,ConditionsTableLength);
inserted=0;
% a=[1,2,3,4,5,6,5,4,3,2,1]
% b=rand(1,6)
% c=b(a)

for II=1:numel(Knob) 
    for TT=1:numel(Knob{II}.VAR)
        inserted=inserted+1;
        PVValues(inserted,:) = Knob{II}.VAR{TT}.Values(ConditionsTable(II,:));
    end
end

%Apply formulas.
for II=1:SB
    expression=Table{9,II};
    if(isempty(expression))
        continue
    end
    for REG=SB:-1:1
        expression = regexprep(expression, ['#',num2str(REG)],['PVValues(',num2str(REG),',:)']);
    end
    PVValues(II,:) = PVValues(II,:) + eval(expression);
end

%Calculate pause for each line and save PV checklist and tolerances.

LcaPutNoWaitList={};
PvsWithReadOut={};
ConditionCheckoutListLocation=[];
PauseVector=[];
Condition_TOLERANCE=[];
for II=1:SB
    LcaPutNoWaitList{end+1} = Table{1,II};
    PAUSE=str2double(Table{8,II});
    if(~isempty(Table{8,II}))
        if(isnan(PAUSE))
            ErrorString{end+1}=['One non-empty pause value is not a number'];
            return
        end
        PauseVector(end+1)=str2num(Table{7,II});
    else
        PauseVector(end+1)=0;
    end
    if(~isempty(Table{5,II}))
        ConditionCheckoutListLocation(end+1)=II;
        PvsWithReadOut{end+1} = Table{5,II};
        TOLERANCE=str2double(Table{6,II});
        if(isnan(TOLERANCE))
            ErrorString{end+1}=['One tolerance is not a number, for readout PV present'];
            return
        else
           Condition_TOLERANCE(end+1)=TOLERANCE; 
        end
    end
end

PauseValue=zeros(ConditionsTableLength,1);

for II=1:ConditionsTableLength
    if(II==1)
        PauseValue(II)=max(PauseVector);
    else
        PauseValue(II)=max(PauseVector.'.*(PVValues(:,II) ~= PVValues(:,II-1)));
    end
end

ReadOutTable=PVValues(ConditionCheckoutListLocation,:);

ScanSetting.PVValues=PVValues;
ScanSetting.PauseValue=PauseValue.';
ScanSetting.ReadOutTable=ReadOutTable;
ScanSetting.LcaPutNoWaitList=LcaPutNoWaitList;
ScanSetting.PvsWithReadOut=PvsWithReadOut;
ScanSetting.ConditionsTable=ConditionsTable;
ScanSetting.Knob=Knob;
ScanSetting.Condition_TOLERANCE=Condition_TOLERANCE;
ScanSetting.PhysicalVariables={};
ScanSetting.PhysicalValues=[];
ScanSetting.RestoreValues=lcaGetSmart(ScanSetting.LcaPutNoWaitList);

end

function ScanSetting=PSGapSet(ScanSetting,Condition, usePvValue)
persistent UL static fh sh
PhysicalValues=ScanSetting.PhysicalValues.';
    if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
        ULT_ScriptToLoadAllFunctions
    end
    
    if(nargin<3)
        usePvValue=0;
    end
    
switch upper(ScanSetting.Line)
    case 'HXR'
        ULID=1;
    case 'H'
        ULID=1;
    case 'SXR'
        ULID=2;
    case 'S'
        ULID=2;
end

% if(isstruct(Condition)) %this is restoring an old setting.
%     UL(ULID).f.UndulatorLine_K_set(UL(ULID),Condition);
%     return
% end
%ScanSetting.UndulatorList=20;
DEVICE=UL(ULID).slot(ScanSetting.UndulatorList).PHAS;

ScanSetting.OldDestination=DEVICE.f.Get_Gap(DEVICE);
disp('Calling Gap Set Function')
TARGET_GAP=ScanSetting.PVValues(Condition);
DEVICE.f.Set_Gap(DEVICE, TARGET_GAP);
THRESHOLD=0.005;

ActualValue=DEVICE.f.Get_Gap(DEVICE);
Distance=abs(ActualValue-TARGET_GAP);
COUNTER=0;
TARGET_GAP
while(Distance>THRESHOLD)
    pause(2);
    ActualValue=DEVICE.f.Get_Gap(DEVICE);
    NewDistance=abs(ActualValue-TARGET_GAP);
    if(NewDistance>=Distance)
        COUNTER=COUNTER+1;
        
        disp('I Believe you are stuck')
        %device seems stopped but not arrived.
        if(COUNTER==3)
            disp('I am confindent you are stuck')
            COUNTER=0;
            DEVICE.f.Set_Gap(DEVICE, TARGET_GAP);
            disp('Device seems stopped but not arrived')
        end
    end
    Distance=NewDistance;
    disp(Distance)
end

disp('Phase Shifters Have been set');
PSphase = getPSphase (ScanSetting.Line, DEVICE.Cell_Number);
lcaPutSmart('SIOC:SYS0:ML02:AO320',PSphase);
pause(0.25);
disp('Extra Wait Done (Quarter of a second)');
ActualValue=DEVICE.f.Get_Gap(DEVICE);
disp(['The Gap when taking data is: ',num2str(ActualValue)]);
end

function ScanSetting=PSGapSetRange(ScanSetting,Condition, usePvValue)
persistent UL static fh sh
PhysicalValues=ScanSetting.PhysicalValues.';
if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
    ULT_ScriptToLoadAllFunctions
end

lcaPutSmart(ScanSetting.PSPV,ScanSetting.PhysicalValues(Condition));

if(nargin<3)
    usePvValue=0;
end

switch upper(ScanSetting.Line)
    case 'HXR'
        ULID=1;
    case 'H'
        ULID=1;
    case 'SXR'
        ULID=2;
    case 'S'
        ULID=2;
end

Destination.K=[]; Destination.Kend=[]; Destination.Cell=[];
for II=1:length(ScanSetting.LineReadout)
    if(UL(ULID).slot(II).USEG.present)
        Destination.Cell(1) = UL(ULID).slot(II).USEG.Cell_Number;
        Destination.K(1) = ScanSetting.LineReadout(II).K;
        Destination.Kend(1) = ScanSetting.LineReadout(II).Kend;
        break
    end
end

UL(ULID).f.UndulatorLine_K_set(UL(ULID),Destination,0);
        
        
end

function ScanSetting=UndulatorKSet(ScanSetting,Condition, usePvValue)
persistent UL static fh sh
PhysicalValues=ScanSetting.PhysicalValues.';
    if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
        ULT_ScriptToLoadAllFunctions
    end
    
    if(nargin<3)
        usePvValue=0;
    end
    
switch upper(ScanSetting.Line)
    case 'HXR'
        ULID=1;
    case 'H'
        ULID=1;
    case 'SXR'
        ULID=2;
    case 'S'
        ULID=2;
end

if(isstruct(Condition)) %this is restoring an old setting.
    UL(ULID).f.UndulatorLine_K_set(UL(ULID),Condition);
    return
end

LineReadout=UL(ULID).f.Read_all_K_values(UL(ULID));
Destination.Cell=[]; Destination.K=[]; Destination.Kend=[];
OldDestination.Cell=[];OldDestination.K=[]; OldDestination.Kend=[];
for II=1:length(LineReadout)
   if(UL(ULID).slot(II).USEG.present)
       if(any(II==ScanSetting.UndulatorList))
           Destination.Cell(end+1) = UL(ULID).slot(II).USEG.Cell_Number;
           OldDestination.Cell(end+1) = UL(ULID).slot(II).USEG.Cell_Number;
           ID=find(II==ScanSetting.UndulatorList);
           KstartPos=2*ID - 1;
           KendPos=2*ID;
           if(Condition==round(Condition))
               Destination.K(end+1) = PhysicalValues(Condition, KstartPos);
               Destination.Kend(end+1) = PhysicalValues(Condition, KendPos);
           else
               Destination.K(end+1) = interp1(1:length( PhysicalValues(:, KstartPos) ),PhysicalValues(:, KstartPos), Condition);
               Destination.Kend(end+1) = interp1(1:length( PhysicalValues(:, KendPos) ),PhysicalValues(:, KendPos), Condition);
           end
           OldDestination.K(end+1) = LineReadout(II).K;
           OldDestination.Kend(end+1) = LineReadout(II).Kend;
       else
           if(~isnan(LineReadout(II).K))
               Destination.Cell(end+1) = UL(ULID).slot(II).USEG.Cell_Number;
               Destination.K(end+1) = LineReadout(II).K;
               Destination.Kend(end+1) = LineReadout(II).Kend;
               OldDestination.Cell(end+1) = UL(ULID).slot(II).USEG.Cell_Number;
               OldDestination.K(end+1) = LineReadout(II).K;
               OldDestination.Kend(end+1) = LineReadout(II).Kend;
           else
               
           end
       end
   end
end
ScanSetting.OldDestination=OldDestination;
disp('Calling Und Set Function')
UL(ULID).f.UndulatorLine_K_set(UL(ULID),Destination,0);
disp('Undulators Have been set');
pause(0.25);
disp('Extra Wait Done (Quarter of a second)');

end


function [ScanSetting, ErrorString] = CalculateKScanPoints(Table, Options)

ErrorString={};
ScanSetting=[];

PVList={'SIOC:SYS0:ML02:AO314'}; %this is a dummy PV, with the position within the scan.

Line=Table{6,1};
UndulatorNumber=str2num(Table{1,1});
Kstart=str2num(Table{2,1});
Kend=str2num(Table{3,1});
Steps=str2num(Table{4,1});
Taper=str2num(Table{5,1});

UniqueKnobs=1;
NumberOfKnobs=length(UniqueKnobs);
Condition_TOLERANCE=10^-3;

ConditionsTable=(1:Steps);
Knob{1}.VAR{1}.Data = Table;
KValues=linspace(Kstart,Kend,Steps);
Knob{1}.VAR{1}.Values = KValues;
Knob{1}.Steps=length(KValues);

ScanSetting.PVValues=KValues;
ScanSetting.PauseValue=ones(size(KValues))/120;
ScanSetting.ReadOutTable=KValues;
ScanSetting.LcaPutNoWaitList=PVList;
ScanSetting.PvsWithReadOut=PVList;
ScanSetting.ConditionsTable=ConditionsTable;
ScanSetting.Knob=Knob;
ScanSetting.Condition_TOLERANCE=Condition_TOLERANCE;
ScanSetting.PhysicalVariables={['K-seg. ',Table{1,1},' ini'],['K-seg. ',Table{1,1},' end']};
ScanSetting.PhysicalValues=[KValues,KValues+Taper];
ScanSetting.Line=Line;
ScanSetting.UndulatorList=UndulatorNumber;

end

function [ScanSetting, ErrorString] = CalculatePSScanPointsDEG_Range(Table, Options)
    persistent UL static fh sh
    if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
        ULT_ScriptToLoadAllFunctions
    end
    
    Line=Table{6,1};
    SteerFlat=~isempty(Table{7,1});
    Start=str2num(Table{2,1});
    PSRange=str2num(Table{1,1});
    End=str2num(Table{3,1});
    Steps=str2num(Table{4,1});
    ErrorString={};ScanSetting=[];
    PVList={'SIOC:SYS0:ML02:AO314'}; %this is a dummy PV, with the position within the scan.
    %'Phase Shifter Range','Start Phase [deg]','End Phase [deg]','# of Steps','Use Girder #','Line','Steer Flat'
    
    switch upper(Line)
        case 'HXR'
            ULID=1;
        case 'H'
            ULID=1;
        case 'SXR'
            ULID=2;
        case 'S'
            ULID=2;
    end

    LineReadout=UL(ULID).f.Read_all_K_values(UL(ULID));
    UniqueKnobs=1;
NumberOfKnobs=length(UniqueKnobs);
Condition_TOLERANCE=10^-3;
ScanSetting.PSList=[]; ScanSetting.PSPV={};
for II=1:length(UL(ULID).slot)
    if(UL(ULID).slot(II).PHAS.present)
        if(any(II==PSRange))
            ScanSetting.PSList(end+1)=II;
            ScanSetting.PSPV{end+1}=UL(ULID).slot(II).PHAS.pv.PDes;
        else
           
        end
    else
        
    end
end



ConditionsTable=(1:Steps);
Knob{1}.VAR{1}.Data = Table;
%KValues=[linspace(Gapstart,18,round((Steps+1)/2)),linspace(18.25,Gapend,round((Steps-1)/2))];
% length(KValues)
% Steps
KValues=linspace(Start,End,Steps);

PhysicalValues=KValues;
   
Knob{1}.VAR{1}.Values = KValues;
Knob{1}.Steps=length(KValues);
ScanSetting.PVValues=KValues;
ScanSetting.PauseValue=ones(size(KValues))/120;
ScanSetting.ReadOutTable=KValues;
ScanSetting.LcaPutNoWaitList=PVList;
ScanSetting.PvsWithReadOut=PVList;
ScanSetting.ConditionsTable=ConditionsTable;
ScanSetting.Knob=Knob;
ScanSetting.Condition_TOLERANCE=Condition_TOLERANCE;
ScanSetting.PhysicalVariables={'PS Phase'};
ScanSetting.PhysicalValues=PhysicalValues;
ScanSetting.Line=Line;
ScanSetting.LineReadout=LineReadout;
ScanSetting.SteerFlat=SteerFlat;

    
end


function [ScanSetting, ErrorString] = CalculatePSScanPointsDEG(Table, Options)
persistent UL static fh sh
    if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
        ULT_ScriptToLoadAllFunctions
    end
    
    if(nargin<3)
        usePvValue=0;
    end
    
ErrorString={};ScanSetting=[];
PVList={'SIOC:SYS0:ML02:AO314'}; %this is a dummy PV, with the position within the scan.
Line=Table{6,1};
PSNumber=str2num(Table{1,1});
Gapstart=str2num(Table{2,1});
Gapend=str2num(Table{3,1});
Steps=str2num(Table{4,1});
UseInsertN=~isempty(Table{5,1});
UniqueKnobs=1;
NumberOfKnobs=length(UniqueKnobs);
Condition_TOLERANCE=10^-3;

switch upper(Line)
    case 'HXR'
        ULID=1;
    case 'H'
        ULID=1;
    case 'SXR'
        ULID=2;
    case 'S'
        ULID=2;
end

if(UseInsertN)
    CellN=PSNumber;
    PSNumber=find(UL(ULID).slotcell==PSNumber);
else
    CellN=UL(ULID).slotcell(PSNumber);
end

[CellN,PSNumber]

ConditionsTable=(1:Steps);
Knob{1}.VAR{1}.Data = Table;
%KValues=[linspace(Gapstart,18,round((Steps+1)/2)),linspace(18.25,Gapend,round((Steps-1)/2))];
% length(KValues)
% Steps
KValues=linspace(Gapstart,Gapend,Steps);

PSgap = DeltaPhase2PSgap ( Line,ones(size(KValues))*CellN,KValues).';

if(~any(isnan(PSgap)))
   Gaps=PSgap;
   Phases=KValues;
   KValues=PSgap; 
end

KValues

Knob{1}.VAR{1}.Values = KValues;
Knob{1}.Steps=length(KValues);
ScanSetting.PVValues=KValues;
ScanSetting.PauseValue=ones(size(KValues))/120;
ScanSetting.ReadOutTable=KValues;
ScanSetting.LcaPutNoWaitList=PVList;
ScanSetting.PvsWithReadOut=PVList;
ScanSetting.ConditionsTable=ConditionsTable;
ScanSetting.Knob=Knob;
ScanSetting.Condition_TOLERANCE=Condition_TOLERANCE;
ScanSetting.PhysicalVariables={['PS Phase ',Table{1,1}],['PS Gap ',Table{1,1}]};
ScanSetting.PhysicalValues=[Phases;Gaps];
ScanSetting.Line=Line;
ScanSetting.UndulatorList=PSNumber;

end


function [ScanSetting, ErrorString] = CalculatePSScanPoints(Table, Options)
persistent UL static fh sh
    if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
        ULT_ScriptToLoadAllFunctions
    end
    
    if(nargin<3)
        usePvValue=0;
    end
    
ErrorString={};ScanSetting=[];
PVList={'SIOC:SYS0:ML02:AO314'}; %this is a dummy PV, with the position within the scan.
Line=Table{6,1};
PSNumber=str2num(Table{1,1});
Gapstart=str2num(Table{2,1});
Gapend=str2num(Table{3,1});
Steps=str2num(Table{4,1});
UseInsertN=~isempty(Table{5,1});
UniqueKnobs=1;
NumberOfKnobs=length(UniqueKnobs);
Condition_TOLERANCE=10^-3;

switch upper(Line)
    case 'HXR'
        ULID=1;
    case 'H'
        ULID=1;
    case 'SXR'
        ULID=2;
    case 'S'
        ULID=2;
end
if(UseInsertN)
    PSNumber=find(UL(ULID).slotcell==PSNumber);
end

PSNumber

ConditionsTable=(1:Steps);
Knob{1}.VAR{1}.Data = Table;
KValues=[linspace(Gapstart,18,round((Steps+1)/2)),linspace(18.25,Gapend,round((Steps-1)/2))];
length(KValues)
Steps
KValues=linspace(Gapstart,18,Steps);

Knob{1}.VAR{1}.Values = KValues;
Knob{1}.Steps=length(KValues);
ScanSetting.PVValues=KValues;
ScanSetting.PauseValue=ones(size(KValues))/120;
ScanSetting.ReadOutTable=KValues;
ScanSetting.LcaPutNoWaitList=PVList;
ScanSetting.PvsWithReadOut=PVList;
ScanSetting.ConditionsTable=ConditionsTable;
ScanSetting.Knob=Knob;
ScanSetting.Condition_TOLERANCE=Condition_TOLERANCE;
ScanSetting.PhysicalVariables={['PS Gap ',Table{1,1}]};
ScanSetting.PhysicalValues=[KValues];
ScanSetting.Line=Line;
ScanSetting.UndulatorList=PSNumber;

end

function [ScanSetting, ErrorString] = CalculateKParallelScanPoints(Table, Options)
    persistent UL static fh sh
    if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
        ULT_ScriptToLoadAllFunctions
    end
    
    Line=Table{9,1};
    
    switch upper(Line)
        case 'HXR'
            ULID=1;
        case 'H'
            ULID=1;
        case 'SXR'
            ULID=2;
        case 'S'
            ULID=2;
    end
    
   PhyConsts.c=299792458;
   PhyConsts.mc2_e=5.109989180000000e+05;
   PhyConsts.echarge=1.602176530000000e-19;
   PhyConsts.mu_0=1.256637061435917e-06;
   PhyConsts.eps_0=8.854187817620391e-12;
   PhyConsts.r_e=2.817940318198647e-15;
   PhyConsts.Z_0=3.767303134617707e+02;
   PhyConsts.h_bar=1.054571682364455e-34; %J s
   PhyConsts.alpha=0.007297352554051;
   PhyConsts.Avogadro=6.022141500000000e+23;
   PhyConsts.k_Boltzmann=1.380650500000000e-23;
   PhyConsts.Stefan_Boltzmann=5.670401243654186e-08;
   PhyConsts.hplanck=4.135667516*10^-15;
    
    
    DeltaK=~isempty(Table{8,1});
    DeltaE=~isempty(Table{7,1});
    Steps=str2num(Table{6,1});
    RelativeEnd=str2num(Table{5,1});
    RelativeStart=str2num(Table{4,1});
    ReferenceEnergy=str2num(Table{3,1});
    ReferenceK=str2num(Table{2,1});
    UndulatorRange=str2num(Table{1,1});
    
    SteerFlat=~isempty(Table{10,2});
    
    ErrorString={};
    ScanSetting.Success=0;
  
    if(~(DeltaK) && ~(DeltaE))
        ErrorString{1}='Neither Energy nor K shift selected';
    end
    if(DeltaK)
        UseK=1;
    elseif(DeltaE)
        UseK=0;
        if(isnan(ReferenceEnergy))
            ErrorString{end+1}='Need Reference Energy for Energy movement';
        end
%         if(isnan(ReferenceK))
%             ErrorString{end+1}='Need Reference K for Energy movement';
%         end
    end

    UniqueKnobs=1;
    NumberOfKnobs=length(UniqueKnobs);
    Condition_TOLERANCE=10^-3;
    ConditionsTable=(1:Steps);
    
    Knob{1}.VAR{1}.Data = Table;
    Delta=linspace(RelativeStart,RelativeEnd,Steps);
    Knob{1}.VAR{1}.Values = Delta;
    Knob{1}.Steps=length(Delta);
    
    ScanSetting.UndulatorList=[]; PhysicalVariables={}; PhysicalValues=[];
    
    if(UseK)
        for II=1:length(UL(ULID).slot)
            if(UL(ULID).slot(II).USEG.present)
                if(any(II==UndulatorRange))
                    ScanSetting.UndulatorList(end+1)=II;
                    PhysicalValues(:,2*length(ScanSetting.UndulatorList)-1)=str2double(Table{9+II,1}) + Delta.';
                    PhysicalValues(:,2*length(ScanSetting.UndulatorList))=str2double(Table{9+II,2}) + Delta.';
                    PhysicalVariables{end+1}=['K-seg. ',num2str(II),' ini'];
                    PhysicalVariables{end+1}=['K-seg. ',num2str(II),' end'];
                else
                    Table{9+II,1}=NaN;
                    Table{9+II,2}=NaN;
                end
            else
                Table{9+II,1}=NaN;
                Table{9+II,2}=NaN;
            end
        end
    else
        for II=1:length(UL(ULID).slot)
            if(UL(ULID).slot(II).USEG.present)
                if(any(II==UndulatorRange))
                    e_ene_number=ReferenceEnergy*1000;
                    K_number=str2double(Table{9+II,1});
                    DELTAe_Ph_number=Delta;
                    ScanSetting.UndulatorList(end+1)=II;
                    ReciprocoUnoPiuKappaNuovoQuadratoMezziNuovoMenoVecchio = DELTAe_Ph_number/(PhyConsts.hplanck * PhyConsts.c / (UL(ULID).Basic.Reference_lambda_u/1000/(2*(e_ene_number/(PhyConsts.mc2_e/10^6))^2)));
                    Knuovo = sqrt(2*(1./(ReciprocoUnoPiuKappaNuovoQuadratoMezziNuovoMenoVecchio + 1/(1+K_number^2/2)) -1));
                    PhysicalValues(:,2*length(ScanSetting.UndulatorList)-1)=Knuovo;
                    
                    K_number=str2double(Table{9+II,2});
                    ReciprocoUnoPiuKappaNuovoQuadratoMezziNuovoMenoVecchio = DELTAe_Ph_number/(PhyConsts.hplanck * PhyConsts.c / (UL(ULID).Basic.Reference_lambda_u/1000/(2*(e_ene_number/(PhyConsts.mc2_e/10^6))^2)));
                    Knuovo = sqrt(2*(1./(ReciprocoUnoPiuKappaNuovoQuadratoMezziNuovoMenoVecchio + 1/(1+K_number^2/2)) -1));
                    PhysicalValues(:,2*length(ScanSetting.UndulatorList))=Knuovo;
%                     if(~isnan(e_ene_number) && ~isnan(K_number) && ~isnan(DELTAe_Ph_number))
%                         ReciprocoUnoPiuKappaNuovoQuadratoMezziNuovoMenoVecchio = DELTAe_Ph_number/(handles.PhyConsts.hplanck * handles.PhyConsts.c / (handles.UL(ULID).Basic.Reference_lambda_u/1000/(2*(e_ene_number/(handles.PhyConsts.mc2_e/10^6))^2)));
%                         Knuovo = sqrt(2*(1/(ReciprocoUnoPiuKappaNuovoQuadratoMezziNuovoMenoVecchio + 1/(1+K_number^2/2)) -1));
%                         set(handles.Risposta,'string',num2str(Knuovo))
%                     end
                    
                    
                    
%                     UndulatorPeriod=UL(ULID).slot(II).USEG.Period; %mm
%                     %ReferenceEnergy is in GeV
%                     PhysicalValues(:,2*length(ScanSetting.UndulatorList)-1)=sqrt(str2double(Table{9+II,1})^2 + 4*(1000*ReferenceEnergy/0.511)^2*Delta/UndulatorPeriod);
%                     PhysicalValues(:,2*length(ScanSetting.UndulatorList))=sqrt(str2double(Table{9+II,2})^2 + 4*(1000*ReferenceEnergy/0.511)^2*Delta/UndulatorPeriod);
                    PhysicalVariables{end+1}=['K-seg. ',num2str(II),' ini'];
                    PhysicalVariables{end+1}=['K-seg. ',num2str(II),' end'];
                else
                    Table{9+II,1}=NaN;
                    Table{9+II,2}=NaN;
                end
            else
                Table{9+II,1}=NaN;
                Table{9+II,2}=NaN;
            end
        end
        PhysicalVariables{end+1}='Delta Energy [eV]';
        PhysicalValues(:,end+1)=DELTAe_Ph_number;
    end

    PVList={'SIOC:SYS0:ML02:AO314'};
    
    ScanSetting.PVValues=Delta;
    ScanSetting.PauseValue=ones(size(Delta))/120;
    ScanSetting.ReadOutTable=Delta;
    ScanSetting.LcaPutNoWaitList=PVList;
    ScanSetting.PvsWithReadOut=PVList;
    ScanSetting.ConditionsTable=ConditionsTable;
    ScanSetting.Knob=Knob;
    ScanSetting.Condition_TOLERANCE=Condition_TOLERANCE;
    ScanSetting.PhysicalVariables=PhysicalVariables;
    ScanSetting.PhysicalValues=PhysicalValues.';
    ScanSetting.SteerFlat=SteerFlat;
    ScanSetting.Line=Line;
    save KParallel ScanSetting
end

function Table=Parse_TableKParallelScanPoints(Table)
    persistent UL static fh sh
    if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
        ULT_ScriptToLoadAllFunctions
    end
    
    Line=Table{9,1};
    
    switch upper(Line)
        case 'HXR'
            ULID=1;
        case 'H'
            ULID=1;
        case 'SXR'
            ULID=2;
        case 'S'
            ULID=2;
    end
    
    ReferenceEnergy=str2double(Table{3,1});
    ReferenceK=str2double(Table{2,1});
    
    if(isnan(ReferenceEnergy) || isempty(ReferenceEnergy))
        Energy=lcaGetSmart(UL(ULID).Basic.EBeamEnergyPV);
        Table{3,1}=num2str(Energy);
    end
    
    if(~isnan(ReferenceK) || ~isempty(ReferenceK))
        LineReadout=UL(ULID).f.Read_all_K_values(UL(ULID));
        UndulatorRange=str2num(Table{1,1});
        for II=1:length(UL(ULID).slot)
           if(UL(ULID).slot(II).USEG.present)
              if(any(II==UndulatorRange)) 
                  ReferenceK=LineReadout(II).K;
                  break
              end
           end
        end
        Table{2,1}=num2str(ReferenceK);
    end
    
    for II=1:length(UL(ULID).slot)
        if(UL(ULID).slot(II).USEG.present)
            if(any(II==UndulatorRange))
                Table{9+II,1}=num2str(LineReadout(II).K);
                Table{9+II,2}=num2str(LineReadout(II).Kend);
            else
                Table{9+II,1}='NaN';
                Table{9+II,2}='NaN';
            end
        else
            Table{9+II,1}='NaN';
            Table{9+II,2}='NaN';
        end
    end
    
end

function Table=Parse_TableGeneralizedKScanPoints(Table)  
    persistent UL static fh sh
    if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
        ULT_ScriptToLoadAllFunctions
    end
    Line=Table{9,1};
    switch upper(Line)
        case 'HXR'
            ULID=1;
        case 'H'
            ULID=1;
        case 'SXR'
            ULID=2;
        case 'S'
            ULID=2;
    end

end

function [ScanSetting, ErrorString] = CalculateGeneralizedScanPoints(Table, Options)
    PVList={'SIOC:SYS0:ML02:AO314'};
    persistent UL static fh sh
    if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
        ULT_ScriptToLoadAllFunctions
    end
    
    UndulatorRange=str2num(Table{1,1});
    StartKValue=str2double(Table{2,1});
    isKStartScan=str2double(Table{2,2});
    if(~isnan(isKStartScan)), EndKValue=isKStartScan ; isKStartScan = true; else isKStartScan=false; EndKValue=StartKValue; end
    
    LinearCoefficientStart=str2double(Table{3,1});
    isLinearScan=str2double(Table{3,2});
    if(~isnan(isLinearScan)), LinearCoefficientEnd=isLinearScan ; isLinearScan = true; else isLinearScan=false; LinearCoefficientEnd=LinearCoefficientStart ;end
    
    NonLinearPosStart=str2double(Table{4,1});
    isPosScan=str2double(Table{4,2});
    if(~isnan(isPosScan)),NonLinearPosEnd=isPosScan ; isPosScan = true; else isPosScan=false; NonLinearPosEnd=NonLinearPosStart ;end
    
    NonLinearAmplitudeStart=str2double(Table{5,1});
    isAmpScan=str2double(Table{5,2});
    if(~isnan(isAmpScan)),NonLinearAmplitudeEnd=isAmpScan ; isAmpScan = true; else isAmpScan=false; NonLinearAmplitudeEnd=NonLinearAmplitudeStart; end
    
    NonLinearPowerStart=str2double(Table{6,1});
    isPowerScan=str2double(Table{6,2});
    if(~isnan(isPowerScan)),NonLinearPowerEnd=isPowerScan ; isPowerScan = true; else isPowerScan=false; NonLinearPowerEnd = NonLinearPowerStart; end
    
    Continuous=~isempty(Table{7,1});
    STEPS=str2double(Table{8,1});
    SteerFlat=~isempty(Table{9,1});
    Line=Table{10,1};
    
    KSTART=linspace(StartKValue,EndKValue,STEPS);
    LinearCoefficient=linspace(LinearCoefficientStart,LinearCoefficientEnd,STEPS);
    NonLinearPos=linspace(NonLinearPosStart,NonLinearPosEnd,STEPS);
    NonLinearAmp=linspace(NonLinearAmplitudeStart,NonLinearAmplitudeEnd,STEPS);
    NonLinearPower=linspace(NonLinearPowerStart,NonLinearPowerEnd,STEPS);
    
    switch upper(Line)
        case 'HXR'
            ULID=1;
        case 'H'
            ULID=1;
        case 'SXR'
            ULID=2;
        case 'S'
            ULID=2;
    end
   
    S=0*(1:length(UL(ULID).slot)).';
    UndulatorRange(UndulatorRange>(length(S)))=[];
    S(UndulatorRange)=1;
    
    for ZZ=1:STEPS
        Parameters(1)=KSTART(ZZ); %Start K
        Parameters(2)=LinearCoefficient(ZZ); %Linear 
        Parameters(3)=NonLinearAmp(ZZ); %Power Term
        Parameters(5)=NonLinearPower(ZZ); %Power Coefficient;
        Parameters(4)=round(NonLinearPos(ZZ)); %Power start location;
        Parameters(6)=Continuous; %1 for Continuous taper;
        K{ZZ} = EvalTaperShaping(UL(ULID), logical(S), Parameters);
    end

    UniqueKnobs=1;
    NumberOfKnobs=length(UniqueKnobs);
    Condition_TOLERANCE=10^-3; Steps=STEPS;
    ConditionsTable=(1:Steps);
    
    Knob{1}.VAR{1}.Data = Table;
    Delta=1:STEPS;
    Knob{1}.VAR{1}.Values = 1:STEPS;
    Knob{1}.Steps=length(Delta);
    
    ScanSetting.UndulatorList=[]; PhysicalVariables={}; PhysicalValues=[];
    figure, hold on
    colors={'r','g','b','k','m','c'}
    for ZZ=1:STEPS
        ins=0;
    for II=1:length(UL(ULID).slot)
        if(UL(ULID).slot(II).USEG.present)
            if(S(II))
                ins=ins+1;
                if(ZZ==1)
                    ScanSetting.UndulatorList(end+1)=II;
                end
                
                PhysicalValues(ZZ,2*(ins-1)+1)=K{ZZ}(II,1);
                PhysicalValues(ZZ,2*(ins-1)+2)=K{ZZ}(II,2);
                
                plot([II,II+1],[K{ZZ}(II,1),K{ZZ}(II,2)],colors{1+mod(ZZ,5)})
                
                if(ZZ==1)
                    PhysicalVariables{end+1}=['K-seg. ',num2str(II),' ini'];
                    PhysicalVariables{end+1}=['K-seg. ',num2str(II),' end'];
                    %KValues(ZZ,2*(ins-1)+1)=K{ZZ}(II,1);
                    %KValues(ZZ,2*(ins-1)+2)=K{ZZ}(II,2);
                end
            else
            end
        else
        end
    end
    PhysicalValues(ZZ,2*ins+1)=KSTART(ZZ);
    PhysicalValues(ZZ,2*ins+2)=LinearCoefficient(ZZ);
    PhysicalValues(ZZ,2*ins+3)=NonLinearAmp(ZZ);
    PhysicalValues(ZZ,2*ins+4)=NonLinearPower(ZZ);
    PhysicalValues(ZZ,2*ins+5)=round(NonLinearPos(ZZ));
        if(ZZ==1)
            
            PhysicalVariables{end+1}='K-START';
            
            PhysicalVariables{end+1}='LinearCoefficient';
            
            PhysicalVariables{end+1}='Non Linear Amplitude';
            
            PhysicalVariables{end+1}='Non Linear Power Coefficient';
            
            PhysicalVariables{end+1}='Non Linear Start Position';
        end
    end
    
    ScanSetting.PVValues=Delta;
    ScanSetting.PauseValue=ones(size(ConditionsTable))/120;
    ScanSetting.ReadOutTable=ConditionsTable;
    ScanSetting.LcaPutNoWaitList=PVList;
    ScanSetting.PvsWithReadOut=PVList;
    ScanSetting.ConditionsTable=ConditionsTable;
    ScanSetting.Knob=Knob;
    ScanSetting.Condition_TOLERANCE=Condition_TOLERANCE;
    ScanSetting.PhysicalVariables=PhysicalVariables;
    ScanSetting.PhysicalValues=PhysicalValues.';
    ScanSetting.Line=Line;
    ScanSetting.SteerFlat=SteerFlat;
    
    
    ErrorString={};
    ScanSetting.Success=0;
    
    save Generalized ScanSetting
end

function ScanSetting=UndulatorLineSteerFlat(ScanSetting)
    persistent UL static fh sh
    if(isempty(UL) || isempty(static) || isempty(fh) || isempty(sh))
        ULT_ScriptToLoadAllFunctions
    end
    if(~isfield(ScanSetting,'SteerFlat'))
        return
    end
    if(~ScanSetting.SteerFlat)
        return
    end
    
    switch upper(ScanSetting.Line)
        case 'HXR'
            ULID=1;
        case 'H'
            ULID=1;
        case 'SXR'
            ULID=2;
        case 'S'
            ULID=2;
    end
    
    disp('Steering to 0')
    options.BSA_HB=1; options.AcquisitionTime=1;
    [~,options.startTime]=lcaGetSmart(strcat(static(ULID).bpmList_e{1},':X'));
    options.fitSVDRatio=0.005;
    Solution=sh.steer(static(ULID),options);
    if(Solution.FAILED)
        disp('Steering Failed: solution not applied');
    else
        disp('Steering Solution applied');
        lcaPutSmart(strcat(Solution.UsedCorr_e,':BCTRL'),Solution.NewCorr);
        pause(0.5);
    end
end

function K = EvalTaperShaping(UL, S, Parameters)
C(1)=Parameters(1); %Start K
C(2)=Parameters(2); %Linear 
C(3)=Parameters(3); %Power Term
D(1)=Parameters(5); %Power Coefficient;
E(1)=Parameters(4); %Power start location;
CT(1)=Parameters(6); %1 for Continuous taper;

K=NaN*zeros(UL.slotlength,2);

II=0; SETTING=0; Linears=0; Powers=0; First=1; Second=2; SLOPE=[];
while(II<UL.slotlength)
    II=II+1;
    if(S(II))
        SETTING=1;
        if(UL.slot(II).USEG.present) %there is an undulator
            K(II,1)=C(1)+Linears*C(2)+C(3)*Powers.^D(1);
            if(CT)
                if(~First)
                    K(LASTID,2) = K(II,1);
                    SLOPE(end+1)=K(LASTID,2) - K(LASTID,1);
                end
            else
                K(II,2)=K(II,1); 
            end
            LASTID=II;
            First=0; Second=Second-1;
            if(II>=E(1))
                Powers=Powers+1;
                Linears=Linears+1;
            else
                Linears=Linears+1;
            end
        else
            Linears=Linears+1;
        end
    else
        if(SETTING)
            Linears=Linears+1;
        else
            continue
        end
    end
end

if(CT)
      if(~First)
                 if(Second==1) %There is only one, copy & paste
                     K(LASTID,2)=K(LASTID,1);
                 elseif(Second<1)
                     K(LASTID,2)=K(LASTID,1)+SLOPE(end);
                 end
      else %there was none!
          
      end
end
end

function ScanSetting=HXRSS_Scan_SetFunction(ScanSetting,PositionOrValues, usePvValue)
    %PositionOrValues if usePvValues = 1, it is going to consider it as target values
    %if usePvValues = 0, it is going to use it as position within scan
    %table, that's the typical use when running a scan.
    if(nargin<3)
       usePvValue=1; 
    end
    lcaPutSmart(ScanSetting.ACK_PV,0);
    if(usePvValue)
       % Set the PVs and forget
       ScanSetting.OldDestination=lcaGetSmart(ScanSetting.LcaPutNoWaitList);
       Target=PositionOrValues;
       lcaPutSmart(ScanSetting.LcaPutNoWaitList,Target);
       PauseID=1;
    else
       % Set the "Position within the scan"
       ScanSetting.OldDestinations=lcaGetSmart(ScanSetting.LcaPutNoWaitList);
       Target=ScanSetting.PVValues(:,PositionOrValues);
       lcaPutSmart(ScanSetting.LcaPutNoWaitList,Target);
       PauseID=PositionOrValues;
    end
    ReadoutPV=ScanSetting.PvsWithReadOut;
    %Manage destination arrival status and pause.
    %[int_list, WPut, WReadout]=intersect(ScanSetting.LcaPutNoWaitList,ScanSetting.PvsWithReadOut,'stable');    
    CurrentValues=lcaGetSmart(ReadoutPV);
    ColumnTarget=Target(:); ColumnTarget=ColumnTarget(:);
    Distance=abs(CurrentValues-ColumnTarget); Re_Read=0;
    
    while(any(Distance>ScanSetting.Condition_TOLERANCE(:)))
       pause(0.25);
       CurrentValues=lcaGetSmart(ReadoutPV);
       NewDistance=abs(CurrentValues-ColumnTarget);
       Re_Read=Re_Read+1;
       if(any(NewDistance>=Distance) && Re_Read>5) %this seems stuck.
          Re_Read=0;
          disp('Encoder position does not match required position within tolerance');
          disp(['[Set ',ScanSetting.ACK_PV,' to 1 to bypass check and take data']);
          Breakout=lcaGetSmart(ScanSetting.ACK_PV);
          if(Breakout)
              break
          end
          lcaPutSmart(ScanSetting.LcaPutNoWaitList,Target); %issue command again
       end
       Distance=NewDistance;
    end
    lcaPutSmart(ScanSetting.ACK_PV,0);
    pause(ScanSetting.PauseValue(PauseID));
    if(~usePvValue)
        ReadAlso={'XTAL:UNDH:2850:PIT:MOTOR.RBV','XTAL:UNDH:2850:YAW:MOTOR.RBV','XTAL:UNDH:2850:X:MOTOR.RBV','XTAL:UNDH:2850:Y:MOTOR.RBV'};
        FourValues=lcaGetSmart(ReadAlso);
        ScanSetting.Values(PositionOrValues,4)=FourValues(1);
        ScanSetting.Values(PositionOrValues,5)=FourValues(2);
        ScanSetting.Values(PositionOrValues,6)=FourValues(3);
        ScanSetting.Values(PositionOrValues,7)=FourValues(4);
    end
end