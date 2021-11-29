function [Data]=Decode_CBPOL(CB_POLData,Initialize,TimeStampsOrPulseIDs)
PulseID=[];TimeStamp=[];
if(Initialize) %gives the amount/type/names of Output data from the function when actual data is processed
    Data.NumberOfScalars=4;
    Data.ScalarNames={'Degree_Linear_Polarizaton','Polarization_Angle','Degree_Lin_Pol_Error','Pol_Angle_Error'};

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
    Elements=numel(CB_POLData);
    TR=transpose(CB_POLData);
    TR=reshape(TR(:),[5,Elements/5]);
    [KeepOut,DoveKeepOut]=unique(TR(1,:),'stable');
    DoveKeepOut=DoveKeepOut(~isnan(KeepOut));
    Data.Scalars=TR(2:5,DoveKeepOut);
    Data.Vectors=[];
    Data.Array2D=[];
    Data.PulseID=TR(1,DoveKeepOut);
    Data.TimeStamp=[];
    Data.NumberOfScalars=4;
    Data.NumberOfVectors=0;
    Data.NumberOfArray2D=0;
    save TEMPCOOKIEBOX -v7.3
end


