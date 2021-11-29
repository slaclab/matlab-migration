function fh=Steering_Functions()
    fh.steerOrbit=@steerOrbit;
    %fh.eLossBump=@eLossBump;
    fh.orbitBump=@orbitBump;
    fh.orbitBumpArray=@orbitBumpArray;
    fh.getBPMData_caget=@getBPMData_caget;
    fh.getBPMData_HB_timing=@getBPMData_HB_timing;
    fh.getBPMData_reserveBSA=@getBPMData_reserveBSA;
    fh.steer=@steer;
    fh.steerTrims=@steerTrims;
    fh.steer3Trims=@steer3Trims;
    fh.steerList=@steerList;
    fh.steerQuad=@steerQuad;
    fh.gapCorrectionFit=@gapCorrectionFit;
    fh.Build_BBA_Matrix=@Build_BBA_Matrix;
    fh.InitMatrix_Fast=@InitMatrix_Fast;
    fh.QuadOffsetMatrix_Fast=@QuadOffsetMatrix_Fast;
    fh.BPMOffsetMatrix=@BPMOffsetMatrix;
    fh.SolveBBA_System=@SolveBBA_System;
    fh.CorrectorOrbitMatrix_Fast=@CorrectorOrbitMatrix_Fast;
    fh.TrimsOrbitMatrix_Fast=@TrimsOrbitMatrix_Fast;
    fh.CorrectorAndTrimsOrbitMatrix_wYag_Fast=@CorrectorAndTrimsOrbitMatrix_wYag_Fast;
    fh.getModel=@getModel;
    fh.getModel_wBend=@getModel_wBend;
    fh.getModel_wAll=@getModel_wAll;
    fh.ConstrainMatrix=@ConstrainMatrix;
    fh.ApplyBBA=@ApplyBBA;
    fh.matchLaunchDoubleElimination=@matchLaunchDoubleElimination;
end

function [ReducedBaseline_POS, ReducedData_POS]=matchLaunchDoubleElimination(Baseline, Data, Weights, Sigmas)
if(nargin<4)
    Sigmas=1.5;
end
    STDData=std(Data); MDATA=mean(Data);
    STDBaseline=std(Baseline); MBaseline=mean(Baseline);
    KED=true(size(STDData,1),1); KEB=true(size(STDData,1),1);
    for II=1:size(STDData,2)
       KED=KED&(abs(Data(:,II)-MDATA(II))<(STDData(II)*Sigmas));
       KEB=KEB&(abs(Baseline(:,II)-MBaseline(II))<(STDBaseline(II)*Sigmas));
    end
    ReducedData_POS = find(KED);
    ReducedBaseline_POS = find(KEB);
    
    TARGET=mean(Data(ReducedData_POS,:));
    PartialBaseline=Baseline(ReducedBaseline_POS,:);
    KERef=1:length(ReducedBaseline_POS);
    
    AVERAGE=mean(PartialBaseline(KERef,:));
    Distance=sum(abs(AVERAGE-TARGET).*Weights);
    
    while(1)
        AVERAGE=mean(PartialBaseline(KERef,:));
        Distance=sum(abs(AVERAGE-TARGET).*Weights);
        ELEM=length(KERef);
        
        Couples=zeros(2,ELEM*(ELEM-1)-ELEM);
        STATE=1;
        for II=1:(ELEM-1)
            ss=ELEM-II+1;
            Couples(1,STATE:(STATE+ss-1))=II;
            Couples(2,STATE:(STATE+ss-1))=II:ELEM;
            STATE=STATE+length(II:ELEM);
        end
        Couples(:,(Couples(1,:)==Couples(2,:)))=[];
        
        Zoppas=zeros(length(AVERAGE),size(Couples,2));
        for JJ=1:length(AVERAGE)
           Zoppas(JJ,:) = sum(reshape(PartialBaseline(KERef(Couples),JJ),size(Couples)));
        end

        MVER=ver;
        if(~any(strfind(MVER(1).Release,'2012')))
            
            DISTANCES=sum(abs(TARGET-(AVERAGE*ELEM - Zoppas)/(ELEM-2)),1);
            [MV,MP]=min(DISTANCES);
            if(MV<Distance)
                KERef(Couples(:,MP))=[];
                Distance=MV;
            else
                break
            end
            length(KERef)
        else
            
            DISTANCES=Weights*(abs(repmat(TARGET.',[1,size(Zoppas,2)])-(repmat(AVERAGE.',[1,size(Zoppas,2)])*ELEM - Zoppas)/(ELEM-2)));
            [MV,MP]=min(DISTANCES);
            if(MV<Distance)
                KERef(Couples(:,MP))=[];
                Distance=MV;
            else
                break
            end
            length(KERef)
            
        end
    end
    
    ReducedBaseline_POS=ReducedBaseline_POS(KERef);
    %End Elimination here
end

function ApplyBBA(SolutionToBeApplied)
bykik_state=lcaGetSmart(SolutionToBeApplied.UL.Basic.bykikPV);
lcaPutSmart(SolutionToBeApplied.UL.Basic.bykikPV,SolutionToBeApplied.UL.Basic.bykik_On); pause(0.1);
% 
disp('Moving Quads');
moveQuadsSmoothly(SolutionToBeApplied.Line, SolutionToBeApplied.quadCells, SolutionToBeApplied.quadMoveList); %this applies the quadrupole motion.
pause(1);
bpm_X_NEW=SolutionToBeApplied.bpm_X_OLD+SolutionToBeApplied.bpm_X.';
bpm_Y_NEW=SolutionToBeApplied.bpm_Y_OLD+SolutionToBeApplied.bpm_Y.';

disp('Setting  BPM Offsets')

lcaPut(SolutionToBeApplied.bpmAOffsetsPV{1},bpm_X_NEW); lcaPut(SolutionToBeApplied.bpmAOffsetsPV{2},bpm_Y_NEW);
pause(1);
% restore bykik
lcaPutSmart(SolutionToBeApplied.UL.Basic.bykikPV,bykik_state); pause(0.1);
end

function [MODEL,Pos]=getModel(static,options)
    if(nargin==1), options=struct(); end
    if(~isfield(options,'BEAMPATH'))
        if (any(cellfun(@(x) any(strfind(x,'UNDS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'LTUS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'DMPS')),[static.bpmList_e;static.corrList_e])))
            options.BEAMPATH=['BEAMPATH=','CU_SXR'];
        else
            options.BEAMPATH=['BEAMPATH=','CU_HXR'];
        end 
    end
    if(any(strfind(options.BEAMPATH,'CU_SXR')))
        model_init('source','MATLAB','beamPath','CU_SXR','useBdes',1);
    elseif(any(strfind(options.BEAMPATH,'CU_HXR')))
        model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
    end
    
    Pos.nBPM=length(static.bpmList); Pos.nQuad=length(static.quadList); Pos.nCorr=length(static.corrList); Pos.nUnd=length(static.undList);
    [~, MP] = min(static.zBPM); StartBPM=static.bpmList{MP};

    ToList=[static.bpmList;static.quadList;static.quadList;static.corrList;static.undList;static.undList];
    PosList=[repmat({'POSB=END'},length(static.bpmList),1);repmat({'POSB=BEG'},length(static.quadList),1);repmat({'POSB=END'},length(static.quadList),1);repmat({'POSB=END'},length(static.corrList),1);repmat({'POSB=BEG'},length(static.undList),1);repmat({'POSB=END'},length(static.undList),1)];

    Pos.Bpm=1:Pos.nBPM;
    Pos.QuadBeg=Pos.nBPM+(1:Pos.nQuad);
    Pos.QuadEnd=Pos.nBPM+Pos.nQuad+(1:Pos.nQuad);
    Pos.Corr=Pos.nBPM+2*Pos.nQuad+(1:Pos.nCorr);
    Pos.UndBeg=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+(1:Pos.nUnd);
    Pos.UndEnd=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+Pos.nUnd+(1:Pos.nUnd);
   
    if(~isfield(options,'MODEL_TYPE')), options.MODEL_TYPE='TYPE=EXTANT'; end
    Plist=PosList; Plist{end+1}=options.MODEL_TYPE; Plist{end+1}=options.BEAMPATH; Plist{end+1}='SelPosUse=BBA';
    [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,Plist);
    MODEL.Pos=Pos;
end

function [MODEL,Pos]=getModel_wAll(static,options)
    if(nargin==1), options=struct(); end
    if(~isfield(options,'BEAMPATH'))
        if (any(cellfun(@(x) any(strfind(x,'UNDS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'LTUS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'DMPS')),[static.bpmList_e;static.corrList_e])))
            options.BEAMPATH=['BEAMPATH=','CU_SXR'];
        else
            options.BEAMPATH=['BEAMPATH=','CU_HXR'];
        end 
    end
    
    if(any(strfind(options.BEAMPATH,'CU_SXR')))
        model_init('source','MATLAB','beamPath','CU_SXR','useBdes',1);
    elseif(any(strfind(options.BEAMPATH,'CU_HXR')))
        model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
    end
    
    Pos.nBPM=length(static.bpmList); Pos.nQuad=length(static.quadList); Pos.nCorr=length(static.corrList); Pos.nUnd=length(static.undList); Pos.nBend=length(static.bendList); Pos.nYag=length(static.yagList);
    [~, MP] = min(static.zBPM); StartBPM=static.bpmList{MP};

    ToList=[static.bpmList;static.quadList;static.quadList;static.corrList;static.undList;static.undList;static.bendList;static.bendList;static.bendList;static.yagList];
    PosList=[repmat({'POSB=END'},length(static.bpmList),1);repmat({'POSB=BEG'},length(static.quadList),1);repmat({'POSB=END'},length(static.quadList),1);repmat({'POSB=END'},length(static.corrList),1);repmat({'POSB=BEG'},length(static.undList),1);repmat({'POSB=END'},length(static.undList),1);repmat({'POSB=BEG'},length(static.bendList),1);repmat({'POSB=END'},length(static.bendList),1);repmat({'POSB=MID'},length(static.bendList),1);repmat({'POSB=MID'},length(static.yagList),1)];

    Pos.Bpm=1:Pos.nBPM;
    Pos.QuadBeg=Pos.nBPM+(1:Pos.nQuad);
    Pos.QuadEnd=Pos.nBPM+Pos.nQuad+(1:Pos.nQuad);
    Pos.Corr=Pos.nBPM+2*Pos.nQuad+(1:Pos.nCorr);
    Pos.UndBeg=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+(1:Pos.nUnd);
    Pos.UndEnd=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+Pos.nUnd+(1:Pos.nUnd);
    Pos.BendBeg=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+2*Pos.nUnd+(1:Pos.nBend);
    Pos.BendEnd=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+2*Pos.nUnd+Pos.nBend+(1:Pos.nBend);
    Pos.BendMid=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+2*Pos.nUnd+2*Pos.nBend+(1:Pos.nBend);
    Pos.YagMid=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+2*Pos.nUnd+3*Pos.nBend+(1:Pos.nYag);
   
    if(~isfield(options,'MODEL_TYPE')), options.MODEL_TYPE='TYPE=EXTANT'; end
    Plist=PosList; Plist{end+1}=options.MODEL_TYPE; Plist{end+1}=options.BEAMPATH; Plist{end+1}='SelPosUse=BBA'; 
    [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,Plist);
    MODEL.Pos=Pos;
end

function [MODEL,Pos]=getModel_wBend(static,options)
    if(nargin==1), options=struct(); end
    if(~isfield(options,'BEAMPATH'))
        if (any(cellfun(@(x) any(strfind(x,'UNDS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'LTUS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'DMPS')),[static.bpmList_e;static.corrList_e])))
            options.BEAMPATH=['BEAMPATH=','CU_SXR'];
        else
            options.BEAMPATH=['BEAMPATH=','CU_HXR'];
        end 
    end
    
    if(any(strfind(options.BEAMPATH,'CU_SXR')))
        model_init('source','MATLAB','beamPath','CU_SXR','useBdes',1);
    elseif(any(strfind(options.BEAMPATH,'CU_HXR')))
        model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
    end
    
    Pos.nBPM=length(static.bpmList); Pos.nQuad=length(static.quadList); Pos.nCorr=length(static.corrList); Pos.nUnd=length(static.undList); Pos.nBend=length(static.bendList);
    [~, MP] = min(static.zBPM); StartBPM=static.bpmList{MP};

    ToList=[static.bpmList;static.quadList;static.quadList;static.corrList;static.undList;static.undList;static.bendList;static.bendList;static.bendList];
    PosList=[repmat({'POSB=END'},length(static.bpmList),1);repmat({'POSB=BEG'},length(static.quadList),1);repmat({'POSB=END'},length(static.quadList),1);repmat({'POSB=END'},length(static.corrList),1);repmat({'POSB=BEG'},length(static.undList),1);repmat({'POSB=END'},length(static.undList),1);repmat({'POSB=BEG'},length(static.bendList),1);repmat({'POSB=END'},length(static.bendList),1);repmat({'POSB=MID'},length(static.bendList),1)];

    Pos.Bpm=1:Pos.nBPM;
    Pos.QuadBeg=Pos.nBPM+(1:Pos.nQuad);
    Pos.QuadEnd=Pos.nBPM+Pos.nQuad+(1:Pos.nQuad);
    Pos.Corr=Pos.nBPM+2*Pos.nQuad+(1:Pos.nCorr);
    Pos.UndBeg=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+(1:Pos.nUnd);
    Pos.UndEnd=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+Pos.nUnd+(1:Pos.nUnd);
    Pos.BendBeg=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+2*Pos.nUnd+(1:Pos.nBend);
    Pos.BendEnd=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+2*Pos.nUnd+Pos.nBend+(1:Pos.nBend);
    Pos.BendMid=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+2*Pos.nUnd+2*Pos.nBend+(1:Pos.nBend);
   
    if(~isfield(options,'MODEL_TYPE')), options.MODEL_TYPE='TYPE=EXTANT'; end
    Plist=PosList; Plist{end+1}=options.MODEL_TYPE; Plist{end+1}=options.BEAMPATH; Plist{end+1}='SelPosUse=BBA';
    [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,Plist);
    MODEL.Pos=Pos;
end

function Solution=steerList(bpmList, corrList, options, target)
    %target is target.x and target.y with x and y of the length appropriate
    %for the bpmList passed.
    if(any(cellfun(@(x) any(x==':'),bpmList))) %it has columns, the guy passed epics names, better for him all of them and NOT device names, I need :X and :Y.
       static.bpmList_e=unique(cellfun(@(x) x(1:end-1),bpmList),'stable');
       static.bpmList=model_nameConvert(static.bpmList_e,'MAD'); %these are MAD names
       use_epics_bpm_names=1;
    else
       static.bpmList=bpmList(:);
       static.bpmList_e=model_nameConvert(static.bpmList);
       use_epics_bpm_names=0;
    end
    if(any(cellfun(@(x) any(x==':'),corrList))) %it is a epics vector. correctors have x and y embedded in their names, no so problem.
       static.corrList=model_nameConvert(corrList(:),'MAD');
       static.corrList_e=corrList(:);
    else
       static.corrList=corrList(:);
       static.corrList_e=model_nameConvert(static.corrList(:));
    end
    
    %Beam path selection. This is tedious, if one has a better idea help!
    if (any(cellfun(@(x) any(strfind(x,'UNDS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'LTUS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'DMPS')),[static.bpmList_e;static.corrList_e])))
        options.BEAMPATH=['BEAMPATH=','CU_SXR'];
    else
        options.BEAMPATH=['BEAMPATH=','CU_HXR'];
    end
    if(any(strfind(options.BEAMPATH,'CU_SXR')))
        model_init('source','MATLAB','beamPath','CU_SXR','useBdes',1);
    elseif(any(strfind(options.BEAMPATH,'CU_HXR')))
        model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
    end
    
    Z=model_rMatGet([static.bpmList;static.corrList],[],{'TYPE=DESIGN',options.BEAMPATH},'Z');
    static.zBPM=Z(1:length(static.bpmList));
    static.zCorr=Z((length(static.bpmList)+1):end);
    if(~isempty(static.zBPM))
        [~,zOrder]=sort(static.zBPM,'ascend');
        static.bpmList=static.bpmList(zOrder);
        static.bpmList_e=static.bpmList_e(zOrder);
        %static.lBPM=static.lBPM(zOrder);
        static.zBPM=static.zBPM(zOrder);
    end
    if(~isempty(static.zCorr))
        XorY=cellfun(@(x) x(1),static.corrList);
        xPos=find(XorY=='X'); yPos=find(XorY=='Y');
        [~,zxOrder]=sort(static.zCorr(xPos),'ascend');
        [~,zyOrder]=sort(static.zCorr(yPos),'ascend');
        static.corrList=[static.corrList(xPos(zxOrder));static.corrList(yPos(zyOrder))];
        static.corrList_e=[static.corrList_e(xPos(zxOrder));static.corrList_e(yPos(zyOrder))];
        %static.lCorr=[static.lCorr(xPos(zxOrder)),static.lCorr(yPos(zyOrder))];
        static.zCorr=[static.zCorr(xPos(zxOrder)),static.zCorr(yPos(zyOrder))];
    end
    static.corrRange(:,1)=lcaGetSmart(strcat(static.corrList_e,':BMIN'));
    static.corrRange(:,2)=lcaGetSmart(strcat(static.corrList_e,':BMAX'));
    
    if(use_epics_bpm_names)
        options.useBPMx=false(size(static.bpmList_e));
        options.useBPMy=false(size(static.bpmList_e));
        usex=intersect(strcat(static.bpmList,':X',bpmList),'stable');
        usey=intersect(strcat(static.bpmList,':Y',bpmList),'stable');
        options.useBPMx(usex)=true;
        options.useBPMy(usey)=true;
    else
        usex=true(size(static.bpmList_e));
        usey=true(size(static.bpmList_e));
        options.useBPMx=true(size(static.bpmList_e));
        options.useBPMy=true(size(static.bpmList_e));
    end
    options.useCorr=true(size(static.corrList));
    TARGET=zeros(length(static.bpmList),2);
    if(nargin>3)
        TARGET(usex)=target.x;
        TARGET(usey)=target.y;
    end
    static.quadList=[];
    static.undList=[];
    Solution=steer(static, options, TARGET);
