function [Data]=CVCRCI2_Decode_CXI_Screen_After_CSPAD(IncomingData,Initialize,TimeStampsOrPulseIDs)
PulseID=[];TimeStamp=[];

    NumberOfEventsPerLine=10;
    PrXLen=160;
    PrYLen=40;
    ScalarLength=12;
    PIDID=8;

if(Initialize) %gives the amount/type/names of Output data from the function when actual data is processed
    Data.NumberOfScalars=11;
    Data.ScalarNames={'ebeamL3Energy','ebeamEnergyBC1','ebeamEnergyBC2','GDET_f11','GDET_f12','eventID_time0','eventID_time1','eventID_ticks','eventCode', 'a', 'b'};
    
    Data.NumberOfVectors=2;
    Data.VectorNames={'CXI Screen X Projection','CXI Screen Y Projection'};
    Data.VectorSizes=[PrXLen,PrYLen]; %size 1, size 2 ... as many as the number of vectors
    
    
    Data.NumberOfArray2D=0;
    Data.Array2DNames={''};
    Data.Array2DSizes=[0,0]; %size 1 ; size 2 ; size 3...
    
    Data.NumberOfPulseID=1;
    Data.NumberOfTimeStamps=0;
    
    Data.ReadOnceIn=100;

    
    
else %actually decode the input data, giving scalar, vectors, 2d arrays along with their matrices

    FirstPid=IncomingData(:,PIDID);
    [~,UniqueList]=unique(FirstPid,'stable');
    IncomingData=IncomingData(UniqueList,:);
    Data.Vectors{1}=zeros(PrXLen,length(UniqueList)*120);
    Data.Vectors{2}=zeros(PrYLen,length(UniqueList)*120);
    Data.PulseID=zeros(1,length(UniqueList)*120);
    Data.Scalars=zeros(ScalarLength-1,length(UniqueList)*120);
    %save TEMP
    for II=1:length(UniqueList)
      length_batch = PrXLen+PrYLen+ScalarLength;
      ThisLine=reshape(IncomingData(II,1:length_batch * NumberOfEventsPerLine),[length_batch,NumberOfEventsPerLine]);
      Data.Scalars(1:9,((II-1)*NumberOfEventsPerLine+1 ):(II*NumberOfEventsPerLine)) = ThisLine([1:7,9:10],1:NumberOfEventsPerLine);
      Data.PulseID(((II-1)*NumberOfEventsPerLine+1 ):(II*NumberOfEventsPerLine)) = ThisLine(8,1:NumberOfEventsPerLine);
      Data.Vectors{1}(:,((II-1)*NumberOfEventsPerLine+1 ):(II*NumberOfEventsPerLine)) = ThisLine((ScalarLength + 1 ): (ScalarLength + PrXLen),1:NumberOfEventsPerLine);
      Data.Vectors{2}(:,((II-1)*NumberOfEventsPerLine+1 ):(II*NumberOfEventsPerLine)) = ThisLine((ScalarLength + 1 + PrXLen): (ScalarLength + PrXLen + PrYLen),1:NumberOfEventsPerLine);
      Data.Vectors{1}(Data.Vectors{1} > 1e8) = 0;
    end

    Data.TimeStamp=[];
    
    GoodData=find(~isnan(Data.PulseID));
    Data.PulseID=Data.PulseID(GoodData);
    Data.Scalars=Data.Scalars(:,GoodData);
    Data.Vectors{1}=Data.Vectors{1}(:,GoodData).';
    Data.Vectors{2}=Data.Vectors{2}(:,GoodData).';
    
    Data.Array2D=[];
    
    Data.NumberOfScalars=9;
    Data.NumberOfVectors=2;
    Data.NumberOfArray2D=0;
end


%CXI:VARS:FLOAT:01