classdef ARC_Steering_Class < handle
    
    properties
        MODEL_S;
        MODEL_H; % Acquisition Setup
        staticS=[]; % Recorder Data
        staticH=[]; % Transiet Data for recording
        static=[];
        D;
    end
    
    methods
        
        function Sol=Steer(obj,problem,sh)
            if(nargin<3)
                sh=Steering_Functions();
            end
            [CorrMatrix_S,CorrMatrixAngles_S]=sh.CorrectorOrbitMatrix_Fast(obj.staticS,obj.D(1).MODEL_S.rMat,obj.D(1).MODEL_S.Pos,obj.D(1).MODEL_S.energy);
            [CorrMatrix_H,CorrMatrixAngles_H]=sh.CorrectorOrbitMatrix_Fast(obj.staticH,obj.D(1).MODEL_H.rMat,obj.D(1).MODEL_H.Pos,obj.D(1).MODEL_H.energy);
            
            UseCorrectors=problem.UseCorr;
            UseBPMs=unique([problem.UseBPM_SX;problem.UseBPM_SY;problem.UseBPM_HX;problem.UseBPM_HY],'stable');

            [~,CorrLinesInSoftSystem,CorrLinesInProblemMatrix_FormSoft]=intersect(obj.staticS.corrList_e,UseCorrectors);
            [~,CorrLinesInHardSystem,CorrLinesInProblemMatrix_FromHard]=intersect(obj.staticH.corrList_e,UseCorrectors);
