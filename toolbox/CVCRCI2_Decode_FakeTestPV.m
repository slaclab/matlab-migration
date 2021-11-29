function [Data,PulseID,TimeStamp]=Decode_FakeTestPV(FakeTestPVata,Initialize)
PulseID=[];TimeStamp=[];
if(Initialize) %gives the amount/type/names of Output data from the function when actual data is processed
    Data.NumberOfScalars=3;
    Data.ScalarNames={'Test Scalar 1','Test Scalar 2','Test Scalar 3'};

    Data.NumberOfVectors=2;
    Data.VectorNames={'Test Vector 1','Test Vector 2'};
    Data.VectorSizes=[100,123]; %size 1, size 2 ... as many as the number of vectors
    
    
    Data.NumberOfArray2D=2;
    Data.Array2DNames={'Test Matrix 1','Test Matrix 2'};
    Data.Array2DSizes=[20,20;25,20]; %size 1 ; size 2 ; size 3...
    
    Data.NumberOfPulseID=0;
    Data.NumberOfTimeStamps=0;

    Data.ReadOnceIn=1;
    

    
    
else %actually decode the input data, giving scalar, vectors, 2d arrays along with their matrices
    Elements=size(FakeTestPVata);
    Scalars=FakeTestPVata(1:3,:);
    Vector1=FakeTestPVata(4:103,:);
    Vector2=FakeTestPVata(104:226,:);
    Matrix1=FakeTestPVata(227:626,:);
    Matrix2=FakeTestPVata(627:1026,:);
     
    Data.Scalars = Scalars;
    Data.Vectors{1} = Vector1;
    Data.Vectors{2} = Vector2;
    Data.Array2D{1} = reshape(Matrix1,[20,20,Elements/1026]);
    Data.Array2D{2} = reshape(Matrix2,[25,20,Elements/1026]);
end