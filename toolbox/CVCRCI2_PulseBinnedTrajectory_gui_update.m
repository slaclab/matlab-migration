function CVCRCI2_PulseBinnedTrajectory_gui_update(Initialize, SynchMode, MyHandle,StrutturaDatiFull,PulseIDMatrix,TimeStampsMatrix,AbsoluteEventCounterMatrix,ProfileBuffer,SynchProfilePVs,NotSynchProfilePVs,AdditionalNonStandardPVsMatrices,FiltersBuffer,ScalarsBuffer,ScanBuffer,AcquisitionBufferCycle,AcquisitionTotalSynchronousEvents,AcquisitionBufferNextWrittenElement,AcquisitionBufferLastWrittenElement)
persistent LASTBLOCKPID;
persistent XTRAJPOS;
persistent YTRAJPOS;
persistent History;
persistent HistoryLength;
persistent GDETPOSITION;
persistent XPOS;
persistent YPOS;
persistent COLORMATRIX;
persistent MAXAbsoluteEventCounterMatrix;

if(Initialize)
    CurrentDataStructure = get(MyHandle.StrutturaDatiAttuale,'userdata');
    if(isequal(CurrentDataStructure,StrutturaDatiFull))
        
    else
        MAXAbsoluteEventCounterMatrix=-inf;
        XTRAJPOS=zeros(34,2);
        YTRAJPOS=zeros(34,2);
        XPOS=[];
        YPOS=[];
        LASTBLOCKPID=-inf;
        History=[];
        HistoryLength=100;
        COLORMATRIX=[0,0,0;1,0,0;0,0,1;0,1,0;0,1,1;1,0,1;1,1,0;1/2,1/2,1/2;1,1/2,1/2;1/2,1,1/2;1/2,1/2,1;0,1/2,1;1/2,0,1;1,0,1/2;1,1/2,0;0,1,1/2;1/2,1,0;1/3,1/3,1/3,;2/3,2/3,2/3;0,2/3,1/2];
        COLORMATRIX=repmat(COLORMATRIX,[6,1]);
        XBPMLIST={'BPMS:UND1:100:X'};
        YBPMLIST={'BPMS:UND1:100:Y'};
        for II=1:33
            XBPMLIST{end+1}=['BPMS:UND1:',num2str(II),'90:X'];
            YBPMLIST{end+1}=['BPMS:UND1:',num2str(II),'90:Y'];
        end
        
        for KK=1:numel(XBPMLIST)
            Position=find(strcmp(StrutturaDatiFull.ScalarNames,XBPMLIST{KK}));
            if(~isempty(Position))
                XTRAJPOS(KK,1)=StrutturaDatiFull.ScalarWhereToBeFound(Position,3);
                XTRAJPOS(KK,2)=KK;
                XPOS(end+1)=KK;
            end
        end
        
        GDETPOSITION=find(strcmp(StrutturaDatiFull.ScalarNames,'GDET:FEE1:241:ENRC'));
        
        for KK=1:numel(YBPMLIST)
            Position=find(strcmp(StrutturaDatiFull.ScalarNames,YBPMLIST{KK}));
            if(~isempty(Position))
                YTRAJPOS(KK,1)=StrutturaDatiFull.ScalarWhereToBeFound(Position,3);
                YTRAJPOS(KK,2)=KK;
                YPOS(end+1)=KK;
            end
        end
        
        petizione=get(MyHandle.IdatiStanQua,'userdata');
        set(MyHandle.StrutturaDatiAttuale,'userdata',StrutturaDatiFull);
        
        LIST_OF_SCALARS{1}='OFF';
        for II=1:numel(StrutturaDatiFull.ScalarNames)
            LIST_OF_SCALARS{end+1}=StrutturaDatiFull.ScalarNames{II};
        end
        
        set(MyHandle.X_SEL,'string',LIST_OF_SCALARS);
        if(get(MyHandle.X_SEL,'value') > numel(LIST_OF_SCALARS))
            set(MyHandle.X_SEL,'value',1);
            petizione.X_SEL=[0,0,0];
        else %reset it as the current value...
            VAL=get(MyHandle.X_SEL,'value');
            if(VAL==1)
                petizione.X_SEL=[0,0,0];
            else
                petizione.X_SEL=StrutturaDatiFull.ScalarWhereToBeFound(VAL-1,:);
            end
        end
        
        set(MyHandle.e_x1,'string',num2str(petizione.lim_x1));
        set(MyHandle.e_x2,'string',num2str(petizione.lim_x2));
        
        set(MyHandle.TOM,'value',petizione.OUTPVS);
        set(MyHandle.TOME,'value',petizione.ErrorBars);
        set(MyHandle.TOMEA,'value',petizione.ErrorBarsOnAvg);
        set(MyHandle.TOMT,'value',petizione.ShowTraj);
        set(MyHandle.TORELORBIT,'value',petizione.RELORBIT);
        set(MyHandle.RejectLow,'string',num2str(petizione.RejectLow));
        set(MyHandle.e_binsx,'string',num2str(petizione.binsx));
        set(MyHandle.e_binsy,'string',num2str(petizione.binsy));
        set(MyHandle.eT1,'string',num2str(petizione.TOLX));
        set(MyHandle.eT2,'string',num2str(petizione.TOLY));
        set(MyHandle.eT3,'string',num2str(petizione.TOL));
        set(MyHandle.Frequency,'value',petizione.Frequency);
        set(MyHandle.FormulaErr,'value',petizione.FormulaErr);
        set(MyHandle.ConsecutiveDataCheck,'string','NOT ENOUGH CONSECUTIVE DATA');
        set(MyHandle.ConsecutiveDataCheck,'backgroundcolor',[1,0,0]);
        %         set(MyHandle.TypeOfPlot,'value',petizione.TypeOfPlot);
        if(SynchMode)
            set(MyHandle.SynchModeFlag,'string','Running in Synchronous Mode');
            set(MyHandle.SynchModeFlag,'backgroundcolor',[0,1,0]);
        else
            set(MyHandle.SynchModeFlag,'string','NOT Running in Synchronous Mode');
            set(MyHandle.SynchModeFlag,'backgroundcolor',[1,0,0]);
        end
        set(MyHandle.OUTOFSYNCH,'string','OUT OF SYNCH');
        set(MyHandle.OUTOFSYNCH,'backgroundcolor',[1,0,0]);
        pulsesstring='[';
        %save TEMPXXX
        for TT=1:length(petizione.Pulses)
            if(TT>1)
                pulsesstring=[pulsesstring,',',num2str(petizione.Pulses(TT))];
            else
                pulsesstring=[pulsesstring,num2str(petizione.Pulses(TT))];
            end
        end
        pulsesstring=[pulsesstring,']'];
        set(MyHandle.ShowPulses,'string',pulsesstring);
        if(petizione.b_autoX)
            set(MyHandle.b_autoX,'backgroundcolor',[0,1,0]);
        else
            set(MyHandle.b_autoX,'backgroundcolor',[0.7,0.7,0.7]);
        end
        set(MyHandle.IdatiStanQua,'userdata',petizione);
    end
