function fh=ULT_HXU_functions()
    fh.Useg_Init=@Useg_Init; 
    fh.Set_K=@HXU_Set_K;
    fh.Set_K_struct=@HXU_Set_K_struct;
%     fh.Get_K=@HXU_Get_K_from_K;
%     fh.Get_K_alternate=@HXU_Get_K_from_Gap;
    
    fh.Get_K=@HXU_Get_K_from_Gap;
    fh.Get_K_alternate=@HXU_Get_K_from_K;
    
    fh.Get_State_String=@HXU_Get_State_String;
    fh.Set_State=@HXU_Set_State;
    fh.Get_State=@HXU_Get_State;
    
    fh.Set_State_struct=@HXU_Set_State_struct;
    
    fh.Get_Temperature=@HXU_Get_Temperature;
    
    fh.K_to_gap=@K_to_gap;
    fh.gap_to_K=@gap_to_K;
    fh.K_to_gap_dumb=@K_to_gap_dumb;
    
    fh.Get_TaperRange=@HXU_TaperRange;
    
    fh.Move_Out=@HXU_Move_Out;
    fh.Move_In=@HXU_Move_In;
    
    fh.Move_Out_struct=@HXU_Move_Out_struct;
    fh.Move_In_struct=@HXU_Move_In_struct;
    
    fh.LoadKGapConversion=@HXU_LoadKGapConversion;
    fh.LoadSplineFile=@LoadSplineFile;
    
    fh.ExEy2Stokes=@Stokes2ExEy;
    
    fh.Set_Gap=@HXU_Set_Gap;
    fh.Get_Gap=@HXU_Get_Gap;
    
    fh.k_to_keff=@k_to_keff;
    fh.keff_and_harm_to_k=@keff_and_harm_to_k;
    fh.eval_harmonic_K=@eval_harmonic_K;
       
    fh.isMoving=@isMoving;
    fh.openEDM=@HXU_openEDM;
    fh.plotUndulator=@plotUndulator;
end

function Temperature=HXU_Get_Temperature(USEG)
    Temperature=lcaGetSmart(USEG.pv.TemperatureAct); % This avoids any impact of temperature.
end

function HXU_openEDM(CallingObject,Void,USEG,q,c,s) 
%disp(['This will open the EDM screen for undulator ',undulator.PV]);
    PhasPV=regexprep(USEG.PV,'USEG','PHAS');
    PhasPV=regexprep(PhasPV,'50','95');
    CMPV=regexprep(USEG.PV,'USEG','MOVR');
    IOC=['IOC:UNDH:UC',USEG.Cell_String];
    CommandString=['! edm -x -m "U=',USEG.PV,',CELL=',USEG.Cell_String,',PS=',PhasPV,',ioc=',IOC,',CM=',CMPV,'" mc_undh_cell_main.edl &'];
    eval(CommandString)
end

function OUT=isMoving(USEG)
    Val=lcaGetSmart(USEG.pv.Moving);
    if(Val==USEG.MovingVAL)
        OUT=1;
    else
        OUT=0;
    end
end

function OUT=HXU_Set_Gap(USEG,GapDes)
    OUT=1;
    if((GapDes<USEG.GapMin) || (GapDes>USEG.GapOut))
        OUT=0;
        return
    end
    UndGapSetRaw ('HXR', USEG.Cell_Number, GapDes, 1);
%     if(nargin>2)
%         if((TaperDes<min(USEG.TaperRange)) || (TaperDes>max(USEG.TaperRange)))
%             OUT=0;
%             return
%         end
%         lcaPutNoWait(USEG.pv.TaperDes,TaperDes);
%     end
%     lcaPutNoWait(USEG.pv.GapDes,GapDes);
%     tic
%     while(toc<0.25 || (abs(lcaGetSmart(USEG.pv.GapDes)-GapDes)>0.0001))
%         pause(0.05);
%     end
%     lcaPutNoWait(USEG.pv.Go,1);
%     tic
%     while(toc<0.25 || ~lcaGetSmart(USEG.pv.Go))
%         pause(0.05);
%     end
%     lcaPutNoWait(USEG.pv.Go,0); 
end

function OUT=HXU_Get_Gap(USEG)
    OUT=lcaGetSmart(USEG.pv.GapAct);
end

function OUT=HXU_isMoving(USEG)
    VAL=lcaGetSmart(USEG.pv.Moving);
    if(~isnan(VAL))
        OUT=VAL==USEG.MovingVAL;
    else
        OUT=NaN;
    end
end

