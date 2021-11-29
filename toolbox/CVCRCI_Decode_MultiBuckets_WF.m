function [Data,PulseID,TimeStamp]=CVCRCI_Decode_MultiBuckets_WF(InputData,Options,Profile,RawTimeStamp,Initialize)
PulseID=[];TimeStamp=[]; DefaultBaseline='/u1/lcls/matlab/VOM_Configs/LAST_DecodeMultiBuckets_BASELINE';
persistent BASELINE MULTIBUNCHCONFIG
if(Initialize) %gives the amount/type/names of Output data from the function when actual data is processed
    CROP_START=str2double(Options{1,2}); CROP_END=str2double(Options{2,2});
    if(isnan(CROP_START)), CROP_START=1; end
    if(isnan(CROP_END)), CROP_END=length(InputData); end
    Buckets=str2num(Options{4,2});
    switch length(Buckets)
        case 1
            Data.ScalarNames={'Intensity 1'};
            Data.VectorNames={'Raw Cropped','Pulse 1','Pulse Sum'};
        case 2
            Data.ScalarNames={'Intensity 1','Intensity 2'};
            Data.VectorNames={'Raw Cropped','Pulse 1','Pulse 2','Pulse Sum'};
        case 3
            Data.ScalarNames={'Intensity 1','Intensity 2','Intensity 3'};
            Data.VectorNames={'Raw Cropped','Pulse 1','Pulse 2','Pulse 3','Pulse Sum'};
        case 4
            Data.ScalarNames={'Intensity 1','Intensity 2','Intensity 3','Intensity 4'};
            Data.VectorNames={'Raw Cropped','Pulse 1','Pulse 2','Pulse 3','Pulse 4','Pulse Sum'};
        case 5
            Data.ScalarNames={'Intensity 1','Intensity 2','Intensity 3','Intensity 4','Intensity 5'};
            Data.VectorNames={'Raw Cropped','Pulse 1','Pulse 2','Pulse 3','Pulse 4','Pulse 5','Pulse Sum'};
        case 6
            Data.ScalarNames={'Intensity 1','Intensity 2','Intensity 3','Intensity 4','Intensity 5','Intensity 6'};
            Data.VectorNames={'Raw Cropped','Pulse 1','Pulse 2','Pulse 3','Pulse 4','Pulse 5','Pulse 6','Pulse Sum'};
        case 7
            Data.ScalarNames={'Intensity 1','Intensity 2','Intensity 3','Intensity 4','Intensity 5','Intensity 6','Intensity 7'};
            Data.VectorNames={'Raw Cropped','Pulse 1','Pulse 2','Pulse 3','Pulse 4','Pulse 5','Pulse 6','Pulse 7','Pulse Sum'};
        case 8
            Data.ScalarNames={'Intensity 1','Intensity 2','Intensity 3','Intensity 4','Intensity 5','Intensity 6','Intensity 7','Intensity 8'};
            Data.VectorNames={'Raw Cropped','Pulse 1','Pulse 2','Pulse 3','Pulse 4','Pulse 5','Pulse 6','Pulse 7','Pulse 8','Pulse Sum'};
        otherwise
            Data.VectorNames=cell(2+length(Buckets),1);
            Data.VectorNames{1}='Raw Cropped';
            Data.ScalarNames=cell(length(Buckets),1);
            for II=1:length(length(Buckets)), Data.ScalarNames{II}=['Intensity ',num2str(II)];Data.VectorNames{1+II}=['Pulse ',num2str(II)]; end
            Data.VectorNames{end+1}='Pulse Sum'; 
    end
    Data.NumberOfScalars=numel(Data.ScalarNames);
    Data.NumberOfVectors=numel(Data.VectorNames);
    Data.VectorSizes=repmat(CROP_END-CROP_START+1,[1,Data.NumberOfVectors]);
    Data.NumberOfArray2D=0; Data.Array2DNames={''}; %Data.Array2DSizes=SIZE; %size 1 ; size 2 ; size 3...
    Data.UseExternalTimeStamps=0; %If 0, uses the pulse ID calculated during processing. If 1, uses the external one
    Data.AdditionalInformation={'Add. Info','NONE'};   
    if(Initialize==2) %Make up BASELINE loading File.
        Samples=str2double(Options{10,2});
        TakeDataAgain=~str2double(Options{8,2});
        if(TakeDataAgain)
            D=zeros(size(repmat(InputData,[Samples,1])));
            D(1,:)=lcaGetSmart(Profile.PVName,prod(Profile.size));
            ins=2;
            while(ins<Samples)
                D(ins,:)=lcaGetSmart(Profile.PVName,prod(Profile.size));
                if(any(D(ins,:)~=D(ins-1,:)))
                    ins=ins+1;
