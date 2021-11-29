function [Data,PulseID,TimeStamp]=CVCRCI_Decode_TwoBuckets_WF(InputData,Options,Profile,RawTimeStamp,Initialize)
PulseID=[];TimeStamp=[];
persistent BASELINE VITARA
if(Initialize) %gives the amount/type/names of Output data from the function when actual data is processed
    CROP_START=str2double(Options{3,2}); CROP_END=str2double(Options{4,2});
    if(isnan(CROP_START)), CROP_START=1; end
    if(isnan(CROP_END)), CROP_END=length(InputData); end
    Data.ScalarNames={'Intensity 1st Pulse ','Intensity 2nd Pulse'};
    Data.VectorNames={'Raw Cropped','Pulse 1','Pulse 2','Pulse 1+2'};
    Data.NumberOfScalars=numel(Data.ScalarNames);
    Data.NumberOfVectors=numel(Data.VectorNames);
    Data.VectorSizes=[CROP_END-CROP_START+1,CROP_END-CROP_START+1,CROP_END-CROP_START+1,CROP_END-CROP_START+1];
    Data.NumberOfArray2D=0;
    Data.Array2DNames={''};
    %Data.Array2DSizes=SIZE; %size 1 ; size 2 ; size 3...
    Data.UseExternalTimeStamps=0; %If 0, uses the pulse ID calculated during processing. If 1, uses the external one
    Data.AdditionalInformation={'Add. Info','NONE'};   
    if(Initialize==2) %Make up BASELINE loading File.
        try
           load([Options{2,2},'/',Options{1,2}]); 
        catch
           Samples=200;
           TakeDataAgain=~str2double(Options{10,2});
           if(TakeDataAgain)
               D=zeros(size(repmat(InputData,[200,1])));
               D(1,:)=lcaGetSmart(Profile.PVName,prod(Profile.size));
               ins=2;
               while(ins<Samples)
                   D(ins,:)=lcaGetSmart(Profile.PVName,prod(Profile.size));
                   if(any(D(ins,:)~=D(ins-1,:)))
                       ins=ins+1;
                   end
               end
               DatiBaseline=D.';
               DatiBaseline=DatiBaseline(CROP_START:CROP_END,:);
           else
               load(['/u1/lcls/matlab/VOM_Configs/LAST_DecodeTwoBuckets_BASELINE',Options{16,2}],'BASELINE');
               DatiBaseline=BASELINE.DatiBaseline;
           end
           
           %%%HERE MAKE BASELINE
           [VectorLength,BaseLineLength]=size(DatiBaseline);
           BackgroundArea=str2num(Options{9,2});
           %Realignat=str2num(get(handles.Realignat,'string'));
           %keeptop=str2num(get(handles.keeptop,'string'));
           Export.BaselineOffset=mean( mean( DatiBaseline(BackgroundArea,:) ) ) ;
           Export.DatiBaseline=DatiBaseline;
           WorkingDatiBaseline=DatiBaseline-Export.BaselineOffset;
           Intensita=sum(WorkingDatiBaseline,1);
           [~,MP]=max(Intensita);
           Export.HalfShiftWindow=str2num(Options{7,2});
           WorkingDatiBaseline=[zeros(Export.HalfShiftWindow,BaseLineLength); WorkingDatiBaseline; zeros(Export.HalfShiftWindow,BaseLineLength)];
           BaseLineOfTheMax=WorkingDatiBaseline(:,MP);
           Export.BaseLineOfTheMax=BaseLineOfTheMax;
           
           
