function [Sol,MODEL]=undulatorClosedBump(Line, options)
persistent sh static UL
if(nargin<2)
    options=struct();
end
if(~isfield(options,'steps')), options.steps=1; end

if(~isfield(options,'sh') || ~isfield(options,'static') || ~isfield(options,'UL'))
    if(isempty(sh) || isempty(static) || isempty(UL))
        ULT_ScriptToLoadAllFunctions;
    end
else
    sh=options.sh; static=options.static; UL=options.UL;
end

switch(upper(Line(1)))
    case 'H'
        ULID=1;
    case 'S'
        ULID=2;
    otherwise
        disp('Thou needest to specify an undulator line, returning NaN');
        Sol=NaN; return
end

s=static(ULID);
u=UL(ULID);

if(~isfield(options,'xCorStart'))
    switch ULID
        case 1
            if(~isfield(options,'direction'))
                options.xCorStart='XCOR:UNDH:1380';
            else
                if(any(upper(options.direction)=='X'))
                    options.xCorStart='XCOR:UNDH:1380';
                else
                    options.xCorStart='';
                end
            end
            
        case 2
            if(~isfield(options,'direction'))
                options.xCorStart='XCOR:UNDS:1680';
            else
                if(any(upper(options.direction)=='X'))
                    options.xCorStart='XCOR:UNDS:1680';
                else
                    options.xCorStart='';
                end
            end
    end
end

if(~isfield(options,'yCorStart'))
    switch ULID
        case 1
            if(~isfield(options,'direction'))
                options.yCorStart='YCOR:UNDH:1380';
            else
                if(any(upper(options.direction)=='Y'))
                    options.yCorStart='YCOR:UNDH:1380';
                else
                    options.yCorStart='';
                end
            end
            
        case 2
            if(~isfield(options,'direction'))
                options.yCorStart='YCOR:UNDS:1680';
            else
                if(any(upper(options.direction)=='Y'))
                    options.yCorStart='YCOR:UNDS:1680';
                else
                    options.yCorStart='';
                end
            end
    end
end

if(~isfield(options,'closeAt'))
    switch ULID
        case 1
            options.closeAt='BPMS:UNDH:5190';
        case 2
            options.closeAt='BPMS:UNDS:5190';
    end
end

if(~isfield(options,'xSize')), options.xSize=300e-6; end
if(~isfield(options,'ySize')), options.ySize=300e-6; end
if(~isfield(options,'RelevantBPMs'))
    options.RelevantBPMs=false(size(s.bpmList));
    UndulatorBPMLocation=cellfun(@(x) any(x),strfind(s.bpmList_e,'UND'));
    options.RelevantBPMs(UndulatorBPMLocation(1:(end-1)))=true;
end
if(~isfield(options,'closeBump')), options.closeBump=1; end
if(~isfield(options,'closeAngle')), options.closeAngle=1; end



if(~isempty(options.xCorStart))
    ot=options;
    ot.end=find(strcmp(s.bpmList_e,options.closeAt));
    CorrMat=cell2mat(cellfun(@(x) x(1),s.corrList,'un',0));
    XCorrPos=CorrMat(:,1)=='X';
    XCorrPos=find(XCorrPos);
    ot.start=find(strcmp(s.corrList_e(XCorrPos),ot.xCorStart));
    ot.size=options.xSize;
    ot.direction='X';
    [SolX,MODEL]=sh.orbitBump(s,ot);
else
    SolX=NaN;
end

if(~isempty(options.yCorStart))
    ot=options;
    ot.end=find(strcmp(s.bpmList_e,options.closeAt));
    CorrMat=cell2mat(cellfun(@(x) x(1),s.corrList,'un',0));
    YCorrPos=CorrMat(:,1)=='Y';
    YCorrPos=find(YCorrPos);
    ot.direction='Y';
    ot.start=find(strcmp(s.corrList_e(YCorrPos),ot.yCorStart));
    ot.size=options.ySize;
    [SolY,MODEL]=sh.orbitBump(s,ot);
else
    SolY=NaN;
end