function USEG=Useg_Init(USEG)
%    fh=ULT_HXU_functions();
    if(USEG.Type==3)
        USEG.Period=26; %mm
        USEG.Period_m=26/1000; %mm
    elseif(USEG.Type==4)
        USEG.Period=39; %mm
        USEG.Period_m=39/1000; %mm
    end
    USEG.TaperRange=[-0.3,0.3]; % mm.
    USEG.pv.KAct=[USEG.PV,':KAct']; %Upstream K Act
    USEG.pv.DSKAct=[USEG.PV,':DSKAct']; %Downstream K Act 
    USEG.pv.KDes=[USEG.PV,':KDes']; %This is the K upstream Des
    USEG.pv.TaperDes=[USEG.PV,':TaperDes']; %Note this is in micron for now!
    USEG.pv.TaperAct=[USEG.PV,':TaperAct']; %Note this is in micron for now!
    USEG.pv.TempAdjust=[USEG.PV,':TempAdjust']; %1/0 if temp adjust is used or not
    USEG.pv.KTempCoeff=[USEG.PV,':KTempCoeff']; %K linear coefficient?
    USEG.pv.GapDes=[USEG.PV,':GapDes']; %maybe it exists: to crosscheck
    %USEG.pv.GapAct=[USEG.PV,':GapAct'];
    USEG.pv.MoveSegment=[USEG.PV,':ConvertK2Gap.PROC']; 
    USEG.pv.Go=[USEG.PV,':Go.VAL']; 
    USEG.pv.Moving=[USEG.PV,':MotorsMoving']; % 1 if moving
    USEG.pv.IdControlMsg=[USEG.PV,':IdControlMsg'];
    USEG.pv.TemperatureAct=[USEG.PV,':MeanTemp'];
    USEG.pv.US_FullGapEncoder=[USEG.PV,':US:EncRbck'];
    USEG.pv.GapAct=[USEG.PV,':US:EncRbck'];
    USEG.pv.DS_FullGapEncoder=[USEG.PV,':DS:EncRbck'];
    USEG.splinefiles.k_vs_gap=['/u1/lcls/epics/ioc/data/ioc-undh-uc',USEG.Cell_String,'/datafiles/hxu_cell',USEG.Cell_String,'_kvsgap_spline.dat'];
    USEG.splinefiles.i1x_vs_gap=['/u1/lcls/epics/ioc/data/ioc-undh-uc',USEG.Cell_String,'/datafiles/hxu_cell',USEG.Cell_String,'_i1xvsgap_spline.dat'];
    USEG.splinefiles.i2x_vs_gap=['/u1/lcls/epics/ioc/data/ioc-undh-uc',USEG.Cell_String,'/datafiles/hxu_cell',USEG.Cell_String,'_i2xvsgap_spline.dat'];
    USEG.splinefiles.i1y_vs_gap=['/u1/lcls/epics/ioc/data/ioc-undh-uc',USEG.Cell_String,'/datafiles/hxu_cell',USEG.Cell_String,'_i1yvsgap_spline.dat'];
    USEG.splinefiles.i2y_vs_gap=['/u1/lcls/epics/ioc/data/ioc-undh-uc',USEG.Cell_String,'/datafiles/hxu_cell',USEG.Cell_String,'_i2yvsgap_spline.dat'];
    USEG.splinefiles.orbitCorrection_vs_gap=['/u1/lcls/matlab/undulator/XYcorrSplineData/GapCorr_H_',regexprep(USEG.PV,':','_'),'.dat'];
    USEG.splinefiles.phase_match_enter_vs_gap=['/u1/lcls/epics/ioc/data/ioc-undh-uc',USEG.Cell_String,'/datafiles/hxu_cell',USEG.Cell_String,'_phasematchentervsgap_spline.dat'];
    USEG.splinefiles.phase_match_exit_vs_gap=['/u1/lcls/epics/ioc/data/ioc-undh-uc',USEG.Cell_String,'/datafiles/hxu_cell',USEG.Cell_String,'_phasematchexitvsgap_spline.dat'];
    [USEG.splinedata.K_vs_gap,Table]=LoadSplineFile(USEG.splinefiles.k_vs_gap,1);
    [USEG.splinedata.i1x_vs_gap]=LoadSplineFile(USEG.splinefiles.i1x_vs_gap,2);
    [USEG.splinedata.i2x_vs_gap]=LoadSplineFile(USEG.splinefiles.i2x_vs_gap,3);
    [USEG.splinedata.i1y_vs_gap]=LoadSplineFile(USEG.splinefiles.i1y_vs_gap,4);
    [USEG.splinedata.i2y_vs_gap]=LoadSplineFile(USEG.splinefiles.i2y_vs_gap,5);
    [USEG.splinedata.dPI_enter_vs_gap]=LoadSplineFile(USEG.splinefiles.phase_match_enter_vs_gap,6);
    [USEG.splinedata.dPI_exit_vs_gap]=LoadSplineFile(USEG.splinefiles.phase_match_exit_vs_gap,7);
    [USEG.splinedata.orbitCorrection_vs_gap]=LoadSplineFile(USEG.splinefiles.orbitCorrection_vs_gap,9);
    
    USEG.splinedata.cell=USEG.Cell_Number;
    
    %fmtpi_vs_gap                 = 'hxps_cell%2.2d_pivsgap_spline.dat';
    USEG.Temperature_MMF=str2double(USEG.splinedata.K_vs_gap.MMFtemp);
    USEG.Serial=USEG.splinedata.K_vs_gap.SerialNumber;
    USEG.kgap_spline=Table;
   
    USEG.Temperature_Coefficient=lcaGetSmart([USEG.PV,':KTempCoeff']);
    USEG.MovingVAL=1; %this says that 1 is moving.
    USEG.isMaintenance=0;
    USEG.f.panel={@ULT_HXU_RegularUndulator,@HXU_openEDM};
    USEG.panelNames={'Matlab USEG Panel','Open EDM Screen'};
    USEG=HXU_LoadKGapConversion(USEG);
    USEG.SegmentLength=USEG.z_end-USEG.z_ini;
    if(USEG.Type==3)
        USEG.CommissioningK=2.34;
        USEG.GapMin=7.2; %mm
        USEG.GapMax=30; %mm
        USEG.GapOut=100; %mm
        USEG.GapIn=15.71; %mm
        USEG.K_nominal=2.34;
        USEG.SegmentPeriods=130;
        USEG.BreakLength = 0.612666666666667;                 % m
        USEG.SegmentLength = 3.40;                                      % m
        USEG.CellLength = USEG.BreakLength + USEG.SegmentLength;   % m
        USEG.Kmax=2.44;
        USEG.Kmin=0.0001;
        USEG.Krange_native=gap_to_K(USEG,[USEG.GapMax,USEG.GapMin]);
        USEG.Kout=0.2;
    elseif(USEG.Type==4)
        USEG.CommissioningK=4.05;
        USEG.Period=39; %mm
        USEG.GapMin=7.2; %mm
        USEG.GapMax=30; %mm
        USEG.GapOut=100; %mm
        USEG.GapIn=15.71; %mm
        USEG.K_nominal=4.05;
        USEG.SegmentPeriods=87;
        USEG.BreakLength = 1;                % m
        USEG.SegmentLength = 3.40;                                      % m
        USEG.CellLength = USEG.BreakLength + USEG.SegmentLength;   % m
        USEG.Kmax=5.48;
        USEG.Kmin=0.0001;
        USEG.Krange_native=gap_to_K(USEG,[USEG.GapMax,USEG.GapMin]);
        USEG.Kout=0.2;
    else
