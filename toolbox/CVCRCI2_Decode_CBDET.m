function [Data]=Decode_CBDET(CB_DETData,Initialize,TimeStampsOrPulseIDs)
PulseID=[];TimeStamp=[];
if(Initialize) %gives the amount/type/names of Output data from the function when actual data is processed
    Data.NumberOfScalars=16;
    Data.ScalarNames={'Detector 1','Detector 2','Detector 3','Detector 4','Detector 5','Detector 6','Detector 7','Detector 8','Detector 9','Detector 10','Detector 11','Detector 12','Detector 13','Detector 14','Detector 15','Detector 16'};
    
    Data.NumberOfVectors=0;
    Data.VectorNames={''};
    Data.VectorSizes=0; %size 1, size 2 ... as many as the number of vectors
    
    
    Data.NumberOfArray2D=0;
    Data.Array2DNames={''};
    Data.Array2DSizes=[0,0]; %size 1 ; size 2 ; size 3...
    
    Data.NumberOfPulseID=1;
    Data.NumberOfTimeStamps=0;
    
    Data.ReadOnceIn=30;

    
    
else %actually decode the input data, giving scalar, vectors, 2d arrays along with their matrices
    Elements=numel(CB_DETData);
    TR=transpose(CB_DETData);
    TR=reshape(TR(:),[17,Elements/17]);
    [KeepOut,DoveKeepOut]=unique(TR(1,:),'stable');
    DoveKeepOut=DoveKeepOut(~isnan(KeepOut));
    Data.Scalars=TR(2:17,DoveKeepOut);
    Data.Vectors=[];
    Data.Array2D=[];
    Data.PulseID=TR(1,DoveKeepOut);
    Data.TimeStamp=[];
    Data.NumberOfScalars=16;
    Data.NumberOfVectors=0;
    Data.NumberOfArray2D=0;
end