end

function Solution=steer(static, options, target)
    %finds new correctors to steer to target orbit. If target is not
    %specified, target is 0. 
    %One can pass BPM data with options.BPMData, they should be a matrix of
    % [length static.bpmList x 2] size with average BPM position
    %optionally one can pass also options.BPMDataStd with std for each BPM. No
    %additional filtering will be done.
    %If not options.BPMData, then Data will be acquired within the function
    %there are three modes, at least one should be turned to 1, if you want
    %to choose how data is taken.
    %options.BSA_HB, options.BSA and options.CAGET
    %BSA_HB requires:
    %either options.startTime OR options.startTimePV AND
    %options.AcquisitionTime
    %BSA requires:
    %options.Samples, 
    %options.eDefBuffer is not mandatory if one has a reserved buffer can
    %use that.
    %CAGET requires a number of samples. No beam synchronicity is assured,
    %but is supposed to work at some extent if BSA is down
    %options.tmitMin is used to filter out data with too low tmit.
    %options.fitSVDRatio is used to select how to cut SVD coefficients
    %options.MODEL_TYPE to choose model for Model_rMatGet
    %options.BEAMPATH for same reason.
    %target is a structure, target.x must have length of the
    %trues of options.useBPMx if specified, otherwise of the static.bpmList 
    
    Do_Acquisition=1;
    
    if(isfield(options,'BPMData'))
        %NEED TO ADD PROPER VARIABLE NAMES...
        Do_Acquisition=0;
    else
        if(~isfield(options,'BSA_HB')), options.BSA_HB=0; else 
            if(options.BSA_HB)
                tic, 
                if(~isfield(options,'AcquisitionTime')), options.AcquisitionTime=1; end
                if(~isfield(options,'startTime')), [~,options.startTime]=lcaGetSmart(strcat(static.bpmList_e{1},':X')); end
            end
        end
        if(~isfield(options,'BSA')), options.BSA=0; end
        if(~isfield(options,'CAGET')), options.CAGET=0; end
        
        if(~options.BSA_HB && ~options.BSA && ~options.CAGET)
            options.BSA_HB=1;
            [~,options.startTime]=lcaGetSmart(strcat(static.bpmList_e{1},':X'));
            options.AcquisitionTime=1;
        end
        if(options.BSA)
            if(~isfield(options,'eDefBuffer')), options.eDefBuffer=NaN; end
            if(~isfield(options,'Samples')), options.Samples=60; end
            [BPMRawData,ts,PvList]=getBPMData_reserveBSA(static.bpmList_e, options.Samples, 1, options.eDefBuffer);
        end
        if(options.CAGET)
            if(~isfield(options,'Samples')), options.Samples=60; end
            [BPMRawData,ts,PvList]=getBPMData_caget(static.bpmList_e, options.Samples, 1);
        end
    end
    
    if(~isfield(options,'Simul')), options.Simul=0; end
    
    if(nargin<3)
        target=zeros(length(static.bpmList),2);
    end
    
    %Get the model here!
    %Only correctors to BPM are actually needed for steering, but the other
    %ones are left for future use.
    
    if(~isfield(options,'BEAMPATH'))
        if (any(cellfun(@(x) any(strfind(x,'UNDS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'LTUS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'DMPS')),[static.bpmList_e;static.corrList_e])))
            options.BEAMPATH=['BEAMPATH=','CU_SXR'];
        else
            options.BEAMPATH=['BEAMPATH=','CU_HXR'];
        end 
    end
    if(any(strfind(options.BEAMPATH,'CU_SXR')))
        model_init('source','MATLAB','beamPath','CU_SXR','useBdes',1);
    elseif(any(strfind(options.BEAMPATH,'CU_HXR')))
        model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
    end
    
    Pos.nBPM=length(static.bpmList); Pos.nQuad=length(static.quadList); Pos.nCorr=length(static.corrList); Pos.nUnd=length(static.undList);
    [~, MP] = min(static.zBPM); StartBPM=static.bpmList{MP};

    ToList=[static.bpmList;static.quadList;static.quadList;static.corrList;static.undList;static.undList];
    PosList=[repmat({'POSB=END'},length(static.bpmList),1);repmat({'POSB=BEG'},length(static.quadList),1);repmat({'POSB=END'},length(static.quadList),1);repmat({'POSB=END'},length(static.corrList),1);repmat({'POSB=BEG'},length(static.undList),1);repmat({'POSB=END'},length(static.undList),1)];

    Pos.Bpm=1:Pos.nBPM;
    Pos.QuadBeg=Pos.nBPM+(1:Pos.nQuad);
    Pos.QuadEnd=Pos.nBPM+Pos.nQuad+(1:Pos.nQuad);
    Pos.Corr=Pos.nBPM+2*Pos.nQuad+(1:Pos.nCorr);
    Pos.UndBeg=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+(1:Pos.nUnd);
    Pos.UndEnd=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+Pos.nUnd+(1:Pos.nUnd);
    
    if(~isfield(options,'Simul')), options.Simul=0; end
    
    if(~isfield(options,'rMat') && ~isfield(options,'MODEL'))
        if(options.Simul)
            [MODEL.rMat, MODEL.zPos, MODEL.lEff, MODEL.energy] = Get_Model_Simul(StartBPM,ToList,PosList);
        else
            if(~isfield(options,'MODEL_TYPE')), options.MODEL_TYPE='TYPE=EXTANT'; end
            Plist=PosList; Plist{end+1}=options.MODEL_TYPE; Plist{end+1}=options.BEAMPATH; Plist{end+1}='SelPosUse=BBA';
            [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,Plist);
%            MODEL.zPos=model_rMatGet(ToList,[],{'TYPE=DESIGN',options.BEAMPATH},'Z'); 
%            MODEL.lEff=model_rMatGet(ToList,[],{'TYPE=DESIGN',options.BEAMPATH},'LEFF');
            %[MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,{options.MODEL_TYPE,options.BEAMPATH},PosList);
        end
    elseif(isfield(options,'rMat'))
       if(~isfield(options,'MODEL_TYPE')), options.MODEL_TYPE='TYPE=EXTANT'; end
       if(~isfield(options,'zPos') || ~isfield(options,'lEff'))
           Plist=PosList; Plist{end+1}=options.MODEL_TYPE; Plist{end+1}=options.BEAMPATH; Plist{end+1}='SelPosUse=BBA';
           [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,Plist);
       end
       MODEL.rMat=options.rMat; 
       if(isfield(options,'energy'))
            MODEL.energy=options.energy;
       end
    elseif(isfield(options,'MODEL'))
        MODEL=options.MODEL;
    end
    
    if(~isfield(options,'useBPMx')),options.useBPMx=true(size(static.bpmList)); end
    if(~isfield(options,'useBPMy')),options.useBPMy=true(size(static.bpmList)); end
    if(~isfield(options,'useCorr')),options.useCorr=true(size(static.corrList)); end
    
    CorrectorStrengths=lcaGetSmart(strcat(static.corrList_e,':BCTRL'));
    [CorrMatrix,CorrMatrixAngles]=CorrectorOrbitMatrix_Fast(static,MODEL.rMat,Pos,MODEL.energy);
    
    if(options.BSA_HB) %then it is time to get your data...
        b=toc;
        while(b<options.AcquisitionTime)
            pause(0.025); b=toc;
        end
        [BPMRawData,ts,PvList]=getBPMData_HB_timing(static.bpmList_e, 1, options.startTime);
    end
    
    if(Do_Acquisition) %This will calculated avg X, avg Y, std X, std Y and filter TMIT
        BPMDataMeas=zeros(length(static.bpmList),2);
        BPMData=zeros(length(static.bpmList),2);
        BPMDataStd=zeros(length(static.bpmList),2);
        if(~isfield(options,'tmitMin')), options.tmitMin=-inf; end
        for II=1:Pos.nBPM %further exclude BPMs if they give NaNs (?)
            TempData=[BPMRawData(II,:);BPMRawData(II+Pos.nBPM,:);BPMRawData(II+2*Pos.nBPM,:)];
            TempData(:,any(isnan(TempData)))=[]; %Excludes NaN readings first
            if(isempty(TempData(3,:)>options.tmitMin))
                BPMData(II,1)=NaN;
                BPMDataStd(II,1)=NaN;
                BPMData(II,2)=NaN;
                BPMDataStd(II,2)=NaN;
                options.useBPMx(II)=false;
                options.useBPMy(II)=false;
                BPMDataMeas(II,1)=NaN;
                BPMDataMeas(II,2)=NaN;
            else
                BPMDataMeas(II,1)=mean(TempData(1,TempData(3,:)>options.tmitMin));
                BPMDataStd(II,1)=std(TempData(1,TempData(3,:)>options.tmitMin));
                BPMDataMeas(II,2)=mean(TempData(2,TempData(3,:)>options.tmitMin));
                BPMDataStd(II,2)=std(TempData(2,TempData(3,:)>options.tmitMin));
                
                BPMData(II,1)=BPMDataMeas(II,1) - target(II,1);
                BPMData(II,2)=BPMDataMeas(II,2) - target(II,2);
            end
        end
    end
  
    CorrMat=cell2mat(cellfun(@(x) x(1),static.corrList,'un',0));
    XCorrPos=find(CorrMat(options.useCorr,1)=='X');
    YCorrPos=find(CorrMat(options.useCorr,1)=='Y');
  
    useBPM=false(2*Pos.nBPM,1);
    useBPM(1:2:end)=options.useBPMx;
    useBPM(2:2:end)=options.useBPMy;
    
    SystemBPMData=zeros(2*Pos.nBPM,1);
    SystemBPMData(1:2:end)=BPMData(:,1); SystemBPMData(2:2:end)=BPMData(:,2);
    
    CorrMatrix_Reduced = CorrMatrix(useBPM,options.useCorr);
    if(~isfield(options,'fitSVDRatio')), options.fitSVDRatio=10^-5; end
    [SystemSolution,SystemSolution_Std] = util_lssvd(CorrMatrix_Reduced, SystemBPMData(useBPM), ones(size(BPMData(useBPM)))/10^6, options.fitSVDRatio); 
    
    SystemSolution=SystemSolution/1000;
    SystemSolution_Std=SystemSolution_Std/1000;
 
    Solution.SystemSolution=SystemSolution;
    Solution.SystemSolution_Std=SystemSolution_Std;
    Solution.OldCorr=CorrectorStrengths;
    
    Solution.OldCorrReset=CorrectorStrengths(options.useCorr);
    Solution.NewCorr=Solution.OldCorr(options.useCorr) - SystemSolution;
    Solution.OutOfRange=(Solution.NewCorr<static.corrRange(options.useCorr,1)) | (Solution.NewCorr>static.corrRange(options.useCorr,2));
    Solution.FAILED=any(Solution.OutOfRange);
    Solution.UsedCorr=static.corrList(options.useCorr);
    Solution.UsedCorr_e=static.corrList_e(options.useCorr);
    
    Solution.X.NewCorr=Solution.NewCorr(XCorrPos);
    Solution.X.OutOfRange=Solution.OutOfRange(XCorrPos);
    Solution.X.FAILED=any(Solution.X.OutOfRange);
    Solution.X.UsedCorr=Solution.UsedCorr(XCorrPos);
    Solution.X.UsedCorr_e=Solution.UsedCorr_e(XCorrPos);
    
    Solution.Y.NewCorr=Solution.NewCorr(YCorrPos);
    Solution.Y.OutOfRange=Solution.OutOfRange(YCorrPos);
    Solution.Y.FAILED=any(Solution.Y.OutOfRange);
    Solution.Y.UsedCorr=Solution.UsedCorr(YCorrPos);
    Solution.Y.UsedCorr_e=Solution.UsedCorr_e(YCorrPos);
    
    Solution.RecordedOrbitMinusTarget=BPMData;
    Solution.RecordedOrbit=BPMDataMeas;
    Solution.RecordedOrbitStd=BPMDataStd;
    Solution.options=options;
    
    Solution.MODEL=MODEL;
    Solution.MODEL.CorrMatrix=CorrMatrix;
    Solution.MODEL.CorrMatrixAngles=CorrMatrixAngles;
    
    
    %Evaluate unappplicable solution if correcors are railed
    Solution.Unapplayed=(static.corrRange(options.useCorr,1)+Solution.NewCorr).*(static.corrRange(options.useCorr,1)<Solution.NewCorr) + (static.corrRange(options.useCorr,2)-Solution.NewCorr).*(static.corrRange(options.useCorr,2)>Solution.NewCorr);
    Solution.DeltaCorrectors=zeros(size(static.corrList)); Solution.DeltaCorrectors(options.useCorr)=Solution.Unapplayed - SystemSolution;
    Solution.DeltaBPMIfApplied=Solution.MODEL.CorrMatrix*Solution.DeltaCorrectors*1000;
    Solution.orbitXChanges=Solution.DeltaBPMIfApplied(1:2:end);
    Solution.orbitYChanges=Solution.DeltaBPMIfApplied(2:2:end);
    Solution.newOrbitX=BPMDataMeas(:,1)+Solution.orbitXChanges;
    Solution.newOrbitY=BPMDataMeas(:,2)+Solution.orbitYChanges;
    
    if(isfield(options,'ApplyAndForget'))
       if(options.ApplyAndForget)
            lcaPutSmart(strcat(Solution.UsedCorr_e,':BCTRL'),Solution.NewCorr)
       end
    end
end

function Solution=gapCorrectionFit(static, options)
%specialized function to find corrector solution to steer flat, from data
%and model already acquired. options.Launch is used to fit (1) or not (2) the
%launch or to filter it to "zero" (3) from the data itself. It has ben
%written for gap correction software.
Pos=options.MODEL.Pos;
MODEL=options.MODEL;

[CorrMatrix,CorrMatrixAngles]=CorrectorOrbitMatrix_Fast(static,MODEL.rMat,Pos,MODEL.energy);
BPMMatrix=BPMOffsetMatrix(static);

save GapCorrection -v7.3

Orbits=options.Orbit; Reference=options.Reference; ins=0;
%Clear evenutal NaN's. 
DIFFx=max(abs(diff(Orbits.X,1,1))); TEMP=sort(DIFFx); THRx=TEMP(round(length(TEMP)/5*4));
DIFFy=max(abs(diff(Orbits.Y,1,1))); TEMP=sort(DIFFy); THRy=TEMP(round(length(TEMP)/5*4));
DELETE=((DIFFy>THRy) | (DIFFx>THRx) | any(isnan(Orbits.X)) | (any(isnan(Orbits.Y))) | (any(isnan(Orbits.EnergyBPMs))));
Orbits.X(:,DELETE)=[]; Orbits.Y(:,DELETE)=[]; Orbits.XLaunch(:,DELETE)=[]; Orbits.YLaunch(:,DELETE)=[];
Orbits.XAngle(:,DELETE)=[]; Orbits.YAngle(:,DELETE)=[]; Orbits.EnergyBPMs(:,DELETE)=[]; 

DIFFx=max(abs(diff(Reference.X,1,1))); TEMP=sort(DIFFx); THRx=TEMP(round(length(TEMP)/5*4));
DIFFy=max(abs(diff(Reference.Y,1,1))); TEMP=sort(DIFFy); THRy=TEMP(round(length(TEMP)/5*4));
DELETE=((DIFFy>THRy) | (DIFFx>THRx) | any(isnan(Reference.X)) | (any(isnan(Reference.Y))) | (any(isnan(Reference.EnergyBPMs))));
Reference.X(:,DELETE)=[]; Reference.Y(:,DELETE)=[]; Reference.XLaunch(:,DELETE)=[]; Reference.YLaunch(:,DELETE)=[];
Reference.XAngle(:,DELETE)=[]; Reference.YAngle(:,DELETE)=[]; Reference.EnergyBPMs(:,DELETE)=[]; 

MeanOrbitsEnergy1=mean(Orbits.EnergyBPMs(1,:));
MeanOrbitsEnergy2=mean(Orbits.EnergyBPMs(2,:));

KEOrb=find((abs(Orbits.EnergyBPMs(1,:) - MeanOrbitsEnergy1) < options.thresholds(1)/2) & (abs(Orbits.EnergyBPMs(2,:) - MeanOrbitsEnergy2) < options.thresholds(1)/2));
MeanOrbitsEnergy1=mean(Orbits.EnergyBPMs(1,KEOrb));
MeanOrbitsEnergy2=mean(Orbits.EnergyBPMs(2,KEOrb));

OrbitsLaunchX=mean(Orbits.XLaunch(:,KEOrb),2);
OrbitsLaunchY=mean(Orbits.YLaunch(:,KEOrb),2);
OrbitsXAngle=mean(Orbits.XAngle(:,KEOrb),2);
OrbitsYAngle=mean(Orbits.YAngle(:,KEOrb),2);

KERef=find((abs(Reference.EnergyBPMs(1,:) - MeanOrbitsEnergy1) < options.thresholds(1)/2) & (abs(Reference.EnergyBPMs(2,:) - MeanOrbitsEnergy2) < options.thresholds(1)/2));

MeanReferenceEnergy1=mean(Reference.EnergyBPMs(1,:));
MeanReferenceEnergy2=mean(Reference.EnergyBPMs(2,:));

while(1)
ReferenceLaunchX=mean(Reference.XLaunch(:,KERef),2);
ReferenceLaunchY=mean(Reference.YLaunch(:,KERef),2);
ReferenceXAngle=mean(Reference.XAngle(:,KERef),2);
ReferenceYAngle=mean(Reference.YAngle(:,KERef),2);
Distance=sum(abs(OrbitsLaunchX-ReferenceLaunchX) + abs(OrbitsLaunchY-ReferenceLaunchY) + abs(OrbitsXAngle-ReferenceXAngle) + abs(OrbitsYAngle-ReferenceYAngle));


