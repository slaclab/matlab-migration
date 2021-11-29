if(Init_Vars.KeepPartialEvents)
    for II=1:numel(ProfileBuffer)
       ProfileBuffer{II}=zeros(size(ProfileBuffer{II})); 
    end
    for II=1:numel(ScalarBuffer)
       ScalarBuffer{II}=zeros(size(ScalarBuffer{II})); 
    end
    for II=1:numel(ScalarsBuffer)
       ScalarsBuffer{II}=zeros(size(ScalarsBuffer{II})); 
    end
    NotSynchProfilePVs=zeros(size(NotSynchProfilePVs));
    SynchProfilePVs=zeros(size(SynchProfilePVs));
    
    if(~BSA)
        FullPulseIDMatrix{1}=NaN*ones(size(SynchProfilePVs));
        FullAcquisitionBufferCycle{1}=zeros(1,numel(SynchProfilePVsNames));
        FullAcquisitionBufferNextWrittenElement{1} = ones(1,numel(SynchProfilePVsNames));
        FullAcquisitionBufferLastWrittenElement{1} = ones(1,numel(SynchProfilePVsNames));
        LAST_VALID_PULSE_IDs{1} = -1*ones(1,numel(SynchProfilePVsNames));
        FullAcquisitionTotalSynchronousEvents{1}=zeros(1,numel(SynchProfilePVsNames));
        AcquisitionBufferSpaceLeftThisBuffer{1} = Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{1} + 1;
        AcquisitionTotalSynchronousEvents{1}=zeros(1,numel(SynchProfilePVsNames));
    else
        FullPulseIDMatrix{1}=NaN*ones(Init_Vars.BufferSize,1);   
        FullAcquisitionBufferCycle{1}=0;
        FullAcquisitionBufferNextWrittenElement{1}=1;
        FullAcquisitionBufferLastWrittenElement{1}=1;
        LAST_VALID_PULSE_IDs{1} = -1;
        FullAcquisitionTotalSynchronousEvents{1}=0;
        AcquisitionBufferSpaceLeftThisBuffer{1} = Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{1} + 1;   
        AcquisitionTotalSynchronousEvents{1}=0;
    end
    FullPulseIDMatrix{2}=NaN*ones(Init_Vars.BufferSize,AdditionalNonStandardPVsMatrices);
    FullAcquisitionBufferCycle{2}=zeros(1,AdditionalNonStandardPVsMatrices);
    AcquisitionTotalSynchronousEvents{2}=zeros(1,AdditionalNonStandardPVsMatrices);
    FullAcquisitionBufferNextWrittenElement{2} = ones(1,AdditionalNonStandardPVsMatrices);
    FullAcquisitionBufferLastWrittenElement{2} = ones(1,AdditionalNonStandardPVsMatrices);
    LAST_VALID_PULSE_IDs{2} = -1*ones(1,AdditionalNonStandardPVsMatrices);
    FullAcquisitionTotalSynchronousEvents{2}=zeros(1,AdditionalNonStandardPVsMatrices);
    AcquisitionBufferSpaceLeftThisBuffer{2} = Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{2} + 1;
    
    FullPulseIDMatrix{3}=NaN*ones(Init_Vars.BufferSize,1);
    FullAcquisitionBufferCycle{3}=0;
    AcquisitionTotalSynchronousEvents{3}=0;
    FullAcquisitionBufferNextWrittenElement{3} = 1;
    FullAcquisitionBufferLastWrittenElement{3} = 1;
    LAST_VALID_PULSE_IDs{3} = -1;
    FullAcquisitionTotalSynchronousEvents{3}=0;
    AcquisitionBufferSpaceLeftThisBuffer{3} = Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{3} + 1;
    
    FullPulseIDMatrix{4}=NaN*ones(Init_Vars.BufferSize,1);
    FullAcquisitionBufferCycle{4}=0;
    AcquisitionTotalSynchronousEvents{4}=0;
    FullAcquisitionBufferNextWrittenElement{4} = 1;
    FullAcquisitionBufferLastWrittenElement{4} = 1;
    LAST_VALID_PULSE_IDs{4} = -1;
    FullAcquisitionTotalSynchronousEvents{4}=0;
    AcquisitionBufferSpaceLeftThisBuffer{4} = Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{4} + 1;
    
    FullPulseIDMatrix{5}=NaN*ones(Init_Vars.BufferSize,1);
    FullAcquisitionBufferCycle{5}=0;
    AcquisitionTotalSynchronousEvents{5}=0;
    FullAcquisitionBufferNextWrittenElement{5} = 1;
    FullAcquisitionBufferLastWrittenElement{5} = 1;
    LAST_VALID_PULSE_IDs{5} = -1;
    FullAcquisitionTotalSynchronousEvents{5}=0;
    AcquisitionBufferSpaceLeftThisBuffer{5} = Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{5} + 1;
    
    FullPulseIDMatrix{6}=NaN*ones(Init_Vars.BufferSize,1);
    FullAcquisitionBufferCycle{6}=0;
    AcquisitionTotalSynchronousEvents{6}=0;
    FullAcquisitionBufferNextWrittenElement{6} = 1;
    FullAcquisitionBufferLastWrittenElement{6} = 1;
    LAST_VALID_PULSE_IDs{6} = -1;
    FullAcquisitionTotalSynchronousEvents{6}=0;
    AcquisitionBufferSpaceLeftThisBuffer{6} = Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{6} + 1;
    
    FullPulseIDMatrix{7}=NaN*ones(Init_Vars.BufferSize,1);
    FullAcquisitionBufferCycle{7}=0;
    AcquisitionTotalSynchronousEvents{7}=0;
    FullAcquisitionBufferNextWrittenElement{7} = 1;
    FullAcquisitionBufferLastWrittenElement{7} = 1;
    LAST_VALID_PULSE_IDs{7} = -1;
    FullAcquisitionTotalSynchronousEvents{7}=0;
    AcquisitionBufferSpaceLeftThisBuffer{7} = Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{7} + 1;
    
    FullPulseIDMatrix{8}=NaN*ones(Init_Vars.BufferSize,1);
    FullAcquisitionBufferCycle{8}=0;
    AcquisitionTotalSynchronousEvents{8}=0;
    FullAcquisitionBufferNextWrittenElement{8} = 1;
    FullAcquisitionBufferLastWrittenElement{8} = 1;
    LAST_VALID_PULSE_IDs{8} = -1;
    FullAcquisitionTotalSynchronousEvents{8}=0;
    AcquisitionBufferSpaceLeftThisBuffer{8} = Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElement{8} + 1;

    for TT=1:numel(ProfileBuffer)
        [SA,SB,SC]=size(ProfileBuffer{TT});
        if(SC>1)
            FullPulseIDProfiles{TT}=NaN*ones(1,SC);
        else
            FullPulseIDProfiles{TT}=NaN*ones(1,SA);
        end
        FullAcquisitionBufferCycleProfiles{TT}=0;
        FullAcquisitionBufferNextWrittenElementProfiles{TT} = 1;
        FullAcquisitionBufferLastWrittenElementProfiles{TT} = 1;
        LAST_VALID_PULSE_IDsProfiles{TT} = -1;
        FullAcquisitionTotalSynchronousEventsProfiles{TT}=0;
        AcquisitionBufferSpaceLeftThisBufferProfiles{TT} = Init_Vars.BufferSize - FullAcquisitionBufferNextWrittenElementProfiles{TT} + 1;
    end
    FullTimeStampsMatrix = FullPulseIDMatrix;
    AbsoluteEventCounterMatrix=FullTimeStampsMatrix;
    
    if(Init_Vars.NumberOfProfiles)
        FullTimeStampsProfiles= FullPulseIDProfiles;
        AbsoluteEventCounterProfiles=FullTimeStampsProfiles;
        AcquisitionTotalSynchronousEventsProfiles=FullAcquisitionBufferCycleProfiles;
    end
    
    MAXEVENTS=0;
    
    Filters{1}=zeros(size(Filters{1}));
    
else
    
    PulseIDMatrix = zeros(1,Init_Vars.BufferSize);
    TimeStampsMatrix = zeros(1,Init_Vars.BufferSize);
    AbsoluteEventCounterMatrix = zeros(1,Init_Vars.BufferSize);
    AcquisitionBufferCycle = 0;
    AcquisitionTotalSynchronousEvents=0;
    AcquisitionBufferNextWrittenElement = 1;
    AcquisitionBufferLastWrittenElement = 1;
    AcquisitionBufferSpaceLeftThisBuffer = Init_Vars.BufferSize - AcquisitionBufferNextWrittenElement + 1;
    LAST_VALID_PULSE_ID = -1;
    FiltersBuffer{1}=false(size(FiltersBuffer{1}));
    
    for II=1:numel(ProfileBuffer)
       ProfileBuffer{II}=zeros(size(ProfileBuffer{II})); 
    end
    for II=1:numel(ScalarBuffer)
       ScalarBuffer{II}=zeros(size(ScalarBuffer{II})); 
    end
    for II=1:numel(ScalarsBuffer)
       ScalarsBuffer{II}=zeros(size(ScalarsBuffer{II})); 
    end
    
end