%         USEG.GapMin=7.2; %mm
%         USEG.GapMax=30; %mm
%         USEG.GapOut=100; %mm
%         USEG.GapIn=15.71; %mm
%         USEG.Krange_native=gap_to_K(USEG,[USEG.GapMax,USEG.GapMin]);
    end
end

function MoveSegment(USEG)
    lcaPutSmart(USEG.pv.MoveSegment,1);
end

function State_string=HXU_Get_State_String(USEG,ReferencePeriod,K)
    State_string='VER';
end

function Keff=k_to_keff(USEG, K,Harmonic,Ref_period)
if(USEG.Period~=Ref_period)
    Keff=sqrt( ( 2*USEG.Period*Harmonic - 2*Ref_period + K.^2*USEG.Period*Harmonic  ) / Ref_period);
else
    Keff=K;
end
end

function k=keff_and_harm_to_k(USEG,Keff,Harmonic,Ref_period)
        if(USEG.Period~=Ref_period)
            k= sqrt(-2 + (2*Ref_period + Keff.^2*Ref_period)/(USEG.Period*Harmonic ));
        else
            k= sqrt(-2+ 2/Harmonic + Keff.^2/Harmonic);
        end
end

function K_harm=eval_harmonic_K(K, harm)
    K_harm=sqrt(2.*harm-2+K(1).^2.*harm);
end

function Gaps=K_to_gap_dumb(USEG,K)
    USEG.TemperatureAct=USEG.f.Get_Temperature(USEG);
    USEG.kgap_spline(:,2) = USEG.kgap_spline(:,2)*(1 + (USEG.TemperatureAct-USEG.Temperature_MMF)*USEG.Temperature_Coefficient);
    Gaps=spline(USEG.kgap_spline(:,2),USEG.kgap_spline(:,1),K);
end

function Gaps=K_to_gap(USEG,K)
    %Dumb ignorant way:
    USEG.TemperatureAct=USEG.f.Get_Temperature(USEG);
    USEG.kgap_spline(:,2) = USEG.kgap_spline(:,2)*(1 + (USEG.TemperatureAct-USEG.Temperature_MMF)*USEG.Temperature_Coefficient);
    
    Gaps=spline(USEG.kgap_spline(:,2),USEG.kgap_spline(:,1),K);
    pp=spline(USEG.kgap_spline(:,1),USEG.kgap_spline(:,2));
    for II=1:length(K)
        POS=find(Gaps(II)>=pp.breaks,1,'last');
        if(isempty(POS))
            return
        end
        if(POS>(length(pp.breaks)-1) || (POS <1))
            return
        end
        c=pp.coefs(POS,:);
        Offset=pp.breaks(POS);
        if(isempty(Offset))
            Gaps(II)=NaN; continue % this is an idea give NaN if no solution
        end
        S1=-(c(2)/(3*c(1)))-(2^(1/3)*(-c(2)^2+3*c(1)*c(3)))/(3*c(1)*(-2*c(2)^3+9*c(1)*c(2)*c(3)-27*c(1)^2*c(4)+27*c(1)^2*K(II)+sqrt(4*(-c(2)^2+3*c(1)*c(3))^3+(-2*c(2)^3+9*c(1)*c(2)*c(3)-27*c(1)^2*c(4)+27*c(1)^2*K(II))^2))^(1/3))+(-2*c(2)^3+9*c(1)*c(2)*c(3)-27*c(1)^2*c(4)+27*c(1)^2*K(II)+sqrt(4*(-c(2)^2+3*c(1)*c(3))^3+(-2*c(2)^3+9*c(1)*c(2)*c(3)-27*c(1)^2*c(4)+27*c(1)^2*K(II))^2))^(1/3)/(3*2^(1/3)*c(1));
        S2= -(c(2)/(3*c(1)))+((1+1i*sqrt(3))*(-c(2)^2+3*c(1)*c(3)))/(3*2^(2/3)*c(1)*(-2*c(2)^3+9*c(1)*c(2)*c(3)-27*c(1)^2*c(4)+27*c(1)^2*K(II)+sqrt(4*(-c(2)^2+3*c(1)*c(3))^3+(-2*c(2)^3+9*c(1)*c(2)*c(3)-27*c(1)^2*c(4)+27*c(1)^2*K(II))^2))^(1/3))-((1-1i*sqrt(3))*(-2*c(2)^3+9*c(1)*c(2)*c(3)-27*c(1)^2*c(4)+27*c(1)^2*K(II)+sqrt(4*(-c(2)^2+3*c(1)*c(3))^3+(-2*c(2)^3+9*c(1)*c(2)*c(3)-27*c(1)^2*c(4)+27*c(1)^2*K(II))^2))^(1/3))/(6*2^(1/3)*c(1));
        S3= -(c(2)/(3*c(1)))+((1-1i*sqrt(3))*(-c(2)^2+3*c(1)*c(3)))/(3*2^(2/3)*c(1)*(-2*c(2)^3+9*c(1)*c(2)*c(3)-27*c(1)^2*c(4)+27*c(1)^2*K(II)+sqrt(4*(-c(2)^2+3*c(1)*c(3))^3+(-2*c(2)^3+9*c(1)*c(2)*c(3)-27*c(1)^2*c(4)+27*c(1)^2*K(II))^2))^(1/3))-((1+1i*sqrt(3))*(-2*c(2)^3+9*c(1)*c(2)*c(3)-27*c(1)^2*c(4)+27*c(1)^2*K(II)+sqrt(4*(-c(2)^2+3*c(1)*c(3))^3+(-2*c(2)^3+9*c(1)*c(2)*c(3)-27*c(1)^2*c(4)+27*c(1)^2*K(II))^2))^(1/3))/(6*2^(1/3)*c(1));
        
        S(1)=real(S1)+Offset;
        S(2)=real(S2)+Offset;
        S(3)=real(S3)+Offset;
        S(4)=Gaps(II);

        INV=spline(USEG.kgap_spline(:,1),USEG.kgap_spline(:,2),S);
        
        [~, minpos] = min(abs(INV - K(II)));
        
        Gaps(II)=S(minpos); % + soluzione del problema inverso 
    end