TARGET=[OrbitsLaunchX;OrbitsLaunchY;OrbitsXAngle;OrbitsYAngle];
AVERAGE=[ReferenceLaunchX;ReferenceLaunchY;ReferenceXAngle;ReferenceYAngle];
ELEM=length(KERef);

Couples=zeros(2,ELEM*(ELEM-1)-ELEM);
STATE=1;
for II=1:(ELEM-1)
   ss=ELEM-II+1;
   Couples(1,STATE:(STATE+ss-1))=II; 
   Couples(2,STATE:(STATE+ss-1))=II:ELEM;
   STATE=STATE+length(II:ELEM);
end
Couples(:,(Couples(1,:)==Couples(2,:)))=[];

Zoppas=zeros(6,size(Couples,2));

Zoppas(1,:)=sum(reshape(Reference.XLaunch(1,KERef(Couples)),size(Couples)));
Zoppas(2,:)=sum(reshape(Reference.XLaunch(2,KERef(Couples)),size(Couples)));
Zoppas(3,:)=sum(reshape(Reference.YLaunch(1,KERef(Couples)),size(Couples)));
Zoppas(4,:)=sum(reshape(Reference.YLaunch(2,KERef(Couples)),size(Couples)));
Zoppas(5,:)=sum(reshape(Reference.XAngle(1,KERef(Couples)),size(Couples)));
Zoppas(6,:)=sum(reshape(Reference.YAngle(1,KERef(Couples)),size(Couples)));
MVER=ver;
if(~any(strfind(MVER(1).Release,'2012')))
    
    DISTANCES=sum(abs(TARGET-(AVERAGE*ELEM - Zoppas)/(ELEM-2)),1);
    [MV,MP]=min(DISTANCES);
    if(MV<Distance)
        KERef(Couples(:,MP))=[];
        Distance=MV;
    else
        break
    end
    length(KERef)
else
    [XXX,YYY]=size(Zoppas);
    
    DISTANCES=sum(abs(TARGET-(AVERAGE*ELEM - Zoppas)/(ELEM-2)),1);
    [MV,MP]=min(DISTANCES);
    if(MV<Distance)
        KERef(Couples(:,MP))=[];
        Distance=MV;
    else
        break
    end
    length(KERef)
    
end
end
% Remove=NaN;
% Distance=sum(abs(OrbitsLaunchX-ReferenceLaunchX) + abs(OrbitsLaunchY-ReferenceLaunchY) + abs(OrbitsXAngle-ReferenceXAngle) + abs(OrbitsYAngle-ReferenceYAngle));
% DistanceM=Distance;
% while(1)
%     disp(length(KERef))
%     for II=1:length(KERef)
%         TKERef=KERef;
%         TKERef(II)=[];
%         TReferenceLaunchX=mean(Reference.XLaunch(:,TKERef),2);
%         TReferenceLaunchY=mean(Reference.YLaunch(:,TKERef),2);
%         TReferenceXAngle=mean(Reference.XAngle(:,TKERef),2);
%         TReferenceYAngle=mean(Reference.YAngle(:,TKERef),2);
%         TDistance=sum(abs(OrbitsLaunchX-TReferenceLaunchX) + abs(OrbitsLaunchY-TReferenceLaunchY) + abs(OrbitsXAngle-TReferenceXAngle) + abs(OrbitsYAngle-TReferenceYAngle));
%         if(TDistance<DistanceM)
%             Remove=II;
%         end
%     end
%     if(~isnan(Remove))
%         KERef(Remove)=[];
%         ReferenceLaunchX=mean(Reference.XLaunch(:,KERef),2);
%         ReferenceLaunchY=mean(Reference.YLaunch(:,KERef),2);
%         ReferenceXAngle=mean(Reference.XAngle(:,KERef),2);
%         ReferenceYAngle=mean(Reference.YAngle(:,KERef),2);
%         Distance=sum(abs(OrbitsLaunchX-ReferenceLaunchX) + abs(OrbitsLaunchY-ReferenceLaunchY) + abs(OrbitsXAngle-ReferenceXAngle) + abs(OrbitsYAngle-ReferenceYAngle));
%         DistanceM=Distance;
%         Remove=NaN;
%     else
%         break
%     end
% end

% 
% for II=1:size(Orbits.EnergyBPMs,2)
%    DistanceEnergy=sum(abs(Orbits.EnergyBPMs(:,II)*ones(1,size(Reference.EnergyBPMs,2)) - Reference.EnergyBPMs),1); 
%    DistanceLaunchPos=sum(abs(Orbits.XLaunch(:,II)*ones(1,size(Reference.XLaunch,2)) - Reference.XLaunch),1) + sum(abs(Orbits.YLaunch(:,II)*ones(1,size(Reference.YLaunch,2)) - Reference.YLaunch),1);
%    DistanceLaunchAngle=sum(abs(Orbits.XAngle(:,II)*ones(1,size(Reference.XAngle,2)) - Reference.XAngle),1) + sum(abs(Orbits.YAngle(:,II)*ones(1,size(Reference.YAngle,2)) - Reference.YAngle),1);
%    
%    OverallSimilarity= DistanceLaunchPos + DistanceLaunchAngle;
%    
%    OK{II}=find(DistanceEnergy < options.thresholds(1));
%    OKValues(II)=length(OK{II});
%    LOK(II)=length(OK{II});
%    
%    if(OKValues(II))
%         [SortedDistance{II},SortedOrder{II}]=sort(OverallSimilarity(OK{II}),'ascend');
%         
%         ins=ins+1;
%         SimilarShots.Measurement.x(:,ins)=Orbits.X(:,II);
%         SimilarShots.Measurement.y(:,ins)=Orbits.Y(:,II);
%         SimilarShots.Baseline.x(:,ins)=Reference.X(:,SortedOrder{II}(1));
%         SimilarShots.Baseline.y(:,ins)=Reference.Y(:,SortedOrder{II}(1));
%         SimilarShots.Distance(ins)=OverallSimilarity(SortedOrder{II}(1));
%    else
%        SortedDistance{II}=[];
%        SortedOrder{II}=[];
%    end
% end
% 
% %Remove Reference Orbit
% Meas_x=mean(Orbits.X(:,KEOrb),2); Meas_y=mean(Orbits.Y(:,KEOrb),2); 
% %CorrectorsOrbit=CorrMatrix*MODEL.corrB*1000;
% %CorrectorsOrbitX=CorrectorsOrbit(1:2:end); CorrectorsOrbitY=CorrectorsOrbit(2:2:end);
% UseForInit=[1,1,1,1,0,0]; % fit 4 coordinates for launch, x,x',y,y'. Energy might be fit as well.
% [LaunchMatrix,LaunchMatrixAngles]=InitMatrix_Fast(static,MODEL.rMat,Pos,UseForInit);
% 
% [SD,SDO]=sort(SimilarShots.Distance,'ascend');

Meas_x=mean(Orbits.X(:,KEOrb),2); Meas_y=mean(Orbits.Y(:,KEOrb),2); 
Baseline_x=mean(Reference.X(:,KERef),2); Baseline_y=mean(Reference.Y(:,KERef),2); 

BPMData(:,1) = Meas_x - Baseline_x; BPMData(:,2)= Meas_y - Baseline_y;

SystemBPMData=zeros(2*Pos.nBPM,1);
SystemBPMData(1:2:end)=BPMData(:,1); SystemBPMData(2:2:end)=BPMData(:,2);

useBPM=true(2*Pos.nBPM,1);
fitBPM=false(2*Pos.nBPM,1);
fitBPM(1:2:end)=options.fitBPM;
fitBPM(2:2:end)=options.fitBPM;
BPMMatrix_Reduced=BPMMatrix(useBPM,fitBPM);
CorrMatrix_Reduced = CorrMatrix(useBPM,options.useCorr);
SystemMatrix=[CorrMatrix_Reduced,BPMMatrix_Reduced];

if(~isfield(options,'fitSVDRatio')), options.fitSVDRatio=10^-2; end

[SystemSolution,SystemSolution_Std] = util_lssvd(SystemMatrix, SystemBPMData(useBPM), ones(size(BPMData(useBPM)))/10^6, options.fitSVDRatio);

SystemSolution=SystemSolution/1000;
SystemSolution_Std=SystemSolution_Std/1000;

Solution.SystemSolution=SystemSolution;
Solution.SystemSolution_Std=SystemSolution_Std;

Solution.CorrectorValues=-SystemSolution(1:sum(options.useCorr));
Solution.BPMValues=-SystemSolution((sum(options.useCorr)+1):end)*1000;

end

function [OUT,ts,PvList]=getBPMData_caget(BPMList, Samples, AddXYTMIT, mintmit, MorePVs)
    ins=1; ListSize=numel(BPMList);
    if(nargin>2)
        if(AddXYTMIT)
            BPMList=[strcat(BPMList(:),':X');strcat(BPMList(:),':Y');strcat(BPMList(:),':TMIT')];
            ListSize=numel(BPMList);
            TmitLocation=(2*length(BPMList)/3+1):(length(BPMList));
        end
    end
    if(nargin>4)
        if(~isempty(MorePVs))
            BPMList=[BPMList;MorePVs(:)];
            ListSize=numel(BPMList);
        end
    end
    [OUT,ts]=deal(zeros([ListSize,Samples]));
    [ReadOut,ReadOut_ts] =lcaGetSmart(BPMList(:));
    OUT(:,ins) = ReadOut;
    ts(:,ins) = ReadOut_ts;
    tic 
    time=0;
    if(AddXYTMIT)
        if(nargin>3)
           Tmits=ReadOut(TmitLocation);
           if(isempty(Tmits))
               ins=ins-1;
           elseif(any(Tmits<mintmit))
               ins=ins-1;
           end
        end
    end
    while(ins<Samples)
        [New_Element, New_Element_ts]=lcaGetSmart(BPMList(:));
        if(AddXYTMIT)
            if(nargin>3)
                Tmits=New_Element(TmitLocation);
                if(isempty(Tmits))
                    continue
                elseif(any(Tmits<mintmit))
                    continue
                end
           end
        end
        if(any(New_Element~=ReadOut) || any(New_Element_ts~=ReadOut_ts) || ((toc-time)>1))
           time=toc;
           ins=ins+1;
           ReadOut=New_Element;
           ReadOut_ts=New_Element_ts;
           OUT(:,ins) = ReadOut;
           ts(:,ins) = ReadOut_ts; 
        end
    end
    PvList=BPMList(:);
end

function [OUT,ts,PvList]=getBPMData_HB_timing(BPMList, AddXYTMIT, StartTime, MorePVs)
if(nargin>2)
    if(AddXYTMIT)
        BPMList=[strcat(BPMList(:),':X');strcat(BPMList(:),':Y');strcat(BPMList(:),':TMIT')];
    end
end
if(nargin>3)
    if(~isempty(MorePVs))
        BPMList=[BPMList;MorePVs(:)];
    end
end
PvList=BPMList(:);

[ReadOut,ComplexTimestamps] = lcaGetSyncHST(PvList);

if(~isreal(StartTime))
    ats=double(real(StartTime)) + double(imag(StartTime))/10^9;
end

readout_ats = double(real(ComplexTimestamps)) + double(imag(ComplexTimestamps))/10^9;

OUT=ReadOut(:,readout_ats>ats);
ts=readout_ats(readout_ats>ats);
end

function [OUT,ts,PvList]=getBPMData_reserveBSA(BPMList, Samples, AddXYTMIT, eDefNumber,mintmit,MorePVs,ExcludeNaN,BeamCode)
if(nargin<8),BeamCode=NaN;end
if(nargin<7),ExcludeNaN=1; end
if(nargin<6),MorePVs={}; end
if(nargin<5),mintmit=-inf; end
if(nargin<4),eDefNumber=NaN; end
if(nargin<3),AddXYTMIT=0; end
if(nargin<2),Samples=1571; end   
if(isempty(eDefNumber)), eDefNumber=NaN; end

if(AddXYTMIT)
    BPMList=[strcat(BPMList(:),':X');strcat(BPMList(:),':Y');strcat(BPMList(:),':TMIT')];
    TmitLocation=(2*length(BPMList)/3+1):(length(BPMList));
end

if(~isempty(MorePVs))
    BPMList=[BPMList;MorePVs(:)];
end

PvList=BPMList(:); RELEASE=0;
if(isnan(eDefNumber))
    eDefNumber=eDefReserve('Steering BSA Acquisition');
    RELEASE=1;
end

if(isnan(eDefNumber) || (~eDefNumber))
    OUT=NaN; ts=NaN; return
end

dataok=0;
ListSize=numel(BPMList);
new_list=strcat(BPMList(:),'HST',num2str(eDefNumber));
%    Non so se questa cosa serva minimamente...
new_list{end+1} = sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',eDefNumber);
new_list{end+1} = sprintf('PATT:%s:1:SECHST%d','SYS0',eDefNumber);
new_list{end+1} = sprintf('PATT:%s:1:NSECHST%d','SYS0',eDefNumber);
eDefOff(eDefNumber);
if(length(BeamCode)~=1)
    AutoBeamCode=1;
elseif(any(BeamCode==[0,1,2]))
    AutoBeamCode=0;
else
    AutoBeamCode=1;
end

if(AutoBeamCode)
    if(any(cellfun(@(x) any(strfind(x,'DMPS')),new_list) | cellfun(@(x) any(strfind(x,'UNDS')),new_list) | cellfun(@(x) any(strfind(x,'LTUS')),new_list)))
        BeamCode=2;
    else
        BeamCode=1;
    end
end
eDefParams (eDefNumber, 1, Samples,[],[],[],[],BeamCode);
eDefOn(eDefNumber);

while(~dataok)

    done=eDefDone(eDefNumber);
    while(~done)
        pause(0.01);
        done=eDefDone(eDefNumber);
    end

    ReadOut=lcaGet(new_list,Samples); ReadOut=ReadOut(:,1:Samples);
    
    if(ExcludeNaN(1)) %remove any shot that has NaN
        if(length(ExcludeNaN)>1)
            if(ExcludeNaN(2))
                Retain=find(~isnan(sum(ReadOut,1)) & ~any(ReadOut==0));
            else
                Retain=find(~isnan(sum(ReadOut,1)));
            end
        else
            Retain=find(~isnan(sum(ReadOut,1)));
        end
        if(isempty(Retain))
            dataok=0;
            disp('Every shot recorded has at least a NaN or a 0, taking data again');
            disp(['Shots with a NaN: ',num2str(sum(isnan(sum(ReadOut,1))))]);
            disp(['Shots with a 0 or NaN: ',num2str(sum(any(ReadOut==0) | isnan(sum(ReadOut,1))))]);
            eDefOn(eDefNumber);
            pause(0.1);
            continue
        else
            ReadOut=ReadOut(:,Retain);
            dataok=1;
        end
        
    else
        if(any(any(isnan(ReadOut))))
            dataok=0;
            disp('Readout data has NaN, taking data again, and I am not authorized to take them out, waiting for fully good dataset, use ExludeNaN=1 otherwise') 
            eDefOn(eDefNumber);
            pause(0.1);
        else
            dataok=1;
        end
    end
    
    if(AddXYTMIT)
        Tmits=ReadOut(TmitLocation,:);
        Retain=all(Tmits>mintmit);
        if(isempty(Retain))
            dataok=0;
            disp('No shots has all BPMs with tmit above threshold. Maybe beam is down, or tmit are bad reporting values');
            eDefOn(eDefNumber);
            pause(0.1);
        else
            dataok=1;
        end
    end
    
    if(nargin>4)
        if(AddXYTMIT)
            Tmits=ReadOut(TmitLocation,:);
            if(any(any(isnan(Tmits))))
                disp('Data Tmit had NaN, taking data again')
                dataok=0; eDefOn(eDefNumber); pause(0.1);
            elseif(any(Tmits<mintmit))
                disp('Data had Tmit below threshold, taking data again')
                dataok=0; eDefOn(eDefNumber); pause(0.1);
            end
        end
    end
end

OUT=ReadOut(1:end-3,:);
ts=double(ReadOut(end-1,:)) + double(ReadOut(end,:))/10^9;
if(RELEASE)
    eDefRelease(eDefNumber);
end
end

