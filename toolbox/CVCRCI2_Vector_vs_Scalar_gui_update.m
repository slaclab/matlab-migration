function CVCRCI2_Vector_vs_Scalar_gui_update(Initialize, SynchMode, MyHandle,StrutturaDatiFull,PulseIDMatrix,TimeStampsMatrix,AbsoluteEventCounterMatrix,ProfileBuffer,SynchProfilePVs,NotSynchProfilePVs,AdditionalNonStandardPVsMatrices,FiltersBuffer,ScalarsBuffer,ScanBuffer,AcquisitionBufferCycle,AcquisitionTotalSynchronousEvents,AcquisitionBufferNextWrittenElement,AcquisitionBufferLastWrittenElement)
persistent COLORMATRIX
if(Initialize)
    
    COLORMATRIX=[0,0,0;1,0,0;0,0,1;0,1,0;0,1,1;1,0,1;1,1,0;1/2,1/2,1/2;1,1/2,1/2;1/2,1,1/2;1/2,1/2,1;0,1/2,1;1/2,0,1;1,0,1/2;1,1/2,0;0,1,1/2;1/2,1,0;1/3,1/3,1/3,;2/3,2/3,2/3;0,2/3,1/2];
    CurrentDataStructure = get(MyHandle.StrutturaDatiAttuale,'userdata');
    if(isequal(CurrentDataStructure,StrutturaDatiFull))
        
    else
        petizione=get(MyHandle.IdatiStanQua,'userdata');
        set(MyHandle.StrutturaDatiAttuale,'userdata',StrutturaDatiFull);
        LIST_OF_FILTERS{1}='Filter OFF';
        for II=1:StrutturaDatiFull.FilterNumber
            LIST_OF_FILTERS{end+1}=StrutturaDatiFull.FilterNames{II};
        end
        set(MyHandle.Filter1,'string',LIST_OF_FILTERS);
        set(MyHandle.Filter2,'string',LIST_OF_FILTERS);
        
        if(get(MyHandle.Filter1,'value') > numel(LIST_OF_FILTERS))
            petizione.Filtri(1)=0; set(MyHandle.Filter1,'value',1);
        end
        if(get(MyHandle.Filter2,'value') > numel(LIST_OF_FILTERS))
            petizione.Filtri(2)=0; set(MyHandle.Filter2,'value',1);
        end
        
        LIST_OF_VECTORS{1}='Off'; 
        for II=1:StrutturaDatiFull.Number_of_vectors
            LIST_OF_VECTORS{end+1}=StrutturaDatiFull.Names_of_vectors{II};
        end
        set(MyHandle.V_SEL,'string',LIST_OF_VECTORS);
        if(get(MyHandle.V_SEL,'value') > numel(LIST_OF_VECTORS))
            set(MyHandle.V_SEL,'value',1);
            petizione.V_SEL=[0,0];
        else %reset it as the current value...
            VAL=get(MyHandle.V_SEL,'value');
            if(VAL==1)
               petizione.V_SEL=[0,0];
            else
               petizione.V_SEL=[VAL-1,StrutturaDatiFull.Position_of_vectors_in_Profiles(VAL-1)];
            end
        end
        
        LIST_OF_SCALARS{1}='OFF';
        for II=1:numel(StrutturaDatiFull.ScalarNames)
            LIST_OF_SCALARS{end+1}=StrutturaDatiFull.ScalarNames{II};
        end
        set(MyHandle.Y_SEL,'string',LIST_OF_SCALARS);
        
        if(get(MyHandle.Y_SEL,'value') > numel(LIST_OF_SCALARS))
            set(MyHandle.Y_SEL,'value',1);
            petizione.Y_SEL=[0,0,0];
        else %reset it as the current value...
            VAL=get(MyHandle.Y_SEL,'value');
            if(VAL==1)
               petizione.Y_SEL=[0,0,0];
            else
               petizione.Y_SEL=StrutturaDatiFull.ScalarWhereToBeFound(VAL-1,:);
            end
        end
    
        if(~isnan(petizione.lim_x1)), set(MyHandle.e_x1,'string',num2str(petizione.lim_x1)); else set(MyHandle.e_x1,'string',num2str([])); end
        if(~isnan(petizione.lim_x2)), set(MyHandle.e_x2,'string',num2str(petizione.lim_x2)); else set(MyHandle.e_x2,'string',num2str([])); end
        if(~isnan(petizione.lim_y1)), set(MyHandle.e_y1,'string',num2str(petizione.lim_y1)); else set(MyHandle.e_y1,'string',num2str([])); end
        if(~isnan(petizione.lim_y2)), set(MyHandle.e_y2,'string',num2str(petizione.lim_y2)); else set(MyHandle.e_y2,'string',num2str([])); end
        if(~isnan(petizione.PartitionPos))
            str='[';
            for XX=1:numel(petizione.PartitionPos)
                str=[str,',',num2str(petizione.PartitionPos(XX))];
            end
            str=[str,']'];
            set(MyHandle.e_Partition,'string',str); 
        else
            set(MyHandle.e_Partition,'string',num2str([]));
        end
        if(~isnan(petizione.PartitionWidth))
            str='[';
            for XX=1:numel(petizione.PartitionWidth)
                str=[str,',',num2str(petizione.PartitionWidth(XX))];
            end
            str=[str,']'];
            set(MyHandle.e_PartitionWidth,'string',str);
        else
            set(MyHandle.e_PartitionWidth,'string',num2str([]));
        end
        
        if(SynchMode)
            set(MyHandle.X_PID_DELAY,'visible','off');
            set(MyHandle.tpx,'visible','off');
        else
            set(MyHandle.X_PID_DELAY,'string',int2str(petizione.X_PID_DELAY));
            set(MyHandle.X_PID_DELAY,'visible','on');
            set(MyHandle.tpx,'visible','on');
        end
        if(petizione.TypeOfPlot==1)
            set(MyHandle.InfoData,'visible','off');
            set(MyHandle.axes4,'visible','on');
        elseif((petizione.TypeOfPlot==2) || (petizione.TypeOfPlot==3))
            set(MyHandle.InfoData,'visible','on');
            set(MyHandle.axes4,'visible','off');
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
        
        set(MyHandle.e_binsy,'string',num2str(petizione.binsy));
        set(MyHandle.CalibLinear,'string',num2str(petizione.calib));
        set(MyHandle.CalibCenter,'string',num2str(petizione.center));
        set(MyHandle.TOM,'value',petizione.MomentsON);
        set(MyHandle.TOFWHM,'value',petizione.FWHMON);
        set(MyHandle.TOPEAK,'value',petizione.PEAKON);
        set(MyHandle.ShowAverageON,'value',petizione.ShowAVGLASTON);
        set(MyHandle.HMAVG,'string',num2str(petizione.HMAVG));
        set(MyHandle.TypeOfPlot,'value',petizione.TypeOfPlot);
        set(MyHandle.IdatiStanQua,'userdata',petizione);
    end
