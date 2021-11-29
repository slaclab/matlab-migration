FMA=1;
ALL_PIDS_FOUND=[];
if(Init_Vars.NumberOfSynchPVs) % Questo e i profili e basta...
    PvsCue_PID=bitand(uint32(imag(PvsCue_TS(:,1:LastValidCueElement))),hex2dec('1FFFF'));
    
    if(S_Guaranteed(1)==1)
        CO=(PvsCue(S_Guaranteed(3),1:LastValidCueElement)>=ScanSetting.GuaranteedPV_MIN) & (PvsCue(S_Guaranteed(3),1:LastValidCueElement)<=ScanSetting.GuaranteedPV_MAX);
    end
    
    
    for TT=1:Init_Vars.NumberOfSynchPVs
        [Upid,DoveUpid]=unique(PvsCue_PID(TT,:),'stable');
        [Upid,DoveDiNuovo]=setdiff(Upid,LAST_VALID_PULSE_IDs{1}(TT),'stable');
        ALL_PIDS_FOUND=union(ALL_PIDS_FOUND,Upid);
        DOVE=DoveUpid(DoveDiNuovo);
        NewDataFoundLength=length(DOVE);
        if(NewDataFoundLength)
            
            if(NewDataFoundLength>AcquisitionBufferSpaceLeftThisBuffer{1}(TT))%??
               Destination=[FullAcquisitionBufferNextWrittenElement{1}(TT):Init_Vars.BufferSize,1:(NewDataFoundLength-AcquisitionBufferSpaceLeftThisBuffer{1}(TT))];
               FullAcquisitionBufferCycle{1}(TT)=FullAcquisitionBufferCycle{1}(TT)+1;
               FullAcquisitionBufferLastWrittenElement{1}(TT)=Destination(end);
               FullAcquisitionBufferNextWrittenElement{1}(TT)=FullAcquisitionBufferLastWrittenElement{1}(TT)+1;
               if(FullAcquisitionBufferNextWrittenElement{1}(TT) > Init_Vars.BufferSize)
                   FullAcquisitionBufferNextWrittenElement{1}(TT)=1;
               end
               AcquisitionBufferSpaceLeftThisBuffer{1}(TT)= Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{1}(TT) + 1;
            else
               Destination =  FullAcquisitionBufferNextWrittenElement{1}(TT):(FullAcquisitionBufferNextWrittenElement{1}(TT)+NewDataFoundLength-1);
               FullAcquisitionBufferLastWrittenElement{1}(TT)=FullAcquisitionBufferNextWrittenElement{1}(TT)+NewDataFoundLength-1;
               FullAcquisitionBufferNextWrittenElement{1}(TT)=FullAcquisitionBufferLastWrittenElement{1}(TT)+1;
               if(FullAcquisitionBufferNextWrittenElement{1}(TT) > Init_Vars.BufferSize)
                   FullAcquisitionBufferNextWrittenElement{1}(TT)=1;
                   FullAcquisitionBufferCycle{1}(TT)=FullAcquisitionBufferCycle{1}(TT)+1;
               end
               AcquisitionBufferSpaceLeftThisBuffer{1}(TT)= Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{1}(TT) + 1;
            end
        LAST_VALID_PULSE_IDs{1}(TT)= Upid(end);
        SynchProfilePVs(Destination,TT) = PvsCue(TT,DOVE).';
        FullPulseIDMatrix{1}(Destination,TT) = Upid;
        FullTimeStampsMatrix{1}(Destination,TT) = PvsCue_TS(TT,DOVE).'; 
        
        AbsoluteEventCounterMatrix{1}(Destination,TT) = AcquisitionTotalSynchronousEvents{1}(TT) + (1:NewDataFoundLength);
        AcquisitionTotalSynchronousEvents{1}(TT)=AcquisitionTotalSynchronousEvents{1}(TT) + NewDataFoundLength;
        if(FMA)
            MAXEVENTS=Destination(end);
            FMA=0;
        end
        
        end % se ha trovato qualcosa ... lo aggiunge
    end
end