% function Sol=eLossBump(static, Options)
%     Pos.nBPM=length(static.bpmList);Pos.nQuad=length(static.quadList);Pos.nCorr=length(static.corrList);Pos.nUnd=length(static.undList);
%     [~, MP] = min(static.zBPM);StartBPM=static.bpmList{MP};
%     ToList=[static.bpmList;static.quadList;static.quadList;static.corrList;static.undList;static.undList];
%     PosList=[repmat({'POSB=END'},length(static.bpmList),1);repmat({'POSB=BEG'},length(static.quadList),1);repmat({'POSB=END'},length(static.quadList),1);repmat({'POSB=END'},length(static.corrList),1);repmat({'POSB=BEG'},length(static.undList),1);repmat({'POSB=END'},length(static.undList),1)];
%     Pos.Bpm=1:Pos.nBPM;Pos.QuadBeg=Pos.nBPM+(1:Pos.nQuad);Pos.QuadEnd=Pos.nBPM+Pos.nQuad+(1:Pos.nQuad);Pos.Corr=Pos.nBPM+2*Pos.nQuad+(1:Pos.nCorr);Pos.UndBeg=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+(1:Pos.nUnd);Pos.UndEnd=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+Pos.nUnd+(1:Pos.nUnd);
%     
%     
%     if(~isfield(options,'MODEL'))
%         if(options.Simul)
%             [MODEL.rMat, MODEL.zPos, MODEL.lEff, MODEL.energy] = Get_Model_Simul(StartBPM,ToList,PosList);
%         else
%             if(~isfield(options,'MODEL_TYPE')), options.MODEL_TYPE='TYPE=EXTANT'; end
%             if(~isfield(options,'BEAMPATH'))
%                 if (any(cellfun(@(x) any(strfind(x,'UNDS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'LTUS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'DMPS')),[static.bpmList_e;static.corrList_e])))
%                     options.BEAMPATH=['BEAMPATH=','CU_SXR'];
%                 else
%                     options.BEAMPATH=['BEAMPATH=','CU_HXR'];
%                 end
%             end
%             if(any(strfind(options.BEAMPATH,'CU_SXR')))
%                 model_init('SOURCE','MATLAB','beamPath','CU_SXR','useBdes',1);
%             elseif(any(strfind(options.BEAMPATH,'CU_HXR')))
%                 model_init('SOURCE','MATLAB','beamPath','CU_HXR','useBdes',1);
%             end
%             Plist=PosList; Plist{end+1}=options.MODEL_TYPE; Plist{end+1}=options.BEAMPATH;
%             [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,Plist);
%             %[MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,{options.MODEL_TYPE,options.BEAMPATH},PosList);
%         end
%     else
%         MODEL=options.MODEL;
%     end
%     CorrectorStrengths=lcaGetSmart(strcat(static.corrList_e,':BCTRL'));
%     [CorrMatrix,CorrMatrixAngles]=CorrectorOrbitMatrix_Fast(static,MODEL.rMat,Pos,MODEL.energy);
%     
%     CorrMat=cell2mat(cellfun(@(x) x(1),static.corrList,'un',0));
%     XCorrPos=CorrMat(:,1)=='X';
%     XCorrPos=find(XCorrPos);
%     YCorrPos=CorrMat(:,1)=='Y';
%     YCorrPos=find(YCorrPos);
%     
%     
%     UndBpmPos=find(cellfun(@(x) any(strfind(x,'UND')),static(1).bpmList_e));
%     UndBpmPos(end)=[];
%     ClosePos=find(cellfun(@(x) any(strfind(x,Options.end)),static(1).bpmList_e));
%     StartPos=find(cellfun(@(x) any(strfind(x,Options.start)),static(1).bpmList_e));
%     
%     if(strcmp(Options.direction,'X'))
%         CM=CorrMatrix(1:2:end,XCorrPos);
%         CMA=CorrMatrixAngles(1:2:end,XCorrPos);
%         Excitation=zeros(size(XCorrPos));
%         zCorr=static.zCorr(XCorrPos);
%         CS=CorrectorStrengths(XCorrPos);
%         CorrPVs=strcat(static.corrList_e(XCorrPos),':BCTRL');
%         CorrRange=static.corrRange(XCorrPos,:);
%     elseif(strcmp(Options.direction,'Y'))
%         CM=CorrMatrix(2:2:end,YCorrPos);
%         CMA=CorrMatrixAngles(2:2:end,YCorrPos);
%         Excitation=zeros(size(YCorrPos));
%         zCorr=static.zCorr(YCorrPos);
%         CS=CorrectorStrengths(YCorrPos);
%         CorrPVs=strcat(static.corrList_e(YCorrPos),':BCTRL');
%         CorrRange=static.corrRange(YCorrPos,:);
%     end
%      
%     % UndBpmPos,StartPos,ClosePos
%     
%     Excitation(StartPos)=1; Orbit=CM*Excitation;
%     ExcitationMax=max(abs(Excitation))/max(abs(Orbit(UndBpmPos)))*Options.size; Excitation(StartPos)=ExcitationMax;
%     Orbit=CM*Excitation;
%     
%     LineToCloseLocation=CM(ClosePos,:);
%     LineToCloseLocation(1:StartPos)=NaN;
%     [minVal,minPos]=min(abs(LineToCloseLocation)); %multiple of 180 degrees  phase advance
%     CorrClosest=find(zCorr<static.zBPM(ClosePos),1,'last');
%     SteerBackInitialLocation=minPos:CorrClosest; %Correctors used to close initial bump.
% 
%     Orbit=CM*Excitation;
%     OrbitA=CMA*Excitation;
%     CMClose=CM(ClosePos:end,:);
%     CMAClose=CMA(ClosePos:end,:);
%     Orbit_Solve=Orbit(ClosePos:end);
%     OrbitA_Solve=OrbitA(ClosePos:end);
%     %2 Correctors closing solution
%    
%     CM_F=CMClose(:,SteerBackInitialLocation);
%     CMA_F=CMAClose(:,SteerBackInitialLocation);
%     
%     
%     SystemMatrix=CM_F; Measure=Orbit_Solve;
%     PART1=pinv(SystemMatrix)*Measure;
%     P1.Excitation=Excitation;
%     P1.Excitation(SteerBackInitialLocation)=-PART1;
%     
%     SystemMatrix=[CM_F;CMA_F]; Measure=[Orbit_Solve;OrbitA_Solve];
%     PART2=pinv(SystemMatrix)*Measure;
%     
%     P2.Excitation=Excitation;
%     P2.Excitation(SteerBackInitialLocation)=-PART2;
%     
%     Excitation2=Excitation*0;
%     Excitation2(minPos)=1;
%     
%     if(abs(ClosePos-minPos) >4)
%         
%     end
%     
%     Orbit=CM*Excitation2;
%     ExcitationMax=max(abs(Excitation2))/max(abs(Orbit(UndBpmPos)))*Options.size;
%     Excitation=0*Excitation2; Excitation2(Options.start)=ExcitationMax;
%     
%     Orbit1=CM*(Excitation + P1.Excitation);
%     Orbit2=CM*(Excitation + P2.Excitation);
%     
%     CorrClosest=find(zCorr<static.zBPM(ClosePos),2,'last');
% 
%     CM_F=CMClose(:,CorrClosest);
%     CMA_F=CMAClose(:,CorrClosest);
%     if(~Options.closeAngle)
%         SystemMatrix=CM_F; Measure=Orbit_Solve;
%     else
%         SystemMatrix=[CM_F;CMA_F]; Measure=[Orbit_Solve;OrbitA_Solve];
%     end
%     Solution=pinv(SystemMatrix)*Measure;
%     Sol(1).Excitation=Excitation;
%     Sol(1).Excitation(CorrClosest)=-Solution;
%     Sol(1).ExitOrbit=CM*Sol(1).Excitation;
%     Sol(1).ExitOrbitA=CMA*Sol(1).Excitation;
%     Sol(1).OldCorrectors=CS;
%     Sol(1).NewCorrectors=CS+Sol(1).Excitation;
%     Sol(1).CorrPVs=CorrPVs;
%     Sol(1).MODEL=MODEL;
%  
%     
% end

function [SolA, MODEL]=orbitBumpArray(static, Options)
if(~nargin)
   Options=struct();
   disp('Options');
   disp('.direction, char X, char Y or char XY') ;
   disp('.start, start corrector position within static structure') ;
   disp('.end, end bpm position within static structure') ;
   disp('.closeBump, 1/0') ;
   disp('.closeAngle, 1/0') ;
   disp('.RelevantBPM, position of BPMs used to compute orbit size') ;
   disp('.SafetyMargin, reduces corrector change by this factor') ;
   disp('.SafetyMargin, reduces corrector change by this factor') ;
   disp('.SafetyMargin, reduces corrector change by this factor') ;
   disp('.equivalentCorrectorExcitation, 1/0 uses another corrector to compute excitation for required orbit');
   disp('.equivalentCorrectorExcitationPosition, position within static structure');
   disp('.NotExceedOrbit, Never exceed orbit in m, even at non relevant BPM locations');
   if(~isfield(Options,'direction')), Options.direction='X'; end
   if(~isfield(Options,'start')), Options.start=1; end %start is a corrector
   if(~isfield(Options,'end')), Options.end=[]; end %end is a BPM!
   if(~isfield(Options,'size')), Options.size=3*10^-4; end
   if(~isfield(Options,'closeBump')), Options.closeBump=1; end %if 0, it leave it open.
   if(~isfield(Options,'closeAngle')), Options.closeAngle=1; end %if 0, it leave it open.
   if(~isfield(Options,'RelevantBPM')), Options.RelevantBPM=[]; end
   if(~isfield(Options,'SafetyMargin')), Options.SafetyMargin=1; end % between 0 and 1, 1 means no safety margin.
   if(~isfield(Options,'equivalentCorrectorExcitation')), Options.equivalentCorrectorExcitation=0; end
   if(~isfield(Options,'equivalentCorrectorExcitationPosition')), Options.equivalentCorrectorExcitationPosition=4; end
   if(~isfield(Options,'NotExceedOrbit')), Options.NotExceedOrbit=+inf;end
   Sol=Options; return
end
if(~isfield(Options,'direction')), Options.direction='X'; end
if(~isfield(Options,'start')), Options.start=1; end %start is a corrector
if(~isfield(Options,'end')), Options.end=length(static.bpmList); end %end is a BPM!
if(isempty(Options.end)), Options.end=true(size(static.bpmList)); end
if(~isfield(Options,'size')), Options.size=3*10^-4; end
if(~isfield(Options,'closeBump')), Options.closeBump=1; end %if 0, it leave it open.
if(~isfield(Options,'closeAngle')), Options.closeAngle=1; end %if 0, it leave it open.
if(~isfield(Options,'RelevantBPM')), Options.RelevantBPM=true(size(static.bpmList)); end
if(isempty(Options.RelevantBPM)), Options.RelevantBPM=true(size(static.bpmList)); end
if(~isfield(Options,'SafetyMargin')), Options.SafetyMargin=1; end % between 0 and 1, 1 means no safety margin.
%if(~isfield(Options,'equivalentCorrectorExcitation')), Options.equivalentCorrectorExcitation=0; end
%if(~isfield(Options,'equivalentCorrectorExcitationPosition')), Options.equivalentCorrectorExcitationPosition=4; end
if(~isfield(Options,'NotExceedOrbit')), Options.NotExceedOrbit=+inf;end

if(~isfield(Options,'Simul')), Options.Simul=0; end
Pos.nBPM=length(static.bpmList);Pos.nQuad=length(static.quadList);Pos.nCorr=length(static.corrList);Pos.nUnd=length(static.undList);
[~, MP] = min(static.zBPM);StartBPM=static.bpmList{MP};
ToList=[static.bpmList;static.quadList;static.quadList;static.corrList;static.undList;static.undList];
PosList=[repmat({'POSB=END'},length(static.bpmList),1);repmat({'POSB=BEG'},length(static.quadList),1);repmat({'POSB=END'},length(static.quadList),1);repmat({'POSB=END'},length(static.corrList),1);repmat({'POSB=BEG'},length(static.undList),1);repmat({'POSB=END'},length(static.undList),1)];
Pos.Bpm=1:Pos.nBPM;Pos.QuadBeg=Pos.nBPM+(1:Pos.nQuad);Pos.QuadEnd=Pos.nBPM+Pos.nQuad+(1:Pos.nQuad);Pos.Corr=Pos.nBPM+2*Pos.nQuad+(1:Pos.nCorr);Pos.UndBeg=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+(1:Pos.nUnd);Pos.UndEnd=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+Pos.nUnd+(1:Pos.nUnd);

if(~isfield(Options,'MODEL'))
    if(Options.Simul)
        [MODEL.rMat, MODEL.zPos, MODEL.lEff, MODEL.energy] = Get_Model_Simul(StartBPM,ToList,PosList);
    else
        if(~isfield(Options,'MODEL_TYPE')), Options.MODEL_TYPE='TYPE=EXTANT'; end
        if(~isfield(Options,'BEAMPATH'))
            if (any(cellfun(@(x) any(strfind(x,'UNDS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'LTUS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'DMPS')),[static.bpmList_e;static.corrList_e])))
                Options.BEAMPATH=['BEAMPATH=','CU_SXR'];
            else
                Options.BEAMPATH=['BEAMPATH=','CU_HXR'];
            end
        end
        if(any(strfind(Options.BEAMPATH,'CU_SXR')))
            model_init('source','MATLAB','beamPath','CU_SXR','useBdes',1);
            Options.BEAMPATH=['BEAMPATH=','CU_SXR'];
        elseif(any(strfind(Options.BEAMPATH,'CU_HXR')))
            model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
            Options.BEAMPATH=['BEAMPATH=','CU_HXR'];
        end
        %Options.BEAMPATH=regexprep(Options.BEAMPATH,'BEAMPATH=','');
        Plist=PosList; Plist{end+1}=Options.MODEL_TYPE; Plist{end+1}=Options.BEAMPATH; Plist{end+1}='SelPosUse=BBA';
        [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,Plist);
        %[MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,{options.MODEL_TYPE,options.BEAMPATH},PosList);
    end
else
    MODEL=Options.MODEL;
end
CorrectorStrengths=lcaGetSmart(strcat(static.corrList_e,':BCTRL'));
[CorrMatrix,CorrMatrixAngles]=CorrectorOrbitMatrix_Fast(static,MODEL.rMat,Pos,MODEL.energy);

CorrMat=cell2mat(cellfun(@(x) x(1),static.corrList,'un',0));
XCorrPos=CorrMat(:,1)=='X';
XCorrPos=find(XCorrPos);
YCorrPos=CorrMat(:,1)=='Y';
YCorrPos=find(YCorrPos);

if(strcmp(Options.direction,'X'))
    CM=CorrMatrix(1:2:end,XCorrPos);
    CMA=CorrMatrixAngles(1:2:end,XCorrPos);
    Excitation=zeros(size(XCorrPos));
    zCorr=static.zCorr(XCorrPos);
    CS=CorrectorStrengths(XCorrPos);
    CorrPVs=strcat(static.corrList_e(XCorrPos),':BCTRL');
    CorrRange=static.corrRange(XCorrPos,:);
elseif(strcmp(Options.direction,'Y'))
    CM=CorrMatrix(2:2:end,YCorrPos);
    CMA=CorrMatrixAngles(2:2:end,YCorrPos);
    Excitation=zeros(size(YCorrPos));
    zCorr=static.zCorr(YCorrPos);
    CS=CorrectorStrengths(YCorrPos);
    CorrPVs=strcat(static.corrList_e(YCorrPos),':BCTRL');
    CorrRange=static.corrRange(YCorrPos,:);
end

Excitation(Options.start(1))=1;
Orbit=CM*Excitation;
ExcitationMax=max(abs(Excitation))/max(abs(Orbit(Options.RelevantBPM)))*Options.size;

for AKs=1:length(Options.start)
    Excitation=0*Excitation; Excitation(Options.start(AKs))=ExcitationMax;
    Orbit=CM*Excitation;
    MaxAmplitude=Options.NotExceedOrbit/max(abs(Orbit(Options.RelevantBPM)));
    
    Sol(1).Excitation=Excitation;
    Sol(1).OldCorrectors=CS;
    Sol(1).NewCorrectors=CS+Sol(1).Excitation;
    Sol(1).CorrPVs=CorrPVs;
    Sol(1).MODEL=MODEL;
    Sol(1).ExitOrbit=CM*Sol(1).Excitation;
    Sol(1).ExitOrbitA=CMA*Sol(1).Excitation;
    Sol(1).CorrRange=CorrRange;
    
    if(any((Sol(1).NewCorrectors < CorrRange(:,1))) || any(Sol(1).NewCorrectors > CorrRange(:,2)))
        Sol(1).Success=false;
    else
        Sol(1).Success=true;
    end
    
    Sol(2).Excitation=Excitation;
    Sol(2).OldCorrectors=CS;
    Sol(2).NewCorrectors=CS+Sol(1).Excitation;
    Sol(2).CorrPVs=CorrPVs;
    Sol(2).MODEL=MODEL;
    Sol(2).ExitOrbit=CM*Sol(2).Excitation;
    Sol(2).ExitOrbitA=CMA*Sol(2).Excitation;
    Sol(2).CorrRange=CorrRange;
    
    if(any(Sol(2).NewCorrectors < CorrRange(:,1)) || any(Sol(2).NewCorrectors > CorrRange(:,2)))
        Sol(2).Success=false;
    else
        Sol(2).Success=true;
    end
    
    %Lowerboundextreme for Sol(1)
    Non_Zero=find(Sol(1).Excitation~=0); MaxVal=zeros(size(Non_Zero));
    for II=1:length(Non_Zero)
        if(Sol(1).Excitation(Non_Zero(II))<0) %look at lower bound
            MaxVal(II)=abs(CS(Non_Zero(II)) - CorrRange(Non_Zero(II),1))/abs(Sol(1).Excitation(Non_Zero(II)));
        else
            MaxVal(II)=abs(CorrRange(Non_Zero(II),2) - CS(Non_Zero(II)))/abs(Sol(1).Excitation(Non_Zero(II)));
        end
    end
    Sol(3).Excitation=Sol(1).Excitation*min(MaxVal)*Options.SafetyMargin;
    Sol(3).ExitOrbit=CM*Sol(3).Excitation;
    Sol(3).ExitOrbitA=CMA*Sol(3).Excitation;
    Sol(3).OldCorrectors=CS;
    Sol(3).NewCorrectors=CS+Sol(3).Excitation;
    Sol(3).CorrPVs=CorrPVs;
    Sol(3).MODEL=MODEL;
    Sol(3).Success=true;
    Sol(3).CorrRange=CorrRange;
    
    %Lowerboundextreme for Sol(2)
    Non_Zero=find(Sol(2).Excitation~=0); MaxVal=zeros(size(Non_Zero));
    for II=1:length(Non_Zero)
        if(Sol(2).Excitation(Non_Zero(II))<0) %look at lower bound
            MaxVal(II)=abs(CS(Non_Zero(II)) - CorrRange(Non_Zero(II),1))/abs(Sol(2).Excitation(Non_Zero(II)));
        else
            MaxVal(II)=abs(CorrRange(Non_Zero(II),2) - CS(Non_Zero(II)))/abs(Sol(2).Excitation(Non_Zero(II)));
        end
    end
    Sol(4).Excitation=Sol(2).Excitation*min(MaxVal)*Options.SafetyMargin;
    Sol(4).ExitOrbit=CM*Sol(4).Excitation;
    Sol(4).ExitOrbitA=CMA*Sol(4).Excitation;
    Sol(4).OldCorrectors=CS;
    Sol(4).NewCorrectors=CS+Sol(4).Excitation;
    Sol(4).CorrPVs=CorrPVs;
    Sol(4).MODEL=MODEL;
    Sol(4).Success=true;
    Sol(4).CorrRange=CorrRange;
    
    SolA{AKs}=Sol;    
