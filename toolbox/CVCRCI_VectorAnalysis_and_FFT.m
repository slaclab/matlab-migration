function [Data,PulseID,TimeStamp]=CVCRCI_VectorAnalysis_and_FFT(InputData,Options,Profile,RawTimeStamp,Initialize)
PulseID=[];TimeStamp=[];
if(Initialize) %gives the amount/type/names of Output data from the function when actual data is processed
    CROP_START=str2double(Options{2,2}); CROP_END=str2double(Options{3,2});
    if(isnan(CROP_START))
        CROP_START=1;
    end
    if(isnan(CROP_END))
        CROP_END=length(InputData);
    end
    Data.ScalarNames={};
    for TT=4:10
        if(~isempty(str2num(Options{TT,2})))
            Data.ScalarNames{end+1}=Options{TT,1};
        end 
    end
    Data.NumberOfScalars=numel(Data.ScalarNames);
    Data.NumberOfVectors=2;
    Data.VectorNames={Options{1,2},'FFT?'};
    Data.VectorSizes=[CROP_END-CROP_START+1,CROP_END-CROP_START+1];
    Data.NumberOfArray2D=0;
    Data.Array2DNames={''};
    %Data.Array2DSizes=SIZE; %size 1 ; size 2 ; size 3...
    
    Data.UseExternalTimeStamps=0; %If 0, uses the pulse ID calculated during processing. If 1, uses the external one
    Data.AdditionalInformation={'Add. Info','NONE'};
else %actually decode the input data, giving scalar, vectors, 2d arrays along with their matrices
    Data.PulseID = bitand(uint32(imag(RawTimeStamp)),hex2dec('1FFFF'));
    Data.TimeStamps=RawTimeStamp;
    [Data.PulseID,WherePID]=unique(Data.PulseID,'stable');
    Data.NumberOfScalars=0;
    Data.NumberOfVectors=2;
    Data.NumberOfArray2D=0;
    Data.TimeStamps=Data.TimeStamps(WherePID);
    Data.Scalars=[];
    Data.Array2D{1}=[];
    Data.Vectors{1}=[];
    InputData=InputData(WherePID,:);
    CROP_START=str2double(Options{2,2}); CROP_END=str2double(Options{3,2});
    if(isnan(CROP_START))
        CROP_START=1;
    end
    if(isnan(CROP_END))
        CROP_END=size(InputData,2);
    end
    Data.VectorSizes=CROP_END-CROP_START+1;
    if(~isempty(Data.PulseID))
        if(~isempty(Profile.Background))
            Data.Vectors{1}=InputData(:,CROP_START:CROP_END) - ones(length(Data.PulseID),1)*Profile.Background(1,CROP_START:CROP_END);
        else
            Data.Vectors{1}=InputData(:,CROP_START:CROP_END);
        end
        INS=0;
        for TT=4:10
            AREA=str2num(Options{TT,2});
            if(~isempty(AREA))
                INS=INS+1;
                Data.NumberOfScalars=Data.NumberOfScalars+1;
                Data.Scalars(INS,:) = sum(Data.Vectors{1}(:,AREA),2);
            end 
        end
    end
    Data.Vectors{2}=abs(fft(Data.Vectors{1},[],2));
   
end