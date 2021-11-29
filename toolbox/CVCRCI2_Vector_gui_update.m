function CVCRCI2_Vector_gui_update(Initialize, SynchMode, MyHandle,StrutturaDatiFull,PulseIDMatrix,TimeStampsMatrix,AbsoluteEventCounterMatrix,ProfileBuffer,SynchProfilePVs,NotSynchProfilePVs,AdditionalNonStandardPVsMatrices,FiltersBuffer,ScalarsBuffer,ScanBuffer,AcquisitionBufferCycle,AcquisitionTotalSynchronousEvents,AcquisitionBufferNextWrittenElement,AcquisitionBufferLastWrittenElement)
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
 
        if(~isnan(petizione.lim_x1)), set(MyHandle.e_x1,'string',num2str(petizione.lim_x1)); else set(MyHandle.e_x1,'string',num2str([])); end
        if(~isnan(petizione.lim_x2)), set(MyHandle.e_x2,'string',num2str(petizione.lim_x2)); else set(MyHandle.e_x2,'string',num2str([])); end
        if(~isnan(petizione.lim_y1)), set(MyHandle.e_y1,'string',num2str(petizione.lim_y1)); else set(MyHandle.e_y1,'string',num2str([])); end
        if(~isnan(petizione.lim_y2)), set(MyHandle.e_y2,'string',num2str(petizione.lim_y2)); else set(MyHandle.e_y2,'string',num2str([])); end
        set(MyHandle.TOM,'value',petizione.MomentsON);
        
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
        
        set(MyHandle.CalibLinear,'string',num2str(petizione.calib));
        set(MyHandle.CalibCenter,'string',num2str(petizione.center));
        set(MyHandle.TOM,'value',petizione.MomentsON);
        set(MyHandle.TOFWHM,'value',petizione.FWHMON);
        set(MyHandle.TOPEAK,'value',petizione.PEAKON);
        set(MyHandle.Show_AVG,'value',petizione.ShowAVGON);
        set(MyHandle.ShowAverageON,'value',petizione.ShowAVGLASTON);
        set(MyHandle.ShowSingles,'value',petizione.ShowLASTON);
        set(MyHandle.HMAVG,'string',num2str(petizione.HMAVG));
        set(MyHandle.HMSingles,'string',num2str(petizione.HMSingles));
        set(MyHandle.plot1style,'string',petizione.plot1style);
        set(MyHandle.plot2style,'string',petizione.plot2style);
        set(MyHandle.plot3style,'string',petizione.plot3style);
        set(MyHandle.plot1lw,'string',num2str(petizione.plot1lw));
        set(MyHandle.plot2lw,'string',num2str(petizione.plot2lw));
        set(MyHandle.plot3lw,'string',num2str(petizione.plot3lw));  
        set(MyHandle.S1,'value',petizione.S1); set(MyHandle.S2,'value',petizione.S2); set(MyHandle.S3,'value',petizione.S3);
        set(MyHandle.S1MASK,'string',['[',num2str(petizione.S1MASK(1)) ,',',num2str(petizione.S1MASK(2)) ,']']);
        set(MyHandle.S2MASK,'string',['[',num2str(petizione.S2MASK(1)) ,',',num2str(petizione.S2MASK(2)) ,']']);
        set(MyHandle.S3MASK,'string',['[',num2str(petizione.S3MASK(1)) ,',',num2str(petizione.S3MASK(2)) ,']']);
        set(MyHandle.UseCalibration,'value',petizione.UseCalibration);
        set(MyHandle.IdatiStanQua,'userdata',petizione);
    end
