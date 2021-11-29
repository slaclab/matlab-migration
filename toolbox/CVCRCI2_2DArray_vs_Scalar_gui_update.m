function CVCRCI2_2DArray_vs_Scalar_gui_update(Initialize, SynchMode, MyHandle,StrutturaDatiFull,PulseIDMatrix,TimeStampsMatrix,AbsoluteEventCounterMatrix,ProfileBuffer,SynchProfilePVs,NotSynchProfilePVs,AdditionalNonStandardPVsMatrices,FiltersBuffer,ScalarsBuffer,ScanBuffer,AcquisitionBufferCycle,AcquisitionTotalSynchronousEvents,AcquisitionBufferNextWrittenElement,AcquisitionBufferLastWrittenElement)

if(Initialize)
    CurrentDataStructure = get(MyHandle.StrutturaDatiAttuale,'userdata');
    if(isequal(CurrentDataStructure,StrutturaDatiFull))
        
    else
        set(MyHandle.StrutturaDatiAttuale,'userdata',StrutturaDatiFull);
        LIST_OF_FILTERS{1}='Filter OFF';
        for II=1:StrutturaDatiFull.FilterNumber
            LIST_OF_FILTERS{end+1}=StrutturaDatiFull.FilterNames{II};
        end
        set(MyHandle.Filter1,'string',LIST_OF_FILTERS);
        set(MyHandle.Filter2,'string',LIST_OF_FILTERS);
        
        LIST_OF_2DARRAYS{1}='Off';
        
        for II=1:StrutturaDatiFull.Number_of_2Darrays
            LIST_OF_2DARRAYS{end+1}=StrutturaDatiFull.Names_of_2Darrays{II};
        end
        
        LIST_OF_SCALARS{1}='OFF';
        for II=1:numel(StrutturaDatiFull.ScalarNames)
            LIST_OF_SCALARS{end+1}=StrutturaDatiFull.ScalarNames{II};
        end
        
        set(MyHandle.Y_SEL,'string',LIST_OF_SCALARS);set(MyHandle.Y_SEL,'value',1);
        
        set(MyHandle.V_SEL,'string',LIST_OF_2DARRAYS);set(MyHandle.V_SEL,'value',1);
        petizione=get(MyHandle.IdatiStanQua,'userdata');
        if(~isnan(petizione.lim_x1)), set(MyHandle.e_x1,'string',num2str(petizione.lim_x1)); else set(MyHandle.e_x1,'string',num2str([])); end
        if(~isnan(petizione.lim_x2)), set(MyHandle.e_x2,'string',num2str(petizione.lim_x2)); else set(MyHandle.e_x2,'string',num2str([])); end
        if(~isnan(petizione.lim_y1)), set(MyHandle.e_y1,'string',num2str(petizione.lim_y1)); else set(MyHandle.e_y1,'string',num2str([])); end
        if(~isnan(petizione.lim_y2)), set(MyHandle.e_y2,'string',num2str(petizione.lim_y2)); else set(MyHandle.e_y2,'string',num2str([])); end
        if(~isnan(petizione.PartitionPos))
            str='[';
            for SS=1:numel(petizione.PartitionPos)
                str=[str,num2str(petizione.PartitionPos(SS)),','];
            end
            str=[str(1:end-1),']'];
            set(MyHandle.e_Partition,'string',str);
        else
            set(MyHandle.e_Partition,'string',num2str([]));
        end
        if(~isnan(petizione.PartitionWidth))
            str='[';
            for SS=1:numel(petizione.PartitionWidth)
                str=[str,num2str(petizione.PartitionWidth(SS)),','];
            end
            str=[str(1:end-1),']'];
            set(MyHandle.e_PartitionWidth,'string',str)
        else
            set(MyHandle.e_PartitionWidth,'string',num2str([]))
        end
        
        petizione.V_SEL=[0,0];
        petizione.Y_SEL=[0,0,0];
        petizione.Filtri=[0,0];
        set(MyHandle.Filter1,'value',1);
        set(MyHandle.Filter2,'value',1);
        if(SynchMode)
            set(MyHandle.X_PID_DELAY,'visible','off');
            set(MyHandle.tpx,'visible','off');
        else
            set(MyHandle.X_PID_DELAY,'string',int2str(petizione.X_PID_DELAY));
            set(MyHandle.X_PID_DELAY,'visible','on');
            set(MyHandle.tpx,'visible','on');
        end
        if(petizione.TypeOfPlot==1)
            set(MyHandle.InfoData,'visible','on');
            set(MyHandle.axes4,'visible','off');
        elseif(petizione.TypeOfPlot==2)
            set(MyHandle.InfoData,'visible','off');
            set(MyHandle.axes4,'visible','on');
        end
        
        if(petizione.b_autoX)
            set(MyHandle.b_autoX,'backgroundcolor',[0,1,0]);
        else
            set(MyHandle.b_autoX,'backgroundcolor',[0.7,0.7,0.7]);
        end
        if(petizione.b_autoY)
            set(MyHandle.b_autoY,'backgroundcolor',[0,1,0]);
        else
            set(MyHandle.b_autoY,'backgroundcolor',[0.7,0.7,0.7]);
        end
        set(MyHandle.PLAY,'value',petizione.PLAY)
        set(MyHandle.e_Condition,'string',num2str(petizione.Condition));
        set(MyHandle.CalibLinear,'string',num2str(petizione.calib));
        set(MyHandle.CalibCenter,'string',num2str(petizione.center));
        set(MyHandle.CalibLinearY,'string',num2str(petizione.calibY));
        set(MyHandle.CalibCenterY,'string',num2str(petizione.centerY));
        set(MyHandle.ShowAverageON,'value',petizione.ShowAVGLASTON);
        set(MyHandle.HMAVG,'string',num2str(petizione.HMAVG));
        set(MyHandle.IdatiStanQua,'userdata',petizione);
    end