end

end

function [Sol,MODEL]=orbitBump(static, Options)
if(~nargin)
   Options=struct();
   disp('Options');
   disp('.direction, char X, char Y or char XY') ;
   disp('.start, start corrector position within static structure') ;
   disp('.end, end bpm position within static structure') ;
   disp('.closeBump, 1/0') ;
   disp('.closeAngle, 1/0') ;
   disp('.RelevantBPM, position of BPMs used to compute orbit size') ;
   disp('.SafetyMargin, reduces corrector change by this factor') ;
   disp('.SafetyMargin, reduces corrector change by this factor') ;
   disp('.SafetyMargin, reduces corrector change by this factor') ;
   disp('.equivalentCorrectorExcitation, 1/0 uses another corrector to compute excitation for required orbit');
   disp('.equivalentCorrectorExcitationPosition, position within static structure');
   disp('.NotExceedOrbit, Never exceed orbit in m, even at non relevant BPM locations');
   if(~isfield(Options,'direction')), Options.direction='X'; end
   if(~isfield(Options,'start')), Options.start=1; end %start is a corrector
   if(~isfield(Options,'end')), Options.end=[]; end %end is a BPM!
   if(~isfield(Options,'size')), Options.size=3*10^-4; end
   if(~isfield(Options,'closeBump')), Options.closeBump=1; end %if 0, it leave it open.
   if(~isfield(Options,'closeAngle')), Options.closeAngle=1; end %if 0, it leave it open.
   if(~isfield(Options,'RelevantBPM')), Options.RelevantBPM=[]; end
   if(~isfield(Options,'SafetyMargin')), Options.SafetyMargin=1; end % between 0 and 1, 1 means no safety margin.
   if(~isfield(Options,'equivalentCorrectorExcitation')), Options.equivalentCorrectorExcitation=0; end
   if(~isfield(Options,'equivalentCorrectorExcitationPosition')), Options.equivalentCorrectorExcitationPosition=4; end
   if(~isfield(Options,'NotExceedOrbit')), Options.NotExceedOrbit=+inf;end
   Sol=Options; return
end
if(~isfield(Options,'direction')), Options.direction='X'; end
if(~isfield(Options,'start')), Options.start=1; end %start is a corrector
if(~isfield(Options,'end')), Options.end=length(static.bpmList); end %end is a BPM!
if(isempty(Options.end)), Options.end=true(size(static.bpmList)); end
if(~isfield(Options,'size')), Options.size=3*10^-4; end
if(~isfield(Options,'closeBump')), Options.closeBump=1; end %if 0, it leave it open.
if(~isfield(Options,'closeAngle')), Options.closeAngle=1; end %if 0, it leave it open.
if(~isfield(Options,'RelevantBPM')), Options.RelevantBPM=true(size(static.bpmList)); end
if(isempty(Options.RelevantBPM)), Options.RelevantBPM=true(size(static.bpmList)); end
if(~isfield(Options,'SafetyMargin')), Options.SafetyMargin=1; end % between 0 and 1, 1 means no safety margin.
if(~isfield(Options,'equivalentCorrectorExcitation')), Options.equivalentCorrectorExcitation=0; end
if(~isfield(Options,'equivalentCorrectorExcitationPosition')), Options.equivalentCorrectorExcitationPosition=4; end
if(~isfield(Options,'NotExceedOrbit')), Options.NotExceedOrbit=+inf;end

if(~isfield(Options,'Simul')), Options.Simul=0; end

Pos.nBPM=length(static.bpmList);Pos.nQuad=length(static.quadList);Pos.nCorr=length(static.corrList);Pos.nUnd=length(static.undList);
[~, MP] = min(static.zBPM);StartBPM=static.bpmList{MP};
ToList=[static.bpmList;static.quadList;static.quadList;static.corrList;static.undList;static.undList];
PosList=[repmat({'POSB=END'},length(static.bpmList),1);repmat({'POSB=BEG'},length(static.quadList),1);repmat({'POSB=END'},length(static.quadList),1);repmat({'POSB=END'},length(static.corrList),1);repmat({'POSB=BEG'},length(static.undList),1);repmat({'POSB=END'},length(static.undList),1)];
Pos.Bpm=1:Pos.nBPM;Pos.QuadBeg=Pos.nBPM+(1:Pos.nQuad);Pos.QuadEnd=Pos.nBPM+Pos.nQuad+(1:Pos.nQuad);Pos.Corr=Pos.nBPM+2*Pos.nQuad+(1:Pos.nCorr);Pos.UndBeg=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+(1:Pos.nUnd);Pos.UndEnd=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+Pos.nUnd+(1:Pos.nUnd);

if(~isfield(Options,'MODEL'))
    if(Options.Simul)
        [MODEL.rMat, MODEL.zPos, MODEL.lEff, MODEL.energy] = Get_Model_Simul(StartBPM,ToList,PosList);
    else
        if(~isfield(Options,'MODEL_TYPE')), Options.MODEL_TYPE='TYPE=EXTANT'; end
        if(~isfield(Options,'BEAMPATH'))
            if (any(cellfun(@(x) any(strfind(x,'UNDS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'LTUS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'DMPS')),[static.bpmList_e;static.corrList_e])))
                Options.BEAMPATH=['BEAMPATH=','CU_SXR'];
            else
                Options.BEAMPATH=['BEAMPATH=','CU_HXR'];
            end
        end
        if(any(strfind(Options.BEAMPATH,'CU_SXR')))
            model_init('source','MATLAB','beamPath','CU_SXR','useBdes',1);
            Options.BEAMPATH=['BEAMPATH=','CU_SXR'];
        elseif(any(strfind(Options.BEAMPATH,'CU_HXR')))
            model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
            Options.BEAMPATH=['BEAMPATH=','CU_HXR'];
        end
        %Options.BEAMPATH=regexprep(Options.BEAMPATH,'BEAMPATH=','');
        Plist=PosList; Plist{end+1}=Options.MODEL_TYPE; Plist{end+1}=Options.BEAMPATH; Plist{end+1}='SelPosUse=BBA';
        [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,Plist);
        %[MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,{options.MODEL_TYPE,options.BEAMPATH},PosList);
    end
else
    MODEL=Options.MODEL;
end

if(strcmp(Options.direction,'XY'))
    OptionsX=Options; OptionsX.direction='X';
    OptionsY=Options; OptionsY.direction='Y';
    OptionsX.MODEL=MODEL; OptionsY.MODEL=MODEL;
    if(length(Options.size)==2)
        OptionsX.size=Options.size(1);
        OptionsY.size=Options.size(2);
    end
    SolX=orbitBump(static, OptionsX);
    SolY=orbitBump(static, OptionsY);
   
    Sol=SolX;
    for II=1:4
        Sol(II).Excitation=[Sol(II).Excitation;SolY(II).Excitation];
        Sol(II).ExitOrbit=[Sol(II).ExitOrbit;SolY(II).ExitOrbit];
        Sol(II).ExitOrbitA=[Sol(II).ExitOrbitA;SolY(II).ExitOrbitA];
        Sol(II).OldCorrectors=[Sol(II).OldCorrectors;SolY(II).OldCorrectors];
        Sol(II).NewCorrectors=[Sol(II).NewCorrectors;SolY(II).NewCorrectors];
        Sol(II).CorrPVs=[Sol(II).CorrPVs;SolY(II).CorrPVs];
        Sol(II).Success=Sol(II).Success && SolY(II).Success;
        
        Sol(II).MaxExcursion_X=SolX(II).MaxExcursion;
        Sol(II).MaxExcursionRelevantBPM_X=SolX(II).MaxExcursionRelevantBPM; 
        Sol(II).MaxExcursion_Y=SolY(II).MaxExcursion;
        Sol(II).MaxExcursionRelevantBPM_Y=SolY(II).MaxExcursionRelevantBPM; 
    end
    return
end

%Only correctors to BPM are actually needed for steering, but the other
%ones are left for future use.

CorrectorStrengths=lcaGetSmart(strcat(static.corrList_e,':BCTRL'));
[CorrMatrix,CorrMatrixAngles]=CorrectorOrbitMatrix_Fast(static,MODEL.rMat,Pos,MODEL.energy);

CorrMat=cell2mat(cellfun(@(x) x(1),static.corrList,'un',0));
XCorrPos=CorrMat(:,1)=='X';
XCorrPos=find(XCorrPos);
YCorrPos=CorrMat(:,1)=='Y';
YCorrPos=find(YCorrPos);

if(strcmp(Options.direction,'X'))
    CM=CorrMatrix(1:2:end,XCorrPos);
    CMA=CorrMatrixAngles(1:2:end,XCorrPos);
    Excitation=zeros(size(XCorrPos));
    zCorr=static.zCorr(XCorrPos);
    CS=CorrectorStrengths(XCorrPos);
    CorrPVs=strcat(static.corrList_e(XCorrPos),':BCTRL');
    CorrRange=static.corrRange(XCorrPos,:);
elseif(strcmp(Options.direction,'Y'))
    CM=CorrMatrix(2:2:end,YCorrPos);
    CMA=CorrMatrixAngles(2:2:end,YCorrPos);
    Excitation=zeros(size(YCorrPos));
    zCorr=static.zCorr(YCorrPos);
    CS=CorrectorStrengths(YCorrPos);
    CorrPVs=strcat(static.corrList_e(YCorrPos),':BCTRL');
    CorrRange=static.corrRange(YCorrPos,:);
end

if(Options.equivalentCorrectorExcitation)
    if(length(Excitation)<Options.equivalentCorrectorExcitationPosition)
        Excitation(Options.equivalentCorrectorExcitationPosition)=1;
    else
        Excitation(1)=1;
    end
else
    Excitation(Options.start)=1;
end
Orbit=CM*Excitation;
ExcitationMax=max(abs(Excitation))/max(abs(Orbit(Options.RelevantBPM)))*Options.size;
Excitation=0*Excitation; Excitation(Options.start)=ExcitationMax;
Orbit=CM*Excitation;
MaxAmplitude=Options.NotExceedOrbit/max(abs(Orbit(Options.RelevantBPM)));

if(Options.closeBump)
    Orbit=CM*Excitation;
    OrbitA=CMA*Excitation;
    CMClose=CM(Options.end:end,:);
    CMAClose=CMA(Options.end:end,:);
    Orbit_Solve=Orbit(Options.end:end);
    OrbitA_Solve=OrbitA(Options.end:end);
    %2 Correctors closing solution
    CorrClosest=find(zCorr<static.zBPM(Options.end),2,'last');
    CM_F=CMClose(:,CorrClosest);
    CMA_F=CMAClose(:,CorrClosest);
    if(~Options.closeAngle)
        SystemMatrix=CM_F; Measure=Orbit_Solve;
    else
        SystemMatrix=[CM_F;CMA_F]; Measure=[Orbit_Solve;OrbitA_Solve];
    end
    Solution=pinv(SystemMatrix)*Measure;
    Sol(1).Excitation=Excitation;
    Sol(1).Excitation(CorrClosest)=-Solution;
    Sol(1).ExitOrbit=CM*Sol(1).Excitation;
    Sol(1).ExitOrbitA=CMA*Sol(1).Excitation;
    Sol(1).OldCorrectors=CS;
    Sol(1).NewCorrectors=CS+Sol(1).Excitation;
    Sol(1).CorrPVs=CorrPVs;
    Sol(1).MODEL=MODEL;
    Sol(1).CorrRange=CorrRange;
    
    if(any(Sol(1).NewCorrectors < CorrRange(:,1)) || any(Sol(1).NewCorrectors > CorrRange(:,2)))
        Sol(1).Success=false;
    else
        Sol(1).Success=true;
    end
        
    CorrClosest=find(zCorr<static.zBPM(Options.end),4,'last');
    CM_F=CMClose(:,CorrClosest);
    CMA_F=CMAClose(:,CorrClosest);
    SystemMatrix=[CM_F;CMA_F]; Measure=[Orbit_Solve;OrbitA_Solve];
    Solution=pinv(SystemMatrix)*Measure;
    Excitation(CorrClosest)=Solution;

    Sol(2).Excitation=Excitation;
    Sol(2).Excitation(CorrClosest)=-Solution;
    Sol(2).ExitOrbit=CM*Sol(2).Excitation;
    Sol(2).ExitOrbitA=CMA*Sol(2).Excitation;
    Sol(2).OldCorrectors=CS;
    Sol(2).NewCorrectors=CS+Sol(2).Excitation;
    Sol(2).CorrPVs=CorrPVs;
    Sol(2).MODEL=MODEL;
    Sol(2).CorrRange=CorrRange;
    
    if(any(Sol(2).NewCorrectors < CorrRange(:,1)) || any(Sol(2).NewCorrectors > CorrRange(:,2)))
        Sol(2).Success=false;
    else
        Sol(2).Success=true;
    end
    
    %Lowerboundextreme for Sol(1)
    Non_Zero=find(Sol(1).Excitation~=0); MaxVal=zeros(size(Non_Zero));
    for II=1:length(Non_Zero)
        if(Sol(1).Excitation(Non_Zero(II))<0) %look at lower bound
            MaxVal(II)=abs(CS(Non_Zero(II)) - CorrRange(Non_Zero(II),1))/abs(Sol(1).Excitation(Non_Zero(II)));
        else
            MaxVal(II)=abs(CorrRange(Non_Zero(II),2) - CS(Non_Zero(II)))/abs(Sol(1).Excitation(Non_Zero(II)));
        end
    end
    MaxVal(end+1)=MaxAmplitude;
    Sol(3).Excitation=Sol(1).Excitation*min(MaxVal)*Options.SafetyMargin;
    Sol(3).ExitOrbit=CM*Sol(3).Excitation;
    Sol(3).ExitOrbitA=CMA*Sol(3).Excitation;
    Sol(3).OldCorrectors=CS;
    Sol(3).NewCorrectors=CS+Sol(3).Excitation;
    Sol(3).CorrPVs=CorrPVs;
    Sol(3).MODEL=MODEL;
    Sol(3).Success=true;
    Sol(3).CorrRange=CorrRange;
    
    %Lowerboundextreme for Sol(2)
    Non_Zero=find(Sol(2).Excitation~=0); MaxVal=zeros(size(Non_Zero));
    for II=1:length(Non_Zero)
        if(Sol(2).Excitation(Non_Zero(II))<0) %look at lower bound
            MaxVal(II)=abs(CS(Non_Zero(II)) - CorrRange(Non_Zero(II),1))/abs(Sol(2).Excitation(Non_Zero(II)));
        else
            MaxVal(II)=abs(CorrRange(Non_Zero(II),2) - CS(Non_Zero(II)))/abs(Sol(2).Excitation(Non_Zero(II)));
        end
    end
    MaxVal(end+1)=MaxAmplitude;
    Sol(4).Excitation=Sol(2).Excitation*min(MaxVal)*Options.SafetyMargin;
    Sol(4).ExitOrbit=CM*Sol(4).Excitation;
    Sol(4).ExitOrbitA=CMA*Sol(4).Excitation;
    Sol(4).OldCorrectors=CS;
    Sol(4).NewCorrectors=CS+Sol(4).Excitation;
    Sol(4).CorrPVs=CorrPVs;
    Sol(4).MODEL=MODEL;
    Sol(4).Success=true;
    Sol(4).CorrRange=CorrRange;
    
    
else
    Sol(1).Excitation=Excitation;
    Sol(1).OldCorrectors=CS;
    Sol(1).NewCorrectors=CS+Sol(1).Excitation;
    Sol(1).CorrPVs=CorrPVs;
    Sol(1).MODEL=MODEL;
    Sol(1).ExitOrbit=CM*Sol(1).Excitation;
    Sol(1).ExitOrbitA=CMA*Sol(1).Excitation;
    Sol(1).CorrRange=CorrRange;
    
    if(any((Sol(1).NewCorrectors < CorrRange(:,1))) || any(Sol(1).NewCorrectors > CorrRange(:,2)))
        Sol(1).Success=false;
    else
        Sol(1).Success=true;
    end
    
    Sol(2).Excitation=Excitation;
    Sol(2).OldCorrectors=CS;
    Sol(2).NewCorrectors=CS+Sol(1).Excitation;
    Sol(2).CorrPVs=CorrPVs;
    Sol(2).MODEL=MODEL;
    Sol(2).ExitOrbit=CM*Sol(2).Excitation;
    Sol(2).ExitOrbitA=CMA*Sol(2).Excitation;
    Sol(2).CorrRange=CorrRange;
    
    if(any(Sol(2).NewCorrectors < CorrRange(:,1)) || any(Sol(2).NewCorrectors > CorrRange(:,2)))
        Sol(2).Success=false;
    else
        Sol(2).Success=true;
    end
    
    %Lowerboundextreme for Sol(1)
    Non_Zero=find(Sol(1).Excitation~=0); MaxVal=zeros(size(Non_Zero));
    for II=1:length(Non_Zero)
        if(Sol(1).Excitation(Non_Zero(II))<0) %look at lower bound
            MaxVal(II)=abs(CS(Non_Zero(II)) - CorrRange(Non_Zero(II),1))/abs(Sol(1).Excitation(Non_Zero(II)));
        else
            MaxVal(II)=abs(CorrRange(Non_Zero(II),2) - CS(Non_Zero(II)))/abs(Sol(1).Excitation(Non_Zero(II)));
        end
    end
    Sol(3).Excitation=Sol(1).Excitation*min(MaxVal)*Options.SafetyMargin;
    Sol(3).ExitOrbit=CM*Sol(3).Excitation;
    Sol(3).ExitOrbitA=CMA*Sol(3).Excitation;
    Sol(3).OldCorrectors=CS;
    Sol(3).NewCorrectors=CS+Sol(3).Excitation;
    Sol(3).CorrPVs=CorrPVs;
    Sol(3).MODEL=MODEL;
    Sol(3).Success=true;
    Sol(3).CorrRange=CorrRange;
    
    %Lowerboundextreme for Sol(2)
    Non_Zero=find(Sol(2).Excitation~=0); MaxVal=zeros(size(Non_Zero));
    for II=1:length(Non_Zero)
        if(Sol(2).Excitation(Non_Zero(II))<0) %look at lower bound
            MaxVal(II)=abs(CS(Non_Zero(II)) - CorrRange(Non_Zero(II),1))/abs(Sol(2).Excitation(Non_Zero(II)));
        else
            MaxVal(II)=abs(CorrRange(Non_Zero(II),2) - CS(Non_Zero(II)))/abs(Sol(2).Excitation(Non_Zero(II)));
        end
    end
    Sol(4).Excitation=Sol(2).Excitation*min(MaxVal)*Options.SafetyMargin;
    Sol(4).ExitOrbit=CM*Sol(4).Excitation;
    Sol(4).ExitOrbitA=CMA*Sol(4).Excitation;
    Sol(4).OldCorrectors=CS;
    Sol(4).NewCorrectors=CS+Sol(4).Excitation;
    Sol(4).CorrPVs=CorrPVs;
    Sol(4).MODEL=MODEL;
    Sol(4).Success=true;
    Sol(4).CorrRange=CorrRange;
    