end

function K=gap_to_K(USEG,Gaps)
    USEG.TemperatureAct=USEG.f.Get_Temperature(USEG);
    if(~isnan(USEG.TemperatureAct))
        USEG.kgap_spline(:,2) = USEG.kgap_spline(:,2)*(1 + (USEG.TemperatureAct-USEG.Temperature_MMF)*USEG.Temperature_Coefficient);
        K=spline(USEG.kgap_spline(:,1),USEG.kgap_spline(:,2),Gaps);
    else
        USEG.kgap_spline(:,2) = USEG.kgap_spline(:,2);
        K=spline(USEG.kgap_spline(:,1),USEG.kgap_spline(:,2),Gaps);
    end
end

function plotUndulator(USEG,Ax,ULID,handles)

Kmax_reg = USEG.f.Get_K(USEG, handles.UL(ULID).Basic.Reference_lambda_u, 'max');
Kmin_reg = USEG.f.Get_K(USEG, handles.UL(ULID).Basic.Reference_lambda_u, 'min');
ReferenceLambda=handles.UL(ULID).Basic.Reference_lambda_u;
if(USEG.isMaintenance)
    RegularArea=rectangle('parent',Ax,'position',[USEG.z_ini,Kmin_reg,USEG.z_end-USEG.z_ini,Kmax_reg-Kmin_reg],'FaceColor',[0.45,0.45,0.45]);
else
    %save TEMP
    RegularArea=rectangle('parent',Ax,'position',[USEG.z_ini,Kmin_reg,USEG.z_end-USEG.z_ini,Kmax_reg-Kmin_reg],'FaceColor',[0.9,1,0.2]);
    hcmenu = uicontextmenu;
    
    for TT=1:numel(USEG.f.panel)
        hcb1 = {USEG.f.panel{TT},USEG,ReferenceLambda,handles.UL(ULID)};%['CrystalGUI_setplane(get(gco,''UserData''),1,get(gco,''parent''))'];%callbackhere!
        uimenu(hcmenu, 'Label',USEG.panelNames{TT}, 'Callback', hcb1);
    end 
    set(RegularArea,'uicontextmenu',hcmenu)
end
end


function MovePvs=HXU_Set_K(USEG,Keff,Harmonic,ReferencePeriod,OutputPVList)
    %Change K that if passed as Keff into acutal K, for chosen Harmonic
    %number
    MovePvs.allowed=0;
    MovePvs.reason='';
    K=keff_and_harm_to_k(USEG,Keff,Harmonic,ReferencePeriod);
    if(length(K)==1), K(2)=K(1); end  %if called with only one K, then 
    if(any(imag(K))), MovePvs.reason='a K is complex, likely harmonic number too high'; return, end
    Gaps=K_to_gap(USEG,K);
    Taper=Gaps(2)-Gaps(1);
    if(Taper<USEG.TaperRange(1))
        MovePvs.reason='Taper too negative'; return
    elseif(Taper>USEG.TaperRange(2))
        MovePvs.reason='Taper too positive'; return
    end
    if(any(K>USEG.Krange_native(2)))
        MovePvs.reason='A K is too large'; return
    elseif(any(K<USEG.Krange_native(1)))
        MovePvs.reason='A K is too small'; return
    end
    
    if(nargin<5), OutputPVList=0; end
    if(~OutputPVList) %just do it.
        %it may work with only K, or base K + taper, or a mixture!
        lcaPutNoWait(USEG.pv.GapDes,Gaps(1));
        lcaPutNoWait(USEG.pv.TaperDes,Taper);pause(0.01);
        lcaPutNoWait(USEG.pv.Go,1);
        MovePvs.allowed=1;
    else
        MovePvs.PvList{1}.names={USEG.pv.GapDes,USEG.pv.TaperDes};
        MovePvs.PvList{1}.vals={Gaps(1),Taper};
        MovePvs.PvList{2}.names={USEG.pv.Go};
        MovePvs.PvList{2}.vals={1};
        MovePvs.allowed=1;
    end
end