%                     D(ins,:)
%                     FTD(151)=0;FTD(301)=0;FTD(451)=0;
%                     D(ins,:)=real(ifft(FTD));
                end
            end
            BASELINE.DatiBaseline=D.';
            BASELINE.DatiBaseline=BASELINE.DatiBaseline(CROP_START:CROP_END,:);
            BASELINE.CROP_START=CROP_START; BASELINE.CROP_END=CROP_END;
            if((BASELINE.CROP_START~=1) || (BASELINE.CROP_END~=length(InputData))), BASELINE.DO_CROP=1; else, BASELINE.DO_CROP=0; end
        else
            load([DefaultBaseline,Options{18,2}],'BASELINE');
        end
        BASELINE.BackgroundArea=str2num(Options{7,2});
        BackgroundUse=2; BASELINE.MaxShifts=str2num(Options{5,2});
        if(str2double(Options{11,2}))
            BASELINE.SignalMultiplier=-1;
        else
            BASELINE.SignalMultiplier=+1;
        end
        BASELINE.RemoveFrequencies=str2num(Options{19,2});
        if(~isempty(BASELINE.RemoveFrequencies))
            for II=1:size(BASELINE.DatiBaseline,2)
                BASELINE.DenoiseBaseline(:,II)=BASELINE.DatiBaseline(:,II)-mean(BASELINE.DatiBaseline(:,II));
                FFT_Line=fft(BASELINE.DenoiseBaseline(:,II));
                FFT_Line(BASELINE.RemoveFrequencies)=0;
                BASELINE.DenoiseBaseline(:,II)=real(ifft(FFT_Line));
            end
        else
            BASELINE.DenoiseBaseline=BASELINE.DatiBaseline;
        end
        BASELINE.TopPerCent=str2num(Options{12,2});
        CircShiftedBaseLine=RealignBaseLineOfTheMax(BASELINE.DenoiseBaseline, BASELINE.BackgroundArea, BASELINE.MaxShifts, BackgroundUse,BASELINE.SignalMultiplier);   
        [BASELINE.Shape,BASELINE.ShapeBackground]=CalculateBaselineShape(CircShiftedBaseLine,BASELINE.TopPerCent,BASELINE.SignalMultiplier,BASELINE.BackgroundArea);
        if(~isempty(BASELINE.RemoveFrequencies))
            FTD=fft(BASELINE.Shape); FTD(BASELINE.RemoveFrequencies)=0;
            BASELINE.Shape=real(ifft(FTD));
        end
        
        if(isempty(MULTIBUNCHCONFIG)) %this load multi-bunch variables such as Vitara state.
            Vitara1S=lcaGetSmart(Options{13,2}); Vitara2S=lcaGetSmart(Options{14,2});
            if(iscell(Vitara1S)), Vitara1S=Vitara1S{1}; end
            if(iscell(Vitara2S)), Vitara2S=Vitara2S{1}; end
            Bucket1=lcaGetSmart(Options{15,2}); Bucket2=lcaGetSmart(Options{16,2});
            BucketDelay=lcaGetSmart(Options{17,2});
            Vitara1S = Vitara1S(1)=='I'; Vitara2S = Vitara2S(1)=='I';
            MULTIBUNCHCONFIG.Vitara1S=Vitara1S;
            MULTIBUNCHCONFIG.Vitara2S=Vitara2S;
            MULTIBUNCHCONFIG.Bucket1=Bucket1;
            MULTIBUNCHCONFIG.Bucket2=Bucket2;
            MULTIBUNCHCONFIG.BucketDelay=BucketDelay;
        end
        [BASELINE.DelayDT, BASELINE.DelayBuckets, BASELINE.DelayNanoSeconds, BASELINE.Shifts]=ComputeDelay(MULTIBUNCHCONFIG,Options);
        [BASELINE.PINV,BASELINE.BSL,BASELINE.FixedBackground,BASELINE.AllCombinations,BASELINE.HalfShiftWindow,BASELINE.FixedSamplesAveraging]=ComputeBaseline(BASELINE,Options);
        if(str2double(Options{6,2}))
            ActiveBunches=[(~MULTIBUNCHCONFIG.Vitara1S) && (round(MULTIBUNCHCONFIG.Bucket1)==MULTIBUNCHCONFIG.Bucket1),(~MULTIBUNCHCONFIG.Vitara2S) && (round(MULTIBUNCHCONFIG.Bucket2)==MULTIBUNCHCONFIG.Bucket2)];
            BASELINE.DecoderID=find(~(pdist2(BASELINE.AllCombinations, ActiveBunches)));
            if(isempty(BASELINE.DecoderID)), BASELINE.DecoderID=1; end
        else
            BASELINE.DecoderID=1;
        end
        save([DefaultBaseline,Options{18,2}],'BASELINE');
        disp(['Initialization Done BASELINE stored in ',DefaultBaseline,Options{18,2}]);
        return   
    end