%Wrap-up.
if(isstruct(SolX) && isstruct(SolY)) %both are used.
    for II=1:4
        ActuallyUsedCorrectorsX=SolX(II).Excitation~=0;
        ActuallyUsedCorrectorsY=SolY(II).Excitation~=0;
        if( ~any(ActuallyUsedCorrectorsX))
            ActuallyUsedCorrectorsX(1)=true; ActuallyUsedCorrectorsX(end)=true;
        end
        if( ~any(ActuallyUsedCorrectorsY))
            ActuallyUsedCorrectorsY(1)=true; ActuallyUsedCorrectorsY(end)=true;
        end
        Sol(II).Success=SolX(II).Success && SolY(II).Success;
        Sol(II).CorrPV=[SolX(II).CorrPVs(ActuallyUsedCorrectorsX);SolY(II).CorrPVs(ActuallyUsedCorrectorsY)];
        Sol(II).CorrDest=[SolX(II).NewCorrectors(ActuallyUsedCorrectorsX);SolY(II).NewCorrectors(ActuallyUsedCorrectorsY)];
        Sol(II).CorrRange=[SolX(II).CorrRange(ActuallyUsedCorrectorsX,:);SolY(II).CorrRange(ActuallyUsedCorrectorsY,:)];
        Sol(II).Excitation=[SolX(II).Excitation(ActuallyUsedCorrectorsX);SolY(II).Excitation(ActuallyUsedCorrectorsY)];
        Sol(II).RestorePV=[SolX(II).CorrPVs(ActuallyUsedCorrectorsX);SolY(II).CorrPVs(ActuallyUsedCorrectorsY)];
        Sol(II).RestoreDest=[SolX(II).OldCorrectors(ActuallyUsedCorrectorsX);SolY(II).OldCorrectors(ActuallyUsedCorrectorsY)];
        Sol(II).MaxExcursionReleventBPM=[SolX(II).MaxExcursionRelevantBPM_X;SolY(II).MaxExcursionRelevantBPM_Y];
        Sol(II).MaxExcursion=[SolX(II).MaxExcursion_X;SolY(II).MaxExcursion_Y];
    end
elseif(isstruct(SolX))
    for II=1:4
        ActuallyUsedCorrectorsX=SolX(II).Excitation~=0;
        if( ~any(ActuallyUsedCorrectorsX))
            ActuallyUsedCorrectorsX(1)=true; ActuallyUsedCorrectorsX(end)=true;
        end
        Sol(II).Success=SolX(II).Success;
        Sol(II).CorrPV=SolX(II).CorrPVs(ActuallyUsedCorrectorsX);
        Sol(II).CorrRange=SolX(II).CorrRange(ActuallyUsedCorrectorsX,:);
        Sol(II).CorrDest=SolX(II).NewCorrectors(ActuallyUsedCorrectorsX);
        Sol(II).Excitation=SolX(II).Excitation(ActuallyUsedCorrectorsX);
        Sol(II).RestorePV=SolX(II).CorrPVs(ActuallyUsedCorrectorsX);
        Sol(II).RestoreDest=SolX(II).OldCorrectors(ActuallyUsedCorrectorsX);
        Sol(II).MaxExcursionReleventBPM=SolX(II).MaxExcursionRelevantBPM;
        Sol(II).MaxExcursion=SolX(II).MaxExcursion;
    end
elseif(isstruct(SolY))
    for II=1:4
        ActuallyUsedCorrectorsY=SolY(II).Excitation~=0;
        if( ~any(ActuallyUsedCorrectorsY))
            ActuallyUsedCorrectorsY(1)=true; ActuallyUsedCorrectorsY(end)=true;
        end
        Sol(II).Success=SolY(II).Success;
        Sol(II).CorrPV=SolY(II).CorrPVs(ActuallyUsedCorrectorsY);
        Sol(II).CorrDest=SolY(II).NewCorrectors(ActuallyUsedCorrectorsY);
        Sol(II).CorrRange=SolY(II).CorrRange(ActuallyUsedCorrectorsY,:);
        Sol(II).Excitation=SolY(II).Excitation(ActuallyUsedCorrectorsY);
        Sol(II).RestorePV=SolY(II).CorrPVs(ActuallyUsedCorrectorsY);
        Sol(II).RestoreDest=SolY(II).OldCorrectors(ActuallyUsedCorrectorsY);
        Sol(II).MaxExcursionReleventBPM=SolY(II).MaxExcursionRelevantBPM;
        Sol(II).MaxExcursion=SolY(II).MaxExcursion;
    end
