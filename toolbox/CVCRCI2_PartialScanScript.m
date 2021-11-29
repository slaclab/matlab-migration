if(get(handles.StartScan,'userdata'))
    if(ishandle(handles.MyScanPanel))
        ScanSetting=get(handles.MyScanTags.Ready,'userdata');
    else
        ScanSetting=[];
        set(handles.StartScan,'backgroundcolor',handles.ColorOff);
        pause(0.1);drawnow;set(handles.StartScan,'backgroundcolor',handles.ColorIdle);
        set(handles.StartScan,'userdata',0);
    end
    if(isstruct(ScanSetting))
        %set up buffers for the scan
        PositionGuaranteedPV=find(strcmp(FullDataStructure.ScalarNames,ScanSetting.GuaranteedPV));
        if(~isempty(PositionGuaranteedPV))
            S_Guaranteed=FullDataStructure.ScalarWhereToBeFound(PositionGuaranteedPV,:);
        else
            S_Guaranteed=[0,0,0];
        end
        CurrentCondition=0;
        ScanBuffer=zeros(Init_Vars.BufferSize,ScanSetting.ScanBufferLength);
        
        %for partial synchronization only...
        
%         FullPulseIDMatrix{8}=NaN*ones(Init_Vars.BufferSize,1);
%             FullAcquisitionBufferCycle{8}=0;
%             AcquisitionTotalSynchronousEvents{8}=0;
%             FullAcquisitionBufferNextWrittenElement{8} = 1;
%             FullAcquisitionBufferLastWrittenElement{8} = 1;
%             LAST_VALID_PULSE_IDs{8} = -1;
%             FullAcquisitionTotalSynchronousEvents{8}=0;
%             AcquisitionBufferSpaceLeftThisBuffer{8} = Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{8} + 1;
%             FullTimeStampsMatrix = FullPulseIDMatrix;
%             AbsoluteEventCounterMatrix=FullTimeStampsMatrix;

        
        
        CVCRCI2_FullDataStructureScript
        set(handles.Profile2,'userdata',FullDataStructure);
        %set(handles.Profile2,'userdata');
        CVCRCI2_Initialize_All_Graphics
        CVCRCI2_ClearAllBuffer_Script
        
        if(ScanSetting.RestoreStarting)
            for SCPV=1:ScanSetting.NumberOfScanPVs
                RESTORE(SCPV)=lcaGetSmart(ScanSetting.SCANPVLIST{SCPV});
            end
            set(handles.ResumeFreeRun,'userdata',RESTORE);
        end
        drawnow
        
        ScanSetting.Functions{2}();
        set(handles.StopScan,'enable','on');
        
        if(~Init_Vars.UpdateNonSynch) %read them at least once before starting...
              for II=1:Init_Vars.NumberOfNoNSynchPVs
                  NotSynchProfilePVsReadVariables(II)=lcaGetSmart(Init_Vars.PvNotSyncList{II});
              end
              %you cannot... this one will require attention... fill the entire buffer here and forget about it
        end
        
        while(1) %entering scan cycle...
            CurrentCondition=CurrentCondition+1;
            if(CurrentCondition>ScanSetting.TotalNumberOfConditions)
                break
            end
            
            CurrentScanBufferValues=ScanSetting.ScanBufferValues(CurrentCondition,:);
            
            for SCPV=1:ScanSetting.NumberOfScanPVs
                lcaPutSmart(ScanSetting.SCANPVLIST{SCPV},ScanSetting.ScanValuesMatrix(CurrentCondition,SCPV));
            end
            %disp('Moving Rows =')
            Destination=ScanSetting.ScanValuesMatrix(CurrentCondition,:);
            DestinationWithDistance=Destination(ScanSetting.WaitUntilArrivedPosition);
            tic
            ExitCondition=1;
            TRYS=0;
            CurrentValue=zeros(size(ScanSetting.WaitUntilArrived));
            AcquiredSamples=0;
            while(ExitCondition) %checks until you are arrived
                TRYS=TRYS+1;
                if(any(DestinationWithDistance))
                    for CheckPV=1:numel(ScanSetting.READOUTPVLIST)
                        CurrentValue(CheckPV)=lcaGetSmart(ScanSetting.READOUTPVLIST{CheckPV});
                    end
                    
                    Distance=abs(CurrentValue-DestinationWithDistance);
                    
                    if(all(Distance<=(ScanSetting.ToleranceVector+10^-15)) && (toc>ScanSetting.Pause(CurrentCondition)))
                        ExitCondition=0;
                        
                    else
                        pause(0.1);
                        if(mod(TRYS,10)==9)
                            for SCPV=1:ScanSetting.NumberOfScanPVs
                                disp('Reissuing command, distance =')
                                disp(Distance)
                                lcaPutSmart(ScanSetting.SCANPVLIST{SCPV},ScanSetting.ScanValuesMatrix(CurrentCondition,SCPV));
                            end
                        end
                        drawnow
                    end
                else
                    if(toc>ScanSetting.Pause(CurrentCondition))
                        ExitCondition=0;
                    else
                        pause(0.1);
                        drawnow
                        if(mod(TRYS,10)==9)
                            for SCPV=1:ScanSetting.NumberOfScanPVs
                                lcaPutSmart(ScanSetting.SCANPVLIST{SCPV},ScanSetting.ScanValuesMatrix(CurrentCondition,SCPV));
                            end
                        end
                    end
                end
            end
            
            ScanSetting.Functions{3}(); %After each setting;
            
            
            %Arrivati leggi il timestamp attuale se lavora in BSA
            if(BSA) 
                [~,ats]=lcaGetSmart(Init_Vars.PvSyncList{1});
                LastValidTime=real(ats)+imag(ats)/10^9- 631152000;
                while(isnan(LastValidTime))
                    [~,ats]=lcaGetSmart(Init_Vars.PvSyncList{1});
                    LastValidTime=real(ats)+imag(ats)/10^9 - 631152000;
                end
                % LastValidTime
                LastValidPulseID = bitand(uint32(imag(ats)),hex2dec('1FFFF'));
            end
            
            ExitCondition=1;
            while(ExitCondition)
                
                drawnow
                % RECORDING !!
                if(BSA)
                    CVCRCI2_BSA_Acquisition_Script
                else %Not BSA
                    CVCRCI2_Non_BSA_Acquisition_Script
                end
                %disp('Done')
                
                if(Init_Vars.NumberOfProfiles)
                    if(any([CycleVars.Run_Post_Processing]))
                        for II=1:Init_Vars.NumberOfProfiles
                            if(CycleVars(II).Run_Post_Processing)
                                ProcessedData(II)=CycleVars(II).ProcessingFunction(ProfileCue{II},0,ProfileCue_TS(II,:));
                                if(CycleVars(II).Processing_Comes_With_PID)
                                    ProcessedData(II).PulseID=mod(ProcessedData(II).PulseID + CycleVars(1).PulseIDDealy,handles.MAX_Pulse_ID);
                                elseif(CycleVars(1).Processing_Comes_With_TimeStamps)
                                    ProcessedData(II).PulseID=bitand(uint32(imag(ProcessedData(II).TimeStamp)),hex2dec('1FFFF'));
                                    ProcessedData(II).PulseID=mod(ProcessedData(II).PulseID + CycleVars(1).PulseIDDealy,handles.MAX_Pulse_ID);
                                else %timestamps are the one of the readout.
                                    ProcessedData(II).PulseID=mod(ProfileCue_TS(II,1:LastValidCueElement) + CycleVars(1).PulseIDDealy,handles.MAX_Pulse_ID);
                                end
                            end
                        end
                    end
                end
                
                if(BSA)
                    if(~isempty(ValidDataArray_PV))
                        CVCRCI2_Partial_SynchronizeEvents_with_guaranteed_BSA
                    end
                else %Not BSA
                    CVCRCI2_Partial_SynchronizeEvents_with_guaranteed
                end
                if(~isempty(ALL_PIDS_FOUND))
                        [Upid,DoveUpid]=unique(ALL_PIDS_FOUND,'stable');
                        NewDataFoundLength=length(Upid);
                        %[NewDataFoundLength,AcquisitionBufferSpaceLeftThisBuffer{1}]
                        if(NewDataFoundLength>AcquisitionBufferSpaceLeftThisBuffer{8})%??
                           Destination=[FullAcquisitionBufferNextWrittenElement{8}:Init_Vars.BufferSize,1:(NewDataFoundLength-AcquisitionBufferSpaceLeftThisBuffer{8})];
                           FullAcquisitionBufferCycle{8}=FullAcquisitionBufferCycle{8}+1;
                           FullAcquisitionBufferLastWrittenElement{8}=Destination(end);
                           FullAcquisitionBufferNextWrittenElement{8}=FullAcquisitionBufferLastWrittenElement{8}+1;
                           if(FullAcquisitionBufferNextWrittenElement{8} > Init_Vars.BufferSize)
                               FullAcquisitionBufferNextWrittenElement{8}=1;
                           end
                           AcquisitionBufferSpaceLeftThisBuffer{8}= Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{8} + 1;
                        else
                           Destination =  FullAcquisitionBufferNextWrittenElement{8}:(FullAcquisitionBufferNextWrittenElement{8}+NewDataFoundLength-1);
                           FullAcquisitionBufferLastWrittenElement{8}=FullAcquisitionBufferNextWrittenElement{8}+NewDataFoundLength-1;
                           FullAcquisitionBufferNextWrittenElement{8}=FullAcquisitionBufferLastWrittenElement{8}+1;
                           if(FullAcquisitionBufferNextWrittenElement{8} > Init_Vars.BufferSize)
                               FullAcquisitionBufferNextWrittenElement{8}=1;
                               FullAcquisitionBufferCycle{8}=FullAcquisitionBufferCycle{8}+1;
                           end
                           AcquisitionBufferSpaceLeftThisBuffer{8}= Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{8} + 1;
                        end
                    if(S_Guaranteed(1)==1)
                        AcquiredSamples=AcquiredSamples+length(CO);
                    else
                        AcquiredSamples=AcquiredSamples+NewDataFoundLength;
                    end
                    
                    
                    ScanBuffer(Destination,:)= repmat(CurrentScanBufferValues,NewDataFoundLength,1);
                    
                    set(handles.EventsNumber,'string',[num2str(FullAcquisitionBufferLastWrittenElement{1}(1)),'/',num2str(AcquiredSamples)]);
                    
                    %disp('Synchronization Done')
