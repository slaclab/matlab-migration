function CVCRCI2_DISPLAYTEST_update(Initialize, SynchMode, MyHandle,DATASTRUCTURE,PulseIDMatrix,TSorPID,AbsoluteEventCounterMatrix,ProfileBuffer,SynchProfilePVs,NotSynchProfilePVs,AdditionalNonStandardPVsMatrices,FiltersBuffer,ScalarsBufferORbsa,ScanBuffer,AcqBufCycORAbsCountProfiles,AcquisitionTotalSynchronousEvents,AcquisitionBufferNextWrittenElement,AcquisitionBufferLastWrittenElement)

%Input
% Initialize, 1 when initializing, 0 when update

% SynchMode, 1 when synch mode, the acquisition does the timestamp
% matching and values of event number N on all the buffers are supposed to represent the same event
% SynchMode, 0 when not in synch mode, the acquisition does not the
% timestamp matching, pulse id are provided for any single event, the
% update function must take care of timestamp matching and eventually of
% timestamp shifting

% MyHandle, a structure having as fields the handles to all the objects in
% the figure related to the update function, no search is performed on
% second level children therefore do not use panels, because object within
% panels will not be available

% DATASTRUCTURE 
% current data structure given by the acquisition function, it should be
% stored in a local variable within the display/analysis gui, to be
% retrieved and used for local callbacks and to avoid
% computation overload required by reading the objects within the figure at
% every single call

% PulseIDMatrix
% if synch mode =1, is the PulseIDMatrix having size of the buffer size
% if synch mode =0, it has the PulseIDMatrix for all the scalars refer to
% the example in the code to see how it is supposed to be used

% TSorPID
% if synch mode =1, is the TimeStampMatrix having size of the buffer size
% if synch mode =0, it has the PulseIDMatrix for all the non-scalars (vectors and images) refer to
% the example in the code to see how it is supposed to be used

% AbsoluteEventCounterMatrix
% if synch mode =1, is the AbsoluteEventCounterMatrix having size of the
% buffer size keeps information about the incremental event number that has
% been recorded
% if synch mode =0, it has the information only for the Scalars refer below
% to how use it

% ProfileBuffer
% Cell array with all the vectors and 2D images

% SynchProfilePVs
% Matrix with all "normal" scalar profiles (synch profile read with lcaGet)

%NotSynchProfilePVs
%Any PV read at the beginning of the acquisition but not at synchronous
%rate, one may read them once at every acquisition cycle

%AdditionalNonStandardPVsMatrices
%All the PVs read in non-standard way, such as decoded from user-side
%waveforms, such as cookiebox data

%FiltersBuffer
%Works only in Synch mode: Cell Array with all the calculated filters. Filters are logical vectors of
%the size of the buffer, true = fullfills conditions, false doesn't.

%ScalarsBufferORbsa
%In synch mode=1 has the on-the-fly evaluated scalar quantities (such an angle from two bpms, or the integrated intensity on an area of a detector)
%In synch mode=0, 1= BSA is ON ; 0= BSA is off. (Evaluated scalars do not work in non-synch mode)

%ScanBuffer
%Matrix with all the pvs related to a scan, such as scan settings, scan
%position within the scan and other relevant quantities defined by the scan
%preset

%AcqBufCycORAbsCountProfiles
% in Synch Mode =0, has the number of times the acquisition buffer has been
% filled
% in Synch Mode =1, has the absolut event counter for the profiles (vectors
% and images) stored as a cell array matched to the ProfileBuffer cell
% array

%AcquisitionTotalSynchronousEvents
%Number of total acquired event in synch mode, unused in non synch mode

%AcquisitionBufferNextWrittenElement
%Next element written in the buffer cue (the first that will go out when another event is recorded)
%Unused when non synch mode is off

%AcquisitionBufferLastWrittenElement
%Last element written in the buffer cue (the last that will go out when another event is recorded)
%Unused when non synch mode is off

persistent MyPersistentData
if(Initialize)
    % Initialize is run when:
    % function is called the first time
    % and anytime something in the acquisition might be changed (a scan is started, a new filter has been activated)

    % Current data structure stored within the display/analysis is read
    % here, if it is changed, then it is a good idea to run fully the
    % initialization script, otherwise the old initialization may be still
    % good
    
    CurrentDataStructure = get(MyHandle.StoredDataStructure,'userdata');
    if(isequal(CurrentDataStructure,DATASTRUCTURE))
        %you might still do something if the init function is called, even
        %if CurrentDataStructure has not changed, I usually don't do
        %anything
    else
        
        % Data needed by the analysis/display that is used across different
        % callings should be stored in persistent variables. Anything loaded
        % from the hard disk, should be put in some persistent data during
        % initialization
        %MyPersistentData=0;
        
        %Populates the list of scalars, vectors, images and filters and
        %stores the new Data structure in the gui itself as "most
        %up-to-date"
        
        %Stores current (new) data structure
        %set(MyHandle.StoredDataStructure,'userdata',DATASTRUCTURE);
        
        %Reads the current user selection, initialization may override some
        %of those
        %UserSelections=get(MyHandle.Requested,'userdata');
        
        %Sets the Filters pop-up-menu with the filter list and defaults it
        %as "off"