%             [~,BpmLinesInSoftSystem,BpmXIndexInProblemMatrix_FromSoft]=intersect(obj.staticS.bpmList_e,UseBPMs);
%             [~,BpmLinesInHardSystem,BpmXIndexInProblemMatrix_FromHard]=intersect(obj.staticH.bpmList_e,UseBPMs);
            
            [~,BpmLinesInSoftSystem_X,BpmXIndexInProblemMatrix_FromSoft_X]=intersect(obj.staticS.bpmList_e,problem.UseBPM_SX);
            [~,BpmLinesInSoftSystem_Y,BpmXIndexInProblemMatrix_FromSoft_Y]=intersect(obj.staticS.bpmList_e,problem.UseBPM_SY);
            
            [~,BpmLinesInHardSystem_X,BpmXIndexInProblemMatrix_FromHard_X]=intersect(obj.staticH.bpmList_e,problem.UseBPM_HX);
            [~,BpmLinesInHardSystem_Y,BpmXIndexInProblemMatrix_FromHard_Y]=intersect(obj.staticH.bpmList_e,problem.UseBPM_HY);

            %AllBPMMatrix, despite the silly name is a corrector matri, the
            %AllBPM stand for the fact that no selection on used BPM has
            %been made yet.
            AllBPMMatrix=zeros(2*length(obj.staticS.bpmList)+ 2*length(obj.staticH.bpmList), length(UseCorrectors));
            AllBPMMatrix(1:2*length(obj.staticS.bpmList),CorrLinesInProblemMatrix_FormSoft) = CorrMatrix_S(:,CorrLinesInSoftSystem);
            %AllBPMMatrix(2*length(obj.staticS.bpmList) + (1:(2*length(obj.staticH.bpmList))),CorrLinesInProblemMatrix_FormSoft) = CorrMatrix_H(:,CorrLinesInHardSystem);
            AllBPMMatrix(2*length(obj.staticS.bpmList) + (1:(2*length(obj.staticH.bpmList))),CorrLinesInProblemMatrix_FromHard) = CorrMatrix_H(:,CorrLinesInHardSystem);
            
            AllBPM_CorrMatrix=zeros(2*length(obj.staticS.bpmList)+ 2*length(obj.staticH.bpmList), length(UseCorrectors));
            AllBPM_CorrMatrix(1:2*length(obj.staticS.bpmList),CorrLinesInProblemMatrix_FormSoft) = CorrMatrixAngles_S(:,CorrLinesInSoftSystem);
            AllBPM_CorrMatrix(2*length(obj.staticS.bpmList) + (1:(2*length(obj.staticH.bpmList))),CorrLinesInProblemMatrix_FromHard) = CorrMatrixAngles_H(:,CorrLinesInHardSystem);
            
            RecordedOrbits_XS= problem.Orbit_SX;
            RecordedOrbits_YS= problem.Orbit_SY;
            RecordedOrbits_XH= problem.Orbit_HX;
            RecordedOrbits_YH= problem.Orbit_HY;
            
            %%%DA FARE ATTENZIONE GIU
            KeepBPMLines_X_Soft=2*(BpmLinesInSoftSystem_X)-1;
            KeepBPMLines_Y_Soft=2*(BpmLinesInSoftSystem_Y);
            KeepBPMLines_X_Hard=2*(BpmLinesInHardSystem_X)-1;
            KeepBPMLines_Y_Hard=2*(BpmLinesInHardSystem_Y);

            KeepBPMLines=[KeepBPMLines_X_Soft(:);KeepBPMLines_Y_Soft(:);KeepBPMLines_X_Hard(:)+2*length(obj.staticS.bpmList_e);KeepBPMLines_Y_Hard(:)+2*length(obj.staticS.bpmList_e)];
            MeasurementColumn=NaN*ones(length(KeepBPMLines),1);
            MeasurementColumn(1:length(KeepBPMLines_X_Soft)) = RecordedOrbits_XS(BpmLinesInSoftSystem_X);
            MeasurementColumn(length(KeepBPMLines_X_Soft) + (1:length(KeepBPMLines_Y_Soft))) = RecordedOrbits_YS(BpmLinesInSoftSystem_Y);
            MeasurementColumn(length(KeepBPMLines_X_Soft)+length(KeepBPMLines_Y_Soft)+(1:length(KeepBPMLines_X_Hard))) = RecordedOrbits_XH(BpmLinesInHardSystem_X);
            MeasurementColumn(length(KeepBPMLines_X_Soft)+length(KeepBPMLines_Y_Soft)+length(KeepBPMLines_X_Hard)+(1:length(KeepBPMLines_Y_Hard))) = RecordedOrbits_YH(BpmLinesInHardSystem_Y);
  
            SystemMatrix=AllBPMMatrix(KeepBPMLines,:);
            LengthBasicSystem=size(SystemMatrix,1);
            
            if(problem.CloseOffsetH) %Add one additional line for total angle = 0 at the last BPM for X and Y
                MeasurementColumn(length(KeepBPMLines_X_Soft)+length(KeepBPMLines_Y_Soft)+length(KeepBPMLines_X_Hard))=0;
                MeasurementColumn(length(KeepBPMLines_X_Soft)+length(KeepBPMLines_Y_Soft)+length(KeepBPMLines_X_Hard)+length(KeepBPMLines_Y_Hard))=0;
            end
            if(problem.CloseOffsetS) %Add one additional line for total angle =0 at the last BPM for X and Y
                MeasurementColumn(length(KeepBPMLines_X_Soft))=0;
                MeasurementColumn(length(KeepBPMLines_X_Soft) + length(KeepBPMLines_Y_Soft))=0;
            end
            if(problem.CloseAngleH) %Add one additional line for total angle = 0 at the last BPM for X and Y
                AdditionalConstrainXHard=AllBPM_CorrMatrix(2*length(obj.staticS.bpmList)+2*length(obj.staticH.bpmList)-1);
                AdditionalConstrainYHard=AllBPM_CorrMatrix(2*length(obj.staticS.bpmList)+2*length(obj.staticH.bpmList)); 
                MeasurementColumn(end+1)=problem.InducedAngleH_X(end);
                SystemMatrix(end+1,:)=AdditionalConstrainXHard;
                MeasurementColumn(end+1)=problem.InducedAngleH_Y(end);
                SystemMatrix(end+1,:)=AdditionalConstrainYHard;
                PosConstrainH=size(SystemMatrix,1)+((-1:0).');
            end
            if(problem.CloseAngleS) %Add one additional line for total angle =0 at the last BPM for X and Y
                AdditionalConstrainXSoft=AllBPM_CorrMatrix(2*length(obj.staticS.bpmList)-1);
                AdditionalConstrainYSoft=AllBPM_CorrMatrix(2*length(obj.staticS.bpmList));
                MeasurementColumn(end+1)=problem.InducedAngleS_X(end);
                SystemMatrix(end+1,:)=AdditionalConstrainXSoft;
                MeasurementColumn(end+1)=problem.InducedAngleS_Y(end);
                SystemMatrix(end+1,:)=AdditionalConstrainYSoft;
                PosConstrainS=size(SystemMatrix,1)+((-1:0).');
            end   
            
            fitSVDRatio=problem.SVD_Parameter;
            uncertaintyColumn=ones(size(MeasurementColumn));
            if(problem.CloseAngleH)
                uncertaintyColumn(PosConstrainH)=problem.WHC;
            end
            if(problem.CloseAngleS)
                uncertaintyColumn(PosConstrainS)=problem.WSC;
            end
            [SystemSolution,SystemSolution_Std] = util_lssvd(SystemMatrix, MeasurementColumn, uncertaintyColumn, fitSVDRatio);
            
            Sol.CorrectorsChanged=problem.UseCorr;
            Sol.CorrectionToApply=-SystemSolution/1000; %divided by 1000 because orbit was input in mm.
            
            [~,XCorrPosition,CorrPosInSolution_To_X]=intersect(obj.static.X.corrList_e,UseCorrectors);
            [~,YCorrPosition,CorrPosInSolution_To_Y]=intersect(obj.static.Y.corrList_e,UseCorrectors);
            
            Sol.NewCorrX=problem.XCorrStart;
            Sol.NewCorrY=problem.YCorrStart;
            Sol.NewCorrX(XCorrPosition)=Sol.NewCorrX(XCorrPosition)+Sol.CorrectionToApply(CorrPosInSolution_To_X);
            Sol.NewCorrY(YCorrPosition)=Sol.NewCorrY(YCorrPosition)+Sol.CorrectionToApply(CorrPosInSolution_To_Y);
        end
        
        function Indices=match_entrance(obj, sh, IDs, MatchOnBpmList, Weight, Sigma, MatchSHSeparately)
            if(~isempty(obj.D(IDs(1)).H_X))
                HREF_X=obj.D(IDs(1)).H_X;
                HREF_Y=obj.D(IDs(1)).H_Y;
                HREF_T=obj.D(IDs(1)).H_T;
            end
            if(~isempty(obj.D(IDs(1)).S_X))
                SREF_X=obj.D(IDs(1)).S_X;
                SREF_Y=obj.D(IDs(1)).S_Y;
                SREF_T=obj.D(IDs(1)).S_T;
            end
            
           try
                [~,WhereS,WhereS_onList]=intersect(obj.staticS.bpmList_e,MatchOnBpmList);
           end
           try
                [~,WhereH,WhereH_onList]=intersect(obj.staticH.bpmList_e,MatchOnBpmList);
           end
           
           if(MatchSHSeparately)
               
               
           else %Match at the same time.
               BL=[HREF_X(WhereH,:);HREF_Y(WhereH,:);HREF_T(WhereH,:)]; W=[Weight.X;Weight.Y;Weight.T];
               for II=1:length(IDs)
                    if(~isempty(obj.D(IDs(II)).H_X))
                        Data_X=obj.D(IDs(II)).H_X;
                        Data_Y=obj.D(IDs(II)).H_Y;
                        Data_Z=obj.D(IDs(II)).H_T;
                        DATA=[Data_X(WhereH,:);Data_Y(WhereH,:);Data_Z(WhereH,:)];
                        
                        [WD,WB] = sh.matchLaunchDoubleElimination(DATA.', BL.', W.', Sigma);
                        Indices(II).H=WD;
                        
                        obj.D(IDs(II)).H_IND=WD;
                        
                        obj.D(IDs(II)).MHF_X=mean(obj.D(IDs(II)).H_X(:,WD),2);
                        obj.D(IDs(II)).MHF_Y=mean(obj.D(IDs(II)).H_Y(:,WD),2);
                        obj.D(IDs(II)).MHF_T=mean(obj.D(IDs(II)).H_T(:,WD),2);
                        
                    end
                    if(~isempty(obj.D(IDs(1)).S_X))
                        Data_X=obj.D(IDs(II)).S_X;
                        Data_Y=obj.D(IDs(II)).S_Y;
                        Data_Z=obj.D(IDs(II)).S_T;
                        DATA=[Data_X(WhereS,:);Data_Y(WhereS,:);Data_Z(WhereS,:)];
                        [WD,WB] = sh.matchLaunchDoubleElimination(DATA.', BL.', W.', Sigma);
                        Indices(II).S=WD;
                        
                        obj.D(IDs(II)).S_IND=WD;
                        
                        obj.D(IDs(II)).MSF_X=mean(obj.D(IDs(II)).S_X(:,WD),2);
                        obj.D(IDs(II)).MSF_Y=mean(obj.D(IDs(II)).S_Y(:,WD),2);
                        obj.D(IDs(II)).MSF_T=mean(obj.D(IDs(II)).S_T(:,WD),2);
                    end
               end
           end
           
           %[ReducedBaseline_POS, ReducedData_POS]=sh.matchLaunchDoubleElimination(Baseline, Data, Weights, Sigmas) 
        end
        
        function evaluate_avg_trajectory(obj,ExcludeNaN,FilterTMIT,rmsFilter,ID)
            for II=1:length(obj.D)
                if(nargin>=5)
                    if(ID~=II)
                        continue
                    end
                end
                if(~isempty(obj.D(II).BPMRawData_S))
                    L=size(obj.D(II).BPMRawData_S,1)/3;
                    X=obj.D(II).BPMRawData_S(1:L,:);
                    Y=obj.D(II).BPMRawData_S(L+(1:L),:);
                    T=obj.D(II).BPMRawData_S(2*L+(1:L),:);
                    
                    obj.D(II).MS_X=NaN*ones(size(X,1),1);
                    obj.D(II).MS_Y=NaN*ones(size(Y,1),1);
                    obj.D(II).MS_T=NaN*ones(size(T,1),1);
                    
                    if(size(X,2)==1) %non c'e' molto da fare una size e' 1
                        obj.D(II).S_X=X;
                        obj.D(II).S_Y=Y;
                        obj.D(II).S_T=T;

                        obj.D(II).MS_X=X;
                        obj.D(II).MS_Y=Y;
                        obj.D(II).MS_T=T;
                    else
                        for TT=1:size(X,1)
                            Xw=X(TT,~isnan(X(TT,:)));
                            Yw=Y(TT,~isnan(Y(TT,:)));
                            Tw=T(TT,~isnan(T(TT,:)));
                            
                            Xw(Tw<FilterTMIT)=[];
                            Yw(Tw<FilterTMIT)=[];
                            Tw(Tw<FilterTMIT)=[];
                            
                            if(isempty(Xw))
                                obj.D(II).MS_X(TT)=NaN;
                            else
                                obj.D(II).MS_X(TT)=mean(Xw,2);
                            end
                            
                            if(isempty(Yw))
                                obj.D(II).MS_Y(TT)=NaN;
                            else
                                obj.D(II).MS_Y(TT)=mean(Yw,2);
                            end
                            
                            if(isempty(Tw))
                                obj.D(II).MS_T(TT)=NaN;
                            else
                                obj.D(II).MS_T(TT)=mean(Tw,2);
                            end
                        end
                        
                        if(ExcludeNaN)
                            RemX=isnan(sum(X));
                            RemY=isnan(sum(Y));
                            RemT=isnan(sum(T));
                        
                            RemT2=any(T<FilterTMIT);

                            X(:,RemX | RemY | RemT | RemT2)=[];
                            Y(:,RemX | RemY | RemT | RemT2)=[];
                            T(:,RemX | RemY | RemT | RemT2)=[];
                            
                            XS=std(X,[],2);
                            YS=std(Y,[],2);
                            XM=mean(X,2);
                            YM=mean(Y,2);

                            RemXS=any(((X-XM*ones(size(X(1,:))) - rmsFilter*XS*ones(size(X(1,:))))>0) | ((X-XM*ones(size(X(1,:))) + rmsFilter*XS*ones(size(X(1,:))))<0));
                            RemYS=any(((Y-YM*ones(size(Y(1,:))) - rmsFilter*YS*ones(size(Y(1,:))))>0) | ((Y-YM*ones(size(X(1,:))) + rmsFilter*YS*ones(size(Y(1,:))))<0));

                            X(:,RemXS | RemYS)=[];
                            Y(:,RemXS | RemYS)=[];
                            T(:,RemXS | RemYS)=[];
                        end
                        obj.D(II).S_X=X;
                        obj.D(II).S_Y=Y;
                        obj.D(II).S_T=T;
                    end
                else
                    obj.D(II).S_X=[];
                    obj.D(II).S_Y=[];
                    obj.D(II).S_T=[];
                    
                    obj.D(II).MS_X=[];
                    obj.D(II).MS_Y=[];
                    obj.D(II).MS_T=[];
                end
                
                if(~isempty(obj.D(II).BPMRawData_H))
                    L=size(obj.D(II).BPMRawData_H,1)/3;
                    X=obj.D(II).BPMRawData_H(1:L,:);
                    Y=obj.D(II).BPMRawData_H(L+(1:L),:);
                    T=obj.D(II).BPMRawData_H(2*L+(1:L),:);
                    obj.D(II).MH_X=NaN*ones(size(X,1),1);
                    obj.D(II).MH_Y=NaN*ones(size(Y,1),1);
                    obj.D(II).MH_T=NaN*ones(size(T,1),1);
                    if(size(X,2)==1) %non c'e' molto da fare una size e' 1
                        obj.D(II).H_X=X;
                        obj.D(II).H_Y=Y;
                        obj.D(II).H_T=T;
                        
                        obj.D(II).MH_X=X;
                        obj.D(II).MH_Y=Y;
                        obj.D(II).MH_T=T;
                    else
                        for TT=1:size(X,1)
                            Xw=X(TT,~isnan(X(TT,:)));
                            Yw=Y(TT,~isnan(Y(TT,:)));
                            Tw=T(TT,~isnan(T(TT,:)));
                            
                            Xw(Tw<FilterTMIT)=[];
                            Yw(Tw<FilterTMIT)=[];
                            Tw(Tw<FilterTMIT)=[];
                            
                            if(isempty(Xw))
                                obj.D(II).MH_X(TT)=NaN;
                            else
                                obj.D(II).MH_X(TT)=mean(Xw,2);
                            end
                            
                            if(isempty(Yw))
                                obj.D(II).MH_Y(TT)=NaN;
                            else
                                obj.D(II).MH_Y(TT)=mean(Yw,2);
                            end
                            
                            if(isempty(Tw))
                                obj.D(II).MH_T(TT)=NaN;
                            else
                                obj.D(II).MH_T(TT)=mean(Tw,2);
                            end
                           
                        end
                        
                        if(ExcludeNaN)
                            RemX=isnan(sum(X));
                            RemY=isnan(sum(Y));
                            RemT=isnan(sum(T));
                        
                            RemT2=any(T<FilterTMIT);

                            X(:,RemX | RemY | RemT | RemT2)=[];
                            Y(:,RemX | RemY | RemT | RemT2)=[];
                            T(:,RemX | RemY | RemT | RemT2)=[];
                            
                            XS=std(X,[],2);
                            YS=std(Y,[],2);
                            XM=mean(X,2);
                            YM=mean(Y,2);

                            RemXS=any(((X-XM*ones(size(X(1,:))) - rmsFilter*XS*ones(size(X(1,:))))>0) | ((X-XM*ones(size(X(1,:))) + rmsFilter*XS*ones(size(X(1,:))))<0));
                            RemYS=any(((Y-YM*ones(size(Y(1,:))) - rmsFilter*YS*ones(size(Y(1,:))))>0) | ((Y-YM*ones(size(X(1,:))) + rmsFilter*YS*ones(size(Y(1,:))))<0));

                            X(:,RemXS | RemYS)=[];
                            Y(:,RemXS | RemYS)=[];
                            T(:,RemXS | RemYS)=[];
                        end
                        obj.D(II).H_X=X;
                        obj.D(II).H_Y=Y;
                        obj.D(II).H_T=T;
                    end
                else
                    obj.D(II).H_X=[];
                    obj.D(II).H_Y=[];
                    obj.D(II).H_T=[];
                    
                    obj.D(II).MH_X=[];
                    obj.D(II).MH_Y=[];
                    obj.D(II).MH_T=[];
                end
                
            end
        end
                
        function makeStatic(obj,Lines)
            disp('Making Static Structure...')
            devList={'BEND','BPMS','QUAD','XCOR','YCOR','USEG','PHAS','XEFC','YEFC','BTRM'};
            use_sort_Z=1;
            if(any(strcmp(Lines,'S')) || any(strcmp(Lines,'SXR')))
                obj.staticS=bba2_init('sector','CU_SXR','devList',devList,'beampath','CU_SXR','sortZ',use_sort_Z);
            end
            if(any(strcmp(Lines,'H')) || any(strcmp(Lines,'HXR')))
                obj.staticH=bba2_init('sector','CU_HXR','devList',devList,'beampath','CU_HXR','sortZ',use_sort_Z);
            end
            obj.makeStaticFromSandH();
        end
        
        function loadModelFromFile(obj,Filename)
            fileData=load(Filename);
            if(isfield(fileData,'MODEL_S'))
                obj.MODEL_S=fileData.MODEL_S;
                obj.MODEL_S.Pos=fileData.PosS;
            end
            if(isfield(fileData,'MODEL_H'))
                obj.MODEL_H=fileData.MODEL_H;
                obj.MODEL_H.Pos=fileData.PosH;
            end
        end
        function loadStaticFromFile(obj,Filename)
            fileData=load(Filename);
            if(isfield(fileData,'staticS'))
                obj.staticS=fileData.staticS;
            end
            if(isfield(fileData,'staticH'))
                obj.staticH=fileData.staticH;
            end
            if(isfield(fileData,'StaticS'))
                obj.staticS=fileData.StaticS;
            end
            if(isfield(fileData,'StaticH'))
                obj.staticS=fileData.StaticH;
            end
            obj.makeStaticFromSandH();
        end
        
        function takeModel(obj,ID)
            if(~isempty(obj.staticS) && ~isempty(obj.staticH))
                PosS.nBPM=length(obj.staticS.bpmList);PosS.nQuad=length(obj.staticS.quadList);PosS.nCorr=length(obj.staticS.corrList);PosS.nUnd=length(obj.staticS.undList);
                [~, MP] = min(obj.staticS.zBPM);
                StartBPM_S=obj.staticS.bpmList{MP};
                ToListS=[obj.staticS.bpmList;obj.staticS.quadList;obj.staticS.quadList;obj.staticS.corrList;obj.staticS.undList;obj.staticS.undList];
                PosList_S=[repmat({'POSB=END'},length(obj.staticS.bpmList),1);repmat({'POSB=BEG'},length(obj.staticS.quadList),1);repmat({'POSB=END'},length(obj.staticS.quadList),1);repmat({'POSB=END'},length(obj.staticS.corrList),1);repmat({'POSB=BEG'},length(obj.staticS.undList),1);repmat({'POSB=END'},length(obj.staticS.undList),1)];
                PosS.Bpm=1:PosS.nBPM;PosS.QuadBeg=PosS.nBPM+(1:PosS.nQuad);PosS.QuadEnd=PosS.nBPM+PosS.nQuad+(1:PosS.nQuad);PosS.Corr=PosS.nBPM+2*PosS.nQuad+(1:PosS.nCorr);PosS.UndBeg=PosS.nBPM+2*PosS.nQuad+PosS.nCorr+(1:PosS.nUnd);PosS.UndEnd=PosS.nBPM+2*PosS.nQuad+PosS.nCorr+PosS.nUnd+(1:PosS.nUnd);
                
                PosH.nBPM=length(obj.staticH.bpmList);PosH.nQuad=length(obj.staticH.quadList);PosH.nCorr=length(obj.staticH.corrList);PosH.nUnd=length(obj.staticH.undList);
                [~, MP] = min(obj.staticH.zBPM);
                StartBPM_H=obj.staticH.bpmList{MP};
                ToListH=[obj.staticH.bpmList;obj.staticH.quadList;obj.staticH.quadList;obj.staticH.corrList;obj.staticH.undList;obj.staticH.undList];
                PosList_H=[repmat({'POSB=END'},length(obj.staticH.bpmList),1);repmat({'POSB=BEG'},length(obj.staticH.quadList),1);repmat({'POSB=END'},length(obj.staticH.quadList),1);repmat({'POSB=END'},length(obj.staticH.corrList),1);repmat({'POSB=BEG'},length(obj.staticH.undList),1);repmat({'POSB=END'},length(obj.staticH.undList),1)];
                PosH.Bpm=1:PosH.nBPM;PosH.QuadBeg=PosH.nBPM+(1:PosH.nQuad);PosH.QuadEnd=PosH.nBPM+PosH.nQuad+(1:PosH.nQuad);PosH.Corr=PosH.nBPM+2*PosH.nQuad+(1:PosH.nCorr);PosH.UndBeg=PosH.nBPM+2*PosH.nQuad+PosH.nCorr+(1:PosH.nUnd);PosH.UndEnd=PosH.nBPM+2*PosH.nQuad+PosH.nCorr+PosH.nUnd+(1:PosH.nUnd);
                
                Options.MODEL_TYPE='TYPE=EXTANT'; Options.BEAMPATH_H=['BEAMPATH=','CU_HXR'];
                model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
                PlistH=PosList_H; PlistH{end+1}=Options.MODEL_TYPE; PlistH{end+1}=Options.BEAMPATH_H; PlistH{end+1}='SelPosUse=BBA';
                [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM_H,ToListH,PlistH);
                obj.MODEL_H=MODEL;
                obj.MODEL_H.Pos=PosH;
                
                Options.MODEL_TYPE='TYPE=EXTANT'; Options.BEAMPATH_S=['BEAMPATH=','CU_SXR'];
                model_init('SOURCE','MATLAB','beamPath','CU_SXR','useBdes',1);
                PlistS=PosList_S; PlistS{end+1}=Options.MODEL_TYPE; PlistS{end+1}=Options.BEAMPATH_S; PlistS{end+1}='SelPosUse=BBA';
                [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM_S,ToListS,PlistS);
                obj.MODEL_S=MODEL;
                obj.MODEL_S.Pos=PosS;
                
                CorrectorStrengths_H=lcaGetSmart(strcat(obj.staticH.corrList_e,':BCTRL'));
                CorrectorStrengths_S=lcaGetSmart(strcat(obj.staticS.corrList_e,':BCTRL'));
                
%                 obj.D(ID).BPMRawData_S=BPMRawData_S;
%                 obj.D(ID).ts_S=ts_S;
%                 obj.D(ID).BPMList_S=PvList_S;
%                 
%                 obj.D(ID).BPMRawData_H=BPMRawData_H;
%                 obj.D(ID).ts_H=ts_H;
%                 obj.D(ID).BPMList_H=PvList_H;
                
                obj.D(ID).MODEL_S=obj.MODEL_S;
                obj.D(ID).MODEL_H=obj.MODEL_H;
                obj.D(ID).CorrectorStrengths_H=CorrectorStrengths_H;
                obj.D(ID).CorrectorStrengths_S=CorrectorStrengths_S;
                
            elseif(~isempty(obj.staticS)) 
                PosS.nBPM=length(obj.staticS.bpmList);PosS.nQuad=length(obj.staticS.quadList);PosS.nCorr=length(obj.staticS.corrList);PosS.nUnd=length(obj.staticS.undList);
                [~, MP] = min(obj.staticS.zBPM);
                StartBPM_S=obj.staticS.bpmList{MP};
                ToListS=[obj.staticS.bpmList;obj.staticS.quadList;obj.staticS.quadList;obj.staticS.corrList;obj.staticS.undList;obj.staticS.undList];
                PosList_S=[repmat({'POSB=END'},length(obj.staticS.bpmList),1);repmat({'POSB=BEG'},length(obj.staticS.quadList),1);repmat({'POSB=END'},length(obj.staticS.quadList),1);repmat({'POSB=END'},length(obj.staticS.corrList),1);repmat({'POSB=BEG'},length(obj.staticS.undList),1);repmat({'POSB=END'},length(obj.staticS.undList),1)];
                PosS.Bpm=1:PosS.nBPM;PosS.QuadBeg=PosS.nBPM+(1:PosS.nQuad);PosS.QuadEnd=PosS.nBPM+PosS.nQuad+(1:PosS.nQuad);PosS.Corr=PosS.nBPM+2*PosS.nQuad+(1:PosS.nCorr);PosS.UndBeg=PosS.nBPM+2*PosS.nQuad+PosS.nCorr+(1:PosS.nUnd);PosS.UndEnd=PosS.nBPM+2*PosS.nQuad+PosS.nCorr+PosS.nUnd+(1:PosS.nUnd);
                
                Options.MODEL_TYPE='TYPE=EXTANT'; Options.BEAMPATH_S=['BEAMPATH=','CU_SXR'];
                model_init('SOURCE','MATLAB','beamPath','CU_SXR','useBdes',1);
                PlistS=PosList_S; PlistS{end+1}=Options.MODEL_TYPE; PlistS{end+1}=Options.BEAMPATH_S; PlistS{end+1}='SelPosUse=BBA';
                [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM_S,ToListS,PlistS);
                obj.MODEL_S=MODEL;
                obj.MODEL_S.Pos=PosS;
                CorrectorStrengths_S=lcaGetSmart(strcat(obj.staticS.corrList_e,':BCTRL'));
                obj.D(ID).MODEL_S=obj.MODEL_S;
                obj.D(ID).MODEL_H=[];
                obj.D(ID).CorrectorStrengths_H=[];
                obj.D(ID).CorrectorStrengths_S=CorrectorStrengths_S;
            elseif(~isempty(obj.staticH)) 
                PosH.nBPM=length(obj.staticH.bpmList);PosH.nQuad=length(obj.staticH.quadList);PosH.nCorr=length(obj.staticH.corrList);PosH.nUnd=length(obj.staticH.undList);
                [~, MP] = min(obj.staticH.zBPM);
                StartBPM_H=obj.staticH.bpmList{MP};
                ToListH=[obj.staticH.bpmList;obj.staticH.quadList;obj.staticH.quadList;obj.staticH.corrList;obj.staticH.undList;obj.staticH.undList];
                PosList_H=[repmat({'POSB=END'},length(obj.staticH.bpmList),1);repmat({'POSB=BEG'},length(obj.staticH.quadList),1);repmat({'POSB=END'},length(obj.staticH.quadList),1);repmat({'POSB=END'},length(obj.staticH.corrList),1);repmat({'POSB=BEG'},length(obj.staticH.undList),1);repmat({'POSB=END'},length(obj.staticH.undList),1)];
                PosH.Bpm=1:PosH.nBPM;PosH.QuadBeg=PosH.nBPM+(1:PosH.nQuad);PosH.QuadEnd=PosH.nBPM+PosH.nQuad+(1:PosH.nQuad);PosH.Corr=PosH.nBPM+2*PosH.nQuad+(1:PosH.nCorr);PosH.UndBeg=PosH.nBPM+2*PosH.nQuad+PosH.nCorr+(1:PosH.nUnd);PosH.UndEnd=PosH.nBPM+2*PosH.nQuad+PosH.nCorr+PosH.nUnd+(1:PosH.nUnd);
                
                Options.MODEL_TYPE='TYPE=EXTANT'; Options.BEAMPATH_H=['BEAMPATH=','CU_HXR'];
                model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
                PlistH=PosList_H; PlistH{end+1}=Options.MODEL_TYPE; PlistH{end+1}=Options.BEAMPATH_H; PlistH{end+1}='SelPosUse=BBA';
                [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM_H,ToListH,PlistH);
                obj.MODEL_H=MODEL;
                obj.MODEL_H.Pos=PosH;
                CorrectorStrengths_H=lcaGetSmart(strcat(obj.staticH.corrList_e,':BCTRL'));
                obj.D(ID).MODEL_H=obj.MODEL_H;
                obj.D(ID).MODEL_S=[];
                obj.D(ID).CorrectorStrengths_S=[];
                obj.D(ID).CorrectorStrengths_H=CorrectorStrengths_H;
            end
        end
        
        function takeSingleShotCAGET(obj,ID,Line)
            if(strcmpi(Line,'Hard'))
                BPMList_H=[strcat(obj.staticH.bpmList_e(:),':X');strcat(obj.staticH.bpmList_e(:),':Y');strcat(obj.staticH.bpmList_e(:),':TMIT')];
                [BPMRawData_H,ts]=lcaGet(BPMList_H);
                obj.D(ID).BPMRawData_H=BPMRawData_H;
                obj.D(ID).ts_H=double(ts) + double(imag(ts))/10^9;
                obj.D(ID).BPMList_H=BPMList_H;
                if(~isfield(obj.D(ID),'BPMRawData_S'))
                    obj.D(ID).BPMRawData_S=[];
                    obj.D(ID).ts_S=[];
                    obj.D(ID).BPMList_S=[];
                end
                obj.D(ID).CorrectorStrengths_S=lcaGetSmart(strcat(obj.staticS.corrList_e,':BCTRL'));
            elseif(strcmpi(Line,'Soft'))
                BPMList_S=[strcat(obj.staticS.bpmList_e(:),':X');strcat(obj.staticS.bpmList_e(:),':Y');strcat(obj.staticS.bpmList_e(:),':TMIT')];
                [BPMRawData_S,ts]=lcaGet(BPMList_S);
                obj.D(ID).BPMRawData_S=BPMRawData_S;
                obj.D(ID).ts_S=double(ts) + double(imag(ts))/10^9;
                obj.D(ID).BPMList_S=BPMList_S;
                if(~isfield(obj.D(ID),'BPMRawData_H'))
                    obj.D(ID).BPMRawData_H=[];
                    obj.D(ID).ts_H=[];
                    obj.D(ID).BPMList_H=[];
                end
                obj.D(ID).CorrectorStrengths_H=lcaGetSmart(strcat(obj.staticH.corrList_e,':BCTRL'));
            end           
        end
        
        function takeData(obj,ID,Samples,takeModel)
            if(~isempty(obj.staticS) && ~isempty(obj.staticH))
                BPMList_H=[strcat(obj.staticH.bpmList_e(:),':X');strcat(obj.staticH.bpmList_e(:),':Y');strcat(obj.staticH.bpmList_e(:),':TMIT')];
                TmitLocation_H=(2*length(obj.staticH.bpmList_e)/3+1):(length(obj.staticH.bpmList_e));

                BPMList_S=[strcat(obj.staticS.bpmList_e(:),':X');strcat(obj.staticS.bpmList_e(:),':Y');strcat(obj.staticS.bpmList_e(:),':TMIT')];
                TmitLocation_S=(2*length(obj.staticS.bpmList_e)/3+1):(length(obj.staticS.bpmList_e));
                
                eDefNumber_S=eDefReserve('Dual-Energy Steer Soft');
                eDefNumber_H=eDefReserve('Dual-Energy Steer Hard');
                RELEASE=1;

                eDefParams (eDefNumber_S, 1, Samples,[],[],[],[], 2);
                eDefParams (eDefNumber_H, 1, Samples,[],[],[],[], 1);

                eDefOn(eDefNumber_S);
                eDefOn(eDefNumber_H);
                
                if(takeModel)
                    PosS.nBPM=length(obj.staticS.bpmList);PosS.nQuad=length(obj.staticS.quadList);PosS.nCorr=length(obj.staticS.corrList);PosS.nUnd=length(obj.staticS.undList);
                    [~, MP] = min(obj.staticS.zBPM);
                    StartBPM_S=obj.staticS.bpmList{MP};
                    ToListS=[obj.staticS.bpmList;obj.staticS.quadList;obj.staticS.quadList;obj.staticS.corrList;obj.staticS.undList;obj.staticS.undList];
                    PosList_S=[repmat({'POSB=END'},length(obj.staticS.bpmList),1);repmat({'POSB=BEG'},length(obj.staticS.quadList),1);repmat({'POSB=END'},length(obj.staticS.quadList),1);repmat({'POSB=END'},length(obj.staticS.corrList),1);repmat({'POSB=BEG'},length(obj.staticS.undList),1);repmat({'POSB=END'},length(obj.staticS.undList),1)];
                    PosS.Bpm=1:PosS.nBPM;PosS.QuadBeg=PosS.nBPM+(1:PosS.nQuad);PosS.QuadEnd=PosS.nBPM+PosS.nQuad+(1:PosS.nQuad);PosS.Corr=PosS.nBPM+2*PosS.nQuad+(1:PosS.nCorr);PosS.UndBeg=PosS.nBPM+2*PosS.nQuad+PosS.nCorr+(1:PosS.nUnd);PosS.UndEnd=PosS.nBPM+2*PosS.nQuad+PosS.nCorr+PosS.nUnd+(1:PosS.nUnd);
                    
                    PosH.nBPM=length(obj.staticH.bpmList);PosH.nQuad=length(obj.staticH.quadList);PosH.nCorr=length(obj.staticH.corrList);PosH.nUnd=length(obj.staticH.undList);
                    [~, MP] = min(obj.staticH.zBPM);
                    StartBPM_H=obj.staticH.bpmList{MP};
                    ToListH=[obj.staticH.bpmList;obj.staticH.quadList;obj.staticH.quadList;obj.staticH.corrList;obj.staticH.undList;obj.staticH.undList];
                    PosList_H=[repmat({'POSB=END'},length(obj.staticH.bpmList),1);repmat({'POSB=BEG'},length(obj.staticH.quadList),1);repmat({'POSB=END'},length(obj.staticH.quadList),1);repmat({'POSB=END'},length(obj.staticH.corrList),1);repmat({'POSB=BEG'},length(obj.staticH.undList),1);repmat({'POSB=END'},length(obj.staticH.undList),1)];
                    PosH.Bpm=1:PosH.nBPM;PosH.QuadBeg=PosH.nBPM+(1:PosH.nQuad);PosH.QuadEnd=PosH.nBPM+PosH.nQuad+(1:PosH.nQuad);PosH.Corr=PosH.nBPM+2*PosH.nQuad+(1:PosH.nCorr);PosH.UndBeg=PosH.nBPM+2*PosH.nQuad+PosH.nCorr+(1:PosH.nUnd);PosH.UndEnd=PosH.nBPM+2*PosH.nQuad+PosH.nCorr+PosH.nUnd+(1:PosH.nUnd);
                    
                    Options.MODEL_TYPE='TYPE=EXTANT'; Options.BEAMPATH_H=['BEAMPATH=','CU_HXR'];
                    model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
                    PlistH=PosList_H; PlistH{end+1}=Options.MODEL_TYPE; PlistH{end+1}=Options.BEAMPATH_H; PlistH{end+1}='SelPosUse=BBA';
                    [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM_H,ToListH,PlistH);
                    obj.MODEL_H=MODEL;
                    obj.MODEL_H.Pos=PosH;
                    
                    Options.MODEL_TYPE='TYPE=EXTANT'; Options.BEAMPATH_S=['BEAMPATH=','CU_SXR'];
                    model_init('SOURCE','MATLAB','beamPath','CU_SXR','useBdes',1);
                    PlistS=PosList_S; PlistS{end+1}=Options.MODEL_TYPE; PlistS{end+1}=Options.BEAMPATH_S; PlistS{end+1}='SelPosUse=BBA';
                    [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM_S,ToListS,PlistS);
                    obj.MODEL_S=MODEL;
                    obj.MODEL_S.Pos=PosS;
                    
                    CorrectorStrengths_H=lcaGetSmart(strcat(obj.staticH.corrList_e,':BCTRL'));
                    CorrectorStrengths_S=lcaGetSmart(strcat(obj.staticS.corrList_e,':BCTRL'));
                end
                
                new_list_H=strcat(BPMList_H(:),'HST',num2str(eDefNumber_H));
                %    Non so se questa cosa serva minimamente...
                new_list_H{end+1} = sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',eDefNumber_H);
                new_list_H{end+1} = sprintf('PATT:%s:1:SECHST%d','SYS0',eDefNumber_H);
                new_list_H{end+1} = sprintf('PATT:%s:1:NSECHST%d','SYS0',eDefNumber_H);
                
                new_list_S=strcat(BPMList_S(:),'HST',num2str(eDefNumber_S));
                %    Non so se questa cosa serva minimamente...
                new_list_S{end+1} = sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',eDefNumber_S);
                new_list_S{end+1} = sprintf('PATT:%s:1:SECHST%d','SYS0',eDefNumber_S);
                new_list_S{end+1} = sprintf('PATT:%s:1:NSECHST%d','SYS0',eDefNumber_S);
                dataok=0;

                %while(~dataok)
                
                done=eDefDone(eDefNumber_S) && eDefDone(eDefNumber_H);
                while(~done)
                    pause(0.01);
                    done=eDefDone(eDefNumber_S) && eDefDone(eDefNumber_H);
                end
                
                ReadOut_S=lcaGet(new_list_S); ReadOut_S=ReadOut_S(:,1:Samples);
                ReadOut_H=lcaGet(new_list_H); ReadOut_H=ReadOut_H(:,1:Samples);
                data_ok=1; 
                
                eDefRelease(eDefNumber_H);
                eDefRelease(eDefNumber_S);
                

                BPMRawData_S=ReadOut_S(1:end-3,:);
                ts_S=double(ReadOut_S(end-1,:)) + double(ReadOut_S(end,:))/10^9;
                PvList_S=new_list_S(1:end-3);
                
                BPMRawData_H=ReadOut_H(1:end-3,:);
                ts_H=double(ReadOut_H(end-1,:)) + double(ReadOut_H(end,:))/10^9;
                PvList_H=new_list_H(1:end-3);
                
                obj.D(ID).BPMRawData_S=BPMRawData_S;
                obj.D(ID).ts_S=ts_S;
                obj.D(ID).BPMList_S=PvList_S;
                
                obj.D(ID).BPMRawData_H=BPMRawData_H;
                obj.D(ID).ts_H=ts_H;
                obj.D(ID).BPMList_H=PvList_H;
                
                obj.D(ID).MODEL_S=obj.MODEL_S;
                obj.D(ID).MODEL_H=obj.MODEL_H;
                obj.D(ID).CorrectorStrengths_H=CorrectorStrengths_H;
                obj.D(ID).CorrectorStrengths_S=CorrectorStrengths_S;
                
            elseif(~isempty(obj.staticS)) 
                BPMList_S=[strcat(obj.staticS.bpmList_e(:),':X');strcat(obj.staticS.bpmList_e(:),':Y');strcat(obj.staticS.bpmList_e(:),':TMIT')];
                TmitLocation_S=(2*length(obj.staticS.bpmList_e)/3+1):(length(obj.staticS.bpmList_e));
                
                eDefNumber_S=eDefReserve('Dual-Energy Steer Soft');
 
                RELEASE=1;

                eDefParams (eDefNumber_S, 1, Samples,[],[],[],[], 2);
   

                eDefOn(eDefNumber_S);
       
                
                if(takeModel)
                    PosS.nBPM=length(obj.staticS.bpmList);PosS.nQuad=length(obj.staticS.quadList);PosS.nCorr=length(obj.staticS.corrList);PosS.nUnd=length(obj.staticS.undList);
                    [~, MP] = min(obj.staticS.zBPM);
                    StartBPM_S=obj.staticS.bpmList{MP};
                    ToListS=[obj.staticS.bpmList;obj.staticS.quadList;obj.staticS.quadList;obj.staticS.corrList;obj.staticS.undList;obj.staticS.undList];
                    PosList_S=[repmat({'POSB=END'},length(obj.staticS.bpmList),1);repmat({'POSB=BEG'},length(obj.staticS.quadList),1);repmat({'POSB=END'},length(obj.staticS.quadList),1);repmat({'POSB=END'},length(obj.staticS.corrList),1);repmat({'POSB=BEG'},length(obj.staticS.undList),1);repmat({'POSB=END'},length(obj.staticS.undList),1)];
                    PosS.Bpm=1:PosS.nBPM;PosS.QuadBeg=PosS.nBPM+(1:PosS.nQuad);PosS.QuadEnd=PosS.nBPM+PosS.nQuad+(1:PosS.nQuad);PosS.Corr=PosS.nBPM+2*PosS.nQuad+(1:PosS.nCorr);PosS.UndBeg=PosS.nBPM+2*PosS.nQuad+PosS.nCorr+(1:PosS.nUnd);PosS.UndEnd=PosS.nBPM+2*PosS.nQuad+PosS.nCorr+PosS.nUnd+(1:PosS.nUnd);
  
                    Options.MODEL_TYPE='TYPE=EXTANT'; Options.BEAMPATH_S=['BEAMPATH=','CU_SXR'];
                    model_init('SOURCE','MATLAB','beamPath','CU_SXR','useBdes',1);
                    PlistS=PosList_S; PlistS{end+1}=Options.MODEL_TYPE; PlistS{end+1}=Options.BEAMPATH_S; PlistS{end+1}='SelPosUse=BBA';
                    [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM_S,ToListS,PlistS);
                    obj.MODEL_S=MODEL;
                    obj.MODEL_S.Pos=PosS;
 
                    CorrectorStrengths_S=lcaGetSmart(strcat(obj.staticS.corrList_e,':BCTRL'));
                end
 
                
                new_list_S=strcat(BPMList_S(:),'HST',num2str(eDefNumber_S));
                %    Non so se questa cosa serva minimamente...
                new_list_S{end+1} = sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',eDefNumber_S);
                new_list_S{end+1} = sprintf('PATT:%s:1:SECHST%d','SYS0',eDefNumber_S);
                new_list_S{end+1} = sprintf('PATT:%s:1:NSECHST%d','SYS0',eDefNumber_S);
                dataok=0;

                %while(~dataok)
                
                done=eDefDone(eDefNumber_S);  
                while(~done)
                    pause(0.01);
                    done=eDefDone(eDefNumber_S) ;
                end
                
                ReadOut_S=lcaGet(new_list_S); ReadOut_S=ReadOut_S(:,1:Samples);
 
                data_ok=1; 
                
         
                eDefRelease(eDefNumber_S);
                
                BPMRawData_S=ReadOut_S(1:end-3,:);
                ts_S=double(ReadOut_S(end-1,:)) + double(ReadOut_S(end,:))/10^9;
                PvList_S=new_list_S(1:end-3);
    
                obj.D(ID).BPMRawData_S=BPMRawData_S;
                obj.D(ID).ts_S=ts_S;
                obj.D(ID).BPMList_S=PvList_S;
                
                obj.D(ID).BPMRawData_H=[];
                obj.D(ID).ts_H=[];
                obj.D(ID).BPMList_H=[];
                
                obj.D(ID).MODEL_S=obj.MODEL_S;
                obj.D(ID).MODEL_H=[];
                obj.D(ID).CorrectorStrengths_H=[];
                obj.D(ID).CorrectorStrengths_S=CorrectorStrengths_S;
                
            elseif(~isempty(obj.staticH))
                BPMList_H=[strcat(obj.staticH.bpmList_e(:),':X');strcat(obj.staticH.bpmList_e(:),':Y');strcat(obj.staticH.bpmList_e(:),':TMIT')];
                TmitLocation_H=(2*length(obj.staticH.bpmList_e)/3+1):(length(obj.staticH.bpmList_e));
 
                eDefNumber_H=eDefReserve('Dual-Energy Steer Hard');
                RELEASE=1;
 
                eDefParams (eDefNumber_H, 1, Samples,[],[],[],[], 1);
 
                eDefOn(eDefNumber_H);
                
                if(takeModel)
 
                    PosH.nBPM=length(obj.staticH.bpmList);PosH.nQuad=length(obj.staticH.quadList);PosH.nCorr=length(obj.staticH.corrList);PosH.nUnd=length(obj.staticH.undList);
                    [~, MP] = min(obj.staticH.zBPM);
                    StartBPM_H=obj.staticH.bpmList{MP};
                    ToListH=[obj.staticH.bpmList;obj.staticH.quadList;obj.staticH.quadList;obj.staticH.corrList;obj.staticH.undList;obj.staticH.undList];
                    PosList_H=[repmat({'POSB=END'},length(obj.staticH.bpmList),1);repmat({'POSB=BEG'},length(obj.staticH.quadList),1);repmat({'POSB=END'},length(obj.staticH.quadList),1);repmat({'POSB=END'},length(obj.staticH.corrList),1);repmat({'POSB=BEG'},length(obj.staticH.undList),1);repmat({'POSB=END'},length(obj.staticH.undList),1)];
                    PosH.Bpm=1:PosH.nBPM;PosH.QuadBeg=PosH.nBPM+(1:PosH.nQuad);PosH.QuadEnd=PosH.nBPM+PosH.nQuad+(1:PosH.nQuad);PosH.Corr=PosH.nBPM+2*PosH.nQuad+(1:PosH.nCorr);PosH.UndBeg=PosH.nBPM+2*PosH.nQuad+PosH.nCorr+(1:PosH.nUnd);PosH.UndEnd=PosH.nBPM+2*PosH.nQuad+PosH.nCorr+PosH.nUnd+(1:PosH.nUnd);
                    
                    Options.MODEL_TYPE='TYPE=EXTANT'; Options.BEAMPATH_H=['BEAMPATH=','CU_HXR'];
                    model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
                    PlistH=PosList_H; PlistH{end+1}=Options.MODEL_TYPE; PlistH{end+1}=Options.BEAMPATH_H; PlistH{end+1}='SelPosUse=BBA';
                    [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM_H,ToListH,PlistH);
                    obj.MODEL_H=MODEL;
                    obj.MODEL_H.Pos=PosH;
 
                    
                    CorrectorStrengths_H=lcaGetSmart(strcat(obj.staticH.corrList_e,':BCTRL'));
 
                end
                
                new_list_H=strcat(BPMList_H(:),'HST',num2str(eDefNumber_H));
                %    Non so se questa cosa serva minimamente...
                new_list_H{end+1} = sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',eDefNumber_H);
                new_list_H{end+1} = sprintf('PATT:%s:1:SECHST%d','SYS0',eDefNumber_H);
                new_list_H{end+1} = sprintf('PATT:%s:1:NSECHST%d','SYS0',eDefNumber_H);
 
                dataok=0;

                %while(~dataok)
                
                done= eDefDone(eDefNumber_H);
                while(~done)
                    pause(0.01);
                    done= eDefDone(eDefNumber_H);
                end
 
                ReadOut_H=lcaGet(new_list_H); ReadOut_H=ReadOut_H(:,1:Samples);
                data_ok=1; 
                
                eDefRelease(eDefNumber_H);
                
                BPMRawData_H=ReadOut_H(1:end-3,:);
                ts_H=double(ReadOut_H(end-1,:)) + double(ReadOut_H(end,:))/10^9;
                PvList_H=new_list_H(1:end-3);
                
                obj.D(ID).BPMRawData_S=[];
                obj.D(ID).ts_S=[];
                obj.D(ID).BPMList_S=[];
                
                obj.D(ID).BPMRawData_H=BPMRawData_H;
                obj.D(ID).ts_H=ts_H;
                obj.D(ID).BPMList_H=PvList_H;
                
                obj.D(ID).MODEL_S=[];
                obj.D(ID).MODEL_H=obj.MODEL_H;
                obj.D(ID).CorrectorStrengths_H=CorrectorStrengths_H;
                obj.D(ID).CorrectorStrengths_S=[];
            else %nothing to do here...
                return
            end
                
            
        end        
        function loadOrbitFromFile(obj,ID,Filename)
            fileData=load(Filename);
            if(isfield(fileData,'BPMRawData_H'))
                obj.D(ID).BPMRawData_H=fileData.BPMRawData_H;
            else
                obj.D(ID).BPMRawData_H=[];
            end
            if(isfield(fileData,'CorrectorStrengths_S'))
               obj.D(ID).CorrectorStrengths_S=fileData.CorrectorStrengths_S;
            else
               obj.D(ID).CorrectorStrengths_S=[];
            end
            if(isfield(fileData,'BPMRawData_S'))
                obj.D(ID).BPMRawData_S=fileData.BPMRawData_S;
            else
                obj.D(ID).BPMRawData_S=[];
            end
            if(isfield(fileData,'CorrectorStrengths_H'))
               obj.D(ID).CorrectorStrengths_H=fileData.CorrectorStrengths_H;
            else
               obj.D(ID).CorrectorStrengths_H=[];
            end
            if(isfield(fileData,'staticS'))
               obj.D(ID).BPMList_S=[strcat(fileData.staticS.bpmList_e',':X');strcat(fileData.staticS.bpmList_e',':Y');strcat(fileData.staticS.bpmList_e',':TMIT')];
            else
               obj.D(ID).BPMList_S=[];
            end
            if(isfield(fileData,'staticH'))
               obj.D(ID).BPMList_H=[strcat(fileData.staticH.bpmList_e',':X');strcat(fileData.staticH.bpmList_e',':Y');strcat(fileData.staticH.bpmList_e',':TMIT')];
            else
               obj.D(ID).BPMList_H=[];
            end
            if(isfield(fileData,'staticS'))
               obj.D(ID).BPMList_S=[strcat(fileData.staticS.bpmList_e',':X');strcat(fileData.staticS.bpmList_e',':Y');strcat(fileData.staticS.bpmList_e',':TMIT')];
            else
               obj.D(ID).BPMList_S=[];
            end
            if(isfield(fileData,'staticH'))
               obj.D(ID).BPMList_H=[strcat(fileData.staticH.bpmList_e',':X');strcat(fileData.staticH.bpmList_e',':Y');strcat(fileData.staticH.bpmList_e',':TMIT')];
            else
               obj.D(ID).BPMList_H=[];
            end
            if(isfield(fileData,'MODEL_S'))
                obj.D(ID).MODEL_S=fileData.MODEL_S;
                obj.D(ID).MODEL_S.Pos=fileData.PosS;
            else
                obj.D(ID).MODEL_S=[];
            end
            if(isfield(fileData,'MODEL_H'))
                obj.D(ID).MODEL_H=fileData.MODEL_H;
                obj.D(ID).MODEL_H.Pos=fileData.PosH;
            else
                obj.D(ID).MODEL_H=[];
            end
        end
        
        
        function makeStaticFromSandH(obj)
            if(isempty(obj.staticS) && isempty(obj.staticH))
                return
            elseif(isempty(obj.staticS))
                obj.static=obj.staticH;
            elseif(isempty(obj.staticH))
                obj.static=obj.staticS;
            else
                Corr_All_e=[obj.staticH.corrList_e;obj.staticS.corrList_e];
                zCorr_All=[obj.staticH.zCorr(:);obj.staticS.zCorr(:)];
                Corr_All=[obj.staticH.corrList;obj.staticS.corrList];
                Corr_All_Range=[obj.staticH.corrRange;obj.staticS.corrRange];
                lCorr_All=0*zCorr_All;
                
                [Corr_Union_e,ORDER]=unique(Corr_All_e);
                zCorr_Union=zCorr_All(ORDER);
                Corr_Union=Corr_All(ORDER);
                lCorr_Union=lCorr_All(ORDER);
                corrRange_Union=Corr_All_Range(ORDER,:);
                
                
                [sortZ,sortPos]=sort(zCorr_Union,'ascend');
                obj.static.zCorr=sortZ;
                obj.static.lCorr=lCorr_Union(sortPos);
                obj.static.corrList=Corr_Union(sortPos);
                obj.static.corrRange=corrRange_Union(sortPos,:);
                
                obj.static.corrList_e=Corr_Union_e(sortPos);
                obj.static.sCorr=false(size(obj.static.corrList_e));
                obj.static.hCorr=false(size(obj.static.corrList_e));
                
                [~,WHI,~]=intersect(obj.static.corrList_e,obj.staticS.corrList_e,'stable');
                obj.static.sCorr(WHI)=true;
                [~,WHI,~]=intersect(obj.static.corrList_e,obj.staticH.corrList_e,'stable');
                obj.static.hCorr(WHI)=true;
                XorY=cellfun(@(x) x(1),obj.static.corrList_e);
                obj.static.corrList_e_shortname=regexprep(obj.static.corrList_e,'XCOR:','');
                obj.static.corrList_e_shortname=regexprep(obj.static.corrList_e_shortname,'YCOR:','');
                XPos=find(XorY=='X'); YPos=find(XorY=='Y');
                obj.static.X.corrList=obj.static.corrList(XPos);
                obj.static.X.zCorr=obj.static.zCorr(XPos);
                obj.static.X.lCorr=obj.static.lCorr(XPos);
                obj.static.X.corrList_e=obj.static.corrList_e(XPos);
                obj.static.X.corrList_e_shortname=obj.static.corrList_e_shortname(XPos);
                obj.static.X.sCorr=obj.static.sCorr(XPos);
                obj.static.X.hCorr=obj.static.hCorr(XPos);
                obj.static.X.corrRange=obj.static.corrRange(XPos,:);
                
                obj.static.Y.corrList=obj.static.corrList(YPos);
                obj.static.Y.zCorr=obj.static.zCorr(YPos);
                obj.static.Y.lCorr=obj.static.lCorr(YPos);
                obj.static.Y.corrList_e=obj.static.corrList_e(YPos);
                obj.static.Y.sCorr=obj.static.sCorr(YPos);
                obj.static.Y.hCorr=obj.static.hCorr(YPos);
                obj.static.Y.corrList_e_shortname=obj.static.corrList_e_shortname(YPos);
                obj.static.Y.corrRange=obj.static.corrRange(YPos,:);
                
                Bpm_All_e=[obj.staticH.bpmList_e;obj.staticS.bpmList_e];
                zBPM_All=[obj.staticH.zBPM(:);obj.staticS.zBPM(:)];
                Bpm_All=[obj.staticH.bpmList;obj.staticS.bpmList];
                lBPM_All=0*zBPM_All;
                
                [Bpm_Union_e,ORDER]=unique(Bpm_All_e);
                zBPM_Union=zBPM_All(ORDER);
                Bpm_Union=Bpm_All(ORDER);
                lBPM_Union=lBPM_All(ORDER);
                
                [sortZ,sortPos]=sort(zBPM_Union,'ascend');
                obj.static.zBPM=sortZ;
                obj.static.lBPM=lBPM_Union(sortPos);
                obj.static.bpmList=Bpm_Union(sortPos);
                
                obj.static.bpmList_e=Bpm_Union_e(sortPos);
                obj.static.sBpm=false(size(obj.static.bpmList_e));
                obj.static.hBpm=false(size(obj.static.bpmList_e));
                
                [~,WHI,~]=intersect(obj.static.bpmList_e,obj.staticS.bpmList_e,'stable');
                obj.static.sBpm(WHI)=true;
                [~,WHI,~]=intersect(obj.static.bpmList_e,obj.staticH.bpmList_e,'stable');
                obj.static.hBpm(WHI)=true;

            end
        end
    end
end