%                     if(~AcquisitionBufferCycle)
%                         FiltersBuffer{1}(Destination)=true;
%                     end
                    
%                     EvaluatingSynchScalars
%                     EvaluatingFilters
%                     EvaluatingOuts
                    
                end
                disp(['Getting Data ',num2str(AcquiredSamples)])
                
                    %Finally Call Display "GUIs"...
                    %         AbsoluteEventCounterMatrix <-AcquisitionTotalSynchronousEvents
                    %         AbsoluteEventCounterProfiles <-AcquisitionBufferCycle
                    %         FullPulseIDMatrix <- PulseIDMatrix
                    %         FullPulseIDProfiles <- TimeStampsMatrix
                    %         BSA <- ScalarsBuffer
                        DisplayGuis=get(handles.Displays,'Userdata'); 
                        for II=1:DisplayGuis(1).NumberOfDisplays
                            ToBeDeleted=0;
                            if(ishandle(DisplayGuis(II).Displayhandle)) %figure exists, update it
                                DisplayGuis(II).CallingFunction(0,0,DisplayGuis(II).ALLTAGS,FullDataStructure,FullPulseIDMatrix,FullPulseIDProfiles,AbsoluteEventCounterMatrix,ProfileBuffer,SynchProfilePVs,NotSynchProfilePVs,ScalarBuffer,FiltersBuffer,BSA,ScanBuffer,AbsoluteEventCounterProfiles,AcquisitionTotalSynchronousEvents,FullAcquisitionBufferNextWrittenElement,FullAcquisitionBufferLastWrittenElement);
                            else %figure does not exist anymore, remember to close it soon
                                ToBeDeleted=1;
                            end
                            if(ToBeDeleted)
                                check_open_displays(handles);
                                update_current_displays(handles);
                            end
                        end
                
                COLORESTOP=get(handles.StopScan,'backgroundcolor');
                if(~any(COLORESTOP-handles.ColorWait))
                    break
                end
                if(AcquiredSamples>=ScanSetting.NumberOfEvents)
                    ExitCondition=0;
                end
            end
            if(~any(COLORESTOP-handles.ColorWait))
                break
            end
            %going to the next sample...
            
        end %lo scan viene effettivamente fatto
        %Lo scan e' finito puoi continuare a vedere i dati e eventualmente salvarli
        ScanSetting.Functions{4}();
        set(handles.StartScan,'backgroundcolor',handles.ColorIdle);set(handles.StartScan,'enable','off');
        set(handles.StopScan,'backgroundcolor',handles.ColorIdle);set(handles.StopScan,'enable','off');
        set(handles.ResumeFreeRun,'backgroundcolor',handles.ColorOn);set(handles.ResumeFreeRun,'enable','on');
        set(handles.StartScan,'Userdata',0);set(handles.StopScan,'Userdata',0);set(handles.ResumeFreeRun,'Userdata',0);
        drawnow
        while(1)
            COLORERESUME=get(handles.ResumeFreeRun,'backgroundcolor');
            if(~any(COLORERESUME-handles.ColorWait))
                ScanSetting.ScanBufferNames={};
                ScanSetting.ScanBufferLength=0;
                CVCRCI2_FullDataStructureScript
                CVCRCI2_ClearAllBuffer_Script
                CVCRCI2_Initialize_All_Graphics
                set(handles.START,'enable','off'); set(handles.PAUSE,'enable','on'); set(handles.STOP,'enable','on');
                set(handles.START,'string','Start'); set(handles.PAUSE,'string','Pause'); set(handles.STOP,'string','Stop');
                set(handles.START,'backgroundcolor',handles.ColorOn); set(handles.PAUSE,'backgroundcolor',handles.ColorIdle); set(handles.PAUSE,'backgroundcolor',handles.ColorIdle);drawnow
                set(handles.StartScan,'enable','on'); set(handles.StartScan,'Userdata',0);
                set(handles.ResumeFreeRun,'enable','off'); set(handles.ResumeFreeRun,'Userdata',0); set(handles.ResumeFreeRun,'backgroundcolor',handles.ColorIdle);
                break
            end
            %Finally Call Display "GUIs"...
            %    AbsoluteEventCounterMatrix <-AcquisitionTotalSynchronousEvents
            %         AbsoluteEventCounterProfiles <-AcquisitionBufferCycle
            %         FullPulseIDMatrix <- PulseIDMatrix
            %         FullPulseIDProfiles <- TimeStampsMatrix
            %         BSA <- ScalarsBuffer
            DisplayGuis=get(handles.Displays,'Userdata');
            for II=1:DisplayGuis(1).NumberOfDisplays
                ToBeDeleted=0;
                if(ishandle(DisplayGuis(II).Displayhandle)) %figure exists, update it
                    DisplayGuis(II).CallingFunction(0,0,DisplayGuis(II).ALLTAGS,FullDataStructure,FullPulseIDMatrix,FullPulseIDProfiles,AbsoluteEventCounterMatrix,ProfileBuffer,SynchProfilePVs,NotSynchProfilePVs,ScalarBuffer,FiltersBuffer,BSA,ScanBuffer,AbsoluteEventCounterProfiles,AcquisitionTotalSynchronousEvents,FullAcquisitionBufferNextWrittenElement,FullAcquisitionBufferLastWrittenElement);
                else %figure does not exist anymore, remember to close it soon
                    ToBeDeleted=1;
                end
                if(ToBeDeleted)
                    check_open_displays(handles);
                    update_current_displays(handles);
                end
            end
            pause(0.2);
        end
        
        %restore previous buffers
        CVCRCI2_ClearAllBuffer_Script
        
    end %scan setting e' struttura e quindi, forse si puo' fare
    
end