function Destination=HXU_Set_State_struct(USEG, TargetState,ReferencePeriod, UseRawSettings)
if(UseRawSettings)
    Destination.Type=USEG.Type;
    Destination.Cell=USEG.Cell_Number;
    Destination.Device=USEG.PV;
    if(ischar(TargetState.Gap))
        if(strcmpi(TargetState.Gap,'OUT'))
            TargetState.Harmonic=1;
            Destination.Gap=USEG.GapOut;
            Destination.GapEnd=USEG.GapOut;
            Destination.Taper=Destination.GapEnd - Destination.Gap;
        end
    else
        Destination.Gap=TargetState.Gap;
        if(isfield(Destination,'GapEnd'))
            Destination.GapEnd=TargetState.GapEnd;
        else
            Destination.GapEnd=TargetState.Gap;
        end
        Destination.Taper=TargetState.GapEnd - TargetState.Gap;
    end
    Destination.errors=0;
    Destination.pv_val{1}=[Destination.Gap,Destination.Taper];
    Destination.pv_name{1}={USEG.pv.GapDes,USEG.pv.TaperDes};
    Destination.pv_val{2}=1;
    Destination.pv_name{2}={USEG.pv.Go};
    K=gap_to_K(USEG,Destination.Gap);
    Ke=k_to_keff(USEG, K,TargetState.Harmonic,ReferencePeriod);
    Destination.K=Ke;
    Destination.Kend=Ke;
else
    Destination=HXU_Set_K_struct(USEG,[TargetState.K,TargetState.Kend],TargetState.Harmonic,ReferencePeriod);
end
end

function Destination=HXU_Set_K_struct(USEG,Keff,Harmonic,ReferencePeriod)
    %Change K that if passed as Keff into acutal K, for chosen Harmonic
    %number
    Destination.Type=USEG.Type;
    Destination.Cell=USEG.Cell_Number;
    Destination.Device=USEG.PV;
    Destination.K=NaN;
    Destination.Kend=NaN;
    Destination.Gap=NaN;
    Destination.GapEnd=NaN;
    Destination.Taper=NaN;
    Destination.errors=0;
    Destination.errorlog={};
    Destination.pv_val{1}=[];
    Destination.pv_name{1}={};
    if(ischar(Keff))
       if(strcmpi(Keff,'OUT'))
           Destination.Type=USEG.Type;
           Destination.Cell=USEG.Cell_Number;
           Destination.Device=USEG.PV;
           Destination.Gap=USEG.GapOut;
           Destination.GapEnd=USEG.GapOut;
           Destination.Taper=0;
           Destination.errors=0;
           Destination.pv_val{1}=[Destination.Gap,Destination.Taper,Destination.K];
           Destination.pv_name{1}={USEG.pv.GapDes,USEG.pv.TaperDes,USEG.pv.GapDes};
           Destination.pv_val{2}=1;
           Destination.pv_name{2}={USEG.pv.Go};
           K=gap_to_K(USEG,Destination.Gap);
           Ke=k_to_keff(USEG, K,Harmonic,ReferencePeriod);
           Destination.K=Ke;
           Destination.Kend=Ke; 
           return
       end
    end
    K=keff_and_harm_to_k(USEG,Keff,Harmonic,ReferencePeriod);
    if(length(K)==1), K(2)=K(1); end  %if called with only one K, then 
    if(any(imag(K))), Destination.errors=0; Destination.errorlog{end+1}='Unavailable K, harmonic combination'; return, end
    
    Gaps=K_to_gap(USEG,K);
    Taper=Gaps(2)-Gaps(1);
    if(Taper<USEG.TaperRange(1)), Taper=USEG.TaperRange(1); Destination.errors=1; Destination.errorlog{end+1}='Desired taper too negative';
    elseif(Taper>USEG.TaperRange(2)), Taper=USEG.TaperRange(2); Destination.errors=1; Destination.errorlog{end+1}='Desired taper too positive'; end
    
    if(any(K>USEG.Krange_native(2))), Destination.errors=1; Destination.errorlog{end+1}='A destination K is too large'; 
    elseif(any(K<USEG.Krange_native(1))) Destination.errors=1; Destination.errorlog{end+1}='A destination K is too small'; end 

    Destination.K=K(1);
    Destination.Kend=K(2);
    Destination.Gap=Gaps(1);
    Destination.GapEnd=Gaps(2);
    Destination.Taper=Taper;
    Destination.pv_val{1}=[Destination.Gap,Destination.Taper,Destination.K];
    Destination.pv_name{1}={USEG.pv.GapDes,USEG.pv.TaperDes,USEG.pv.GapDes};
    Destination.pv_val{2}=1;
    Destination.pv_name{2}={USEG.pv.Go};
end

function [K,Kend]=HXU_Get_K_from_K(USEG,ReferencePeriod,givenPosition)
if(nargin<3) %it reads the K value from the machine
     K = lcaGetSmart(USEG.pv.KAct);
     Kend=lcaGetSmart(USEG.pv.DSKAct) ;
     %one can read gap and convert;
     %Gap = lcaGetSmart(USEG.pv.GapAct);
     %Gap_end=lcaGetSmart(USEG.pv.TaperAct);
     %K = gap_to_K(USEG,Gap);
     %Kend=gap_to_K(USEG,Gap_end);
     if(K<USEG.Kout)
        K=0; Kend=0; 
     end
else
    if(strcmp(givenPosition,'max'))
        gmax=7;
        K = gap_to_K(USEG,gmax); Kend=K;
    elseif(strcmp(givenPosition,'min'))
        gmin=20;
        K = gap_to_K(USEG,gmin); Kend=K;
    else
        x=givenPosition;
        K = gap_to_K(USEG,x); Kend=K;
    end
end