else
    petizione=get(MyHandle.IdatiStanQua,'userdata');
    % da controllare se e' il primo giro, se no... insomma un caos
    if(SynchMode==1)
        %save UNO
        if(any(petizione.Filtri))
            if(~petizione.Filtri(1))
                TENUTI=FiltersBuffer{petizione.Filtri(2)+1};
            elseif(~petizione.Filtri(2))
                TENUTI=FiltersBuffer{petizione.Filtri(1)+1};
            else
                TENUTI=FiltersBuffer{petizione.Filtri(1)+1} & FiltersBuffer{petizione.Filtri(2)+1};
            end
        else
            TENUTI=FiltersBuffer{1};
        end
        if(isempty(TENUTI) || (~petizione.V_SEL(1)) )
            return
        end
        %save DUE
        [SA,SB,SC]=size(ProfileBuffer{petizione.V_SEL(2)});
        USE_Y=1;
        switch(petizione.Y_SEL(1))
            case 0
                USE_Y=0;
            case 1
                DATI_Y=SynchProfilePVs(TENUTI,petizione.Y_SEL(3));
            case 2
                DATI_Y=AdditionalNonStandardPVsMatrices{petizione.Y_SEL(2)}(TENUTI,petizione.Y_SEL(3));
            case 3
                DATI_Y=NotSynchProfilePVs(TENUTI,petizione.Y_SEL(3));
            case 4
                DATI_Y=ScalarsBuffer(TENUTI,petizione.Y_SEL(3));
            case 5
                DATI_Y= PulseIDMatrix(TENUTI);
            case 6
                DATI_Y= TimeStampsMatrix(TENUTI);
            case 7
                DATI_Y= AbsoluteEventCounterMatrix(TENUTI);
            case 8
                DATI_Y= ScanBuffer(TENUTI,petizione.Y_SEL(3));
        end
        
        if(petizione.ShowAVGLASTON)
            if(sum(TENUTI)<=petizione.HMAVG)
                UltimiN=find(TENUTI);
            else
                [~,IB]=sort(AbsoluteEventCounterMatrix(TENUTI),'descend');
                UltimiN=IB(1:petizione.HMAVG);
            end
            if(USE_Y)
                DATI_Y=DATI_Y(UltimiN);
            end
            %MEDIA=mean(ProfileBuffer{petizione.V_SEL(2)}(UltimiN,:),1); 
        elseif(USE_Y)
            UltimiN=find(TENUTI);
        else
            VALMAX = max(AbsoluteEventCounterMatrix(TENUTI));
            if(~isempty(VALMAX))
              UltimiN = find(AbsoluteEventCounterMatrix==VALMAX);
            else
              return
            end
        end
        
        if(~isempty(petizione.calib))
            ASSE=((1:SB)-SB/2)*petizione.calib;
            if(~isempty(petizione.center))
                ASSE=ASSE+petizione.center ;
            end
        else
            ASSE=1:SA;
        end
        
        if(~isempty(petizione.calibY))
            ASSEY=((1:SA)-SA/2)*petizione.calibY;
            if(~isempty(petizione.centerY))
                ASSEY=ASSEY+petizione.centerY ;
            end
        else
            ASSEY=1:SB;
        end
        %save TEMP -v7.3
        %save TEMPXX
        % Se... se... se...
        if(~USE_Y) %non usare le partizioni in Y
          %save TEMP -v7.3
            %imagesc(ASSE,ASSEY,mean(ProfileBuffer{petizione.V_SEL(2)}(:,:,UltimiN),3),'parent',MyHandle.axes1);
            imagesc(ASSEY,ASSE,mean(ProfileBuffer{petizione.V_SEL(2)}(:,:,UltimiN),3).','parent',MyHandle.axes1);
            colorbar('peer',MyHandle.axes1)
        else %usa le partizioni in Y
            if(any(isnan(petizione.PartitionWidth)) || any(isnan(petizione.PartitionPos)))
                return
            end
            if(isscalar(petizione.PartitionWidth))
                PartitionWidth=ones(size(petizione.PartitionPos))*petizione.PartitionWidth;
                PartitionPos=petizione.PartitionPos;
            elseif(isscalar(petizione.PartitionPos))
                PartitionPos=ones(size(petizione.PartitionWidth))*petizione.PartitionPos;
                PartitionWidth=petizione.PartitionWidth;
            else
                if(length(petizione.PartitionWidth)~=length(petizione.PartitionPos))
                    return
                else
                    PartitionWidth=petizione.PartitionWidth;
                    PartitionPos=petizione.PartitionPos;
                end
            end
            PW=PartitionWidth(petizione.Condition);
            PP=PartitionPos(petizione.Condition);
            %save DUE
            KE=find(abs(DATI_Y-PP) <= PW/2);
            if(isempty(KE)), return; end
            ListString={};
            MEDIA=mean(ProfileBuffer{petizione.V_SEL(2)}(:,:,UltimiN(KE)),3);
            ListString{end+1} = ['P: ',num2str(PP- PW/2 ),' , ' num2str(PP+ PW/2 )];
            ListString{end+1} = ['Events = ',num2str(length(KE))];
            set(MyHandle.InfoData,'string',ListString);
            imagesc(ASSE,ASSEY,MEDIA,'parent',MyHandle.axes1);
        end
        if(petizione.PLAY)
            MAXP=get(MyHandle.e_Condition,'userdata');
            petizione.Condition=petizione.Condition+1;
            if(petizione.Condition>MAXP)
                petizione.Condition=1;
            end
            set(MyHandle.e_Condition,'string',int2str(petizione.Condition));
            set(MyHandle.IdatiStanQua,'userdata',petizione);
        end
        
        CurrLimX=[min(ASSEY),max(ASSEY)];
        if(~petizione.b_autoX)
            if(~isnan(petizione.lim_x1)), CurrLimX(1)=petizione.lim_x1; end
            if(~isnan(petizione.lim_x2)), CurrLimX(2)=petizione.lim_x2; end
        end
        
        CurrLimY=[min(ASSE),max(ASSE)];
        if(~petizione.b_autoY)
            if(~isnan(petizione.lim_y1)), CurrLimY(1)=petizione.lim_y1; end
            if(~isnan(petizione.lim_y2)), CurrLimY(2)=petizione.lim_y2; end
            
        end
        xlim(MyHandle.axes1,CurrLimX);
        ylim(MyHandle.axes1,CurrLimY);
    elseif(petizione.V_SEL(1))
        
        %         hold(MyHandle.axes1,'on');
        
        [SA,SB,SC]=size(ProfileBuffer{petizione.V_SEL(2)});
        V_PID=mod(TimeStampsMatrix{petizione.V_SEL(2)} + petizione.X_PID_DELAY ,131040);
        V_ABS=AcquisitionBufferCycle{petizione.V_SEL(2)};
        USE_Y=1;
        switch(petizione.Y_SEL(1))
            case 0
                USE_Y=0;
            case 1
                if(ScalarsBuffer)
                    DATI_Y=SynchProfilePVs(:,petizione.Y_SEL(3));
                    PID_Y=mod((PulseIDMatrix{1}+ 0),131040);
                    ABS_Y=AbsoluteEventCounterMatrix{1};
                else
                    DATI_Y=SynchProfilePVs(:,petizione.Y_SEL(3));
                    PID_Y=mod((PulseIDMatrix{1}(:,petizione.Y_SEL(3))+ 0),131040);
                    ABS_Y=AbsoluteEventCounterMatrix{1}(:,petizione.Y_SEL(3));
                end
            case 2
                DATI_Y=AdditionalNonStandardPVsMatrices{petizione.Y_SEL(2)}(:,petizione.Y_SEL(3));
                PID_Y=mod((PulseIDMatrix{2}(:,petizione.Y_SEL(2))+ 0),131040);
                ABS_Y=AbsoluteEventCounterMatrix{2}(:,petizione.Y_SEL(2));
            case 3
                DATI_Y=NotSynchProfilePVs(:,petizione.Y_SEL(3));
                PID_Y=mod((PulseIDMatrix{3}(:,petizione.Y_SEL(3))+ 0),131040);
                ABS_Y=AbsoluteEventCounterMatrix{3}(:,petizione.Y_SEL(3));
            case 4
                USE_Y=0;
            case 5
                USE_Y=0;
            case 6
                USE_Y=0;
            case 7
                USE_Y=0;
            case 8
                DATI_Y= ScanBuffer(:,petizione.Y_SEL(3));
                PID_Y=mod((PulseIDMatrix{1}(8,petizione.Y_SEL(3))+ 0),131040);
                ABS_Y=AbsoluteEventCounterMatrix{8}(:,petizione.Y_SEL(3));
        end
        
        if(USE_Y)
            [~,DY,DV]=intersect(PID_Y,V_PID,'stable');
            if(any(isnan(petizione.PartitionWidth)) || any(isnan(petizione.PartitionPos)) || isempty(petizione.PartitionWidth) || isempty(petizione.PartitionPos))
                cla(MyHandle.axes1,'reset')
                return
            end
        else
            [~,DV,~]=intersect(V_PID,V_PID,'stable');
        end
        %save TEMPOREX -v7.3
        %length(DV)
        %petizione.ShowAVGLASTON
        %petizione.HMAVG
        
        if(USE_Y)
            if(petizione.ShowAVGLASTON) %average only on last subset
                if(length(DV)<=petizione.HMAVG) %calculate average on last... but do not use Y
                    DATI_Y=DATI_Y(DY);
                else
                    [~,IB]=sort(V_ABS(DV),'descend');
                    V_PID(DV(IB((petizione.HMAVG+1):end)))=NaN;
                    [~,DY,DV]=intersect(PID_Y,V_PID,'stable');
                    DATI_Y=DATI_Y(DY);
                end
            else %average on all
                DATI_Y=DATI_Y(DY);
            end
        else
            if(petizione.ShowAVGLASTON) %average only on last subset
                if(DV<petizione.HMAVG) %calculate average on last... but do not use Y
                    
                else
                    [~,IB]=sort(V_ABS(DV),'descend');
                    DV=DV(IB(1:petizione.HMAVG));
                end
            else %Show Only Last One
                [~,DV]=max(V_ABS);
            end
        end
              
        if(~isempty(petizione.calib))
            ASSE=((1:SB)-SB/2)*petizione.calib;
            if(~isempty(petizione.center))
                ASSE=ASSE+petizione.center ;
            end
        else
            ASSE=1:SB;
        end
        
        if(~isempty(petizione.calibY))
            ASSEY=((1:SA)-SA/2)*petizione.calibY;
            if(~isempty(petizione.centerY))
                ASSEY=ASSEY+petizione.centerY ;
            end
        else
            ASSEY=1:SA;
        end
        %         %save TEMP -v7.3
        %         %save TEMPXX
        
        if(~USE_Y) %non usare le partizioni in Y
            imagesc(ASSE,ASSEY,mean(ProfileBuffer{petizione.V_SEL(2)}(:,:,DV),3),'parent',MyHandle.axes1);
            colorbar('peer',MyHandle.axes1)
        else %usa le partizioni in Y
            if(isscalar(petizione.PartitionWidth))
                PartitionWidth=ones(size(petizione.PartitionPos))*petizione.PartitionWidth;
                PartitionPos=petizione.PartitionPos;
            elseif(isscalar(petizione.PartitionPos))
                PartitionPos=ones(size(petizione.PartitionWidth))*petizione.PartitionPos;
                PartitionWidth=petizione.PartitionWidth;
            else
                if(length(petizione.PartitionWidth)~=length(petizione.PartitionPos))
                    return
                else
                    PartitionWidth=petizione.PartitionWidth;
                    PartitionPos=petizione.PartitionPos;
                end
            end
            PW=PartitionWidth(petizione.Condition);
            PP=PartitionPos(petizione.Condition);
            %             %save DUE
            KE=find(abs(DATI_Y-PP) <= PW/2);
            if(isempty(KE))
                ListString={};
                ListString{end+1} = ['P: ',num2str(PP- PW/2 ),' , ' num2str(PP+ PW/2 )];
                ListString{end+1} = ['Events = ','0'];
                set(MyHandle.InfoData,'string',ListString);
                return
                
            end
            ListString={};
            MEDIA=mean(ProfileBuffer{petizione.V_SEL(2)}(:,:,DV(KE)),3);
            ListString{end+1} = ['P: ',num2str(PP- PW/2 ),' , ' num2str(PP+ PW/2 )];
            ListString{end+1} = ['Events = ',num2str(length(KE))];
            set(MyHandle.InfoData,'string',ListString);
            imagesc(ASSE,ASSEY,MEDIA,'parent',MyHandle.axes1);
            
            if(petizione.PLAY)
                MAXP=get(MyHandle.e_Condition,'userdata');
                petizione.Condition=petizione.Condition+1;
                if(petizione.Condition>MAXP)
                    petizione.Condition=1;
                end
                set(MyHandle.e_Condition,'string',int2str(petizione.Condition));
                set(MyHandle.IdatiStanQua,'userdata',petizione);
            end
            
        end
        CurrLimX=[min(ASSE),max(ASSE)];
        if(~petizione.b_autoX)
            if(~isnan(petizione.lim_x1)), CurrLimX(1)=petizione.lim_x1; end
            if(~isnan(petizione.lim_x2)), CurrLimX(2)=petizione.lim_x2; end
        end
        CurrLimY=[min(ASSEY),max(ASSEY)];
        if(~petizione.b_autoY)
            if(~isnan(petizione.lim_y1)), CurrLimY(1)=petizione.lim_y1; end
            if(~isnan(petizione.lim_y2)), CurrLimY(2)=petizione.lim_y2; end
        end
        xlim(MyHandle.axes1,CurrLimX);
        ylim(MyHandle.axes1,CurrLimY);
        
        
    end
    
    %ProfileBuffer{petizione.V_SEL(2)}
    
    %         AbsoluteEventCounterMatrix <-AbsoluteEventCounterMatrix
    %         AbsoluteEventCounterProfiles <-AcquisitionBufferCycle
    %         FullPulseIDMatrix <- PulseIDMatrix
    %         FullPulseIDProfiles <- TimeStampsMatrix
    
    
    
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
        copyobj(MyHandle.axes1,NuovaFigura);
        AXNF=get(NuovaFigura,'children');
        title(AXNF,titlestring)
        IV=get(MyHandle.V_SEL,'value');
        IS=get(MyHandle.V_SEL,'string');
        xlabel(AXNF,IS{IV});
        %        IV=get(MyHandle.Y_SEL,'value');
        %        IS=get(MyHandle.Y_SEL,'string');
        %        ylabel(AXNF,IS{IV});
        
        try
            util_printLog(NuovaFigura);
        end
        petizione.logbook_only=0;
        set(MyHandle.IdatiStanQua,'userdata',petizione);
    end
    
    
end
