function [Data,PulseID,TimeStamp]=CVCRCI_Crop_Integrate_2D(InputData,Options,Profile,RawTimeStamp,Initialize)
PulseID=[];TimeStamp=[];
if(Initialize) %gives the amount/type/names of Output data from the function when actual data is processed
    ReshapeSize=str2num(Options{2,2});
    CROP_XSTART=str2double(Options{3,2}); CROP_XEND=str2double(Options{4,2});
    CROP_YSTART=str2double(Options{5,2}); CROP_YEND=str2double(Options{6,2});
    if(isnan(CROP_XSTART))
        CROP_XSTART=1;
    end
    if(isnan(CROP_XEND))
        CROP_XEND=ReshapeSize(1);
    end
    if(isnan(CROP_YSTART))
        CROP_YSTART=1;
    end
    if(isnan(CROP_YEND))
        CROP_YEND=ReshapeSize(2);
    end
    Data.ScalarNames={};
    if(~isempty(Options{9,2}))
         Data.ScalarNames{end+1}=Options{9,1};
    end 
    if(~isempty(Options{10,2}))
         Data.ScalarNames{end+1}='ROI X START';
         Data.ScalarNames{end+1}='ROI X END';
         Data.ScalarNames{end+1}='ROI Y START';
         Data.ScalarNames{end+1}='ROI Y END';
    end 
    Data.NumberOfScalars=numel(Data.ScalarNames);
    Data.VectorNames={};
    Data.VectorSizes=[];
    if(~isempty(Options{7,2}))
        Data.VectorNames{end+1}=Options{7,1};
        Data.VectorSizes(end+1)=CROP_XEND-CROP_XSTART+1;
    end
    if(~isempty(Options{8,2}))
        Data.VectorNames{end+1}=Options{8,1};
        Data.VectorSizes(end+1)=CROP_YEND-CROP_YSTART+1;
        Data.Array2DSizes(1,2)=CROP_YEND-CROP_YSTART+1;
    end
    Data.NumberOfVectors=numel(Data.VectorNames);
    Data.Array2DNames={};
    if(~isempty(Options{1,2}))
        Data.Array2DNames{1}=Options{1,2};
        Data.Array2DSizes=[CROP_XEND-CROP_XSTART+1 ,CROP_YEND-CROP_YSTART+1] ;
    end
    Data.NumberOfArray2D=numel(Data.Array2DNames);
    %Data.Array2DSizes=SIZE; %size 1 ; size 2 ; size 3...
    
    Data.UseExternalTimeStamps=0; %If 0, uses the pulse ID calculated during processing. If 1, uses the external one
    Data.AdditionalInformation={'Add. Info','NONE'};
else %actually decode the input data, giving scalar, vectors, 2d arrays along with their matrices
    Data.PulseID = bitand(uint32(imag(RawTimeStamp)),hex2dec('1FFFF'));
    Data.TimeStamps=RawTimeStamp;
    [Data.PulseID,WherePID]=unique(Data.PulseID,'stable');
    Data.TimeStamps=Data.TimeStamps(WherePID);
    Data.NumberOfScalars=0;
    Data.NumberOfVectors=1;
    Data.NumberOfArray2D=0;
    Data.Scalars=[];
    InputData=InputData(WherePID,:);
    ReshapeSize=str2num(Options{2,2});
    CROP_XSTART=str2double(Options{3,2}); CROP_XEND=str2double(Options{4,2});
    CROP_YSTART=str2double(Options{5,2}); CROP_YEND=str2double(Options{6,2});
    if(isnan(CROP_XSTART))
        CROP_XSTART=1;
    end
    if(isnan(CROP_XEND))
        CROP_XEND=ReshapeSize(1);
    end
    if(isnan(CROP_YSTART))
        CROP_YSTART=1;
    end
    if(isnan(CROP_YEND))
        CROP_YEND=ReshapeSize(2);
    end
    ReshapeSize=str2num(Options{2,2});
    TempVariable=permute(reshape(InputData,[length(Data.PulseID),ReshapeSize]),[2,3,1]);
    TempVariable=TempVariable(CROP_XSTART:CROP_XEND,CROP_YSTART:CROP_YEND,:);
    if(~isempty(Profile.Background))
        TempVariable=TempVariable-repmat(Profile.Background(CROP_XSTART:CROP_XEND,CROP_YSTART:CROP_YEND),[1,1,length(Data.PulseID)]);
    end
    if(~isempty(Options{1,2}))
        Data.Array2D{1}=TempVariable;
    else
        Data.Array2D{1}=[];
    end
    if(~isempty(Options{7,2}) && ~isempty(Options{8,2}))
        Data.Vectors{1}=permute(sum(TempVariable,2),[3,1,2]);
        Data.Vectors{2}=permute(sum(TempVariable,1),[3,2,1]);
    elseif(~isempty(Options{7,2}))
        Data.Vectors{1}=permute(sum(TempVariable,2),[3,1,2]);
    elseif(~isempty(Options{8,2}))
        Data.Vectors{1}=permute(sum(TempVariable,1),[3,2,1]);
    else
       Data.Vectors{1}=[];
    end
 
    INS=0;
    if(~isempty(Options{9,2}))
        INS=INS+1;   
        Data.Scalars(INS,:) = permute(sum(sum(TempVariable,2),1),[1,3,2]);
    end
    if(~isempty(Options{10,2}))  
        Data.Scalars(INS+1,:) = CROP_XSTART;
        Data.Scalars(INS+2,:) = CROP_XEND;
        Data.Scalars(INS+3,:) = CROP_YSTART;
        Data.Scalars(INS+4,:) = CROP_YEND;
        INS=INS+4;
    end
    Data.NumberOfScalars=INS;  
end