if(Init_Vars.NumberOfProfiles) %profili
    ProfCue_PID=bitand(uint32(imag(ProfileCue_TS(:,1:LastValidCueElement))),hex2dec('1FFFF'));
    nextprofiletoinsert=1;
    nextscalarmatrixtoinsert=1;
    for TT=1:Init_Vars.NumberOfProfiles
        
        if(CycleVars(TT).Run_Post_Processing)
            
            
                if(ProcessedData(TT).NumberOfScalars)
                    [Upid,DoveUpid]=unique(ProcessedData(TT).PulseID,'stable');
                    [Upid,DoveDiNuovo]=setdiff(Upid,LAST_VALID_PULSE_IDs{2}(nextscalarmatrixtoinsert),'stable');
                    DOVE=DoveUpid(DoveDiNuovo);
                    ALL_PIDS_FOUND=union(ALL_PIDS_FOUND,Upid);
                    NewDataFoundLength=length(DOVE);
                    if(NewDataFoundLength)
                    if(NewDataFoundLength>AcquisitionBufferSpaceLeftThisBuffer{2}(nextscalarmatrixtoinsert))%??
                       Destination=[FullAcquisitionBufferNextWrittenElement{2}(nextscalarmatrixtoinsert):Init_Vars.BufferSize,1:(NewDataFoundLength-AcquisitionBufferSpaceLeftThisBuffer{2}(nextscalarmatrixtoinsert))];
                       FullAcquisitionBufferCycle{2}(nextscalarmatrixtoinsert)=FullAcquisitionBufferCycle{2}(nextscalarmatrixtoinsert)+1;
                       FullAcquisitionBufferLastWrittenElement{2}(nextscalarmatrixtoinsert)=Destination(end);
                       FullAcquisitionBufferNextWrittenElement{2}(nextscalarmatrixtoinsert)=FullAcquisitionBufferLastWrittenElement{2}(nextscalarmatrixtoinsert)+1;
                       if(FullAcquisitionBufferNextWrittenElement{2}(nextscalarmatrixtoinsert) > Init_Vars.BufferSize)
                           FullAcquisitionBufferNextWrittenElement{2}(nextscalarmatrixtoinsert)=1;
                       end
                       AcquisitionBufferSpaceLeftThisBuffer{2}(nextscalarmatrixtoinsert)= Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{2}(nextscalarmatrixtoinsert) + 1;
                    else
                       Destination =  FullAcquisitionBufferNextWrittenElement{2}(nextscalarmatrixtoinsert):(FullAcquisitionBufferNextWrittenElement{2}(nextscalarmatrixtoinsert)+NewDataFoundLength-1);
                       FullAcquisitionBufferLastWrittenElement{2}(nextscalarmatrixtoinsert)=FullAcquisitionBufferNextWrittenElement{2}(nextscalarmatrixtoinsert)+NewDataFoundLength-1;
                       FullAcquisitionBufferNextWrittenElement{2}(nextscalarmatrixtoinsert)=(FullAcquisitionBufferLastWrittenElement{2}(nextscalarmatrixtoinsert)+1);
                       if(FullAcquisitionBufferNextWrittenElement{2}(nextscalarmatrixtoinsert) > Init_Vars.BufferSize)
                           FullAcquisitionBufferNextWrittenElement{2}(nextscalarmatrixtoinsert)=1;
                           FullAcquisitionBufferCycle{2}(nextscalarmatrixtoinsert)=FullAcquisitionBufferCycle{2}(nextscalarmatrixtoinsert)+1;
                       end
                       AcquisitionBufferSpaceLeftThisBuffer{2}(nextscalarmatrixtoinsert)= Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{2}(nextscalarmatrixtoinsert) + 1;
                    end
                    
                    
                    ScalarBuffer{nextscalarmatrixtoinsert}(Destination,:)=ProcessedData(TT).Scalars(:,DOVE).';
                    FullPulseIDMatrix{2}(Destination,nextscalarmatrixtoinsert) = Upid;
                    if(CycleVars(TT).Processing_Comes_With_TimeStamps)
                       FullTimeStampsMatrix{2}(Destination,nextscalarmatrixtoinsert) = ProcessedData(II).TimeStamp(DOVE);
                    end   
                    
                    AbsoluteEventCounterMatrix{2}(Destination,nextscalarmatrixtoinsert) = AcquisitionTotalSynchronousEvents{2}{nextscalarmatrixtoinsert} + (1:NewDataFoundLength);
                    AcquisitionTotalSynchronousEvents{2}(nextscalarmatrixtoinsert)=AcquisitionTotalSynchronousEvents{2}{nextscalarmatrixtoinsert} + NewDataFoundLength;
                    if(FMA)
                        MAXEVENTS=Destination(end);
                        FMA=0;
                    end
                    
                    LAST_VALID_PULSE_IDs{2}(nextscalarmatrixtoinsert)=Upid(end);
                    nextscalarmatrixtoinsert=nextscalarmatrixtoinsert+1;
                    end
                end
                
                if(ProcessedData(TT).NumberOfVectors)
                        
                    [Upid,DoveUpid]=unique(ProcessedData(TT).PulseID,'stable');
                    [Upid,DoveDiNuovo]=setdiff(Upid,LAST_VALID_PULSE_IDsProfiles{nextprofiletoinsert},'stable');
                    DOVE=DoveUpid(DoveDiNuovo);
                    ALL_PIDS_FOUND=union(ALL_PIDS_FOUND,Upid);
                    NewDataFoundLength=length(DOVE);
                    if(NewDataFoundLength)
                    if(NewDataFoundLength>AcquisitionBufferSpaceLeftThisBufferProfiles{nextprofiletoinsert})%??
                       Destination=[FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}:Init_Vars.TrueBufSize(nextprofiletoinsert),1:(NewDataFoundLength-AcquisitionBufferSpaceLeftThisBufferProfiles{nextprofiletoinsert})];
                       FullAcquisitionBufferCycleProfiles{nextprofiletoinsert}=FullAcquisitionBufferCycleProfiles{nextprofiletoinsert}+1;
                       FullAcquisitionBufferLastWrittenElementProfiles{nextprofiletoinsert}=Destination(end);
                       FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}=FullAcquisitionBufferLastWrittenElementProfiles{nextprofiletoinsert}+1;
                       if(FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert} > Init_Vars.TrueBufSize(nextprofiletoinsert))
                           FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}=1;
                       end
                       AcquisitionBufferSpaceLeftThisBufferProfiles{nextprofiletoinsert}= Init_Vars.TrueBufSize(nextprofiletoinsert) - FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert} + 1;
                    else
                       Destination =  FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}:(FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}+NewDataFoundLength-1);
                       FullAcquisitionBufferLastWrittenElementProfiles{nextprofiletoinsert}=FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}+NewDataFoundLength-1;
                       FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}=(FullAcquisitionBufferLastWrittenElementProfiles{nextprofiletoinsert}+1);
                       if(FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert} > Init_Vars.TrueBufSize(nextprofiletoinsert))
                           FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}=1;
                           FullAcquisitionBufferCycleProfiles{nextprofiletoinsert}=FullAcquisitionBufferCycleProfiles{nextprofiletoinsert}+1;
                       end
                       AcquisitionBufferSpaceLeftThisBufferProfiles{nextprofiletoinsert}= Init_Vars.TrueBufSize(nextprofiletoinsert) - FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert} + 1;
                    end
                    
                    for YY=1:ProcessedData(TT).NumberOfVectors

                        ProfileBuffer{nextprofiletoinsert}(Destination,:) = ProcessedData(TT).Vectors{YY}(DOVE,:);
                        FullPulseIDProfiles{nextprofiletoinsert}(Destination) = Upid;
                        if(CycleVars(TT).Processing_Comes_With_TimeStamps)
                            FullTimeStampsProfiles{nextprofiletoinsert}(Destination) = ProcessedData(II).TimeStamp(DOVE);
                        end
                        LAST_VALID_PULSE_IDsProfiles{nextprofiletoinsert}=Upid(end);
                        
                        AbsoluteEventCounterProfiles{nextprofiletoinsert}(Destination) = AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert} + (1:NewDataFoundLength);
                        AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert}=AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert} + NewDataFoundLength;
                        if(FMA)
                            MAXEVENTS=Destination(end);
                            FMA=0;
                        end
                        
                        nextprofiletoinsert=nextprofiletoinsert+1;
                    end
                    
                    end
                end
                
                if(ProcessedData(TT).NumberOfArray2D)
                    
                    [Upid,DoveUpid]=unique(ProcessedData(TT).PulseID,'stable');
                    [Upid,DoveDiNuovo]=setdiff(Upid,LAST_VALID_PULSE_IDs{2}(nextscalarmatrixtoinsert),'stable');
                    DOVE=DoveUpid(DoveDiNuovo);
                    ALL_PIDS_FOUND=union(ALL_PIDS_FOUND,Upid);
                    NewDataFoundLength=length(DOVE);
                    if(NewDataFoundLength)
                    
                    
                    if(NewDataFoundLength>AcquisitionBufferSpaceLeftThisBufferProfiles{nextprofiletoinsert})%??
                       Destination=[FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}:Init_Vars.TrueBufSize(nextprofiletoinsert),1:(NewDataFoundLength-AcquisitionBufferSpaceLeftThisBufferProfiles{nextprofiletoinsert})];
                       FullAcquisitionBufferCycleProfiles{nextprofiletoinsert}=FullAcquisitionBufferCycleProfiles{nextprofiletoinsert}+1;
                       FullAcquisitionBufferLastWrittenElementProfiles{nextprofiletoinsert}=Destination(end);
                       FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}=FullAcquisitionBufferLastWrittenElementProfiles{nextprofiletoinsert}+1;
                       if(FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert} > Init_Vars.TrueBufSize(nextprofiletoinsert))
                           FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}=1;
                       end
                       AcquisitionBufferSpaceLeftThisBufferProfiles{nextprofiletoinsert}= Init_Vars.TrueBufSize(nextprofiletoinsert) - FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert} + 1;
                    else
                       Destination =  FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}:(FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}+NewDataFoundLength-1);
                       FullAcquisitionBufferLastWrittenElementProfiles{nextprofiletoinsert}=FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}+NewDataFoundLength-1;
                       FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}=(FullAcquisitionBufferLastWrittenElementProfiles{nextprofiletoinsert}+1);
                       if(FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert} > Init_Vars.TrueBufSize(nextprofiletoinsert))
                           FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}=1;
                           FullAcquisitionBufferCycleProfiles{nextprofiletoinsert}=FullAcquisitionBufferCycleProfiles{nextprofiletoinsert}+1;
                       end
                       AcquisitionBufferSpaceLeftThisBufferProfiles{nextprofiletoinsert}= Init_Vars.TrueBufSize(nextprofiletoinsert) - FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert} + 1;
                    end
                    
                    for YY=1:ProcessedData(TT).NumberOfArray2D
                        ProfileBuffer{nextprofiletoinsert}(:,:,Destination) = ProcessedData(TT).Array2D{YY}(:,:,DOVE);
                        FullPulseIDProfiles{nextprofiletoinsert}(Destination) = Upid;
                        if(CycleVars(TT).Processing_Comes_With_TimeStamps)
                            FullTimeStampsProfiles{nextprofiletoinsert}(Destination) = ProcessedData(II).TimeStamp(DOVE);
                        end
                        AbsoluteEventCounterProfiles{nextprofiletoinsert}(Destination) = AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert} + (1:NewDataFoundLength);
                        AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert}=AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert} + NewDataFoundLength;
                        if(FMA)
                            MAXEVENTS=Destination(end);
                            FMA=0;
                        end
                        LAST_VALID_PULSE_IDsProfiles{nextprofiletoinsert}=Upid(end);
                        nextprofiletoinsert=nextprofiletoinsert+1;
                    end
                    
                    end
                    
                end
            
            
        else % QUESTI SONO I PROFILI NORMALI !!!
            [Upid,DoveUpid]=unique(ProfCue_PID(TT,1:LastValidCueElement),'stable');
            [Upid,DoveDiNuovo]=setdiff(Upid,LAST_VALID_PULSE_IDsProfiles{nextprofiletoinsert},'stable');
            DOVE=DoveUpid(DoveDiNuovo);
            ALL_PIDS_FOUND=union(ALL_PIDS_FOUND,Upid);
            NewDataFoundLength=length(DOVE);
            
            if(NewDataFoundLength)
            
                    if(NewDataFoundLength>AcquisitionBufferSpaceLeftThisBufferProfiles{nextprofiletoinsert})%??
                       Destination=[FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}:Init_Vars.TrueBufSize(nextprofiletoinsert),1:(NewDataFoundLength-AcquisitionBufferSpaceLeftThisBufferProfiles{nextprofiletoinsert})];
                       FullAcquisitionBufferCycleProfiles{nextprofiletoinsert}=FullAcquisitionBufferCycleProfiles{nextprofiletoinsert}+1;
                       FullAcquisitionBufferLastWrittenElementProfiles{nextprofiletoinsert}=Destination(end);
                       FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}=FullAcquisitionBufferLastWrittenElementProfiles{nextprofiletoinsert}+1;
                       if(FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert} > Init_Vars.TrueBufSize(nextprofiletoinsert))
                           FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}=1;
                       end
                       AcquisitionBufferSpaceLeftThisBufferProfiles{nextprofiletoinsert}= Init_Vars.TrueBufSize(nextprofiletoinsert) - FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert} + 1;
                    else
                       Destination =  FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}:(FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}+NewDataFoundLength-1);
                       FullAcquisitionBufferLastWrittenElementProfiles{nextprofiletoinsert}=FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}+NewDataFoundLength-1;
                       FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}=(FullAcquisitionBufferLastWrittenElementProfiles{nextprofiletoinsert}+1);
                       if(FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert} > Init_Vars.TrueBufSize(nextprofiletoinsert))
                           FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert}=1;
                           FullAcquisitionBufferCycleProfiles{nextprofiletoinsert}=FullAcquisitionBufferCycleProfiles{nextprofiletoinsert}+1;
                       end
                       AcquisitionBufferSpaceLeftThisBufferProfiles{nextprofiletoinsert}= Init_Vars.TrueBufSize(nextprofiletoinsert) - FullAcquisitionBufferNextWrittenElementProfiles{nextprofiletoinsert} + 1;
                    end
            
            
            
                if(CycleVars(TT).Do_ROI)
                    TemporaryData = ProfileCue{TT}(DOVE,CycleVars(TT).ROI_Elements_Position);
                else
                    TemporaryData = ProfileCue{TT}(DOVE,:);
                end
                if(any(CycleVars(TT).Background))
                    TemporaryData=TemporaryData-ones(NewDataFoundLength,1)*CycleVars(TT).Background;
                end
                if(CycleVars(TT).DoReshape)
                   TemporaryData=reshape(TemporaryData.',[CycleVars(TT).ROIReshapeSize,NewDataFoundLength]); 
                end
                
                if(CycleVars(TT).FullData) %Full Data to be stored
                    if(CycleVars(TT).FullTrueImage) % never, ever transpose a true image.
                        ProfileBuffer{nextprofiletoinsert}(:,:,Destination) = TemporaryData;
                    else
                        if(CycleVars(TT).FullTranspose)
                            ProfileBuffer{nextprofiletoinsert}(Destination,:) = permute(TemporaryData,[3,2,1]);
                        else
                            ProfileBuffer{nextprofiletoinsert}(Destination,:) = permute(TemporaryData,[3,1,2]);
                        end
                    end
                    
                    FullPulseIDProfiles{nextprofiletoinsert}(Destination) = Upid;
                    FullTimeStampsProfiles{nextprofiletoinsert}(Destination) = ProfileCue_TS(TT,DOVE);
                    %aggiungi pulse ID e Timestamp
                    
                    LAST_VALID_PULSE_IDsProfiles{nextprofiletoinsert}=Upid(end);
                    AbsoluteEventCounterProfiles{nextprofiletoinsert}(Destination) = AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert} + (1:NewDataFoundLength);
                        AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert}=AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert} + NewDataFoundLength;
                        if(FMA)
                            MAXEVENTS=Destination(end);
                            FMA=0;
                        end
                    nextprofiletoinsert=nextprofiletoinsert+1;
                end
                
                if(CycleVars(TT).ProjectionX) %Projection X to be stored
                   if(CycleVars(TT).XTranspose)
                       ProfileBuffer{nextprofiletoinsert}(Destination,:) = permute(sum(TemporaryData,1),[3,1,2]);
                   else
                       ProfileBuffer{nextprofiletoinsert}(Destination,:) = permute(sum(TemporaryData,1),[3,2,1]);
                   end
                   FullPulseIDProfiles{nextprofiletoinsert}(Destination) = Upid;
                   FullTimeStampsProfiles{nextprofiletoinsert}(Destination) = ProfileCue_TS(TT,DOVE);
                    
                   LAST_VALID_PULSE_IDsProfiles{nextprofiletoinsert}=Upid(end);
                   AbsoluteEventCounterProfiles{nextprofiletoinsert}(Destination) = AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert} + (1:NewDataFoundLength);
                        AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert}=AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert} + NewDataFoundLength;
                        if(FMA)
                            MAXEVENTS=Destination(end);
                            FMA=0;
                        end
                   nextprofiletoinsert=nextprofiletoinsert+1;
                end
                
                if(CycleVars(TT).ProjectionY) %Projection Y to be stored
                   if(CycleVars(TT).YTranspose)
                       ProfileBuffer{nextprofiletoinsert}(Destination,:) = permute(sum(TemporaryData,2),[3,1,2]);
                   else
                       ProfileBuffer{nextprofiletoinsert}(Destination,:) = permute(sum(TemporaryData,2),[3,2,1]);
                   end
                   
                   FullPulseIDProfiles{nextprofiletoinsert}(Destination) = Upid;
                   FullTimeStampsProfiles{nextprofiletoinsert}(Destination) = ProfileCue_TS(TT,DOVE);
                   
                   LAST_VALID_PULSE_IDsProfiles{nextprofiletoinsert}=Upid(end);
                   AbsoluteEventCounterProfiles{nextprofiletoinsert}(Destination) = AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert} + (1:NewDataFoundLength);
                        AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert}=AcquisitionTotalSynchronousEventsProfiles{nextprofiletoinsert} + NewDataFoundLength;
                        if(FMA)
                            MAXEVENTS=Destination(end);
                            FMA=0;
                        end
                   nextprofiletoinsert=nextprofiletoinsert+1;
                end
            
            end
            
            
        end
   
        
    end
end