else
    if(isempty(XTRAJPOS) &&  isempty(YTRAJPOS))
        XTRAJPOS=zeros(34,2);
        YTRAJPOS=zeros(34,2);
        XPOS=[];
        YPOS=[];
        LASTBLOCKPID=-inf;
        History=[];
        HistoryLength=100;
        COLORMATRIX=[0,0,0;1,0,0;0,0,1;0,1,0;0,1,1;1,0,1;1,1,0;1/2,1/2,1/2;1,1/2,1/2;1/2,1,1/2;1/2,1/2,1;0,1/2,1;1/2,0,1;1,0,1/2;1,1/2,0;0,1,1/2;1/2,1,0;1/3,1/3,1/3,;2/3,2/3,2/3;0,2/3,1/2];
        COLORMATRIX=repmat(COLORMATRIX,[6,1]);
        MAXAbsoluteEventCounterMatrix=-inf;
        XBPMLIST={'BPMS:UND1:100:X'};
        YBPMLIST={'BPMS:UND1:100:Y'};
        for II=1:33
            XBPMLIST{end+1}=['BPMS:UND1:',num2str(II),'90:X'];
            YBPMLIST{end+1}=['BPMS:UND1:',num2str(II),'90:Y'];
        end
        
        for KK=1:numel(XBPMLIST)
            Position=find(strcmp(StrutturaDatiFull.ScalarNames,XBPMLIST{KK}));
            if(~isempty(Position))
                XTRAJPOS(KK,1)=StrutturaDatiFull.ScalarWhereToBeFound(Position,3);
                XTRAJPOS(KK,2)=KK;
                XPOS(end+1)=KK;
            end
        end
        
        GDETPOSITION=find(strcmp(StrutturaDatiFull.ScalarNames,'GDET:FEE1:241:ENRC'));
        
        for KK=1:numel(YBPMLIST)
            Position=find(strcmp(StrutturaDatiFull.ScalarNames,YBPMLIST{KK}));
            if(~isempty(Position))
                YTRAJPOS(KK,1)=StrutturaDatiFull.ScalarWhereToBeFound(Position,3);
                YTRAJPOS(KK,2)=KK;
                YPOS(end+1)=KK;
            end
        end
        
    end
    
    petizione=get(MyHandle.IdatiStanQua,'userdata');
    % da controllare se e' il primo giro, se no... insomma un caos
    if(SynchMode==1)
        NOT_ENOUGH_CONSECUTIVE_DATA=0;
        OUT_OF_TOL=0;
        OUT_OF_SYNCH=0;
        if(petizione.binsy<sum(FiltersBuffer{1}))
            set(MyHandle.ConsecutiveDataCheck,'string','NOT ENOUGH CONSECUTIVE DATA');
            set(MyHandle.ConsecutiveDataCheck,'backgroundcolor',[1,0,0]);
            NOT_ENOUGH_CONSECUTIVE_DATA=1;
        end
        
        [SortedPulses,SortedOrder]=sort(AbsoluteEventCounterMatrix,'descend');
        XTRAJ=SynchProfilePVs(SortedOrder(1:petizione.binsy),XTRAJPOS(:,1));
        YTRAJ=SynchProfilePVs(SortedOrder(1:petizione.binsy),YTRAJPOS(:,1));
        GDET=SynchProfilePVs(SortedOrder(1:petizione.binsy),GDETPOSITION);
        
        switch(petizione.X_SEL(1))
            case 0
                DATI_X=[];
            case 1
                DATI_X=SynchProfilePVs(:,petizione.X_SEL(3));
            case 2
                DATI_X=AdditionalNonStandardPVsMatrices{petizione.X_SEL(2)}(:,petizione.X_SEL(3));
            case 3
                DATI_X=NotSynchProfilePVs(:,petizione.X_SEL(3));
            case 4
                DATI_X=ScalarsBuffer(:,petizione.X_SEL(3));
            case 5
                DATI_X= PulseIDMatrix(:);
            case 6
                DATI_X= TimeStampsMatrix(:);
            case 7
                DATI_X= AbsoluteEventCounterMatrix(:);
            case 8
                DATI_X= ScanBuffer(:,petizione.X_SEL(3));
        end
        
        %Synchronize...
        if(~isempty(GDET))
            PASGD=conv(GDET,ones(1,5)/5,'valid');
            if(any(PASGD<petizione.lim_x1) || any(PASGD>petizione.lim_x2))
                set(MyHandle.ConsecutiveDataCheck,'string','NOT ENOUGH CONSECUTIVE DATA');
                set(MyHandle.ConsecutiveDataCheck,'backgroundcolor',[1,0,0]);
                NOT_ENOUGH_CONSECUTIVE_DATA=1;
            else
                set(MyHandle.ConsecutiveDataCheck,'string','ENOUGH CONSECUTIVE DATA');
                set(MyHandle.ConsecutiveDataCheck,'backgroundcolor',[0,1,0]);
                NOT_ENOUGH_CONSECUTIVE_DATA=0;
            end
        else
            set(MyHandle.ConsecutiveDataCheck,'string','NO GDET DATA, GOOD DATA CHECK DISABLED');
            set(MyHandle.ConsecutiveDataCheck,'backgroundcolor',[1,1,0]);
            NOT_ENOUGH_CONSECUTIVE_DATA=0;
        end
        
        switch petizione.Frequency
            case 1
                SOR=120;
            case 2
                SOR=24;
            case 3
                SOR=12;
            case 4
                SOR=4;
            case 5
                SOR=2;
        end
        
        %save TEMPXXX
        SortedBPMsX=zeros(petizione.binsy/SOR,length(XPOS),SOR);
        SortedBPMsY=zeros(petizione.binsy/SOR,length(YPOS),SOR);
        %UPDATE X AND Y TRAJ
        for SS=1:SOR
            SortedBPMsX(:,:,SS)=XTRAJ(SS:SOR:end,:);
            SortedBPMsY(:,:,SS)=YTRAJ(SS:SOR:end,:);
        end
        
        %         %Faking synchronization ADD LINES TO ADD A FAKE
        %         SYNCHRONIZATION
        %         TOBESYNCH=mod(round(rand(1)*24)+1,25);
        %         if(TOBESYNCH==0 || TOBESYNCH>24)
        %           TOBESYNCH=1;
        %         end
        %         TOBESYNCH=7;
        %         disp([num2str(TOBESYNCH),' will be the synch one'])
        %         SortedBPMsX(:,:,TOBESYNCH)=0;
        %         SortedBPMsY(:,:,TOBESYNCH)=0;
        
        %check if out or in synch
        if(petizione.b_autoX) %Run self-synchronization algorithm
            for SS=1:SOR
                DEV(SS)=sum(std(SortedBPMsX(:,:,SS))) + sum(std(SortedBPMsY(:,:,SS)));
            end
            [~,MinimumPosition]=min(DEV);
            MinimumPosition
            DataPresentationCircShift=MinimumPosition-1;
            
        else % Use input information as synchronization
            ResortedPID=mod(PulseIDMatrix(SortedOrder(1:petizione.binsy))-petizione.binsx,SOR*3);
            PositionRP=find(ResortedPID==0,1,'first');
            DataPresentationCircShift=PositionRP-1;
        end
        
        if(~isempty(GDET))
            for SS=1:SOR
                SortedGDET(:,SS)=GDET(SS:SOR:end);
            end
            %SortedGDET(:,TOBESYNCH)=0;
            try
                if(any(SortedGDET(:,DataPresentationCircShift+1)> petizione.RejectLow) )
                    set(MyHandle.OUTOFSYNCH,'string','OUT OF SYNCH');
                    set(MyHandle.OUTOFSYNCH,'backgroundcolor',[1,0,0]);
                    OUT_OF_SYNCH=1;
                else
                    set(MyHandle.OUTOFSYNCH,'string','IN SYNCH');
                    set(MyHandle.OUTOFSYNCH,'backgroundcolor',[0,1,0]);
                    OUT_OF_SYNCH=0;
                end
            catch SOMETHINGWRONG
                set(MyHandle.OUTOFSYNCH,'string','OUT OF SYNCH');
                set(MyHandle.OUTOFSYNCH,'backgroundcolor',[1,0,0]);
                OUT_OF_SYNCH=1;
            end
        end
        cla(MyHandle.axesX,'reset'); hold(MyHandle.axesX,'on');
        cla(MyHandle.axesY,'reset'); hold(MyHandle.axesY,'on');
        cla(MyHandle.axesE,'reset'); hold(MyHandle.axesE,'on');
        
        %plot on the main windows...
        inserted=0;
        
        MeanTrajX=mean(SortedBPMsX);
        MeanTrajY=mean(SortedBPMsY);
        stdTrajX=std(SortedBPMsX);
        stdTrajY=std(SortedBPMsY);
        legenda={};
        disp(['main shift =',num2str(DataPresentationCircShift)]);
        SORTORDER=[(DataPresentationCircShift+1):24,(1:DataPresentationCircShift)];
        if(petizione.RELORBIT)
            if(SOR>=12)
                ReferenceOrbitX=squeeze(mean(MeanTrajX(:,:,SORTORDER(2:(end-4))),3));
                ReferenceOrbitY=squeeze(mean(MeanTrajY(:,:,SORTORDER(2:(end-4))),3));
            elseif(SOR==4)
                ReferenceOrbitX=squeeze(mean(MeanTrajX(:,:,SORTORDER(2:3)),3));
                ReferenceOrbitY=squeeze(mean(MeanTrajY(:,:,SORTORDER(2:3)),3));
            else
                ReferenceOrbitX=0;
                ReferenceOrbitY=0;
            end
        else
            ReferenceOrbitX=0;
            ReferenceOrbitY=0;
        end
        for SS=SORTORDER
            if(any(petizione.Pulses==mod(SS-SORTORDER(1),SOR)))
                inserted=inserted+1;
                plot(MyHandle.axesX,XPOS,squeeze(MeanTrajX(:,:,SS))-ReferenceOrbitX,'Marker','.','Color',COLORMATRIX(inserted,:));
                plot(MyHandle.axesY,YPOS,squeeze(MeanTrajY(:,:,SS))-ReferenceOrbitY,'Marker','.','Color',COLORMATRIX(inserted,:));
                legenda{inserted}=['Pulse ',num2str(mod(SORTORDER(1)-SS,SOR))];
                if(petizione.ErrorBars)
                    errorbar(MyHandle.axesX,XPOS,squeeze(MeanTrajX(:,:,SS))-ReferenceOrbitX,squeeze(stdTrajX(:,:,SS)),'Color',COLORMATRIX(inserted,:));
                    errorbar(MyHandle.axesY,YPOS,squeeze(MeanTrajY(:,:,SS))-ReferenceOrbitY,squeeze(stdTrajY(:,:,SS)),'Color',COLORMATRIX(inserted,:));
                end
                if(petizione.ErrorBarsOnAvg)
                    errorbar(MyHandle.axesX,XPOS,squeeze(MeanTrajX(:,:,SS))-ReferenceOrbitX,squeeze(stdTrajX(:,:,SS))/sqrt(petizione.binsy/SOR),'Color',COLORMATRIX(inserted,:));
                    errorbar(MyHandle.axesY,YPOS,squeeze(MeanTrajY(:,:,SS))-ReferenceOrbitY,squeeze(stdTrajY(:,:,SS))/sqrt(petizione.binsy/SOR),'Color',COLORMATRIX(inserted,:));
                end
            end
        end
        MTRX=squeeze(mean(MeanTrajX(:,:,SORTORDER(2:end)),3));
        MTRY=squeeze(mean(MeanTrajY(:,:,SORTORDER(2:end)),3));
        if(petizione.ShowTraj)
            plot(MyHandle.axesX,XPOS,MTRX,'m','LineWidth',2);
            plot(MyHandle.axesY,YPOS,MTRY,'m','LineWidth',2);
        end
        if(inserted<10)
            legend(MyHandle.axesX,legenda) ; legend(MyHandle.axesY,legenda) ;
        end
        
        %UPDATE HISTORY or SHOWS PARTITION RESULTS
        Erx=NaN;
        Ery=NaN;
        Er=NaN;
        switch(petizione.FormulaErr)
            case 1
                Erx=sqrt(sum((squeeze(MeanTrajX(:,:,SORTORDER(2))) -  squeeze(MeanTrajX(:,:,SORTORDER(end))) ).^2));
                Ery=sqrt(sum((squeeze(MeanTrajY(:,:,SORTORDER(2))) -  squeeze(MeanTrajY(:,:,SORTORDER(end))) ).^2));
                Er=sqrt(Erx^2+Ery^2);
            case 2
                Erx=sqrt(sum((squeeze(MeanTrajX(:,:,SORTORDER(2))) -  MTRX ).^2));
                Ery=sqrt(sum((squeeze(MeanTrajY(:,:,SORTORDER(2))) -  MTRY ).^2));
                Er=sqrt(Erx^2+Ery^2);
            case 3
                Erx=sqrt(sum((squeeze(MeanTrajX(:,:,SORTORDER(2))) -  MTRX ).^2) + sum((squeeze(MeanTrajX(:,:,SORTORDER(3))) -  MTRX ).^2));
                Ery=sqrt(sum((squeeze(MeanTrajY(:,:,SORTORDER(2))) -  MTRY ).^2) + sum((squeeze(MeanTrajY(:,:,SORTORDER(3))) -  MTRY ).^2)   );
                Er=sqrt(Erx^2+Ery^2);
            case 4
                Erx=mean(std(permute(MeanTrajX(:,:,SORTORDER(1:end)),[2,3,1])));
                Ery=mean(std(permute(MeanTrajY(:,:,SORTORDER(1:end)),[2,3,1])));
                Er=sqrt(Erx^2+Ery^2);
        end
        set(MyHandle.xdiststring,'string',num2str(Erx));
        set(MyHandle.ydiststring,'string',num2str(Ery));
        set(MyHandle.diststring,'string',num2str(Er));
        %         HistoryLength
        %         length(History)
        
        if(~OUT_OF_SYNCH && ~NOT_ENOUGH_CONSECUTIVE_DATA && (MAXAbsoluteEventCounterMatrix~=max(AbsoluteEventCounterMatrix)))
            if(HistoryLength>length(History))
                History(end+1,1)=Erx;
                History(end,2)=Ery;
                History(end,3)=Er;
            else
                History=History(2:(HistoryLength-1),:);
                History(HistoryLength,1)=Erx;
                History(HistoryLength,2)=Ery;
                History(HistoryLength,3)=Er;
            end
            MAXAbsoluteEventCounterMatrix=max(AbsoluteEventCounterMatrix);
            if((Erx>petizione.TOLX) || (Ery>petizione.TOLY) || (Er>petizione.TOL) )
                set(MyHandle.text47,'string','OUT OF TOL');
                set(MyHandle.text47,'backgroundcolor',[1,0,0]);
            else
                set(MyHandle.text47,'string','INSIDE TOL');
                set(MyHandle.text47,'backgroundcolor',[0,1,0]);
            end
        end
        
        if(~isempty(DATI_X)) %Deve fare la partizione...sai complicado...
            %save TEMPXXX
            PartitionVariable=unique(DATI_X,'stable');
            settingsfound=0;ERRORIX=[];ERRORIY=[];ERRORI=[];XSET=[];
            for XX=1:length(PartitionVariable)
                falseflag=false(size(FiltersBuffer{1}));
                falseflag(PartitionVariable==PartitionVariable(XX))=true;
                NOT_ENOUGH_CONSECUTIVE_DATA=0;
                OUT_OF_SYNCH=0;
                if(petizione.binsy<sum(falseflag))
                    continue
                end
                TEMPAbsoluteEventCounterMatrix=AbsoluteEventCounterMatrix;
                TEMPAbsoluteEventCounterMatrix(~falseflag)=-inf;
                [SortedPulses,SortedOrder]=sort(TEMPAbsoluteEventCounterMatrix,'descend');
                XTRAJ=SynchProfilePVs(SortedOrder(1:petizione.binsy),XTRAJPOS(:,1));
                YTRAJ=SynchProfilePVs(SortedOrder(1:petizione.binsy),YTRAJPOS(:,1));
                GDET=SynchProfilePVs(SortedOrder(1:petizione.binsy),GDETPOSITION);
                if(~isempty(GDET))
                    PASGD=conv(GDET,ones(1,5)/5,'valid');
                    if(any(PASGD<petizione.lim_x1) || any(PASGD>petizione.lim_x2))
                        continue
                    else
                        
                    end
                else
                    
                end
                
                SortedBPMsX=zeros(petizione.binsy/SOR,length(XPOS),SOR);
                SortedBPMsY=zeros(petizione.binsy/SOR,length(YPOS),SOR);
                %UPDATE X AND Y TRAJ
                for SS=1:SOR
                    SortedBPMsX(:,:,SS)=XTRAJ(SS:SOR:end,:);
                    SortedBPMsY(:,:,SS)=YTRAJ(SS:SOR:end,:);
                end
                
                %                 SortedBPMsX(:,:,TOBESYNCH)=0;
                %                 SortedBPMsY(:,:,TOBESYNCH)=0;
                
                %check if out or in synch
                if(petizione.b_autoX) %Run self-synchronization algorithm
                    DEV=squeeze(sum(std(SortedBPMsX,1) + std(SortedBPMsY,1),2));
                    [~,MinimumPosition]=min(DEV);
                    DataPresentationCircShift=MinimumPosition-1;
                else % Use input information as synchronization
                    ResortedPID=mod(PulseIDMatrix(SortedOrder(1:petizione.binsy))-petizione.binsx,SOR*3);
                    PositionRP=find(ResortedPID==0,1,'first');
                    DataPresentationCircShift=PositionRP-1;
                end
                if(~isempty(GDET))
                    for SS=1:SOR
                        SortedGDET(:,SS)=GDET(SS:SOR:end);
                    end
                    try
                        if(any(SortedGDET(:,DataPresentationCircShift+1)> petizione.RejectLow) )
                            continue
                        else
                            
                        end
                    catch SOMETHINGWRONG
                        continue
                    end
                end
                MeanTrajX=mean(SortedBPMsX);
                MeanTrajY=mean(SortedBPMsY);
                stdTrajX=std(SortedBPMsX);
                stdTrajY=std(SortedBPMsY);
                SORTORDER=[DataPresentationCircShift+1:24,1:DataPresentationCircShift];
                MTRX=squeeze(mean(MeanTrajX(:,:,SORTORDER(2:end)),3));
                MTRY=squeeze(mean(MeanTrajY(:,:,SORTORDER(2:end)),3));
                settingsfound=settingsfound+1;
                
                switch(petizione.FormulaErr)
                    case 1
                        ErxT=sqrt(sum((squeeze(MeanTrajX(:,:,SORTORDER(2))) -  squeeze(MeanTrajX(:,:,SORTORDER(end))) ).^2));
                        EryT=sqrt(sum((squeeze(MeanTrajY(:,:,SORTORDER(2))) -  squeeze(MeanTrajY(:,:,SORTORDER(end))) ).^2));
                        ErT=sqrt(ErxT^2+EryT^2);
                    case 2
                        ErxT=sqrt(sum((squeeze(MeanTrajX(:,:,SORTORDER(2))) -  MTRX ).^2));
                        EryT=sqrt(sum((squeeze(MeanTrajY(:,:,SORTORDER(2))) -  MTRY ).^2));
                        ErT=sqrt(ErxT^2+EryT^2);
                    case 3
                        ErxT=sqrt(sum((squeeze(MeanTrajX(:,:,SORTORDER(2))) -  MTRX ).^2) + sum((squeeze(MeanTrajX(:,:,SORTORDER(3))) -  MTRX ).^2));
                        EryT=sqrt(sum((squeeze(MeanTrajY(:,:,SORTORDER(2))) -  MTRY ).^2) + sum((squeeze(MeanTrajY(:,:,SORTORDER(3))) -  MTRY ).^2)   );
                        ErT=sqrt(ErxT^2+EryT^2);
                    case 4
                        ErxT=mean(std(permute(MeanTrajX(:,:,SORTORDER(1:end)),[2,3,1])));
                        EryT=mean(std(permute(MeanTrajY(:,:,SORTORDER(1:end)),[2,3,1])));
                        ErT=sqrt(ErxT^2+EryT^2);
                end
                
                ERRORIX(settingsfound)=ErxT;
                ERRORIY(settingsfound)=EryT;
                ERRORI(settingsfound)=ErT;
                XSET(settingsfound)=PartitionVariable(XX);
            end
            if(~isempty(XSET))
                plot(MyHandle.axesE,XSET,ERRORIX,'.b');
                plot(MyHandle.axesE,XSET,ERRORIY,'.r');
                plot(MyHandle.axesE,XSET,ERRORI,'.k');
                legend(MyHandle.axesE,'X','Y','Both','location','SouthWest')
            end
            
        elseif(~isempty(History)) %plotta la storia
            plot(MyHandle.axesE,History(:,1),'.b');
            plot(MyHandle.axesE,History(:,2),'.r');
            plot(MyHandle.axesE,History(:,3),'.k');
            legend(MyHandle.axesE,'X','Y','Both','location','SouthWest')
        end
        
    else
        % this is not supposed to work in asynchronous mode
    end
    
    if(petizione.logbook_and_save || petizione.logbook_only)
        
        petizione.logbook_only=0;
        set(MyHandle.IdatiStanQua,'userdata',petizione);
        
        CurrentTime=clock;
        CurrentYearString=num2str(CurrentTime(1),'%.4d');
        CurrentMonthString=num2str(CurrentTime(2),'%.2d');
        CurrentDieiString=num2str(CurrentTime(3),'%.2d');
        CurrentTempo1String=num2str(CurrentTime(4),'%.2d');
        CurrentTempo2String=num2str(CurrentTime(5),'%.2d');
        CurrentTempo3String=num2str(floor(CurrentTime(6)),'%.2d');
        CurrentTempo4String=num2str(round((CurrentTime(6)-floor(CurrentTime(6)))*1000),'%.3d');
        CurrentTimeString=[CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString,'--',CurrentTempo1String,'-',CurrentTempo2String,'-',CurrentTempo3String,'-',CurrentTempo4String];
        titlestring=['OnlineMonitor - ',CurrentTimeString];
        filename=['OnlineMonitor_',CurrentTimeString];
        targetdir=['/u1/lcls/matlab/data/',CurrentYearString,'/',CurrentYearString,'-',CurrentMonthString,'/',CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString];
        if(petizione.logbook_and_save)
            if(isdir(targetdir))
                save([targetdir,'/',filename],'StrutturaDatiFull','PulseIDMatrix','TimeStampsMatrix','AbsoluteEventCounterMatrix','ProfileBuffer','SynchProfilePVs','NotSynchProfilePVs','AdditionalNonStandardPVsMatrices','FiltersBuffer','ScalarsBuffer','ScanBuffer','AcquisitionBufferCycle','AcquisitionTotalSynchronousEvents','AcquisitionBufferNextWrittenElement','AcquisitionBufferLastWrittenElement','-v7.3');
            else
                mkdir(targetdir);
                save([targetdir,'/',filename],'StrutturaDatiFull','PulseIDMatrix','TimeStampsMatrix','AbsoluteEventCounterMatrix','ProfileBuffer','SynchProfilePVs','NotSynchProfilePVs','AdditionalNonStandardPVsMatrices','FiltersBuffer','ScalarsBuffer','ScanBuffer','AcquisitionBufferCycle','AcquisitionTotalSynchronousEvents','AcquisitionBufferNextWrittenElement','AcquisitionBufferLastWrittenElement','-v7.3');
            end
            petizione.logbook_and_save=0;
            set(MyHandle.IdatiStanQua,'userdata',petizione);
        end
        NuovaFigura=figure;
        copyobj(MyHandle.axesX,NuovaFigura);
        copyobj(MyHandle.axesY,NuovaFigura);
        copyobj(MyHandle.axesE,NuovaFigura);
        CHILDREN=get(NuovaFigura,'children');
        set(CHILDREN(1),'position',[12 2.5 75 6]);
        xlabel(CHILDREN(1),'history,  X blue, Y red, Both black','fontsize',6)
        set(CHILDREN(2),'position',[12 11 75 6]);
        title(CHILDREN(2),'Y Traj','fontsize',8);
        set(CHILDREN(3),'position',[12 20.5 75 6]);
        title(CHILDREN(3),'X Traj','fontsize',8);
        legend(CHILDREN(2),legenda,'fontsize',6)
        legend(CHILDREN(3),legenda,'fontsize',6)
        
        try
            util_printLog(NuovaFigura);
        end
        petizione.logbook_only=0;
        set(MyHandle.IdatiStanQua,'userdata',petizione);
    end
    
    
end