if(ReferencePeriod(1))
    if(ReferencePeriod(1)~=USEG.Period)
        K=k_to_keff(USEG,K,1,ReferencePeriod);
        Kend=k_to_keff(USEG,Kend,1,ReferencePeriod);
    end
end

if(K(1)==0)
    K=K*0;
    Kend=Kend*0;
end

end

function [K,Kend]=HXU_Get_K_from_Gap(USEG,ReferencePeriod,givenPosition)
if(nargin<3) %it reads the K value from the machine
     Gap = lcaGetSmart(USEG.pv.GapAct);
     Gap_end= lcaGetSmart(USEG.pv.DS_FullGapEncoder);%  Gap+lcaGetSmart(USEG.pv.TaperAct);
     K = gap_to_K(USEG,Gap);
     Kend=gap_to_K(USEG,Gap_end);
     if(K<USEG.Kout)
        K=0; Kend=0; 
     end
else
    if(strcmp(givenPosition,'max'))
        gmax=USEG.GapMin;
        K = gap_to_K(USEG,gmax); Kend=K;
    elseif(strcmp(givenPosition,'min'))
        gmin=USEG.GapMax;
        K = gap_to_K(USEG,gmin); Kend=K;
    else
        x=givenPosition;
        K = gap_to_K(USEG,x); Kend=K;
    end
end

if(ReferencePeriod(1))
    if(ReferencePeriod(1)~=USEG.Period)
        K=k_to_keff(USEG,K,1,ReferencePeriod);
        Kend=k_to_keff(USEG,Kend,1,ReferencePeriod);
    end
end

if(K(1)==0)
    K=K*0;
    Kend=Kend*0;
end

end

function MovePvs=HXU_Set_State(USEG,StateStructure)
    MovePvs=[];
    if(nargin<3)
        if(~OutputPVList) %just do it. 
            lcaPutNoWait(USEG.pv.GapDes,StateStructure.Gap);
            lcaPutNoWait(USEG.pv.TaperDes,StateStructure.GapTaper);pause(0.01);
            lcaPutNoWait(USEG.pv.MoveSegment,1);
        end
    end
    MovePvs.PvList{1}.names={USEG.pv.GapDes,USEG.pv.TaperDes};
    MovePvs.PvList{1}.vals={StateStructure.Gap,StateStructure.GapTaper};
    MovePvs.PvList{1}.names={USEG.pv.MoveSegment};
    MovePvs.PvList{1}.vals={1};
end

function StateStructure=HXU_Get_State(USEG,ReferencePeriod,givenPosition)
    StateStructure.StatusString='VER';
    
    if(nargin<3) %it reads the K value from the machine
        K = lcaGetSmart(USEG.pv.KAct);
        Kend=lcaGetSmart(USEG.pv.DSKAct);
        %one can read gap and convert
        Gap = lcaGetSmart(USEG.pv.GapAct);
        Gap_end= lcaGetSmart(USEG.pv.DS_FullGapEncoder);
        GapTaper=Gap_end-Gap;
        %K = gap_to_K(USEG,Gap);
        %Kend=gap_to_K(USEG,Gap_end);
    else
        if(strcmp(givenPosition,'max'))
            gmax=USEG.GapMax; Gap=gmax; GapTaper=0; Gap_end = Gap+GapTaper;
            K = gap_to_K(USEG,gmax); Kend=K;
        elseif(strcmp(givenPosition,'min'))
            gmin=USEG.GapMin; Gap=gmin; GapTaper=0; Gap_end = Gap+GapTaper;
            K = gap_to_K(USEG,gmin); Kend=K;
        else
            x=givenPosition; Gap=x; GapTaper=0; Gap_end = Gap+GapTaper;
            K = gap_to_K(USEG,x); Kend=K;
        end
    end
    
    StateStructure.native_K=K;
    StateStructure.native_Kend=Kend;
    StateStructure.native_KRangeFundamental=gap_to_K(USEG,Gap(1)+USEG.TaperRange);
    
    if(length(ReferencePeriod)==2) %second part of reference period is used to check further harmonics and add them to K
        harm=2;
        while(K(end)<ReferencePeriod(2))
            Knew=sqrt(2*harm-2+K(1)^2*harm);
            Knew2=sqrt(2*harm-2+Kend(1)^2*harm);
            if(Knew<ReferencePeriod(2))
                K(end+1)=Knew;
                Kend(end+1)=Knew2;
            else
                break
            end
            harm=harm+1;
        end
    end
    
    if(ReferencePeriod(1))
        if(ReferencePeriod(1)~=USEG.Period)

        K=k_to_keff(USEG,K,1,ReferencePeriod);
        Kend=k_to_keff(USEG,Kend,1,ReferencePeriod);
%             K=sqrt(2*(USEG.Period/ReferencePeriod(1))*(1+ K.^2/2) - 2);
%             Kend=sqrt(2*(USEG.Period/ReferencePeriod(1))*(1+ Kend.^2/2) - 2);
            StateStructure.KRangeFundamental=k_to_keff(USEG,ReferencePeriod,StateStructure.native_KRangeFundamental);
        end
    end
    
    if(K(1)==0)
        K=K*0;
        Kend=Kend*0;
    end
    
    StateStructure.NativePeriod=USEG.Period;
    StateStructure.ReferencePeriod=ReferencePeriod;
    StateStructure.K=K;
    StateStructure.TaperRange=USEG.TaperRange;
    StateStructure.Kend=Kend;
    StateStructure.Gap=Gap;
    StateStructure.GapTaper=GapTaper;
    StateStructure.Gap_end=Gap_end;
    StateStructure.Harm=1:length(K);
    StateStructure.StokesParameters=ExEy2Stokes([K^2,0,0]);
    StateStructure.StokesParameters_end=ExEy2Stokes([Kend^2,0,0]);