end

for II=1:length(Sol)
    if(~isempty(Sol(II).ExitOrbit))
        [~,MP]=max(abs(Sol(II).ExitOrbit));
        Sol(II).MaxExcursion=Sol(II).ExitOrbit(MP);
        [~,MP]=max(abs(Sol(II).ExitOrbit(Options.RelevantBPM)));
        TEMP=Sol(II).ExitOrbit(Options.RelevantBPM);
        Sol(II).MaxExcursionRelevantBPM=TEMP(MP);
    end
end

end

function [Matrix,CMeas,Locations]=Build_BBA_Matrix(AllDataModel, options)

if(nargin<4)
    options.UseForInit=[1,1,1,1,0,0];
end

npar=0;
nmeas=0;

for II=1:numel(AllDataModel)
    %[rList,Pos,E]=RetrieveMatrixFromFirstBPM_new(static,AllR{II});
    Energy(II)= median(AllDataModel{II}.energy);
    QuadOffset{II} = QuadOffsetMatrix_Fast(AllDataModel{II}.static,AllDataModel{II}.rMat,AllDataModel{II}.Pos);
    BPMOffset{II} = BPMOffsetMatrix(AllDataModel{II}.static);
    InitM{II} = InitMatrix_Fast(AllDataModel{II}.static,AllDataModel{II}.rMat,AllDataModel{II}.Pos,options.UseForInit);
    if(II==1)
        npar=npar+size(QuadOffset{II},2)+size(BPMOffset{II},2);
    end
    npar=npar+size(InitM{II},2); 
    nmeas=nmeas + size(BPMOffset{II},2);
%     Extras(II).rList=rList;
%     Extras(II).Pos=Pos;
%     Extras(II).E=E;
end

nBpm2=size(BPMOffset{II},2);
nInit=size(InitM{II},2);
nQuad2=size(QuadOffset{II},2);
nEn=length(Energy);

Matrix=zeros(nmeas,npar);
for II=1:numel(AllDataModel)
    Matrix((II-1)*nBpm2 + (1:nBpm2) ,(II-1)*nInit + (1:nInit)) = InitM{II};
    Matrix((II-1)*nBpm2 + (1:nBpm2) ,nEn*nInit + (1:nQuad2)) = QuadOffset{II};
    Matrix((II-1)*nBpm2 + (1:nBpm2) ,nEn*nInit + nQuad2 + (1:nBpm2)) = BPMOffset{II};
end

options.num.nBpm2=nBpm2;
options.num.nInit=nInit;
options.num.nQuad2=nQuad2;
options.num.nEn=nEn;
options.quadB=AllDataModel{1}.quadB;

[CMatrix,CMeas]=ConstrainMatrix(AllDataModel{1}.static,options);

Matrix=[Matrix;CMatrix];
Locations.Init=1:(nInit*nEn);
Locations.Quad=max(Locations.Init) + (1:nQuad2);
Locations.Bpm=max(Locations.Quad) + (1:nBpm2);
end

function [InitMatrix,InitMatrixAngles]=InitMatrix_Fast(static,rList,Pos,UseForInit)
%UseForInit
%[x,x',y,y',t,delta], typically [1,1,1,1,0,0], but may be [1,1,1,1,0,1];

InitMatrix=zeros(Pos.nBPM*2,sum(UseForInit));

for II=1:Pos.nBPM
    Matrix = rList(:,:,Pos.Bpm(II));
    InitMatrix(((II-1)*2)+(1:2),1:sum(UseForInit)) = Matrix([1,3],logical(UseForInit));
end

if(nargout>1)
    InitMatrixAngles=zeros(Pos.nBPM*2,sum(UseForInit));
    for II=1:Pos.nBPM
        Matrix = rList(:,:,Pos.Bpm(II));
        InitMatrixAngles(((II-1)*2)+(1:2),1:sum(UseForInit)) = Matrix([2,4],logical(UseForInit));
    end
end
end

function OUT=QuadOffsetMatrix_Fast(static,rList,Pos)

OUT=zeros(2*Pos.nBPM,2*Pos.nQuad);

for II=1:Pos.nQuad
    for JJ=1:Pos.nBPM
        if(static.zQuad(II)<static.zBPM(JJ))
            OffsetMatrix=rList(:,:,Pos.Bpm(JJ))*(inv(rList(:,:,Pos.QuadEnd(II))) - inv(rList(:,:,Pos.QuadBeg(II))));
            OUT(((JJ-1)*2) + 1 , ((II-1)*2) + 1) = OffsetMatrix(1,1);
            OUT(((JJ-1)*2) + 2 , ((II-1)*2) + 2) = OffsetMatrix(3,3);
        end
    end
end
end

function [OUT,Desc1,Desc2]=BPMOffsetMatrix(static)
nBPM=length(static.bpmList);
OUT=-eye(2*nBPM);
Desc1={};Desc2={};
for II=1:nBPM
    Desc1{(II-1)*2+1}=['On X, ',static.bpmList{II}];
    Desc1{(II-1)*2+2}=['On Y, ',static.bpmList{II}];
    Desc2{(II-1)*2+1}=['X shift, ',static.bpmList{II}];
    Desc2{(II-1)*2+2}=['Y shift, ',static.bpmList{II}];
end
end

function [Offsets,lsqSolution]=SolveBBA_System(BBA_Matrix, OrbitMeas, OrbitMeasStd, CMeas, Locations)
Meas=[];
for II=1:numel(OrbitMeas)
    Temp=zeros(numel(OrbitMeas{II}),1);
    Temp(1:2:end)=OrbitMeas{II}(:,1);
    Temp(2:2:end)=OrbitMeas{II}(:,2);
    Meas=[Meas;Temp];
end
Meas=[Meas;CMeas];

MeasStd=[];
for II=1:numel(OrbitMeasStd)
    Temp=zeros(numel(OrbitMeasStd{II}),1);
    Temp(1:2:end)=OrbitMeasStd{II}(:,1);
    Temp(2:2:end)=OrbitMeasStd{II}(:,2);
    MeasStd=[MeasStd;Temp];
end
MeasStd=[MeasStd;ones(size(CMeas))/10^6];

[lsqSolution,lsqSolutionStd]=lscov(BBA_Matrix,Meas,MeasStd);
Offsets.Quad=lsqSolution(Locations.Quad);
Offsets.Bpm=lsqSolution(Locations.Bpm);
Offsets.Init=lsqSolution(Locations.Init);
Offsets.QuadErr=lsqSolutionStd(Locations.Quad);
Offsets.BpmErr=lsqSolutionStd(Locations.Bpm);
Offsets.InitErr=lsqSolutionStd(Locations.Init);
end

function [CorrMatrix,CorrMatrixAngles]=CorrectorMatrix_toQuad(static,rList,Pos,EnergyGeV)
end

function [CorrMatrix,CorrMatrixAngles]=CorrectorOrbitMatrix_Fast(static,rList,Pos,EnergyGeV)

% Coeff=0.51105562846485;
% ElectronMass=9.10938356*10^-31;
% c=299792458;
% echarge=1.60217662*10^-19;
%Brho = EnergyMeV*ElectronMass*c/echarge/Coeff; %For integrated field in T m
%Brho = EnergyMeV*0.003335270991074;
%Brho = EnergyMeV*ElectronMass*c/echarge/Coeff*10; %For integrated field in kG m 
Brho = EnergyGeV*0.03335270991074*1000;


CorrMatrix=zeros(2*Pos.nBPM,Pos.nCorr);
CorrMatrixAngles=zeros(2*Pos.nBPM,Pos.nCorr);

for II=1:Pos.nCorr
    for JJ=1:Pos.nBPM
        if(static.zCorr(II)<static.zBPM(JJ))
            CorrFullMatrix=rList(:,:,Pos.Bpm(JJ))*(inv(rList(:,:,Pos.Corr(II))));
            if(strcmp(static.corrList{II}(1),'X'))
                CorrMatrix(((JJ-1)*2) + 1 , (II)) = CorrFullMatrix(1,2)/Brho(Pos.Corr(II));
            elseif(strcmp(static.corrList{II}(1),'Y'))
                CorrMatrix(((JJ-1)*2) + 2 , (II)) = CorrFullMatrix(3,4)/Brho(Pos.Corr(II));
            end
            if(strcmp(static.corrList{II}(1),'X'))
                CorrMatrixAngles(((JJ-1)*2) + 1 , (II)) = CorrFullMatrix(2,2);
            elseif(strcmp(static.corrList{II}(1),'Y'))
                CorrMatrixAngles(((JJ-1)*2) + 2 , (II)) = CorrFullMatrix(4,4);
            end
        end
    end
end

end

function [CorrMatrix,CorrMatrixAngles]=CorrectorAndTrimsOrbitMatrix_wYag_Fast(static,rList,Pos,EnergyGeV)

% Coeff=0.51105562846485;
% ElectronMass=9.10938356*10^-31;
% c=299792458;
% echarge=1.60217662*10^-19;
%Brho = EnergyMeV*ElectronMass*c/echarge/Coeff; %For integrated field in T m
%Brho = EnergyMeV*0.003335270991074;
%Brho = EnergyMeV*ElectronMass*c/echarge/Coeff*10; %For integrated field in kG m 
Brho = EnergyGeV*0.03335270991074*1000;


CorrMatrix=zeros(2*Pos.nBPM+2*Pos.nYag,Pos.nCorr+Pos.nTrims);
CorrMatrixAngles=zeros(2*Pos.nBPM+2*Pos.nYag,Pos.nCorr);

for II=1:Pos.nCorr
    for JJ=1:Pos.nBPM
        if(static.zCorr(II)<static.zBPM(JJ))
            CorrFullMatrix=rList(:,:,Pos.Bpm(JJ))*(inv(rList(:,:,Pos.Corr(II))));
            if(strcmp(static.corrList{II}(1),'X'))
                CorrMatrix(((JJ-1)*2) + 1 , (II)) = CorrFullMatrix(1,2)/Brho(Pos.Corr(II));
            elseif(strcmp(static.corrList{II}(1),'Y'))
                CorrMatrix(((JJ-1)*2) + 2 , (II)) = CorrFullMatrix(3,4)/Brho(Pos.Corr(II));
            end
            if(strcmp(static.corrList{II}(1),'X'))
                CorrMatrixAngles(((JJ-1)*2) + 1 , (II)) = CorrFullMatrix(2,2);
            elseif(strcmp(static.corrList{II}(1),'Y'))
                CorrMatrixAngles(((JJ-1)*2) + 2 , (II)) = CorrFullMatrix(4,4);
            end
        end
    end
    for KK=1:Pos.nYag
        if(static.zCorr(II)<static.zYag(KK))
            CorrFullMatrix=rList(:,:,Pos.Yag(KK))*(inv(rList(:,:,Pos.Corr(II))));
            if(strcmp(static.corrList{II}(1),'X'))
                CorrMatrix(((KK-1)*2) + 1 + Pos.nBPM*2, (II)) = CorrFullMatrix(1,2)/Brho(Pos.Corr(II));
            elseif(strcmp(static.corrList{II}(1),'Y'))
                CorrMatrix(((KK-1)*2) + 2 + Pos.nBPM*2, (II)) = CorrFullMatrix(3,4)/Brho(Pos.Corr(II));
            end
            if(strcmp(static.corrList{II}(1),'X'))
                CorrMatrixAngles(((KK-1)*2) + 1 + Pos.nBPM*2, (II)) = CorrFullMatrix(2,2);
            elseif(strcmp(static.corrList{II}(1),'Y'))
                CorrMatrixAngles(((KK-1)*2) + 2 + Pos.nBPM*2, (II)) = CorrFullMatrix(4,4);
            end
        end
    end
end

ArbitraryFactor=3;

for II=1:Pos.nTrims
    for JJ=1:Pos.nBPM
        if(static.zBend(II)<static.zBPM(JJ))
            Tratto=find(static.btrimList{II}=='_');
            Position=str2num(static.btrimList{II}(Tratto-1));
            switch(Position)
                case 1
                    Segno=1;
                case 2
                    Segno=-1;
                case 3
                    Segno=-1;
                case 4
                    Segno=1;
                otherwise
                    Segno=1;
            end    
            CorrFullMatrix=rList(:,:,Pos.Bpm(JJ))*(inv(rList(:,:,Pos.Trims(II))));
            CorrFullMatrix=CorrFullMatrix*Segno/ArbitraryFactor;
            if(any(static.btrimList{II}=='X'))
                CorrMatrix(((JJ-1)*2) + 1 , (II) + Pos.nCorr) = CorrFullMatrix(1,2)/Brho(Pos.Trims(II));
            elseif(any(static.btrimList{II}=='Y'))
                CorrMatrix(((JJ-1)*2) + 2 , (II) + Pos.nCorr) = CorrFullMatrix(3,4)/Brho(Pos.Trims(II));
            end
            if(any(static.btrimList{II}=='X'))
                CorrMatrixAngles(((JJ-1)*2) + 1 , (II) + Pos.nCorr) = CorrFullMatrix(2,2);
            elseif(any(static.btrimList{II}=='Y'))
                CorrMatrixAngles(((JJ-1)*2) + 2 , (II) + Pos.nCorr) = CorrFullMatrix(4,4);
            end
        end
    end
    for KK=1:Pos.nYag
        if(static.zBend(II)<static.zYag(JJ))
            Tratto=find(static.btrimList{II}=='_');
            Position=str2num(static.btrimList{II}(Tratto-1));
            switch(Position)
                case 1
                    Segno=1;
                case 2
                    Segno=-1;
                case 3
                    Segno=-1;
                case 4
                    Segno=1;
                otherwise
                    Segno=1;
            end    
            CorrFullMatrix=rList(:,:,Pos.Yag(KK))*(inv(rList(:,:,Pos.Trims(II))));
            CorrFullMatrix=CorrFullMatrix*Segno/ArbitraryFactor;
            if(any(static.btrimList{II}=='X'))
                CorrMatrix(((KK-1)*2) + 1 + Pos.nBPM*2, (II) + Pos.nCorr) = CorrFullMatrix(1,2)/Brho(Pos.Trims(II));
            elseif(any(static.btrimList{II}=='Y'))
                CorrMatrix(((KK-1)*2) + 2 + Pos.nBPM*2, (II) + Pos.nCorr) = CorrFullMatrix(3,4)/Brho(Pos.Trims(II));
            end
            if(any(static.btrimList{II}=='X'))
                CorrMatrixAngles(((KK-1)*2) + 1 + Pos.nBPM*2, (II) + Pos.nCorr) = CorrFullMatrix(2,2);
            elseif(any(static.btrimList{II}=='Y'))
                CorrMatrixAngles(((KK-1)*2) + 2 + Pos.nBPM*2, (II) + Pos.nCorr) = CorrFullMatrix(4,4);
            end
        end
    end
end

end


function [TrimsMatrix,TrimsMatrixAngles]=TrimsOrbitMatrix_Fast(static,rList,Pos,EnergyGeV)

% Coeff=0.51105562846485;
% ElectronMass=9.10938356*10^-31;
% c=299792458;
% echarge=1.60217662*10^-19;
%Brho = EnergyMeV*ElectronMass*c/echarge/Coeff; %For integrated field in T m
%Brho = EnergyMeV*0.003335270991074;
%Brho = EnergyMeV*ElectronMass*c/echarge/Coeff*10; %For integrated field in kG m 
Brho = EnergyGeV*0.03335270991074*1000;


TrimsMatrix=zeros(2*Pos.nBPM,Pos.nTrims);
TrimsMatrixAngles=zeros(2*Pos.nBPM,Pos.nTrims);
ArbitraryFactor=3;

for II=1:Pos.nTrims
    for JJ=1:Pos.nBPM
        if(static.zBend(II)<static.zBPM(JJ))
            Tratto=find(static.btrimList{II}=='_');
            Position=str2num(static.btrimList{II}(Tratto-1));
            switch(Position)
                case 1
                    Segno=1;
                case 2
                    Segno=-1;
                case 3
                    Segno=-1;
                case 4
                    Segno=1;
                otherwise
                    Segno=1;
            end    
            CorrFullMatrix=rList(:,:,Pos.Bpm(JJ))*(inv(rList(:,:,Pos.Trims(II))));
            CorrFullMatrix=CorrFullMatrix*Segno/ArbitraryFactor;
            if(any(static.btrimList{II}=='X'))
                TrimsMatrix(((JJ-1)*2) + 1 , (II)) = CorrFullMatrix(1,2)/Brho(Pos.Trims(II));
            elseif(any(static.btrimList{II}=='Y'))
                TrimsMatrix(((JJ-1)*2) + 2 , (II)) = CorrFullMatrix(3,4)/Brho(Pos.Trims(II));
            end
            if(any(static.btrimList{II}=='X'))
                TrimsMatrixAngles(((JJ-1)*2) + 1 , (II)) = CorrFullMatrix(2,2);
            elseif(any(static.btrimList{II}=='Y'))
                TrimsMatrixAngles(((JJ-1)*2) + 2 , (II)) = CorrFullMatrix(4,4);
            end
        end
    end
