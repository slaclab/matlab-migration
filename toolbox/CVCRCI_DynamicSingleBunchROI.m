function [Data,PulseID,TimeStamp]=CVCRCI_DynamicSingleBunchROI(InputData,Options,Profile,RawTimeStamp,Initialize)
PulseID=[];TimeStamp=[];
ConfigurationPath='/u1/lcls/matlab/VOM_Configs/BackgroundAndBaseline';
persistent INITVARS

if(Initialize) %gives the amount/type/names of Output data from the function when actual data is processed
    CROP_START=str2double(Options{3,2}); CROP_END=str2double(Options{4,2});
    if(isnan(CROP_START))
        CROP_START=1;
    end
    if(isnan(CROP_END))
        CROP_END=length(InputData);
    end
    Data.ScalarNames={'X Start','X End','Y Start','Y End'};
    Data.VectorNames={Options{4,2},Options{5,2}};
    if(strcmpi(Options{1,2},'Auto'))
        Data.Array2DNames={[Profile.PVName,'-ROI']};
    else
        Data.Array2DNames={Options{1,2}};
    end
    Data.NumberOfScalars=numel(Data.ScalarNames);
    Data.NumberOfVectors=numel(Data.VectorNames);
    Data.NumberOfArray2D=numel(Data.Array2DNames);
    XSIZE=str2double(Options{2,2}); YSIZE=str2double(Options{3,2});
    Data.VectorSizes=[XSIZE, YSIZE];
    Data.Array2DSizes=[XSIZE, YSIZE];
    %Data.Array2DSizes=SIZE; %size 1 ; size 2 ; size 3...
    Data.UseExternalTimeStamps=0; %If 0, uses the pulse ID calculated during processing. If 1, uses the external one
    Data.AdditionalInformation={'Add. Info','NONE'};
    if(Initialize==2) %Make up BASELINE loading File.
        
    end
else %actually decode the input data, giving scalar, vectors, 2d arrays along with their matrices
    Data.PulseID = bitand(uint32(imag(RawTimeStamp)),hex2dec('1FFFF'));
    Data.TimeStamps=RawTimeStamp;
    [Data.PulseID,WherePID]=unique(Data.PulseID,'stable');
    Remove=Data.PulseID==0;
    Data.PulseID(Remove)=[]; WherePID(Remove)=[];
    Data.NumberOfScalars=4;
    Data.NumberOfVectors=2;
    Data.NumberOfArray2D=1;
    Data.TimeStamps=Data.TimeStamps(WherePID);
    if(isempty(INITVARS))
        INITVARS.XSIZE=str2double(Options{2,2}); INITVARS.YSIZE=str2double(Options{3,2});
        INITVARS.XSIZE_=str2double(Options{6,2}); INITVARS.YSIZE_=str2double(Options{7,2});
        INITVARS.XCONV=ones(INITVARS.XSIZE,1); INITVARS.YCONV=ones(INITVARS.YSIZE,1);
        INITVARS.XAREA=(1:INITVARS.XSIZE).'; INITVARS.YAREA=1:INITVARS.YSIZE;
        INITVARS.XROUNDER=round(INITVARS.XSIZE/2); INITVARS.YROUNDER=round(INITVARS.YSIZE/2);
    end
    Data_Found=length(WherePID);
    Data.Scalars=zeros(4,Data_Found);
    Data.Vectors{1}=zeros(Data_Found,INITVARS.XSIZE);%Current
    Data.Vectors{2}=zeros(Data_Found,INITVARS.YSIZE);%Energy
    Data.Array2D{1}=zeros(INITVARS.XSIZE,INITVARS.YSIZE,Data_Found); %XTCAV IMAGE
    for II=1:Data_Found
        if(isempty(Profile.Background))
            Image=reshape(InputData(WherePID(II),:),[INITVARS.XSIZE_,INITVARS.YSIZE_]);
        else
            Image=reshape(InputData(WherePID(II),:)-Profile.Background,[INITVARS.XSIZE_,INITVARS.YSIZE_]);
        end
        Prof1=sum(Image,1);
        [~,MP]=max(conv(Prof1,INITVARS.XCONV,'same'));
        MP=MP-INITVARS.XROUNDER;
        if(MP<=1)
            MP=1;
        elseif(MP>(INITVARS.XSIZE_-INITVARS.XSIZE))
            MP=INITVARS.XSIZE_-INITVARS.XSIZE;
        end
        Barx=Prof1(MP:(MP+INITVARS.XSIZE-1))*INITVARS.XAREA/sum(Prof1(MP:(MP+INITVARS.XSIZE-1)));
        MP=MP+round(Barx)-INITVARS.XROUNDER;
        if(MP<=1)
            MP=1;
        elseif(MP>(INITVARS.XSIZE_-INITVARS.XSIZE))
            MP=INITVARS.XSIZE_-INITVARS.XSIZE;
        end
        Prof2=sum(Image(:,MP:(MP+INITVARS.XSIZE-1)),2);
        [~,MY]=max(conv(Prof2,INITVARS.YCONV,'same'));
        MY=MY-INITVARS.YROUNDER;
        if(MY<=1)
            MY=1;
        elseif(MY>(INITVARS.YSIZE_-INITVARS.YSIZE))
            MY=INITVARS.YSIZE_-INITVARS.YSIZE;
        end
        Bary=INITVARS.YAREA*Prof2(MY:(MY+INITVARS.YSIZE-1))/sum(Prof1(MY:(MY+INITVARS.YSIZE-1)));
        Data.Scalars(:,II)=[MP;(MP+INITVARS.XSIZE-1);MY;(MY+INITVARS.YSIZE-1)];
        Data.Vectors{1}(II,:)=Prof1(MP:(MP+INITVARS.XSIZE-1));
        Data.Vectors{2}(II,:)=Prof2(MY:(MY+INITVARS.YSIZE-1)).';
        Data.Array2D{1}(:,:,II)=Image(MY:(MY+INITVARS.YSIZE-1),MP:(MP+INITVARS.XSIZE-1)).';
    end
end
