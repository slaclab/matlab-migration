function CVCRCI2_Scalar_vs_Scalars_gui_update(Initialize, SynchMode, MyHandle,StrutturaDatiFull,PulseIDMatrix,TimeStampsMatrix,AbsoluteEventCounterMatrix,ProfileBuffer,SynchProfilePVs,NotSynchProfilePVs,AdditionalNonStandardPVsMatrices,FiltersBuffer,ScalarsBuffer,ScanBuffer,AcquisitionBufferCycle,AcquisitionTotalSynchronousEvents,AcquisitionBufferNextWrittenElement,AcquisitionBufferLastWrittenElement)
if(Initialize)
    CurrentDataStructure = get(MyHandle.StrutturaDatiAttuale,'userdata');
    if(isequal(CurrentDataStructure,StrutturaDatiFull))
        
    else
        petizione=get(MyHandle.IdatiStanQua,'userdata');
        set(MyHandle.StrutturaDatiAttuale,'userdata',StrutturaDatiFull);
        CurrentColumnFormat=get(MyHandle.TabellaY,'ColumnFormat');
        LIST_OF_FILTERS{1}='Filter OFF';
        for II=1:StrutturaDatiFull.FilterNumber
            LIST_OF_FILTERS{end+1}=StrutturaDatiFull.FilterNames{II};
        end
        CurrentColumnFormat{1}=LIST_OF_FILTERS;
        CurrentColumnFormat{2}=LIST_OF_FILTERS;
        
        LIST_OF_SCALARS{1}='OFF';
        for II=1:numel(StrutturaDatiFull.ScalarNames)
            LIST_OF_SCALARS{end+1}=StrutturaDatiFull.ScalarNames{II};
        end
        CurrentColumnFormat{3}=LIST_OF_SCALARS;
        
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
        
        %set(MyHandle.X_SEL,'value',1);
        
        set(MyHandle.TabellaY,'ColumnFormat',CurrentColumnFormat);
        CurrentDataY=get(MyHandle.TabellaY,'data');
        [SA,~]=size(CurrentDataY);
        
        for II=1:SA
            if((petizione.Filtri(II,1)+1)>numel(LIST_OF_FILTERS))
                CurrentDataY{II,1}=LIST_OF_FILTERS{1};
                petizione.Filtri(II,1)=0;
            else
                CurrentDataY{II,1}=LIST_OF_FILTERS{petizione.Filtri(II,1)+1};
            end
            if((petizione.Filtri(II,2)+1)>numel(LIST_OF_FILTERS))
                CurrentDataY{II,2}=LIST_OF_FILTERS{1};
                petizione.Filtri(II,2)=0;
            else
                CurrentDataY{II,2}=LIST_OF_FILTERS{petizione.Filtri(II,2)+1};
            end
            found=0;
            for KK=1:numel(StrutturaDatiFull.ScalarNames)
                if(all(petizione.Y_SEL(II,:)==StrutturaDatiFull.ScalarWhereToBeFound(KK,:)))
                    CurrentDataY{II,3}=StrutturaDatiFull.ScalarNames{KK};
                    found=1;
                    break
                end
            end
            if(~found)
                CurrentDataY{II,3}=LIST_OF_SCALARS{1};
                petizione.Y_SEL(II,:)=[0,0,0];
            end
        end
        
        %         if(get(MyHandle.Filter1,'value') > numel(LIST_OF_FILTERS))
        %             petizione.Filtri(1)=0; set(MyHandle.Filter1,'value',1);
        %         end
        
        
        if(SynchMode)
            set(MyHandle.X_PID_DELAY,'visible','off');
            set(MyHandle.tpx,'visible','off');
        else
            set(MyHandle.X_PID_DELAY,'string',int2str(petizione.X_PID_DELAY));
            set(MyHandle.X_PID_DELAY,'visible','on');
            set(MyHandle.tpx,'visible','on');
        end
        
        set(MyHandle.TabellaY,'data',CurrentDataY);
        
        set(MyHandle.e_y1,'string',num2str(petizione.lim_y1));
        set(MyHandle.e_y2,'string',num2str(petizione.lim_y2));
        set(MyHandle.e_x1,'string',num2str(petizione.lim_x1));
        set(MyHandle.e_x2,'string',num2str(petizione.lim_x2));
        set(MyHandle.TOM,'value',petizione.MomentsON);
        set(MyHandle.SMP,'value',petizione.ShowMoments);
        set(MyHandle.e_binsx,'string',num2str(petizione.binsx));
        set(MyHandle.e_binsy,'string',num2str(petizione.binsy));
        set(MyHandle.TypeOfPlot,'value',petizione.TypeOfPlot);
        set(MyHandle.QuickFit,'value',petizione.QuickFit);
        %petizione.X_SEL=[0,0,0];
        %petizione.Y_SEL=zeros(SA,3);
        %petizione.Filtri=zeros(SA,2);
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
        set(MyHandle.IdatiStanQua,'userdata',petizione);
    end
