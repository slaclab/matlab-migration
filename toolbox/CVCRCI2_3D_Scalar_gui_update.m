function CVCRCI2_3D_Scalar_gui_update(Initialize, SynchMode, MyHandle,StrutturaDatiFull,PulseIDMatrix,TimeStampsMatrix,AbsoluteEventCounterMatrix,ProfileBuffer,SynchProfilePVs,NotSynchProfilePVs,AdditionalNonStandardPVsMatrices,FiltersBuffer,ScalarsBuffer,ScanBuffer,AcquisitionBufferCycle,AcquisitionTotalSynchronousEvents,AcquisitionBufferNextWrittenElement,AcquisitionBufferLastWrittenElement)
if(Initialize)
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
        
        LIST_OF_SCALARS{1}='OFF';
        for II=1:numel(StrutturaDatiFull.ScalarNames)
            LIST_OF_SCALARS{end+1}=StrutturaDatiFull.ScalarNames{II};
        end
        
        %         set(MyHandle.X_SEL,'string',LIST_OF_SCALARS);%set(MyHandle.X_SEL,'value',1);
        %         set(MyHandle.Y_SEL,'string',LIST_OF_SCALARS);%set(MyHandle.Y_SEL,'value',1);
        %         set(MyHandle.Z_SEL,'string',LIST_OF_SCALARS);%set(MyHandle.Z_SEL,'value',1);
        
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
        
        set(MyHandle.Z_SEL,'string',LIST_OF_SCALARS);
        if(get(MyHandle.Z_SEL,'value') > numel(LIST_OF_SCALARS))
            set(MyHandle.Z_SEL,'value',1);
            petizione.Z_SEL=[0,0,0];
        else %reset it as the current value...
            VAL=get(MyHandle.Z_SEL,'value');
            if(VAL==1)
                petizione.Z_SEL=[0,0,0];
            else
                petizione.Z_SEL=StrutturaDatiFull.ScalarWhereToBeFound(VAL-1,:);
            end
        end
        
        %petizione=get(MyHandle.IdatiStanQua,'userdata');
        set(MyHandle.e_y1,'string',num2str(petizione.lim_y1));
        set(MyHandle.e_y2,'string',num2str(petizione.lim_y2));
        set(MyHandle.e_x1,'string',num2str(petizione.lim_x1));
        set(MyHandle.e_x2,'string',num2str(petizione.lim_x2));
        set(MyHandle.e_z1,'string',num2str(petizione.lim_z1));
        set(MyHandle.e_z2,'string',num2str(petizione.lim_z2));
        set(MyHandle.TOM,'value',petizione.MomentsON);
        set(MyHandle.e_binsx,'string',num2str(petizione.binsx));
        set(MyHandle.e_binsy,'string',num2str(petizione.binsy));
        set(MyHandle.TypeOfPlot,'value',petizione.TypeOfPlot);
        if(SynchMode)
            set(MyHandle.X_PID_DELAY,'visible','off');
            set(MyHandle.Y_PID_DELAY,'visible','off');
            set(MyHandle.Z_PID_DELAY,'visible','off');
            set(MyHandle.tpx,'visible','off');
            set(MyHandle.tpy,'visible','off');
            set(MyHandle.tpz,'visible','off');
        else
            set(MyHandle.X_PID_DELAY,'string',int2str(petizione.X_PID_DELAY));
            set(MyHandle.Y_PID_DELAY,'string',int2str(petizione.Y_PID_DELAY));
            set(MyHandle.Z_PID_DELAY,'string',int2str(petizione.Z_PID_DELAY));
            set(MyHandle.X_PID_DELAY,'visible','on');
            set(MyHandle.Y_PID_DELAY,'visible','on');
            set(MyHandle.Z_PID_DELAY,'visible','on');
            set(MyHandle.tpx,'visible','on');
            set(MyHandle.tpy,'visible','on');
            set(MyHandle.tpz,'visible','on');
        end
        
        %         petizione.X_SEL=[0,0,0];
        %         petizione.Y_SEL=[0,0,0];
        %         petizione.Z_SEL=[0,0,0];
        %         petizione.Filtri=[0,0];
        %         set(MyHandle.Filter1,'value',1);
        %         set(MyHandle.Filter2,'value',1);
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
        if(petizione.b_autoZ)
            set(MyHandle.b_autoZ,'backgroundcolor',[0,1,0]);
        else
            set(MyHandle.b_autoZ,'backgroundcolor',[0.7,0.7,0.7]);
        end
        set(MyHandle.IdatiStanQua,'userdata',petizione);
    end
