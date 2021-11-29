function NTS_FullData=CVCRCI5_NonTimeStamped_On_Timestamped(NTS_AcquisitionWritingCycle,NTS_Data,TS_AcquisitionWritingCycle)

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
