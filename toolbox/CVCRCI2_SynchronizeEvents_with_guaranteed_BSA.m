%save ALL -v7.3
if(Init_Vars.NumberOfSynchPVs)
  if(S_Guaranteed(1)==1)
        CO=(ValidDataArray_PV(S_Guaranteed(3),:)<ScanSetting.GuaranteedPV_MIN) | (ValidDataArray_PV(S_Guaranteed(3),:)>ScanSetting.GuaranteedPV_MAX);
        BAD_PIDs=PvsCue_PID(CO);
  end
  IntersectPid=unique(PvsCue_PID,'stable');
  IntersectPid=setdiff(IntersectPid,BAD_PIDs,'stable');
  
  if(Init_Vars.NumberOfProfiles)
    ProfCue_PID=bitand(uint32(imag(ProfileCue_TS(:,1:LastValidCueElement))),hex2dec('1FFFF'));
  end
  for TT=1:Init_Vars.NumberOfProfiles
    if(CycleVars(TT).Run_Post_Processing)
      IntersectPid=intersect(IntersectPid,ProcessedData(TT).PulseID,'stable');
    else
      ProfCue_PID(TT,:)=mod(ProfCue_PID(TT,:)+Init_Vars.Profili(TT).PulseIDDealy,handles.MAX_Pulse_ID);
      IntersectPid=intersect(IntersectPid,ProfCue_PID(TT,:),'stable');
    end
  end
end

IntersectPid=setdiff(IntersectPid,LAST_VALID_PULSE_ID);
NewDataFoundLength=length(IntersectPid);

