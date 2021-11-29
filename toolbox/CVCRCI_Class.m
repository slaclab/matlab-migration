classdef CVCRCI_Class < handle
    
    properties
        InternalCounter;
        Acquisition; % Acquisition Setup
        Recorder; % Recorder Data
        Transient; % Transiet Data for recording
        CompareTo; % Compare To
        WriteInto; % Write Into
        InputStructure;
        myeDefNumber;
        my_names;
        BufferCounterName={'SIOC:SYS0:ML02:AO312','SIOC:SYS0:ML02:AO313'};
        LastValidCueElement=-1;
        Counter=0;
        ScanSetting=[];
        ScanState;
        auxillaryData;
        uselcaGetSmart=1;
    end
    
    methods
        
        function DoNothing(obj)
        end
        
        function load_Scans(obj,functionWithScans)
            obj.AllScans=functionWithScans;
        end
        
        function LoadFile(obj,file)
           FILE=load(file);
           if(isfield(FILE,'auxillaryData'))
            obj.Acquisition=FILE.DataStructure;
            obj.auxillaryData=FILE.auxillaryData;
            obj.Recorder=FILE.Data;
            Assign_ReloadMax=1;
           elseif(isfield(FILE,'Recorder'))
            obj.auxillaryData=[];  
            if(isfield(FILE,'Acquisition'))
                obj.Recorder=FILE.Recorder;
                obj.Acquisition=FILE.Acquisition;
            end
            if(isfield(FILE,'DataStructure'))
                obj.Recorder=FILE.Recorder;
                obj.Acquisition=FILE.DataStructure;
            end 
            Assign_ReloadMax=1;
           elseif(isfield(FILE,'ProfileBuffer'))
               if(isfield(FILE,'DataStructure'))
                   SD=FILE.DataStructure;
               elseif(isfield(FILE,'StrutturaDatiFull'))
                   SD=FILE.StrutturaDatiFull;
               end
               if(iscell(FILE.AcquisitionBufferLastWrittenElement))
                   disp('asynchronous recording for old file is not supported!');
                   return
               end
               obj.auxillaryData=[];
               AllScalars=[FILE.SynchProfilePVs,FILE.NotSynchProfilePVs;FILE.ScanBuffer];
               AllScalarsNames=[SD.Names_of_synch_pvs(:);SD.Names_of_unsynch_pvs(:);SD.ScanSetting.ScanBufferNames(:)];
               obj.Recorder.Data{1}=AllScalars;
               obj.Recorder.Data{2}=[];
               obj.Recorder.Data{3}=[];
               obj.Acquisition.Vectors_Positions=[];
               obj.Acquisition.Arrays2D_Positions=[];
               for II=1:numel(FILE.ProfileBuffer)
                   obj.Recorder.Data{3+II}=FILE.ProfileBuffer{II};
                   if(any(SD.Position_of_vectors_in_Profiles==II))
                       obj.Acquisition.Vectors_Positions(end+1,:)=[3+II,1,1];
                   end
                   if(any(SD.Position_of_2Darrays_in_Profiles==II))
                       obj.Acquisition.Arrays2D_Positions(end+1,:)=[3+II,1,1];
                   end                   
               end
               obj.Acquisition.SynchronousPVs=AllScalarsNames;
               obj.Acquisition.OncePerCyclePVs={};
               obj.Acquisition.OnlyOncePVs={};
               obj.Acquisition.ProfilePVs={};
               obj.Acquisition.ProfileNonTS_PVs={};
               obj.Acquisition.SingleValueScalars={};       
               obj.Acquisition.OnlyOncePVs={};
               obj.Acquisition.SingleValueScalars_Positions=[];
               obj.Acquisition.Author='Matlab';
               obj.Acquisition.Synchronous=1;
               obj.Acquisition.BSA=1;
               obj.Acquisition.Scan=SD.ScanSetting;
               obj.Acquisition.ScanSetting=SD.ScanSetting;
               obj.Acquisition.ProfileTimeStamped=[];
               obj.Acquisition.NonTimeStampedProfilesPositionWithinData=[];
               obj.Acquisition.Scalars=obj.Acquisition.SynchronousPVs(:);
               obj.Acquisition.Vectors=SD.Names_of_vectors(:);
               obj.Acquisition.Arrays2D=SD.Names_of_2Darrays(:);
               obj.Acquisition.Scalars_Positions=[ones(numel(AllScalarsNames),1),(1:numel(AllScalarsNames)).',ones(numel(AllScalarsNames),1)];
               obj.Acquisition.VarNames=[obj.Acquisition.Scalars;obj.Acquisition.Vectors;obj.Acquisition.Arrays2D];
               obj.Acquisition.VarPosition=[obj.Acquisition.Scalars_Positions;obj.Acquisition.Vectors_Positions;obj.Acquisition.Arrays2D_Positions];

               obj.Acquisition.Buffersize=size(obj.Recorder.Data{1},1);
               obj.Acquisition.TimeStamped=ones(1,length(obj.Recorder.Data)); obj.Acquisition.TimeStamped(2)=0; obj.Acquisition.TimeStamped(3)=0;
               obj.Acquisition.VarBuffersize=ones(size(obj.Acquisition.TimeStamped))*obj.Acquisition.Buffersize;
               for II=1:length(obj.Acquisition.TimeStamped)
                   obj.Acquisition.AllSizes{II}=size(obj.Recorder.Data{II});
                   if((II==2) || (II==3))
                       obj.Recorder.MaxEventsAbsoluteCounter{II}=0;
                   else
                       obj.Recorder.MaxEventsAbsoluteCounter{II}=max(FILE.AbsoluteEventCounterMatrix);
                   end
               end
               
               obj.Recorder.TimeStamps=FILE.TimeStampsMatrix.';
               obj.Recorder.PulseIds=FILE.PulseIDMatrix.';
               obj.Recorder.AcquisitionWritingCycle=FILE.AbsoluteEventCounterMatrix.';
               obj.Recorder.NextWrittenElement=FILE.AcquisitionBufferNextWrittenElement;
               obj.Recorder.LastWrittenElement=FILE.AcquisitionBufferLastWrittenElement;
               obj.Recorder.TimesBufferFilled=FILE.AcquisitionBufferCycle;
               obj.Recorder.LastWrittenPulseID=obj.Recorder.PulseIds(FILE.AcquisitionBufferLastWrittenElement);
               obj.Recorder.EventsAbsoluteCounter=obj.Recorder.AcquisitionWritingCycle;
               
               obj.Recorder.AcquisitionWritingCycle_NonTimeStamped= {[],[],[]};
               obj.Recorder.AcquisitionNonTimeStampedBuffersize= [0,0,0];
               obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter= [0,0,0];
               obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement= [0,0,0];
               obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement= [0,0,0];
               obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled= [0,0,0];
               obj.Recorder.AbsoluteCaptureID=1;
               if(obj.Recorder.TimesBufferFilled)
                  obj.Recorder.ReloadMaxEvent=obj.Acquisition.Buffersize;
               else
                  obj.Recorder.ReloadMaxEvent=obj.Recorder.LastWrittenElement;
               end
               obj.Recorder.ReloadMaxEventNonTimestamped=[0,0,0];
               Assign_ReloadMax=0;
           else
              disp('File type not recognized or not supported yet')
           end
           
           if(Assign_ReloadMax)
              for II=1:length(obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled)
                 if(obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(II))
                     obj.Recorder.ReloadMaxEventNonTimestamped(II)=obj.Recorder.AcquisitionNonTimeStampedBuffersize(II);
                 else
                     obj.Recorder.ReloadMaxEventNonTimestamped(II)=obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(II);
                 end
              end
              if(obj.Acquisition.Synchronous)
                  if(obj.Recorder.TimesBufferFilled)
                      obj.Recorder.ReloadMaxEvent=obj.Acquisition.Buffersize;
                  else
                      obj.Recorder.ReloadMaxEvent=obj.Recorder.LastWrittenElement;
                  end
              else
                  if(obj.Acquisition.BSA)
                      if(obj.Recorder.TimesBufferFilled{1})
                        obj.Recorder.ReloadMaxEvent{1}=obj.Acquisition.VarBuffersize(1);
                      else
                        obj.Recorder.ReloadMaxEvent{1}=obj.Recorder.LastWrittenElement{1};
                      end
                  else
                      for JJ=1:length(obj.Acquisition.VarBuffersize(1))
                         if(obj.Recorder.TimesBufferFilled{1}(JJ))
                             obj.Recorder.ReloadMaxEvent{1}(JJ)=obj.Acquisition.VarBuffersize(1);
                         else
                             obj.Recorder.ReloadMaxEvent{1}(JJ)=obj.Recorder.LastWrittenElement{1}(JJ);
                         end
                      end
                  end
                  for JJ=2:numel(obj.Recorder.LastWrittenElement)
                     if(obj.Recorder.TimesBufferFilled{JJ}) 
                         obj.Recorder.ReloadMaxEvent{JJ}=obj.Acquisition.VarBuffersize(JJ);
                     else
                         obj.Recorder.ReloadMaxEvent{JJ}=obj.Recorder.LastWrittenElement{JJ};
                     end 
                  end
              end
           end 
           
           obj.Recorder.Fieldnames=fieldnames(obj.Recorder);
           for II=1:numel(obj.Recorder.Fieldnames)
               if(~strcmp(obj.Recorder.Fieldnames{II},'Data'))
                    obj.Recorder.RestorePristineState.(obj.Recorder.Fieldnames{II}) = obj.Recorder.(obj.Recorder.Fieldnames{II});
               end
           end
        end
        
        function RestorePristineState(obj)
            for II=1:numel(obj.Recorder.Fieldnames)
               if(~strcmp(obj.Recorder.Fieldnames{II},'Data'))
                    obj.Recorder.(obj.Recorder.Fieldnames{II})=obj.Recorder.RestorePristineState.(obj.Recorder.Fieldnames{II});
               end
            end
        end
        
        function out=GetReplayStatusString(obj)
            if(iscell(obj.Recorder.NextWrittenElement))
                out{1}=[]; out{2}=[];
                for II=1:numel(obj.Recorder.LastWrittenElement)
                    out{1}=[out{1},num2str(obj.Recorder.LastWrittenElement{II}),' '];
                    out{2}=[out{2},num2str(obj.Recorder.NextWrittenElement{II}),' '];
                end
            else
               out{1}=num2str(obj.Recorder.LastWrittenElement);
               out{2}=num2str(obj.Recorder.NextWrittenElement); 
            end
        end
        
        function CycleEvent(obj)
           if(obj.Acquisition.Synchronous)
              obj.Recorder.NextWrittenElement=obj.Recorder.NextWrittenElement+1;
              if(obj.Recorder.NextWrittenElement>obj.Recorder.ReloadMaxEvent)
                  obj.Recorder.NextWrittenElement=1;
              end
              obj.Recorder.LastWrittenElement=obj.Recorder.LastWrittenElement+1;
              if(obj.Recorder.LastWrittenElement>obj.Recorder.ReloadMaxEvent)
                  obj.Recorder.LastWrittenElement=1;
              end
              for II=1:length(obj.Recorder.ReloadMaxEventNonTimestamped)
                 if(obj.Recorder.ReloadMaxEventNonTimestamped(II)>0)
                     obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(II)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(II)+1;
                      if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(II)>obj.Recorder.ReloadMaxEventNonTimestamped(II))
                          obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(II)=1;
                      end
                      obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(II)=obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(II)+1;
                      if(obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(II)>obj.Recorder.ReloadMaxEventNonTimestamped(II))
                          obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(II)=1;
                      end
                 end
              end
           else
               for II=1:length(obj.Recorder.ReloadMaxEventNonTimestamped)
                 if(obj.Recorder.ReloadMaxEventNonTimestamped(II)>0)
                     obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(II)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(II)+1;
                      if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(II)>obj.Recorder.ReloadMaxEventNonTimestamped(II))
                          obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(II)=1;
                      end
                      obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(II)=obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(II)+1;
                      if(obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(II)>obj.Recorder.ReloadMaxEventNonTimestamped(II))
                          obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(II)=1;
                      end
                 end
               end
               if(obj.Acquisition.BSA)
                   obj.Recorder.LastWrittenElement{1}=obj.Recorder.LastWrittenElement{1}+1;
                   if(obj.Recorder.LastWrittenElement{1}>obj.Recorder.ReloadMaxEvent{1})
                       obj.Recorder.LastWrittenElement{1}=1;
                   end
                   obj.Recorder.NextWrittenElement{1}=obj.Recorder.NextWrittenElement{1}+1;
                   if(obj.Recorder.NextWrittenElement{1}>obj.Recorder.ReloadMaxEvent{1})
                       obj.Recorder.NextWrittenElement{1}=1;
                   end
               else
                  for JJ=1:length(obj.Recorder.LastWrittenElement{1})
                      obj.Recorder.LastWrittenElement{1}(JJ)=obj.Recorder.LastWrittenElement{1}(JJ)+1;
                      if(obj.Recorder.LastWrittenElement{1}(JJ)>obj.Recorder.ReloadMaxEvent{1}(JJ))
                          obj.Recorder.LastWrittenElement{1}(JJ)=1;
                      end
                      obj.Recorder.NextWrittenElement{1}(JJ)=obj.Recorder.NextWrittenElement{1}(JJ)+1;
                      if(obj.Recorder.NextWrittenElement{1}(JJ)>obj.Recorder.ReloadMaxEvent{1}(JJ))
                          obj.Recorder.NextWrittenElement{1}(JJ)=1;
                      end
                  end
               end
               for II=2:numel(obj.Recorder.LastWrittenElement)
                   obj.Recorder.LastWrittenElement{II}=obj.Recorder.LastWrittenElement{II}+1;
                   if(obj.Recorder.LastWrittenElement{II}>obj.Recorder.ReloadMaxEvent{II})
                       obj.Recorder.LastWrittenElement{II}=1;
                   end
                   obj.Recorder.NextWrittenElement{II}=obj.Recorder.NextWrittenElement{II}+1;
                   if(obj.Recorder.NextWrittenElement{II}>obj.Recorder.ReloadMaxEvent{II})
                       obj.Recorder.NextWrittenElement{II}=1;
                   end
               end
           end
        end
        
        function OUT=CVCRCI5_AllScanData(obj)
            TABLE{1,1}='SIOC:SYS0:ML02:AO314'; %Scan PV name
            TABLE{1,2}='0'; %Start Position
            TABLE{1,3}='5'; %End Position
            TABLE{1,4}='6'; %# Of Steps
            TABLE{1,5}='SIOC:SYS0:ML02:AO314'; %# Read-out PV
            TABLE{1,6}='0.001'; %Read-out tolerance
            TABLE{1,7}='0.2'; %# Pause
            TABLE{1,8}='1'; %# Knob ID
            TABLE{1,9}=''; %# Grid Shape
            OUT{1}=TABLE;

            TABLE{1,1}='SIOC:SYS0:ML02:AO314'; %Scan PV name
            TABLE{1,2}='0'; %Start Position
            TABLE{1,3}='5'; %End Position
            TABLE{1,4}='6'; %# Of Steps
            TABLE{1,5}='SIOC:SYS0:ML02:AO314'; %# Read-out PV
            TABLE{1,6}='0.001'; %Read-out tolerance
            TABLE{1,7}='0.2'; %# Pause
            TABLE{1,8}='1'; %# Knob ID
            TABLE{1,9}=''; %# Grid Shape

            TABLE{2,1}='SIOC:SYS0:ML02:AO315'; %Scan PV name
            TABLE{2,2}='0'; %Start Position
            TABLE{2,3}='5'; %End Position
            TABLE{2,4}='12'; %# Of Steps
            TABLE{2,5}='SIOC:SYS0:ML02:AO315'; %# Read-out PV
            TABLE{2,6}='0.001'; %Read-out tolerance
            TABLE{2,7}='1'; %# Pause
            TABLE{2,8}='2'; %# Knob ID
            TABLE{2,9}=''; %# Grid Shape
            OUT{2}=TABLE;
        end
        
        function [Xo,Yo]=ReduceToUniqueX(obj,X,Y)
            Keep=~isnan(X) & ~isnan(Y);
            Y=Y(Keep); X=X(Keep);
            Xo=unique(X,'stable');
            if(length(Xo)==length(X))
                Xo=X; Yo=Y;
            else %must take some averaging
                Yo=zeros(size(Xo));
                for II=1:length(Xo)
                    Yo(II)=mean(Y(Xo(II)==X));
                end
            end
            
        end
        
        function NTS_FullData=NonTimeStamped_On_Timestamped(obj, NTS_AcquisitionWritingCycle,NTS_Data,TS_AcquisitionWritingCycle)
            if(size(NTS_Data,2)==1)
                NTS_FullData=ones(length(TS_AcquisitionWritingCycle),1)*NaN;
                [Intersect_Writing_Cycle,anyone]=intersect(NTS_AcquisitionWritingCycle,TS_AcquisitionWritingCycle);
                Intersect_Writing_Cycle=Intersect_Writing_Cycle(~isnan(Intersect_Writing_Cycle));
                for II=1:length(Intersect_Writing_Cycle)
                    NTS_FullData(TS_AcquisitionWritingCycle==Intersect_Writing_Cycle(II)) = NTS_Data(anyone(II));
                end
            else
                NTS_FullData=ones(length(TS_AcquisitionWritingCycle),size(NTS_Data,2))*NaN;
                [Intersect_Writing_Cycle,anyone]=intersect(NTS_AcquisitionWritingCycle,TS_AcquisitionWritingCycle);
                Intersect_Writing_Cycle=Intersect_Writing_Cycle(~isnan(Intersect_Writing_Cycle));
                for II=1:length(Intersect_Writing_Cycle)
                    NTS_FullData(TS_AcquisitionWritingCycle==Intersect_Writing_Cycle(II),:) = repmat(NTS_Data(anyone(II),:),[sum(TS_AcquisitionWritingCycle==Intersect_Writing_Cycle(II)),1]);
                end 
            end
        end
        
        function TakeDataUntilBufferFull(obj)
            TEMP=[obj.Acquisition.StopAfterBufferFilled,obj.Acquisition.CheckForBufferCompleted];
            obj.Acquisition.StopAfterBufferFilled=1;
            obj.Acquisition.CheckForBufferCompleted=1;
            AlreadyFilled=obj.Recorder.TimesBufferFilled;
            while(obj.Recorder.TimesBufferFilled==AlreadyFilled)
                obj.ContAcquisitionCycle;
                obj.Recorder.LastWrittenElement
            end
            obj.Acquisition.StopAfterBufferFilled=TEMP(1);
            obj.Acquisition.CheckForBufferCompleted=TEMP(2);
        end
        
        function InitializeScan(obj)
           obj.ScanState.ScanPosition=1;
           obj.ScanSetting=obj.Acquisition.Scan.Functions.BeforeScanStarts(obj.ScanSetting);
           obj.ScanState.SamplesRecordedEntireScan=0;
           obj.ScanState.TotalScanSteps=size(obj.ScanSetting.ConditionsTable,2);
           if(obj.Acquisition.Synchronous)
               obj.ScanState.RelBufferSize=obj.Acquisition.Buffersize;
           elseif(obj.Acquisition.AsynchronousVarCounter(1)==1)
               if(obj.Acquisition.BSA)
                   obj.ScanState.RelBufferSize=obj.Acquisition.VarBuffersize(obj.Acquisition.AsynchronousVarCounter(1));
               else
                   obj.ScanState.RelBufferSize=obj.Acquisition.VarBuffersize(obj.Acquisition.AsynchronousVarCounter(1));
               end
           else % it is not on the first Recorder.Data
               if(obj.Acquisition.TimeStamped(obj.Acquisition.AsynchronousVarCounter(1)))
                   obj.ScanState.RelBufferSize=obj.Acquisition.VarBuffersize(obj.Acquisition.AsynchronousVarCounter(1));
               else
                   obj.ScanState.RelBufferSize=obj.Acquisition.VarBuffersize(obj.Acquisition.AsynchronousVarCounter(1));
               end
           end
           obj.ScanState.RelBufferLastWrittenElement=0; obj.ScanState.PositionString='Initialized'; obj.ScanState.StepPositionString='0 / 0';
           obj.ScanState.Finished=0; obj.ScanState.SamplesRecordedThisStep=0;
        end
        
        function IncrementScanPosition(obj)
            obj.ScanState.ScanPosition=obj.ScanState.ScanPosition+1;
            if(obj.ScanState.ScanPosition>obj.ScanState.TotalScanSteps)
                obj.ScanState.ScanPosition=obj.ScanState.TotalScanSteps;
                obj.ScanState.Finished=1;
            end
        end
        
        function InvalidateBSAScan(obj)
            if(obj.Acquisition.BSA)
                if(obj.Acquisition.BSA>1)
                    [~,ts]=lcaGetSmart(obj.Acquisition.PV_For_Time_Reference);
                    obj.Recorder.LastValidTime=double(real(ts)) + double(imag(ts))/10^9; 
                    while(isnan(obj.Recorder.LastValidTime))
                        [~,ts]=lcaGetSmart(obj.Acquisition.PV_For_Time_Reference);
                        obj.Recorder.LastValidTime=double(real(ts)) + double(imag(ts))/10^9; 
                    end
                else
                    [~,ts]=lcaGetSmart(obj.Acquisition.PV_For_Time_Reference);
                    obj.Recorder.LastValidTime=double(real(ts)) + double(imag(ts))/10^9; 
                    while(isnan(obj.Recorder.LastValidTime))
                        [~,ts]=lcaGetSmart(obj.Acquisition.PV_For_Time_Reference);
                        obj.Recorder.LastValidTime=double(real(ts)) + double(imag(ts))/10^9; 
                    end
                end
            end
        end
        
        function StateNumberScan(obj)
            if(obj.Acquisition.Synchronous)
               NewCounterValue=obj.Recorder.LastWrittenElement;
            elseif(obj.Acquisition.AsynchronousVarCounter(1)==1)
                if(obj.Acquisition.BSA)
                    NewCounterValue=obj.Recorder.LastWrittenElement{obj.Acquisition.AsynchronousVarCounter(1)};
                else
                    NewCounterValue=obj.Recorder.LastWrittenElement{obj.Acquisition.AsynchronousVarCounter(1)}(obj.Acquisition.AsynchronousVarCounter(2));
                end
            else
                if(obj.Acquisition.TimeStamped(obj.Acquisition.AsynchronousVarCounter(1)))
                    NewCounterValue=obj.Recorder.LastWrittenElement{obj.Acquisition.AsynchronousVarCounter(1)};
                else
                    NewCounterValue=obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(obj.Acquisition.AsynchronousVarCounter(1));
                end
            end
            
            if(NewCounterValue==obj.ScanState.RelBufferLastWrittenElement)
                return
            end
            
            if(NewCounterValue>obj.ScanState.RelBufferLastWrittenElement)
                NewElements=NewCounterValue - obj.ScanState.RelBufferLastWrittenElement;    
            else
                NewElements=obj.ScanState.RelBufferSize - obj.ScanState.RelBufferLastWrittenElement + NewCounterValue;
            end
            obj.ScanState.RelBufferLastWrittenElement=NewCounterValue;
            obj.ScanState.SamplesRecordedEntireScan=obj.ScanState.SamplesRecordedEntireScan+NewElements;
            obj.ScanState.SamplesRecordedThisStep=obj.ScanState.SamplesRecordedThisStep+NewElements;
            obj.ScanState.StepPositionString=[num2str(obj.ScanState.SamplesRecordedThisStep),' / ',num2str(obj.ScanState.SamplesRecordedEntireScan)];
        end
        
        function SetNextPosition(obj)
            obj.ScanSetting=obj.Acquisition.Scan.Functions.BeforeSettingNewValue(obj.ScanSetting);
            obj.ScanState.SamplesRecordedThisStep=0; 
            obj.ScanSetting=obj.Acquisition.Scan.Functions.SetValue(obj.ScanSetting,obj.ScanState.ScanPosition,0);
            obj.ScanSetting=obj.Acquisition.Scan.Functions.AfterSettingNewValue(obj.ScanSetting);
            obj.ScanState.PositionString=[num2str(obj.ScanState.ScanPosition), ' / ',num2str(size(obj.ScanSetting.ConditionsTable,2))];
            if(obj.Acquisition.BSA)
                if(obj.Acquisition.BSA>1)
                    [~,ts]=lcaGetSmart(obj.Acquisition.PV_For_Time_Reference);
                    obj.Recorder.LastValidTime=double(real(ts)) + double(imag(ts))/10^9; 
                    while(isnan(obj.Recorder.LastValidTime))
                        [~,ts]=lcaGetSmart(obj.Acquisition.PV_For_Time_Reference);
                        obj.Recorder.LastValidTime=double(real(ts)) + double(imag(ts))/10^9; 
                    end
                else
                    [~,ts]=lcaGetSmart(obj.Acquisition.PV_For_Time_Reference);
                    obj.Recorder.LastValidTime=double(real(ts)) + double(imag(ts))/10^9; 
                    while(isnan(obj.Recorder.LastValidTime))
                        [~,ts]=lcaGetSmart(obj.Acquisition.PV_For_Time_Reference);
                        obj.Recorder.LastValidTime=double(real(ts)) + double(imag(ts))/10^9; 
                    end
                end
            end
        end
        
        function ContAcquisitionCycle(obj)
            if(~obj.Acquisition.BSA && obj.Acquisition.Synchronous)
                obj.ACQ_Cycle_SynchNoBSA();
            end
            
            if(~obj.Acquisition.BSA && ~obj.Acquisition.Synchronous)
                obj.ACQ_Cycle_NoSynchNoBSA();
            end
            
            if(obj.Acquisition.BSA)
                if(obj.Acquisition.BSA==1)
                    if(obj.Acquisition.Synchronous)
                        obj.ACQ_Cycle_BSA_2B();
                        obj.ACQ_Cycle_Synchronize_BSA();
                    else
                        obj.ACQ_Cycle_Asynchronous_BSA_2B();
                    end
                elseif(obj.Acquisition.BSA>1)
                    if(obj.Acquisition.Synchronous)
                        obj.ACQ_Cycle_BSA_HB();
                        obj.ACQ_Cycle_Synchronize_BSA();
                    else
                        obj.ACQ_Cycle_Asynchronous_BSA_HB();
                    end
                end
            end
        end

        function setupPreset(obj,Preset)
            ExternalInputStructure.DoScan=0;
            SynchScalars=Preset.Variables.SynchPV;
            SlowScalars=Preset.Variables.SlowPV;
            ReadOnce=Preset.Variables.OnlyOncePV;
            switch(Preset.AcquisitionSetup.BSA_Mode)
                case 'No BSA'
                    ExternalInputStructure.BSA=0;
                case 'Double Buffer BSA'
                    ExternalInputStructure.BSA=1;
                case 'History Buffer BSA'
                    ExternalInputStructure.BSA=2;
                otherwise
                    ExternalInputStructure.BSA=0;
                    disp('Something went wrong, not recognized BSA mode!');
            end
            switch(Preset.AcquisitionSetup.Synch_Mode)
                case 'Synchronous Mode'
                    ExternalInputStructure.Synchronous=1;
                case 'Asynchronous Mode'
                    ExternalInputStructure.Synchronous=0;
                otherwise
                    disp('Something went wrong, not recognized Synchronous Mode');
                    ExternalInputStructure.Synchronous=1;
            end
            ExternalInputStructure.Buffersize=Preset.AcquisitionSetup.BufferSize;
            ExternalInputStructure.Blocksize=Preset.AcquisitionSetup.BlockSize;
            ExternalInputStructure.TimeCycle=Preset.AcquisitionSetup.BSATime;
            ExternalInputStructure.PV_For_Time_Reference=Preset.AcquisitionSetup.TimeReference;
            ExternalInputStructure.BSA_Safe_Trash_Data=Preset.AcquisitionSetup.BSAwait;
            ExternalInputStructure.Author=Preset.AcquisitionSetup.Author;
            
            switch(Preset.AcquisitionSetup.BeamCode)
                case 'All 120 Hz'
                    ExternalInputStructure.BSA_Exclusion=0;
                case 'HXR Branch only'
                    ExternalInputStructure.BSA_Exclusion=1;
                case 'SXR Branch only'
                    ExternalInputStructure.BSA_Exclusion=2;
                otherwise
                    disp('Something went wrong, not recognized Beam Code');
                    ExternalInputStructure.BSA_Exclusion=0;
            end
            
            ExternalInputStructure.Variables={};
            ExternalInputStructure.Rejection=[];
            ExternalInputStructure.name=Preset.name;
            ExternalInputStructure.InsertedCounterVariable=1;
            ExternalInputStructure.InsertedCounterVariable=Preset.AcquisitionSetup.InsertedCounterVariableName;
            ExternalInputStructure.SpawnMultiple=0;
            ExternalInputStructure.Profile=Preset.Profile;
            %ExternalInputStructure.ExitAtBufferFilled=Preset.Acquisition.ExitAtBufferFilled;
            ExternalInputStructure.BufferFullFunction=Preset.AcquisitionSetup.AtBufferFullFunction;
            ExternalInputStructure.StopBufferFilled=Preset.AcquisitionSetup.ExitAtBufferFilled;
            
            for TT=1:numel(ExternalInputStructure.Profile)
                if(~ExternalInputStructure.Profile(TT).in_use)
                    continue
                end
                ExternalInputStructure.Variables{end+1}=ExternalInputStructure.Profile(TT);
            end
            
            for TT=1:size(SynchScalars,1)
                ExternalInputStructure.Variables{end+1}.name=SynchScalars{TT,1};
                ExternalInputStructure.Variables{end}.PVname=SynchScalars{TT,1};
                ExternalInputStructure.Variables{end}.size=[1,1];
                ExternalInputStructure.Variables{end}.Synchronous=1;
                ExternalInputStructure.Variables{end}.ReadOnlyOnce=NaN;
                ExternalInputStructure.Variables{end}.Background=[];
                if ( (~isempty(SynchScalars{TT,2})) || (~isempty(SynchScalars{TT,3})) )
                    ExternalInputStructure.Rejection(end+1).PVname=SynchScalars{TT,1};
                    if(isempty(SynchScalars{TT,2}))
                        ExternalInputStructure.Rejection(end).Range(1)=-inf;
                    else
                        ExternalInputStructure.Rejection(end).Range(1)=SynchScalars{TT,2};
                    end
                    if(isempty(SynchScalars{TT,3}))
                        ExternalInputStructure.Rejection(end).Range(2)=+inf;
                    else
                        ExternalInputStructure.Rejection(end).Range(2)=SynchScalars{TT,3};
                    end
                end
                if(strcmp(ExternalInputStructure.InsertedCounterVariable,ExternalInputStructure.Variables{end}.PVname))
                    ExternalInputStructure.InsertedCounterVariable=length(ExternalInputStructure.Variables);
                end
            end
            
            for TT=1:size(SlowScalars,1)
                ExternalInputStructure.Variables{end+1}.name=SlowScalars{TT,1};
                ExternalInputStructure.Variables{end}.PVname=SlowScalars{TT,1};
                ExternalInputStructure.Variables{end}.size=[1,1];
                ExternalInputStructure.Variables{end}.Synchronous=0;
                ExternalInputStructure.Variables{end}.ReadOnlyOnce=0;
                ExternalInputStructure.Variables{end}.Background=[];
                if(strcmp(ExternalInputStructure.InsertedCounterVariable,ExternalInputStructure.Variables{end}.PVname))
                    ExternalInputStructure.InsertedCounterVariable=length(ExternalInputStructure.Variables);
                end
            end
            
            for TT=1:size(ReadOnce,1)
                ExternalInputStructure.Variables{end+1}.name=ReadOnce{TT,1};
                ExternalInputStructure.Variables{end}.PVname=ReadOnce{TT,1};
                ExternalInputStructure.Variables{end}.size=[1,1];
                ExternalInputStructure.Variables{end}.Synchronous=0;
                ExternalInputStructure.Variables{end}.ReadOnlyOnce=1;
                ExternalInputStructure.Variables{end}.Background=[];
            end
            
            for TT=1:numel(ExternalInputStructure.Profile)
                if(~ExternalInputStructure.Profile(TT).in_use)
                    continue
                end
                if(~isempty(ExternalInputStructure.Profile(TT).AdditionalPv{1}))
                    for ZZ=1:numel(ExternalInputStructure.Profile(TT).AdditionalPv)
                        ExternalInputStructure.Variables{end+1}.name=ExternalInputStructure.Profile(TT).AdditionalPv{ZZ};
                        ExternalInputStructure.Variables{end}.PVname=ExternalInputStructure.Profile(TT).AdditionalPv{ZZ};
                        ExternalInputStructure.Variables{end}.size=[1,1];
                        ExternalInputStructure.Variables{end}.Synchronous=0;
                        ExternalInputStructure.Variables{end}.ReadOnlyOnce=1;
                        ExternalInputStructure.Variables{end}.Background=[];
                    end
                end
                if(strcmp(ExternalInputStructure.InsertedCounterVariable,ExternalInputStructure.Variables{end}.PVname))
                    ExternalInputStructure.InsertedCounterVariable=length(ExternalInputStructure.Variables);
                end
            end
            if(ExternalInputStructure.DoScan)
                ExternalInputStructure.ScanSetting=ScanSetting;
            end      
            setupInputStructure(obj,ExternalInputStructure);
        end
        
        function setupInputStructure(obj,ExternalInputStructure)
            obj.InputStructure=ExternalInputStructure;
        end
        
        function CounterAddition(obj)
            obj.InternalCounter=obj.InternalCounter+1;
        end
        
        function GetReadyToTakeData(obj)
            obj.uselcaGetSmart=1;
            obj.BuildAcquisitionStructure();
            obj.MakeAcquisitionBuffers();
            obj.zeroAllBuffers();
            obj.Initialize_BSA();
        end
        
        function MakeAcquisitionBuffers(obj)
            if(obj.Acquisition.Synchronous)
                if(obj.Acquisition.BSA>0)
                    TempBufferSize=2800;
                else
                    TempBufferSize=obj.Acquisition.Blocksize;
                end
            else
                TempBufferSize=2;
            end
            
            obj.Transient.SynchPV=NaN*ones(numel(obj.Acquisition.SynchronousPVs),TempBufferSize);
            obj.Transient.SynchPV_TS=NaN*ones(numel(obj.Acquisition.SynchronousPVs),TempBufferSize);
            for TT=1:numel(obj.Acquisition.ProfilePVs)
                obj.Transient.ProfilePV{TT}=NaN*ones(TempBufferSize,obj.Acquisition.ProfilePVs(TT).ReadSize);
                %obj.Transient.Profile_TS{TT}=NaN*ones(numel(obj.Acquisition.ProfilePVs),TempBufferSize);
            end
            obj.Transient.Profile_TS=NaN*ones(numel(obj.Acquisition.ProfilePVs),TempBufferSize);
            obj.Transient.UnSynchPV=NaN*ones(numel(obj.Acquisition.OncePerCyclePVs));
            
            if(~obj.Acquisition.Synchronous)
                obj.Transient.SynchPV_PID=NaN*ones(numel(obj.Acquisition.SynchronousPVs),TempBufferSize);
                obj.Transient.Profile_PID=NaN*ones(numel(obj.Acquisition.ProfilePVs),TempBufferSize);
                obj.WriteInto=2;
                obj.CompareTo=1;
            end
            
            if(obj.Acquisition.UseLcaMonitor)
                if(obj.Acquisition.BSA>0)
                    lcaSetMonitor(obj.Acquisition.OncePerCyclePVs);
                    for TT=1:numel(obj.Acquisition.ProfilePVs)
                        lcaSetMonitor(obj.Acquisition.ProfilePVs(TT).PVName);
                    end
                else
                    lcaSetMonitor(obj.Acquisition.OncePerCyclePVs);
                    lcaSetMonitor(obj.Acquisition.SynchronousPVs);
                    for TT=1:numel(obj.Acquisition.ProfilePVs)
                        lcaSetMonitor(obj.Acquisition.ProfilePVs(TT).PVName);
                    end
                end
            end
        end %End MakeAcquisitionBuffers
        
        function zeroAllBuffers(obj)
            if(obj.Acquisition.Synchronous)
                obj.Recorder.TimeStamps=NaN*ones(1,obj.Acquisition.Buffersize);
                obj.Recorder.PulseIds=NaN*ones(1,obj.Acquisition.Buffersize);
                obj.Recorder.EventsAbsoluteCounter=NaN*ones(1,obj.Acquisition.Buffersize);
                obj.Recorder.MaxEventsAbsoluteCounter=0;
                obj.Recorder.AcquisitionWritingCycle=obj.Recorder.TimeStamps;
                obj.Recorder.NextWrittenElement=1;
                obj.Recorder.LastWrittenElement=0;
                obj.Recorder.TimesBufferFilled=0;
                obj.Recorder.LastWrittenPulseID=NaN;
                for II=1:numel(obj.Acquisition.AllSizes)
                    obj.Recorder.Data{II}=zeros(obj.Acquisition.AllSizes{II});
                    if(~obj.Acquisition.TimeStamped(II))
                        obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{II}=NaN*ones(1,obj.Acquisition.VarBuffersize(II));
                        obj.Recorder.AcquisitionNonTimeStampedBuffersize(II)=obj.Acquisition.VarBuffersize(II);
                        obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(II)=0;
                        obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(II)=1;
                        obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(II)=0;
                        obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(II)=0;
                    end
                end
            else
                for II=1:numel(obj.Acquisition.AllSizes)
                    obj.Recorder.Data{II}=zeros(obj.Acquisition.AllSizes{II});
                    if((II>1) || obj.Acquisition.BSA)
                        obj.Recorder.TimeStamps{II}=NaN*ones(1,obj.Acquisition.VarBuffersize(II));
                        obj.Recorder.AcquisitionWritingCycle{II}=NaN*ones(1,obj.Acquisition.VarBuffersize(II));
                        obj.Recorder.PulseIds{II}=NaN*ones(1,obj.Acquisition.VarBuffersize(II));
                        %obj.Recorder.EventsAbsoluteCounter{II}=NaN*ones(1,obj.Acquisition.Buffersize);%oldline
                        obj.Recorder.EventsAbsoluteCounter{II}=NaN*ones(1,obj.Acquisition.VarBuffersize(II));
                        obj.Recorder.MaxEventsAbsoluteCounter{II}=0;
                        obj.Recorder.NextWrittenElement{II}=1;
                        obj.Recorder.LastWrittenElement{II}=0;
                        obj.Recorder.LastWrittenPulseID{II}=NaN;
                        obj.Recorder.TimesBufferFilled{II}=0;
                    else %this depends on BSA state
                        obj.Recorder.TimeStamps{1}=NaN*ones(obj.Acquisition.AllSizes{1});
                        obj.Recorder.PulseIds{1}=NaN*ones(obj.Acquisition.AllSizes{1});
                        obj.Recorder.AcquisitionWritingCycle{1}=NaN*ones(obj.Acquisition.AllSizes{1});
                        obj.Recorder.NextWrittenElement{1}=1*ones(1,numel(obj.Acquisition.SynchronousPVs));
                        obj.Recorder.LastWrittenElement{1}=0*ones(1,numel(obj.Acquisition.SynchronousPVs));
                        obj.Recorder.TimesBufferFilled{1}=zeros(1,numel(obj.Acquisition.SynchronousPVs));
                        obj.Recorder.LastWrittenPulseID{1}=NaN*zeros(1,numel(obj.Acquisition.SynchronousPVs));
                        obj.Recorder.EventsAbsoluteCounter{1}=NaN*ones(1,obj.Acquisition.Buffersize);
                        obj.Recorder.MaxEventsAbsoluteCounter{1}=zeros(1,numel(obj.Acquisition.SynchronousPVs));
                    end
                    if(~obj.Acquisition.TimeStamped(II))
                        obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{II}=NaN*ones(1,obj.Acquisition.VarBuffersize(II));
                        obj.Recorder.AcquisitionNonTimeStampedBuffersize(II)=obj.Acquisition.VarBuffersize(II);
                        obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(II)=0;
                        obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(II)=1;
                        obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(II)=0;
                        obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(II)=0;
                    end
                end
            end
            
            if(obj.Acquisition.BSA)
                try
                    [~,ts]=lcaGetSmart(obj.Acquisition.PV_For_Time_Reference);
                    obj.Recorder.LastValidTime= double(real(ts)) + double(imag(ts)/10^9);
                catch
                    obj.Recorder.LastValidTime=-inf;
                end
            end
            
            obj.Recorder.AbsoluteCaptureID=0;
        end %zeroAllBuffers(obj)
        
        function BuildAcquisitionStructure(obj)
            InsertedData=0;
            InsertedSynchronousPVs=0;
            InsertedOncePerCyle=0;
            InsertedProfiles=0;
            InsertedNonTSProfiles=0;
            InsertedOnlyOnce=0;
            
            PositionWithinData=3;
            
            ReadOnceScalarsInserted=0;
            ScalarsInserted=0;
            VectorsInserted=0;
            Arrays2DInserted=0;
            TotalProfiles=0;
            
            obj.Acquisition.SynchronousPVs={};
            obj.Acquisition.OncePerCyclePVs={};
            obj.Acquisition.OnlyOncePVs={};
            obj.Acquisition.ProfilePVs=[];
            obj.Acquisition.ProfileNonTS_PVs=[];
            
            obj.Acquisition.SingleValueScalars={};
            obj.Acquisition.Scalars={};
            obj.Acquisition.Vectors={};
            obj.Acquisition.Arrays2D={};
            obj.Acquisition.SingleValueScalars_Positions=[];
            obj.Acquisition.Scalars_Positions=[];
            obj.Acquisition.Vectors_Positions=[];
            obj.Acquisition.Arrays2D_Positions=[];
            
            if(isfield(obj.InputStructure,'Author'))
                obj.Acquisition.Author=obj.InputStructure.Author;
            else
                obj.Acquisition.Author='Mathworks MatLab';
            end
            
            obj.Acquisition.Buffersize=obj.InputStructure.Buffersize;
            obj.Acquisition.Synchronous=obj.InputStructure.Synchronous;
            obj.Acquisition.BSA=obj.InputStructure.BSA;
            obj.Acquisition.BSA_Exclusion=obj.InputStructure.BSA_Exclusion;
            obj.Acquisition.Blocksize=obj.InputStructure.Blocksize;
            obj.Acquisition.TimeCycle=obj.InputStructure.TimeCycle;
            obj.Acquisition.StopAfterBufferFilled=obj.InputStructure.StopBufferFilled;
            
            switch(obj.InputStructure.BufferFullFunction)
                case 'DoNothing'
                    obj.Acquisition.DumpAfterBufferFilled=0;
                    obj.Acquisition.DumpAfterBufferFilledFunction=@obj.DoNothing;
                case 'SaveOnDisk'
                    obj.Acquisition.DumpAfterBufferFilled=1;
                    obj.Acquisition.DumpAfterBufferFilledFunction=@obj.SaveOnDisk;
                otherwise
                    obj.Acquisition.DumpAfterBufferFilled=1;
                    obj.Acquisition.DumpAfterBufferFilledFunction=eval(['@',obj.InputStructure.BufferFullFunction]);
            end
            obj.Acquisition.CheckForBufferCompleted=obj.Acquisition.DumpAfterBufferFilled || obj.Acquisition.StopAfterBufferFilled;
            
            obj.Acquisition.SpawnMultiple=obj.InputStructure.SpawnMultiple;
            obj.Acquisition.ProfileTimeStamped=[];
            obj.Acquisition.NonTimeStampedProfilesPositionWithinData=[];
            
            if(obj.Acquisition.BSA && ~obj.InputStructure.Synchronous) %pre-screens. If not any array in recording and BSA turns it to synchronous.
                obj.Acquisition.Synchronous=1;
                for II=1:numel(obj.InputStructure.Variables)
                    if(prod(obj.InputStructure.Variables{II}.size) > 1)
                        obj.Acquisition.Synchronous=0;
                        break
                    end
                end
                if(obj.Acquisition.Synchronous)
                    disp('Turned acquisition to Synchronous because no profiles are recorded.')
                end
            end
            
            COUNTERERROR=0;
            obj.Acquisition.TimeStamped(1)=1;obj.Acquisition.TimeStamped(2)=0;obj.Acquisition.TimeStamped(3)=0;
            obj.Acquisition.VarBuffersize(2)=obj.Acquisition.Buffersize;
            obj.Acquisition.VarBuffersize(3)=obj.Acquisition.Buffersize;
                        
            for II=1:numel(obj.InputStructure.Variables)
                if(prod(obj.InputStructure.Variables{II}.size) ==1) %it is a scalar
                    if(obj.InputStructure.Variables{II}.Synchronous) %it is synchronous
                        InsertedData=InsertedData+1;
                        obj.Acquisition.VarNames{InsertedData} = obj.InputStructure.Variables{II}.name;
                        InsertedSynchronousPVs=InsertedSynchronousPVs+1;
                        obj.Acquisition.SynchronousPVs{InsertedSynchronousPVs} = obj.InputStructure.Variables{II}.PVname;
                        obj.Acquisition.VarPosition(InsertedData,:) = [1, InsertedSynchronousPVs] ;
                        ScalarsInserted=ScalarsInserted+1;
                        obj.Acquisition.Scalars{ScalarsInserted}=obj.InputStructure.Variables{II}.name;
                        obj.Acquisition.Scalars_Positions(ScalarsInserted,:) = [1, InsertedSynchronousPVs] ;
                        if(InsertedSynchronousPVs==1)
                            obj.Acquisition.Mode4BSA_PV= obj.InputStructure.Variables{II}.PVname;
                        end
                        if(obj.InputStructure.InsertedCounterVariable ==II)
                            obj.Acquisition.AsynchronousVarCounter=[1,InsertedSynchronousPVs] ;
                        end
                    else %it is not synchronous
                        if(~obj.InputStructure.Variables{II}.ReadOnlyOnce)
                            InsertedData=InsertedData+1;
                            obj.Acquisition.VarNames{InsertedData} = obj.InputStructure.Variables{II}.name;
                            InsertedOncePerCyle=InsertedOncePerCyle+1;
                            obj.Acquisition.OncePerCyclePVs{InsertedOncePerCyle} = obj.InputStructure.Variables{II}.PVname;
                            obj.Acquisition.VarPosition(InsertedData,:) = [2, length(obj.Acquisition.OncePerCyclePVs)] ;
                            ScalarsInserted=ScalarsInserted+1;
                            obj.Acquisition.Scalars{ScalarsInserted}=obj.InputStructure.Variables{II}.name;
                            obj.Acquisition.Scalars_Positions(ScalarsInserted,:) = [2, length(obj.Acquisition.OncePerCyclePVs)] ;
                            if(obj.InputStructure.InsertedCounterVariable ==II)
                                obj.Acquisition.AsynchronousVarCounter=[2,1] ;
                            end
                        else
                            InsertedData=InsertedData+1;
                            obj.Acquisition.VarNames{InsertedData} = obj.InputStructure.Variables{II}.name;
                            InsertedOnlyOnce=InsertedOnlyOnce+1;
                            obj.Acquisition.OnlyOncePVs{InsertedOnlyOnce} = obj.InputStructure.Variables{II}.PVname;
                            ReadOnceScalarsInserted=ReadOnceScalarsInserted+1;
                            obj.Acquisition.VarPosition(InsertedData,:) = [3, length(obj.Acquisition.OnlyOncePVs)] ;
                            obj.Acquisition.SingleValueScalars{ReadOnceScalarsInserted}=obj.InputStructure.Variables{II}.name;
                            obj.Acquisition.SingleValueScalars_Positions(ReadOnceScalarsInserted,:) = [3, length(obj.Acquisition.OnlyOncePVs)] ;
                            if(obj.InputStructure.InsertedCounterVariable ==II)
                                COUNTERERROR=1; % You cannot put the variable counter on something that is counted only once!
                            end
                        end
                    end
                else %it is a vector or image or post processing thing
                    TimeStamped=obj.InputStructure.Variables{II}.TimeStamped;
                    TotalProfiles=TotalProfiles+1;
                    obj.Acquisition.ProfileTimeStamped(TotalProfiles)=TimeStamped;
                    if(~TimeStamped)
                        InsertedNonTSProfiles=InsertedNonTSProfiles+1;
                        obj.Acquisition.ProfileNonTS_PVs(InsertedNonTSProfiles).PVName = obj.InputStructure.Variables{II}.PVName;
                        obj.Acquisition.ProfileNonTS_PVs(InsertedNonTSProfiles).ReadSize = prod(obj.InputStructure.Variables{II}.size);
                        obj.Acquisition.ProfileNonTS_PVs(InsertedNonTSProfiles).Background = obj.InputStructure.Variables{II}.Background;
                        obj.Acquisition.ProfileNonTS_PVs(InsertedNonTSProfiles).AsynchOffsetStart=PositionWithinData;
                        PositionWithinData=PositionWithinData+1;
                        InsertedData=InsertedData+1;
                        obj.Acquisition.VarNames{InsertedData} = obj.InputStructure.Variables{II}.name;
                        obj.Acquisition.VarPosition(InsertedData,:) = [PositionWithinData, 0] ;
                        obj.Acquisition.TimeStamped(PositionWithinData)=0;
                        obj.Acquisition.NonTimeStampedProfilesPositionWithinData(end+1)=PositionWithinData;
                        
                        if((obj.InputStructure.Variables{II}.size(1) == 1) || (obj.InputStructure.Variables{II}.size(2)==1))
                            obj.Acquisition.ProfileNonTS_PVs(InsertedNonTSProfiles).IsVector=1;
                            %this is a vector
                            if(obj.InputStructure.Variables{II}.size(1)~=1)
                                obj.Acquisition.ProfileNonTS_PVs(InsertedNonTSProfiles).AutoTranspose = 1;
                                obj.Acquisition.AllSizes{PositionWithinData}(1:2) = [1,obj.InputStructure.Variables{II}.size(1)];
                                obj.Acquisition.ProfileNonTS_PVs(InsertedNonTSProfiles).ReshapeSize=obj.InputStructure.Variables{II}.size(1);
                            else
                                obj.Acquisition.ProfileNonTS_PVs(InsertedNonTSProfiles).AutoTranspose = 0;
                                obj.Acquisition.AllSizes{PositionWithinData}(1:2) = [1,obj.InputStructure.Variables{II}.size(2)];
                                obj.Acquisition.ProfileNonTS_PVs(InsertedNonTSProfiles).ReshapeSize=obj.InputStructure.Variables{II}.size(2);
                            end
                            obj.Acquisition.AllSizes{PositionWithinData}(1) = obj.InputStructure.Variables{II}.Buffersize ;
                            obj.Acquisition.VarBuffersize(PositionWithinData)= obj.InputStructure.Variables{II}.Buffersize;
                            VectorsInserted=VectorsInserted+1;
                            obj.Acquisition.Vectors{VectorsInserted}=obj.InputStructure.Variables{II}.name;
                            obj.Acquisition.Vectors_Positions(VectorsInserted,:) = [PositionWithinData, 0] ;
                        else
                            obj.Acquisition.ProfileNonTS_PVs(InsertedNonTSProfiles).IsVector=0;
                            obj.Acquisition.AllSizes{PositionWithinData} = [obj.InputStructure.Variables{II}.size(1),obj.InputStructure.Variables{II}.size(2)];
                            obj.Acquisition.ProfileNonTS_PVs(InsertedNonTSProfiles).ReshapeSize=[obj.InputStructure.Variables{II}.size(1),obj.InputStructure.Variables{II}.size(2)];
                            obj.Acquisition.AllSizes{PositionWithinData}(3) = obj.InputStructure.Variables{II}.Buffersize ;
                            obj.Acquisition.VarBuffersize(PositionWithinData)= obj.InputStructure.Variables{II}.Buffersize;
                            Arrays2DInserted=Arrays2DInserted+1;
                            obj.Acquisition.Arrays2D{Arrays2DInserted}=obj.InputStructure.Variables{II}.name;
                            obj.Acquisition.Arrays2D_Positions(Arrays2DInserted,:) = [PositionWithinData, 0] ;
                        end
                    else
                        %Add it first to the profiles to be read
                        InsertedProfiles=InsertedProfiles+1;
                        obj.Acquisition.ProfilePVs(InsertedProfiles).PVName = obj.InputStructure.Variables{II}.PVName;
                        obj.Acquisition.ProfilePVs(InsertedProfiles).ReadSize = prod(obj.InputStructure.Variables{II}.size);
                        obj.Acquisition.ProfilePVs(InsertedProfiles).Background = obj.InputStructure.Variables{II}.Background;
                        obj.Acquisition.ProfilePVs(InsertedProfiles).PostProcessing = obj.InputStructure.Variables{II}.PostProcessing;
                        obj.Acquisition.ProfilePVs(InsertedProfiles).PostProcessingFunction = obj.InputStructure.Variables{II}.PostProcessingFunction;
                        obj.Acquisition.ProfilePVs(InsertedProfiles).PostProcessingOptions = obj.InputStructure.Variables{II}.PostProcessingOptions;
                        obj.Acquisition.ProfilePVs(InsertedProfiles).PID_Delay = obj.InputStructure.Variables{II}.PID_Delay;
                        obj.Acquisition.ProfilePVs(InsertedProfiles).AsynchOffsetStart=PositionWithinData;
                        if(~obj.InputStructure.Variables{II}.PostProcessing)
                            PositionWithinData=PositionWithinData+1;
                            if(obj.InputStructure.InsertedCounterVariable ==II)
                                obj.Acquisition.AsynchronousVarCounter=[PositionWithinData,1] ;
                            end
                            InsertedData=InsertedData+1;
                            obj.Acquisition.VarNames{InsertedData} = obj.InputStructure.Variables{II}.name;
                            obj.Acquisition.VarPosition(InsertedData,:) = [PositionWithinData, 0] ;
                            if(TimeStamped), obj.Acquisition.TimeStamped(PositionWithinData)=obj.InputStructure.Variables{II}.TimeStamped; end
                            if((obj.InputStructure.Variables{II}.size(1) == 1) || (obj.InputStructure.Variables{II}.size(2)==1))
                                obj.Acquisition.ProfilePVs(InsertedProfiles).IsVector=1;
                                %this is a vector
                                if(obj.InputStructure.Variables{II}.size(1)~=1)
                                    obj.Acquisition.ProfilePVs(InsertedProfiles).AutoTranspose = 1;
                                    obj.Acquisition.AllSizes{PositionWithinData}(1:2) = [1,obj.InputStructure.Variables{II}.size(1)];
                                    obj.Acquisition.ProfilePVs(InsertedProfiles).ReshapeSize=obj.InputStructure.Variables{II}.size(1);
                                else
                                    obj.Acquisition.ProfilePVs(InsertedProfiles).AutoTranspose = 0;
                                    obj.Acquisition.AllSizes{PositionWithinData}(1:2) = [1,obj.InputStructure.Variables{II}.size(2)];
                                    obj.Acquisition.ProfilePVs(InsertedProfiles).ReshapeSize=obj.InputStructure.Variables{II}.size(2);
                                end
                                if(obj.InputStructure.Synchronous)
                                    obj.Acquisition.AllSizes{PositionWithinData}(1) = obj.InputStructure.Buffersize ;
                                else
                                    obj.Acquisition.AllSizes{PositionWithinData}(1) = obj.InputStructure.Variables{II}.Buffersize ;
                                    obj.Acquisition.VarBuffersize(PositionWithinData)= obj.InputStructure.Variables{II}.Buffersize;
                                end
                                VectorsInserted=VectorsInserted+1;
                                obj.Acquisition.Vectors{VectorsInserted}=obj.InputStructure.Variables{II}.name;
                                obj.Acquisition.Vectors_Positions(VectorsInserted,:) = [PositionWithinData, 0] ;
                            else
                                obj.Acquisition.ProfilePVs(InsertedProfiles).IsVector=0;
                                obj.Acquisition.AllSizes{PositionWithinData} = [obj.InputStructure.Variables{II}.size(1),obj.InputStructure.Variables{II}.size(2)];
                                obj.Acquisition.ProfilePVs(InsertedProfiles).ReshapeSize=[obj.InputStructure.Variables{II}.size(1),obj.InputStructure.Variables{II}.size(2)];
                                if(obj.InputStructure.Synchronous)
                                    obj.Acquisition.AllSizes{PositionWithinData}(3) = obj.InputStructure.Buffersize ;
                                else
                                    obj.Acquisition.AllSizes{PositionWithinData}(3) = obj.InputStructure.Variables{II}.Buffersize ;
                                    obj.Acquisition.VarBuffersize(PositionWithinData)= obj.InputStructure.Variables{II}.Buffersize;
                                end
                                Arrays2DInserted=Arrays2DInserted+1;
                                obj.Acquisition.Arrays2D{Arrays2DInserted}=obj.InputStructure.Variables{II}.name;
                                obj.Acquisition.Arrays2D_Positions(Arrays2DInserted,:) = [PositionWithinData, 0] ;
                            end
                        else
                            %Call PostProcessingFunction in Init Mode, with options to discover
                            %the size of the outputs.
                            Options=obj.Acquisition.ProfilePVs(InsertedProfiles).PostProcessingFunction(ones(1,obj.Acquisition.ProfilePVs(InsertedProfiles).ReadSize),obj.Acquisition.ProfilePVs(InsertedProfiles).PostProcessingOptions,obj.Acquisition.ProfilePVs(InsertedProfiles),[],1);
                            %(InputData,Options,Background,RawTimeStamp,Initialize)
                            obj.Acquisition.ProfilePVs(InsertedProfiles).UseExternalTimeStamps=Options.UseExternalTimeStamps;
                            obj.Acquisition.ProfilePVs(InsertedProfiles).Options=Options;
                            if(Options.NumberOfScalars)
                                PositionWithinData=PositionWithinData+1;
                                if(obj.InputStructure.InsertedCounterVariable ==II)
                                    obj.Acquisition.AsynchronousVarCounter=[PositionWithinData,1] ;
                                end
                                for HH=1:Options.NumberOfScalars
                                    InsertedData=InsertedData+1;
                                    if(TimeStamped), obj.Acquisition.TimeStamped(PositionWithinData)=obj.InputStructure.Variables{II}.TimeStamped; end
                                    obj.Acquisition.VarNames{InsertedData} = Options.ScalarNames{HH};
                                    obj.Acquisition.VarPosition(InsertedData,:) = [PositionWithinData, HH] ;
                                    ScalarsInserted=ScalarsInserted+1;
                                    obj.Acquisition.Scalars{ScalarsInserted}=Options.ScalarNames{HH};
                                    obj.Acquisition.Scalars_Positions(ScalarsInserted,:) = [PositionWithinData, HH] ;
                                end
                                if(obj.InputStructure.Synchronous)
                                    obj.Acquisition.AllSizes{PositionWithinData}(1) = obj.InputStructure.Buffersize ;
                                else
                                    obj.Acquisition.AllSizes{PositionWithinData}(1) = obj.InputStructure.Variables{II}.Buffersize ;
                                    obj.Acquisition.VarBuffersize(PositionWithinData)= obj.InputStructure.Variables{II}.Buffersize;
                                end
                                obj.Acquisition.AllSizes{PositionWithinData}(2) = HH;
                            end
                            if(Options.NumberOfVectors)
                                for HH=1:Options.NumberOfVectors
                                    PositionWithinData=PositionWithinData+1;
                                    if(TimeStamped), obj.Acquisition.TimeStamped(PositionWithinData)=obj.InputStructure.Variables{II}.TimeStamped; end
                                    if(obj.InputStructure.InsertedCounterVariable ==II)
                                        obj.Acquisition.AsynchronousVarCounter=[PositionWithinData,1] ;
                                    end
                                    InsertedData=InsertedData+1;
                                    obj.Acquisition.VarNames{InsertedData} = Options.VectorNames{HH};
                                    obj.Acquisition.VarPosition(InsertedData,:) = [PositionWithinData, 0] ;
                                    if(obj.InputStructure.Synchronous)
                                        obj.Acquisition.AllSizes{PositionWithinData}(1) = obj.InputStructure.Buffersize ;
                                    else
                                        obj.Acquisition.AllSizes{PositionWithinData}(1) = obj.InputStructure.Variables{II}.Buffersize ;
                                        obj.Acquisition.VarBuffersize(PositionWithinData)= obj.InputStructure.Variables{II}.Buffersize;
                                    end
                                    obj.Acquisition.AllSizes{PositionWithinData}(2) = Options.VectorSizes(HH);
                                    VectorsInserted=VectorsInserted+1;
                                    obj.Acquisition.Vectors{VectorsInserted}=Options.VectorNames{HH};
                                    obj.Acquisition.Vectors_Positions(VectorsInserted,:) = [PositionWithinData, 0] ;
                                end
                            end
                            if(Options.NumberOfArray2D)
                                for HH=1:Options.NumberOfArray2D
                                    PositionWithinData=PositionWithinData+1;
                                    if(TimeStamped), obj.Acquisition.TimeStamped(PositionWithinData)=obj.InputStructure.Variables{II}.TimeStamped; end
                                    if(obj.InputStructure.InsertedCounterVariable ==II)
                                        obj.Acquisition.AsynchronousVarCounter=[PositionWithinData,1] ;
                                    end
                                    InsertedData=InsertedData+1;
                                    obj.Acquisition.VarNames{InsertedData} = Options.Array2DNames{HH};
                                    obj.Acquisition.VarPosition(InsertedData,:) = [PositionWithinData, 0] ;
                                    if(obj.InputStructure.Synchronous)
                                        obj.Acquisition.AllSizes{PositionWithinData}(3) = obj.InputStructure.Buffersize ;
                                    else
                                        obj.Acquisition.AllSizes{PositionWithinData}(3) = obj.InputStructure.Variables{II}.Buffersize ;
                                        obj.Acquisition.VarBuffersize(PositionWithinData)= obj.InputStructure.Variables{II}.Buffersize;
                                    end
                                    obj.Acquisition.AllSizes{PositionWithinData}(1) = Options.Array2DSizes(HH,1);
                                    obj.Acquisition.AllSizes{PositionWithinData}(2) = Options.Array2DSizes(HH,2);
                                    Arrays2DInserted=Arrays2DInserted+1;
                                    obj.Acquisition.Arrays2D{Arrays2DInserted}=Options.Array2DNames{HH};
                                    obj.Acquisition.Arrays2D_Positions(Arrays2DInserted,:) = [PositionWithinData, 0] ;
                                end
                            end
                        end
                    end
                    
                end
            end
            
            obj.Acquisition.AllSizes{1}=[obj.InputStructure.Buffersize,InsertedSynchronousPVs];
            obj.Acquisition.AllSizes{2}=[obj.InputStructure.Buffersize,InsertedOncePerCyle];
            obj.Acquisition.AllSizes{3}=[1,InsertedOnlyOnce];
            
            obj.Acquisition.VarBuffersize(1)= obj.InputStructure.Buffersize;
            obj.Acquisition.VarBuffersize(2)= obj.InputStructure.Buffersize;
            obj.Acquisition.VarBuffersize(3)= 1;
            
            
            obj.Acquisition.UseRejection=0; Rejections_inserted=0;
            if(obj.Acquisition.Synchronous)
                if(isfield(obj.InputStructure,'Rejection'))
                    for TT=1:numel(obj.InputStructure.Rejection)
                        POS=find(strcmp(obj.Acquisition.SynchronousPVs,obj.InputStructure.Rejection(TT).PVname));
                        if(~isempty(POS))
                            Rejections_inserted=Rejections_inserted+1;
                            obj.Acquisition.UseRejection=1;
                            obj.Acquisition.Rejection(Rejections_inserted).PVName=obj.InputStructure.Rejection(TT).PVname;
                            obj.Acquisition.Rejection(Rejections_inserted).POS=POS;
                            obj.Acquisition.Rejection(Rejections_inserted).LO=obj.InputStructure.Rejection(TT).Range(1);
                            obj.Acquisition.Rejection(Rejections_inserted).HI=obj.InputStructure.Rejection(TT).Range(2);
                        end
                    end
                end
            end
            
            obj.Acquisition.NumberSynchPVs=numel(obj.Acquisition.SynchronousPVs);
            obj.Acquisition.NumberProfiles=numel(obj.Acquisition.ProfilePVs);
            obj.Acquisition.NumberProfilesNonTS=numel(obj.Acquisition.ProfileNonTS_PVs);
            obj.Acquisition.NumberOncePerCyclePVs=numel(obj.Acquisition.OncePerCyclePVs);
            
            obj.Acquisition.DoScan=obj.InputStructure.DoScan;
            obj.Acquisition.ScanBufferPVs={};
            obj.Acquisition.NumberOfScanPVs=0;
            if(obj.Acquisition.DoScan && ~isempty(obj.InputStructure.ScanSetting.ConditionsTable))
                obj.ScanSetting=obj.InputStructure.ScanSetting;
                obj.Acquisition.Scan.Functions=obj.InputStructure.ScanSetting.Scan.Functions;
                if(isfield(obj.Acquisition.Scan,'Name'))
                    obj.Acquisition.Scan.Name=obj.InputStructure.ScanSetting.Scan.Name;
                end
                PositionWithinData=PositionWithinData+1;
                obj.Acquisition.Scan.ScanDataPosition=PositionWithinData;
                for TT=1:numel(obj.InputStructure.ScanSetting.LcaPutNoWaitList)
                    InsertedData=InsertedData+1;
                    obj.Acquisition.VarNames{InsertedData} = obj.InputStructure.ScanSetting.LcaPutNoWaitList{TT};
                    obj.Acquisition.NumberOfScanPVs=obj.Acquisition.NumberOfScanPVs+1;
                    %obj.Acquisition.OncePerCyclePVs{obj.Acquisition.NumberOfScanPVs} = obj.InputStructure.ScanSetting.LcaPutNoWaitList{TT};
                    obj.Acquisition.VarPosition(InsertedData,:) = [PositionWithinData, obj.Acquisition.NumberOfScanPVs] ;
                    ScalarsInserted=ScalarsInserted+1;
                    obj.Acquisition.Scalars{ScalarsInserted}=obj.InputStructure.ScanSetting.LcaPutNoWaitList{TT};
                    obj.Acquisition.Scalars_Positions(ScalarsInserted,:) = [PositionWithinData, obj.Acquisition.NumberOfScanPVs] ;
                end
                obj.Acquisition.Scan.Values=obj.InputStructure.ScanSetting.PVValues;
                [SA,SB]=size(obj.InputStructure.ScanSetting.ConditionsTable);
                for TT=1:SA
                    InsertedData=InsertedData+1;
                    obj.Acquisition.VarNames{InsertedData} = ['Knob #',num2str(TT)];
                    obj.Acquisition.NumberOfScanPVs=obj.Acquisition.NumberOfScanPVs+1;
                    %obj.Acquisition.OncePerCyclePVs{obj.Acquisition.NumberOfScanPVs} = ['Knob #',num2str(TT)];
                    obj.Acquisition.VarPosition(InsertedData,:) = [PositionWithinData, obj.Acquisition.NumberOfScanPVs] ;
                    ScalarsInserted=ScalarsInserted+1;
                    obj.Acquisition.Scalars{ScalarsInserted}= ['Knob #',num2str(TT)];
                    obj.Acquisition.Scalars_Positions(ScalarsInserted,:) = [PositionWithinData, obj.Acquisition.NumberOfScanPVs] ;
                end
                obj.Acquisition.Scan.Values=[obj.Acquisition.Scan.Values ; obj.InputStructure.ScanSetting.ConditionsTable];
                InsertedData=InsertedData+1;
                obj.Acquisition.VarNames{InsertedData} = 'Scan Position';
                obj.Acquisition.NumberOfScanPVs=obj.Acquisition.NumberOfScanPVs+1;
                %obj.Acquisition.OncePerCyclePVs{obj.Acquisition.NumberOfScanPVs} = 'Scan Position';
                obj.Acquisition.VarPosition(InsertedData,:) = [PositionWithinData, obj.Acquisition.NumberOfScanPVs] ;
                ScalarsInserted=ScalarsInserted+1;
                obj.Acquisition.Scalars{ScalarsInserted}= 'Scan Position';
                obj.Acquisition.Scalars_Positions(ScalarsInserted,:) = [PositionWithinData, obj.Acquisition.NumberOfScanPVs] ;
                obj.Acquisition.Scan.Values=[obj.Acquisition.Scan.Values ; 1:SB];
                for TT=1:numel(obj.InputStructure.ScanSetting.PhysicalVariables)
                    InsertedData=InsertedData+1;
                    obj.Acquisition.VarNames{InsertedData} = obj.InputStructure.ScanSetting.PhysicalVariables{TT};
                    obj.Acquisition.NumberOfScanPVs=obj.Acquisition.NumberOfScanPVs+1;
                    %obj.Acquisition.OncePerCyclePVs{obj.Acquisition.NumberOfScanPVs} = obj.InputStructure.ScanSetting.PhysicalVariables{TT};
                    obj.Acquisition.VarPosition(InsertedData,:) = [PositionWithinData, obj.Acquisition.NumberOfScanPVs] ;
                    ScalarsInserted=ScalarsInserted+1;
                    obj.Acquisition.Scalars{ScalarsInserted}= obj.InputStructure.ScanSetting.PhysicalVariables{TT};
                    obj.Acquisition.Scalars_Positions(ScalarsInserted,:) = [PositionWithinData, obj.Acquisition.NumberOfScanPVs] ;
                end
                if(~isempty(obj.InputStructure.ScanSetting.PhysicalVariables))
                    obj.Acquisition.Scan.Values=[obj.Acquisition.Scan.Values ; obj.InputStructure.ScanSetting.PhysicalValues];
                end
                obj.Acquisition.Scan.ParameterSpace=obj.InputStructure.ScanSetting.ParameterSpace;
                obj.Acquisition.Scan.PVValues=obj.InputStructure.ScanSetting.PVValues;
                obj.Acquisition.Scan.PauseValue=obj.InputStructure.ScanSetting.PauseValue;
                obj.Acquisition.Scan.ReadOutTable=obj.InputStructure.ScanSetting.ReadOutTable;
                obj.Acquisition.Scan.LcaPutNoWaitList=obj.InputStructure.ScanSetting.LcaPutNoWaitList;
                obj.Acquisition.Scan.PvsWithReadOut=obj.InputStructure.ScanSetting.PvsWithReadOut;
                obj.Acquisition.Scan.ConditionsTable=obj.InputStructure.ScanSetting.ConditionsTable;
                obj.Acquisition.Scan.Knob=obj.InputStructure.ScanSetting.Knob;
                obj.Acquisition.Scan.Condition_TOLERANCE=obj.InputStructure.ScanSetting.Condition_TOLERANCE;
                obj.Acquisition.Scan.PhysicalVariables=obj.InputStructure.ScanSetting.PhysicalVariables;
                obj.Acquisition.Scan.PhysicalValues=obj.InputStructure.ScanSetting.PhysicalValues;
                obj.Acquisition.AllSizes{PositionWithinData}=[obj.InputStructure.Buffersize,obj.Acquisition.NumberOfScanPVs];
                obj.Acquisition.VarBuffersize(PositionWithinData)=obj.InputStructure.Buffersize;
                obj.Acquisition.TimeStamped(PositionWithinData)=0;
                obj.Acquisition.Scan.Samples=obj.InputStructure.ScanSetting.Samples;
                obj.Acquisition.Scan.Values=obj.Acquisition.Scan.Values.';
                obj.Acquisition.ScanVarCounter = obj.Acquisition.AsynchronousVarCounter;%obj.Acquisition.VarPosition(obj.InputStructure.ScanSetting.RelevantVariablePosition,:);
                obj.ScanSetting.Values=obj.Acquisition.Scan.Values;
            else
                obj.ScanSetting=[];
            end
            
            if(InsertedSynchronousPVs==0)
                obj.Acquisition.BSA=0;
            end
            
            obj.Acquisition.PV_For_Time_Reference = obj.InputStructure.PV_For_Time_Reference;
            
            if(obj.Acquisition.BSA)
                try
                    [~,ts]=lcaGetSmart(obj.Acquisition.PV_For_Time_Reference);
                    obj.Acquisition.BSA_Vars.InitialTime= double(real(ts)) + double(imag(ts)/10^9);
                catch
                    obj.Acquisition.BSA_Vars.InitialTime= -inf;
                end
                if(obj.Acquisition.BSA==1)
                    obj.Acquisition.BSA_Vars.Phase_Cycle=0;
                    obj.Acquisition.BSA_Vars.Just_Started=1;
                    obj.Acquisition.BSA_Vars.current_time=0;
                    obj.Acquisition.BSA_Vars.GrabTurn=0;
                    obj.Acquisition.BSA_Vars.ReadCueValid=0;
                    obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data=obj.InputStructure.BSA_Safe_Trash_Data;
                else
                    obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data=obj.InputStructure.BSA_Safe_Trash_Data;
                end
            end
            
            if(COUNTERERROR)
                for TT=1:numel(obj.Acquisition.AllSizes)
                    if(prod(obj.Acquisition.AllSizes{TT}))
                        obj.Acquisition.AsynchronousVarCounter=TT;
                        if(TT==1)
                            obj.Acquisition.AsynchronousVarCounter(2)=1;
                        end
                        break
                    end
                end
            end
            
            if(isfield(obj.InputStructure,'UseLcaSetMonitor'))
                obj.Acquisition.UseLcaMonitor=obj.InputStructure.UseLcaSetMonitor;
            else
                obj.Acquisition.UseLcaMonitor=0;
            end
            
            if(~isempty(obj.Acquisition.SynchronousPVs))
                obj.Acquisition.SynchronousPVs=obj.Acquisition.SynchronousPVs.';
            end
            if(~isempty(obj.Acquisition.OncePerCyclePVs))
                obj.Acquisition.OncePerCyclePVs=obj.Acquisition.OncePerCyclePVs.';
            end
            if(~isempty(obj.Acquisition.OnlyOncePVs))
                obj.Acquisition.OnlyOncePVs=obj.Acquisition.OnlyOncePVs.';
            end
            if(~isempty(obj.Acquisition.Scalars))
                obj.Acquisition.Scalars=obj.Acquisition.Scalars.';
            end
            if(~isempty(obj.Acquisition.Vectors))
                obj.Acquisition.Vectors=obj.Acquisition.Vectors.';
            end
            if(~isempty(obj.Acquisition.Arrays2D))
                obj.Acquisition.Arrays2D=obj.Acquisition.Arrays2D.';
            end
            
            if(~isempty(obj.Acquisition.Scalars_Positions))
                obj.Acquisition.Scalars_Positions(:,3)=0;
            end
            if(~isempty(obj.Acquisition.Vectors_Positions))
                obj.Acquisition.Vectors_Positions(:,3)=0;
            end
            if(~isempty(obj.Acquisition.Arrays2D_Positions))
                obj.Acquisition.Arrays2D_Positions(:,3)=0;
            end
            obj.Acquisition.VarPosition(:,3)=0;
            
            for TT=1:length(obj.Acquisition.TimeStamped)
                if(obj.Acquisition.TimeStamped(TT))
                    if(~isempty(obj.Acquisition.Scalars_Positions))
                        obj.Acquisition.Scalars_Positions(obj.Acquisition.Scalars_Positions(:,1) == TT,3) = 1;
                    end
                    if(~isempty(obj.Acquisition.Vectors_Positions))
                        obj.Acquisition.Vectors_Positions(obj.Acquisition.Vectors_Positions(:,1) == TT,3) = 1;
                    end
                    if(~isempty(obj.Acquisition.Arrays2D_Positions))
                        obj.Acquisition.Arrays2D_Positions(obj.Acquisition.Arrays2D_Positions(:,1) == TT,3) = 1;
                    end
                    obj.Acquisition.VarPosition(obj.Acquisition.VarPosition(:,1) == TT,3) = 1;
                end
            end
            
            if(~isfield(obj.Acquisition,'AsynchronousVarCounter'))
                obj.Acquisition.AsynchronousVarCounter=[1,1];
                for SS=1:length(obj.Acquisition.VarBuffersize)
                    if(obj.Acquisition.VarBuffersize(SS)>1)
                        if(SS==1)
                            obj.Acquisition.AsynchronousVarCounter=[SS,1];
                        else
                            obj.Acquisition.AsynchronousVarCounter=SS;
                        end
                    end
                end
            end
            obj.Acquisition.ExitCondition=0;
        end %BuildAcquisitionStructure(obj)
        
        function Initialize_BSA(obj)
            if(obj.Acquisition.BSA==1)
                obj.myeDefNumber(1:2)=NaN;
                obj.my_names={'',''};
                try
                    lcaPutSmart(obj.BufferCounterName{1}, 1+lcaGetSmart(obj.BufferCounterName{1}));
                    nRuns1 = lcaGetSmart(obj.BufferCounterName{1});
                    lcaPutSmart(obj.BufferCounterName{2}, 1+lcaGetSmart(obj.BufferCounterName{2}));
                    nRuns2 = lcaGetSmart(obj.BufferCounterName{2});
                    if isnan(nRuns1) || isnan(nRuns2)
                        disp(['Channel access failure for ',obj.BufferCounterName{1}]);
                        disp(['Channel access failure for ',obj.BufferCounterName{2}]);
                        obj.my_names{1} = strcat(obj.Acquisition.SynchronousPVs, {'HST'}, {num2str(obj.myeDefNumber(1))});
                        obj.my_names{2} = strcat(obj.Acquisition.SynchronousPVs, {'HST'}, {num2str(obj.myeDefNumber(2))});
                        obj.my_names{1}{end+1} = sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',obj.myeDefNumber(1));
                        obj.my_names{1}{end+1} = sprintf('PATT:%s:1:SECHST%d','SYS0',obj.myeDefNumber(1));
                        obj.my_names{1}{end+1} = sprintf('PATT:%s:1:NSECHST%d','SYS0',obj.myeDefNumber(1));
                        obj.my_names{2}{end+1} = sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',obj.myeDefNumber(2));
                        obj.my_names{2}{end+1} = sprintf('PATT:%s:1:SECHST%d','SYS0',obj.myeDefNumber(2));
                        obj.my_names{2}{end+1} = sprintf('PATT:%s:1:NSECHST%d','SYS0',obj.myeDefNumber(2));
                        return;
                    end
                catch MEIdentifiers
                    disp('Had a problem trying to increment run count');
                    return;
                end
                BufferName{1} = sprintf('VOM_buffer_1_%d',nRuns1);
                obj.myeDefNumber(1) = eDefReserve(BufferName{1});
                if isequal (obj.myeDefNumber(1), 0)
                    disp('Sorry, failed to get eDef for Buffer 1');
                    obj.myeDefNumber(1)=NaN;
                    return;
                end
                BufferName{2} = sprintf('VOM_buffer_2_%d',nRuns2);
                obj.myeDefNumber(2) = eDefReserve(BufferName{2});
                if isequal (obj.myeDefNumber(2), 0)
                    disp('Sorry, failed to get eDef for Buffer 2');
                    eDefRelease(obj.myeDefNumber(1));
                    obj.myeDefNumber(2)=NaN;
                    return;
                end

                switch(obj.Acquisition.BSA_Exclusion)
                    case 0 %All
                        eDefParams (obj.myeDefNumber(1), 1, 2800, [], [], [], [], 0);
                        eDefParams (obj.myeDefNumber(2), 1, 2800, [], [], [], [], 0);
                    case 1 %HXR Only
                        eDefParams (obj.myeDefNumber(1), 1, 2800, [], [], [], [], 1);
                        eDefParams (obj.myeDefNumber(2), 1, 2800, [], [], [], [], 1);
                    case 2
                        eDefParams (obj.myeDefNumber(1), 1, 2800, [], [], [], [], 2);
                        eDefParams (obj.myeDefNumber(2), 1, 2800, [], [], [], [], 2);
                    otherwise
                        eDefParams (obj.myeDefNumber(1), 1, 2800, [], [], [], [], 1);
                        eDefParams (obj.myeDefNumber(2), 1, 2800, [], [], [], [], 1);
                        
                end
                eDefOff(obj.myeDefNumber(1));
                eDefOff(obj.myeDefNumber(2));
                
                obj.my_names{1} = strcat(obj.Acquisition.SynchronousPVs, {'HST'}, {num2str(obj.myeDefNumber(1))});
                obj.my_names{2} = strcat(obj.Acquisition.SynchronousPVs, {'HST'}, {num2str(obj.myeDefNumber(2))});
                obj.my_names{1}{end+1} = sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',obj.myeDefNumber(1));
                obj.my_names{1}{end+1} = sprintf('PATT:%s:1:SECHST%d','SYS0',obj.myeDefNumber(1));
                obj.my_names{1}{end+1} = sprintf('PATT:%s:1:NSECHST%d','SYS0',obj.myeDefNumber(1));
                obj.my_names{2}{end+1} = sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',obj.myeDefNumber(2));
                obj.my_names{2}{end+1} = sprintf('PATT:%s:1:SECHST%d','SYS0',obj.myeDefNumber(2));
                obj.my_names{2}{end+1} = sprintf('PATT:%s:1:NSECHST%d','SYS0',obj.myeDefNumber(2));
                
            else %use the history buffer.
                obj.myeDefNumber(1:2)=NaN; %no need to init anything if history buffer is used.
                obj.my_names={'',''};
                lcaPutSmart(obj.BufferCounterName{1}, 1+lcaGetSmart(obj.BufferCounterName{1}));
                lcaPutSmart(obj.BufferCounterName{2}, 1+lcaGetSmart(obj.BufferCounterName{2}));
            end
        end
        
        function ACQ_Cycle_SynchNoBSA(obj)
            obj.Recorder.AbsoluteCaptureID=obj.Recorder.AbsoluteCaptureID+1;
            
            if(obj.Acquisition.NumberOncePerCyclePVs)
                obj.Recorder.Data{2}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2),:)=lcaGetSmart(obj.Acquisition.OncePerCyclePVs);
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{2}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(2)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2);
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(2) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(2)+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)>obj.Recorder.AcquisitionNonTimeStampedBuffersize(2))
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(2)=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(2)+1;
                end
            end
            
            if(obj.Acquisition.DoScan)
                obj.Recorder.Data{obj.Acquisition.Scan.ScanDataPosition}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition),:)= obj.ScanSetting.Values(obj.ScanState.ScanPosition,:);
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{obj.Acquisition.Scan.ScanDataPosition}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition);
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.Scan.ScanDataPosition) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.Scan.ScanDataPosition)+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)>obj.Recorder.AcquisitionNonTimeStampedBuffersize(obj.Acquisition.Scan.ScanDataPosition))
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.Scan.ScanDataPosition)+1;
                end
            end
            
            for II=1:obj.Acquisition.NumberProfilesNonTS
                if(obj.Acquisition.ProfileNonTS_PVs(II).IsVector)
                    obj.Recorder.Data{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)),:) = lcaGetSmart(obj.Acquisition.ProfileNonTS_PVs(II).PVName);
                else
                    obj.Recorder.Data{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(:,:,obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))) = reshape(lcaGetSmart(obj.Acquisition.ProfileNonTS_PVs(II).PVName),obj.Acquisition.ProfileNonTS_PVs(II).ReshapeSize);
                end
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II));
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)) = obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))>obj.Recorder.AcquisitionNonTimeStampedBuffersize(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)))
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                end
            end
            
            for VL=1:obj.Acquisition.Blocksize
                for VCR=1:obj.Acquisition.NumberProfiles
                    [obj.Transient.ProfilePV{VCR}(VL,:),obj.Transient.Profile_TS(VCR,VL)]=lcaGetSmart(obj.Acquisition.ProfilePVs(VCR).PVName,obj.Acquisition.ProfilePVs(VCR).ReadSize);
                end
                if(obj.Acquisition.NumberSynchPVs)
                    [obj.Transient.SynchPV(:,VL),obj.Transient.SynchPV_TS(:,VL)]=lcaGetSmart(obj.Acquisition.SynchronousPVs);
                end
            end
            
            %post processing to have their pulse IDs. Those should be get first.
            
            for VCR=1:obj.Acquisition.NumberProfiles
                if(obj.Acquisition.ProfilePVs(VCR).PostProcessing)
                    POST_Proc_Data{VCR}=obj.Acquisition.ProfilePVs(VCR).PostProcessingFunction(obj.Transient.ProfilePV{VCR},obj.Acquisition.ProfilePVs(VCR).PostProcessingOptions,obj.Acquisition.ProfilePVs(VCR),obj.Transient.Profile_TS(VCR,:),0);
                    if(obj.Acquisition.ProfilePVs(VCR).UseExternalTimeStamps)
                        POST_Proc_Data{VCR}.PulseID=bitand(uint32(imag(POST_Proc_Data{VCR}.TimeStamps)),hex2dec('1FFFF')) + obj.Acquisition.ProfilePVs(VCR).PID_Delay;
                    end
                end
            end
            
            %Now Synchronize, you have all the timestamps, use them!
            
            if(obj.Acquisition.NumberSynchPVs) %start from this the synchronization
                obj.Transient.PulseIDs=double(bitand(uint32(imag(obj.Transient.SynchPV_TS)),hex2dec('1FFFF')));
                if(obj.Acquisition.UseRejection)
                    for TT=1:numel(obj.Acquisition.Rejection) %If some rejection is required, just NaN the unwanted data in the pulse IDs.
                        obj.Transient.PulseIDs(obj.Acquisition.Rejection(TT).POS,((obj.Transient.SynchPV(obj.Acquisition.Rejection(TT).POS,:)< obj.Acquisition.Rejection(TT).LO) | (obj.Transient.SynchPV(obj.Acquisition.Rejection(TT).POS,:)> obj.Acquisition.Rejection(TT).HI)))=NaN;
                    end
                end
                PID=setdiff(obj.Transient.PulseIDs(1,:),obj.Recorder.LastWrittenPulseID,'stable');
                for TT=2:obj.Acquisition.NumberSynchPVs
                    PID=intersect(PID, obj.Transient.PulseIDs(TT,:),'stable');
                end
                %now intersect with profiles...
                if(obj.Acquisition.NumberProfiles)
                    obj.Transient.Profile_PulseIDs= bitand(uint32(imag(obj.Transient.Profile_TS)),hex2dec('1FFFF'));
                end
                for VCR=1:numel(obj.Acquisition.ProfilePVs)
                    if(obj.Acquisition.ProfilePVs(VCR).PostProcessing) %then it must have calculated PulseIDs earlier...
                        PID=intersect(PID, POST_Proc_Data{VCR}.PulseID,'stable');
                    else %need to calculate pulse ID here and add pulse ID delay obj.Transient.Profile_TS(VCR,VL)
                        PID=intersect(PID, obj.Transient.Profile_PulseIDs(VCR,:) + obj.Acquisition.ProfilePVs(VCR).PID_Delay,'stable');
                    end
                end
            else %no Pvs? Start from profiles...
                obj.Transient.Profile_PulseIDs= bitand(uint32(imag(obj.Transient.Profile_TS)),hex2dec('1FFFF'));
                if(obj.Acquisition.ProfilePVs(1).PostProcessing)
                    PID=setdiff(POST_Proc_Data{1}.PulseID,obj.Recorder.LastWrittenPulseID,'stable');
                else
                    PID=setdiff(obj.Transient.Profile_PulseIDs(1,:) + obj.Acquisition.ProfilePVs(1).PID_Delay ,obj.Recorder.LastWrittenPulseID,'stable');
                end
                for VCR=2:obj.Acquisition.NumberProfiles
                    if(obj.Acquisition.ProfilePVs(VCR).PostProcessing) %then it must have calculated PulseIDs earlier...
                        PID=intersect(PID, POST_Proc_Data{VCR}.PulseID,'stable');
                    else %need to calculate pulse ID here and add pulse ID delay
                        PID=intersect(PID, obj.Transient.Profile_PulseIDs(VCR,:) + obj.Acquisition.ProfilePVs(VCR).PID_Delay,'stable');
                    end
                end
            end
            
            %At this stage we have the new PIDs that have to go in the recorded set.
            obj.Recorder.NewDataFoundLength=length(PID);
            DealWithStoringInTwoSteps=0; ActualSplit=0;
            if(obj.Recorder.NewDataFoundLength)
                obj.Recorder.LastWrittenPulseID = PID(end);
                if(obj.Recorder.NewDataFoundLength>(1+obj.Acquisition.Buffersize-obj.Recorder.NextWrittenElement)) %goes over the buffer size
                    obj.Recorder.LastWrittenElement=obj.Recorder.NewDataFoundLength-obj.Acquisition.Buffersize+obj.Recorder.NextWrittenElement-1;
                    obj.Recorder.Destination=[obj.Recorder.NextWrittenElement:obj.Acquisition.Buffersize,1:obj.Recorder.LastWrittenElement];
                    obj.Recorder.TimesBufferFilled=obj.Recorder.TimesBufferFilled+1;
                    if(obj.Acquisition.CheckForBufferCompleted)
                        DealWithStoringInTwoSteps=1;
                        ActualSplit=1;
                        Destinations{1}=obj.Recorder.NextWrittenElement:obj.Acquisition.Buffersize;
                        Destinations{2}=1:obj.Recorder.LastWrittenElement;
                        PIDS{1}=PID(1:length(Destinations{1}));
                        PIDS{2}=PID((length(Destinations{1})+1):end);
                    else
                       obj.Recorder.EventsAbsoluteCounter(obj.Recorder.Destination) = obj.Recorder.MaxEventsAbsoluteCounter + (1:obj.Recorder.NewDataFoundLength);
                       obj.Recorder.MaxEventsAbsoluteCounter = obj.Recorder.MaxEventsAbsoluteCounter + obj.Recorder.NewDataFoundLength; 
                    end
                    obj.Recorder.NextWrittenElement=obj.Recorder.LastWrittenElement+1;
                    if(obj.Recorder.NextWrittenElement > obj.Acquisition.Buffersize)
                        obj.Recorder.NextWrittenElement=1;
                    end
                else%does not go over buffer size.
                    obj.Recorder.LastWrittenElement=obj.Recorder.NextWrittenElement+obj.Recorder.NewDataFoundLength-1;
                    obj.Recorder.Destination=obj.Recorder.NextWrittenElement:obj.Recorder.LastWrittenElement;
                    obj.Recorder.NextWrittenElement=obj.Recorder.LastWrittenElement+1;
                    if(obj.Recorder.NextWrittenElement > obj.Acquisition.Buffersize)
                        obj.Recorder.NextWrittenElement=1;
                        obj.Recorder.TimesBufferFilled=obj.Recorder.TimesBufferFilled+1;
                        DealWithStoringInTwoSteps=1;
                    end
                    obj.Recorder.EventsAbsoluteCounter(obj.Recorder.Destination) = obj.Recorder.MaxEventsAbsoluteCounter + (1:obj.Recorder.NewDataFoundLength);
                    obj.Recorder.MaxEventsAbsoluteCounter = obj.Recorder.MaxEventsAbsoluteCounter + obj.Recorder.NewDataFoundLength;
                end
                
            else
                %No data has been found.
                return
            end
            
            if(~ActualSplit)
                PositionWithinData=3;
                obj.Recorder.AcquisitionWritingCycle(obj.Recorder.Destination)=obj.Recorder.AbsoluteCaptureID;
                if(obj.Recorder.NewDataFoundLength) %Fill buffers if any new data has been found.
                    if(obj.Acquisition.NumberSynchPVs) %If there are synchronous PVs fill those first...
                        [~,~,DOVE]=intersect(PID, obj.Transient.PulseIDs(1,:),'stable');
                        obj.Recorder.Data{1}(obj.Recorder.Destination,1) = obj.Transient.SynchPV(1,DOVE).';
                        obj.Recorder.TimeStamps(obj.Recorder.Destination)= obj.Transient.SynchPV_TS(1,DOVE);
                        obj.Recorder.PulseIds(obj.Recorder.Destination)= obj.Transient.PulseIDs(1,DOVE);
                        %         if(obj.Acquisition.DoScan) %This to be dealt differently
                        %             obj.Recorder.Data{end}(obj.Recorder.Destination,:) = repmat(obj.Acquisition.Scan.Table(obj.Acquisition.ScanPosition,:),[obj.Recorder.NewDataFoundLength,1]);
                        %         end
                        for TT=2:obj.Acquisition.NumberSynchPVs
                            [~,~,DOVE]=intersect(PID, obj.Transient.PulseIDs(TT,:),'stable');
                            obj.Recorder.Data{1}(obj.Recorder.Destination,TT) = obj.Transient.SynchPV(TT,DOVE).';
                        end
                        %Take care here of non synchronous PVs, there may be a different if
                        %they are 1 or more because how Matlab deals with sizes.
                        %         if(obj.Acquisition.NumberOncePerCyclePVs) not needed anymore !
                        %             if(obj.Acquisition.NumberOncePerCyclePVs==1)
                        %                 obj.Recorder.Data{2}(obj.Recorder.Destination,:)=ones(obj.Recorder.NewDataFoundLength,1)*(obj.Transient.UnSynchPV.');
                        %             else
                        %                 obj.Recorder.Data{2}(obj.Recorder.Destination,:)=ones(obj.Recorder.NewDataFoundLength,1)*(obj.Transient.UnSynchPV.');
                        %             end
                        %         end
                        %Now deal with profiles ...
                        for VCR=1:obj.Acquisition.NumberProfiles
                            while(any((PositionWithinData+1) == obj.Acquisition.NonTimeStampedProfilesPositionWithinData))
                                PositionWithinData=PositionWithinData+1;
                            end
                            if(obj.Acquisition.ProfilePVs(VCR).PostProcessing) %then it must have calculated PulseIDs earlier...
                                [~,~,DOVE]=intersect(PID, POST_Proc_Data{VCR}.PulseID,'stable'); %those are the same for all the data recorded.
                                if(obj.Acquisition.ProfilePVs(VCR).Options.NumberOfScalars)
                                    PositionWithinData=PositionWithinData+1;
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = POST_Proc_Data{VCR}.Scalars(:,DOVE).'; %Scalar data is in columns for some reason.
                                end
                                for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfVectors
                                    PositionWithinData=PositionWithinData+1;
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = POST_Proc_Data{VCR}.Vectors{NOI}(DOVE,:);
                                end
                                for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfArray2D
                                    PositionWithinData=PositionWithinData+1;
                                    obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = POST_Proc_Data{VCR}.Array2D{NOI}(:,:,DOVE);
                                end
                            else %need to calculate pulse ID here and add pulse ID delay
                                [~,~,DOVE]=intersect(PID, obj.Transient.Profile_PulseIDs(VCR,:) + obj.Acquisition.ProfilePVs(VCR).PID_Delay,'stable');
                                PositionWithinData=PositionWithinData+1;
                                if(obj.Acquisition.ProfilePVs(VCR).IsVector)
                                    if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                        obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = obj.Transient.ProfilePV{VCR}(DOVE,:);
                                    else
                                        obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = obj.Transient.ProfilePV{VCR}(DOVE,:) - ones(obj.Recorder.NewDataFoundLength,1)*obj.Acquisition.ProfilePVs(VCR).Background;
                                    end
                                else
                                    if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                        obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = permute(reshape(obj.Transient.ProfilePV{VCR}(DOVE,:),[obj.Recorder.NewDataFoundLength,obj.Acquisition.ProfilePVs(VCR).ReshapeSize]),[2,3,1]);
                                    else
%                                         if(obj.Recorder.NewDataFoundLength==1)
                             
                                        %obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = -repmat(obj.Acquisition.ProfilePVs(VCR).Background,obj.Recorder.NewDataFoundLength) + permute(reshape(obj.Transient.ProfilePV{VCR}(DOVE,:),[obj.Recorder.NewDataFoundLength,obj.Acquisition.ProfilePVs(VCR).ReshapeSize]),[2,3,1]);
                                            obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) =  permute(reshape(obj.Transient.ProfilePV{VCR}(DOVE,:)-repmat(obj.Acquisition.ProfilePVs(VCR).Background,[obj.Recorder.NewDataFoundLength,1]),[obj.Recorder.NewDataFoundLength,obj.Acquisition.ProfilePVs(VCR).ReshapeSize]),[2,3,1]);
%                                         else
%                                         obj.Recorder.NewDataFoundLength
%                                             obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = -repmat(obj.Acquisition.ProfilePVs(VCR).Background,obj.Recorder.NewDataFoundLength) + permute(reshape(obj.Transient.ProfilePV{VCR}(DOVE,:),[obj.Recorder.NewDataFoundLength,obj.Acquisition.ProfilePVs(VCR).ReshapeSize]),[2,3,1]);  
%                                         end
                                    end
                                end
                            end
                        end
                    else
                        TimeStampDone=0;
                        PulseIDDone=0;
                        for VCR=1:obj.Acquisition.NumberProfiles
                            while(any(PositionWithinData+1) == obj.Acquisition.NonTimeStampedProfilesPositionWithinData)
                                PositionWithinData=PositionWithinData+1;
                            end
                            if(obj.Acquisition.ProfilePVs(VCR).PostProcessing) %then it must have calculated PulseIDs earlier...
                                [~,~,DOVE]=intersect(PID, POST_Proc_Data{VCR}.PulseID,'stable');
                                if(~PulseIDDone)
                                    obj.Recorder.PulseIds(obj.Recorder.Destination)= POST_Proc_Data{VCR}.PulseID(DOVE);
                                    PulseIDDone=1;
                                end
                                if(obj.Acquisition.ProfilePVs(VCR).Options.NumberOfScalars)
                                    PositionWithinData=PositionWithinData+1;
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = POST_Proc_Data{VCR}.Scalars(:,DOVE).'; %Scalar data is in columns for some reason.
                                end
                                for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfVectors
                                    PositionWithinData=PositionWithinData+1;
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = POST_Proc_Data{VCR}.Vectors{NOI}(DOVE,:);
                                end
                                for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfArray2D
                                    PositionWithinData=PositionWithinData+1;
                                    obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = POST_Proc_Data{VCR}.Array2D{NOI}(:,:,DOVE);
                                end
                            else %need to calculate pulse ID here and add pulse ID delay
                                [~,~,DOVE]=intersect(PID, obj.Transient.Profile_PulseIDs(VCR,:) + obj.Acquisition.ProfilePVs(VCR).PID_Delay,'stable');
                                if(~TimeStampDone)
                                    obj.Recorder.PulseIds(obj.Recorder.Destination)= obj.Transient.Profile_PulseIDs(VCR,DOVE) + obj.Acquisition.ProfilePVs(VCR).PID_Delay;
                                    obj.Recorder.TimeStamps(obj.Recorder.Destination)= obj.Transient.Profile_TS(VCR,DOVE);
                                    PulseIDDone=1;
                                    TimeStampDone=1;
                                end
                                PositionWithinData=PositionWithinData+1;
                                if(obj.Acquisition.ProfilePVs(VCR).IsVector)
                                    if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                        obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = obj.Transient.ProfilePV{VCR}(DOVE,:);
                                    else
                                        obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = obj.Transient.ProfilePV{VCR}(DOVE,:) - ones(obj.Recorder.NewDataFoundLength,1)*obj.Acquisition.ProfilePVs(VCR).Background;
                                    end
                                else
                                    if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                        obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = permute(reshape(obj.Transient.ProfilePV{VCR}(DOVE,:),[obj.Recorder.NewDataFoundLength,obj.Acquisition.ProfilePVs(VCR).ReshapeSize]),[2,3,1]);
                                    else
                                        obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = -repmat(obj.Acquisition.ProfilePVs(VCR).Background,obj.Recorder.NewDataFoundLength) + permute(reshape(obj.Transient.ProfilePV{VCR}(DOVE,:),[obj.Recorder.NewDataFoundLength,obj.Acquisition.ProfilePVs(VCR).ReshapeSize]),[2,3,1]);
                                    end
                                end
                            end
                        end
                    end
                end % Inserimento effettivo dei dati.
                if(DealWithStoringInTwoSteps)
                    if(obj.Acquisition.StopAfterBufferFilled)
                        obj.Acquisition.ExitConditionMet=1;
                    end
                    if(obj.Acquisition.DumpAfterBufferFilled)
                        [SUCCESS,filename,TargetDir] = obj.SaveOnDisk(now,'AutomaticSave');
                    end
                end
            else % There is an actual split involved.
                if(obj.Acquisition.StopAfterBufferFilled), GroupToInsert=1; obj.Acquisition.ExitConditionMet=1; else, GroupToInsert=2; end
                for ZZ=1:GroupToInsert
                    PID=PIDS{ZZ};
                    obj.Recorder.Destination=Destinations{ZZ};
                    obj.Recorder.EventsAbsoluteCounter(obj.Recorder.Destination) = obj.Recorder.MaxEventsAbsoluteCounter + (1:length(obj.Recorder.Destination));
                    obj.Recorder.MaxEventsAbsoluteCounter = obj.Recorder.MaxEventsAbsoluteCounter + length(obj.Recorder.Destination); 
                    PositionWithinData=3;
                    obj.Recorder.AcquisitionWritingCycle(obj.Recorder.Destination)=obj.Recorder.AbsoluteCaptureID;
                    if(obj.Recorder.NewDataFoundLength) %Fill buffers if any new data has been found.
                        if(obj.Acquisition.NumberSynchPVs) %If there are synchronous PVs fill those first...
                            [~,~,DOVE]=intersect(PID, obj.Transient.PulseIDs(1,:),'stable');
                            obj.Recorder.Data{1}(obj.Recorder.Destination,1) = obj.Transient.SynchPV(1,DOVE).';
                            obj.Recorder.TimeStamps(obj.Recorder.Destination)= obj.Transient.SynchPV_TS(1,DOVE);
                            obj.Recorder.PulseIds(obj.Recorder.Destination)= obj.Transient.PulseIDs(1,DOVE);
                            %         if(obj.Acquisition.DoScan) %This to be dealt differently
                            %             obj.Recorder.Data{end}(obj.Recorder.Destination,:) = repmat(obj.Acquisition.Scan.Table(obj.Acquisition.ScanPosition,:),[obj.Recorder.NewDataFoundLength,1]);
                            %         end
                            for TT=2:obj.Acquisition.NumberSynchPVs
                                [~,~,DOVE]=intersect(PID, obj.Transient.PulseIDs(TT,:),'stable');
                                obj.Recorder.Data{1}(obj.Recorder.Destination,TT) = obj.Transient.SynchPV(TT,DOVE).';
                            end
                            %Take care here of non synchronous PVs, there may be a different if
                            %they are 1 or more because how Matlab deals with sizes.
                            %         if(obj.Acquisition.NumberOncePerCyclePVs) not needed anymore !
                            %             if(obj.Acquisition.NumberOncePerCyclePVs==1)
                            %                 obj.Recorder.Data{2}(obj.Recorder.Destination,:)=ones(obj.Recorder.NewDataFoundLength,1)*(obj.Transient.UnSynchPV.');
                            %             else
                            %                 obj.Recorder.Data{2}(obj.Recorder.Destination,:)=ones(obj.Recorder.NewDataFoundLength,1)*(obj.Transient.UnSynchPV.');
                            %             end
                            %         end
                            %Now deal with profiles ...
                            for VCR=1:obj.Acquisition.NumberProfiles
                                while(any((PositionWithinData+1) == obj.Acquisition.NonTimeStampedProfilesPositionWithinData))
                                    PositionWithinData=PositionWithinData+1;
                                end
                                if(obj.Acquisition.ProfilePVs(VCR).PostProcessing) %then it must have calculated PulseIDs earlier...
                                    [~,~,DOVE]=intersect(PID, POST_Proc_Data{VCR}.PulseID,'stable'); %those are the same for all the data recorded.
                                    if(obj.Acquisition.ProfilePVs(VCR).Options.NumberOfScalars)
                                        PositionWithinData=PositionWithinData+1;
                                        obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = POST_Proc_Data{VCR}.Scalars(:,DOVE).'; %Scalar data is in columns for some reason.
                                    end
                                    for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfVectors
                                        PositionWithinData=PositionWithinData+1;
                                        obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = POST_Proc_Data{VCR}.Vectors{NOI}(DOVE,:);
                                    end
                                    for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfArray2D
                                        PositionWithinData=PositionWithinData+1;
                                        obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = POST_Proc_Data{VCR}.Array2D{NOI}(:,:,DOVE);
                                    end
                                else %need to calculate pulse ID here and add pulse ID delay
                                    [~,~,DOVE]=intersect(PID, obj.Transient.Profile_PulseIDs(VCR,:) + obj.Acquisition.ProfilePVs(VCR).PID_Delay,'stable');
                                    PositionWithinData=PositionWithinData+1;
                                    if(obj.Acquisition.ProfilePVs(VCR).IsVector)
                                        if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                            obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = obj.Transient.ProfilePV{VCR}(DOVE,:);
                                        else
                                            obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = obj.Transient.ProfilePV{VCR}(DOVE,:) - ones(obj.Recorder.NewDataFoundLength,1)*obj.Acquisition.ProfilePVs(VCR).Background;
                                        end
                                    else
                                        if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                            obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = permute(reshape(obj.Transient.ProfilePV{VCR}(DOVE,:),[obj.Recorder.NewDataFoundLength,obj.Acquisition.ProfilePVs(VCR).ReshapeSize]),[2,3,1]);
                                        else
                                            obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = -repmat(obj.Acquisition.ProfilePVs(VCR).Background,obj.Recorder.NewDataFoundLength) + permute(reshape(obj.Transient.ProfilePV{VCR}(DOVE,:),[obj.Recorder.NewDataFoundLength,obj.Acquisition.ProfilePVs(VCR).ReshapeSize]),[2,3,1]);
                                        end
                                    end
                                end
                            end
                        else
                            TimeStampDone=0;
                            PulseIDDone=0;
                            for VCR=1:obj.Acquisition.NumberProfiles
                                while(any(PositionWithinData+1) == obj.Acquisition.NonTimeStampedProfilesPositionWithinData)
                                    PositionWithinData=PositionWithinData+1;
                                end
                                if(obj.Acquisition.ProfilePVs(VCR).PostProcessing) %then it must have calculated PulseIDs earlier...
                                    [~,~,DOVE]=intersect(PID, POST_Proc_Data{VCR}.PulseID,'stable');
                                    if(~PulseIDDone)
                                        obj.Recorder.PulseIds(obj.Recorder.Destination)= POST_Proc_Data{VCR}.PulseID(DOVE);
                                        PulseIDDone=1;
                                    end
                                    if(obj.Acquisition.ProfilePVs(VCR).Options.NumberOfScalars)
                                        PositionWithinData=PositionWithinData+1;
                                        obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = POST_Proc_Data{VCR}.Scalars(:,DOVE).'; %Scalar data is in columns for some reason.
                                    end
                                    for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfVectors
                                        PositionWithinData=PositionWithinData+1;
                                        obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = POST_Proc_Data{VCR}.Vectors{NOI}(DOVE,:);
                                    end
                                    for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfArray2D
                                        PositionWithinData=PositionWithinData+1;
                                        obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = POST_Proc_Data{VCR}.Array2D{NOI}(:,:,DOVE);
                                    end
                                else %need to calculate pulse ID here and add pulse ID delay
                                    [~,~,DOVE]=intersect(PID, obj.Transient.Profile_PulseIDs(VCR,:) + obj.Acquisition.ProfilePVs(VCR).PID_Delay,'stable');
                                    if(~TimeStampDone)
                                        obj.Recorder.PulseIds(obj.Recorder.Destination)= obj.Transient.Profile_PulseIDs(VCR,DOVE) + obj.Acquisition.ProfilePVs(VCR).PID_Delay;
                                        obj.Recorder.TimeStamps(obj.Recorder.Destination)= obj.Transient.Profile_TS(VCR,DOVE);
                                        PulseIDDone=1;
                                        TimeStampDone=1;
                                    end
                                    PositionWithinData=PositionWithinData+1;
                                    if(obj.Acquisition.ProfilePVs(VCR).IsVector)
                                        if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                            obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = obj.Transient.ProfilePV{VCR}(DOVE,:);
                                        else
                                            obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = obj.Transient.ProfilePV{VCR}(DOVE,:) - ones(obj.Recorder.NewDataFoundLength,1)*obj.Acquisition.ProfilePVs(VCR).Background;
                                        end
                                    else
                                        if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                            obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = permute(reshape(obj.Transient.ProfilePV{VCR}(DOVE,:),[obj.Recorder.NewDataFoundLength,obj.Acquisition.ProfilePVs(VCR).ReshapeSize]),[2,3,1]);
                                        else
                                            obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = -repmat(obj.Acquisition.ProfilePVs(VCR).Background,obj.Recorder.NewDataFoundLength) + permute(reshape(obj.Transient.ProfilePV{VCR}(DOVE,:),[obj.Recorder.NewDataFoundLength,obj.Acquisition.ProfilePVs(VCR).ReshapeSize]),[2,3,1]);
                                        end
                                    end
                                end
                            end
                        end
                    end % Inserimento effettivo dei dati.
                    if(GroupToInsert==1)
                        obj.Recorder.NextWrittenElement=1;
                    end
                    if(ZZ==1)
                        if(obj.Acquisition.DumpAfterBufferFilled)
                            [SUCCESS,filename,TargetDir] = obj.SaveOnDisk(now,'AutomaticSave');
                        end
                    end
                end
                
            end
            
        end
        
        function [SUCCESS,filename,TargetDir] = SaveOnDisk(obj,TimeNow,auxillaryData)
            %[SUCCESS,filename,TargetDir] = writeDataToDisk(app,TimeNow,CVObject,auxillaryData)
            CurrentTime=datevec(TimeNow);
            CurrentYearString=num2str(CurrentTime(1),'%.4d'); CurrentMonthString=num2str(CurrentTime(2),'%.2d');
            CurrentDayString=num2str(CurrentTime(3),'%.2d'); CurrentTempo1String=num2str(CurrentTime(4),'%.2d');
            CurrentTempo2String=num2str(CurrentTime(5),'%.2d'); CurrentTempo3String=num2str(floor(CurrentTime(6)),'%.2d');
            CurrentTempo4String=num2str(round((CurrentTime(6)-floor(CurrentTime(6)))*1000),'%.3d');
            CurrentTimeString=[CurrentYearString,'-',CurrentMonthString,'-',CurrentDayString,'--',CurrentTempo1String,'-',CurrentTempo2String,'-',CurrentTempo3String,'-',CurrentTempo4String];
            if(obj.Acquisition.Synchronous)
                synchstring='Synch';
            else
                synchstring='Asynch';
            end
            if(obj.Acquisition.BSA)
               BSAstring='BSA'; 
            else
               BSAstring='noBSA'; 
            end
            filename=['OnlineMonitor-','MainRecorder-',synchstring,'-',BSAstring,'-',CurrentTimeString];
            TargetDir=['/u1/lcls/matlab/data/',CurrentYearString,'/',CurrentYearString,'-',CurrentMonthString,'/',CurrentYearString,'-',CurrentMonthString,'-',CurrentDayString];
            if(~isfolder(TargetDir))
                mkdir(TargetDir);
            end
            DataStructure=obj.Acquisition; Data=obj.Recorder;
            try
                save([TargetDir,'/',filename],'Data','DataStructure','auxillaryData')
                SUCCESS=1;
                disp([filename,' saved on Disk']);
            catch
                SUCCESS=0;
            end
        end
        
        function ACQ_Cycle_NoSynchNoBSA(obj)
            obj.Recorder.AbsoluteCaptureID=obj.Recorder.AbsoluteCaptureID+1;
            if(obj.Acquisition.NumberOncePerCyclePVs)
                obj.Recorder.Data{2}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2),:)=lcaGetSmart(obj.Acquisition.OncePerCyclePVs);
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{2}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(2)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2);
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(2) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(2)+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)>obj.Recorder.AcquisitionNonTimeStampedBuffersize(2))
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(2)=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(2)+1;
                end
            end
            
            if(obj.Acquisition.DoScan)
                obj.Recorder.Data{obj.Acquisition.Scan.ScanDataPosition}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition),:)= obj.ScanSetting.Values(obj.ScanState.ScanPosition,:);
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{obj.Acquisition.Scan.ScanDataPosition}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition);
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.Scan.ScanDataPosition) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.Scan.ScanDataPosition)+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)>obj.Recorder.AcquisitionNonTimeStampedBuffersize(obj.Acquisition.Scan.ScanDataPosition))
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.Scan.ScanDataPosition)+1;
                end
            end
            
            for II=1:obj.Acquisition.NumberProfilesNonTS
                if(obj.Acquisition.ProfileNonTS_PVs(II).IsVector)
                    obj.Recorder.Data{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)),:) = lcaGetSmart(obj.Acquisition.ProfileNonTS_PVs(II).PVName,obj.Acquisition.ProfileNonTS_PVs(II).ReadSize);
                else
                    obj.Recorder.Data{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(:,:,obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))) = reshape(lcaGetSmart(obj.Acquisition.ProfileNonTS_PVs(II).PVName),obj.Acquisition.ProfileNonTS_PVs(II).ReshapeSize);
                end
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II));
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)) = obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))>obj.Recorder.AcquisitionNonTimeStampedBuffersize(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)))
                    %EXIT CONDITION HERE
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                end
            end
            
            for VL=1:obj.Acquisition.Blocksize
                for VCR=1:obj.Acquisition.NumberProfiles
                    [obj.Transient.ProfilePV{VCR}(obj.WriteInto,:),obj.Transient.Profile_TS(VCR,obj.WriteInto)]=lcaGetSmart(obj.Acquisition.ProfilePVs(VCR).PVName,obj.Acquisition.ProfilePVs(VCR).ReadSize);
                end
                if(obj.Acquisition.NumberSynchPVs)
                    [obj.Transient.SynchPV(:,obj.WriteInto),obj.Transient.SynchPV_TS(:,obj.WriteInto)]=lcaGetSmart(obj.Acquisition.SynchronousPVs);
                end
                
                for VCR=1:obj.Acquisition.NumberProfiles
                    obj.Transient.Profile_PID(VCR,obj.WriteInto)=bitand(uint32(imag(obj.Transient.Profile_TS(VCR,obj.WriteInto))),hex2dec('1FFFF'));
                    if(obj.Transient.Profile_TS(VCR,obj.WriteInto) ~= obj.Transient.Profile_TS(VCR,obj.CompareTo))
                        PositionWithinData=obj.Acquisition.ProfilePVs(VCR).AsynchOffsetStart;
                        %             while(any((PositionWithinData+1) == obj.Acquisition.NonTimeStampedProfilesPositionWithinData))
                        %                 PositionWithinData=PositionWithinData+1;
                        %             end
                        if(obj.Acquisition.ProfilePVs(VCR).PostProcessing)
                            POST_Proc_Data_asynch=obj.Acquisition.ProfilePVs(VCR).PostProcessingFunction(obj.Transient.ProfilePV{VCR},obj.Acquisition.ProfilePVs(VCR).PostProcessingOptions,obj.Acquisition.ProfilePVs(VCR),obj.Transient.Profile_TS(VCR,:),0);
                            if(obj.Acquisition.ProfilePVs(VCR).UseExternalTimeStamps)
                                obj.Transient.NewPidsUS=obj.Transient.Profile_PID(VCR,obj.WriteInto);
                            else
                                obj.Transient.NewPidsUS=POST_Proc_Data_asynch.PulseID;
                            end
                            if(obj.Acquisition.ProfilePVs(VCR).Options.NumberOfScalars)
                                PositionWithinData=PositionWithinData+1;
                                for HHH=1:length(obj.Transient.NewPidsUS)
                                    obj.Recorder.LastWrittenElement{PositionWithinData} = obj.Recorder.NextWrittenElement{PositionWithinData};
                                    obj.Recorder.AcquisitionWritingCycle{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Recorder.AbsoluteCaptureID;
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData},:) = POST_Proc_Data_asynch.Scalars(:,HHH).'; %Scalar data is in columns for some reason.
                                    obj.Recorder.PulseIds{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.LastWrittenPulseID{PositionWithinData}  = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.EventsAbsoluteCounter{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData})  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData} +1;
                                    obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}+1;
                                    obj.Recorder.NextWrittenElement{PositionWithinData}=obj.Recorder.NextWrittenElement{PositionWithinData}+1;
                                    if(obj.Recorder.NextWrittenElement{PositionWithinData}>obj.Acquisition.VarBuffersize(PositionWithinData))
                                        %EXIT CONDITION HERE
                                        obj.Recorder.NextWrittenElement{PositionWithinData}=1;
                                        obj.Recorder.TimesBufferFilled{PositionWithinData}=obj.Recorder.TimesBufferFilled{PositionWithinData}+1;
                                    end
                                end
                            end
                            for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfVectors
                                PositionWithinData=PositionWithinData+1;
                                for HHH=1:length(obj.Transient.NewPidsUS)
                                    obj.Recorder.AcquisitionWritingCycle{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Recorder.AbsoluteCaptureID;
                                    obj.Recorder.LastWrittenElement{PositionWithinData} = obj.Recorder.NextWrittenElement{PositionWithinData};
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData},:) = POST_Proc_Data_asynch.Vectors{NOI}(HHH,:);
                                    obj.Recorder.PulseIds{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.LastWrittenPulseID{PositionWithinData}  = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.EventsAbsoluteCounter{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData})  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData} +1;
                                    obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}+1;
                                    obj.Recorder.NextWrittenElement{PositionWithinData}=obj.Recorder.NextWrittenElement{PositionWithinData}+1;
                                    if(obj.Recorder.NextWrittenElement{PositionWithinData}>obj.Acquisition.VarBuffersize(PositionWithinData))
                                        %EXIT CONDITION HERE
                                        obj.Recorder.NextWrittenElement{PositionWithinData}=1;
                                        obj.Recorder.TimesBufferFilled{PositionWithinData}=obj.Recorder.TimesBufferFilled{PositionWithinData}+1;
                                    end
                                end
                            end
                            for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfArray2D
                                PositionWithinData=PositionWithinData+1;
                                for HHH=1:length(obj.Transient.NewPidsUS)
                                    obj.Recorder.AcquisitionWritingCycle{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Recorder.AbsoluteCaptureID;
                                    obj.Recorder.LastWrittenElement{PositionWithinData} = obj.Recorder.NextWrittenElement{PositionWithinData};
                                    obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.NextWrittenElement{PositionWithinData}) = POST_Proc_Data_asynch.Array2D{NOI}(:,:,HHH);
                                    obj.Recorder.PulseIds{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.LastWrittenPulseID{PositionWithinData}  = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.EventsAbsoluteCounter{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData})  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData} +1;
                                    obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}+1;
                                    obj.Recorder.NextWrittenElement{PositionWithinData}=obj.Recorder.NextWrittenElement{PositionWithinData}+1;
                                    if(obj.Recorder.NextWrittenElement{PositionWithinData}>obj.Acquisition.VarBuffersize(PositionWithinData))
                                        obj.Recorder.NextWrittenElement{PositionWithinData}=1;
                                        obj.Recorder.TimesBufferFilled{PositionWithinData}=obj.Recorder.TimesBufferFilled{PositionWithinData}+1;
                                        %CHECK EXIT CONDITION HERE
                                    end
                                end
                            end
                        else
                            PositionWithinData=PositionWithinData+1;
                            obj.Recorder.AcquisitionWritingCycle{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Recorder.AbsoluteCaptureID;
                            obj.Recorder.LastWrittenElement{PositionWithinData} = obj.Recorder.NextWrittenElement{PositionWithinData};
                            if(obj.Acquisition.ProfilePVs(VCR).IsVector)
                                if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData},:) = obj.Transient.ProfilePV{VCR}(obj.WriteInto,:);
                                else
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData},:) = obj.Transient.ProfilePV{VCR}(obj.WriteInto,:) - obj.Acquisition.ProfilePVs(VCR).Background;
                                end
                            else
                                if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                    obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.NextWrittenElement{PositionWithinData}) = reshape(obj.Transient.ProfilePV{VCR}(obj.WriteInto,:),obj.Acquisition.ProfilePVs(VCR).ReshapeSize);
                                else
                                    obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.NextWrittenElement{PositionWithinData}) = reshape(obj.Transient.ProfilePV{VCR}(obj.WriteInto,:),obj.Acquisition.ProfilePVs(VCR).ReshapeSize) - obj.Acquisition.ProfilePVs(VCR).Background;
                                end
                            end
                            obj.Recorder.TimeStamps{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.Profile_TS(VCR,obj.WriteInto);
                            obj.Recorder.PulseIds{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.Profile_PID(VCR,obj.WriteInto);
                            obj.Recorder.LastWrittenPulseID{PositionWithinData}  = obj.Transient.Profile_PID(VCR,obj.WriteInto);
                            obj.Recorder.EventsAbsoluteCounter{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData})  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData} +1;
                            obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}+1;
                            obj.Recorder.NextWrittenElement{PositionWithinData}=obj.Recorder.NextWrittenElement{PositionWithinData}+1;
                            if(obj.Recorder.NextWrittenElement{PositionWithinData}>obj.Acquisition.VarBuffersize(PositionWithinData))
                                obj.Recorder.NextWrittenElement{PositionWithinData}=1;
                                obj.Recorder.TimesBufferFilled{PositionWithinData}=obj.Recorder.TimesBufferFilled{PositionWithinData}+1;
                                if(obj.Acquisition.DumpAfterBufferFilled)
                                     [SUCCESS,filename,TargetDir] = obj.SaveOnDisk(now,'AutomaticSave');
                                end
                            end
                            if(VCR==1 && ~obj.Acquisition.NumberSynchPVs)
                                obj.Transient.NewPidsUS=obj.Transient.Profile_PID(VCR,obj.WriteInto);
                            end
                        end
                    end
                end
                if(obj.Acquisition.NumberSynchPVs)
                    obj.Transient.SynchPV_PID(:,obj.WriteInto)=bitand(uint32(imag(obj.Transient.SynchPV_TS(:,obj.WriteInto))),hex2dec('1FFFF'));
                    obj.Transient.NewPositions=find(obj.Transient.SynchPV_PID(:,obj.WriteInto)~=obj.Transient.SynchPV_PID(:,obj.CompareTo));
                    if(~isempty(obj.Transient.NewPositions))
                        for INP=1:length(obj.Transient.NewPositions)
                            obj.Recorder.AcquisitionWritingCycle{1}(obj.Recorder.NextWrittenElement{1}(obj.Transient.NewPositions(INP)),obj.Transient.NewPositions(INP)) = obj.Recorder.AbsoluteCaptureID;
                            obj.Recorder.LastWrittenElement{1}(obj.Transient.NewPositions(INP)) = obj.Recorder.NextWrittenElement{1}(obj.Transient.NewPositions(INP));
                            obj.Recorder.Data{1}(obj.Recorder.NextWrittenElement{1}(obj.Transient.NewPositions(INP)),obj.Transient.NewPositions(INP)) = obj.Transient.SynchPV(obj.Transient.NewPositions(INP),obj.WriteInto);
                            obj.Recorder.TimeStamps{1}(obj.Recorder.NextWrittenElement{1}(obj.Transient.NewPositions(INP)),obj.Transient.NewPositions(INP)) = obj.Transient.SynchPV_TS(obj.Transient.NewPositions(INP),obj.WriteInto);
                            obj.Recorder.PulseIds{1}(obj.Recorder.NextWrittenElement{1}(obj.Transient.NewPositions(INP)),obj.Transient.NewPositions(INP)) = obj.Transient.SynchPV_PID(obj.Transient.NewPositions(INP),obj.WriteInto);
                            obj.Recorder.LastWrittenPulseID{1}(obj.Transient.NewPositions(INP)) = obj.Transient.SynchPV_PID(obj.Transient.NewPositions(INP),obj.WriteInto);
                            obj.Recorder.EventsAbsoluteCounter{1}(obj.Recorder.NextWrittenElement{1}(obj.Transient.NewPositions(INP)),obj.Transient.NewPositions(INP))  = obj.Recorder.MaxEventsAbsoluteCounter{1}(obj.Transient.NewPositions(INP));
                            obj.Recorder.MaxEventsAbsoluteCounter{1}(obj.Transient.NewPositions(INP))  = obj.Recorder.MaxEventsAbsoluteCounter{1}(obj.Transient.NewPositions(INP))+1;
                            obj.Recorder.NextWrittenElement{1}(obj.Transient.NewPositions(INP))=obj.Recorder.NextWrittenElement{1}(obj.Transient.NewPositions(INP))+1;
                            if(obj.Recorder.NextWrittenElement{1}(obj.Transient.NewPositions(INP))>obj.Acquisition.VarBuffersize(1))
                                obj.Recorder.NextWrittenElement{1}(obj.Transient.NewPositions(INP))=1;
                                obj.Recorder.TimesBufferFilled{1}(obj.Transient.NewPositions(INP))=obj.Recorder.TimesBufferFilled{1}(obj.Transient.NewPositions(INP))+1;
                                %CHECK EXIT CONDITION HERE
                            end
                        end
                    end
                end
                
                if(obj.WriteInto==2)
                    obj.WriteInto=1;
                    obj.CompareTo=2;
                else
                    obj.WriteInto=2;
                    obj.CompareTo=1;
                end
            end
        end
        
        function ACQ_Cycle_BSA_2B(obj)
            switch(obj.Acquisition.BSA_Vars.Phase_Cycle)
                case 0
                    if(obj.Acquisition.BSA_Vars.Just_Started)
                        eDefOn(obj.myeDefNumber(1))
                    end
                case 1
                case 2
                case 3
            end
            tic,obj.Acquisition.BSA_Vars.current_time=toc;
            
            while(obj.Acquisition.BSA_Vars.current_time < obj.Acquisition.TimeCycle) %just get profile monitor while you can
                if(obj.Acquisition.NumberProfiles)
                    obj.Acquisition.BSA_Vars.ReadCueValid=obj.Acquisition.BSA_Vars.ReadCueValid+1;
                    for VCR=1:obj.Acquisition.NumberProfiles
                        [obj.Transient.ProfilePV{VCR}(obj.Acquisition.BSA_Vars.ReadCueValid,:),obj.Transient.Profile_TS(VCR,obj.Acquisition.BSA_Vars.ReadCueValid)]=lcaGetSmart(obj.Acquisition.ProfilePVs(VCR).PVName,obj.Acquisition.ProfilePVs(VCR).ReadSize);
                    end
                else
                    pause(0.05);
                end
                obj.Acquisition.BSA_Vars.current_time=toc;
            end
            
            switch(obj.Acquisition.BSA_Vars.Phase_Cycle)
                case 0
                    if(obj.Acquisition.BSA_Vars.Just_Started)
                        eDefOn(obj.myeDefNumber(2))
                    end
                    obj.Acquisition.BSA_Vars.GrabTurn=0;
                case 1
                    eDefOff(obj.myeDefNumber(1)), pause(1/(120*10));
                    if(obj.uselcaGetSmart)
                        obj.Transient.the_matrix1 = lcaGetSmart(obj.my_names{1},2800);
                    else
                        obj.Transient.the_matrix1 = lcaGet(obj.my_names{1});
                    end
                    eDefOn(obj.myeDefNumber(1))
                    if(obj.Acquisition.BSA_Vars.Just_Started)
                        obj.Transient.the_matrix2=obj.Transient.the_matrix1;
                        obj.Acquisition.BSA_Vars.Just_Started=0;
                    end
                    obj.Acquisition.BSA_Vars.GrabTurn=1;
                case 2
                    if(obj.Acquisition.BSA_Vars.Just_Started)
                        eDefOn(obj.myeDefNumber(1));
                    end
                    obj.Acquisition.BSA_Vars.GrabTurn=0;
                case 3
                    eDefOff(obj.myeDefNumber(2)), pause(1/(120*10));
                    if(obj.uselcaGetSmart)
                        obj.Transient.the_matrix2 = lcaGetSmart(obj.my_names{2},2800);
                    else
                        obj.Transient.the_matrix2 = lcaGet(obj.my_names{2});
                    end
                    eDefOn(obj.myeDefNumber(2))
                    obj.Acquisition.BSA_Vars.GrabTurn=1;
            end
            obj.Acquisition.BSA_Vars.Phase_Cycle=mod((obj.Acquisition.BSA_Vars.Phase_Cycle+1),4);
            
            if(obj.Acquisition.BSA_Vars.GrabTurn) %re-order ONLY THE BSA, first step
                
                obj.Recorder.AbsoluteCaptureID=obj.Recorder.AbsoluteCaptureID+1;
                if(obj.Acquisition.NumberOncePerCyclePVs)
                    obj.Recorder.Data{2}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2),:)=lcaGetSmart(obj.Acquisition.OncePerCyclePVs);
                    obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{2}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2))=obj.Recorder.AbsoluteCaptureID;
                    obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(2)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2);
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)+1;
                    obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(2) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(2)+1;
                    if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)>obj.Recorder.AcquisitionNonTimeStampedBuffersize(2))
                        obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)=1;
                        obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(2)=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(2)+1;
                    end
                end
                
                if(obj.Acquisition.DoScan)
                    obj.Recorder.Data{obj.Acquisition.Scan.ScanDataPosition}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition),:)= obj.ScanSetting.Values(obj.ScanState.ScanPosition,:);
                    obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{obj.Acquisition.Scan.ScanDataPosition}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition))=obj.Recorder.AbsoluteCaptureID;
                    obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition);
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)+1;
                    obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.Scan.ScanDataPosition) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.Scan.ScanDataPosition)+1;
                    if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)>obj.Recorder.AcquisitionNonTimeStampedBuffersize(obj.Acquisition.Scan.ScanDataPosition))
                        obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=1;
                        obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.Scan.ScanDataPosition)+1;
                    end
                end
                
                for II=1:obj.Acquisition.NumberProfilesNonTS
                    if(obj.Acquisition.ProfileNonTS_PVs(II).IsVector)
                        obj.Recorder.Data{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)),:) = lcaGetSmart(obj.Acquisition.ProfileNonTS_PVs(II).PVName);
                    else
                        obj.Recorder.Data{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(:,:,obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))) = reshape(lcaGetSmart(obj.Acquisition.ProfileNonTS_PVs(II).PVName),obj.Acquisition.ProfileNonTS_PVs(II).ReshapeSize);
                    end
                    obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)))=obj.Recorder.AbsoluteCaptureID;
                    obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II));
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)) = obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                    obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                    if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))>obj.Recorder.AcquisitionNonTimeStampedBuffersize(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)))
                        obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=1;
                        obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                    end
                end
                