else
    Sol=NaN;
end

if(isstruct(Sol))
    for II=1:4
        if(options.steps>1)
            [~,we,ws]=intersect(strcat(s.corrList_e,':BCTRL'),Sol(II).CorrPV,'stable');
            CorrRange=s.corrRange(we,:);
            MaxCoeff=zeros(length(Sol(II).Excitation)*2,1);
            for sign=1:2
                if(sign==1)
                    UseEx=Sol(II).Excitation;
                else
                    UseEx=-Sol(II).Excitation;
                end
                for JJ=1:length(UseEx)
                    if(UseEx(JJ)>=0)
                        MaxCoeff(JJ+length(Sol(II).Excitation)*(sign-1)) = (CorrRange(JJ,2) - Sol(II).RestoreDest(JJ))/UseEx(JJ);
                    else
                        MaxCoeff(JJ+length(Sol(II).Excitation)*(sign-1)) = (CorrRange(JJ,1) - Sol(II).RestoreDest(JJ))/UseEx(JJ);
                    end
                end
            end
            Max2SidesAvailable=min(MaxCoeff);
            Max2SidesAvailableForgetClosing=min(MaxCoeff(1,:));
            Max2SidesAvailableForgetClosingResidual=min(MaxCoeff(2:end,:));
            Sol(II).Max2SidesAvailable=Max2SidesAvailable;
            Sol(II).Max2SidesAvailableForgetClosing=Max2SidesAvailableForgetClosing;
            Sol(II).Max2SidesAvailableForgetClosingResidual=Max2SidesAvailableForgetClosingResidual;
            if(Max2SidesAvailable>=1)
                for JJ=1:length(Sol(II).Excitation)
                    Sol(II).KickTable(JJ,:)=Sol(II).RestoreDest(JJ)+linspace(-Sol(II).Excitation(JJ),Sol(II).Excitation(JJ),options.steps);
                end
                Sol(II).KickScanSuccess=1;
                Sol(II).KickScanSuccessForgetClosing=1;
                Sol(II).KickTableForgetClosing=Sol(II).KickTable;
                Sol(II).KickScanMaximum2SidesOrbitDisplacement=abs(Sol(II).MaxExcursionReleventBPM);
                Sol(II).KickScanForgetClosingMaximum2SidesOrbitDisplacement=abs(Sol(II).MaxExcursionReleventBPM);
            else
                for JJ=1:length(Sol(II).Excitation)
                    Sol(II).KickTable(JJ,:)=Sol(II).RestoreDest(JJ)+linspace(-Sol(II).Excitation(JJ),Sol(II).Excitation(JJ),options.steps)*Max2SidesAvailable;
                end
                Sol(II).KickScanSuccess=0;
                Sol(II).KickScanMaximum2SidesOrbitDisplacement=abs(Sol(II).MaxExcursionReleventBPM*Max2SidesAvailable);
                
                if(Max2SidesAvailableForgetClosing>=1) %Two sides room ok, but maybe it doesn't close.
                    Sol(II).KickScanSuccessForgetClosing=1;
                    Sol(II).KickTableForgetClosing(JJ,:)=Sol(II).RestoreDest(JJ)+linspace(-Sol(II).Excitation(JJ),Sol(II).Excitation(JJ),options.steps);
                    Sol(II).KickScanForgetClosingMaximum2SidesOrbitDisplacement=abs(Sol(II).MaxExcursionReleventBPM);
                else %there is not room for two sides kick. Period.
                    Sol(II).KickScanSuccessForgetClosing=0;
                    Sol(II).KickTableForgetClosing(JJ,:)=Sol(II).RestoreDest(JJ)+linspace(-Sol(II).Excitation(JJ),Sol(II).Excitation(JJ),options.steps)*Max2SidesAvailableForgetClosing;
                    Sol(II).KickScanForgetClosingMaximum2SidesOrbitDisplacement=abs(Sol(II).MaxExcursionReleventBPM)*Max2SidesAvailableForgetClosing;
                end
            end
            
            for HH=1:options.steps
                Sol(II).KickScan{HH}=Sol(II).KickTable(:,HH);
                Sol(II).KickScanForgetClosing{HH}=Sol(II).KickTableForgetClosing(:,HH);
            end
        end
    end
    
end