end

end


function Solution=steerQuad(static, options, target)
    %finds new correctors to steer to target orbit. If target is not
    %specified, target is 0. 
    %One can pass BPM data with options.BPMData, they should be a matrix of
    % [length static.bpmList x 2] size with average BPM position
    %optionally one can pass also options.BPMDataStd with std for each BPM. No
    %additional filtering will be done.
    %If not options.BPMData, then Data will be acquired within the function
    %there are three modes, at least one should be turned to 1, if you want
    %to choose how data is taken.
    %options.BSA_HB, options.BSA and options.CAGET
    %BSA_HB requires:
    %either options.startTime OR options.startTimePV AND
    %options.AcquisitionTime
    %BSA requires:
    %options.Samples, 
    %options.eDefBuffer is not mandatory if one has a reserved buffer can
    %use that.
    %CAGET requires a number of samples. No beam synchronicity is assured,
    %but is supposed to work at some extent if BSA is down
    %options.tmitMin is used to filter out data with too low tmit.
    %options.fitSVDRatio is used to select how to cut SVD coefficients
    %options.MODEL_TYPE to choose model for Model_rMatGet
    %options.BEAMPATH for same reason.
    %target is a structure, target.x must have length of the
    %trues of options.useBPMx if specified, otherwise of the static.bpmList 
    
    Do_Acquisition=1;
    
    if(isfield(options,'BPMData'))
        %NEED TO ADD PROPER VARIABLE NAMES...
        Do_Acquisition=0;
    else
        if(~isfield(options,'BSA_HB')), options.BSA_HB=0; else 
            if(options.BSA_HB)
                tic, 
                if(~isfield(options,'AcquisitionTime')), options.AcquisitionTime=1; end
                if(~isfield(options,'startTime')), [~,options.startTime]=lcaGetSmart(strcat(static.bpmList_e{1},':X')); end
            end
        end
        if(~isfield(options,'BSA')), options.BSA=0; end
        if(~isfield(options,'CAGET')), options.CAGET=0; end
        
        if(~options.BSA_HB && ~options.BSA && ~options.CAGET)
            options.BSA_HB=1;
            [~,options.startTime]=lcaGetSmart(strcat(static.bpmList_e{1},':X'));
            options.AcquisitionTime=1;
        end
        if(options.BSA)
            if(~isfield(options,'eDefBuffer')), options.eDefBuffer=NaN; end
            if(~isfield(options,'Samples')), options.Samples=60; end
            [BPMRawData,ts,PvList]=getBPMData_reserveBSA(static.bpmList_e, options.Samples, 1, options.eDefBuffer);
        end
        if(options.CAGET)
            if(~isfield(options,'Samples')), options.Samples=60; end
            [BPMRawData,ts,PvList]=getBPMData_caget(static.bpmList_e, options.Samples, 1);
        end
    end
    
    if(~isfield(options,'Simul')), options.Simul=0; end
    
    if(nargin<3)
        target=zeros(length(static.bpmList),2);
    end
    
    %Get the model here!
    %Only correctors to BPM are actually needed for steering, but the other
    %ones are left for future use.
    
    if(~isfield(options,'BEAMPATH'))
        if (any(cellfun(@(x) any(strfind(x,'UNDS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'LTUS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'DMPS')),[static.bpmList_e;static.corrList_e])))
            options.BEAMPATH=['BEAMPATH=','CU_SXR'];
        else
            options.BEAMPATH=['BEAMPATH=','CU_HXR'];
        end 
    end
    
    Pos.nBPM=length(static.bpmList); Pos.nQuad=length(static.quadList); Pos.nCorr=length(static.corrList); Pos.nUnd=length(static.undList);
    [~, MP] = min(static.zBPM); StartBPM=static.bpmList{MP};

    ToList=[static.bpmList;static.quadList;static.quadList;static.corrList;static.undList;static.undList];
    PosList=[repmat({'POSB=END'},length(static.bpmList),1);repmat({'POSB=BEG'},length(static.quadList),1);repmat({'POSB=END'},length(static.quadList),1);repmat({'POSB=END'},length(static.corrList),1);repmat({'POSB=BEG'},length(static.undList),1);repmat({'POSB=END'},length(static.undList),1)];

    Pos.Bpm=1:Pos.nBPM;
    Pos.QuadBeg=Pos.nBPM+(1:Pos.nQuad);
    Pos.QuadEnd=Pos.nBPM+Pos.nQuad+(1:Pos.nQuad);
    Pos.Corr=Pos.nBPM+2*Pos.nQuad+(1:Pos.nCorr);
    Pos.UndBeg=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+(1:Pos.nUnd);
    Pos.UndEnd=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+Pos.nUnd+(1:Pos.nUnd);
    
    if(~isfield(options,'Simul')), options.Simul=0; end
    
    if(any(strfind(options.BEAMPATH,'CU_SXR')))
        model_init('source','MATLAB','beamPath','CU_SXR','useBdes',1);
    elseif(any(strfind(options.BEAMPATH,'CU_HXR')))
        model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
    end
    
    if(~isfield(options,'rMat'))
        if(options.Simul)
            [MODEL.rMat, MODEL.zPos, MODEL.lEff, MODEL.energy] = Get_Model_Simul(StartBPM,ToList,PosList);
        else
            if(~isfield(options,'MODEL_TYPE')), options.MODEL_TYPE='TYPE=EXTANT'; end
            Plist=PosList; Plist{end+1}=options.MODEL_TYPE; Plist{end+1}=options.BEAMPATH; Plist{end+1}='SelPosUse=BBA'; 
            [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,Plist);
            %[MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,{options.MODEL_TYPE,options.BEAMPATH},PosList);
        end
    else
       MODEL.rMat=options.rMat; 
       MODEL.energy=options.energy;
    end 
    
    if(~isfield(options,'useBPMx')),options.useBPMx=true(size(static.bpmList)); end
    if(~isfield(options,'useBPMy')),options.useBPMy=true(size(static.bpmList)); end
    if(~isfield(options,'useCorr')),options.useCorr=true(size(static.corrList)); end
    
    %CorrectorStrengths=lcaGetSmart(strcat(static.corrList_e,':BCTRL'));
    QuadMatrix=QuadOffsetMatrix_Fast(static,MODEL.rMat,Pos);
    %[CorrMatrix,CorrMatrixAngles]=CorrectorOrbitMatrix_Fast(static,MODEL.rMat,Pos,MODEL.energy);
    
    if(options.BSA_HB) %then it is time to get your data...
        b=toc;
        while(b<options.AcquisitionTime)
            pause(0.025); b=toc;
        end
        [BPMRawData,ts,PvList]=getBPMData_HB_timing(static.bpmList_e, 1, options.startTime);
    end
    
    if(Do_Acquisition) %This will calculated avg X, avg Y, std X, std Y and filter TMIT
        BPMDataMeas=zeros(length(static.bpmList),2);
        BPMData=zeros(length(static.bpmList),2);
        BPMDataStd=zeros(length(static.bpmList),2);
        if(~isfield(options,'tmitMin')), options.tmitMin=-inf; end
        for II=1:Pos.nBPM %further exclude BPMs if they give NaNs (?)
            TempData=[BPMRawData(II,:);BPMRawData(II+Pos.nBPM,:);BPMRawData(II+2*Pos.nBPM,:)];
            TempData(:,any(isnan(TempData)))=[]; %Excludes NaN readings first
            if(isempty(TempData(3,:)>options.tmitMin))
                BPMData(II,1)=NaN;
                BPMDataStd(II,1)=NaN;
                BPMData(II,2)=NaN;
                BPMDataStd(II,2)=NaN;
                options.useBPMx(II)=false;
                options.useBPMy(II)=false;
                BPMDataMeas(II,1)=NaN;
                BPMDataMeas(II,2)=NaN;
            else
                BPMDataMeas(II,1)=mean(TempData(1,TempData(3,:)>options.tmitMin));
                BPMDataStd(II,1)=std(TempData(1,TempData(3,:)>options.tmitMin));
                BPMDataMeas(II,2)=mean(TempData(2,TempData(3,:)>options.tmitMin));
                BPMDataStd(II,2)=std(TempData(2,TempData(3,:)>options.tmitMin));
                
                BPMData(II,1)=BPMDataMeas(II,1) - target(II,1);
                BPMData(II,2)=BPMDataMeas(II,2) - target(II,2);
            end
        end
    end
  
%     CorrMat=cell2mat(cellfun(@(x) x(1),static.corrList,'un',0));
%     XCorrPos=find(CorrMat(options.useCorr,1)=='X');
%     YCorrPos=find(CorrMat(options.useCorr,1)=='Y');
  
    useBPM=false(2*Pos.nBPM,1);
    useBPM(1:2:end)=options.useBPMx;
    useBPM(2:2:end)=options.useBPMy;
    
    SystemBPMData=zeros(2*Pos.nBPM,1);
    SystemBPMData(1:2:end)=BPMData(:,1); SystemBPMData(2:2:end)=BPMData(:,2);
    
    options.useQuad=false(2*Pos.nQuad,1);
    options.useQuad(1:2:end)=options.useQuadX;
    options.useQuad(2:2:end)=options.useQuadY;
    
    QuadMatrix_Reduced = QuadMatrix(useBPM,options.useQuad);
    
    
    if(~isfield(options,'fitSVDRatio')), options.fitSVDRatio=10^-5; end
    [SystemSolution,SystemSolution_Std] = util_lssvd(QuadMatrix_Reduced, SystemBPMData(useBPM), ones(size(BPMData(useBPM)))/10^6, options.fitSVDRatio); 
    
    %if orbit input was in millimeter, output offset shuold be in
    %millimeter as well.
    
    SystemSolution=-SystemSolution;
    SystemSolution_Std=SystemSolution_Std;
    
    BPMChanges=QuadMatrix_Reduced*SystemSolution;
    SystemBPMChanges=zeros(2*Pos.nBPM,1);
    SystemBPMChanges(useBPM)=BPMChanges;
    BPMNewOrbit=SystemBPMData+SystemBPMChanges;
    
    Solutionwithzeros=zeros(2*Pos.nQuad,1);
    Solutionwithzeros(options.useQuad)=SystemSolution;
    
    SolutionX=Solutionwithzeros(1:2:end);
    SolutionY=Solutionwithzeros(2:2:end);
 
    Solution.SystemSolution=SystemSolution;
    Solution.SystemSolution_Std=SystemSolution_Std;
    
    Solution.usedQuadX=static.quadList(options.useQuadX);
    Solution.usedQuadY=static.quadList(options.useQuadY);
    Solution.usedQuadX_e=static.quadList_e(options.useQuadX);
    Solution.usedQuadY_e=static.quadList_e(options.useQuadY);
    
    Solution.QuadXOffsets=SolutionX(options.useQuadX);
    Solution.QuadYOffsets=SolutionY(options.useQuadY);
    
    Solution.allQuad=static.quadList;
    Solution.allQuad_e=static.quadList_e;
    Solution.Offsets=[SolutionX,SolutionY];
    Solution.MODEL=MODEL;
    Solution.options=options;
    Solution.RecordedOrbit=BPMData;
    Solution.RecordedOrbitStd=BPMDataStd;
    Solution.NewOrbitX=BPMNewOrbit(1:2:end);
    Solution.NewOrbitY=BPMNewOrbit(2:2:end);

end


function [ConstrainMatrix,ConstrainMeas]=ConstrainMatrix(static,opt)

nBpm2=opt.num.nBpm2;
nInit=opt.num.nInit;
nQuad2=opt.num.nQuad2;
nQuad=nQuad2/2;
nEn=opt.num.nEn;

nPar=nInit*nEn + nBpm2 + nQuad2;
iBPM=nInit*nEn + nQuad2 + (1:nBpm2);
iQuad=nInit*nEn + (1:nQuad2);

% Constraints
sigBPM=nQuad2/2;
%sigCorr=nCorr*opts.fitScale;
[RBLin,RBMin,RQLin,RQMin]=deal(zeros(0,nPar));
[xBLin,xBMin,xQLin,xQMin]=deal(zeros(0,1));

% Linear BPM Constraint
if opt.fitBPMLin
    RBLin(1:4,iBPM)=kron([ones(1,nBPM);static.zBPM],eye(2));
    xBLin=RBLin(:,1)*0;
end

% Min BPM Constraint
if opt.fitBPMMin
    RBMin(1:2*nBPM,iBPM)=eye(2*nBPM)/sigBPM;
    xBMin=RBMin(:,1)*0;
end

% Linear Quad Constraint
if opt.fitQuadLin
    %RQLin(1:4,iQuad)=kron([ones(1,nQuad);static.zQuad],eye(2));
    RQLin(1:4,iQuad)=kron([ones(1,nQuad);(static.zQuad-min(static.zQuad))],eye(2));
    xQLin=RQLin(:,1)*0;

    % Linear Quad Kick Constraint
    if opt.fitQuadKick && ~isempty(opt.quadB)
        RQLin(1:4,iQuad)=RQLin(1:4,iQuad)*kron(diag(abs(opt.quadB)),eye(2));
        %RQLin(1:4,iQuad)=RQLin(1:4,iQuad)*kron(diag(abs(opt.quadB.*static.lQuad)),eye(2));
        %RQLin(1:4,iQuad)=RQLin(1:4,iQuad)*kron(diag(abs(opt.quadB.*static.lQuad*10)),eye(2));
    end
end

% Min Quad Constraint
if opt.fitQuadMin || opt.fitQuadAbs
    RQMin(1:2*nQuad,iQuad)=eye(2*nQuad)/sigBPM;
    xQMin=RQMin(:,1)*0;
    if opts.fitQuadAbs, xQMin=[1 -.5 0 .1]'*1e-3/sigBPM;end
end

% % Min corr Constraint
% if opts.fitCorrMin || opts.fitCorrAbs
%     RCMin(1:2*nCorr,iCorr)=eye(2*nCorr)/sigCorr;
%     RCMin(badCorr,:)=[];
%     xCMin=RCMin(:,1)*0;
%     if opts.fitCorrAbs, xCMin=corrB(~badCorr)/sigCorr;end
% end

% Assemble constraint matrix and vector
ConstrainMatrix=[RBLin;RBMin;RQLin;RQMin];
ConstrainMeas=[xBLin;xBMin;xQLin;xQMin];
end


function Solution=steerTrims(static, options, target)
   
    Do_Acquisition=1;
    
    if(isfield(options,'BPMData'))
        %NEED TO ADD PROPER VARIABLE NAMES...
        Do_Acquisition=0;
    else
        if(~isfield(options,'BSA_HB')), options.BSA_HB=0; else 
            if(options.BSA_HB)
                tic, 
                if(~isfield(options,'AcquisitionTime')), options.AcquisitionTime=1; end
                if(~isfield(options,'startTime')), [~,options.startTime]=lcaGetSmart(strcat(static.bpmList_e{1},':X')); end
            end
        end
        if(~isfield(options,'BSA')), options.BSA=0; end
        if(~isfield(options,'CAGET')), options.CAGET=0; end
        
        if(~options.BSA_HB && ~options.BSA && ~options.CAGET)
            options.BSA_HB=1;tic;
            [~,options.startTime]=lcaGetSmart(strcat(static.bpmList_e{1},':X'));
            options.AcquisitionTime=1;
        end
        if(options.BSA)
            if(~isfield(options,'eDefBuffer')), options.eDefBuffer=NaN; end
            if(~isfield(options,'Samples')), options.Samples=60; end
            %[OUT,ts,PvList]=getBPMData_reserveBSA(BPMList, Samples, AddXYTMIT, eDefNumber,mintmit,MorePVs,ExcludeNaN)
            [BPMRawData,ts,PvList]=getBPMData_reserveBSA(static.bpmList_e, options.Samples, 1, options.eDefBuffer,-1,[],1);
        end
        if(options.CAGET)
            if(~isfield(options,'Samples')), options.Samples=60; end
            [BPMRawData,ts,PvList]=getBPMData_caget(static.bpmList_e, options.Samples, 1);
        end
    end
    
    if(~isfield(options,'Simul')), options.Simul=0; end
    
    if(nargin<3)
        target=zeros(length(static.bpmList),2);
    end
    
    %Get the model here!
    %Only correctors to BPM are actually needed for steering, but the other
    %ones are left for future use.
    
    if(~isfield(options,'BEAMPATH'))
        if (any(cellfun(@(x) any(strfind(x,'UNDS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'LTUS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'DMPS')),[static.bpmList_e;static.corrList_e])))
            options.BEAMPATH=['BEAMPATH=','CU_SXR'];
        else
            options.BEAMPATH=['BEAMPATH=','CU_HXR'];
        end 
    end
    if(any(strfind(options.BEAMPATH,'CU_SXR')))
        model_init('source','MATLAB','beamPath','CU_SXR','useBdes',1);
    elseif(any(strfind(options.BEAMPATH,'CU_HXR')))
        model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
    end
    
    Pos.nBPM=length(static.bpmList); Pos.nQuad=length(static.quadList); Pos.nCorr=length(static.corrList); Pos.nUnd=length(static.undList); Pos.nTrims=length(static.bendList);
    [~, MP] = min(static.zBPM); StartBPM=static.bpmList{MP};

    ToList=[static.bpmList;static.quadList;static.quadList;static.corrList;static.undList;static.undList;static.bendList];
    PosList=[repmat({'POSB=END'},length(static.bpmList),1);repmat({'POSB=BEG'},length(static.quadList),1);repmat({'POSB=END'},length(static.quadList),1);repmat({'POSB=END'},length(static.corrList),1);repmat({'POSB=BEG'},length(static.undList),1);repmat({'POSB=END'},length(static.bendList),1)];

    Pos.Bpm=1:Pos.nBPM;
    Pos.QuadBeg=Pos.nBPM+(1:Pos.nQuad);
    Pos.QuadEnd=Pos.nBPM+Pos.nQuad+(1:Pos.nQuad);
    Pos.Corr=Pos.nBPM+2*Pos.nQuad+(1:Pos.nCorr);
    Pos.UndBeg=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+(1:Pos.nUnd);
    Pos.UndEnd=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+Pos.nUnd+(1:Pos.nUnd);
    Pos.Trims=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+2*Pos.nUnd + (1:Pos.nTrims);
    
    if(~isfield(options,'Simul')), options.Simul=0; end
    
    if(~isfield(options,'rMat'))
        if(options.Simul)
            [MODEL.rMat, MODEL.zPos, MODEL.lEff, MODEL.energy] = Get_Model_Simul(StartBPM,ToList,PosList);
        else
            if(~isfield(options,'MODEL_TYPE')), options.MODEL_TYPE='TYPE=EXTANT'; end
            Plist=PosList; Plist{end+1}=options.MODEL_TYPE; Plist{end+1}=options.BEAMPATH; Plist{end+1}='SelPosUse=BBA';
            [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,Plist);
