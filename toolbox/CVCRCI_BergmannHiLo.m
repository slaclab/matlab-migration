function [Data,PulseID,TimeStamp]=CVCRCI_BergmannHiLo(InputData,Options,Profile,RawTimeStamp,Initialize)
PulseID=[];TimeStamp=[];
if(Initialize) %gives the amount/type/names of Output data from the function when actual data is processed

    Data.ScalarNames={Options{1,2},Options{2,2}};
    Data.VectorNames={''};
    Data.Array2DNames={''};
    Data.VectorNames={'Raw Cropped','Pulse 1','Pulse 2','Pulse 1+2'};
    Data.NumberOfArray2D=0;
    Data.NumberOfScalars=2;
    Data.NumberOfVectors=0;
    Data.UseExternalTimeStamps=0; %If 0, uses the pulse ID calculated during processing. If 1, uses the external one
    Data.AdditionalInformation={'Add. Info','NONE'}; 
else
    Data.PulseID = InputData(3,:);
    [Data.PulseID,WherePID]=unique(Data.PulseID,'stable');
    Data.TimeStamps=exp(InputData(1,WherePID) + 1i*InputData(2,WherePID));
%     Remove=Data.PulseID==0;
%     Data.PulseID(Remove)=[]; WherePID(Remove)=[];
    Data.NumberOfScalars=2;
    Data.NumberOfVectors=0;
    Data.NumberOfArray2D=0;
    Data.Scalars=NaN*ones(2,1);
    Data.Scalars=InputData(5,WherePID);
    Data.Scalars=InputData(4,WherePID);
    Data.Vectors={};
    Data.Array2D={};
end