else
  if(isempty(COLORMATRIX))
    COLORMATRIX=[0,0,0;1,0,0;0,0,1;0,1,0;0,1,1;1,0,1;1,1,0;1/2,1/2,1/2;1,1/2,1/2;1/2,1,1/2;1/2,1/2,1;0,1/2,1;1/2,0,1;1,0,1/2;1,1/2,0;0,1,1/2;1/2,1,0;1/3,1/3,1/3,;2/3,2/3,2/3;0,2/3,1/2];
  end
    petizione=get(MyHandle.IdatiStanQua,'userdata');
    % da controllare se e' il primo giro, se no... insomma un caos
    if(SynchMode==1)
        %disp('update in synch mode')
        cla(MyHandle.axes1)
        hold(MyHandle.axes1,'on');
        
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
        if(isempty(TENUTI) || (~petizione.V_SEL(1)) || (~petizione.Y_SEL(1)))
            return
        end
        
        [SA,SB]=size(ProfileBuffer{petizione.V_SEL(2)});
        switch(petizione.Y_SEL(1))
            case 0
                return
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
            DATI_Y=DATI_Y(UltimiN);
            MEDIA=mean(ProfileBuffer{petizione.V_SEL(2)}(UltimiN,:),1);
        else
            UltimiN = find(TENUTI);
        end
        
        if(~isempty(petizione.calib))
            ASSE=((1:SB)-SB/2)*petizione.calib;
            if(~isempty(petizione.center))
                ASSE=ASSE+petizione.center ;
            end
        else
            ASSE=1:SB;
        end
        %save TEMP -v7.3
        if(isempty(DATI_Y))
            return
        end
        if(petizione.TypeOfPlot==1) %L-Plot.
            MY(1) = min(DATI_Y); MY(2) =max(DATI_Y);
            if(~petizione.b_autoY)
                if(~isnan(petizione.lim_y1)), MY(1)=petizione.lim_y1; end
                if(~isnan(petizione.lim_y2)), MY(2)=petizione.lim_y2; end
                %ylim(MyHandle.axes1,CurrLimY);
            end
            if(any(isnan(MY)) || MY(1)==MY(2))
                return
            end
            Matrice=zeros(petizione.binsy+1,SB);
            INDICI=round(petizione.binsy*(DATI_Y-MY(1))/(MY(2)-MY(1)) )+1;
            for XX=1:petizione.binsy
                Matrice(XX,:)=mean(ProfileBuffer{petizione.V_SEL(2)}(UltimiN(INDICI==XX),:),1);
            end
            hold(MyHandle.axes1,'off');
            imagesc(ASSE,MY,Matrice,'parent',MyHandle.axes1);
            set(MyHandle.axes1,'Ydir','normal');
            YLIM=ylim(MyHandle.axes1);
            colorbar('peer',MyHandle.axes1);
            [N,X] = hist(DATI_Y((DATI_Y>=MY(1)) & (DATI_Y<=MY(2)) ),petizione.binsy+1);
            barh(MyHandle.axes4,X,N);
            
            ylim(MyHandle.axes4,YLIM);
            
        elseif((petizione.TypeOfPlot==2) || (petizione.TypeOfPlot==3))
            cla(MyHandle.axes1,'reset')
            hold(MyHandle.axes1,'on');
            
            if(petizione.TypeOfPlot==2)
                if(any(isnan(petizione.PartitionWidth)) || any(isnan(petizione.PartitionPos)))
                    return
                end
                if(isscalar(petizione.PartitionWidth))
                    PW=ones(size(petizione.PartitionPos))*petizione.PartitionWidth;
                    PP=petizione.PartitionPos;
                elseif(isscalar(petizione.PartitionPos))
                    PP=ones(size(petizione.PartitionWidth))*petizione.PartitionPos;
                    PW=petizione.PartitionWidth;
                else
                    if(length(petizione.PartitionWidth)~=length(petizione.PartitionPos))
                        return
                    else
                        PW=petizione.PartitionWidth;
                        PP=petizione.PartitionPos;
                    end
                end
            elseif(petizione.TypeOfPlot==3)
                PP=unique(DATI_Y);
                PP=PP(~isnan(PP));
                PW=ones(size(PP))*min(abs(diff(PP)))/8+eps;
                if(isempty(PP))
                    return
                end
            end
            ListString={};
            Legend={};
            %save TEMP -v7.3
            for TT=1:min(length(PW),20);
                KE=find(abs(DATI_Y-PP(TT)) <= PW(TT)/2);
                if(~isempty(KE))
                    MEDIA=mean(ProfileBuffer{petizione.V_SEL(2)}(UltimiN(KE),:),1);
                    ListString{end+1} = ['P: ',num2str(PP(TT)- PW(TT)/2 ),' , ' num2str(PP(TT)+ PW(TT)/2 )];
                    ListString{end+1} = ['Events = ',num2str(length(KE))];
                    ListString{end+1} = ['AVG S. = ',num2str(mean(DATI_Y(KE)))];
                    Legend{end+1}=ListString{end};
                    if(petizione.MomentsON)
                        ME=ASSE*MEDIA.'/sum(MEDIA);
                        ST=sqrt(ASSE.^2*MEDIA.'/sum(MEDIA) - ME^2);
                        ListString{end+1} = ['1st M. = ',num2str(ME)];
                        ListString{end+1} = ['std = ',num2str(ST)];
                    end
                    if(petizione.FWHMON)
                        [MA,MB]=max(MEDIA);
                        LP=find(MEDIA>MA/2,1,'first');
                        MP=find(MEDIA>MA/2,1,'last');
                        if((LP==1) || (MP==SB))
                            FWHM=NaN;
                        else
                            if(isempty(petizione.calib))
                                FWHM=MP-LP+1;
                            else
                                FWHM=(MP-LP+1)*petizione.calib;
                            end
                        end
                        ListString{end+1} = ['FWHM = ',num2str(FWHM)];
                    end
                    if(petizione.PEAKON)
                        [MA,MB]=max(MEDIA);
                        ListString{end+1} = ['Peak = ',num2str(MA)];
                        ListString{end+1} = ['Peak Pos = ',num2str(ASSE(MB))];
                    end
                    ListString{end+1}='';
                    plot(MyHandle.axes1,ASSE,MEDIA,'Color',COLORMATRIX(TT,:));
                end
            end
            set(MyHandle.InfoData,'string',ListString);
            legend(MyHandle.axes1,Legend);
        end
        
        CurrLimX=xlim(MyHandle.axes1);
        if(~petizione.b_autoX)
            if(~isnan(petizione.lim_x1)), CurrLimX(1)=petizione.lim_x1; end
            if(~isnan(petizione.lim_x2)), CurrLimX(2)=petizione.lim_x2; end
            xlim(MyHandle.axes1,CurrLimX);
        end
        CurrLimY=ylim(MyHandle.axes1);
        if(~petizione.b_autoY)
            if(~isnan(petizione.lim_y1)), CurrLimY(1)=petizione.lim_y1; end
            if(~isnan(petizione.lim_y2)), CurrLimY(2)=petizione.lim_y2; end
            ylim(MyHandle.axes1,CurrLimY);
        end
    elseif(petizione.V_SEL(1) && petizione.Y_SEL(1))
        cla(MyHandle.axes1,'reset')
        hold(MyHandle.axes1,'on');
        
        
        [SA,SB]=size(ProfileBuffer{petizione.V_SEL(2)});
        V_PID=mod(TimeStampsMatrix{petizione.V_SEL(2)} + petizione.X_PID_DELAY ,131040);
        V_ABS=AcquisitionBufferCycle{petizione.V_SEL(2)};
        
        switch(petizione.Y_SEL(1))
            case 0
                return
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
                return
            case 5
                return
            case 6
                return
            case 7
                return
            case 8
                DATI_Y= ScanBuffer(:,petizione.Y_SEL(3));
                PID_Y=mod((PulseIDMatrix{1}(8,petizione.Y_SEL(3))+ 0),131040);
                ABS_Y=AbsoluteEventCounterMatrix{8}(:,petizione.Y_SEL(3));
        end
        
        [~,DY,DV]=intersect(PID_Y,V_PID);
        
        
        if(petizione.ShowAVGLASTON)
            if(length(DV)<=petizione.HMAVG)
                %TUTTI
            else
                [~,IB]=sort(V_ABS(DV),'descend');
                V_PID=V_PID(DV(IB(1:petizione.HMAVG)));
            end
            [~,DY,DV]=intersect(PID_Y,V_PID);
        else
            %UltimiN = find(TENUTI);
        end
        
        DATI_Y=DATI_Y(DY);
        
        if(~isempty(petizione.calib))
            ASSE=((1:SB)-SB/2)*petizione.calib;
            if(~isempty(petizione.center))
                ASSE=ASSE+petizione.center ;
            end
        else
            ASSE=1:SB;
        end
        
        if(petizione.TypeOfPlot==1) %L-Plot.
            MY(1) = min(DATI_Y); MY(2) =max(DATI_Y);
            if(~petizione.b_autoY)
                if(~isnan(petizione.lim_y1)), MY(1)=petizione.lim_y1; end
                if(~isnan(petizione.lim_y2)), MY(2)=petizione.lim_y2; end
                %xlim(MyHandle.axes1,CurrLimY);
            end
            if(any(isnan(MY)) || MY(1)==MY(2))
                return
            end
            Matrice=zeros(petizione.binsy+1,SB);
            INDICI=round(petizione.binsy*(DATI_Y-MY(1))/(MY(2)-MY(1)) )+1;
            for XX=1:petizione.binsy
                Matrice(XX,:)=mean(ProfileBuffer{petizione.V_SEL(2)}(DV(INDICI==XX),:),1);
            end
            hold(MyHandle.axes1,'off');
            imagesc(ASSE,MY,Matrice,'parent',MyHandle.axes1);
            set(MyHandle.axes1,'Ydir','normal');
            YLIM=ylim(MyHandle.axes1);
            colorbar('peer',MyHandle.axes1);
            [N,X] = hist(DATI_Y((DATI_Y>=MY(1)) & (DATI_Y<=MY(2)) ),petizione.binsy+1);
            barh(MyHandle.axes4,X,N);
            
            ylim(MyHandle.axes4,YLIM);
        elseif((petizione.TypeOfPlot==2) || (petizione.TypeOfPlot==3))
            
            if(petizione.TypeOfPlot==2)
                
                if(any(isnan(petizione.PartitionWidth)) || any(isnan(petizione.PartitionPos)))
                    return
                end
                if(isscalar(petizione.PartitionWidth))
                    PW=ones(size(petizione.PartitionPos))*petizione.PartitionWidth;
                    PP=petizione.PartitionPos;
                elseif(isscalar(petizione.PartitionPos))
                    PP=ones(size(petizione.PartitionWidth))*petizione.PartitionPos;
                    PW=petizione.PartitionWidth;
                else
                    if(length(petizione.PartitionWidth)~=length(petizione.PartitionPos))
                        return
                    else
                        PW=petizione.PartitionWidth;
                        PP=petizione.PartitionPos;
                    end
                end
            
            elseif(petizione.TypeOfPlot==3)
                PP=unique(DATI_Y);
                PP=PP(~isnan(PP));
                PW=ones(size(PP))*min(abs(diff(PP)))/8+eps;
                if(isempty(PP))
                    return
                end
            end
            
            ListString={};
            Legend={};
            %save TEMP -v7.3
            for TT=1:min(length(PW),20);
                KE=find(abs(DATI_Y-PP(TT)) <= PW(TT)/2);
                if(~isempty(KE))
                    MEDIA=mean(ProfileBuffer{petizione.V_SEL(2)}(DV(KE),:),1);
                    ListString{end+1} = ['P: ',num2str(PP(TT)- PW(TT)/2 ),' , ' num2str(PP(TT)+ PW(TT)/2 )];
                    ListString{end+1} = ['Events = ',num2str(length(KE))];
                    ListString{end+1} = ['AVG S. = ',num2str(mean(DATI_Y(KE)))];
                    Legend{end+1}=ListString{end};
                    if(petizione.MomentsON)
                        ME=ASSE*MEDIA.'/sum(MEDIA);
                        ST=sqrt(ASSE.^2*MEDIA.'/sum(MEDIA) - ME^2);
                        ListString{end+1} = ['1st M. = ',num2str(ME)];
                        ListString{end+1} = ['std = ',num2str(ST)];
                    end
                    if(petizione.FWHMON)
                        [MA,MB]=max(MEDIA);
                        LP=find(MEDIA>MA/2,1,'first');
                        MP=find(MEDIA>MA/2,1,'last');
                        if((LP==1) || (MP==SB))
                            FWHM=NaN;
                        else
                            if(isempty(petizione.calib))
                                FWHM=MP-LP+1;
                            else
                                FWHM=(MP-LP+1)*petizione.calib;
                            end
                        end
                        ListString{end+1} = ['FWHM = ',num2str(FWHM)];
                    end
                    if(petizione.PEAKON)
                        [MA,MB]=max(MEDIA);
                        ListString{end+1} = ['Peak = ',num2str(MA)];
                        ListString{end+1} = ['Peak Pos = ',num2str(ASSE(MB))];
                    end
                    ListString{end+1}='';
                    plot(MyHandle.axes1,ASSE,MEDIA,'Color',COLORMATRIX(TT,:));
                end
            end
            set(MyHandle.InfoData,'string',ListString);
            legend(MyHandle.axes1,Legend);
        end
        
        CurrLimX=xlim(MyHandle.axes1);
        if(~petizione.b_autoX)
            if(~isnan(petizione.lim_x1)), CurrLimX(1)=petizione.lim_x1; end
            if(~isnan(petizione.lim_x2)), CurrLimX(2)=petizione.lim_x2; end
            xlim(MyHandle.axes1,CurrLimX);
        end
        CurrLimY=ylim(MyHandle.axes1);
        if(~petizione.b_autoY)
            if(~isnan(petizione.lim_y1)), CurrLimY(1)=petizione.lim_y1; end
            if(~isnan(petizione.lim_y2)), CurrLimY(2)=petizione.lim_y2; end
            ylim(MyHandle.axes1,CurrLimY);
        end
        
        
          
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
        %save TRYANDERROR -v7.3
        NuovaFigura=figure;
        copyobj(MyHandle.axes1,NuovaFigura);
        if(petizione.TypeOfPlot==1)
          copyobj(MyHandle.axes4,NuovaFigura);
          CHILDREN=get(NuovaFigura,'children');
          set(CHILDREN(2),'position',[35.8 4 55 23]);
          set(CHILDREN(1),'position',[12 4 15 23]);
          title(CHILDREN(2),titlestring);
          IV1=get(MyHandle.V_SEL,'value');
          IS1=get(MyHandle.V_SEL,'string');
          xlabel(CHILDREN(2),IS1(IV1));
          IV2=get(MyHandle.Y_SEL,'value');
          IS2=get(MyHandle.Y_SEL,'string');
          ylabel(CHILDREN(1),IS2(IV2));
          xlabel(CHILDREN(1),'Counts');
          try
            str1=IS1(IV1);
            str1=str1{1};
            str2=IS2(IV2);
            str2=str2{1};
            util_printLog(NuovaFigura,'title',[str1,' vs ',str2]);
          end
        elseif((petizione.TypeOfPlot==2) || (petizione.TypeOfPlot==3))
%           
%           disp('saving tof')
          CHILDREN=get(NuovaFigura,'children');
          set(CHILDREN(1),'position',[12 4 75 23]);
          IV1=get(MyHandle.V_SEL,'value');
          IS1=get(MyHandle.V_SEL,'string');
          xlabel(CHILDREN(1),IS1(IV1));
          IV2=get(MyHandle.Y_SEL,'value');
          IS2=get(MyHandle.Y_SEL,'string');          
          ylabel(CHILDREN(1),IS2(IV2));
          utilplotstring=[];
          for HH=1:numel(ListString)
            utilplotstring=[utilplotstring,ListString{HH},char(13)];           
          end            
          title(CHILDREN(1),titlestring);
          %save TRYANDERROR3 -v7.3
          try
            str1=IS1(IV1);
            str1=str1{1};
            str2=IS2(IV2);
            str2=str2{1};
            util_printLog(NuovaFigura,'title',[str1,' sorted by ',str2],'text',utilplotstring);
          end
        end
%         AXNF=get(NuovaFigura,'children');
%         title(AXNF,titlestring)
%         IV=get(MyHandle.V_SEL,'value');
%         IS=get(MyHandle.V_SEL,'string');
%         xlabel(AXNF,IS{IV});
        %        IV=get(MyHandle.Y_SEL,'value');
        %        IS=get(MyHandle.Y_SEL,'string');
        %        ylabel(AXNF,IS{IV});
        
        
        petizione.logbook_only=0;
        set(MyHandle.IdatiStanQua,'userdata',petizione);
    end
    
    
end