%                 max(double(obj.Transient.the_matrix1(end-1,:)))
%                 max(double(obj.Transient.the_matrix2(end-1,:)))
                obj.Transient.the_matrix1 = obj.Transient.the_matrix1(:,(double(obj.Transient.the_matrix1(end-1,:)) + double(obj.Transient.the_matrix1(end,:))/10^9 + 631152000 > obj.Recorder.LastValidTime ));
                obj.Transient.the_matrix2 = obj.Transient.the_matrix2(:,(double(obj.Transient.the_matrix2(end-1,:)) + double(obj.Transient.the_matrix2(end,:))/10^9 + 631152000 > obj.Recorder.LastValidTime ));
                
                if(~isempty(obj.Transient.the_matrix1) || ~isempty(obj.Transient.the_matrix2))
                    if(obj.Acquisition.BSA_Vars.Phase_Cycle==0)
                        [~,LocBuf2,LocBuf1]=union(obj.Transient.the_matrix2(end-2,:),obj.Transient.the_matrix1(end-2,:),'stable');
                        AllBufferPIDs=[obj.Transient.the_matrix2(end-2,LocBuf2),obj.Transient.the_matrix1(end-2,LocBuf1)];
                        TimeStampsInBSAUnits = [double(obj.Transient.the_matrix2(end-1,LocBuf2)) + double(obj.Transient.the_matrix2(end,LocBuf2))/10^9 , double(obj.Transient.the_matrix1(end-1,LocBuf1)) + double(obj.Transient.the_matrix1(end,LocBuf1))/10^9];
                        ComplexTimeStamps = [obj.Transient.the_matrix2(end-1,LocBuf2) + 1i*obj.Transient.the_matrix2(end,LocBuf2) + 631152000 , obj.Transient.the_matrix1(end-1,LocBuf1) + 1i*obj.Transient.the_matrix1(end,LocBuf1) + 631152000];
                        FullTempMatrix=[obj.Transient.the_matrix2((1:(end-3)),LocBuf2),obj.Transient.the_matrix1((1:(end-3)),LocBuf1)];
                        [SortedTimeStampsTemporary, SortedTimeStampsTemporaryOrder ]= sort(TimeStampsInBSAUnits);
                    else
                        [~,LocBuf1,LocBuf2]=union(obj.Transient.the_matrix1(end-2,:),obj.Transient.the_matrix2(end-2,:),'stable');
                        AllBufferPIDs=[obj.Transient.the_matrix1(end-2,LocBuf1),obj.Transient.the_matrix2(end-2,LocBuf2)];
                        TimeStampsInBSAUnits = [double(obj.Transient.the_matrix1(end-1,LocBuf1)) + double(obj.Transient.the_matrix1(end,LocBuf1))/10^9 , double(obj.Transient.the_matrix2(end-1,LocBuf2)) + double(obj.Transient.the_matrix2(end,LocBuf2))/10^9];
                        ComplexTimeStamps = [obj.Transient.the_matrix1(end-1,LocBuf1) + 1i*obj.Transient.the_matrix1(end,LocBuf1) + 631152000 , obj.Transient.the_matrix2(end-1,LocBuf2) + 1i*obj.Transient.the_matrix2(end,LocBuf2) + 631152000];
                        FullTempMatrix=[obj.Transient.the_matrix1((1:(end-3)),LocBuf1),obj.Transient.the_matrix2((1:(end-3)),LocBuf2)];
                        [SortedTimeStampsTemporary, SortedTimeStampsTemporaryOrder ]= sort(TimeStampsInBSAUnits);
                    end
                    
                    obj.LastValidCueElement=obj.Acquisition.BSA_Vars.ReadCueValid;
                    obj.Acquisition.BSA_Vars.ReadCueValid=0;
                    if(length(SortedTimeStampsTemporary) > obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data)
                        obj.Recorder.LastValidTime=max(obj.Recorder.LastValidTime,max(631152000 + SortedTimeStampsTemporary(1:(end - obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data))));
                        obj.Transient.Valid_BSA_Data=FullTempMatrix(:,SortedTimeStampsTemporaryOrder(1:(end- obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data)));
                        obj.Transient.Valid_BSA_TS=ComplexTimeStamps(SortedTimeStampsTemporaryOrder(1:(end- obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data)));
                        obj.Transient.Valid_BSA_PID=double(AllBufferPIDs(SortedTimeStampsTemporaryOrder(1:(end- obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data))));
                        
                    else
                        obj.Transient.Valid_BSA_Data=[];
                        obj.Transient.Valid_BSA_PID=[];
                        obj.Transient.Valid_BSA_TS=[];
                    end
                end
            else
                obj.Transient.Valid_BSA_Data=[];
                obj.Transient.Valid_BSA_PID=[];
                obj.Transient.Valid_BSA_TS=[];
            end
        end
        
        function ACQ_Cycle_Synchronize_BSA(obj)
            for VCR=1:obj.Acquisition.NumberProfiles
                if(obj.Acquisition.ProfilePVs(VCR).PostProcessing)
                    POST_Proc_Data{VCR}=obj.Acquisition.ProfilePVs(VCR).PostProcessingFunction(obj.Transient.ProfilePV{VCR},obj.Acquisition.ProfilePVs(VCR).PostProcessingOptions,obj.Acquisition.ProfilePVs(VCR),obj.Transient.Profile_TS(VCR,:),0);%<OK>
                    if(obj.Acquisition.ProfilePVs(VCR).UseExternalTimeStamps)
                        POST_Proc_Data{VCR}.PulseID=bitand(uint32(imag(POST_Proc_Data{VCR}.TimeStamps)),hex2dec('1FFFF')) + obj.Acquisition.ProfilePVs(VCR).PID_Delay;
                    end
                end
            end
            
            %Now Synchronize, you have all the timestamps, use them!
            if(isempty(obj.Transient.Valid_BSA_PID)) % if no data... then nothing.
                obj.Recorder.NewDataFoundLength=0;
            else
                if(obj.Acquisition.UseRejection)
                    for TT=1:numel(obj.Acquisition.Rejection) %If some rejection is required, just NaN the unwanted data in the pulse IDs.
                        obj.Transient.Valid_BSA_PID((obj.Transient.Valid_BSA_Data(obj.Acquisition.Rejection(TT).POS,:)< obj.Acquisition.Rejection(TT).LO) | (obj.Transient.Valid_BSA_Data(obj.Acquisition.Rejection(TT).POS,:)> obj.Acquisition.Rejection(TT).HI))=NaN;
                    end
                end
                PID=setdiff(obj.Transient.Valid_BSA_PID,obj.Recorder.LastWrittenPulseID,'stable');
                if(obj.Acquisition.NumberProfiles)
                    obj.Transient.Profile_PulseIDs= bitand(uint32(imag(obj.Transient.Profile_TS)),hex2dec('1FFFF'));
                    for VCR=1:numel(obj.Acquisition.ProfilePVs)
                        if(obj.Acquisition.ProfilePVs(VCR).PostProcessing) %then it must have calculated PulseIDs earlier...
                            PID=intersect(PID, POST_Proc_Data{VCR}.PulseID,'stable');
                        else %need to calculate pulse ID here and add pulse ID delay obj.Transient.Profile_TS(VCR,VL)
                            PID=intersect(PID, obj.Transient.Profile_PulseIDs(VCR,:) + obj.Acquisition.ProfilePVs(VCR).PID_Delay,'stable');
                        end
                    end
                end
                if(obj.Acquisition.UseRejection)
                    PID(isnan(PID))=[];
                end
                obj.Recorder.NewDataFoundLength=length(PID);
                DealWithStoringInTwoSteps=0; ActualSplit=0;
                
                if(obj.Recorder.NewDataFoundLength)
                    obj.Recorder.LastWrittenPulseID = PID(end);
                    if(obj.Recorder.NewDataFoundLength>(1+obj.Acquisition.Buffersize-obj.Recorder.NextWrittenElement)) %goes over the buffer size
                        obj.Recorder.LastWrittenElement=obj.Recorder.NewDataFoundLength-obj.Acquisition.Buffersize+obj.Recorder.NextWrittenElement-1;
                        obj.Recorder.Destination=[obj.Recorder.NextWrittenElement:obj.Acquisition.Buffersize,1:obj.Recorder.LastWrittenElement];
                        obj.Recorder.TimesBufferFilled=obj.Recorder.TimesBufferFilled+1;
                        if(obj.Recorder.NextWrittenElement > obj.Acquisition.Buffersize)
                            obj.Recorder.NextWrittenElement=1;
                        end
                        if(obj.Acquisition.CheckForBufferCompleted)
                            DealWithStoringInTwoSteps=1;
                            ActualSplit=1;
                            Destinations{1}=obj.Recorder.NextWrittenElement:obj.Acquisition.Buffersize;
                            Destinations{2}=1:obj.Recorder.LastWrittenElement;
                            PIDS{1}=PID(1:length(Destinations{1}));
                            PIDS{2}=PID((length(Destinations{1})+1):end);
                        end
                        obj.Recorder.NextWrittenElement=obj.Recorder.LastWrittenElement+1;
                    else%does not go over buffer size.
                        obj.Recorder.LastWrittenElement=obj.Recorder.NextWrittenElement+obj.Recorder.NewDataFoundLength-1;
                        obj.Recorder.Destination=obj.Recorder.NextWrittenElement:obj.Recorder.LastWrittenElement;
                        obj.Recorder.NextWrittenElement=obj.Recorder.LastWrittenElement+1;
                        if(obj.Recorder.NextWrittenElement > obj.Acquisition.Buffersize)
                            if(obj.Acquisition.CheckForBufferCompleted)
                                DealWithStoringInTwoSteps=1;
                            end
                            obj.Recorder.NextWrittenElement=1;
                            obj.Recorder.TimesBufferFilled=obj.Recorder.TimesBufferFilled+1;
                        end
                    end
                    obj.Recorder.EventsAbsoluteCounter(obj.Recorder.Destination) = obj.Recorder.MaxEventsAbsoluteCounter + (1:obj.Recorder.NewDataFoundLength);
                    obj.Recorder.MaxEventsAbsoluteCounter = obj.Recorder.MaxEventsAbsoluteCounter + obj.Recorder.NewDataFoundLength;
                else
                    %No data has been found.
                    return
                end
                
                if(~ActualSplit)
                    PositionWithinData=3;
                    obj.Recorder.AcquisitionWritingCycle(obj.Recorder.Destination)=obj.Recorder.AbsoluteCaptureID;
                    if(obj.Recorder.NewDataFoundLength) %Fill buffers if any new data has been found.
                        [~,~,DOVE]=intersect(PID, obj.Transient.Valid_BSA_PID,'stable');
                        obj.Recorder.Data{1}(obj.Recorder.Destination,:) = obj.Transient.Valid_BSA_Data(:,DOVE).';
                        obj.Recorder.TimeStamps(obj.Recorder.Destination)= obj.Transient.Valid_BSA_TS(1,DOVE);
                        obj.Recorder.PulseIds(obj.Recorder.Destination)= obj.Transient.Valid_BSA_PID(1,DOVE);
                        
                        for VCR=1:obj.Acquisition.NumberProfiles
                            while(any((PositionWithinData+1) == obj.Acquisition.NonTimeStampedProfilesPositionWithinData))
                                PositionWithinData=PositionWithinData+1;
                            end
                            if(obj.Acquisition.ProfilePVs(VCR).PostProcessing) %then it must have calculated PulseIDs earlier...
                                [~,~,DOVE]=intersect(PID, POST_Proc_Data{VCR}.PulseID,'stable'); %those are the same for all the data recorded.
                                if(obj.Acquisition.ProfilePVs(VCR).Options.NumberOfScalars)
                                    PositionWithinData=PositionWithinData+1;
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = POST_Proc_Data{VCR}.Scalars(:,DOVE).'; %Scalar data is in columns for some reason.
                                end
                                for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfVectors
                                    PositionWithinData=PositionWithinData+1;
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = POST_Proc_Data{VCR}.Vectors{NOI}(DOVE,:);
                                end
                                for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfArray2D
                                    PositionWithinData=PositionWithinData+1;
                                    obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = POST_Proc_Data{VCR}.Array2D{NOI}(:,:,DOVE);
                                end
                            else %need to calculate pulse ID here and add pulse ID delay
                                [~,~,DOVE]=intersect(PID, obj.Transient.Profile_PulseIDs(VCR,:) + obj.Acquisition.ProfilePVs(VCR).PID_Delay,'stable');
                                PositionWithinData=PositionWithinData+1;
                                if(obj.Acquisition.ProfilePVs(VCR).IsVector)
                                    if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                        obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = obj.Transient.ProfilePV{VCR}(DOVE,:);
                                    else
                                        obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = obj.Transient.ProfilePV{VCR}(DOVE,:) - ones(obj.Recorder.NewDataFoundLength,1)*obj.Acquisition.ProfilePVs(VCR).Background;
                                    end
                                else
                                    if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                        obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = permute(reshape(obj.Transient.ProfilePV{VCR}(DOVE,:),[obj.Recorder.NewDataFoundLength,obj.Acquisition.ProfilePVs(VCR).ReshapeSize]),[2,3,1]);
                                    else
                                        obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = -repmat(obj.Acquisition.ProfilePVs(VCR).Background,obj.Recorder.NewDataFoundLength) + permute(reshape(obj.Transient.ProfilePV{VCR}(DOVE,:),[obj.Recorder.NewDataFoundLength,obj.Acquisition.ProfilePVs(VCR).ReshapeSize]),[2,3,1]);
                                    end
                                end
                            end
                        end
                    end %end of if(obj.Recorder.NewDataFoundLength) %Fill buffers if any new data has been found.
                    if(DealWithStoringInTwoSteps)
                        if(obj.Acquisition.StopAfterBufferFilled)
                            obj.Acquisition.ExitConditionMet=1;
                        end
                        if(obj.Acquisition.DumpAfterBufferFilled)
                             [SUCCESS,filename,TargetDir] = obj.SaveOnDisk(now,'AutomaticSave');
                        end
                    end
                else %There is an actual split.
                    if(obj.Acquisition.StopAfterBufferFilled), GroupToInsert=1; obj.Acquisition.ExitConditionMet=1; else, GroupToInsert=2; end
                    for ZZ=1:GroupToInsert
                        PID=PIDS{ZZ};
                        obj.Recorder.Destination=Destinations{ZZ};
                        PositionWithinData=3;
                        obj.Recorder.AcquisitionWritingCycle(obj.Recorder.Destination)=obj.Recorder.AbsoluteCaptureID;
                        if(obj.Recorder.NewDataFoundLength) %Fill buffers if any new data has been found.
                            [~,~,DOVE]=intersect(PID, obj.Transient.Valid_BSA_PID,'stable');
                            obj.Recorder.Data{1}(obj.Recorder.Destination,:) = obj.Transient.Valid_BSA_Data(:,DOVE).';
                            obj.Recorder.TimeStamps(obj.Recorder.Destination)= obj.Transient.Valid_BSA_TS(1,DOVE);
                            obj.Recorder.PulseIds(obj.Recorder.Destination)= obj.Transient.Valid_BSA_PID(1,DOVE);
                            
                            for VCR=1:obj.Acquisition.NumberProfiles
                                while(any((PositionWithinData+1) == obj.Acquisition.NonTimeStampedProfilesPositionWithinData))
                                    PositionWithinData=PositionWithinData+1;
                                end
                                if(obj.Acquisition.ProfilePVs(VCR).PostProcessing) %then it must have calculated PulseIDs earlier...
                                    [~,~,DOVE]=intersect(PID, POST_Proc_Data{VCR}.PulseID,'stable'); %those are the same for all the data recorded.
                                    if(obj.Acquisition.ProfilePVs(VCR).Options.NumberOfScalars)
                                        PositionWithinData=PositionWithinData+1;
                                        obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = POST_Proc_Data{VCR}.Scalars(:,DOVE).'; %Scalar data is in columns for some reason.
                                    end
                                    for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfVectors
                                        PositionWithinData=PositionWithinData+1;
                                        obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = POST_Proc_Data{VCR}.Vectors{NOI}(DOVE,:);
                                    end
                                    for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfArray2D
                                        PositionWithinData=PositionWithinData+1;
                                        obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = POST_Proc_Data{VCR}.Array2D{NOI}(:,:,DOVE);
                                    end
                                else %need to calculate pulse ID here and add pulse ID delay
                                    [~,~,DOVE]=intersect(PID, obj.Transient.Profile_PulseIDs(VCR,:) + obj.Acquisition.ProfilePVs(VCR).PID_Delay,'stable');
                                    PositionWithinData=PositionWithinData+1;
                                    if(obj.Acquisition.ProfilePVs(VCR).IsVector)
                                        if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                            obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = obj.Transient.ProfilePV{VCR}(DOVE,:);
                                        else
                                            obj.Recorder.Data{PositionWithinData}(obj.Recorder.Destination,:) = obj.Transient.ProfilePV{VCR}(DOVE,:) - ones(obj.Recorder.NewDataFoundLength,1)*obj.Acquisition.ProfilePVs(VCR).Background;
                                        end
                                    else
                                        if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                            obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = permute(reshape(obj.Transient.ProfilePV{VCR}(DOVE,:),[obj.Recorder.NewDataFoundLength,obj.Acquisition.ProfilePVs(VCR).ReshapeSize]),[2,3,1]);
                                        else
                                            obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.Destination) = -repmat(obj.Acquisition.ProfilePVs(VCR).Background,obj.Recorder.NewDataFoundLength) + permute(reshape(obj.Transient.ProfilePV{VCR}(DOVE,:),[obj.Recorder.NewDataFoundLength,obj.Acquisition.ProfilePVs(VCR).ReshapeSize]),[2,3,1]);
                                        end
                                    end
                                end
                            end
                        end %end of if(obj.Recorder.NewDataFoundLength) %Fill buffers if any new data has been found.
                        if(ZZ==1)
                            if(obj.Acquisition.DumpAfterBufferFilled) %SALVA SOLO SE E' RELEVANT VARIABLE, ALTRIMENTI NO
                               [SUCCESS,filename,TargetDir] = obj.SaveOnDisk(now,'AutomaticSave');
                            end
                        end
                    end
                end
            end
        end
        
        function ACQ_Cycle_Asynchronous_BSA_2B(obj)
            switch(obj.Acquisition.BSA_Vars.Phase_Cycle)
                case 0
                    if(obj.Acquisition.BSA_Vars.Just_Started)
                        eDefOn(obj.myeDefNumber(1))
                    end
                case 1
                case 2
                case 3
            end
            tic,obj.Acquisition.BSA_Vars.current_time=toc;
            
            if(obj.Acquisition.BSA_Vars.Phase_Cycle==1 || obj.Acquisition.BSA_Vars.Phase_Cycle==3)
                obj.Recorder.AbsoluteCaptureID=obj.Recorder.AbsoluteCaptureID+1;
            end
            
            if(obj.Acquisition.NumberOncePerCyclePVs)
                obj.Recorder.Data{2}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2),:)=lcaGetSmart(obj.Acquisition.OncePerCyclePVs);
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{2}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(2)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2);
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(2) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(2)+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)>obj.Recorder.AcquisitionNonTimeStampedBuffersize(2))
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(2)=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(2)+1;
                end
            end
            
            if(obj.Acquisition.DoScan)
                obj.Recorder.Data{obj.Acquisition.Scan.ScanDataPosition}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition),:)= obj.ScanSetting.Values(obj.ScanState.ScanPosition,:);
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{obj.Acquisition.Scan.ScanDataPosition}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition);
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.Scan.ScanDataPosition) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.Scan.ScanDataPosition)+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)>obj.Recorder.AcquisitionNonTimeStampedBuffersize(obj.Acquisition.Scan.ScanDataPosition))
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.Scan.ScanDataPosition)+1;
                end
            end
            
            for II=1:obj.Acquisition.NumberProfilesNonTS
                if(obj.Acquisition.ProfileNonTS_PVs(II).IsVector)
                    obj.Recorder.Data{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)),:) = lcaGetSmart(obj.Acquisition.ProfileNonTS_PVs(II).PVName);
                else
                    obj.Recorder.Data{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(:,:,obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))) = reshape(lcaGetSmart(obj.Acquisition.ProfileNonTS_PVs(II).PVName),obj.Acquisition.ProfileNonTS_PVs(II).ReshapeSize);
                end
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II));
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)) = obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))>obj.Recorder.AcquisitionNonTimeStampedBuffersize(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)))
                    %EXIT CONDITION HERE ...
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                end
            end
            
            while(obj.Acquisition.BSA_Vars.current_time < obj.Acquisition.TimeCycle) %just get profile monitor while you can
                for VCR=1:obj.Acquisition.NumberProfiles
                    [obj.Transient.ProfilePV{VCR}(obj.WriteInto,:),obj.Transient.Profile_TS(VCR,obj.WriteInto)]=lcaGetSmart(obj.Acquisition.ProfilePVs(VCR).PVName,obj.Acquisition.ProfilePVs(VCR).ReadSize);
                end
                
                for VCR=1:obj.Acquisition.NumberProfiles
                    obj.Transient.Profile_PID(VCR,obj.WriteInto)=bitand(uint32(imag(obj.Transient.Profile_TS(VCR,obj.WriteInto))),hex2dec('1FFFF'));
                    if(obj.Transient.Profile_TS(VCR,obj.WriteInto) ~= obj.Transient.Profile_TS(VCR,obj.CompareTo))
                        PositionWithinData=obj.Acquisition.ProfilePVs(VCR).AsynchOffsetStart;
                        %             while(any((PositionWithinData+1) == obj.Acquisition.NonTimeStampedProfilesPositionWithinData))
                        %                 PositionWithinData=PositionWithinData+1;
                        %             end
                        if(obj.Acquisition.ProfilePVs(VCR).PostProcessing)
                            POST_Proc_Data_asynch=obj.Acquisition.ProfilePVs(VCR).PostProcessingFunction(obj.Transient.ProfilePV{VCR},obj.Acquisition.ProfilePVs(VCR).PostProcessingOptions,obj.Acquisition.ProfilePVs(VCR),obj.Transient.Profile_TS(VCR,:),0);
                            if(obj.Acquisition.ProfilePVs(VCR).UseExternalTimeStamps)
                                obj.Transient.NewPidsUS=obj.Transient.Profile_PID(VCR,obj.WriteInto);
                            else
                                obj.Transient.NewPidsUS=POST_Proc_Data_asynch.PulseID;
                            end
                            if(obj.Acquisition.ProfilePVs(VCR).Options.NumberOfScalars)
                                PositionWithinData=PositionWithinData+1;
                                for HHH=1:length(obj.Transient.NewPidsUS)
                                    obj.Recorder.LastWrittenElement{PositionWithinData} = obj.Recorder.NextWrittenElement{PositionWithinData};
                                    obj.Recorder.AcquisitionWritingCycle{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Recorder.AbsoluteCaptureID;
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData},:) = POST_Proc_Data_asynch.Scalars(:,HHH).'; %Scalar data is in columns for some reason.
                                    obj.Recorder.PulseIds{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.LastWrittenPulseID{PositionWithinData}  = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.EventsAbsoluteCounter{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData})  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData} +1;
                                    obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}+1;
                                    obj.Recorder.NextWrittenElement{PositionWithinData}=obj.Recorder.NextWrittenElement{PositionWithinData}+1;
                                    if(obj.Recorder.NextWrittenElement{PositionWithinData}>obj.Acquisition.VarBuffersize(PositionWithinData))
                                        obj.Recorder.NextWrittenElement{PositionWithinData}=1;
                                        obj.Recorder.TimesBufferFilled{PositionWithinData}=obj.Recorder.TimesBufferFilled{PositionWithinData}+1;
                                        %EXIT CONDITION HERE ...
                                    end
                                end
                            end
                            for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfVectors
                                PositionWithinData=PositionWithinData+1;
                                for HHH=1:length(obj.Transient.NewPidsUS)
                                    obj.Recorder.AcquisitionWritingCycle{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Recorder.AbsoluteCaptureID;
                                    obj.Recorder.LastWrittenElement{PositionWithinData} = obj.Recorder.NextWrittenElement{PositionWithinData};
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData},:) = POST_Proc_Data_asynch.Vectors{NOI}(HHH,:);
                                    obj.Recorder.PulseIds{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.LastWrittenPulseID{PositionWithinData}  = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.EventsAbsoluteCounter{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData})  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData} +1;
                                    obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}+1;
                                    obj.Recorder.NextWrittenElement{PositionWithinData}=obj.Recorder.NextWrittenElement{PositionWithinData}+1;
                                    if(obj.Recorder.NextWrittenElement{PositionWithinData}>obj.Acquisition.VarBuffersize(PositionWithinData))
                                        obj.Recorder.NextWrittenElement{PositionWithinData}=1;
                                        obj.Recorder.TimesBufferFilled{PositionWithinData}=obj.Recorder.TimesBufferFilled{PositionWithinData}+1;
                                        %EXIT CONDITION HERE ...
                                    end
                                end
                            end
                            for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfArray2D
                                PositionWithinData=PositionWithinData+1;
                                for HHH=1:length(obj.Transient.NewPidsUS)
                                    obj.Recorder.AcquisitionWritingCycle{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Recorder.AbsoluteCaptureID;
                                    obj.Recorder.LastWrittenElement{PositionWithinData} = obj.Recorder.NextWrittenElement{PositionWithinData};
                                    obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.NextWrittenElement{PositionWithinData}) = POST_Proc_Data_asynch.Array2D{NOI}(:,:,HHH);
                                    obj.Recorder.PulseIds{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.LastWrittenPulseID{PositionWithinData}  = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.EventsAbsoluteCounter{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData})  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData} +1;
                                    obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}+1;
                                    obj.Recorder.NextWrittenElement{PositionWithinData}=obj.Recorder.NextWrittenElement{PositionWithinData}+1;
                                    if(obj.Recorder.NextWrittenElement{PositionWithinData}>obj.Acquisition.VarBuffersize(PositionWithinData))
                                        obj.Recorder.NextWrittenElement{PositionWithinData}=1;
                                        obj.Recorder.TimesBufferFilled{PositionWithinData}=obj.Recorder.TimesBufferFilled{PositionWithinData}+1;
                                        %EXIT CONDITION HERE ...
                                    end
                                end
                            end
                        else %Write the new data, without calling post processing function.
                            %                 while(any((PositionWithinData+1) == obj.Acquisition.NonTimeStampedProfilesPositionWithinData))
                            %                     PositionWithinData=PositionWithinData+1;
                            %                 end
                            PositionWithinData=PositionWithinData+1;
                            obj.Recorder.AcquisitionWritingCycle{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Recorder.AbsoluteCaptureID;
                            obj.Recorder.LastWrittenElement{PositionWithinData} = obj.Recorder.NextWrittenElement{PositionWithinData};
                            if(obj.Acquisition.ProfilePVs(VCR).IsVector)
                                if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData},:) = obj.Transient.ProfilePV{VCR}(obj.WriteInto,:);
                                else
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData},:) = obj.Transient.ProfilePV{VCR}(obj.WriteInto,:) - obj.Acquisition.ProfilePVs(VCR).Background;
                                end
                            else
                                if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                    obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.NextWrittenElement{PositionWithinData}) = reshape(obj.Transient.ProfilePV{VCR}(obj.WriteInto,:),obj.Acquisition.ProfilePVs(VCR).ReshapeSize);
                                else
                                    obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.NextWrittenElement{PositionWithinData}) = reshape(obj.Transient.ProfilePV{VCR}(obj.WriteInto,:)- obj.Acquisition.ProfilePVs(VCR).Background,obj.Acquisition.ProfilePVs(VCR).ReshapeSize) ;
                                end
                            end
                            obj.Recorder.TimeStamps{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.Profile_TS(VCR,obj.WriteInto);
                            obj.Recorder.PulseIds{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.Profile_PID(VCR,obj.WriteInto);
                            obj.Recorder.LastWrittenPulseID{PositionWithinData}  = obj.Transient.Profile_PID(VCR,obj.WriteInto);
                            obj.Recorder.EventsAbsoluteCounter{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData})  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData} +1;
                            obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}+1;
                            obj.Recorder.NextWrittenElement{PositionWithinData}=obj.Recorder.NextWrittenElement{PositionWithinData}+1;
                            if(obj.Recorder.NextWrittenElement{PositionWithinData}>obj.Acquisition.VarBuffersize(PositionWithinData))
                                obj.Recorder.NextWrittenElement{PositionWithinData}=1;
                                obj.Recorder.TimesBufferFilled{PositionWithinData}=obj.Recorder.TimesBufferFilled{PositionWithinData}+1;
                                %EXIT CONDITION HERE ...
                            end
                            if(VCR==1 && ~obj.Acquisition.NumberSynchPVs)
                                obj.Transient.NewPidsUS=obj.Transient.Profile_PID(VCR,obj.WriteInto);
                            end
                        end
                    end
                end
                
                if(obj.WriteInto==2)
                    obj.WriteInto=1;
                    obj.CompareTo=2;
                else
                    obj.WriteInto=2;
                    obj.CompareTo=1;
                end
                obj.Acquisition.BSA_Vars.current_time=toc;
            end
            
            
            switch(obj.Acquisition.BSA_Vars.Phase_Cycle)
                case 0
                    if(obj.Acquisition.BSA_Vars.Just_Started)
                        eDefOn(obj.myeDefNumber(2))
                    end
                    obj.Acquisition.BSA_Vars.GrabTurn=0;
                case 1
                    eDefOff(obj.myeDefNumber(1)), pause(1/(120*10));
                    if(obj.uselcaGetSmart)
                        obj.Transient.the_matrix1 = lcaGetSmart(obj.my_names{1},2800);
                    else
                        obj.Transient.the_matrix1 = lcaGet(obj.my_names{1});
                    end    
                    eDefOn(obj.myeDefNumber(1));
                    if(obj.Acquisition.BSA_Vars.Just_Started)
                        obj.Transient.the_matrix2=obj.Transient.the_matrix1;
                        obj.Acquisition.BSA_Vars.Just_Started=0;
                    end
                    %eDefOn(obj.myeDefNumber(1));
                    obj.Acquisition.BSA_Vars.GrabTurn=1;
                case 2
                    if(obj.Acquisition.BSA_Vars.Just_Started)
                        eDefOn(obj.myeDefNumber(1));
                    end
                    obj.Acquisition.BSA_Vars.GrabTurn=0;
                case 3
                    eDefOff(obj.myeDefNumber(2)), pause(1/(120*10));
                    if(obj.uselcaGetSmart)
                        obj.Transient.the_matrix2 = lcaGetSmart(obj.my_names{2},2800);
                    else
                        obj.Transient.the_matrix2 = lcaGet(obj.my_names{2});
                    end
                    eDefOn(obj.myeDefNumber(2))
                    %     RemoveNaN=find(~isnan(pulseID_Buffer2_PID));
                    %     obj.Transient.the_matrix2=obj.Transient.the_matrix2(:,RemoveNaN);
                    %     pulseID_Buffer2_PID=pulseID_Buffer2_PID(RemoveNaN);
                    %     pulseID_Buffer2_s=pulseID_Buffer2_s(RemoveNaN);
                    %     pulseID_Buffer2_ns=pulseID_Buffer2_ns(RemoveNaN);
                    obj.Acquisition.BSA_Vars.GrabTurn=1;
            end
            
            obj.Acquisition.BSA_Vars.Phase_Cycle=mod((obj.Acquisition.BSA_Vars.Phase_Cycle+1),4);
            
            if(obj.Acquisition.BSA_Vars.GrabTurn) %re-order ONLY THE BSA, first step
                
                obj.Transient.the_matrix1 = obj.Transient.the_matrix1(:,(double(obj.Transient.the_matrix1(end-1,:)) + double(obj.Transient.the_matrix1(end,:))/10^9 + 631152000 > obj.Recorder.LastValidTime ));
                obj.Transient.the_matrix2 = obj.Transient.the_matrix2(:,(double(obj.Transient.the_matrix2(end-1,:)) + double(obj.Transient.the_matrix2(end,:))/10^9 + 631152000 > obj.Recorder.LastValidTime ));
                
                if(~isempty(obj.Transient.the_matrix1) || ~isempty(obj.Transient.the_matrix2))
                    [~,LocBuf1,LocBuf2]=union(obj.Transient.the_matrix1(end-2,:),obj.Transient.the_matrix2(end-2,:),'stable');
                    AllBufferPIDs=[obj.Transient.the_matrix1(end-2,LocBuf1),obj.Transient.the_matrix2(end-2,LocBuf2)];
                    TimeStampsInBSAUnits = [double(obj.Transient.the_matrix1(end-1,LocBuf1)) + double(obj.Transient.the_matrix1(end,LocBuf1))/10^9 , double(obj.Transient.the_matrix2(end-1,LocBuf2)) + double(obj.Transient.the_matrix2(end,LocBuf2))/10^9];
                    ComplexTimeStamps = [obj.Transient.the_matrix1(end-1,LocBuf1) + 1i*obj.Transient.the_matrix1(end,LocBuf1) + 631152000 , obj.Transient.the_matrix2(end-1,LocBuf2) + 1i*obj.Transient.the_matrix2(end,LocBuf2) + 631152000];
                    FullTempMatrix=[obj.Transient.the_matrix1((1:(end-3)),LocBuf1),obj.Transient.the_matrix2((1:(end-3)),LocBuf2)];
                    [SortedTimeStampsTemporary, SortedTimeStampsTemporaryOrder ]= sort(TimeStampsInBSAUnits);
                    obj.LastValidCueElement=obj.Acquisition.BSA_Vars.ReadCueValid;
                    obj.Acquisition.BSA_Vars.ReadCueValid=0;
                    if(length(SortedTimeStampsTemporary) > obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data)
                        obj.Recorder.LastValidTime=max(obj.Recorder.LastValidTime,max(631152000 + SortedTimeStampsTemporary(1:(end - obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data))));
                        obj.Transient.Valid_BSA_Data=FullTempMatrix(:,SortedTimeStampsTemporaryOrder(1:(end- obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data)));
                        obj.Transient.Valid_BSA_TS=ComplexTimeStamps(SortedTimeStampsTemporaryOrder(1:(end- obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data)));
                        obj.Transient.Valid_BSA_PID=double(AllBufferPIDs(SortedTimeStampsTemporaryOrder(1:(end- obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data))));
                        
                    else
                        obj.Transient.Valid_BSA_Data=[];
                        obj.Transient.Valid_BSA_PID=[];
                        obj.Transient.Valid_BSA_TS=[];
                    end
                    
                end
            else
                obj.Transient.Valid_BSA_Data=[];
                obj.Transient.Valid_BSA_PID=[];
                obj.Transient.Valid_BSA_TS=[];
            end
            
            if(isempty(obj.Transient.Valid_BSA_PID)) % if no data... then nothing.
                obj.Recorder.NewDataFoundLength=0;
            else
                if(obj.Acquisition.UseRejection)
                    for TT=1:numel(obj.Acquisition.Rejection) %If some rejection is required, just NaN the unwanted data in the pulse IDs.
                        obj.Transient.Valid_BSA_PID((obj.Transient.Valid_BSA_Data(obj.Acquisition.Rejection(TT).POS,:)< obj.Acquisition.Rejection(TT).LO) | (obj.Transient.Valid_BSA_Data(obj.Acquisition.Rejection(TT).POS,:)> obj.Acquisition.Rejection(TT).HI))=NaN;
                    end
                end
                PID=setdiff(obj.Transient.Valid_BSA_PID,obj.Recorder.LastWrittenPulseID{1},'stable');
                obj.Recorder.NewDataFoundLength=length(PID);
                
                if(obj.Recorder.NewDataFoundLength)
                    obj.Recorder.LastWrittenPulseID{1} = PID(end);
                    if(obj.Recorder.NewDataFoundLength>(1+obj.Acquisition.Buffersize-obj.Recorder.NextWrittenElement{1})) %goes over the buffer size
                        obj.Recorder.LastWrittenElement{1}=obj.Recorder.NewDataFoundLength-obj.Acquisition.Buffersize+obj.Recorder.NextWrittenElement{1}-1;
                        obj.Recorder.Destination=[obj.Recorder.NextWrittenElement{1}:obj.Acquisition.Buffersize,1:obj.Recorder.LastWrittenElement{1}];
                        obj.Recorder.TimesBufferFilled{1}=obj.Recorder.TimesBufferFilled{1}+1;
                        obj.Recorder.NextWrittenElement{1}=obj.Recorder.LastWrittenElement{1}+1;
                        %EXIT CONDITION
                        if(obj.Recorder.NextWrittenElement{1} > obj.Acquisition.Buffersize)
                            obj.Recorder.NextWrittenElement{1}=1;
                        end
                    else%does not go over buffer size.
                        obj.Recorder.LastWrittenElement{1}=obj.Recorder.NextWrittenElement{1}+obj.Recorder.NewDataFoundLength-1;
                        obj.Recorder.Destination=obj.Recorder.NextWrittenElement{1}:obj.Recorder.LastWrittenElement{1};
                        obj.Recorder.NextWrittenElement{1}=obj.Recorder.LastWrittenElement{1}+1;
                        if(obj.Recorder.NextWrittenElement{1} > obj.Acquisition.Buffersize)
                            obj.Recorder.NextWrittenElement{1}=1;
                            obj.Recorder.TimesBufferFilled{1}=obj.Recorder.TimesBufferFilled{1}+1;
                        end
                        %EXIT CONDITION
                    end
                    obj.Recorder.EventsAbsoluteCounter{1}(obj.Recorder.Destination) = obj.Recorder.MaxEventsAbsoluteCounter{1} + (1:obj.Recorder.NewDataFoundLength);
                    obj.Recorder.MaxEventsAbsoluteCounter{1} = obj.Recorder.MaxEventsAbsoluteCounter{1} + obj.Recorder.NewDataFoundLength;
                end
                
                if(obj.Recorder.NewDataFoundLength) %Fill buffers if any new data has been found.
                    [~,~,DOVE]=intersect(PID, obj.Transient.Valid_BSA_PID,'stable');
                    obj.Recorder.Data{1}(obj.Recorder.Destination,:) = obj.Transient.Valid_BSA_Data(:,DOVE).';
                    obj.Recorder.TimeStamps{1}(obj.Recorder.Destination)= obj.Transient.Valid_BSA_TS(1,DOVE);
                    obj.Recorder.PulseIds{1}(obj.Recorder.Destination)= obj.Transient.Valid_BSA_PID(1,DOVE);
                    obj.Recorder.AcquisitionWritingCycle{1}(obj.Recorder.Destination)=obj.Recorder.AbsoluteCaptureID;
                end
            end
        end
        
        function ACQ_Cycle_BSA_HB(obj)
            tic, obj.Acquisition.BSA_Vars.current_time=toc;
            %obj.Transient.UnSynchPV=lcaGetSmart(obj.Acquisition.OncePerCyclePVs);
            obj.Acquisition.BSA_Vars.ReadCueValid=0;
            
            while(obj.Acquisition.BSA_Vars.current_time < obj.Acquisition.TimeCycle) %just get profile monitor while you can
                if(obj.Acquisition.NumberProfiles)
                    obj.Acquisition.BSA_Vars.ReadCueValid=obj.Acquisition.BSA_Vars.ReadCueValid+1;
                    for VCR=1:obj.Acquisition.NumberProfiles
                        [obj.Transient.ProfilePV{VCR}(obj.Acquisition.BSA_Vars.ReadCueValid,:),obj.Transient.Profile_TS(VCR,obj.Acquisition.BSA_Vars.ReadCueValid)]=lcaGetSmart(obj.Acquisition.ProfilePVs(VCR).PVName,obj.Acquisition.ProfilePVs(VCR).ReadSize);
                    end
                    if(obj.Acquisition.BSA==3)
                        [obj.Transient.SynchPV(1,obj.Acquisition.BSA_Vars.ReadCueValid),obj.Transient.SynchPV_TS(1,obj.Acquisition.BSA_Vars.ReadCueValid)]=lcaGetSmart(obj.Acquisition.Mode4BSA_PV);
                    end
                else
                    pause(0.05);
                    obj.Acquisition.BSA_Vars.ReadCueValid=obj.Acquisition.BSA_Vars.ReadCueValid+1;
                    if(obj.Acquisition.BSA==3)
                        [obj.Transient.SynchPV(1,obj.Acquisition.BSA_Vars.ReadCueValid),obj.Transient.SynchPV_TS(1,obj.Acquisition.BSA_Vars.ReadCueValid)]=lcaGetSmart(obj.Acquisition.Mode4BSA_PV);
                    end
                end
                obj.Acquisition.BSA_Vars.current_time=toc;
            end
            
            [the_matrix,ComplexTimestamps] = lcaGetSyncHST(obj.Acquisition.SynchronousPVs);
            
            ActualTime=double(real(ComplexTimestamps)) + double(imag(ComplexTimestamps))/10^9;
            
            Valid_Positions=find(ActualTime>obj.Recorder.LastValidTime);
            
            obj.Recorder.AbsoluteCaptureID=obj.Recorder.AbsoluteCaptureID+1;
            if(obj.Acquisition.NumberOncePerCyclePVs)
                obj.Recorder.Data{2}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2),:)=lcaGetSmart(obj.Acquisition.OncePerCyclePVs);
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{2}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(2)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2);
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(2) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(2)+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)>obj.Recorder.AcquisitionNonTimeStampedBuffersize(2))
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(2)=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(2)+1;
                end
            end
            
            if(obj.Acquisition.DoScan)
                obj.Recorder.Data{obj.Acquisition.Scan.ScanDataPosition}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition),:)= obj.ScanSetting.Values(obj.ScanState.ScanPosition,:);
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{obj.Acquisition.Scan.ScanDataPosition}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition);
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.Scan.ScanDataPosition) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.Scan.ScanDataPosition)+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)>obj.Recorder.AcquisitionNonTimeStampedBuffersize(obj.Acquisition.Scan.ScanDataPosition))
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.Scan.ScanDataPosition)+1;
                end
            end
            
            for II=1:obj.Acquisition.NumberProfilesNonTS
                if(obj.Acquisition.ProfileNonTS_PVs(II).IsVector)
                    obj.Recorder.Data{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)),:) = lcaGetSmart(obj.Acquisition.ProfileNonTS_PVs(II).PVName);
                else
                    obj.Recorder.Data{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(:,:,obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))) = reshape(lcaGetSmart(obj.Acquisition.ProfileNonTS_PVs(II).PVName),obj.Acquisition.ProfileNonTS_PVs(II).ReshapeSize);
                end
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II));
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)) = obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))>obj.Recorder.AcquisitionNonTimeStampedBuffersize(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)))
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                end
            end
            
            if(obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data)
                Valid_Positions=Valid_Positions(1:(end-obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data));
                ActualTime(1:(end-obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data));
            end
            
            obj.LastValidCueElement=obj.Acquisition.BSA_Vars.ReadCueValid;
            
            if(~isempty(Valid_Positions))
                obj.Transient.Valid_BSA_Data=the_matrix(:,Valid_Positions);
                obj.Transient.Valid_BSA_TS=ComplexTimestamps(Valid_Positions);
                obj.Transient.Valid_BSA_PID= bitand(uint32(imag( obj.Transient.Valid_BSA_TS) ),hex2dec('1FFFF'));
                if(obj.Acquisition.BSA==3)
                    [~,DOVE1,DOVE2]=intersect(obj.Transient.SynchPV(1,1:obj.LastValidCueElement),obj.Transient.Valid_BSA_Data(1,:),'stable');
                    obj.Transient.SynchPV_PID=double(bitand(uint32(imag(obj.Transient.SynchPV_TS(1,DOVE1))),hex2dec('1FFFF')));
                    SHIFT=mode(double(obj.Transient.Valid_BSA_PID(DOVE2))-obj.Transient.SynchPV_PID);
                    obj.Transient.Valid_BSA_PID=obj.Transient.Valid_BSA_PID-SHIFT;
                else
                    obj.Transient.Valid_BSA_PID=double(obj.Transient.Valid_BSA_PID);
                end
                obj.Recorder.LastValidTime=max(obj.Recorder.LastValidTime,max(ActualTime));
            else
                obj.Transient.Valid_BSA_Data=[];
                obj.Transient.Valid_BSA_PID=[];
                obj.Transient.Valid_BSA_TS=[];
            end
        end
        
        function ACQ_Cycle_Asynchronous_BSA_HB(obj)
            tic,obj.Acquisition.BSA_Vars.current_time=toc;
            %obj.Transient.UnSynchPV=lcaGetSmart(obj.Acquisition.OncePerCyclePVs);
            
            obj.Recorder.AbsoluteCaptureID=obj.Recorder.AbsoluteCaptureID+1;
            if(obj.Acquisition.NumberOncePerCyclePVs)
                obj.Recorder.Data{2}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2),:)=lcaGetSmart(obj.Acquisition.OncePerCyclePVs);
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{2}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(2)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2);
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(2) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(2)+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)>obj.Recorder.AcquisitionNonTimeStampedBuffersize(2))
                    if(obj.Acquisition.AsynchronousVarCounter(1)==2)
                       %SAVE ON DISK 
                    end
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(2)=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(2)=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(2)+1;
                end
            end
            
            if(obj.Acquisition.DoScan)
                obj.Recorder.Data{obj.Acquisition.Scan.ScanDataPosition}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition),:)= obj.ScanSetting.Values(obj.ScanState.ScanPosition,:);
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{obj.Acquisition.Scan.ScanDataPosition}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition);
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.Scan.ScanDataPosition) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.Scan.ScanDataPosition)+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)>obj.Recorder.AcquisitionNonTimeStampedBuffersize(obj.Acquisition.Scan.ScanDataPosition))
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.Scan.ScanDataPosition)=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.Scan.ScanDataPosition)=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.Scan.ScanDataPosition)+1;
                end
            end
            
            for II=1:obj.Acquisition.NumberProfilesNonTS
                if(obj.Acquisition.ProfileNonTS_PVs(II).IsVector)
                    obj.Recorder.Data{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)),:) = lcaGetSmart(obj.Acquisition.ProfileNonTS_PVs(II).PVName);
                else
                    obj.Recorder.Data{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(:,:,obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))) = reshape(lcaGetSmart(obj.Acquisition.ProfileNonTS_PVs(II).PVName),obj.Acquisition.ProfileNonTS_PVs(II).ReshapeSize);
                end
                obj.Recorder.AcquisitionWritingCycle_NonTimeStamped{obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)}(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)))=obj.Recorder.AbsoluteCaptureID;
                obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II));
                obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)) = obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)) = obj.Recorder.AcquisitionNonTimeStampedMaxEventsAbsoluteCounter(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                if(obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))>obj.Recorder.AcquisitionNonTimeStampedBuffersize(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II)))
                    if(obj.Acquisition.AsynchronousVarCounter(1)==obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))
                       %SAVE ON DISK 
                    end
                    obj.Recorder.AcquisitionNonTimeStampedNextWrittenElement(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=1;
                    obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))=obj.Recorder.AcquisitionNonTimeStampedTimesBufferFilled(obj.Acquisition.NonTimeStampedProfilesPositionWithinData(II))+1;
                end
            end
            
            obj.Acquisition.BSA_Vars.ReadCueValid=0;
            while(obj.Acquisition.BSA_Vars.current_time < obj.Acquisition.TimeCycle) %just get profile monitor while you can
                for VCR=1:obj.Acquisition.NumberProfiles
                    [obj.Transient.ProfilePV{VCR}(obj.WriteInto,:),obj.Transient.Profile_TS(VCR,obj.WriteInto)]=lcaGetSmart(obj.Acquisition.ProfilePVs(VCR).PVName,obj.Acquisition.ProfilePVs(VCR).ReadSize);
                end
                if(obj.Acquisition.BSA==3)
                    obj.Acquisition.BSA_Vars.ReadCueValid=obj.Acquisition.BSA_Vars.ReadCueValid+1;
                    [obj.Transient.SynchPV(1,obj.Acquisition.BSA_Vars.ReadCueValid),obj.Transient.SynchPV_TS(1,obj.Acquisition.BSA_Vars.ReadCueValid)]=lcaGetSmart(obj.Acquisition.Mode4BSA_PV);
                end
                
                for VCR=1:obj.Acquisition.NumberProfiles
                    obj.Transient.Profile_PID(VCR,obj.WriteInto)=bitand(uint32(imag(obj.Transient.Profile_TS(VCR,obj.WriteInto))),hex2dec('1FFFF'));
                    if(obj.Transient.Profile_TS(VCR,obj.WriteInto) ~= obj.Transient.Profile_TS(VCR,obj.CompareTo))
                        PositionWithinData=obj.Acquisition.ProfilePVs(VCR).AsynchOffsetStart;
                        %             while(any((PositionWithinData+1) == obj.Acquisition.NonTimeStampedProfilesPositionWithinData))
                        %                 PositionWithinData=PositionWithinData+1;
                        %             end
                        if(obj.Acquisition.ProfilePVs(VCR).PostProcessing)
                            POST_Proc_Data_asynch=obj.Acquisition.ProfilePVs(VCR).PostProcessingFunction(obj.Transient.ProfilePV{VCR},obj.Acquisition.ProfilePVs(VCR).PostProcessingOptions,obj.Acquisition.ProfilePVs(VCR),obj.Transient.Profile_TS(VCR,:),0);
                            if(obj.Acquisition.ProfilePVs(VCR).UseExternalTimeStamps)
                                obj.Transient.NewPidsUS=obj.Transient.Profile_PID(VCR,obj.WriteInto);
                            else
                                obj.Transient.NewPidsUS=POST_Proc_Data_asynch.PulseID;
                            end
                            if(obj.Acquisition.ProfilePVs(VCR).Options.NumberOfScalars)
                                PositionWithinData=PositionWithinData+1;
                                for HHH=1:length(obj.Transient.NewPidsUS)
                                    obj.Recorder.LastWrittenElement{PositionWithinData} = obj.Recorder.NextWrittenElement{PositionWithinData};
                                    obj.Recorder.AcquisitionWritingCycle{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Recorder.AbsoluteCaptureID;
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData},:) = POST_Proc_Data_asynch.Scalars(:,HHH).'; %Scalar data is in columns for some reason.
                                    obj.Recorder.PulseIds{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.LastWrittenPulseID{PositionWithinData}  = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.EventsAbsoluteCounter{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData})  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData} +1;
                                    obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}+1;
                                    obj.Recorder.NextWrittenElement{PositionWithinData}=obj.Recorder.NextWrittenElement{PositionWithinData}+1;
                                    if(obj.Recorder.NextWrittenElement{PositionWithinData}>obj.Acquisition.VarBuffersize(PositionWithinData))
                                        if(obj.Acquisition.AsynchronousVarCounter(1)==PositionWithinData)
                                           %SAVE ON DISK 
                                        end
                                        obj.Recorder.NextWrittenElement{PositionWithinData}=1;
                                        obj.Recorder.TimesBufferFilled{PositionWithinData}=obj.Recorder.TimesBufferFilled{PositionWithinData}+1;
                                    end
                                end
                            end
                            for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfVectors
                                PositionWithinData=PositionWithinData+1;
                                for HHH=1:length(obj.Transient.NewPidsUS)
                                    obj.Recorder.AcquisitionWritingCycle{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Recorder.AbsoluteCaptureID;
                                    obj.Recorder.LastWrittenElement{PositionWithinData} = obj.Recorder.NextWrittenElement{PositionWithinData};
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData},:) = POST_Proc_Data_asynch.Vectors{NOI}(HHH,:);
                                    obj.Recorder.PulseIds{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.LastWrittenPulseID{PositionWithinData}  = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.EventsAbsoluteCounter{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData})  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData} +1;
                                    obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}+1;
                                    obj.Recorder.NextWrittenElement{PositionWithinData}=obj.Recorder.NextWrittenElement{PositionWithinData}+1;
                                    if(obj.Recorder.NextWrittenElement{PositionWithinData}>obj.Acquisition.VarBuffersize(PositionWithinData))
                                        if(obj.Acquisition.AsynchronousVarCounter(1)==PositionWithinData)
                                           %SAVE ON DISK 
                                        end
                                        obj.Recorder.NextWrittenElement{PositionWithinData}=1;
                                        obj.Recorder.TimesBufferFilled{PositionWithinData}=obj.Recorder.TimesBufferFilled{PositionWithinData}+1;
                                    end
                                end
                            end
                            for NOI =1:obj.Acquisition.ProfilePVs(VCR).Options.NumberOfArray2D
                                PositionWithinData=PositionWithinData+1;
                                for HHH=1:length(obj.Transient.NewPidsUS)
                                    obj.Recorder.AcquisitionWritingCycle{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Recorder.AbsoluteCaptureID;
                                    obj.Recorder.LastWrittenElement{PositionWithinData} = obj.Recorder.NextWrittenElement{PositionWithinData};
                                    obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.NextWrittenElement{PositionWithinData}) = POST_Proc_Data_asynch.Array2D{NOI}(:,:,HHH);
                                    obj.Recorder.PulseIds{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.LastWrittenPulseID{PositionWithinData}  = obj.Transient.NewPidsUS(HHH);
                                    obj.Recorder.EventsAbsoluteCounter{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData})  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData} +1;
                                    obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}+1;
                                    obj.Recorder.NextWrittenElement{PositionWithinData}=obj.Recorder.NextWrittenElement{PositionWithinData}+1;
                                    if(obj.Recorder.NextWrittenElement{PositionWithinData}>obj.Acquisition.VarBuffersize(PositionWithinData))
                                        if(obj.Acquisition.AsynchronousVarCounter(1)==PositionWithinData)
                                           %SAVE ON DISK 
                                        end
                                        obj.Recorder.NextWrittenElement{PositionWithinData}=1;
                                        obj.Recorder.TimesBufferFilled{PositionWithinData}=obj.Recorder.TimesBufferFilled{PositionWithinData}+1;
                                    end
                                end
                            end
                        else %Write the new data, without calling post processing function.
                            %                 while(any((PositionWithinData+1) == obj.Acquisition.NonTimeStampedProfilesPositionWithinData))
                            %                     PositionWithinData=PositionWithinData+1;
                            %                 end
                            PositionWithinData=PositionWithinData+1;
                            obj.Recorder.AcquisitionWritingCycle{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Recorder.AbsoluteCaptureID;
                            obj.Recorder.LastWrittenElement{PositionWithinData} = obj.Recorder.NextWrittenElement{PositionWithinData};
                            if(obj.Acquisition.ProfilePVs(VCR).IsVector)
                                if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData},:) = obj.Transient.ProfilePV{VCR}(obj.WriteInto,:);
                                else
                                    obj.Recorder.Data{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData},:) = obj.Transient.ProfilePV{VCR}(obj.WriteInto,:) - obj.Acquisition.ProfilePVs(VCR).Background;
                                end
                            else
                                if(isempty(obj.Acquisition.ProfilePVs(VCR).Background))
                                    obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.NextWrittenElement{PositionWithinData}) = reshape(obj.Transient.ProfilePV{VCR}(obj.WriteInto,:),obj.Acquisition.ProfilePVs(VCR).ReshapeSize);
                                else
                                    obj.Recorder.Data{PositionWithinData}(:,:,obj.Recorder.NextWrittenElement{PositionWithinData}) = reshape(obj.Transient.ProfilePV{VCR}(obj.WriteInto,:),obj.Acquisition.ProfilePVs(VCR).ReshapeSize) - obj.Acquisition.ProfilePVs(VCR).Background;
                                end
                            end
                            obj.Recorder.TimeStamps{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.Profile_TS(VCR,obj.WriteInto);
                            obj.Recorder.PulseIds{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData}) = obj.Transient.Profile_PID(VCR,obj.WriteInto);
                            obj.Recorder.LastWrittenPulseID{PositionWithinData}  = obj.Transient.Profile_PID(VCR,obj.WriteInto);
                            obj.Recorder.EventsAbsoluteCounter{PositionWithinData}(obj.Recorder.NextWrittenElement{PositionWithinData})  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData} +1;
                            obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}  = obj.Recorder.MaxEventsAbsoluteCounter{PositionWithinData}+1;
                            obj.Recorder.NextWrittenElement{PositionWithinData}=obj.Recorder.NextWrittenElement{PositionWithinData}+1;
                            if(obj.Recorder.NextWrittenElement{PositionWithinData}>obj.Acquisition.VarBuffersize(PositionWithinData))
                                if(obj.Acquisition.AsynchronousVarCounter(1)==PositionWithinData)
                                           %SAVE ON DISK 
                                end
                                obj.Recorder.NextWrittenElement{PositionWithinData}=1;
                                obj.Recorder.TimesBufferFilled{PositionWithinData}=obj.Recorder.TimesBufferFilled{PositionWithinData}+1;
                            end
                            if(VCR==1 && ~obj.Acquisition.NumberSynchPVs)
                                obj.Transient.NewPidsUS=obj.Transient.Profile_PID(VCR,obj.WriteInto);
                            end
                        end
                    end
                end
                
                if(obj.WriteInto==2)
                    obj.WriteInto=1;
                    obj.CompareTo=2;
                else
                    obj.WriteInto=2;
                    obj.CompareTo=1;
                end
                obj.Acquisition.BSA_Vars.current_time=toc;
            end
            [the_matrix,ComplexTimestamps] = lcaGetSyncHST(obj.Acquisition.SynchronousPVs);
            
            ActualTime=double(real(ComplexTimestamps)) + double(imag(ComplexTimestamps))/10^9;
            
            Valid_Positions=find(ActualTime>obj.Recorder.LastValidTime);
            
            if(obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data)
                Valid_Positions=Valid_Positions(1:(end-obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data));
                ActualTime(1:(end-obj.Acquisition.BSA_Vars.BSA_Safe_Trash_Data));
            end
            
            obj.LastValidCueElement=obj.Acquisition.BSA_Vars.ReadCueValid;
            
            
            if(~isempty(Valid_Positions))
                obj.Transient.Valid_BSA_Data=the_matrix(:,Valid_Positions);
                obj.Transient.Valid_BSA_TS=ComplexTimestamps(Valid_Positions);
                obj.Transient.Valid_BSA_PID= bitand(uint32(imag( obj.Transient.Valid_BSA_TS) ),hex2dec('1FFFF'));
                if(obj.Acquisition.BSA==3)
                    [~,DOVE1,DOVE2]=intersect(obj.Transient.SynchPV(1,1:obj.LastValidCueElement),obj.Transient.Valid_BSA_Data(1,:),'stable');
                    obj.Transient.SynchPV_PID=double(bitand(uint32(imag(obj.Transient.SynchPV_TS(1,DOVE1))),hex2dec('1FFFF')));
                    SHIFT=mode(double(obj.Transient.Valid_BSA_PID(DOVE2))-obj.Transient.SynchPV_PID);
                    obj.Transient.Valid_BSA_PID=obj.Transient.Valid_BSA_PID-SHIFT;
                else
                    obj.Transient.Valid_BSA_PID=double(obj.Transient.Valid_BSA_PID);
                end
                obj.Recorder.LastValidTime=max(obj.Recorder.LastValidTime,max(ActualTime));
            else
                obj.Transient.Valid_BSA_Data=[];
                obj.Transient.Valid_BSA_PID=[];
                obj.Transient.Valid_BSA_TS=[];
            end
            
            if(isempty(obj.Transient.Valid_BSA_PID)) % if no data... then nothing.
                obj.Recorder.NewDataFoundLength=0;
            else
                if(obj.Acquisition.UseRejection)
                    for TT=1:numel(obj.Acquisition.Rejection) %If some rejection is required, just NaN the unwanted data in the pulse IDs.
                        obj.Transient.Valid_BSA_PID((obj.Transient.Valid_BSA_Data(obj.Acquisition.Rejection(TT).POS,:)< obj.Acquisition.Rejection(TT).LO) | (obj.Transient.Valid_BSA_Data(obj.Acquisition.Rejection(TT).POS,:)> obj.Acquisition.Rejection(TT).HI))=NaN;
                    end
                end
                PID=setdiff(obj.Transient.Valid_BSA_PID,obj.Recorder.LastWrittenPulseID{1},'stable');
                obj.Recorder.NewDataFoundLength=length(PID);
                
                if(obj.Recorder.NewDataFoundLength)
                    obj.Recorder.LastWrittenPulseID{1} = PID(end);
                    if(obj.Recorder.NewDataFoundLength>(1+obj.Acquisition.Buffersize-obj.Recorder.NextWrittenElement{1})) %goes over the buffer size
                        obj.Recorder.LastWrittenElement{1}=obj.Recorder.NewDataFoundLength-obj.Acquisition.Buffersize+obj.Recorder.NextWrittenElement{1}-1;
                        obj.Recorder.Destination=[obj.Recorder.NextWrittenElement{1}:obj.Acquisition.Buffersize,1:obj.Recorder.LastWrittenElement{1}];
                        obj.Recorder.TimesBufferFilled{1}=obj.Recorder.TimesBufferFilled{1}+1;
                        obj.Recorder.NextWrittenElement{1}=obj.Recorder.LastWrittenElement{1}+1;
                        %EXIT CONDITION HERE
                        if(obj.Recorder.NextWrittenElement{1} > obj.Acquisition.Buffersize)
                            obj.Recorder.NextWrittenElement{1}=1;
                        end
                    else%does not go over buffer size.
                        obj.Recorder.LastWrittenElement{1}=obj.Recorder.NextWrittenElement{1}+obj.Recorder.NewDataFoundLength-1;
                        obj.Recorder.Destination=obj.Recorder.NextWrittenElement{1}:obj.Recorder.LastWrittenElement{1};
                        obj.Recorder.NextWrittenElement{1}=obj.Recorder.LastWrittenElement{1}+1;
                        if(obj.Recorder.NextWrittenElement{1} > obj.Acquisition.Buffersize)
                            %EXIT CONDITION HERE
                            obj.Recorder.NextWrittenElement{1}=1;
                            obj.Recorder.TimesBufferFilled{1}=obj.Recorder.TimesBufferFilled{1}+1;
                        end
                    end
                    obj.Recorder.EventsAbsoluteCounter{1}(obj.Recorder.Destination) = obj.Recorder.MaxEventsAbsoluteCounter{1} + (1:obj.Recorder.NewDataFoundLength);
                    obj.Recorder.MaxEventsAbsoluteCounter{1} = obj.Recorder.MaxEventsAbsoluteCounter{1} + obj.Recorder.NewDataFoundLength;
                end
                
                if(obj.Recorder.NewDataFoundLength) %Fill buffers if any new data has been found.
                    [~,~,DOVE]=intersect(PID, obj.Transient.Valid_BSA_PID,'stable');
                    obj.Recorder.Data{1}(obj.Recorder.Destination,:) = obj.Transient.Valid_BSA_Data(:,DOVE).';
                    obj.Recorder.TimeStamps{1}(obj.Recorder.Destination)= obj.Transient.Valid_BSA_TS(1,DOVE);
                    obj.Recorder.PulseIds{1}(obj.Recorder.Destination)= obj.Transient.Valid_BSA_PID(1,DOVE);
                    obj.Recorder.AcquisitionWritingCycle{1}(obj.Recorder.Destination)=obj.Recorder.AbsoluteCaptureID;
                    
                end
            end
        end
        
        function OUT=FreeGaussFit(obj,X,Y,PARAM)
            % PARM=[petition.A,petition.x0,petition.C,petition.B,petition.Off];
            POS_INC=find(isnan(PARAM));
            POS_FIX=find(~isnan(PARAM));
            X_FIX=PARAM(~isnan(PARAM));
            [MV,MP]=max(Y);
            m=min(Y);
            START = [MV-m,X(MP),2,(max(X)-min(X))/5,m];
            START=START(POS_INC);
            XX = fminsearch(@(x) obj.FE(x,X_FIX,X,Y,POS_INC,POS_FIX),START);
            OUT.Param=zeros(length(POS_INC)+length(POS_FIX),1);
            OUT.Param(POS_INC)=XX; OUT.Param(POS_FIX)=X_FIX;
            OUT.XV=linspace(min(X)-abs(max(X)-min(X))/20,max(X)+abs(max(X)-min(X))/20,100);
            OUT.Fit=obj.FG(OUT.XV,OUT.Param);
        end
 
        function O=FG(obj,X,P)
            O= P(5) + P(1).*exp(- (X - P(2)).^(P(3))./(2*P(4)*P(4)));
        end
        
        function ERR=FE(obj,X_INC,X_FIX,X,Y,VAR,FIX)
            P=zeros(length(VAR)+length(FIX),1);
            P(VAR)=X_INC; P(FIX)=X_FIX;
            ERR=sum((obj.FG(X,P) - Y).^2);
        end
        
        function TM=TextMatrixToTextColumn(obj, IN)
            [SA,SB]=size(IN);
            TM=['\begin{tabular}{',repmat('l',1,SB),'} '];
            for II=1:SA
                for JJ=1:SB
                    TM=[TM,IN{II,JJ}];
                        if(JJ<SB)
                            TM=[TM,'&'];
                        end
                end
                %if(II<SA)
                    TM=[TM,' \\'];
                %end
            end
            TM=[TM,' \end{tabular}'];
        end
        
        function [Mappa, xax, yax]=DensityMap(obj, XData, YData, binsx, binsy)
            Mappa=zeros(binsx,binsy);
            mx=min(XData); Mx=max(XData); my=min(YData); My=max(YData);
            if(mx==Mx)
               mx=mx-max(abs(mx)/10,1/1000);
               Mx=Mx+max(abs(Mx)/10,1/1000);
            end
            if(my==My)
               my=my-max(abs(my)/10,1/1000);
               My=My+max(abs(My)/10,1/1000);
            end
            xax = linspace(mx, Mx, binsx); yax = linspace(my, My, binsy);
            XInd=round((XData-mx)/(Mx-mx)*binsx); XInd(XInd==0)=1;
            YInd=round((YData-my)/(My-my)*binsy); YInd(YInd==0)=1;
            if(length(XInd)<binsx*binsy)
                for II=1:length(XInd)
                   Mappa(XInd(II),YInd(II))=Mappa(XInd(II),YInd(II))+1; 
                end
            else
                for II=1:binsx
                    for JJ=1:binsy
                        Mappa(II,JJ)=sum((XInd==II).*(YInd==JJ));
                    end
                end
            end
            Mappa=Mappa.';
        end
        
        function [PP,PW]=MakePartitionInData(obj,PartitionPos,PartitionWidth)
            if(any(isnan(PartitionPos)))
                PartitionPos=NaN;
            end
            if(any(isnan(PartitionWidth)))
                PartitionWidth=NaN;
            end
            if(isnan(PartitionPos)) %Full partition.
                PP=NaN; PW=NaN;
            elseif(isnan(PartitionWidth)) %Pos is selected, but not width.
                PW=(max(PartitionPos)-min(PartitionPos))/length(PartitionPos); PP=PartitionPos;
                PP=PartitionPos; PW=ones(size(PartitionPos))*PW;
            elseif(length(PartitionPos) == length(PartitionWidth))
                PP=PartitionPos; PW=PartitionWidth;
            elseif(length(PartitionPos)==1)
                PP=ones(size(PartitionWidth))*PartitionPos; PW=PartitionWidth;
            elseif(length(PartitionWidth)==1)
                PP=PartitionPos; PW=ones(size(PartitionPos))*PartitionWidth;
            else
                PartitionWidth=PartitionWidth(1);
                PW=ones(size(PartitionPos))*PartitionWidth; PP=PartitionPos;
            end 
        end
        
        function [PPlot, SubPlots] = PPlot(obj, VectorData,XData,KeepVector,KeepX,VectorArea, PartitionPos, PartitionWidth, Stats)
            if(~isinf(PartitionPos(1)))
                [Centers,Widths]=obj.MakePartitionInData(PartitionPos, PartitionWidth);
                if(isnan(Centers(1)))
                    Centers=mean(XData(KeepX(~isnan(XData(KeepX))))); Widths=inf;
                end
            else
               Centers=unique(XData(KeepX(~isnan(XData(KeepX))))); Widths=zeros(size(Centers)); 
            end
            PPlot=zeros(length(Centers),length(VectorArea));
            [SubPlots.AVGX,SubPlots.Elements,SubPlots.FWHM,SubPlots.MaxPos,SubPlots.MaxVal,SubPlots.Integral]=deal(zeros(1,length(Centers)));
            for II=1:length(Centers)
                if(~Widths(II))
                    KE=find(XData(KeepX)==Centers(II));
                else
                    KE=find((XData(KeepX) >= (Centers(II) - Widths(II)/2) ) & (XData(KeepX) < (Centers(II) + Widths(II)/2)) );
                end
                PPlot(II,:) = mean(VectorData(KeepVector(KE),VectorArea),1);
                SubPlots.AVGX(II)=mean(XData(KeepX(KE)));
                SubPlots.Elements(II)=length(KE);
                if(Stats)
                   [SubPlots.FWHM(II), SubPlots.MaxPos(II), SubPlots.MaxVal(II), SubPlots.Integral(II)] = EvalVectorBasicStats(obj, PPlot(II,:));
                end
            end
        end
        
        function [Partition, stdPartition, AVGX, Centers, Widths, Elements]=PartitionPlotScalar(obj, XData, YData, PartitionPos, PartitionWidth)
            [Centers,Widths]=obj.MakePartitionInData(PartitionPos, PartitionWidth);
            if(isnan(Centers(1)))
                Centers=unique(XData(~isnan(XData))); Widths=0*Centers;
            end
            [AVGX,Partition,stdPartition,Elements]=deal(zeros(1,length(Centers)));
            for II=1:length(Centers)
                if(~Widths(II))
                    KE=find(XData==Centers(II));
                else
                    KE=find((XData >= (Centers(II) - Widths(II)/2) ) & (XData < (Centers(II) + Widths(II)/2)) );
                end
                Partition(II)=mean(YData(KE));
                stdPartition(II)=std(YData(KE));
                AVGX(II)=mean(XData(KE));
                Elements(II)=length(KE);
            end
        end
        
        function [FWHM, MP, MV, INT]=EvalVectorBasicStats(obj, Vector)
           [MV, MP] = max(Vector);
           P1=find(Vector(MP:-1:1)>=MV/2,1,'last');
           P2=find(Vector(MP:end)>=MV/2,1,'last');
           if(isempty(P1) || isempty(P2))
               FWHM=NaN;
           else
               FWHM=P1+P2-1;
           end
           INT=sum(Vector);
        end
        
        function [LMap, xax]=LPlot(obj,VectorData,XData,KeepVector,KeepX,VectorArea, binsx)
            LMap=zeros(binsx,length(VectorArea));
            mx=min(XData(KeepX)); Mx=max(XData(KeepX));
            if(mx==Mx)
               mx=mx-max(abs(mx)/10,1/1000);
               Mx=Mx+max(abs(Mx)/10,1/1000);
            end
            xax = linspace(mx, Mx, binsx);
            XInd=round((XData(KeepX)+eps-mx)/(Mx-mx)*binsx); XInd(XInd==0)=1;
            for II=1:binsx
                LMap(II,:)=mean(VectorData(KeepVector(XInd==II),VectorArea),1);
            end
            
        end
        
        function StateNumberContinuousRecording(obj)
            if(obj.Acquisition.Synchronous)
                obj.Counter=obj.Recorder.LastWrittenElement;
            elseif(obj.Acquisition.AsynchronousVarCounter(1)==1)
                if(obj.Acquisition.BSA)
                    obj.Counter=obj.Recorder.LastWrittenElement{obj.Acquisition.AsynchronousVarCounter(1)};
                else
                    obj.Counter=obj.Recorder.LastWrittenElement{obj.Acquisition.AsynchronousVarCounter(1)}(obj.Acquisition.AsynchronousVarCounter(2));
                end
            else
                if(obj.Acquisition.TimeStamped(obj.Acquisition.AsynchronousVarCounter(1)))
                    obj.Counter=obj.Recorder.LastWrittenElement{obj.Acquisition.AsynchronousVarCounter(1)};
                else
                    obj.Counter=obj.Recorder.AcquisitionNonTimeStampedLastWrittenElement(obj.Acquisition.AsynchronousVarCounter(1));
                end
            end
        end
        
        function eDefRelease(obj)
           for II=1:length(obj.myeDefNumber)
                 eDefRelease(obj.myeDefNumber(II));
            	 obj.myeDefNumber(II)=NaN;
           end
        end
        
        function FullsizeScalars=FullsizeDiscreteScalars(obj,Data,DataStructure)
            if(nargin<2)
               Data=obj.Recorder;
               DataStructure=obj.Acquisition;
            end
            ins=0;
            FullsizeScalars.Variables={};
            for II=1:numel(DataStructure.TimeStamped)
                if(~DataStructure.TimeStamped(II))
                    if(~DataStructure.Synchronous)
                        if(DataStructure.BSA)
                            TS_AWC=Data.AcquisitionWritingCycle{1};
                        else
                            TS_AWC=Data.AcquisitionWritingCycle{1}(:,1);
                        end
                    else
                        TS_AWC=Data.AcquisitionWritingCycle;
                    end
                    Quanti=sum((DataStructure.VarPosition(:,1)==II));
                    if(DataStructure.AllSizes{II}(2)~=Quanti)
                        continue
                    end
                    if(II==1)
                        FullsizeScalars.Data=NaN*TS_AWC;
                    end
                    for JJ=1:size(Data.Data{II},2)
                        ins=ins+1;
                        FullsizeScalars.Data(:,ins)=obj.NonTimeStamped_On_Timestamped(Data.AcquisitionWritingCycle_NonTimeStamped{II},Data.Data{II}(:,JJ),TS_AWC);
                        VARID=find( (DataStructure.VarPosition(:,1)==II) & (DataStructure.VarPosition(:,2)==JJ));
                        FullsizeScalars.Variables{end+1}=DataStructure.VarNames{VARID};
                    end
                end
            end
            if(isempty(FullsizeScalars.Variables))
                FullsizeScalars.Data=[];
            end
        end
    end
    
end