%         LIST_OF_FILTERS{1}='Filter OFF';
%         for II=1:DATASTRUCTURE.FilterNumber
%             LIST_OF_FILTERS{end+1}=DATASTRUCTURE.FilterNames{II};
%         end
%         set(MyHandle.Filter,'string',LIST_OF_FILTERS);
%         UserSelections.FILTERS=0; set(MyHandle.Filter,'value',1);
%         
        %Sets the Vectors pop-up-menu with the filter list and defaults it
%         %as "off"
%         LIST_OF_VECTORS{1}='Off';
%         for II=1:DATASTRUCTURE.Number_of_vectors
%             LIST_OF_VECTORS{end+1}=DATASTRUCTURE.Names_of_vectors{II};
%         end
%         set(MyHandle.VECTOR_SEL,'string',LIST_OF_VECTORS);set(MyHandle.VECTOR_SEL,'value',1);
%         UserSelections.VECTOR_SEL=[0,0];
%         
%         LIST_OF_SCALARS{1}='Off';
%         for II=1:numel(DATASTRUCTURE.ScalarNames)
%             LIST_OF_SCALARS{end+1}=DATASTRUCTURE.ScalarNames{II};
%         end
%         set(MyHandle.SCALAR_SEL,'string',LIST_OF_SCALARS);set(MyHandle.SCALAR_SEL,'value',1);
%         UserSelections.SCALAR_SEL=[0,0,0];
%         
%         LIST_OF_2DARRAYS{1}='Off';
%         for II=1:DATASTRUCTURE.Number_of_2Darrays
%             LIST_OF_2DARRAYS{end+1}=DATASTRUCTURE.Names_of_2Darrays{II};
%         end
%         set(MyHandle.IMAGE_SEL,'string',LIST_OF_2DARRAYS);set(MyHandle.IMAGE_SEL,'value',1);
%         UserSelections.IMAGE_SEL=[0,0];
%         
        
%         if(SynchMode)
%             % Do something when initialized in synch mode
%             % like hiding PID delay boxes
%         else
%             % Do something when initialized in non-synch mode
%             % like showing PID delay boxes
%         end
%         set(MyHandle.Requested,'userdata',UserSelections);
    end