end

function S=ExEy2Stokes(ExEyV)
    S(1)=ExEyV(1);
    S(2)=ExEyV(1)*(2*ExEyV(2)-1);
    S(3)=2*ExEyV(1)*sqrt(ExEyV(2)*(1-ExEyV(2)))*cos(ExEyV(3)/180*pi);
    S(4)=-2*ExEyV(1)*sqrt(ExEyV(2)*(1-ExEyV(2)))*sin(ExEyV(3)/180*pi);
end

function KRange=HXU_TaperRange(USEG)
    Gap=lcaGetSmart(USEG.pv.GapAct);
    Gaps=Gap+USEG.TaperRange;
    KRange=gap_to_K(USEG,Gaps);
end

function HXU_Move_Out(USEG)
    lcaPutNoWait(USEG.pv.GapDes,USEG.GapOut);
    lcaPutNoWait(USEG.pv.TaperDes,0);pause(0.01);
    lcaPutNoWait(USEG.pv.Go,1);
    lcaPutNoWait(USEG.pv.Go,0);
end

function Destination=HXU_Move_Out_struct(USEG)
    Destination.Type=USEG.Type;
    Destination.Cell=USEG.Cell_Number;
    Destination.Gap=USEG.GapOut;
    Destination.GapEnd=USEG.GapOut; 
    Destination.K=USEG.f.gap_to_K(USEG,USEG.GapOut);
    Destination.Kend=Destination.K;
    Destination.Gap=USEG.GapOut;
    Destination.GapEnd=USEG.GapOut;
    Destination.Taper=0;
    Destination.pv_val{1}=[Destination.Gap,Destination.Taper,Destination.K];
    Destination.pv_name{1}={USEG.pv.GapDes,USEG.pv.TaperDes,USEG.pv.GapDes};
    Destination.pv_val{2}=1;
    Destination.pv_name{2}={USEG.pv.Go};
end

function USEG=HXU_LoadKGapConversion(USEG)
    filename=['/u1/lcls/epics/ioc/data/ioc-undh-uc',USEG.Cell_String,'/datafiles/hxu_cell',USEG.Cell_String,'_kvsgap_spline.dat'];
    FID=fopen(filename);
    if(FID==-1)
       disp('File Not Found') 
    end
    LINE=fgetl(FID);LINE=fgetl(FID);LINE=fgetl(FID);
    STR=strfind(LINE,'# Serial:');
    if(~isempty(STR))
        USEG.Serial=regexprep(LINE((length('# Serial:')+STR):end),' ','');
    else
        USEG.Serial=NaN;
    end
    LINE=fgetl(FID);
    STR=strfind(LINE,'# Temperature:');
    if(~isempty(STR))
        Temperature=regexprep(LINE((length('# Temperature:')+STR):end),'C','');
        USEG.Temperature_MMF=str2double(Temperature);
    else
        USEG.Temperature_MMF=NaN;
    end
    LINE=fgetl(FID);
    while(LINE(1)=='#')
        LINE=fgetl(FID);
    end
    ins=0;USEG.kgap_spline=zeros(58,2);
    while(~feof(FID))
       LINE=fgetl(FID);
       ins=ins+1;
       USEG.kgap_spline(ins,:)=str2num(['[',LINE,']']);
    end
    USEG.kgap_spline=USEG.kgap_spline(1:ins,:);
    fclose(FID);
end

function HXU_Move_In(USEG)
    GAP=lcaGetSmart(USEG.pv.GapAct);
    if(GAP>USEG.GapMax)
        lcaPutNoWait(USEG.pv.GapDes,USEG.GapIn);
        lcaPutNoWait(USEG.pv.TaperDes,0);pause(0.01);
        lcaPutNoWait(USEG.pv.Go,1);
        lcaPutNoWait(USEG.pv.Go,0);
    end
end

function Destination=HXU_Move_In_struct(USEG)
    GAP=lcaGetSmart(USEG.pv.GapAct);
    Destination.Type=USEG.Type;
    Destination.Cell=USEG.Cell_Number;
    if(GAP>USEG.GapMax)
        Destination.Gap=USEG.GapIn;
        Destination.GapEnd=USEG.GapIn; 
        Destination.K=USEG.f.gap_to_K(USEG,USEG.GapIn);
        Destination.Kend=Destination.K;
        Destination.Gap=USEG.GapOut;
        Destination.GapEnd=USEG.GapOut;
        Destination.Taper=0;
        Destination.pv_val{1}=[Destination.Gap,Destination.Taper,Destination.K];
        Destination.pv_name{1}={USEG.pv.GapDes,USEG.pv.TaperDes,USEG.pv.GapDes};
        Destination.pv_val{2}=1;
        Destination.pv_name{2}={USEG.pv.Go};
    else
        Destination=[];
    end 
end

function ExEyV=Stokes2ExEy(S)
    ExEyV(1)=S(1);
    ExEyV(2)=(S(2)/S(1)+1)/2;
    ExEyV(3)=angle(S(3)-1i*S(4))*180/pi;
end

