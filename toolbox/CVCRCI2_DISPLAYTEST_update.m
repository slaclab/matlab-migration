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
        MyPersistentData=0;
        
        %Populates the list of scalars, vectors, images and filters and
        %stores the new Data structure in the gui itself as "most
        %up-to-date"
        
        %Stores current (new) data structure
        set(MyHandle.StoredDataStructure,'userdata',DATASTRUCTURE);
        
        %Reads the current user selection, initialization may override some
        %of those
        UserSelections=get(MyHandle.Requested,'userdata');
        
        %Sets the Filters pop-up-menu with the filter list and defaults it
        %as "off"
        LIST_OF_FILTERS{1}='Filter OFF';
        for II=1:DATASTRUCTURE.FilterNumber
            LIST_OF_FILTERS{end+1}=DATASTRUCTURE.FilterNames{II};
        end
        set(MyHandle.Filter,'string',LIST_OF_FILTERS);
        UserSelections.FILTERS=0; set(MyHandle.Filter,'value',1);
        
        %Sets the Vectors pop-up-menu with the filter list and defaults it
        %as "off"
        LIST_OF_VECTORS{1}='Off';
        for II=1:DATASTRUCTURE.Number_of_vectors
            LIST_OF_VECTORS{end+1}=DATASTRUCTURE.Names_of_vectors{II};
        end
        set(MyHandle.VECTOR_SEL,'string',LIST_OF_VECTORS);set(MyHandle.VECTOR_SEL,'value',1);
        UserSelections.VECTOR_SEL=[0,0];
        
        LIST_OF_SCALARS{1}='Off';
        for II=1:numel(DATASTRUCTURE.ScalarNames)
            LIST_OF_SCALARS{end+1}=DATASTRUCTURE.ScalarNames{II};
        end
        set(MyHandle.SCALAR_SEL,'string',LIST_OF_SCALARS);set(MyHandle.SCALAR_SEL,'value',1);
        UserSelections.SCALAR_SEL=[0,0,0];
        
        LIST_OF_2DARRAYS{1}='Off';
        for II=1:DATASTRUCTURE.Number_of_2Darrays
            LIST_OF_2DARRAYS{end+1}=DATASTRUCTURE.Names_of_2Darrays{II};
        end
        set(MyHandle.IMAGE_SEL,'string',LIST_OF_2DARRAYS);set(MyHandle.IMAGE_SEL,'value',1);
        UserSelections.IMAGE_SEL=[0,0];
        
        
        if(SynchMode)
            % Do something when initialized in synch mode
            % like hiding PID delay boxes
        else
            % Do something when initialized in non-synch mode
            % like showing PID delay boxes
        end
        set(MyHandle.Requested,'userdata',UserSelections);
    end