else % GUI IS RUN in update mode, not initialization
    
    %reads all the UserSelections at once
    UserSelections=get(MyHandle.Requested,'userdata');
    
    if(UserSelections.ON==1)
       if(UserSelections.Status)
          UserSelections.ON=NaN; 
       else
          UserSelections.Status=1;
          UserSelections.ON=NaN; 
          UserSelections.TimeTurnedOn=now;
          set(MyHandle.Status,'backgroundcolor',[0,1,0]);
          set(MyHandle.Status,'String','ON');
       end
      set(MyHandle.TurnON,'backgroundcolor',[.7,.7,.7]);
      set(MyHandle.TurnOFF,'backgroundcolor',[.7,.7,.7]);  
    elseif(UserSelections.ON==0)
        if(~UserSelections.Status)
            UserSelections.ON=NaN; 
        else
            UserSelections.ON=NaN; 
            UserSelections.Status=0;
            UserSelections.TimeTurnedOn=NaN;
            set(MyHandle.Status,'backgroundcolor',[1,1,0]);
            set(MyHandle.Status,'String','OFF');
        end
        set(MyHandle.TurnON,'backgroundcolor',[.7,.7,.7]);
        set(MyHandle.TurnOFF,'backgroundcolor',[.7,.7,.7]);
    end
    
    if(UserSelections.ForceSaving)
        UserSelections.ForceSaving=0;
        set(MyHandle.ForceSaving,'backgroundcolor',[.7,.7,.7]);
        
           CurrentTime=clock; 
           CurrentYearString=num2str(CurrentTime(1),'%.4d');
           CurrentMonthString=num2str(CurrentTime(2),'%.2d');
           CurrentDieiString=num2str(CurrentTime(3),'%.2d');
           CurrentTempo1String=num2str(CurrentTime(4),'%.2d');
           CurrentTempo2String=num2str(CurrentTime(5),'%.2d');
           CurrentTempo3String=num2str(floor(CurrentTime(6)),'%.2d');
           CurrentTempo4String=num2str(round((CurrentTime(6)-floor(CurrentTime(6)))*1000),'%.3d');
           CurrentTimeString=[CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString,'--',CurrentTempo1String,'-',CurrentTempo2String,'-',CurrentTempo3String,'-',CurrentTempo4String]; 
           filename=['OnlineMonitor_',UserSelections.FN,'_',CurrentTimeString];
           targetdir=['/u1/lcls/matlab/data/',CurrentYearString,'/',CurrentYearString,'-',CurrentMonthString,'/',CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString];
           
           if(isdir(targetdir)) 
               save([targetdir,'/',filename],'DATASTRUCTURE','PulseIDMatrix','TSorPID','AbsoluteEventCounterMatrix','ProfileBuffer','SynchProfilePVs','NotSynchProfilePVs','AdditionalNonStandardPVsMatrices','FiltersBuffer','ScalarsBufferORbsa','ScanBuffer','AcqBufCycORAbsCountProfiles','AcquisitionTotalSynchronousEvents','AcquisitionBufferNextWrittenElement','AcquisitionBufferLastWrittenElement','-v7.3');               
           else
               mkdir(targetdir);
               save([targetdir,'/',filename],'DATASTRUCTURE','PulseIDMatrix','TSorPID','AbsoluteEventCounterMatrix','ProfileBuffer','SynchProfilePVs','NotSynchProfilePVs','AdditionalNonStandardPVsMatrices','FiltersBuffer','ScalarsBufferORbsa','ScanBuffer','AcqBufCycORAbsCountProfiles','AcquisitionTotalSynchronousEvents','AcquisitionBufferNextWrittenElement','AcquisitionBufferLastWrittenElement','-v7.3'); 
           end
           
        
        if(UserSelections.ON==1)
            UserSelections.TimeTurnedOn=now;
        end     
        
    end
    
    currenttime=now;
    elapsedtime=(currenttime-UserSelections.TimeTurnedOn)/UserSelections.OneSecond;
    remainingtime=UserSelections.TimeOut-elapsedtime;
    set(MyHandle.RemainingTime,'string',num2str(remainingtime));
    if((remainingtime<0) && UserSelections.Status)
        
        
        CurrentTime=clock; 
           CurrentYearString=num2str(CurrentTime(1),'%.4d');
           CurrentMonthString=num2str(CurrentTime(2),'%.2d');
           CurrentDieiString=num2str(CurrentTime(3),'%.2d');
           CurrentTempo1String=num2str(CurrentTime(4),'%.2d');
           CurrentTempo2String=num2str(CurrentTime(5),'%.2d');
           CurrentTempo3String=num2str(floor(CurrentTime(6)),'%.2d');
           CurrentTempo4String=num2str(round((CurrentTime(6)-floor(CurrentTime(6)))*1000),'%.3d');
           CurrentTimeString=[CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString,'--',CurrentTempo1String,'-',CurrentTempo2String,'-',CurrentTempo3String,'-',CurrentTempo4String]; 
           filename=['OnlineMonitor_',UserSelections.FN,'_',CurrentTimeString];
           targetdir=['/u1/lcls/matlab/data/',CurrentYearString,'/',CurrentYearString,'-',CurrentMonthString,'/',CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString];
           
           if(isdir(targetdir)) 
               save([targetdir,'/',filename],'DATASTRUCTURE','PulseIDMatrix','TSorPID','AbsoluteEventCounterMatrix','ProfileBuffer','SynchProfilePVs','NotSynchProfilePVs','AdditionalNonStandardPVsMatrices','FiltersBuffer','ScalarsBufferORbsa','ScanBuffer','AcqBufCycORAbsCountProfiles','AcquisitionTotalSynchronousEvents','AcquisitionBufferNextWrittenElement','AcquisitionBufferLastWrittenElement','-v7.3'); 
           else
               mkdir(targetdir);
               save([targetdir,'/',filename],'DATASTRUCTURE','PulseIDMatrix','TSorPID','AbsoluteEventCounterMatrix','ProfileBuffer','SynchProfilePVs','NotSynchProfilePVs','AdditionalNonStandardPVsMatrices','FiltersBuffer','ScalarsBufferORbsa','ScanBuffer','AcqBufCycORAbsCountProfiles','AcquisitionTotalSynchronousEvents','AcquisitionBufferNextWrittenElement','AcquisitionBufferLastWrittenElement','-v7.3'); 
           end
        
        UserSelections.TimeTurnedOn=now;
        
    end
    
    set(MyHandle.Requested,'userdata',UserSelections);  
    
end