if(NewDataFoundLength)
  LAST_VALID_PULSE_ID = IntersectPid(end);
  if(NewDataFoundLength>AcquisitionBufferSpaceLeftThisBuffer)
    Destination=[AcquisitionBufferNextWrittenElement:Init_Vars.BufferSize,1:(NewDataFoundLength-AcquisitionBufferSpaceLeftThisBuffer)];
    AcquisitionBufferCycle=AcquisitionBufferCycle+1;
    AcquisitionBufferLastWrittenElement=Destination(end);
    AcquisitionBufferNextWrittenElement=AcquisitionBufferLastWrittenElement+1;
    if(AcquisitionBufferNextWrittenElement > Init_Vars.BufferSize)
      AcquisitionBufferNextWrittenElement=1;
    end
    AcquisitionBufferSpaceLeftThisBuffer= Init_Vars.BufferSize - AcquisitionBufferNextWrittenElement + 1;
  else
    %repstosb=0;
    Destination =  AcquisitionBufferNextWrittenElement:(AcquisitionBufferNextWrittenElement+NewDataFoundLength-1);
    AcquisitionBufferLastWrittenElement=AcquisitionBufferNextWrittenElement+NewDataFoundLength-1;
    AcquisitionBufferNextWrittenElement=(AcquisitionBufferLastWrittenElement+1);
    if(AcquisitionBufferNextWrittenElement > Init_Vars.BufferSize)
      AcquisitionBufferNextWrittenElement=1;
      AcquisitionBufferCycle=AcquisitionBufferCycle+1;
    end
    AcquisitionBufferSpaceLeftThisBuffer= Init_Vars.BufferSize - AcquisitionBufferNextWrittenElement + 1;
  end
  
  
  %Now that you have the intersection of all the pids, and prepare the new
  %data structures
  
  TimeStampDone=0;
  PulseIDDone=0;
  AbsoluteEventCounterMatrix(Destination) = AcquisitionTotalSynchronousEvents + (1:NewDataFoundLength);
  AcquisitionTotalSynchronousEvents=AcquisitionTotalSynchronousEvents+NewDataFoundLength;
  
  if(NewDataFoundLength)
    [~,DOVE,DoveInPid]=intersect(PvsCue_PID(1,:),IntersectPid,'stable');
    PulseIDMatrix(Destination) = IntersectPid(DoveInPid);
    TimeStampsMatrix(Destination) = PvsCue_TS(1,DOVE).';
    PulseIDDone=1;TimeStampDone=1;
    SynchProfilePVs(Destination,:) = ValidDataArray_PV(:,DOVE).';
    
    if(Init_Vars.NumberOfProfiles)
      nextprofiletoinsert=1;
      nextscalarmatrixtoinsert=1;
      for TT=1:Init_Vars.NumberOfProfiles
        if(CycleVars(TT).Run_Post_Processing)
          if(~PulseIDDone)
            [~,DOVE,DoveInPid]=intersect(ProcessedData(TT).PulseID,IntersectPid,'stable');
            PulseIDMatrix(Destination) = IntersectPid(DoveInPid);
            PulseIDDone=1;
          else
            [~,DOVE,~]=intersect(ProcessedData(TT).PulseID,IntersectPid,'stable');
          end
          if(ProcessedData(TT).NumberOfScalars)
            ScalarBuffer{nextscalarmatrixtoinsert}(Destination,:)=ProcessedData(TT).Scalars(:,DOVE).';
            nextscalarmatrixtoinsert=nextscalarmatrixtoinsert+1;
          end
          if(ProcessedData(TT).NumberOfVectors)
            for YY=1:ProcessedData(TT).NumberOfVectors
              ProfileBuffer{nextprofiletoinsert}(Destination,:) = ProcessedData(TT).Vectors{YY}(DOVE,:);
              nextprofiletoinsert=nextprofiletoinsert+1;
            end
          end
          if(ProcessedData(TT).NumberOfArray2D)
            for YY=1:ProcessedData(TT).NumberOfArray2D
              ProfileBuffer{nextprofiletoinsert}(:,:,Destination) = ProcessedData(TT).Array2D{YY}(:,:,DOVE);
              nextprofiletoinsert=nextprofiletoinsert+1;
            end
          end
        else
          if(~TimeStampDone)
            [~,DOVE,DoveInPid]=intersect(ProfCue_PID(TT,:),IntersectPid,'stable');
            PulseIDMatrix(Destination) = IntersectPid(DoveInPid);
            %save temp
            TimeStampsMatrix(Destination) = ProfileCue_TS(TT,DOVE).';
            PulseIDDone=1;TimeStampDone=1;
          else
            [~,DOVE,~]=intersect(ProfCue_PID(TT,:),IntersectPid,'stable');
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
            nextprofiletoinsert=nextprofiletoinsert+1;
          end
          
          if(CycleVars(TT).ProjectionX) %Projection X to be stored
            if(CycleVars(TT).XTranspose)
              ProfileBuffer{nextprofiletoinsert}(Destination,:) = permute(sum(TemporaryData,1),[3,1,2]);
            else
              ProfileBuffer{nextprofiletoinsert}(Destination,:) = permute(sum(TemporaryData,1),[3,2,1]);
            end
            nextprofiletoinsert=nextprofiletoinsert+1;
          end
          
          if(CycleVars(TT).ProjectionY) %Projection Y to be stored
            if(CycleVars(TT).YTranspose)
              ProfileBuffer{nextprofiletoinsert}(Destination,:) = permute(sum(TemporaryData,2),[3,1,2]);
            else
              ProfileBuffer{nextprofiletoinsert}(Destination,:) = permute(sum(TemporaryData,2),[3,2,1]);
            end
            nextprofiletoinsert=nextprofiletoinsert+1;
          end
          
        end
      end
    end
  end
  
%   if(Init_Vars.UpdateNonSynch) %Do also this one...
%     NotSynchProfilePVs(Destination) = ones(NewDataFoundLength,1)*NotSynchProfilePVsReadVariables;
%   end
  
  if(~TimeStampDone)
    TimeStampsMatrix(Destination) = AbsoluteEventCounterMatrix(Destination);
  end
  
else
  Destination=[];
end
if(~isempty(Destination))
      if(Init_Vars.UpdateNonSynch) %Do also this one...
          %save TEMP
        NotSynchProfilePVs(Destination,:) = ones(NewDataFoundLength,1)*NotSynchProfilePVsReadVariables.';
      end
end
NewDataFoundLength=length(Destination);