else % GUI IS RUN in update mode, not initialization
    
    %reads all the UserSelections at once
    UserSelections=get(MyHandle.Requested,'userdata');
    
    if(SynchMode==1) %disp('update in synch mode')
        
        set(MyHandle.SynchMode,'string','SYNCH MODE = 1');
        
        if(UserSelections.FILTERS)
            OK_IDs=FiltersBuffer{UserSelections.FILTERS+1};
            AF=get(MyHandle.Filter,'string');
            AI=get(MyHandle.Filter,'value');
            
            filterstring=['filter ' ,AF{AI}, ' selected. events selected in OK_IDs'];
        else
            OK_IDs=FiltersBuffer{1};
            filterstring=['no filter selected. all VALID events selected in OK_IDs'];
        end
        
        set(MyHandle.FILTER_INFO,'string',filterstring);
        
        if(~UserSelections.VECTOR_SEL(1))
            vectorstring=['no vector selected']; 
        else
            AF=get(MyHandle.VECTOR_SEL,'string');
            AI=get(MyHandle.VECTOR_SEL,'value');
            vectorstring=['vector ',AF{AI},' selected']; 
            [SA,SB]=size(ProfileBuffer{UserSelections.VECTOR_SEL(2)});
            vectorstring=[vectorstring,' unfiltered size=[',num2str(SA) ,',',num2str(SB),']'];
            vectorstring=[vectorstring,' data in: ProfileBuffer{UserSelections.VECTOR_SEL(2)}'];            
        end
        
        set(MyHandle.VECTOR_INFO,'string',vectorstring);
        AF=get(MyHandle.SCALAR_SEL,'string');
        AI=get(MyHandle.SCALAR_SEL,'value');
            
        switch(UserSelections.SCALAR_SEL(1))
            case 0
                scalarstring=['no scalar selected']; 
            case 1
                DATI_Y=SynchProfilePVs(OK_IDs,UserSelections.SCALAR_SEL(3));
                scalarstring=['scalar selected ',AF{AI},' filt data in: SynchProfilePVs(OK_IDs,UserSelections.SCALAR_SEL(3))']; 
            case 2
                DATI_Y=AdditionalNonStandardPVsMatrices{UserSelections.SCALAR_SEL(2)}(OK_IDs,UserSelections.SCALAR_SEL(3));
                scalarstring=['scalar selected ',AF{AI},' filt data in: AdditionalNonStandardPVsMatrices{UserSelections.SCALAR_SEL(2)}(OK_IDs,UserSelections.SCALAR_SEL(3))']; 
            case 3
                DATI_Y=NotSynchProfilePVs(OK_IDs,UserSelections.SCALAR_SEL(3));
                scalarstring=['scalar selected ',AF{AI},' filt data in: NotSynchProfilePVs(OK_IDs,UserSelections.SCALAR_SEL(3))']; 
            case 4
                DATI_Y=ScalarsBufferORbsa(OK_IDs,UserSelections.SCALAR_SEL(3));
                scalarstring=['scalar selected ',AF{AI},' filt data in: ScalarsBufferORbsa(OK_IDs,UserSelections.SCALAR_SEL(3))']; 

            case 5
                DATI_Y= PulseIDMatrix(OK_IDs);
                scalarstring=['scalar selected ',AF{AI},' filt data in: PulseIDMatrix(OK_IDs)']; 

            case 6
                DATI_Y= TSorPID(OK_IDs);
                scalarstring=['scalar selected ',AF{AI},' filt data in: TSorPID(OK_IDs)']; 

            case 7
                DATI_Y= AbsoluteEventCounterMatrix(OK_IDs);
                scalarstring=['scalar selected ',AF{AI},' filt data in: AbsoluteEventCounterMatrix(OK_IDs)']; 

            case 8
                DATI_Y= ScanBuffer(OK_IDs,UserSelections.SCALAR_SEL(3));
                scalarstring=['scalar selected ',AF{AI},' filt data in: ScanBuffer(OK_IDs,UserSelections.SCALAR_SEL(3))']; 
        end
        
        set(MyHandle.SCALAR_INFO,'string',scalarstring);
        
        if(~UserSelections.IMAGE_SEL(1))
            imagestring=['no image selected']; 
        else
            AF=get(MyHandle.IMAGE_SEL,'string');
            AI=get(MyHandle.IMAGE_SEL,'value');
            imagestring=['Image ',AF{AI},' selected']; 
            [SA,SB,SC]=size(ProfileBuffer{UserSelections.IMAGE_SEL(2)});
            imagestring=[imagestring,' unfiltered size=[',num2str(SA) ,',',num2str(SB),',',num2str(SC),']'];
            imagestring=[imagestring,' data in: ProfileBuffer{UserSelections.IMAGE_SEL(2)}'];            
        end
        
        set(MyHandle.IMAGE_INFO,'string',imagestring);
        
    else % SynchMode==0 case 
        
        
        %%%%%%%%%%%%%%%%%%%%
        % WORK IN PROGRESS %
        %%%%%%%%%%%%%%%%%%%%
        %                  %
        