else %actually decode the input data, giving scalar, vectors, 2d arrays along with their matrices
    if(isempty(BASELINE))
        load([DefaultBaseline,Options{18,2}],'BASELINE');
    end
    if(str2double(Options{6,2}))% AUTOVITARA (reprocesses baseline if shift has changed.)
        Vitara1S=lcaGetSmart(Options{13,2}); Vitara2S=lcaGetSmart(Options{14,2});
        if(iscell(Vitara1S)), Vitara1S=Vitara1S{1}; end
        if(iscell(Vitara2S)), Vitara2S=Vitara2S{1}; end
        Bucket1=lcaGetSmart(Options{15,2}); Bucket2=lcaGetSmart(Options{16,2});
        BucketDelay=lcaGetSmart(Options{17,2});
        Vitara1S = Vitara1S(1)=='I'; Vitara2S = Vitara2S(1)=='I';
        ReprocessBaseline=0;
        if(isempty(MULTIBUNCHCONFIG))
            ReprocessBaseline=1;
            MULTIBUNCHCONFIG.Vitara1S=Vitara1S;
            MULTIBUNCHCONFIG.Vitara2S=Vitara2S;
            MULTIBUNCHCONFIG.Bucket1=Bucket1;
            MULTIBUNCHCONFIG.Bucket2=Bucket2;
            MULTIBUNCHCONFIG.BucketDelay=BucketDelay;
        else
            if(~all([MULTIBUNCHCONFIG.Vitara1S,MULTIBUNCHCONFIG.Vitara2S,MULTIBUNCHCONFIG.Bucket1,MULTIBUNCHCONFIG.Bucket2,MULTIBUNCHCONFIG.BucketDelay] == [Vitara1S,Vitara2S,Bucket1,Bucket2,BucketDelay]))
                ReprocessBaseline=1;
                MULTIBUNCHCONFIG.Vitara1S=Vitara1S;
                MULTIBUNCHCONFIG.Vitara2S=Vitara2S;
                MULTIBUNCHCONFIG.Bucket1=Bucket1;
                MULTIBUNCHCONFIG.Bucket2=Bucket2;
                MULTIBUNCHCONFIG.BucketDelay=BucketDelay;
            end
        end
        ActiveBunches=[(~MULTIBUNCHCONFIG.Vitara1S) && (round(MULTIBUNCHCONFIG.Bucket1)==MULTIBUNCHCONFIG.Bucket1),(~MULTIBUNCHCONFIG.Vitara2S) && (round(MULTIBUNCHCONFIG.Bucket2)==MULTIBUNCHCONFIG.Bucket2)];
        %(~MULTIBUNCHCONFIG.Vitara1S && round(MULTIBUNCHCONFIG.Bucket1)==MULTIBUNCHCONFIG.Bucket1) && (~ MULTIBUNCHCONFIG.Vitara2S && round(MULTIBUNCHCONFIG.Bucket2)==MULTIBUNCHCONFIG.Bucket2) 
        BASELINE.DecoderID=find(~(pdist2(BASELINE.AllCombinations, double(ActiveBunches))));
        if(isempty(BASELINE.DecoderID)), BASELINE.DecoderID=1; end
        if(ReprocessBaseline)
            [BASELINE.DelayDT, BASELINE.DelayBuckets, BASELINE.DelayNanoSeconds, BASELINE.Shifts]=ComputeDelay(MULTIBUNCHCONFIG,Options);
            [BASELINE.PINV,BASELINE.BSL,BASELINE.FixedBackground,BASELINE.AllCombinations,BASELINE.HalfShiftWindow,BASELINE.FixedSamplesAveraging]=ComputeBaseline(BASELINE,Options);
            %save([DefaultBaseline,Options{18,2}],'BASELINE'); Better not to save here. Otherwise multiple instances can try to save same file at once.
            disp('Re-initialization done, vitara conditions changed or lost - not saving a new file anymore.')
            disp(['Used Shift = ',num2str(BASELINE.Shifts)]);
        end
    end
    Data.PulseID = bitand(uint32(imag(RawTimeStamp)),hex2dec('1FFFF'));
    Data.TimeStamps=RawTimeStamp;
    [Data.PulseID,WherePID]=unique(Data.PulseID,'stable');
    %Remove=Data.PulseID==0;
    %Data.PulseID(Remove)=[]; WherePID(Remove)=[];
    Buckets=str2num(Options{4,2});
    Data.NumberOfScalars=length(Buckets); Data.NumberOfVectors=2+length(Buckets); Data.NumberOfArray2D=0;
    Data.TimeStamps=Data.TimeStamps(WherePID);
    Data.Scalars=[];
    Data.Array2D{1}=[]; Data.Vectors{1}=[];
    BASELINE.RemoveFrequencies=[151,301,451];
    %V=[zeros(BASELINE.HalfShiftWindow,length(WherePID)).',InputData(WherePID,:)-BASELINE.BaselineOffset,zeros(BASELINE.HalfShiftWindow,length(WherePID)).'];  
    if(BASELINE.DO_CROP)
        if(~isempty(BASELINE.RemoveFrequencies))
            for II=1:length(WherePID)
                Datax=InputData(WherePID(II),BASELINE.CROP_START:BASELINE.CROP_END);
                FTD=fft(Datax);
                FTD(BASELINE.RemoveFrequencies)=0;
                Data.Vectors{1}(II,:)=real(ifft(FTD));
            end
        else
            Data.Vectors{1}=InputData(WherePID,BASELINE.CROP_START:BASELINE.CROP_END);
        end
    else
        if(~isempty(BASELINE.RemoveFrequencies))
            for II=1:length(WherePID)
                Datax=InputData(WherePID(II),BASELINE.CROP_START:BASELINE.CROP_END);
                FTD=fft(Datax-mean(Datax));
                FTD(BASELINE.RemoveFrequencies)=0;
                Data.Vectors{1}(II,:)=real(ifft(FTD));
            end
        else
            Data.Vectors{1}=InputData(WherePID,:);
        end
    end
    Active_Signals=sum(BASELINE.AllCombinations(BASELINE.DecoderID,:));
    All_Signals=sum(BASELINE.AllCombinations(1,:));
    for II=1:All_Signals
        Data.Vectors{II+1}=0*Data.Vectors{1};
    end
    
    if(Active_Signals==2)
        Scalars=BASELINE.PINV{BASELINE.DecoderID}*Data.Vectors{1}.';
        for KK=1:length(WherePID)
           Scalars1=Scalars(1:3:(3*(2*BASELINE.HalfShiftWindow+1)),KK);Scalars2=Scalars(2:3:(3*(2*BASELINE.HalfShiftWindow+1)),KK); Scalars3=Scalars(3:3:(3*(2*BASELINE.HalfShiftWindow+1)),KK); 
           SIG1 = BASELINE.BSL{BASELINE.DecoderID}(:,1:3:end)*diag(Scalars1);
           SIG2 = BASELINE.BSL{BASELINE.DecoderID}(:,2:3:end)*diag(Scalars2);
           SIG3 = BASELINE.BSL{BASELINE.DecoderID}(:,3:3:end)*diag(Scalars3);
           ERR=sum(abs(SIG1+SIG2+SIG3-repmat(Data.Vectors{1}(KK,:).',[1,2*BASELINE.HalfShiftWindow+1])));
           [~,OKLOC]=min(ERR);
           Data.Vectors{1}(KK,:)=Data.Vectors{1}(KK,:)-SIG3(:,OKLOC).';
           Data.Vectors{2}(KK,:)=SIG1(:,OKLOC).';
           Data.Vectors{3}(KK,:)=SIG2(:,OKLOC).';
           Data.Scalars(:,KK)=[Scalars1(OKLOC);Scalars2(OKLOC)];
        end
        Data.Vectors{4}=Data.Vectors{2}+Data.Vectors{3};
    elseif(Active_Signals==1)
        Scalars=BASELINE.PINV{BASELINE.DecoderID}*Data.Vectors{1}.';
        for KK=1:length(WherePID)
           Scalars1=Scalars(1:2:(2*(2*BASELINE.HalfShiftWindow+1)),KK); Scalars2=Scalars(2:2:(2*(2*BASELINE.HalfShiftWindow+1)),KK); 
           SIG1 = BASELINE.BSL{BASELINE.DecoderID}(:,1:2:end)*diag(Scalars1);
           SIG2 = BASELINE.BSL{BASELINE.DecoderID}(:,2:2:end)*diag(Scalars2);
           ERR=sum(abs(SIG1+SIG2-repmat(Data.Vectors{1}(KK,:).',[1,2*BASELINE.HalfShiftWindow+1])));
           [~,OKLOC]=min(ERR);
           if(BASELINE.AllCombinations(BASELINE.DecoderID,1))
               Data.Vectors{1}(KK,:)=Data.Vectors{1}(KK,:)-SIG2(:,OKLOC).';
               Data.Vectors{2}(KK,:)=SIG1(:,OKLOC).';
               Data.Vectors{3}(KK,:)=0*SIG2(:,OKLOC).';
               Data.Scalars(:,KK)=[Scalars1(OKLOC);Scalars1(OKLOC)*0];
           else
               Data.Vectors{1}(KK,:)=Data.Vectors{1}(KK,:)-SIG2(:,OKLOC).';
               Data.Vectors{2}(KK,:)=0*SIG1(:,OKLOC).';
               Data.Vectors{3}(KK,:)=SIG1(:,OKLOC).';
               Data.Scalars(:,KK)=[Scalars1(OKLOC)*0;Scalars1(OKLOC)];
           end
        end
        Data.Vectors{4}=Data.Vectors{2}+Data.Vectors{3};
    elseif(Active_Signals==0)
        Scalars=BASELINE.PINV{1}*Data.Vectors{1}.';
        for KK=1:length(WherePID)
           Scalars1=Scalars(1:3:(3*(2*BASELINE.HalfShiftWindow+1)),KK);Scalars2=Scalars(2:3:(3*(2*BASELINE.HalfShiftWindow+1)),KK); Scalars3=Scalars(3:3:(3*(2*BASELINE.HalfShiftWindow+1)),KK); 
           SIG1 = BASELINE.BSL{1}(:,1:3:end)*diag(Scalars1);
           SIG2 = BASELINE.BSL{1}(:,2:3:end)*diag(Scalars2);
           SIG3 = BASELINE.BSL{1}(:,3:3:end)*diag(Scalars3);
           ERR=sum(abs(SIG1+SIG2+SIG3-repmat(Data.Vectors{1}(KK,:).',[1,2*BASELINE.HalfShiftWindow+1])));
           [~,OKLOC]=min(ERR);
           Data.Vectors{1}(KK,:)=Data.Vectors{1}(KK,:)-SIG3(:,OKLOC).';
           Data.Vectors{2}(KK,:)=SIG1(:,OKLOC).';
           Data.Vectors{3}(KK,:)=SIG2(:,OKLOC).';
           Data.Scalars(:,KK)=[Scalars1(OKLOC);Scalars2(OKLOC)];
        end
        Data.Vectors{4}=Data.Vectors{2}+Data.Vectors{3};
    end
end

end

function CircShiftedBaseLine=RealignBaseLineOfTheMax(DatiBaseline, BackgroundArea, MaxShifts, BackgroundUse, SignalMultiplier)
    Remove=(~any(DatiBaseline)) | (any(isnan(DatiBaseline)));
    DatiBaseline(:,Remove)=[];
    Integral=sum(DatiBaseline);
    if(SignalMultiplier==1)
        [~,MP]=max(Integral);
    else
        [~,MP]=min(Integral);
    end
    MaxSignal=DatiBaseline(:,MP)-mean(DatiBaseline(BackgroundArea,MP));
    %MaxSignal=[zeros(MaxShifts,1);MaxSignal;zeros(MaxShifts,1)];
    Distances=zeros(2*MaxShifts+1,size(DatiBaseline,2));
    for II=-MaxShifts:MaxShifts
        MaxSignalShifted=circshift(MaxSignal,II);
        BaselineForThisShift=[MaxSignalShifted,ones(size(MaxSignalShifted))];
        BS=BaselineForThisShift((MaxShifts+1):(end-MaxShifts),:);
        Projections=pinv(BS)*DatiBaseline((MaxShifts+1):(end-MaxShifts),:);
        Signals=BaselineForThisShift((MaxShifts+1):(end-MaxShifts),:)*Projections;
        Distances(II+MaxShifts+1,:)=sum(abs(Signals - DatiBaseline((MaxShifts+1):(end-MaxShifts),:)));
        ShiftsTable(II+MaxShifts+1)=II;
    end
    [~,MP]=min(Distances);
    ShiftsToBeApplied=ShiftsTable(MP);
    ShiftsToBeApplied=ShiftsToBeApplied-round(mean(ShiftsToBeApplied));
    for II=1:size(DatiBaseline,2)
        CircShiftedBaseLine(:,II)=circshift(DatiBaseline(:,II),-ShiftsToBeApplied(II));
        if((-ShiftsToBeApplied(II))>0)
            CircShiftedBaseLine(1:(abs(ShiftsToBeApplied(II))),II)=DatiBaseline(1,II);
        elseif((-ShiftsToBeApplied(II))<0)
            CircShiftedBaseLine((end-abs(ShiftsToBeApplied(II))+1):end,II)=DatiBaseline(end,II);
        end
    end
end

function [Shape,ShapeBackground]=CalculateBaselineShape(CircShiftedBaseLine,TopPerCent,SignalMultiplier,BackgroundArea)
    Integral=SignalMultiplier*sum(CircShiftedBaseLine);
    [~,SortingOrder]=sort(Integral,'ascend');
    CircShiftedBaseLine=CircShiftedBaseLine(:,SortingOrder);
    if(TopPerCent<100)
       Amount=round(length(SortingOrder)/100*TopPerCent); 
    else
       Amount=length(SortingOrder);
    end
    Shape=mean(CircShiftedBaseLine(:,1:Amount),2);
    ShapeBackground=mean(Shape(BackgroundArea));
    Shape=Shape-ShapeBackground;
end

function [DelayDT, DelayBuckets, DelayNanoSeconds, DelaySHIFT] = ComputeDelay(MULTIBUNCHCONFIG,Options)
        if(str2double(Options{6,2}))
            DelayBuckets=[abs(MULTIBUNCHCONFIG.Bucket1 - MULTIBUNCHCONFIG.Bucket1),abs(MULTIBUNCHCONFIG.Bucket2 - MULTIBUNCHCONFIG.Bucket1)];
        else
            DelayBuckets=str2num(Options{4,2});
        end
        DelayNanoSeconds=0.350140056022409*DelayBuckets;
        DelayDT=str2num(Options{3,2}); %pixel per nanoseconds.
        DelaySHIFT=round(DelayNanoSeconds*DelayDT);
end

function [PINV,BSL,FixedBackground,AllCombinations,HalfShiftWindow,FixedSamplesAveraging]=ComputeBaseline(BASELINE,Options)
    HalfShiftWindow=str2double(Options{5,2});
    FixedSamplesAveraging=5;
    for II=-HalfShiftWindow:HalfShiftWindow
        for JJ=1:numel(BASELINE.Shifts)
            Baseline_f{II+HalfShiftWindow+1}(:,JJ)=circshift(BASELINE.Shape,BASELINE.Shifts(JJ)+II);
            if(BASELINE.Shifts(JJ)>0)
                Baseline_f{II+HalfShiftWindow+1}(1:(BASELINE.Shifts(JJ)+II),JJ) = mean(BASELINE.Shape(1:FixedSamplesAveraging));
            elseif(BASELINE.Shifts(JJ)<0)
                Baseline_f{II+HalfShiftWindow+1}((end + (BASELINE.Shifts(JJ)+II)+1) : end,JJ) = mean(BASELINE.Shape((end-FixedSamplesAveraging):end));
            end
        end
    end
    NofPulses=length(BASELINE.Shifts);
    AllCombinations=ones(2^NofPulses,NofPulses);
    for II=1:length(BASELINE.Shifts)
        REPMAT=[ones(2^(NofPulses-II),1);NaN*zeros(2^(NofPulses-II),1)]*1;
        REPTIMES=2^(II-1);
        AllCombinations(:,II)=repmat(REPMAT,[REPTIMES,1]);
    end
    AllCombinations(isnan(AllCombinations))=0;
    FixedBackground=str2num(Options{9,2});
    for JJ=1:size(AllCombinations,1)
        PINV{JJ}=[];
        BSL{JJ}=[];
        for II=-HalfShiftWindow:HalfShiftWindow
            SolverMatrix = Baseline_f{II+HalfShiftWindow+1}(:,logical(AllCombinations(JJ,:)));
            if(~FixedBackground)
                SolverMatrix(:,end+1)=1; %#ok<AGROW>
            end
            SolverPinvMatrix = pinv(SolverMatrix);
            PINV{JJ}=[PINV{JJ};SolverPinvMatrix];
            BSL{JJ}=[BSL{JJ},SolverMatrix];
        end
    end
 end
 