function [SP_OUT,Table]=LoadSplineFile(file,type)
    FID=fopen(file);
    if(FID==-1)
       disp('File Not Found') 
       file
    end
    %Always
    SP_OUT.SerialNumber='';SP_OUT.Dataset=1;SP_OUT.MMFtemp='';SP_OUT.MMFtemp_unit='C'; ColumnSize=2;
    switch(type)
        case 1 % kvsgap_spline files
            SP_OUT.gap_unit='mm'; SP_OUT.K_unit=''; var1='gap'; var2='K';
        case 2 % i1x_vs_gap spline
            SP_OUT.gap_unit='mm'; SP_OUT.I1x_unit='Tm'; var1='gap'; var2='I1x';
        case 3 % i2x_vs_gap spline
            SP_OUT.gap_unit='mm'; SP_OUT.I2x_unit='Tm^2'; var1='gap'; var2='I2x';
        case 4 % i1y_vs_gap spline
            SP_OUT.gap_unit='mm'; SP_OUT.I1y_unit='Tm'; var1='gap'; var2='I1y';
        case 5 % i2y_vs_gap spline
            SP_OUT.gap_unit='mm'; SP_OUT.I2y_unit='Tm^2'; var1='gap'; var2='I2y';
        case 6 % dPI_enter_vs_gap
            SP_OUT.gap_unit='mm'; SP_OUT.dPI_unit='T^2mm^3'; var1='gap'; var2='dPI';
        case 7 % dPI_exit_vs_gap
            SP_OUT.gap_unit='mm'; SP_OUT.dPI_unit='T^2mm^3'; var1='gap'; var2='dPI';
        case 8 % dPI_exit_vs_gap
            SP_OUT.gap_unit='mm'; SP_OUT.dPI_unit='T^2mm^3'; var1='gap'; var2='PI';
        case 9 % dPI_exit_vs_gap
            SP_OUT.gap_unit='mm'; SP_OUT.Corrector_units='kGm'; var1='gap'; ColumnSize=5; SP_OUT.MMFtemp='n/a';SP_OUT.MMFtemp_unit='n/a'; 
    end
    LINE=fgetl(FID);
    while(any(LINE=='#'))
       if(type<9)
           STR=strfind(LINE,'# Serial:');
           if(~isempty(STR))
               SP_OUT.SerialNumber=regexprep(LINE((length('# Serial:')+STR):end),' ','');
               if(any(strfind(SP_OUT.SerialNumber,'PS')))
                   SP_OUT.SN=str2double(SP_OUT.SerialNumber((end-4):end));
               else
                   SP_OUT.SN=str2double(SP_OUT.SerialNumber((end-2):end));
               end
           end
           STR=strfind(LINE,'# Temperature:');
           if(~isempty(STR))
               SP_OUT.MMFtemp=regexprep(LINE((length('# Temperature:')+STR):end),{' ','C','F'},'');
           end
           STR=strfind(LINE,'# Date:');
           if(~isempty(STR))
               SP_OUT.inFileDate=LINE((length('# Date: ')+STR):end);
               SP_OUT.Rundate=regexprep(SP_OUT.inFileDate(1:10),'-','/');
           end
       elseif(type==9)
           STR=strfind(LINE,'# Undulator Serial =');
           if(~isempty(STR))
               SP_OUT.SerialNumber=regexprep(LINE((length('# Undulator Serial =')+STR):end),' ','');
           end
           STR=strfind(LINE,'# Phaseshifter Serial =');
           if(~isempty(STR))
               SP_OUT.SerialNumber=regexprep(LINE((length('# Phaseshifter Serial =')+STR):end),' ','');
           end
           STR=strfind(LINE,'# Previous Corrector X =');
           if(~isempty(STR))
               SP_OUT.PreviousCorrectorX=regexprep(LINE((length('# Previous Corrector X =')+STR):end),' ','');
               var2=regexprep(SP_OUT.PreviousCorrectorX,':','_');
           end
           STR=strfind(LINE,'# Previous Corrector Y =');
           if(~isempty(STR))
               SP_OUT.PreviousCorrectorY=regexprep(LINE((length('# Previous Corrector Y =')+STR):end),' ','');
               var3=regexprep(SP_OUT.PreviousCorrectorY,':','_');
           end
           STR=strfind(LINE,'# Next Corrector X =');
           if(~isempty(STR))
               SP_OUT.NextCorrectorX=regexprep(LINE((length('# Next Corrector X =')+STR):end),' ','');
               var4=regexprep(SP_OUT.NextCorrectorX,':','_');
           end
           STR=strfind(LINE,'# Next Corrector Y =');
           if(~isempty(STR))
               SP_OUT.NextCorrectorY=regexprep(LINE((length('# Next Corrector Y =')+STR):end),' ','');
               var5=regexprep(SP_OUT.NextCorrectorY,':','_');
           end
           STR=strfind(LINE,'# Date:');
           if(~isempty(STR))
               SP_OUT.inFileDate=LINE((length('# Date: ')+STR):end);
               SP_OUT.Rundate=regexprep(SP_OUT.inFileDate(1:10),'-','/');
           end
           STR=strfind(LINE,'# EpicsDevice =');
           if(~isempty(STR))
               SP_OUT.EpicsDevice=regexprep(LINE((length('# EpicsDevice =')+STR):end),' ','');
           end
           STR=strfind(LINE,'# MadDevice =');
           if(~isempty(STR))
               SP_OUT.MadDevice=regexprep(LINE((length('# MadDevice =')+STR):end),' ','');
           end
           
       end
       LINE=fgetl(FID); 
    end
    ins=0; Table=zeros(80,ColumnSize);
    while(~feof(FID))
       LINE=fgetl(FID);
       ins=ins+1;
       Table(ins,:)=str2num(['[',LINE,']']);
    end
    fclose(FID);
    Table=Table(1:ins,:);
    SP_OUT.(var1)=Table(:,1);
    SP_OUT.(var2)=Table(:,2);
    if(type==9)
        SP_OUT.(var3)=Table(:,3);
        SP_OUT.(var4)=Table(:,4);
        SP_OUT.(var5)=Table(:,5); 
    end
end