else
    petizione=get(MyHandle.IdatiStanQua,'userdata'); 
    % da controllare se e' il primo giro, se no... insomma un caos
    if(SynchMode==1)
        %disp('update in synch mode')
         cla(MyHandle.axes1,'reset');
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
        DATAMATRIX=get(MyHandle.RT,'data');
        THREEBYTHREE=get(MyHandle.STABLE,'data');
        if(isempty(TENUTI) || (~petizione.V_SEL(1)))
            if(petizione.MomentsON )
                DATAMATRIX{1,1}=NaN;DATAMATRIX{1,2}=NaN;DATAMATRIX{1,3}=NaN;
                DATAMATRIX{2,1}=NaN;DATAMATRIX{2,2}=NaN;DATAMATRIX{2,3}=NaN;
            end
            if(petizione.FWHMON )
                DATAMATRIX{3,1}=NaN;DATAMATRIX{3,2}=NaN;DATAMATRIX{3,3}=NaN;
            end
            if(petizione.PEAKON )
                DATAMATRIX{4,1}=NaN;DATAMATRIX{4,2}=NaN;DATAMATRIX{4,3}=NaN;
                DATAMATRIX{5,1}=NaN;DATAMATRIX{5,2}=NaN;DATAMATRIX{5,3}=NaN;
            end
            set(MyHandle.RT,'data',DATAMATRIX);
            if(petizione.S1)
                THREEBYTHREE{1,1}=NaN;THREEBYTHREE{1,2}=NaN;THREEBYTHREE{1,3}=NaN;
            end
            if(petizione.S2)
                THREEBYTHREE{2,1}=NaN;THREEBYTHREE{2,2}=NaN;THREEBYTHREE{2,3}=NaN;
            end
            if(petizione.S3)
                THREEBYTHREE{3,1}=NaN;THREEBYTHREE{3,2}=NaN;THREEBYTHREE{3,3}=NaN;
            end
            set(MyHandle.RT,'data',DATAMATRIX);
            set(MyHandle.STABLE,'data',THREEBYTHREE);
            return
        end
       
        [SA,SB]=size(ProfileBuffer{petizione.V_SEL(2)});
        
        if(~isempty(petizione.calib))
            ASSE=((1:SB)-SB/2)*petizione.calib;
            if(~isempty(petizione.center))
               ASSE=ASSE+petizione.center ;
            end
        else
            ASSE=1:SB;
        end
        
        if(petizione.UseCalibration)
           ASSEMOMENTI=ASSE; 
        else
           ASSEMOMENTI=1:SB;
        end
        
        
        if(petizione.ShowAVGON) %Plot Average on Filtered
            MEDIA=mean(ProfileBuffer{petizione.V_SEL(2)}(TENUTI,:),1);
            plot(MyHandle.axes1,ASSE,MEDIA,petizione.plot1style,'linewidth',petizione.plot1lw);
            if(petizione.MomentsON)
                 DATAMATRIX{1,1}=ASSEMOMENTI*MEDIA.'/sum(MEDIA);
                 DATAMATRIX{2,1}=sqrt(ASSEMOMENTI.^2*MEDIA.'/sum(MEDIA) - DATAMATRIX{1,1}^2);
            end
            if(petizione.FWHMON)
                [MA,MB]=max(MEDIA);
                LP=find(MEDIA>MA/2,1,'first');
                MP=find(MEDIA>MA/2,1,'last');
                if((LP==1) || (MP==SB))
                    FWHM=NaN;
                else
                    if(isempty(petizione.calib) || ~petizione.UseCalibration)
                        FWHM=MP-LP+1;
                    else
                        FWHM=(MP-LP+1)*petizione.calib;
                    end
                end
                DATAMATRIX{3,1}=FWHM;
            end
            if(petizione.PEAKON)
                [MA,MB]=max(MEDIA);
                if(isempty(petizione.calib))
                    DATAMATRIX{5,1}=MB;
                else
                    DATAMATRIX{5,1}=ASSEMOMENTI(MB);
                end
                DATAMATRIX{4,1}=MA;
            end
        end
        if(petizione.ShowAVGLASTON)  %Plot Average on Filtered and last...
            if(sum(TENUTI)<=petizione.HMAVG)
                UltimiN=TENUTI;
            else
                [~,IB]=sort(AbsoluteEventCounterMatrix(TENUTI),'descend');
                UltimiN=IB(1:petizione.HMAVG);
            end
            MEDIA=mean(ProfileBuffer{petizione.V_SEL(2)}(UltimiN,:),1);
            plot(MyHandle.axes1,ASSE,MEDIA,petizione.plot2style,'linewidth',petizione.plot2lw);
            if(petizione.MomentsON)
                DATAMATRIX{1,2}=ASSEMOMENTI*MEDIA.'/sum(MEDIA);
                DATAMATRIX{2,2}=sqrt(ASSEMOMENTI.^2*MEDIA.'/sum(MEDIA) - DATAMATRIX{1,2}^2);
            end
            if(petizione.FWHMON)
                [MA,MB]=max(MEDIA);
                LP=find(MEDIA>MA/2,1,'first');
                MP=find(MEDIA>MA/2,1,'last');
                if((LP==1) || (MP==SB))
                    FWHM=NaN;
                else
                    if(isempty(petizione.calib) || ~petizione.UseCalibration)
                        FWHM=MP-LP+1;
                    else
                        FWHM=(MP-LP+1)*petizione.calib;
                    end
                end
                DATAMATRIX{3,2}=FWHM;
            end
            if(petizione.PEAKON)
                [MA,MB]=max(MEDIA);
                if(isempty(petizione.calib))
                    DATAMATRIX{5,2}=MB;
                else
                    DATAMATRIX{5,2}=ASSEMOMENTI(MB);
                end
                DATAMATRIX{4,2}=MA;
            end
        end
        if(petizione.ShowLASTON) %Plot the last N events after Filtering
            %save TEMP
            if(sum(TENUTI)<=petizione.HMSingles)
                UltimiN=TENUTI;
                ToBePlotted=length(TENUTI);
            else
                [~,IB]=sort(AbsoluteEventCounterMatrix(TENUTI),'descend');
                UltimiN=IB(1:petizione.HMSingles);
                ToBePlotted=petizione.HMSingles;
            end
            MEDIA=mean(ProfileBuffer{petizione.V_SEL(2)}(UltimiN(1),:),1);
%             size(ASSE)
%             ToBePlotted
%             
            
            for TT=1:ToBePlotted
%                 size(ProfileBuffer{petizione.V_SEL(2)}(UltimiN(TT),:))
%                 save TEMPOREX
               plot(MyHandle.axes1,ASSE,ProfileBuffer{petizione.V_SEL(2)}(UltimiN(TT),:),petizione.plot3style,'linewidth',petizione.plot3lw);  
            end
            if(petizione.MomentsON)
                DATAMATRIX{1,3}=ASSEMOMENTI*MEDIA.'/sum(MEDIA);
                DATAMATRIX{2,3}=sqrt(ASSEMOMENTI.^2*MEDIA.'/sum(MEDIA) - DATAMATRIX{1,3}^2);
            end
            if(petizione.FWHMON)
                [MA,MB]=max(MEDIA);
                LP=find(MEDIA>MA/2,1,'first');
                MP=find(MEDIA>MA/2,1,'last');
                if((LP==1) || (MP==SB))
                    FWHM=NaN;
                else
                    if(isempty(petizione.calib) || ~petizione.UseCalibration)
                        FWHM=MP-LP+1;
                    else
                        FWHM=(MP-LP+1)*petizione.calib;
                    end
                end
                DATAMATRIX{3,3}=FWHM;
            end
            if(petizione.PEAKON)
                [MA,MB]=max(MEDIA);
                if(isempty(petizione.calib))
                    DATAMATRIX{5,3}=MB;
                else
                    DATAMATRIX{5,3}=ASSEMOMENTI(MB);
                end
                DATAMATRIX{4,3}=MA;
            end
        end
        set(MyHandle.RT,'data',DATAMATRIX)
        
        if(petizione.S1)
           S1= mean(sum(ProfileBuffer{petizione.V_SEL(2)}(TENUTI,petizione.S1MASK(1):petizione.S1MASK(2)),2));
           THREEBYTHREE{1,1}=S1;
        end
        if(petizione.S2)
           S2= mean(sum(ProfileBuffer{petizione.V_SEL(2)}(TENUTI,petizione.S2MASK(1):petizione.S2MASK(2)),2));
           THREEBYTHREE{2,2}=S2;
        end
        if(petizione.S3)
           S3= mean(sum(ProfileBuffer{petizione.V_SEL(2)}(TENUTI,petizione.S3MASK(1):petizione.S3MASK(2)),2));
           THREEBYTHREE{3,3}=S3;
        end
        if(petizione.S1 && petizione.S2)
            THREEBYTHREE{1,2}=S1/S2;
            THREEBYTHREE{2,1}=S2/S1;
        end
        if(petizione.S1 && petizione.S3)
            THREEBYTHREE{1,3}=S1/S3;
            THREEBYTHREE{3,1}=S3/S1;
        end
        if(petizione.S2 && petizione.S3)
            THREEBYTHREE{2,3}=S2/S3;
            THREEBYTHREE{3,2}=S3/S2;
        end
        set(MyHandle.STABLE,'data',THREEBYTHREE);

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
    elseif(petizione.V_SEL(1))
        %disp('not ready yet, maybe never!')
        cla(MyHandle.axes1)
        hold(MyHandle.axes1,'on');
        
        %petizione.V_SEL
        
        %ProfileBuffer{petizione.V_SEL(2)}
        
        %         AbsoluteEventCounterMatrix <-AbsoluteEventCounterMatrix
        %         AbsoluteEventCounterProfiles <-AcquisitionBufferCycle
        %         FullPulseIDMatrix <- PulseIDMatrix
        %         FullPulseIDProfiles <- TimeStampsMatrix
        DATAMATRIX=get(MyHandle.RT,'data');
        THREEBYTHREE=get(MyHandle.STABLE,'data');
        
        TENUTI=~isnan(AcquisitionBufferCycle{petizione.V_SEL(2)});
        
        if(~any(TENUTI) || (~petizione.V_SEL(1)))
            if(petizione.MomentsON )
                DATAMATRIX{1,1}=NaN;DATAMATRIX{1,2}=NaN;DATAMATRIX{1,3}=NaN;
                DATAMATRIX{2,1}=NaN;DATAMATRIX{2,2}=NaN;DATAMATRIX{2,3}=NaN;
            end
            if(petizione.FWHMON )
                DATAMATRIX{3,1}=NaN;DATAMATRIX{3,2}=NaN;DATAMATRIX{3,3}=NaN;
            end
            if(petizione.PEAKON )
                DATAMATRIX{4,1}=NaN;DATAMATRIX{4,2}=NaN;DATAMATRIX{4,3}=NaN;
                DATAMATRIX{5,1}=NaN;DATAMATRIX{5,2}=NaN;DATAMATRIX{5,3}=NaN;
            end
            set(MyHandle.RT,'data',DATAMATRIX);
            if(petizione.S1)
                THREEBYTHREE{1,1}=NaN;THREEBYTHREE{1,2}=NaN;THREEBYTHREE{1,3}=NaN;
            end
            if(petizione.S2)
                THREEBYTHREE{2,1}=NaN;THREEBYTHREE{2,2}=NaN;THREEBYTHREE{2,3}=NaN;
            end
            if(petizione.S3)
                THREEBYTHREE{3,1}=NaN;THREEBYTHREE{3,2}=NaN;THREEBYTHREE{3,3}=NaN;
            end
            set(MyHandle.RT,'data',DATAMATRIX);
            set(MyHandle.STABLE,'data',THREEBYTHREE);
            return
        end
        
        [SA,SB]=size(ProfileBuffer{petizione.V_SEL(2)});
        
        if(~isempty(petizione.calib))
            ASSE=((1:SB)-SB/2)*petizione.calib;
            if(~isempty(petizione.center))
               ASSE=ASSE+petizione.center ;
            end
        else
            ASSE=1:SB;
        end
        
        if(petizione.UseCalibration)
           ASSEMOMENTI=ASSE; 
        else
           ASSEMOMENTI=1:SB;
        end 
        
        if(petizione.ShowAVGON) %Plot Average on Filtered
            MEDIA=mean(ProfileBuffer{petizione.V_SEL(2)}(TENUTI,:),1);
            plot(MyHandle.axes1,ASSE,MEDIA,petizione.plot1style,'linewidth',petizione.plot1lw);
            if(petizione.MomentsON)
                 DATAMATRIX{1,1}=ASSEMOMENTI*MEDIA.'/sum(MEDIA);
                 DATAMATRIX{2,1}=sqrt(ASSEMOMENTI.^2*MEDIA.'/sum(MEDIA) - DATAMATRIX{1,1}^2);
            end
            if(petizione.FWHMON)
                [MA,MB]=max(MEDIA);
                LP=find(MEDIA>MA/2,1,'first');
                MP=find(MEDIA>MA/2,1,'last');
                if((LP==1) || (MP==SB))
                    FWHM=NaN;
                else
                    if(isempty(petizione.calib) || ~petizione.UseCalibration)
                        FWHM=MP-LP+1;
                    else
                        FWHM=(MP-LP+1)*petizione.calib;
                    end
                end
                DATAMATRIX{3,1}=FWHM;
            end
            if(petizione.PEAKON)
                [MA,MB]=max(MEDIA);
                if(isempty(petizione.calib))
                    DATAMATRIX{5,1}=MB;
                else
                    DATAMATRIX{5,1}=ASSEMOMENTI(MB);
                end
                DATAMATRIX{4,1}=MA;
            end
        end
        
        if(petizione.ShowAVGLASTON)  %Plot Average on Filtered and last...
            if(sum(TENUTI)<=petizione.HMAVG)
                UltimiN=TENUTI;
            else
                [~,IB]=sort(AcquisitionBufferCycle{petizione.V_SEL(2)}(TENUTI),'descend');
                UltimiN=IB(1:petizione.HMAVG);
            end
            MEDIA=mean(ProfileBuffer{petizione.V_SEL(2)}(UltimiN,:),1);
            plot(MyHandle.axes1,ASSE,MEDIA,petizione.plot2style,'linewidth',petizione.plot2lw);
            if(petizione.MomentsON)
                DATAMATRIX{1,2}=ASSEMOMENTI*MEDIA.'/sum(MEDIA);
                DATAMATRIX{2,2}=sqrt(ASSEMOMENTI.^2*MEDIA.'/sum(MEDIA) - DATAMATRIX{1,2}^2);
            end
            if(petizione.FWHMON)
                [MA,MB]=max(MEDIA);
                LP=find(MEDIA>MA/2,1,'first');
                MP=find(MEDIA>MA/2,1,'last');
                if((LP==1) || (MP==SB))
                    FWHM=NaN;
                else
                    if(isempty(petizione.calib) || ~petizione.UseCalibration)
                        FWHM=MP-LP+1;
                    else
                        FWHM=(MP-LP+1)*petizione.calib;
                    end
                end
                DATAMATRIX{3,2}=FWHM;
            end
            if(petizione.PEAKON)
                [MA,MB]=max(MEDIA);
                if(isempty(petizione.calib))
                    DATAMATRIX{5,2}=MB;
                else
                    DATAMATRIX{5,2}=ASSEMOMENTI(MB);
                end
                DATAMATRIX{4,2}=MA;
            end
        end
        
        if(petizione.ShowLASTON) %Plot the last N events after Filtering
            %save TEMP
            if(sum(TENUTI)<=petizione.HMSingles)
                UltimiN=TENUTI;
                ToBePlotted=length(TENUTI);
            else
                [~,IB]=sort(AcquisitionBufferCycle{petizione.V_SEL(2)}(TENUTI),'descend');
                UltimiN=IB(1:petizione.HMSingles);
                ToBePlotted=petizione.HMSingles;
            end
            MEDIA=mean(ProfileBuffer{petizione.V_SEL(2)}(UltimiN(1),:),1);
            for TT=1:ToBePlotted
               plot(MyHandle.axes1,ASSE,ProfileBuffer{petizione.V_SEL(2)}(UltimiN(TT),:),petizione.plot3style,'linewidth',petizione.plot3lw);  
            end
            if(petizione.MomentsON)
                DATAMATRIX{1,3}=ASSEMOMENTI*MEDIA.'/sum(MEDIA);
                DATAMATRIX{2,3}=sqrt(ASSEMOMENTI.^2*MEDIA.'/sum(MEDIA) - DATAMATRIX{1,3}^2);
            end
            if(petizione.FWHMON)
                [MA,MB]=max(MEDIA);
                LP=find(MEDIA>MA/2,1,'first');
                MP=find(MEDIA>MA/2,1,'last');
                if((LP==1) || (MP==SB))
                    FWHM=NaN;
                else
                    if(isempty(petizione.calib) || ~petizione.UseCalibration)
                        FWHM=MP-LP+1;
                    else
                        FWHM=(MP-LP+1)*petizione.calib;
                    end
                end
                DATAMATRIX{3,3}=FWHM;
            end
            if(petizione.PEAKON)
                [MA,MB]=max(MEDIA);
                if(isempty(petizione.calib))
                    DATAMATRIX{5,3}=MB;
                else
                    DATAMATRIX{5,3}=ASSEMOMENTI(MB);
                end
                DATAMATRIX{4,3}=MA;
            end
        end
        
        set(MyHandle.RT,'data',DATAMATRIX)
        
        if(petizione.S1)
           S1= mean(sum(ProfileBuffer{petizione.V_SEL(2)}(TENUTI,petizione.S1MASK(1):petizione.S1MASK(2)),2));
           THREEBYTHREE{1,1}=S1;
        end
        if(petizione.S2)
           S2= mean(sum(ProfileBuffer{petizione.V_SEL(2)}(TENUTI,petizione.S2MASK(1):petizione.S2MASK(2)),2));
           THREEBYTHREE{2,2}=S2;
        end
        if(petizione.S3)
           S3= mean(sum(ProfileBuffer{petizione.V_SEL(2)}(TENUTI,petizione.S3MASK(1):petizione.S3MASK(2)),2));
           THREEBYTHREE{3,3}=S3;
        end
        if(petizione.S1 && petizione.S2)
            THREEBYTHREE{1,2}=S1/S2;
            THREEBYTHREE{2,1}=S2/S1;
        end
        if(petizione.S1 && petizione.S3)
            THREEBYTHREE{1,3}=S1/S3;
            THREEBYTHREE{3,1}=S3/S1;
        end
        if(petizione.S2 && petizione.S3)
            THREEBYTHREE{2,3}=S2/S3;
            THREEBYTHREE{3,2}=S3/S2;
        end
        set(MyHandle.STABLE,'data',THREEBYTHREE);

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
            xlim(MyHandle.axes1,CurrLimY);
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
       CHILDREN=get(NuovaFigura,'children');
       set(CHILDREN(1),'position',[12.5 3.5 75 24]);
       title(CHILDREN(1),titlestring)
       TEMPLABEL=ylabel(CHILDREN(1),'Waveform intensity [Arb. Units]');
       TEMPLABELPOS=get(TEMPLABEL,'Position');
       TLXLIM=xlim(CHILDREN(1));
       TEMPLABELPOS(1)=TLXLIM(2)+diff(TLXLIM)/15;
       set(TEMPLABEL,'Position',TEMPLABELPOS);
       IV=get(MyHandle.V_SEL,'value');
       IS=get(MyHandle.V_SEL,'string');
       str1=IS{IV};
       try  
           util_printLog(NuovaFigura,'title',str1);
       end
       petizione.logbook_only=0;
       set(MyHandle.IdatiStanQua,'userdata',petizione);
    end
    
    
end