else
    petizione=get(MyHandle.IdatiStanQua,'userdata');
    % da controllare se e' il primo giro, se no... insomma un caos
    if(SynchMode==1)
        %disp('update in synch mode')
        %         cla(MyHandle.axes1)
        %         hold(MyHandle.axes1,'on');
        
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
        
        if(isempty(TENUTI))
            if(petizione.MomentsON )
                set(MyHandle.AverageStringX,'string','NaN');
                set(MyHandle.stdStringX,'string','NaN');
                set(MyHandle.AverageStringY,'string','NaN');
                set(MyHandle.stdStringY,'string','NaN');
                set(MyHandle.AverageStringZ,'string','NaN');
                set(MyHandle.stdStringZ,'string','NaN');
            end
            return
        end
        
        switch(petizione.X_SEL(1))
            case 0
                return
            case 1
                DATI_X=SynchProfilePVs(TENUTI,petizione.X_SEL(3));
            case 2
                DATI_X=AdditionalNonStandardPVsMatrices{petizione.X_SEL(2)}(TENUTI,petizione.X_SEL(3));
            case 3
                DATI_X=NotSynchProfilePVs(TENUTI,petizione.X_SEL(3));
            case 4
                DATI_X=ScalarsBuffer(TENUTI,petizione.X_SEL(3));
            case 5
                DATI_X= PulseIDMatrix(TENUTI);
            case 6
                DATI_X= TimeStampsMatrix(TENUTI);
            case 7
                DATI_X= AbsoluteEventCounterMatrix(TENUTI);
            case 8
                DATI_X= ScanBuffer(TENUTI,petizione.X_SEL(3));
        end
        
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
        
        switch(petizione.Z_SEL(1))
            case 0
                return
            case 1
                DATI_Z=SynchProfilePVs(TENUTI,petizione.Z_SEL(3));
            case 2
                DATI_Z=AdditionalNonStandardPVsMatrices{petizione.Z_SEL(2)}(TENUTI,petizione.Z_SEL(3));
            case 3
                DATI_Z=NotSynchProfilePVs(TENUTI,petizione.Z_SEL(3));
            case 4
                DATI_Z=ScalarsBuffer(TENUTI,petizione.Z_SEL(3));
            case 5
                DATI_Z= PulseIDMatrix(TENUTI);
            case 6
                DATI_Z= TimeStampsMatrix(TENUTI);
            case 7
                DATI_Z= AbsoluteEventCounterMatrix(TENUTI);
            case 8
                DATI_Z= ScanBuffer(TENUTI,petizione.Z_SEL(3));
        end
        
        if(petizione.MomentsON )
            XAVG=mean(DATI_X);
            XSTD=std(DATI_X);
            YAVG=mean(DATI_Y);
            YSTD=std(DATI_Y);
            ZAVG=mean(DATI_Z);
            ZSTD=std(DATI_Z);
            if(petizione.MomentsON)
                set(MyHandle.AverageStringX,'string',num2str(XAVG));
                set(MyHandle.stdStringX,'string',num2str(XSTD));
                set(MyHandle.AverageStringY,'string',num2str(YSTD));
                set(MyHandle.stdStringY,'string',num2str(YSTD));
                set(MyHandle.AverageStringZ,'string',num2str(ZSTD));
                set(MyHandle.stdStringZ,'string',num2str(ZSTD));
            end
        end
        
        if(petizione.TypeOfPlot==1) % Markers
            
            grid(MyHandle.axes1,'on')
            plot3(MyHandle.axes1,DATI_X,DATI_Y,DATI_Z,'k.');
            CurrLimX=xlim(MyHandle.axes1);
            CurrLimY=ylim(MyHandle.axes1);
            CurrLimZ=zlim(MyHandle.axes1);
            
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
            if(~petizione.b_autoZ)
                if(~isnan(petizione.lim_z1)), CurrLimZ(1)=petizione.lim_z1; end
                if(~isnan(petizione.lim_z2)), CurrLimZ(2)=petizione.lim_z2; end
                zlim(MyHandle.axes1,CurrLimZ);
            end
            
        elseif(petizione.TypeOfPlot==2) %PlotAs2dmap
            
            grid(MyHandle.axes1,'off')
            Mx=max(DATI_X);mx=min(DATI_X);my=min(DATI_Y);My=max(DATI_Y);mz=min(DATI_Z);Mz=max(DATI_Z);
            
            if(~petizione.b_autoX)
                if(~isnan(petizione.lim_x1)), mx=petizione.lim_x1; end
                if(~isnan(petizione.lim_x2)), Mx=petizione.lim_x2; end;
            end
            if(~petizione.b_autoY)
                if(~isnan(petizione.lim_y1)), my=petizione.lim_y1; end
                if(~isnan(petizione.lim_y2)), My=petizione.lim_y2; end
            end
            if(~petizione.b_autoZ)
                if(~isnan(petizione.lim_z1)), mz=petizione.lim_z1; end
                if(~isnan(petizione.lim_z2)), Mz=petizione.lim_z2; end
            end
            Matrice=zeros(petizione.binsy,petizione.binsx);
            MatriceCounts=zeros(petizione.binsy,petizione.binsx);
            INDICIX=round(petizione.binsx*(DATI_X-mx)/(Mx-mx))+1;
            INDICIY=round(petizione.binsy*(DATI_Y-my)/(My-my))+1;
            OutOfBounds=0;
            for SS=1:length(DATI_X)
                if((INDICIX(SS)>=1) && (INDICIX(SS)<=petizione.binsx) && (INDICIY(SS)<=petizione.binsy) && (INDICIX(SS)>=1) )
                    Matrice(INDICIY(SS),INDICIX(SS))=Matrice(INDICIY(SS),INDICIX(SS))+DATI_Z(SS);
                    MatriceCounts(INDICIY(SS),INDICIX(SS))=MatriceCounts(INDICIY(SS),INDICIX(SS))+1;
                else
                    OutOfBounds=OutOfBounds+1;
                end
            end
            MatriceCounts(MatriceCounts==0)=1;
            Matrice=Matrice./MatriceCounts;
            imagesc(linspace(mx,Mx,petizione.binsx),linspace(my,My,petizione.binsy),Matrice,'parent',MyHandle.axes1);
            COLORBAR= colorbar('peer',MyHandle.axes1);
            xlim(MyHandle.axes1,[mx,Mx]);ylim(MyHandle.axes1,[my,My]);
            set(MyHandle.axes1,'ydir','normal')
            
        elseif(petizione.TypeOfPlot==3)
            grid(MyHandle.axes1,'off')
            if(~petizione.b_autoX)
                if(~isnan(petizione.lim_x1)), mx=petizione.lim_x1; end
                if(~isnan(petizione.lim_x2)), Mx=petizione.lim_x2; end;
                KEX=(DATI_X>=mx) & (DATI_X<=Mx);
            else
                KEX=true(size(DATI_X));
            end
            if(~petizione.b_autoY)
                if(~isnan(petizione.lim_y1)), my=petizione.lim_y1; end
                if(~isnan(petizione.lim_y2)), My=petizione.lim_y2; end
                KEY=(DATI_Y>=my) & (DATI_Y<=My);
            else
                KEY=true(size(DATI_Y));
            end
            XU=unique(DATI_X(KEX&KEY));
            YU=unique(DATI_Y(KEX&KEY));
            XU=XU(~isnan(XU));
            YU=YU(~isnan(YU));
            save TEMPX
            if(~isempty(XU) && ~isempty(YU))
                Mappa=zeros(length(YU),length(XU));
                for CountMappa1=1:length(XU)
                    for CountMappa2=1:length(YU)
                        Mappa(CountMappa2,CountMappa1)= mean(DATI_Z((DATI_X==XU(CountMappa1))&(DATI_Y==YU(CountMappa2))));
                    end
                end
                
                imagesc(linspace(min(YU),max(YU),length(YU)),linspace(min(XU),max(XU),length(XU)),Mappa,'parent',MyHandle.axes1);
                COLORBAR= colorbar('peer',MyHandle.axes1);
                ylim(MyHandle.axes1,[min(XU),max(XU)]);xlim(MyHandle.axes1,[min(YU),max(YU)]);
                set(MyHandle.axes1,'ydir','normal')
            end
        elseif(petizione.TypeOfPlot==4)
            grid(MyHandle.axes1,'off')
            if(~petizione.b_autoX)
                if(~isnan(petizione.lim_x1)), mx=petizione.lim_x1; end
                if(~isnan(petizione.lim_x2)), Mx=petizione.lim_x2; end;
                KEX=(DATI_X>=mx) & (DATI_X<=Mx);
            else
                KEX=true(size(DATI_X));
            end
            if(~petizione.b_autoY)
                if(~isnan(petizione.lim_y1)), my=petizione.lim_y1; end
                if(~isnan(petizione.lim_y2)), My=petizione.lim_y2; end
                KEY=(DATI_Y>=my) & (DATI_Y<=My);
            else
                KEY=true(size(DATI_Y));
            end
            XU=unique(DATI_X(KEX&KEY));
            YU=unique(DATI_Y(KEX&KEY));
            XU=XU(~isnan(XU));
            YU=YU(~isnan(YU));
            if(~isempty(XU) && ~isempty(YU))
                Mappa=zeros(length(YU),length(XU));
                for CountMappa1=1:length(XU)
                    for CountMappa2=1:length(YU)
                        Mappa(CountMappa2,CountMappa1)= mean(DATI_Z((DATI_X==XU(CountMappa1))&(DATI_Y==YU(CountMappa2))));
                    end
                end
                surf(MyHandle.axes1,XU,YU,Mappa)
            end
            
            
        end
        
        
    else %this runs in fully asynchronous mode
        
        %         AbsoluteEventCounterMatrix <-AbsoluteEventCounterMatrix
        %         AbsoluteEventCounterProfiles <-AcquisitionBufferCycle
        %         FullPulseIDMatrix <- PulseIDMatrix
        %         FullPulseIDProfiles <- TimeStampsMatrix
        
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
                    PID_Y=mod((PulseIDMatrix{1}(:,petizione.Y_SEL(3))+ petizione.Y_PID_DELAY),131040);
                    ABS_Y=AbsoluteEventCounterMatrix{1}(:,petizione.Y_SEL(3));
                end
                
                
                
                
                
            case 2
                DATI_Y=AdditionalNonStandardPVsMatrices{petizione.Y_SEL(2)}(:,petizione.Y_SEL(3));
                PID_Y=mod((PulseIDMatrix{2}(:,petizione.Y_SEL(2))+ petizione.Y_PID_DELAY),131040);
                ABS_Y=AbsoluteEventCounterMatrix{2}(:,petizione.Y_SEL(2));
            case 3
                DATI_Y=NotSynchProfilePVs(:,petizione.Y_SEL(3));
                PID_Y=mod((PulseIDMatrix{3}(:,petizione.Y_SEL(3))+ petizione.Y_PID_DELAY),131040);
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
                PID_Y=mod((PulseIDMatrix{1}(8,petizione.Y_SEL(3))+ petizione.Y_PID_DELAY),131040);
                ABS_Y=AbsoluteEventCounterMatrix{8}(:,petizione.Y_SEL(3));
        end
        
        switch(petizione.Z_SEL(1))
            case 0
                return
            case 1
                
                if(ScalarsBuffer)
                    DATI_Z=SynchProfilePVs(:,petizione.Z_SEL(3));
                    PID_Z=mod((PulseIDMatrix{1}+ 0),131040);
                    ABS_Z=AbsoluteEventCounterMatrix{1};
                else
                    DATI_Z=SynchProfilePVs(:,petizione.Z_SEL(3));
                    PID_Z=mod((PulseIDMatrix{1}(:,petizione.Z_SEL(3))+ petizione.Z_PID_DELAY),131040);
                    ABS_Z=AbsoluteEventCounterMatrix{1}(:,petizione.Z_SEL(3));
                end
                
                
                
            case 2
                DATI_Z=AdditionalNonStandardPVsMatrices{petizione.Z_SEL(2)}(:,petizione.Z_SEL(3));
                PID_Z=mod((PulseIDMatrix{2}(:,petizione.Z_SEL(2))+ petizione.Z_PID_DELAY),131040);
                ABS_Z=AbsoluteEventCounterMatrix{2}(:,petizione.Z_SEL(2));
            case 3
                DATI_Z=NotSynchProfilePVs(:,petizione.Z_SEL(3));
                PID_Z=mod((PulseIDMatrix{3}(:,petizione.Z_SEL(3))+ petizione.Z_PID_DELAY),131040);
                ABS_Z=AbsoluteEventCounterMatrix{3}(:,petizione.Z_SEL(3));
            case 4
                return
            case 5
                return
            case 6
                return
            case 7
                return
            case 8
                DATI_Z= ScanBuffer(:,petizione.Z_SEL(3));
                PID_Z=mod((PulseIDMatrix{8}(:,petizione.Z_SEL(3))+ petizione.Z_PID_DELAY),131040);
                ABS_Z=AbsoluteEventCounterMatrix{8}(:,petizione.Z_SEL(3));
        end
        
        DATI_X=DATI_X(~isnan(ABS_X));
        DATI_Y=DATI_Y(~isnan(ABS_Y));
        DATI_Z=DATI_Z(~isnan(ABS_Z));
        
        IPID=intersect(PID_X,PID_Y);
        IPID=intersect(PID_Z,IPID);
        [~,DX,~]=intersect(PID_X,IPID);
        [~,DY,~]=intersect(PID_Y,IPID);
        [~,DZ,~]=intersect(PID_Z,IPID);
        
        if(petizione.MomentsON )
            XAVG=mean(DATI_X);
            XSTD=std(DATI_X);
            YAVG=mean(DATI_Y);
            YSTD=std(DATI_Y);
            ZAVG=mean(DATI_Z);
            ZSTD=std(DATI_Z);
            if(petizione.MomentsON)
                set(MyHandle.AverageStringX,'string',num2str(XAVG));
                set(MyHandle.stdStringX,'string',num2str(XSTD));
                set(MyHandle.AverageStringY,'string',num2str(YSTD));
                set(MyHandle.stdStringY,'string',num2str(YSTD));
                set(MyHandle.AverageStringZ,'string',num2str(ZSTD));
                set(MyHandle.stdStringZ,'string',num2str(ZSTD));
            end
        end
        
        if(~isempty(DX))
            
            if(petizione.TypeOfPlot==1 ) % Markers
                
                plot3(MyHandle.axes1,DATI_X(DX),DATI_Y(DY),DATI_Z(DZ),'k.');
                CurrLimX=xlim(MyHandle.axes1);
                CurrLimY=ylim(MyHandle.axes1);
                CurrLimZ=zlim(MyHandle.axes1);
                grid(MyHandle.axes1,'on')
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
                if(~petizione.b_autoZ)
                    if(~isnan(petizione.lim_z1)), CurrLimZ(1)=petizione.lim_z1; end
                    if(~isnan(petizione.lim_z2)), CurrLimZ(2)=petizione.lim_z2; end
                    zlim(MyHandle.axes1,CurrLimZ);
                end
            elseif(petizione.TypeOfPlot==2)
                grid(MyHandle.axes1,'off')
                DATI_X=DATI_X(DX);DATI_Y=DATI_Y(DY);DATI_Z=DATI_Z(DZ);
                Mx=max(DATI_X);mx=min(DATI_X);my=min(DATI_Y);My=max(DATI_Y);%mz=min(DATI_Z);Mz=max(DATI_Z);
                
                if(~petizione.b_autoX)
                    if(~isnan(petizione.lim_x1)), mx=petizione.lim_x1; end
                    if(~isnan(petizione.lim_x2)), Mx=petizione.lim_x2; end;
                end
                if(~petizione.b_autoY)
                    if(~isnan(petizione.lim_y1)), my=petizione.lim_y1; end
                    if(~isnan(petizione.lim_y2)), My=petizione.lim_y2; end
                end
                if(~petizione.b_autoZ)
                    if(~isnan(petizione.lim_z1)), mz=petizione.lim_z1; end
                    if(~isnan(petizione.lim_z2)), Mz=petizione.lim_z2; end
                end
                Matrice=zeros(petizione.binsy,petizione.binsx);
                MatriceCounts=zeros(petizione.binsy,petizione.binsx);
                INDICIX=round(petizione.binsx*(DATI_X-mx)/(Mx-mx))+1;
                INDICIY=round(petizione.binsy*(DATI_Y-my)/(My-my))+1;
                OutOfBounds=0;
                for SS=1:length(DATI_X)
                    if((INDICIX(SS)>=1) && (INDICIX(SS)<=petizione.binsx) && (INDICIY(SS)<=petizione.binsy) && (INDICIX(SS)>=1) )
                        Matrice(INDICIY(SS),INDICIX(SS))=Matrice(INDICIY(SS),INDICIX(SS))+DATI_Z(SS);
                        MatriceCounts(INDICIY(SS),INDICIX(SS))=MatriceCounts(INDICIY(SS),INDICIX(SS))+1;
                    else
                        OutOfBounds=OutOfBounds+1;
                    end
                end
                MatriceCounts(MatriceCounts==0)=1;
                Matrice=Matrice./MatriceCounts;
                imagesc(linspace(mx,Mx,petizione.binsx),linspace(my,My,petizione.binsy),Matrice,'parent',MyHandle.axes1);
                colorbar('peer',MyHandle.axes1);
                xlim(MyHandle.axes1,[mx,Mx]);ylim(MyHandle.axes1,[my,My]);
                set(MyHandle.axes1,'ydir','normal')
                
            elseif(petizione.TypeOfPlot==3)
                grid(MyHandle.axes1,'off');
                DATI_X=DATI_X(DX);DATI_Y=DATI_Y(DY);DATI_Z=DATI_Z(DZ);
                if(~petizione.b_autoX)
                    if(~isnan(petizione.lim_x1)), mx=petizione.lim_x1; end
                    if(~isnan(petizione.lim_x2)), Mx=petizione.lim_x2; end;
                    KEX=(DATI_X>=mx) & (DATI_X<=Mx);
                else
                    KEX=true(size(DATI_X));
                end
                if(~petizione.b_autoY)
                    if(~isnan(petizione.lim_y1)), my=petizione.lim_y1; end
                    if(~isnan(petizione.lim_y2)), My=petizione.lim_y2; end
                    KEY=(DATI_Y>=my) & (DATI_Y<=My);
                else
                    KEY=true(size(DATI_Y));
                end
                XU=unique(DATI_X(KEX&KEY));
                YU=unique(DATI_Y(KEX&KEY));
                XU=XU(~isnan(XU));
                YU=YU(~isnan(YU));
                if(~isempty(XU) && ~isempty(YU))
                    Mappa=zeros(length(YU),length(XU));
                    for CountMappa1=1:length(XU)
                        for CountMappa2=1:length(YU)
                            Mappa(CountMappa2,CountMappa1)= mean(DATI_Z((DATI_X==XU(CountMappa1))&(DATI_Y==YU(CountMappa2))));
                        end
                    end
                    
                    imagesc(linspace(min(YU),max(YU),length(YU)),linspace(min(XU),max(XU),length(XU)),Mappa,'parent',MyHandle.axes1);
                    COLORBAR= colorbar('peer',MyHandle.axes1);
                    ylim(MyHandle.axes1,[min(XU),max(XU)]);xlim(MyHandle.axes1,[min(YU),max(YU)]);
                    set(MyHandle.axes1,'ydir','normal')
                end
            elseif(petizione.TypeOfPlot==4)
                DATI_X=DATI_X(DX);DATI_Y=DATI_Y(DY);DATI_Z=DATI_Z(DZ);
                grid(MyHandle.axes1,'on')
                if(~petizione.b_autoX)
                    if(~isnan(petizione.lim_x1)), mx=petizione.lim_x1; end
                    if(~isnan(petizione.lim_x2)), Mx=petizione.lim_x2; end;
                    KEX=(DATI_X>=mx) & (DATI_X<=Mx);
                else
                    KEX=true(size(DATI_X));
                end
                if(~petizione.b_autoY)
                    if(~isnan(petizione.lim_y1)), my=petizione.lim_y1; end
                    if(~isnan(petizione.lim_y2)), My=petizione.lim_y2; end
                    KEY=(DATI_Y>=my) & (DATI_Y<=My);
                else
                    KEY=true(size(DATI_Y));
                end
                XU=unique(DATI_X(KEX&KEY));
                YU=unique(DATI_Y(KEX&KEY));
                XU=XU(~isnan(XU));
                YU=YU(~isnan(YU));
                if(~isempty(XU) && ~isempty(YU))
                    Mappa=zeros(length(YU),length(XU));
                    for CountMappa1=1:length(XU)
                        for CountMappa2=1:length(YU)
                            Mappa(CountMappa2,CountMappa1)= mean(DATI_Z((DATI_X==XU(CountMappa1))&(DATI_Y==YU(CountMappa2))));
                        end
                    end
                    surf(MyHandle.axes1,XU,YU,Mappa)
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
            set(MyHandle.IdatiStanQua,'userdata',petizione);
        end
        NuovaFigura=figure;
        copyobj(MyHandle.axes1,NuovaFigura);
        %save TEMP
        CHILDREN=get(NuovaFigura,'children');
        if(petizione.TypeOfPlot==1)
            set(CHILDREN(1),'position',[12.5 4 88 26]);
        else
            set(CHILDREN(1),'position',[12.5 4 82 26]);
        end
        title(CHILDREN(1),titlestring)
        %        TEMPLABEL=ylabel(CHILDREN(1),'Waveform intensity [Arb. Units]');
        %        TEMPLABELPOS=get(TEMPLABEL,'Position');
        %        TLXLIM=xlim(CHILDREN(1));
        %        TEMPLABELPOS(1)=TLXLIM(2)+diff(TLXLIM)/15;
        %        set(TEMPLABEL,'Position',TEMPLABELPOS);
        IV=get(MyHandle.X_SEL,'value');
        IS=get(MyHandle.X_SEL,'string');
        str1=IS{IV};
        IV=get(MyHandle.Y_SEL,'value');
        IS=get(MyHandle.Y_SEL,'string');
        str2=IS{IV};
        IV=get(MyHandle.Z_SEL,'value');
        IS=get(MyHandle.Z_SEL,'string');
        str3=IS{IV};
        if(petizione.TypeOfPlot==1) %3d plot, 3 assi
            TLX=xlabel(CHILDREN(1),str1,'fontsize',12);
            TLY=ylabel(CHILDREN(1),str2,'fontsize',12);
            TLZ=zlabel(CHILDREN(1),str3,'fontsize',12);
            set(TLX,'rotation',15);
            set(TLY,'rotation',-27);
            grid(CHILDREN(1),'on')
            try
                util_printLog(NuovaFigura,'title',[str3,' vs ',str2,',',str1]);
            end
        elseif((petizione.TypeOfPlot==2) || (petizione.TypeOfPlot==3) || (petizione.TypeOfPlot==4)) %2d plot, 2 assi
            colorbar('peer',CHILDREN(1))
            grid(CHILDREN(1),'off')
            TLX=xlabel(CHILDREN(1),str1,'fontsize',12);
            TLY=ylabel(CHILDREN(1),str2,'fontsize',12);
            if(petizione.TypeOfPlot==4)
               grid(CHILDREN(1),'on') 
            end
            try
                util_printLog(NuovaFigura,'title',[str3,' vs ',str2,',',str1]);
            end
        end
        %        TLX=xlabel(CHILDREN(1),str1);
        %        TLY=ylabel(CHILDREN(2),str2);
        %        TLZ=zlabel(CHILDREN(3),str3);
        
        petizione.logbook_only=0;
        set(MyHandle.IdatiStanQua,'userdata',petizione);
    end
    
    
end