%            MODEL.zPos=model_rMatGet(ToList,[],{'TYPE=DESIGN',options.BEAMPATH},'Z'); 
%            MODEL.lEff=model_rMatGet(ToList,[],{'TYPE=DESIGN',options.BEAMPATH},'LEFF');
            %[MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,{options.MODEL_TYPE,options.BEAMPATH},PosList);
        end
    else
       MODEL.rMat=options.rMat; 
       MODEL.energy=options.energy;
    end 
    
    if(~isfield(options,'useBPMx')),options.useBPMx=true(size(static.bpmList)); end
    if(~isfield(options,'useBPMy')),options.useBPMy=true(size(static.bpmList)); end
    if(~isfield(options,'useCorr')),options.useCorr=true(size(static.corrList)); end
    
    TrimsStrengths=lcaGetSmart(strcat(static.btrimList_e,':BCTRL'));
    %CorrectorStrengths=lcaGetSmart(strcat(static.corrList_e,':BCTRL'));
    [CorrMatrix,CorrMatrixAngles]=CorrectorOrbitMatrix_Fast(static,MODEL.rMat,Pos,MODEL.energy);
    [TrimsMatrix,TrimsMatrixAngles]=TrimsOrbitMatrix_Fast(static,MODEL.rMat,Pos,MODEL.energy);
    
    if(options.BSA_HB) %then it is time to get your data...
        b=toc;
        while(b<options.AcquisitionTime)
            pause(0.025); b=toc;
        end
        [BPMRawData,ts,PvList]=getBPMData_HB_timing(static.bpmList_e, 1, options.startTime);
    end
    
    if(isfield(options,'BASELINE'))
        disp('Reducing Baseline')
        [ReducedBaseline_POS, ReducedData_POS]=matchLaunchDoubleElimination(BPMRawData(12:14,:).',options.BASELINE(12:14,:).', [1,1,1], 1.5);
        BPMRawData=BPMRawData(:,ReducedBaseline_POS);
    end
    
    if(Do_Acquisition) %This will calculated avg X, avg Y, std X, std Y and filter TMIT
        BPMDataMeas=zeros(length(static.bpmList),2);
        BPMData=zeros(length(static.bpmList),2);
        BPMDataStd=zeros(length(static.bpmList),2);
        if(~isfield(options,'tmitMin')), options.tmitMin=-inf; end
        for II=1:Pos.nBPM %further exclude BPMs if they give NaNs (?)
            TempData=[BPMRawData(II,:);BPMRawData(II+Pos.nBPM,:);BPMRawData(II+2*Pos.nBPM,:)];
            TempData(:,any(isnan(TempData)))=[]; %Excludes NaN readings first
            if(isempty(TempData(3,:)>options.tmitMin))
                BPMData(II,1)=NaN;
                BPMDataStd(II,1)=NaN;
                BPMData(II,2)=NaN;
                BPMDataStd(II,2)=NaN;
                options.useBPMx(II)=false;
                options.useBPMy(II)=false;
                BPMDataMeas(II,1)=NaN;
                BPMDataMeas(II,2)=NaN;
            else
                BPMDataMeas(II,1)=mean(TempData(1,TempData(3,:)>options.tmitMin));
                BPMDataStd(II,1)=std(TempData(1,TempData(3,:)>options.tmitMin));
                BPMDataMeas(II,2)=mean(TempData(2,TempData(3,:)>options.tmitMin));
                BPMDataStd(II,2)=std(TempData(2,TempData(3,:)>options.tmitMin));
                
                BPMData(II,1)=BPMDataMeas(II,1) - target(II,1);
                BPMData(II,2)=BPMDataMeas(II,2) - target(II,2);
            end
        end
    end
  
    CorrMat=cell2mat(cellfun(@(x) x(1),static.corrList,'un',0));
    XCorrPos=find(CorrMat(options.useCorr,1)=='X');
    YCorrPos=find(CorrMat(options.useCorr,1)=='Y');
  
    useBPM=false(2*Pos.nBPM,1);
    useBPM(1:2:end)=options.useBPMx;
    useBPM(2:2:end)=options.useBPMy;
    
    SystemBPMData=zeros(2*Pos.nBPM,1);
    SystemBPMData(1:2:end)=BPMData(:,1); SystemBPMData(2:2:end)=BPMData(:,2);
    
    %CorrMatrix_Reduced = CorrMatrix(useBPM,options.useCorr);
    CorrMatrix_Reduced = TrimsMatrix(useBPM,:);
    if(~isfield(options,'fitSVDRatio')), options.fitSVDRatio=10^-5; end
    [SystemSolution,SystemSolution_Std] = util_lssvd(CorrMatrix_Reduced, SystemBPMData(useBPM), ones(size(BPMData(useBPM)))/10^6, options.fitSVDRatio); 
    
    SystemSolution=SystemSolution/1000;
    SystemSolution_Std=SystemSolution_Std/1000;
 
    Solution.SystemSolution=SystemSolution;
    Solution.SystemSolution_Std=SystemSolution_Std;
    Solution.OldTrims=TrimsStrengths;
    
    Solution.OldCorrReset=TrimsStrengths;
    Solution.NewTrims=TrimsStrengths - SystemSolution;
    %Solution.OutOfRange=(Solution.NewCorr<static.corrRange(options.useCorr,1)) | (Solution.NewCorr>static.corrRange(options.useCorr,2));
    Solution.OutOfRange=0*size(TrimsStrengths);
    Solution.FAILED=any(Solution.OutOfRange);
    Solution.UsedTrims=static.btrimList;
    Solution.UsedTrims_e=static.btrimList_e;
      
    Solution.RecordedOrbitMinusTarget=BPMData;
    Solution.RecordedOrbit=BPMDataMeas;
    Solution.RecordedOrbitStd=BPMDataStd;
    Solution.options=options;
    
    Solution.BPMRawData=BPMRawData;
    
    Solution.MODEL=MODEL;
    Solution.MODEL.TrimsMatrix=TrimsMatrix;
    Solution.MODEL.TrimsMatrixAngles=TrimsMatrixAngles;

end

function Solution=steer3Trims(static, options, target)
   
    Do_Acquisition=1;
    
    if(isfield(options,'BPMData'))
        %NEED TO ADD PROPER VARIABLE NAMES...
        Do_Acquisition=0;
    else
        if(~isfield(options,'BSA_HB')), options.BSA_HB=0; else 
            if(options.BSA_HB)
                tic, 
                if(~isfield(options,'AcquisitionTime')), options.AcquisitionTime=1; end
                if(~isfield(options,'startTime')), [~,options.startTime]=lcaGetSmart(strcat(static.bpmList_e{1},':X')); end
            end
        end
        if(~isfield(options,'BSA')), options.BSA=0; end
        if(~isfield(options,'CAGET')), options.CAGET=0; end
        
        if(~options.BSA_HB && ~options.BSA && ~options.CAGET)
            options.BSA_HB=1;tic;
            [~,options.startTime]=lcaGetSmart(strcat(static.bpmList_e{1},':X'));
            options.AcquisitionTime=1;
        end
        if(options.BSA)
            if(~isfield(options,'eDefBuffer')), options.eDefBuffer=NaN; end
            if(~isfield(options,'Samples')), options.Samples=60; end
            %[OUT,ts,PvList]=getBPMData_reserveBSA(BPMList, Samples, AddXYTMIT, eDefNumber,mintmit,MorePVs,ExcludeNaN)
            [BPMRawData,ts,PvList]=getBPMData_reserveBSA(static.bpmList_e, options.Samples, 1, options.eDefBuffer,-1,[],1);
        end
        if(options.CAGET)
            if(~isfield(options,'Samples')), options.Samples=60; end
            [BPMRawData,ts,PvList]=getBPMData_caget(static.bpmList_e, options.Samples, 1);
        end
    end
    
    if(~isfield(options,'Simul')), options.Simul=0; end
    
    if(nargin<3)
        target=zeros(length(static.bpmList),2);
    end
    
    %Get the model here!
    %Only correctors to BPM are actually needed for steering, but the other
    %ones are left for future use.
    
    if(~isfield(options,'BEAMPATH'))
        if (any(cellfun(@(x) any(strfind(x,'UNDS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'LTUS')),[static.bpmList_e;static.corrList_e])) || any(cellfun(@(x) any(strfind(x,'DMPS')),[static.bpmList_e;static.corrList_e])))
            options.BEAMPATH=['BEAMPATH=','CU_SXR'];
        else
            options.BEAMPATH=['BEAMPATH=','CU_HXR'];
        end 
    end
    if(any(strfind(options.BEAMPATH,'CU_SXR')))
        model_init('source','MATLAB','beamPath','CU_SXR','useBdes',1);
    elseif(any(strfind(options.BEAMPATH,'CU_HXR')))
        model_init('source','MATLAB','beamPath','CU_HXR','useBdes',1);
    end
    
    Pos.nBPM=length(static.bpmList); Pos.nQuad=length(static.quadList); Pos.nCorr=length(static.corrList); Pos.nUnd=length(static.undList); Pos.nTrims=length(static.bendList);
    [~, MP] = min(static.zBPM); StartBPM=static.bpmList{MP};

    ToList=[static.bpmList;static.quadList;static.quadList;static.corrList;static.undList;static.undList;static.bendList];
    PosList=[repmat({'POSB=END'},length(static.bpmList),1);repmat({'POSB=BEG'},length(static.quadList),1);repmat({'POSB=END'},length(static.quadList),1);repmat({'POSB=END'},length(static.corrList),1);repmat({'POSB=BEG'},length(static.undList),1);repmat({'POSB=END'},length(static.bendList),1)];

    Pos.Bpm=1:Pos.nBPM;
    Pos.QuadBeg=Pos.nBPM+(1:Pos.nQuad);
    Pos.QuadEnd=Pos.nBPM+Pos.nQuad+(1:Pos.nQuad);
    Pos.Corr=Pos.nBPM+2*Pos.nQuad+(1:Pos.nCorr);
    Pos.UndBeg=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+(1:Pos.nUnd);
    Pos.UndEnd=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+Pos.nUnd+(1:Pos.nUnd);
    Pos.Trims=Pos.nBPM+2*Pos.nQuad+Pos.nCorr+2*Pos.nUnd + (1:Pos.nTrims);
    
    if(~isfield(options,'Simul')), options.Simul=0; end
    
    if(~isfield(options,'rMat'))
        if(options.Simul)
            [MODEL.rMat, MODEL.zPos, MODEL.lEff, MODEL.energy] = Get_Model_Simul(StartBPM,ToList,PosList);
        else
            if(~isfield(options,'MODEL_TYPE')), options.MODEL_TYPE='TYPE=EXTANT'; end
            Plist=PosList; Plist{end+1}=options.MODEL_TYPE; Plist{end+1}=options.BEAMPATH; Plist{end+1}='SelPosUse=BBA';
            [MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,Plist);
%            MODEL.zPos=model_rMatGet(ToList,[],{'TYPE=DESIGN',options.BEAMPATH},'Z'); 
%            MODEL.lEff=model_rMatGet(ToList,[],{'TYPE=DESIGN',options.BEAMPATH},'LEFF');
            %[MODEL.rMat, MODEL.zPos, MODEL.lEff, ~, MODEL.energy, ~] = model_rMatGet(StartBPM,ToList,{options.MODEL_TYPE,options.BEAMPATH},PosList);
        end
    else
       MODEL.rMat=options.rMat; 
       MODEL.energy=options.energy;
    end 
    
    if(~isfield(options,'useBPMx')),options.useBPMx=true(size(static.bpmList)); end
    if(~isfield(options,'useBPMy')),options.useBPMy=true(size(static.bpmList)); end
    if(~isfield(options,'useCorr')),options.useCorr=true(size(static.corrList)); end
    
    TrimsStrengths=lcaGetSmart(strcat(static.btrimList_e,':BCTRL'));
    %CorrectorStrengths=lcaGetSmart(strcat(static.corrList_e,':BCTRL'));
    [CorrMatrix,CorrMatrixAngles]=CorrectorOrbitMatrix_Fast(static,MODEL.rMat,Pos,MODEL.energy);
    [TrimsMatrix,TrimsMatrixAngles]=TrimsOrbitMatrix_Fast(static,MODEL.rMat,Pos,MODEL.energy);
    
    if(options.BSA_HB) %then it is time to get your data...
        b=toc;
        while(b<options.AcquisitionTime)
            pause(0.025); b=toc;
        end
        [BPMRawData,ts,PvList]=getBPMData_HB_timing(static.bpmList_e, 1, options.startTime);
    end
    
    if(isfield(options,'BASELINE'))
        disp('Reducing Baseline')
        [ReducedBaseline_POS, ReducedData_POS]=matchLaunchDoubleElimination(BPMRawData(12:14,:).',options.BASELINE(12:14,:).', [1,1,1], 1.5);
        BPMRawData=BPMRawData(:,ReducedBaseline_POS);
    end
    
    if(Do_Acquisition) %This will calculated avg X, avg Y, std X, std Y and filter TMIT
        BPMDataMeas=zeros(length(static.bpmList),2);
        BPMData=zeros(length(static.bpmList),2);
        BPMDataStd=zeros(length(static.bpmList),2);
        if(~isfield(options,'tmitMin')), options.tmitMin=-inf; end
        for II=1:Pos.nBPM %further exclude BPMs if they give NaNs (?)
            TempData=[BPMRawData(II,:);BPMRawData(II+Pos.nBPM,:);BPMRawData(II+2*Pos.nBPM,:)];
            TempData(:,any(isnan(TempData)))=[]; %Excludes NaN readings first
            if(isempty(TempData(3,:)>options.tmitMin))
                BPMData(II,1)=NaN;
                BPMDataStd(II,1)=NaN;
                BPMData(II,2)=NaN;
                BPMDataStd(II,2)=NaN;
                options.useBPMx(II)=false;
                options.useBPMy(II)=false;
                BPMDataMeas(II,1)=NaN;
                BPMDataMeas(II,2)=NaN;
            else
                BPMDataMeas(II,1)=mean(TempData(1,TempData(3,:)>options.tmitMin));
                BPMDataStd(II,1)=std(TempData(1,TempData(3,:)>options.tmitMin));
                BPMDataMeas(II,2)=mean(TempData(2,TempData(3,:)>options.tmitMin));
                BPMDataStd(II,2)=std(TempData(2,TempData(3,:)>options.tmitMin));
                
                BPMData(II,1)=BPMDataMeas(II,1) - target(II,1);
                BPMData(II,2)=BPMDataMeas(II,2) - target(II,2);
            end
        end
    end
  
    CorrMat=cell2mat(cellfun(@(x) x(1),static.corrList,'un',0));
    XCorrPos=find(CorrMat(options.useCorr,1)=='X');
    YCorrPos=find(CorrMat(options.useCorr,1)=='Y');
  
    useBPM=false(2*Pos.nBPM,1);
    useBPM(1:2:end)=options.useBPMx;
    useBPM(2:2:end)=options.useBPMy;
    
    SystemBPMData=zeros(2*Pos.nBPM,1);
    SystemBPMData(1:2:end)=BPMData(:,1); SystemBPMData(2:2:end)=BPMData(:,2);
    
    %CorrMatrix_Reduced = CorrMatrix(useBPM,options.useCorr);
    CorrMatrix_Reduced = TrimsMatrix(useBPM,:);
    if(~isfield(options,'fitSVDRatio')), options.fitSVDRatio=10^-5; end
    CorrMatrix_Reduced=CorrMatrix_Reduced(:,2:4);
    [SystemSolution,SystemSolution_Std] = util_lssvd(CorrMatrix_Reduced, SystemBPMData(useBPM), ones(size(BPMData(useBPM)))/10^6, options.fitSVDRatio); 
    
    SystemSolution=[0;SystemSolution];
    SystemSolution_Std=[0;SystemSolution_Std];
    
    SystemSolution=SystemSolution/1000;
    SystemSolution_Std=SystemSolution_Std/1000;
 
    Solution.SystemSolution=SystemSolution;
    Solution.SystemSolution_Std=SystemSolution_Std;
    Solution.OldTrims=TrimsStrengths;
    
    Solution.OldCorrReset=TrimsStrengths;
    Solution.NewTrims=TrimsStrengths - SystemSolution;
    %Solution.OutOfRange=(Solution.NewCorr<static.corrRange(options.useCorr,1)) | (Solution.NewCorr>static.corrRange(options.useCorr,2));
    Solution.OutOfRange=0*size(TrimsStrengths);
    Solution.FAILED=any(Solution.OutOfRange);
    Solution.UsedTrims=static.btrimList;
    Solution.UsedTrims_e=static.btrimList_e;
      
    Solution.RecordedOrbitMinusTarget=BPMData;
    Solution.RecordedOrbit=BPMDataMeas;
    Solution.RecordedOrbitStd=BPMDataStd;
    Solution.options=options;
    
    Solution.BPMRawData=BPMRawData;
    
    Solution.MODEL=MODEL;
    Solution.MODEL.TrimsMatrix=TrimsMatrix;
    Solution.MODEL.TrimsMatrixAngles=TrimsMatrixAngles;

end