else
    petizione=get(MyHandle.IdatiStanQua,'userdata');
    % da controllare se e' il primo giro, se no... insomma un caos
    if(SynchMode==1)
        %disp('update in synch mode')
        cla(MyHandle.axes1)
        hold(MyHandle.axes1,'on');
        %save TXT
        switch(petizione.X_SEL(1))
            case 0
                return
            case 1
                DATI_X=SynchProfilePVs(FiltersBuffer{1},petizione.X_SEL(3));
            case 2
                DATI_X=AdditionalNonStandardPVsMatrices{petizione.X_SEL(2)}(FiltersBuffer{1},petizione.X_SEL(3));
            case 3
                DATI_X=NotSynchProfilePVs(FiltersBuffer{1},petizione.X_SEL(3));
            case 4
                DATI_X=ScalarsBuffer(FiltersBuffer{1},petizione.X_SEL(3));
            case 5
                DATI_X= PulseIDMatrix(FiltersBuffer{1});
            case 6
                DATI_X= TimeStampsMatrix(FiltersBuffer{1});
            case 7
                DATI_X= AbsoluteEventCounterMatrix(FiltersBuffer{1});
            case 8
                DATI_X= ScanBuffer(FiltersBuffer{1},petizione.X_SEL(3));
        end
        [SA,SB]=size(petizione.Y_SEL);
        if(petizione.MomentsON || petizione.ShowMoments)
            XAVG=mean(DATI_X);
            XSTD=std(DATI_X);
            if(petizione.MomentsON)
                set(MyHandle.AverageStringX,'string',num2str(XAVG));
                set(MyHandle.stdStringX,'string',num2str(XSTD));
                CDA=get(MyHandle.TabellaY,'data');
            end
        end
        
        if(petizione.TypeOfPlot==1)
            cla(MyHandle.axes1,'reset')
            hold(MyHandle.axes1,'on')
            for II=1:SA
                switch(petizione.Y_SEL(II,1))
                    case 0
                        continue
                    case 1
                        DATI_Y=SynchProfilePVs(FiltersBuffer{1},petizione.Y_SEL(II,3));
                    case 2
                        DATI_Y=AdditionalNonStandardPVsMatrices{petizione.Y_SEL(II,2)}(FiltersBuffer{1},petizione.Y_SEL(II,3));
                    case 3
                        DATI_Y=NotSynchProfilePVs(FiltersBuffer{1},petizione.Y_SEL(II,3));
                    case 4
                        DATI_Y=ScalarsBuffer(FiltersBuffer{1},petizione.Y_SEL(II,3));
                    case 5
                        DATI_Y= PulseIDMatrix(FiltersBuffer{1});
                    case 6
                        DATI_Y= TimeStampsMatrix(FiltersBuffer{1});
                    case 7
                        DATI_Y= AbsoluteEventCounterMatrix(FiltersBuffer{1});
                    case 8
                        DATI_Y= ScanBuffer(FiltersBuffer{1},petizione.Y_SEL(II,3));
                end
                if(any(petizione.Filtri(II,:)))
                    if(petizione.Filtri(II,1)==0)
                        TENUTI=FiltersBuffer{petizione.Filtri(II,2)+1};
                    elseif(petizione.Filtri(II,2)==0)
                        TENUTI=FiltersBuffer{petizione.Filtri(II,1)+1};
                    else
                        TENUTI=FiltersBuffer{petizione.Filtri(II,1)+1} & FiltersBuffer{petizione.Filtri(II,2)+1};
                    end
                    plot(MyHandle.axes1,DATI_X(TENUTI),DATI_Y(TENUTI),petizione.Styl{II});
                    if(petizione.MomentsON)
                        CDA{II,5}=mean(DATI_Y(TENUTI));
                        CDA{II,6}=std(DATI_Y(TENUTI));
                    end
                else
                    if(petizione.MomentsON)
                        CDA{II,5}=mean(DATI_Y);
                        CDA{II,6}=std(DATI_Y);
                    end
                    plot(MyHandle.axes1,DATI_X,DATI_Y,petizione.Styl{II});
                end
            end
            
            if(petizione.MomentsON)
                set(MyHandle.TabellaY,'data',CDA);
            end
            CurrLimX=xlim(MyHandle.axes1);
            CurrLimY=ylim(MyHandle.axes1);
            if(petizione.ShowMoments)
                plot(MyHandle.axes1,[XAVG,XAVG],CurrLimY ,'k--') ;
            end
            
            if(~petizione.b_autoX)
                if(~isnan(petizione.lim_x1)), CurrLimX(1)=petizione.lim_x1; end
                if(~isnan(petizione.lim_x2)), CurrLimX(2)=petizione.lim_x2; end
                xlim(MyHandle.axes1,CurrLimX);
            end
            if(~petizione.b_autoY)
                if(~isnan(petizione.lim_y1)), CurrLimY(1)=petizione.lim_y1; end
                if(~isnan(petizione.lim_y2)), CurrLimY(2)=petizione.lim_y2; end
                ylim(MyHandle.axes1,CurrLimY);
            end
            
        elseif(petizione.TypeOfPlot==2) %PlotAs2dmap
            
            cla(MyHandle.axes1,'reset')
            %hold(MyHandle.axes1,'on');
            %save TXT
            switch(petizione.X_SEL(1))
                case 0
                    return
                case 1
                    DATI_X=SynchProfilePVs(FiltersBuffer{1},petizione.X_SEL(3));
                case 2
                    DATI_X=AdditionalNonStandardPVsMatrices{petizione.X_SEL(2)}(FiltersBuffer{1},petizione.X_SEL(3));
                case 3
                    DATI_X=NotSynchProfilePVs(FiltersBuffer{1},petizione.X_SEL(3));
                case 4
                    DATI_X=ScalarsBuffer(FiltersBuffer{1},petizione.X_SEL(3));
                case 5
                    DATI_X= PulseIDMatrix(FiltersBuffer{1});
                case 6
                    DATI_X= TimeStampsMatrix(FiltersBuffer{1});
                case 7
                    DATI_X= AbsoluteEventCounterMatrix(FiltersBuffer{1});
                case 8
                    DATI_X= ScanBuffer(FiltersBuffer{1},petizione.X_SEL(3));
            end
            [SA,SB]=size(petizione.Y_SEL);
            if(petizione.MomentsON || petizione.ShowMoments)
                XAVG=mean(DATI_X);
                XSTD=std(DATI_X);
                if(petizione.MomentsON)
                    set(MyHandle.AverageStringX,'string',num2str(XAVG));
                    set(MyHandle.stdStringX,'string',num2str(XSTD));
                    CDA=get(MyHandle.TabellaY,'data');
                end
            end
            
            for II=1:SA
                switch(petizione.Y_SEL(II,1))
                    case 0
                        continue
                    case 1
                        DATI_Y=SynchProfilePVs(FiltersBuffer{1},petizione.Y_SEL(II,3));break
                    case 2
                        DATI_Y=AdditionalNonStandardPVsMatrices{petizione.Y_SEL(II,2)}(FiltersBuffer{1},petizione.Y_SEL(II,3));break
                    case 3
                        DATI_Y=NotSynchProfilePVs(FiltersBuffer{1},petizione.Y_SEL(II,3));break
                    case 4
                        DATI_Y=ScalarsBuffer(FiltersBuffer{1},petizione.Y_SEL(II,3));break
                    case 5
                        DATI_Y= PulseIDMatrix(FiltersBuffer{1});break
                    case 6
                        DATI_Y= TimeStampsMatrix(FiltersBuffer{1});break
                    case 7
                        DATI_Y= AbsoluteEventCounterMatrix(FiltersBuffer{1});break
                    case 8
                        DATI_Y= ScanBuffer(FiltersBuffer{1},petizione.Y_SEL(II,3)); break
                end
            end
            
            if(any(petizione.Filtri(II,:)))
                if(petizione.Filtri(II,1)==0)
                    TENUTI=FiltersBuffer{petizione.Filtri(II,2)+1};
                elseif(petizione.Filtri(II,2)==0)
                    TENUTI=FiltersBuffer{petizione.Filtri(II,1)+1};
                else
                    TENUTI=FiltersBuffer{petizione.Filtri(II,1)+1} & FiltersBuffer{petizione.Filtri(II,2)+1};
                end
                DATI_X=DATI_X(TENUTI);
                DATI_Y=DATI_Y(TENUTI);
            end
            if(petizione.MomentsON)
                CDA{II,5}=mean(DATI_Y);
                CDA{II,6}=std(DATI_Y);
                set(MyHandle.TabellaY,'data',CDA);
            end
            
            Mx=max(DATI_X);mx=min(DATI_X);my=min(DATI_Y);My=max(DATI_Y);
            if(~petizione.b_autoX)
                if(~isnan(petizione.lim_x1)), mx=petizione.lim_x1; end
                if(~isnan(petizione.lim_x2)), Mx=petizione.lim_x2; end;
            end
            if(~petizione.b_autoY)
                if(~isnan(petizione.lim_y1)), my=petizione.lim_y1; end
                if(~isnan(petizione.lim_y2)), My=petizione.lim_y2; end
            end
            Matrice=zeros(petizione.binsy,petizione.binsx);
            INDICIX=round(petizione.binsx*(DATI_X-mx)/(Mx-mx))+1;
            INDICIY=round(petizione.binsy*(DATI_Y-my)/(My-my))+1;
            OutOfBounds=0;
            for SS=1:length(DATI_X)
                if((INDICIX(SS)>=1) && (INDICIX(SS)<=petizione.binsx) && (INDICIY(SS)<=petizione.binsy) && (INDICIX(SS)>=1) )
                    Matrice(INDICIY(SS),INDICIX(SS))=Matrice(INDICIY(SS),INDICIX(SS))+1;
                else
                    OutOfBounds=OutOfBounds+1;
                end
            end
            imagesc(linspace(mx,Mx,petizione.binsx),linspace(my,My,petizione.binsy),Matrice,'parent',MyHandle.axes1);
            set(MyHandle.axes1,'ydir','normal');
            colorbar('peer',MyHandle.axes1);
            xlim(MyHandle.axes1,[mx,Mx]);ylim(MyHandle.axes1,[my,My]);
        elseif(petizione.TypeOfPlot==3)  %Full Partition, add partition averages
            cla(MyHandle.axes1,'reset')
            hold(MyHandle.axes1,'on')
            for II=1:SA
                switch(petizione.Y_SEL(II,1))
                    case 0
                        continue
                    case 1
                        DATI_Y=SynchProfilePVs(FiltersBuffer{1},petizione.Y_SEL(II,3));
                    case 2
                        DATI_Y=AdditionalNonStandardPVsMatrices{petizione.Y_SEL(II,2)}(FiltersBuffer{1},petizione.Y_SEL(II,3));
                    case 3
                        DATI_Y=NotSynchProfilePVs(FiltersBuffer{1},petizione.Y_SEL(II,3));
                    case 4
                        DATI_Y=ScalarsBuffer(FiltersBuffer{1},petizione.Y_SEL(II,3));
                    case 5
                        DATI_Y= PulseIDMatrix(FiltersBuffer{1});
                    case 6
                        DATI_Y= TimeStampsMatrix(FiltersBuffer{1});
                    case 7
                        DATI_Y= AbsoluteEventCounterMatrix(FiltersBuffer{1});
                    case 8
                        DATI_Y= ScanBuffer(FiltersBuffer{1},petizione.Y_SEL(II,3));
                end
                
                if(any(petizione.Filtri(II,:)))
                    if(petizione.Filtri(II,1)==0)
                        TENUTI=FiltersBuffer{petizione.Filtri(II,2)+1};
                    elseif(petizione.Filtri(II,2)==0)
                        TENUTI=FiltersBuffer{petizione.Filtri(II,1)+1};
                    else
                        TENUTI=FiltersBuffer{petizione.Filtri(II,1)+1} & FiltersBuffer{petizione.Filtri(II,2)+1};
                    end
                    plot(MyHandle.axes1,DATI_X(TENUTI),DATI_Y(TENUTI),petizione.Styl{II});
                    TEMPDX=DATI_X(TENUTI);
                    TEMPDY=DATI_Y(TENUTI);
                    [UniqueX,DoveUniqueX]=unique(TEMPDX);
                    for AK=1:length(UniqueX)
                        if(~isnan(UniqueX(AK)))
                            PARTY=TEMPDY(TEMPDX==UniqueX(AK));
                            MPY=mean(PARTY(~isnan(PARTY)));
                            if(~isempty(MPY) && ~isempty(UniqueX(AK)))
                                plot(MyHandle.axes1,UniqueX(AK),MPY,'*r','Markersize',20);
                            end
                        end
                    end
                    if(petizione.MomentsON)
                        CDA{II,5}=mean(DATI_Y(TENUTI));
                        CDA{II,6}=std(DATI_Y(TENUTI));
                    end
                else
                    if(petizione.MomentsON)
                        CDA{II,5}=mean(DATI_Y);
                        CDA{II,6}=std(DATI_Y);
                    end
                    plot(MyHandle.axes1,DATI_X,DATI_Y,petizione.Styl{II});    
                    TEMPDX=DATI_X;
                    TEMPDY=DATI_Y;
                    [UniqueX,DoveUniqueX]=unique(TEMPDX);
                    for AK=1:length(UniqueX)
                        if(~isnan(UniqueX(AK)))
                            PARTY=TEMPDY(TEMPDX==UniqueX(AK));
                            MPY=mean(PARTY(~isnan(PARTY)));
                            if(~isempty(MPY) && ~isempty(UniqueX(AK)))
                                plot(MyHandle.axes1,UniqueX(AK),MPY,'*r','Markersize',20);
                            end
                        end
                    end
                end
            end
            if(petizione.MomentsON)
                set(MyHandle.TabellaY,'data',CDA);
            end
            CurrLimX=xlim(MyHandle.axes1);
            CurrLimY=ylim(MyHandle.axes1);
            if(petizione.ShowMoments)
                plot(MyHandle.axes1,[XAVG,XAVG],CurrLimY ,'k--') ;
            end
            if(~petizione.b_autoX)
                if(~isnan(petizione.lim_x1)), CurrLimX(1)=petizione.lim_x1; end
                if(~isnan(petizione.lim_x2)), CurrLimX(2)=petizione.lim_x2; end
                xlim(MyHandle.axes1,CurrLimX);
            end
            if(~petizione.b_autoY)
                if(~isnan(petizione.lim_y1)), CurrLimY(1)=petizione.lim_y1; end
                if(~isnan(petizione.lim_y2)), CurrLimY(2)=petizione.lim_y2; end
                ylim(MyHandle.axes1,CurrLimY);
            end  
            
        elseif(petizione.TypeOfPlot==4)  %Full Strict partition.
            cla(MyHandle.axes1,'reset')
            hold(MyHandle.axes1,'on')
            for II=1:SA
                switch(petizione.Y_SEL(II,1))
                    case 0
                        continue
                    case 1
                        DATI_Y=SynchProfilePVs(FiltersBuffer{1},petizione.Y_SEL(II,3));
                    case 2
                        DATI_Y=AdditionalNonStandardPVsMatrices{petizione.Y_SEL(II,2)}(FiltersBuffer{1},petizione.Y_SEL(II,3));
                    case 3
                        DATI_Y=NotSynchProfilePVs(FiltersBuffer{1},petizione.Y_SEL(II,3));
                    case 4
                        DATI_Y=ScalarsBuffer(FiltersBuffer{1},petizione.Y_SEL(II,3));
                    case 5
                        DATI_Y= PulseIDMatrix(FiltersBuffer{1});
                    case 6
                        DATI_Y= TimeStampsMatrix(FiltersBuffer{1});
                    case 7
                        DATI_Y= AbsoluteEventCounterMatrix(FiltersBuffer{1});
                    case 8
                        DATI_Y= ScanBuffer(FiltersBuffer{1},petizione.Y_SEL(II,3));
                end
                
                if(any(petizione.Filtri(II,:)))
                    if(petizione.Filtri(II,1)==0)
                        TENUTI=FiltersBuffer{petizione.Filtri(II,2)+1};
                    elseif(petizione.Filtri(II,2)==0)
                        TENUTI=FiltersBuffer{petizione.Filtri(II,1)+1};
                    else
                        TENUTI=FiltersBuffer{petizione.Filtri(II,1)+1} & FiltersBuffer{petizione.Filtri(II,2)+1};
                    end
                    %plot(MyHandle.axes1,DATI_X(TENUTI),DATI_Y(TENUTI),petizione.Styl{II});
                    TEMPDX=DATI_X(TENUTI);
                    TEMPDY=DATI_Y(TENUTI);
                    [UniqueX,DoveUniqueX]=unique(TEMPDX);
                    inserted=0;TEMX=[];TEMY=[];ERRY=[];ERRAY=[];
                    for AK=1:length(UniqueX)
                        if(~isnan(UniqueX(AK)))
                            PARTY=TEMPDY(TEMPDX==UniqueX(AK));
                            MPY=mean(PARTY(~isnan(PARTY)));
                            STDY=std(PARTY(~isnan(PARTY)));
                            if(~isempty(MPY) && ~isempty(UniqueX(AK)))
                                inserted=inserted+1;
                                TEMX(inserted)=UniqueX(AK);
                                TEMY(inserted)=MPY;
                                ERRY(inserted)=STDY;
                                ERRAY(inserted)=STDY/sqrt(numel(PARTY));
                            end
                        end
                    end
                    plot(MyHandle.axes1,TEMX,TEMY,'xr','Markersize',12);
                    errorbar(MyHandle.axes1,TEMX,TEMY,ERRY,'b');
                    errorbar(MyHandle.axes1,TEMX,TEMY,ERRAY,'r');
                                
                    if(petizione.MomentsON)
                        CDA{II,5}=mean(DATI_Y(TENUTI));
                        CDA{II,6}=std(DATI_Y(TENUTI));
                    end
                else
                    if(petizione.MomentsON)
                        CDA{II,5}=mean(DATI_Y);
                        CDA{II,6}=std(DATI_Y);
                    end
                    %plot(MyHandle.axes1,DATI_X,DATI_Y,petizione.Styl{II});    
                    TEMPDX=DATI_X;
                    TEMPDY=DATI_Y;
                    [UniqueX,DoveUniqueX]=unique(TEMPDX);
                    inserted=0;TEMX=[];TEMY=[];ERRY=[];ERRAY=[];
                    for AK=1:length(UniqueX)
                            PARTY=TEMPDY(TEMPDX==UniqueX(AK));
                            MPY=mean(PARTY(~isnan(PARTY)));
                            STDY=std(PARTY(~isnan(PARTY)));
                            if(~isempty(MPY) && ~isempty(UniqueX(AK)))
                                inserted=inserted+1;
                                TEMX(inserted)=UniqueX(AK);
                                TEMY(inserted)=MPY;
                                ERRY(inserted)=STDY;
                                ERRAY(inserted)=STDY/sqrt(numel(PARTY));
                            end
                    end
                    switch(II)
                        case 1
                            plot(MyHandle.axes1,TEMX,TEMY,'r-');
                        case 2
                            plot(MyHandle.axes1,TEMX,TEMY,'g-');
                        case 3
                            plot(MyHandle.axes1,TEMX,TEMY,'k-');
                        otherwise
                            plot(MyHandle.axes1,TEMX,TEMY,'m-');
                    end
                    errorbar(MyHandle.axes1,TEMX,TEMY,ERRY,'b.');
                    errorbar(MyHandle.axes1,TEMX,TEMY,ERRAY,'r.');
                end
            end
            if(petizione.MomentsON)
                set(MyHandle.TabellaY,'data',CDA);
            end
            CurrLimX=xlim(MyHandle.axes1);
            CurrLimY=ylim(MyHandle.axes1);
            if(petizione.ShowMoments)
                plot(MyHandle.axes1,[XAVG,XAVG],CurrLimY ,'k--') ;
            end
            if(~petizione.b_autoX)
                if(~isnan(petizione.lim_x1)), CurrLimX(1)=petizione.lim_x1; end
                if(~isnan(petizione.lim_x2)), CurrLimX(2)=petizione.lim_x2; end
                xlim(MyHandle.axes1,CurrLimX);
            end
            if(~petizione.b_autoY)
                if(~isnan(petizione.lim_y1)), CurrLimY(1)=petizione.lim_y1; end
                if(~isnan(petizione.lim_y2)), CurrLimY(2)=petizione.lim_y2; end
                ylim(MyHandle.axes1,CurrLimY);
            end     
            
        end % end of type of IF TYPES OF PLOT 
    else % the terrible asynchronous mode... where synchronization is evaluated live on the displays
        cla(MyHandle.axes1)
        hold(MyHandle.axes1,'on')
        switch(petizione.X_SEL(1))
            case 0
                return
            case 1
                if(ScalarsBuffer)
                    DATI_X=SynchProfilePVs(:,petizione.X_SEL(3));
                    PID_X=mod((PulseIDMatrix{1}+ 0),131040);
                    ABS_X=AbsoluteEventCounterMatrix{1};
                else
                    DATI_X=SynchProfilePVs(:,petizione.X_SEL(3));
                    PID_X=mod((PulseIDMatrix{1}(:,petizione.X_SEL(3))+ petizione.X_PID_DELAY),131040);
                    ABS_X=AbsoluteEventCounterMatrix{1}(:,petizione.X_SEL(3));
                end
            case 2
                DATI_X=AdditionalNonStandardPVsMatrices{petizione.X_SEL(2)}(:,petizione.X_SEL(3));
                PID_X=mod((PulseIDMatrix{2}(:,petizione.X_SEL(2))+ petizione.X_PID_DELAY),131040);
                ABS_X=AbsoluteEventCounterMatrix{2}(:,petizione.X_SEL(2));
            case 3
                DATI_X=NotSynchProfilePVs(:,petizione.X_SEL(3));
                PID_X=mod((PulseIDMatrix{3}(:,petizione.X_SEL(3))+ petizione.X_PID_DELAY),131040);
                ABS_X=AbsoluteEventCounterMatrix{3}(:,petizione.X_SEL(3));
            case 4
                return
            case 5
                return
            case 6
                return
            case 7
                return
            case 8
                DATI_X= ScanBuffer(:,petizione.X_SEL(3));
                PID_X=mod((PulseIDMatrix{8}(:,petizione.X_SEL(3))+ petizione.X_PID_DELAY),131040);
                ABS_X=AbsoluteEventCounterMatrix{8}(:,petizione.X_SEL(3));
        end

        [SA,SB]=size(petizione.Y_SEL);
        DATI_X=DATI_X(~isnan(ABS_X));
        if(petizione.MomentsON || petizione.ShowMoments)
            XAVG=mean(DATI_X);
            XSTD=std(DATI_X);
            if(petizione.MomentsON)
                set(MyHandle.AverageStringX,'string',num2str(XAVG));
                set(MyHandle.stdStringX,'string',num2str(XSTD));
                CDA=get(MyHandle.TabellaY,'data');
            end
        end
        
        for II=1:SA
            switch(petizione.Y_SEL(II,1))
                case 0
                    continue
                case 1
                    
                    if(ScalarsBuffer)
                        DATI_Y=SynchProfilePVs(:,petizione.Y_SEL(II,3));
                        PID_Y=mod((PulseIDMatrix{1}+ 0),131040);
                        ABS_Y=AbsoluteEventCounterMatrix{1};
                    else
                        DATI_Y=SynchProfilePVs(:,petizione.Y_SEL(II,3));
                        PID_Y=mod((PulseIDMatrix{1}(:,petizione.Y_SEL(II,3))+ 0),131040);
                        ABS_Y=AbsoluteEventCounterMatrix{1}(:,petizione.Y_SEL(II,3));
                    end
                    
                    
                case 2
                    DATI_Y=AdditionalNonStandardPVsMatrices{petizione.Y_SEL(II,2)}(:,petizione.Y_SEL(II,3));
                    PID_Y=mod((PulseIDMatrix{2}(:,petizione.Y_SEL(II,2))+ 0),131040);
                    ABS_Y=AbsoluteEventCounterMatrix{2}(:,petizione.Y_SEL(II,2));
                case 3
                    DATI_Y=NotSynchProfilePVs(:,petizione.Y_SEL(II,3));
                    PID_Y=mod((PulseIDMatrix{3}(:,petizione.Y_SEL(II,3))+ 0),131040);
                    ABS_Y=AbsoluteEventCounterMatrix{3}(:,petizione.Y_SEL(II,3));
                case 4
                    continue
                case 5
                    continue
                case 6
                    continue
                case 7
                    continue
                case 8
                    DATI_Y= ScanBuffer(:,petizione.Y_SEL(II,3));
                    PID_Y=mod((PulseIDMatrix{1}(8,petizione.Y_SEL(II,3))+ 0),131040);
                    ABS_Y=AbsoluteEventCounterMatrix{8}(:,petizione.Y_SEL(II,3));
            end
            DATI_Y=DATI_Y(~isnan(ABS_Y));
            if(petizione.MomentsON)
                CDA{II,5}=mean(DATI_Y);
                CDA{II,6}=std(DATI_Y);
            end
            
            [~,DX,DY]=intersect(PID_X,PID_Y);
            if(~isempty(DX))
                if(petizione.TypeOfPlot==1)
                    plot(MyHandle.axes1,DATI_X(DX),DATI_Y(DY),petizione.Styl{II});
                elseif(petizione.TypeOfPlot==2)
                    DATI_X=DATI_X(DX); DATI_Y=DATI_Y(DY);
                    Mx=max(DATI_X);mx=min(DATI_X);my=min(DATI_Y);My=max(DATI_Y);
                    if(~petizione.b_autoX)
                        if(~isnan(petizione.lim_x1)), mx=petizione.lim_x1; end
                        if(~isnan(petizione.lim_x2)), Mx=petizione.lim_x2; end;
                    end
                    if(~petizione.b_autoY)
                        if(~isnan(petizione.lim_y1)), my=petizione.lim_y1; end
                        if(~isnan(petizione.lim_y2)), My=petizione.lim_y2; end
                    end
                    Matrice=zeros(petizione.binsy,petizione.binsx);
                    INDICIX=round(petizione.binsx*(DATI_X-mx)/(Mx-mx))+1;
                    INDICIY=round(petizione.binsy*(DATI_Y-my)/(My-my))+1;
                    OutOfBounds=0;
                    for SS=1:length(DATI_X)
                        if((INDICIX(SS)>=1) && (INDICIX(SS)<=petizione.binsx) && (INDICIY(SS)<=petizione.binsy) && (INDICIX(SS)>=1) )
                            Matrice(INDICIY(SS),INDICIX(SS))=Matrice(INDICIY(SS),INDICIX(SS))+1;
                        else
                            OutOfBounds=OutOfBounds+1;
                        end
                    end
                    imagesc(linspace(mx,Mx,petizione.binsx),linspace(my,My,petizione.binsy),Matrice,'parent',MyHandle.axes1);
                    xlim(MyHandle.axes1,[mx,Mx]);ylim(MyHandle.axes1,[my,My]);
                    break
                elseif(petizione.TypeOfPlot==3)
                    plot(MyHandle.axes1,DATI_X(DX),DATI_Y(DY),petizione.Styl{II});
                    TEMPDX=DATI_X(DX);
                    TEMPDY=DATI_Y(DY);
                    [UniqueX,DoveUniqueX]=unique(TEMPDX);
                    inserted=0;TEMX=[];TEMY=[];ERRY=[];ERRAY=[];
                    for AK=1:length(UniqueX)
                            PARTY=TEMPDY(TEMPDX==UniqueX(AK));
                            MPY=mean(PARTY(~isnan(PARTY)));
                            STDY=std(PARTY(~isnan(PARTY)));
                            if(~isempty(MPY) && ~isempty(UniqueX(AK)))
                                inserted=inserted+1;
                                TEMX(inserted)=UniqueX(AK);
                                TEMY(inserted)=MPY;
                                ERRY(inserted)=STDY;
                                ERRAY(inserted)=STDY/sqrt(numel(PARTY));
                            end
                    end
                    if(inserted)
                        plot(MyHandle.axes1,TEMX,TEMY,'xr','Markersize',12);
                        errorbar(MyHandle.axes1,TEMX,TEMY,ERRY,'b');
                        errorbar(MyHandle.axes1,TEMX,TEMY,ERRAY,'r');
                    end

                elseif(petizione.TypeOfPlot==4)
                    
                    TEMPDX=DATI_X(DX);
                    TEMPDY=DATI_Y(DY);
                    [UniqueX,DoveUniqueX]=unique(TEMPDX);
                    inserted=0;TEMX=[];TEMY=[];ERRY=[];ERRAY=[];
                    for AK=1:length(UniqueX)
                            PARTY=TEMPDY(TEMPDX==UniqueX(AK));
                            MPY=mean(PARTY(~isnan(PARTY)));
                            STDY=std(PARTY(~isnan(PARTY)));
                            if(~isempty(MPY) && ~isempty(UniqueX(AK)))
                                inserted=inserted+1;
                                TEMX(inserted)=UniqueX(AK);
                                TEMY(inserted)=MPY;
                                ERRY(inserted)=STDY;
                                ERRAY(inserted)=STDY/sqrt(numel(PARTY));
                            end
                    end
                    if(inserted)
                        plot(MyHandle.axes1,TEMX,TEMY,'xr','Markersize',12);
                        errorbar(MyHandle.axes1,TEMX,TEMY,ERRY,'b');
                        errorbar(MyHandle.axes1,TEMX,TEMY,ERRAY,'r');
                    end
                    
                    
                end
            end
            if(petizione.TypeOfPlot~=2)
                    CurrLimX=xlim(MyHandle.axes1);
                    CurrLimY=ylim(MyHandle.axes1);
                    if(petizione.ShowMoments)
                        plot(MyHandle.axes1,[XAVG,XAVG],CurrLimY ,'k--') ;
                    end
                    if(~petizione.b_autoX)
                        if(~isnan(petizione.lim_x1)), CurrLimX(1)=petizione.lim_x1; end
                        if(~isnan(petizione.lim_x2)), CurrLimX(2)=petizione.lim_x2; end
                        xlim(MyHandle.axes1,CurrLimX);
                    end
                    if(~petizione.b_autoY)
                        if(~isnan(petizione.lim_y1)), CurrLimY(1)=petizione.lim_y1; end
                        if(~isnan(petizione.lim_y2)), CurrLimY(2)=petizione.lim_y2; end
                        ylim(MyHandle.axes1,CurrLimY);
                    end
            end
            
        end
        
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
        end
        NuovaFigura=figure;
        copyobj(MyHandle.axes1,NuovaFigura);
        AXNF=get(NuovaFigura,'children');
        title(AXNF,titlestring)
        AXNF=get(NuovaFigura,'children');
        IV=get(MyHandle.X_SEL,'value');
        IS=get(MyHandle.X_SEL,'string');
        xlabel(AXNF,IS{IV});
        
        CDA=get(MyHandle.TabellaY,'data');
        Attivi=petizione.Y_SEL(:,1)>0;
        if(petizione.TypeOfPlot==1)
            
            if(sum(Attivi)==1)
                ylabel(AXNF,CDA{find(Attivi),3});
            else
                lista={};
                lfu1={};
                lfu2={};
                for II=1:numel(Attivi)
                    if(Attivi(II))
                        lfu1{end+1}=CDA{II,1};
                        lfu2{end+1}=CDA{II,2};
                        lista{end+1}=CDA{II,3};
                    end
                end
                [lista2,QUALI]=unique(lista);
                lf1=lfu1(QUALI);
                lf2=lfu2(QUALI);
                if(numel(lista2)==1)
                    ylabel(AXNF,lista2{1});
                    legleg={};
                    for TT=1:numel(lfu1)
                        if(strcmp(lfu1{TT},lfu2{TT}))
                            legleg{end+1}=lfu1{TT};
                        else
                            if(strcmp(lfu1{TT},'No Filter'))
                                legleg{end+1}=lfu2{TT};
                            elseif(strcmp(lfu2{TT},'No Filter'))
                                legleg{end+1}=lfu1{TT};
                            else
                                legleg{end+1}=[lfu1{TT},'&',lfu2{TT}];
                            end
                        end
                    end
                    legend(AXNF,legleg);
                else
                    legend(AXNF,lista);
                end
                try
                    util_printLog(NuovaFigura);
                end
            end
        elseif(petizione.TypeOfPlot==2)
            Attivo=find(petizione.Y_SEL(:,1)>0,1,'first');
            Yused=CDA{Attivo,3};
            ylabel(AXNF,Yused);
            colorbar('peer',AXNF)
            try
                util_printLog(NuovaFigura,'title','counts colormap');
            end
        elseif((petizione.TypeOfPlot==3) || (petizione.TypeOfPlot==4))
            if(sum(Attivi)==1)
                ylabel(AXNF,CDA{find(Attivi),3});
            else
                lista={};
                lfu1={};
                lfu2={};
                for II=1:numel(Attivi)
                    if(Attivi(II))
                        lfu1{end+1}=CDA{II,1};
                        lfu2{end+1}=CDA{II,2};
                        lista{end+1}=CDA{II,3};
                    end
                end
                [lista2,QUALI]=unique(lista);
                lf1=lfu1(QUALI);
                lf2=lfu2(QUALI);
                if(numel(lista2)==1)
                    ylabel(AXNF,lista2{1});
                    legleg={};
                    for TT=1:numel(lfu1)
                        if(strcmp(lfu1{TT},lfu2{TT}))
                            legleg{end+1}=lfu1{TT};
                        else
                            if(strcmp(lfu1{TT},'No Filter'))
                                legleg{end+1}=lfu2{TT};
                            elseif(strcmp(lfu2{TT},'No Filter'))
                                legleg{end+1}=lfu1{TT};
                            else
                                legleg{end+1}=[lfu1{TT},'&',lfu2{TT}];
                            end
                        end
                    end
                    legend(AXNF,legleg);
                else
                    legend(AXNF,lista);
                end
                try
                    util_printLog(NuovaFigura);
                end
            end
            
            try
                util_printLog(NuovaFigura,'title','partition plot');
            end
        end
        
        petizione.logbook_only=0;
        set(MyHandle.IdatiStanQua,'userdata',petizione);
    end
    
    
end