% 
%            ROC=4; %Read out channels
%            if(mod(VectorLength,ROC))
%                SUSED=VectorLength-1;
%                while(mod(SUSED,ROC))
%                    SUSED=SUSED-1;
%                end
%            end
%            SDatiBaseline=fft(DatiBaseline(:,((end-SUSED+1):end)).');
%            %plot(SDatiBaseline(:,1));
%            
%            SET0=[1,SUSED/4-1,SUSED/4,SUSED/4+1,SUSED/4+2,SUSED/4+3,SUSED/2-1,SUSED/2,SUSED/2+1,SUSED/2+2,SUSED/2+3,SUSED/4*3-1,SUSED/4*3,SUSED/4*3+1,SUSED/4*3+2,SUSED/4*3+3];
%            SDatiBaseline(SET0,:)=0;
%            
%            for II=1:BaseLineLength
%                RIFT(:,II)=real(ifft(SDatiBaseline(:,II)));
%            end
%            RIFT=[zeros(15,BaseLineLength);RIFT;zeros(15+VectorLength-SUSED,BaseLineLength)];
%            Intensities=sum(abs(RIFT),1);
%            [~,TOP]=max(Intensities);

           ShiftVector=-Export.HalfShiftWindow:Export.HalfShiftWindow;
           for II=-Export.HalfShiftWindow:Export.HalfShiftWindow
               BaseLineOfTheMaxWT{1+II+Export.HalfShiftWindow}= circshift(BaseLineOfTheMax,II);
               PinvOfTheMax{1+II+Export.HalfShiftWindow} = pinv(BaseLineOfTheMaxWT{1+II+Export.HalfShiftWindow});
           end
           
           Errors=zeros(BaseLineLength,2*Export.HalfShiftWindow+1);
           RealignedSet=WorkingDatiBaseline*0;
           
           for II=1:BaseLineLength
               for HH=1:(2*Export.HalfShiftWindow+1)
                   Errors(II,HH)=sum(abs(WorkingDatiBaseline(:,II)-PinvOfTheMax{HH}*WorkingDatiBaseline(:,II)*BaseLineOfTheMaxWT{HH}));
               end
               [~,TheShift(II)]=min(Errors(II,:));
               RealignedSet(:,II)=circshift(WorkingDatiBaseline(:,II),-ShiftVector(TheShift(II)));
           end
           
           keeptop=25;
           [IntSorted,ORDER]=sort(Intensita,'descend');
           IntrThresdold=min(IntSorted(1:min(ceil(length(Intensita)*keeptop/100),length(Intensita))));
           Export.BASELINE=mean(RealignedSet(:,Intensita>IntrThresdold),2);
           
           DT=str2num(Options{5,2});
           Export.DT_ns=DT;
           ExpectDelayBuckets=str2num(Options{6,2});
           Export.DelayBuckets=ExpectDelayBuckets;
           ExpectDelayNumber=0.350140056022409*Export.DelayBuckets;
           Export.ExpectDelay_ns=ExpectDelayNumber;
           SHIFT=round(Export.ExpectDelay_ns*Export.DT_ns);
           Export.SHIFT=SHIFT;
           
           Export.PINV=[];
           Export.PINV_OnlyPulse1=[];
           Export.PINV_OnlyPulse2=[];
           Export.BSL_1=[];
           Export.BSL_2=[];
           for II=-Export.HalfShiftWindow:Export.HalfShiftWindow
               Export.BASELINE_1Pulse{II+1+Export.HalfShiftWindow}= circshift(Export.BASELINE,II);
               Export.BASELINE_2Pulse{II+1+Export.HalfShiftWindow}= circshift(Export.BASELINE,II+SHIFT);
%                if(SHIFT>=Export.HalfShiftWindow+1)
%                    Export.BASELINE_2Pulse{II+Export.HalfShiftWindow+1}(1:(SHIFT-Export.HalfShiftWindow)) = 0;
%                end
               %Export.BASELINE_1Pulse{II+Export.HalfShiftWindow+1}=Export.BASELINE_1Pulse{II+Export.HalfShiftWindow+1}((Export.HalfShiftWindow+1):(Export.HalfShiftWindow+VectorLength));
               %Export.BASELINE_2Pulse{II+Export.HalfShiftWindow+1}=Export.BASELINE_2Pulse{II+Export.HalfShiftWindow+1}((Export.HalfShiftWindow+1):(Export.HalfShiftWindow+VectorLength));
               Export.PinvOfTheMax{II+Export.HalfShiftWindow+1} = pinv(BaseLineOfTheMaxWT{II+Export.HalfShiftWindow+1});
               Export.SolverMatrix{II+Export.HalfShiftWindow+1}=[Export.BASELINE_1Pulse{II+Export.HalfShiftWindow+1},Export.BASELINE_2Pulse{II+Export.HalfShiftWindow+1}];
               Export.SolverMatrixOnlyPulse1{II+Export.HalfShiftWindow+1}=Export.BASELINE_1Pulse{II+Export.HalfShiftWindow+1};
               Export.SolverMatrixOnlyPulse2{II+Export.HalfShiftWindow+1}=Export.BASELINE_2Pulse{II+Export.HalfShiftWindow+1};
               Export.SolverPinvMatrix{II+Export.HalfShiftWindow+1}=pinv(Export.SolverMatrix{II+Export.HalfShiftWindow+1});
               Export.SolverPinvMatrixOnlyPulse1{II+Export.HalfShiftWindow+1}=pinv(Export.SolverMatrixOnlyPulse1{II+Export.HalfShiftWindow+1});
               Export.SolverPinvMatrixOnlyPulse2{II+Export.HalfShiftWindow+1}=pinv(Export.SolverMatrixOnlyPulse2{II+Export.HalfShiftWindow+1});
               
               Export.PINV=[Export.PINV;Export.SolverPinvMatrix{II+Export.HalfShiftWindow+1}];
               Export.PINV_OnlyPulse1=[Export.PINV_OnlyPulse1;Export.SolverPinvMatrixOnlyPulse1{II+Export.HalfShiftWindow+1}];
               Export.PINV_OnlyPulse2=[Export.PINV_OnlyPulse2;Export.SolverPinvMatrixOnlyPulse2{II+Export.HalfShiftWindow+1}];
               Export.BSL_1=[Export.BSL_1,Export.BASELINE_1Pulse{II+Export.HalfShiftWindow+1}];
               Export.BSL_2=[Export.BSL_2,Export.BASELINE_2Pulse{II+Export.HalfShiftWindow+1}];
           end
           
           Export.DT=DT;
           Export.SHIFT=SHIFT;
           Export.ExpectDelay=Export.ExpectDelay_ns;
           Export.BaseLineLength=BaseLineLength;
           Export.VectorLength=VectorLength;
           
           Export.CROP_START=CROP_START; Export.CROP_END=CROP_END;
           if((Export.CROP_START~=1) || (Export.CROP_END~=length(InputData))), Export.DO_CROP=1; else, Export.DO_CROP=0; end

           BASELINE=Export;
           save(['/u1/lcls/matlab/VOM_Configs/LAST_DecodeTwoBuckets_BASELINE',Options{16,2}],'BASELINE');
           %save LAST_BASELINE BASELINE
           disp(['Initialization Done BASELINE stored in ','/u1/lcls/matlab/VOM_Configs/LAST_DecodeTwoBuckets_BASELINE',Options{16,2}]);
        end
    end
else %actually decode the input data, giving scalar, vectors, 2d arrays along with their matrices
    if(isempty(BASELINE))
        load(['/u1/lcls/matlab/VOM_Configs/LAST_DecodeTwoBuckets_BASELINE',Options{16,2}],'BASELINE');
    end
    if(str2double(Options{8,2}))% AUTOVITARA (reprocesses baseline if shift has changed.)
        Vitara1S=lcaGetSmart(Options{11,2}); Vitara2S=lcaGetSmart(Options{12,2});
        if(iscell(Vitara1S)), Vitara1S=Vitara1S{1}; end
        if(iscell(Vitara2S)), Vitara2S=Vitara2S{1}; end
        Bucket1=lcaGetSmart(Options{13,2}); Bucket2=lcaGetSmart(Options{14,2});
        BucketDelay=lcaGetSmart(Options{15,2});
        Vitara1S = Vitara1S(1)=='I'; Vitara2S = Vitara2S(1)=='I';
        ReprocessBaseline=0;
        if(isempty(VITARA))
            ReprocessBaseline=1;
            VITARA.Vitara1S=Vitara1S;
            VITARA.Vitara2S=Vitara2S;
            VITARA.Bucket1=Bucket1;
            VITARA.Bucket2=Bucket2;
            VITARA.BucketDelay=BucketDelay;
        else
            if(~all([VITARA.Vitara1S,VITARA.Vitara2S,VITARA.Bucket1,VITARA.Bucket2,VITARA.BucketDelay] == [Vitara1S,Vitara2S,Bucket1,Bucket2,BucketDelay]))
                ReprocessBaseline=1;
                VITARA.Vitara1S=Vitara1S;
                VITARA.Vitara2S=Vitara2S;
                VITARA.Bucket1=Bucket1;
                VITARA.Bucket2=Bucket2;
                VITARA.BucketDelay=BucketDelay;
            end
        end
        if(ReprocessBaseline)
            DatiBaseline=BASELINE.DatiBaseline;
            Export.CROP_START=BASELINE.CROP_START; Export.CROP_END=BASELINE.CROP_END; Export.DO_CROP=BASELINE.DO_CROP;
            [VectorLength,BaseLineLength]=size(DatiBaseline);
            BackgroundArea=str2num(Options{9,2});
            Export.BaselineOffset=mean( mean( DatiBaseline(BackgroundArea,:) ) ) ;
            Export.DatiBaseline=DatiBaseline;
            DatiBaseline=DatiBaseline-Export.BaselineOffset;
            Intensita=sum(DatiBaseline,1);
            [~,MP]=max(Intensita);
            Export.HalfShiftWindow=str2num(Options{7,2});
            DatiBaseline=[zeros(Export.HalfShiftWindow,BaseLineLength); DatiBaseline; zeros(Export.HalfShiftWindow,BaseLineLength)];
            BaseLineOfTheMax=DatiBaseline(:,MP);
            Export.BaseLineOfTheMax=BaseLineOfTheMax;
            ShiftVector=-Export.HalfShiftWindow:Export.HalfShiftWindow;
            for II=-Export.HalfShiftWindow:Export.HalfShiftWindow
                BaseLineOfTheMaxWT{1+II+Export.HalfShiftWindow}= circshift(BaseLineOfTheMax,II);
                PinvOfTheMax{1+II+Export.HalfShiftWindow} = pinv(BaseLineOfTheMaxWT{1+II+Export.HalfShiftWindow});
            end
            
            Errors=zeros(BaseLineLength,2*Export.HalfShiftWindow+1);
            RealignedSet=DatiBaseline*0;
            
            for II=1:BaseLineLength
                for HH=1:(2*Export.HalfShiftWindow+1)
                    Errors(II,HH)=sum(abs(DatiBaseline(:,II)-PinvOfTheMax{HH}*DatiBaseline(:,II)*BaseLineOfTheMaxWT{HH}));
                end
                [~,TheShift(II)]=min(Errors(II,:));
                RealignedSet(:,II)=circshift(DatiBaseline(:,II),-ShiftVector(TheShift(II)));
            end
            
            keeptop=25;
            [IntSorted,ORDER]=sort(Intensita,'descend');
            IntrThresdold=min(IntSorted(1:min(ceil(length(Intensita)*keeptop/100),length(Intensita))));
            Export.BASELINE=mean(RealignedSet(:,Intensita>IntrThresdold),2);
            DT=str2num(Options{5,2});
            Export.DT_ns=DT;
            ExpectDelayBuckets=VITARA.BucketDelay;
            Export.DelayBuckets=ExpectDelayBuckets;
            
            %ExpectDelayNumber=0.350140056022409*Export.DelayBuckets;
            if(str2double(Options{8,2}))
                ExpectDelayNumber=0.350140056022409*abs(VITARA.Bucket2 - VITARA.Bucket1);
            else
                ExpectDelayNumber=0.350140056022409*Export.DelayBuckets;
            end
            Export.ExpectDelay_ns=ExpectDelayNumber;
            SHIFT=round(Export.ExpectDelay_ns*Export.DT_ns);
            Export.SHIFT=SHIFT;
            
            Export.PINV=[];
            Export.PINV_OnlyPulse1=[];
            Export.PINV_OnlyPulse2=[];
            Export.BSL_1=[];
            Export.BSL_2=[];
            for II=-Export.HalfShiftWindow:Export.HalfShiftWindow
                Export.BASELINE_1Pulse{II+1+Export.HalfShiftWindow}= circshift(Export.BASELINE,II);
                Export.BASELINE_2Pulse{II+1+Export.HalfShiftWindow}= circshift(Export.BASELINE,II+SHIFT);
                if(SHIFT>=Export.HalfShiftWindow+1)
                    Export.BASELINE_2Pulse{II+Export.HalfShiftWindow+1}(1:(SHIFT-Export.HalfShiftWindow)) = 0;
                end
                %Export.BASELINE_1Pulse{II+Export.HalfShiftWindow+1}=Export.BASELINE_1Pulse{II+Export.HalfShiftWindow+1}((Export.HalfShiftWindow+1):(Export.HalfShiftWindow+VectorLength));
                %Export.BASELINE_2Pulse{II+Export.HalfShiftWindow+1}=Export.BASELINE_2Pulse{II+Export.HalfShiftWindow+1}((Export.HalfShiftWindow+1):(Export.HalfShiftWindow+VectorLength));
                Export.PinvOfTheMax{II+Export.HalfShiftWindow+1} = pinv(BaseLineOfTheMaxWT{II+Export.HalfShiftWindow+1});
                Export.SolverMatrix{II+Export.HalfShiftWindow+1}=[Export.BASELINE_1Pulse{II+Export.HalfShiftWindow+1},Export.BASELINE_2Pulse{II+Export.HalfShiftWindow+1}];
                Export.SolverMatrixOnlyPulse1{II+Export.HalfShiftWindow+1}=Export.BASELINE_1Pulse{II+Export.HalfShiftWindow+1};
                Export.SolverMatrixOnlyPulse2{II+Export.HalfShiftWindow+1}=Export.BASELINE_2Pulse{II+Export.HalfShiftWindow+1};
                Export.SolverPinvMatrix{II+Export.HalfShiftWindow+1}=pinv(Export.SolverMatrix{II+Export.HalfShiftWindow+1});
                Export.SolverPinvMatrixOnlyPulse1{II+Export.HalfShiftWindow+1}=pinv(Export.SolverMatrixOnlyPulse1{II+Export.HalfShiftWindow+1});
                Export.SolverPinvMatrixOnlyPulse2{II+Export.HalfShiftWindow+1}=pinv(Export.SolverMatrixOnlyPulse2{II+Export.HalfShiftWindow+1});
                
                Export.PINV=[Export.PINV;Export.SolverPinvMatrix{II+Export.HalfShiftWindow+1}];
                Export.PINV_OnlyPulse1=[Export.PINV_OnlyPulse1;Export.SolverPinvMatrixOnlyPulse1{II+Export.HalfShiftWindow+1}];
                Export.PINV_OnlyPulse2=[Export.PINV_OnlyPulse2;Export.SolverPinvMatrixOnlyPulse2{II+Export.HalfShiftWindow+1}];
                Export.BSL_1=[Export.BSL_1,Export.BASELINE_1Pulse{II+Export.HalfShiftWindow+1}];
                Export.BSL_2=[Export.BSL_2,Export.BASELINE_2Pulse{II+Export.HalfShiftWindow+1}];
            end
            
            Export.DT=DT;
            Export.SHIFT=SHIFT;
            Export.ExpectDelay=Export.ExpectDelay_ns;
            Export.BaseLineLength=BaseLineLength;
            Export.VectorLength=VectorLength;
            
            BASELINE=Export;
            save(['/u1/lcls/matlab/VOM_Configs/LAST_DecodeTwoBuckets_BASELINE',Options{16,2}],'BASELINE');
            %save LAST_BASELINE BASELINE
            disp(['Re-initialization done, vitara conditions changed or lost new BASELINE in ','/u1/lcls/matlab/VOM_Configs/LAST_DecodeTwoBuckets_BASELINE',Options{16,2}]);
            disp(['Used Shift = ',num2str(Export.SHIFT)]);
        end
    end
%     CROP_START=str2double(Options{3,2}); CROP_END=str2double(Options{4,2});
%     if(isnan(CROP_START)), CROP_START=1; end
%     if(isnan(CROP_END)), CROP_END=length(InputData); end
    Data.PulseID = bitand(uint32(imag(RawTimeStamp)),hex2dec('1FFFF'));
    Data.TimeStamps=RawTimeStamp;
    [Data.PulseID,WherePID]=unique(Data.PulseID,'stable');
    Remove=Data.PulseID==0;
    Data.PulseID(Remove)=[]; WherePID(Remove)=[];
    Data.NumberOfScalars=2;
    Data.NumberOfVectors=4;
    Data.NumberOfArray2D=0;
    Data.TimeStamps=Data.TimeStamps(WherePID);
    Data.Scalars=[];
    Data.Array2D{1}=[];
    if(BASELINE.DO_CROP)
        V=[zeros(BASELINE.HalfShiftWindow,length(WherePID)).',InputData(WherePID,BASELINE.CROP_START:BASELINE.CROP_END)-BASELINE.BaselineOffset,zeros(BASELINE.HalfShiftWindow,length(WherePID)).'];  
    else
        V=[zeros(BASELINE.HalfShiftWindow,length(WherePID)).',InputData(WherePID,:)-BASELINE.BaselineOffset,zeros(BASELINE.HalfShiftWindow,length(WherePID)).']; 
    end
    Data.Vectors{1}=V(:,(BASELINE.HalfShiftWindow+1):(end-BASELINE.HalfShiftWindow));
    Data.Vectors{2}=0*Data.Vectors{1};
    Data.Vectors{3}=0*Data.Vectors{1};
    if(~str2double(Options{8,2})) %if not auto-vitara then quickly decode two pulses in fixed condition.
        Scalars=BASELINE.PINV*V.';
        for KK=1:length(WherePID)
            Scalars1=Scalars(1:2:(2*(2*BASELINE.HalfShiftWindow+1)),KK);Scalars2=Scalars(2:2:(2*(2*BASELINE.HalfShiftWindow+1)),KK);
            SIG1 = BASELINE.BSL_1*diag(Scalars1);
            SIG2 = BASELINE.BSL_2*diag(Scalars2);
            ERR=sum(abs(SIG1+SIG2-repmat(V(KK,:).',[1,2*BASELINE.HalfShiftWindow+1])));
            [~,OKLOC]=min(ERR);
            Data.Vectors{2}(KK,:)=SIG1((BASELINE.HalfShiftWindow+1):(end-BASELINE.HalfShiftWindow),OKLOC).';
            Data.Vectors{3}(KK,:)=SIG2((BASELINE.HalfShiftWindow+1):(end-BASELINE.HalfShiftWindow),OKLOC).';
            Data.Scalars(:,KK)=[Scalars1(OKLOC);Scalars2(OKLOC)];
        end
        %     Data.Scalars=[Scalars1(OKLOC);Scalars2(OKLOC)];
        %     Data.Vectors{2}=SIG1(:,OKLOC).';
        %     Data.Vectors{3}=SIG2(:,OKLOC).';
        Data.Vectors{4}=Data.Vectors{2}+Data.Vectors{3};
    else
        if( (~VITARA.Vitara1S && round(VITARA.Bucket1)==VITARA.Bucket1) && (~ VITARA.Vitara2S && round(VITARA.Bucket2)==VITARA.Bucket2) )
            Scalars=BASELINE.PINV*V.';
            for KK=1:length(WherePID)
                Scalars1=Scalars(1:2:(2*(2*BASELINE.HalfShiftWindow+1)),KK);Scalars2=Scalars(2:2:(2*(2*BASELINE.HalfShiftWindow+1)),KK);
                SIG1 = BASELINE.BSL_1*diag(Scalars1);
                SIG2 = BASELINE.BSL_2*diag(Scalars2);
                ERR=sum(abs(SIG1+SIG2-repmat(V(KK,:).',[1,2*BASELINE.HalfShiftWindow+1])));
                [~,OKLOC]=min(ERR);
                Data.Vectors{2}(KK,:)=SIG1((BASELINE.HalfShiftWindow+1):(end-BASELINE.HalfShiftWindow),OKLOC).';
                Data.Vectors{3}(KK,:)=SIG2((BASELINE.HalfShiftWindow+1):(end-BASELINE.HalfShiftWindow),OKLOC).';
                Data.Scalars(:,KK)=[Scalars1(OKLOC);Scalars2(OKLOC)];
            end
            Data.Vectors{4}=Data.Vectors{2}+Data.Vectors{3};
        elseif( (~VITARA.Vitara1S && round(VITARA.Bucket1)==VITARA.Bucket1) )
            Scalars=BASELINE.PINV_OnlyPulse1*V.';
            for KK=1:length(WherePID)
                SIG1 = BASELINE.BSL_1*diag(Scalars(:,KK));
                SIG2 = SIG1*0;
                ERR=sum(abs(SIG1+SIG2-repmat(V(KK,:).',[1,2*BASELINE.HalfShiftWindow+1])));
                [~,OKLOC]=min(ERR);
                Data.Vectors{2}(KK,:)=SIG1((BASELINE.HalfShiftWindow+1):(end-BASELINE.HalfShiftWindow),OKLOC).';
                Data.Vectors{3}(KK,:)=SIG2((BASELINE.HalfShiftWindow+1):(end-BASELINE.HalfShiftWindow),OKLOC).';
                Data.Scalars(:,KK)=[Scalars(OKLOC,KK);zeros(size(Scalars(OKLOC,KK)))];
            end
            Data.Vectors{4}=Data.Vectors{2}+Data.Vectors{3};
        elseif( (~ VITARA.Vitara2S && round(VITARA.Bucket2)==VITARA.Bucket2) )
            Scalars=BASELINE.PINV_OnlyPulse2*V.';
            for KK=1:length(WherePID)
                SIG2 = BASELINE.BSL_2*diag(Scalars(:,KK));
                SIG1=SIG2*0;
                ERR=sum(abs(SIG1+SIG2-repmat(V(KK,:).',[1,2*BASELINE.HalfShiftWindow+1])));
                [~,OKLOC]=min(ERR);
                Data.Vectors{2}(KK,:)=SIG1((BASELINE.HalfShiftWindow+1):(end-BASELINE.HalfShiftWindow),OKLOC).';
                Data.Vectors{3}(KK,:)=SIG2((BASELINE.HalfShiftWindow+1):(end-BASELINE.HalfShiftWindow),OKLOC).';
                Data.Scalars(:,KK)=[zeros(size(Scalars(OKLOC,KK)));Scalars(OKLOC,KK)];
            end
            Data.Vectors{4}=Data.Vectors{2}+Data.Vectors{3};
        else
            Scalars=BASELINE.PINV*V.';
            for KK=1:length(WherePID)
                Scalars1=Scalars(1:2:(2*(2*BASELINE.HalfShiftWindow+1)),KK);Scalars2=Scalars(2:2:(2*(2*BASELINE.HalfShiftWindow+1)),KK);
                SIG1 = BASELINE.BSL_1*diag(Scalars1);
                SIG2 = BASELINE.BSL_2*diag(Scalars2);
                ERR=sum(abs(SIG1+SIG2-repmat(V(KK,:).',[1,2*BASELINE.HalfShiftWindow+1])));
                [~,OKLOC]=min(ERR);
                Data.Vectors{2}(KK,:)=SIG1((BASELINE.HalfShiftWindow+1):(end-BASELINE.HalfShiftWindow),OKLOC).';
                Data.Vectors{3}(KK,:)=SIG2((BASELINE.HalfShiftWindow+1):(end-BASELINE.HalfShiftWindow),OKLOC).';
                Data.Scalars(:,KK)=[Scalars1(OKLOC);Scalars2(OKLOC)];
            end
            Data.Vectors{4}=Data.Vectors{2}+Data.Vectors{3};
        end
    end
   
end