%         set(MyHandle.SynchMode,'string','SYNCH MODE = 0');
%         set(MyHandle.FILTER_INFO,'string','Filtering Not Available in SYNCH MODE = 0');
%         
%         [SA,SB]=size(ProfileBuffer{UserSelections.V_SEL(2)});
%         V_PID=mod(TSorPID{UserSelections.V_SEL(2)} + UserSelections.X_PID_DELAY ,144000);
%         V_ABS=AcqBufCycORAbsCountProfiles{UserSelections.V_SEL(2)};
%         
%         switch(UserSelections.SCALAR_SEL(1))
%             case 0
%                 return
%             case 1
%                 if(ScalarsBufferORbsa)
%                     DATI_Y=SynchProfilePVs(:,UserSelections.SCALAR_SEL(3));
%                     PID_Y=mod((PulseIDMatrix{1}+ 0),144000);
%                     ABS_Y=AbsoluteEventCounterMatrix{1};
%                 else
%                     DATI_Y=SynchProfilePVs(:,UserSelections.SCALAR_SEL(3));
%                     PID_Y=mod((PulseIDMatrix{1}(:,UserSelections.SCALAR_SEL(3))+ 0),144000);
%                     ABS_Y=AbsoluteEventCounterMatrix{1}(:,UserSelections.SCALAR_SEL(3));
%                 end
%             case 2
%                 DATI_Y=AdditionalNonStandardPVsMatrices{UserSelections.SCALAR_SEL(2)}(:,UserSelections.SCALAR_SEL(3));
%                 PID_Y=mod((PulseIDMatrix{2}(:,UserSelections.SCALAR_SEL(3))+ 0),144000);
%                 ABS_Y=AbsoluteEventCounterMatrix{2}(:,UserSelections.SCALAR_SEL(3));
%             case 3
%                 DATI_Y=NotSynchProfilePVs(:,UserSelections.SCALAR_SEL(3));
%                 PID_Y=mod((PulseIDMatrix{3}(:,UserSelections.SCALAR_SEL(3))+ 0),144000);
%                 ABS_Y=AbsoluteEventCounterMatrix{3}(:,UserSelections.SCALAR_SEL(3));
%             case 4
%                 return
%             case 5
%                 return
%             case 6
%                 return
%             case 7
%                 return
%             case 8
%                 DATI_Y= ScanBuffer(:,UserSelections.SCALAR_SEL(3));
%                 PID_Y=mod((PulseIDMatrix{1}(8,UserSelections.SCALAR_SEL(3))+ 0),144000);
%                 ABS_Y=AbsoluteEventCounterMatrix{8}(:,UserSelections.SCALAR_SEL(3));
%         end
%         
%         [~,DY,DV]=intersect(PID_Y,V_PID);
%         
%         
%         if(UserSelections.ShowAVGLASTON)
%             if(length(DV)<=UserSelections.HMAVG)
%                 %TUTTI
%             else
%                 [~,IB]=sort(V_ABS(DV),'descend');
%                 V_PID=V_PID(DV(IB(1:UserSelections.HMAVG)));
%             end
%             [~,DY,DV]=intersect(PID_Y,V_PID);
%         else
%             %UltimiN = find(OK_IDs);
%         end
%         
%         DATI_Y=DATI_Y(DY);
%         
%         if(~isempty(UserSelections.calib))
%             ASSE=((1:SB)-SB/2)*UserSelections.calib;
%             if(~isempty(UserSelections.center))
%                 ASSE=ASSE+UserSelections.center ;
%             end
%         else
%             ASSE=1:SB;
%         end
%         
%         if(UserSelections.TypeOfPlot==1) %L-Plot.
%             MY(1) = min(DATI_Y); MY(2) =max(DATI_Y);
%             if(~UserSelections.b_autoY)
%                 if(~isnan(UserSelections.lim_y1)), MY(1)=UserSelections.lim_y1; end
%                 if(~isnan(UserSelections.lim_y2)), MY(2)=UserSelections.lim_y2; end
%                 %xlim(MyHandle.axes1,CurrLimY);
%             end
%             if(any(isnan(MY)) || MY(1)==MY(2))
%                 return
%             end
%             Matrice=zeros(UserSelections.binsy+1,SB);
%             INDICI=round(UserSelections.binsy*(DATI_Y-MY(1))/(MY(2)-MY(1)) )+1;
%             for XX=1:UserSelections.binsy
%                 Matrice(XX,:)=mean(ProfileBuffer{UserSelections.V_SEL(2)}(DV(INDICI==XX),:),1);
%             end
%             hold(MyHandle.axes1,'off');
%             imagesc(ASSE,MY,Matrice,'parent',MyHandle.axes1);
%             set(MyHandle.axes1,'Ydir','normal');
%             YLIM=ylim(MyHandle.axes1);
%             colorbar('peer',MyHandle.axes1);
%             [N,X] = hist(DATI_Y((DATI_Y>=MY(1)) | (DATI_Y<=MY(2)) ),UserSelections.binsy+1);
%             barh(MyHandle.axes4,X,N);
%             
%             ylim(MyHandle.axes4,YLIM);
%         elseif(UserSelections.TypeOfPlot==2)
%             
%             if(any(isnan(UserSelections.PartitionWidth)) || any(isnan(UserSelections.PartitionPos)))
%                 return
%             end
%             if(isscalar(UserSelections.PartitionWidth))
%                 PW=ones(size(UserSelections.PartitionPos))*UserSelections.PartitionWidth;
%                 PP=UserSelections.PartitionPos;
%             elseif(isscalar(UserSelections.PartitionPos))
%                 PP=ones(size(UserSelections.PartitionWidth))*UserSelections.PartitionPos;
%                 PW=UserSelections.PartitionWidth;
%             else
%                 if(length(UserSelections.PartitionWidth)~=length(UserSelections.PartitionPos))
%                     return
%                 else
%                     PW=UserSelections.PartitionWidth;
%                     PP=UserSelections.PartitionPos;
%                 end
%             end
%             ListString={};
%             Legend={};
%             %save TEMP -v7.3
%             for TT=1:min(length(PW),20);
%                 KE=find(abs(DATI_Y-PP(TT)) <= PW(TT)/2);
%                 if(~isempty(KE))
%                     MEDIA=mean(ProfileBuffer{UserSelections.V_SEL(2)}(DV(KE),:),1);
%                     ListString{end+1} = ['P: ',num2str(PP(TT)- PW(TT)/2 ),' , ' num2str(PP(TT)+ PW(TT)/2 )];
%                     ListString{end+1} = ['Events = ',num2str(length(KE))];
%                     ListString{end+1} = ['AVG S. = ',num2str(mean(DATI_Y(KE)))];
%                     Legend{end+1}=ListString{end};
%                     if(UserSelections.MomentsON)
%                         ME=ASSE*MEDIA.'/sum(MEDIA);
%                         ST=sqrt(ASSE.^2*MEDIA.'/sum(MEDIA) - ME^2);
%                         ListString{end+1} = ['1st M. = ',num2str(ME)];
%                         ListString{end+1} = ['std = ',num2str(ST)];
%                     end
%                     if(UserSelections.FWHMON)
%                         [MA,MB]=max(MEDIA);
%                         LP=find(MEDIA>MA/2,1,'first');
%                         MP=find(MEDIA>MA/2,1,'last');
%                         if((LP==1) || (MP==SB))
%                             FWHM=NaN;
%                         else
%                             if(isempty(UserSelections.calib))
%                                 FWHM=MP-LP+1;
%                             else
%                                 FWHM=(MP-LP+1)*UserSelections.calib;
%                             end
%                         end
%                         ListString{end+1} = ['FWHM = ',num2str(FWHM)];
%                     end
%                     if(UserSelections.PEAKON)
%                         [MA,MB]=max(MEDIA);
%                         ListString{end+1} = ['Peak = ',num2str(MA)];
%                         ListString{end+1} = ['Peak Pos = ',num2str(ASSE(MB))];
%                     end
%                     ListString{end+1}='';
%                     plot(MyHandle.axes1,ASSE,MEDIA,'Color',COLORMATRIX(TT,:));
%                 end
%             end
%             set(MyHandle.InfoData,'string',ListString);
%             legend(MyHandle.axes1,Legend);
%         end
%         
%         CurrLimX=xlim(MyHandle.axes1);
%         if(~UserSelections.b_autoX)
%             if(~isnan(UserSelections.lim_x1)), CurrLimX(1)=UserSelections.lim_x1; end
%             if(~isnan(UserSelections.lim_x2)), CurrLimX(2)=UserSelections.lim_x2; end
%             xlim(MyHandle.axes1,CurrLimX);
%         end
%         CurrLimY=ylim(MyHandle.axes1);
%         if(~UserSelections.b_autoY)
%             if(~isnan(UserSelections.lim_y1)), CurrLimY(1)=UserSelections.lim_y1; end
%             if(~isnan(UserSelections.lim_y2)), CurrLimY(2)=UserSelections.lim_y2; end
%             ylim(MyHandle.axes1,CurrLimY);
%         end
%         
        
          
    end
    
    if(UserSelections.SaveOnLocalFolder)
       UserSelections.SaveOnLocalFolder=0;
       save TestAnalysisTemporarySavedFile -v7.3 
       set(MyHandle.Requested,'userdata',UserSelections);
    end
    
    
end
