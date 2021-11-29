function fh=ULT_UndulatorLine_functions
    addpath ( genpath ( '/home/physics/nuhn/wrk/matlab' ) );  
    addpath ( genpath ( '/home/physics/wolf/PhaseShifterManager' ) ); 
    %addpath ( '/home/physics/nuhn/wrk/matlab/cams' );
    fh.Red_Line=@Red_Line;
    fh.HXU_Init=@HXU_Init;
    fh.SXU_Init=@SXU_Init;
    fh.UnknownBeamLine_Init=@UnknownBeamLine_Init;
     
    fh.Read_all_K_values=@Read_all_K_values;
    fh.Read_all_K_values_alternate=@Read_all_K_values_alternate;
    fh.ReadAllLine=@ReadWholeUndulator;
    fh.Restore_all_K_values=@Restore_all_K_values;
    fh.AnyUndulatorMoving=@AnyUndulatorMoving;
    fh.MoveInSegments=@MoveInSegments_struct;
    fh.MoveOutSegments=@MoveOutSegments_struct;
    fh.MoveInSegments_alternate=@MoveInSegments;
    fh.MoveOutSegments_alternate=@MoveOutSegments;

    fh.LaunchFeedback_Set=@LaunchFeedback_Set;
    fh.LaunchFeedback_Get=@LaunchFeedback_Get;
    
    fh.BYKIK_Set=@BYKIK_Set;
    fh.BYKIK_Get=@BYKIK_Get;
    fh.SetTDUND=@SetTDUND; 
    fh.GetTDUND=@GetTDUND;
    
    fh.UndulatorLine_K_set=@UndulatorLine_K_set;
    fh.UndulatorLine_Status_set=@UndulatorLine_Status_set;
    fh.UndulatorLine_Status_set_RAW=@UndulatorLine_Status_set_RAW;

    fh.Set_phase_shifters=@Set_phase_shifters; %this calls Kact to KDes
    fh.PhaseShifterLine_Gap_set_RAW=@PhaseShifterLine_Gap_set_RAW;
    fh.PhaseShifterLine_Gap_set=@PhaseShifterLine_Gap_set;
    
    fh.SelectBBAMode=@SelectBBAMode;
    fh.PrepareForBBA=@PrepareForBBA;
    fh.GetPhase_alternate=@GetPhase_alternate;
    fh.GetPhase=@GetPhase;
    
    fh.hxr_ps_manage_update=@ULT_hxr_ps_manage_update;
    fh.sxr_ps_manage_update=@ULT_sxr_ps_manage_update;
    
    fh.Read_state_and_magnets=@ReadUndulatorLine_and_magnets;
end

function RestoreValues=LaunchFeedback_Set(UL, Destination_State) %turns feedback on, if destination state is true
    RestoreValues=lcaGet(UL.Basic.LaunchFeedbackPV,0,'double');
    if(Destination_State)
        lcaPutSmart(UL.Basic.LaunchFeedbackPV,UL.Basic.LaunchFeedback_On);
    else
        if(UL.Basic.LaunchFeedback_On)
            lcaPutSmart(UL.Basic.LaunchFeedbackPV,0);
        else
            lcaPutSmart(UL.Basic.LaunchFeedbackPV,1);
        end
    end
end

function RestoreValues=LaunchFeedback_Get(UL) %returns true if feedback is on.
    try
        LaunchPV_Value=lcaGet(UL.Basic.LaunchFeedbackPV,0,'double');
    catch
        RestoreValues=NaN;
        return
    end
    RestoreValues=(LaunchPV_Value==UL.Basic.LaunchFeedback_On);
end

function RestoreValues=BYKIK_Set(UL,InState)
    RestoreValues=lcaGetSmart(UL.Basic.bykikPV);
    if(ischar(InState))
        if (strcmpi(InState,'IN') || strcmpi(InState,'INSERT') || all(InState==UL.Basic.bykik_On))  %Command is to insert TDUND, returns old value.
            lcaPutSmart(UL.Basic.bykikPV,UL.Basic.bykik_On);
        end
        if (strcmpi(InState,'OUT') || strcmpi(InState,'REMOVE') || all(InState==(~UL.Basic.bykik_On)))  %Command is to remove TDUND, returns old value.
            lcaPutSmart(UL.Basic.bykikPV,double(~UL.Basic.bykik_On));
        end
    else
        if(InState)  %Command is to insert TDUND, returns old value.
            lcaPutSmart(UL.Basic.bykikPV,UL.Basic.bykik_On);
        else
            lcaPutSmart(UL.Basic.bykikPV,double(~UL.Basic.bykik_On));
        end
    end
end

function RestoreValues=BYKIK_Get(UL) %returns true if feedback is on.
    try
        BYKIKPV_Value=lcaGet(UL.Basic.bykikPV,0,'double');
    catch
        RestoreValues=NaN;
        return
    end
    RestoreValues=(BYKIKPV_Value==UL.Basic.bykik_On);
end

function RestoreValues=GetTDUND(UL) %returns true if feedback is on.
    try
        TDUNDPV_Value=lcaGet(UL.Basic.TDUNDPV,0,'double');
    catch
        RestoreValues=NaN;
        return
    end
    RestoreValues=(TDUNDPV_Value==UL.Basic.TDUND_In);
end

function RestoreValues=SetTDUND(UL,InState)
    RestoreValues=lcaGetSmart(UL.Basic.TDUNDPV);
    if(ischar(InState))
        if (strcmpi(InState,'IN') || strcmpi(InState,'INSERT') || all(InState==UL.Basic.TDUND_In))  %Command is to insert TDUND, returns old value.         
            lcaPutSmart(UL.Basic.TDUNDPV,UL.Basic.TDUND_In);
        end
        if (strcmpi(InState,'OUT') || strcmpi(InState,'REMOVE') || all(InState==(~UL.Basic.TDUND_In)))  %Command is to remove TDUND, returns old value.
            lcaPutSmart(UL.Basic.TDUNDPV,double(~UL.Basic.TDUND_In));
        end
    else
        if(InState)  %Command is to insert TDUND, returns old value.
            lcaPutSmart(UL.Basic.TDUNDPV,UL.Basic.TDUND_In);
        else
            lcaPutSmart(UL.Basic.TDUNDPV,double(~UL.Basic.TDUND_In));
        end
    end
end

function [Line,Magnets]=ReadUndulatorLine_and_magnets(UL, static)
for II=1:length(UL.slot)
        if(UL.slot(II).USEG.present)
            UndState=UL.slot(II).USEG.f.Get_State(UL.slot(II).USEG,UL.Basic.Reference_lambda_u);
            Line{II}.Undulator=UndState;
        else
            Line{II}.Undulator=NaN;
        end
        if(UL.slot(II).PHAS.present)
            PhasState=UL.slot(II).PHAS.f.Get_State(UL.slot(II).PHAS);
            LineReadout(II).Phase=PhasState.phaseDes;
            LineReadout(II).PhaseDes=PhasState.phaseDes;
            Line{II}.PS=PhasState;
        else
            LineReadout(II).Phase=NaN;
            LineReadout(II).PhaseDes=NaN;
            Line{II}.PS=NaN;
        end
        if(UL.slot(II).BEND.present)
            delay=UL.slot(II).BEND.f.get_Delay(UL.slot(II).BEND,UL);
            Line{II}.Delay=delay;
            Line{II}.bend=lcaGetSmart(strcat(UL.slot(II).BEND.PVs,':BCTRL'));
            Line{II}.btrm=lcaGetSmart(strcat(UL.slot(II).BEND.TrimPVs,':BCTRL'));
        else
            Line{II}.Delay=NaN;
        end
        LineReadout(II).slot=II;
end
if(true)  
Phi=GetPhase(UL, LineReadout);
PhaseShifters=cell2mat(UL.DeviceMap(:,4)); PhaseShifters(isnan(PhaseShifters))=0;
for II=1:length(Phi)
    if(isnan(Phi(II)))
        continue
    else
       CellTo=II;
       CellFrom=II-1;
       Value=Phi(II);
       if(any(UL.slotcell(logical(UL.UsegPresent)) == CellFrom))
           %ok
       else
           while(~any(UL.slotcell(logical(UL.UsegPresent)) == CellFrom))
              CellFrom=CellFrom-1;
              if(CellFrom==0), continue, end;
           end
       end
       if(CellFrom==0), continue, end;
       %[CellFrom:CellTo]
       AREA=CellFrom:(CellTo-1);
       [~,WS,WA]=intersect(UL.slotcell,AREA);
       LRTemp=[LineReadout(WS).PhaseDes];
       if(sum(~isnan(LRTemp))==0)
          %do nothing, maybe all undulators are out? Report PHI DES as phase and forget. 
       elseif(sum(~isnan(LRTemp))==1)
           %WS(~isnan(LRTemp))
           LineReadout(WS(~isnan(LRTemp))).Phase=Value;
       else
           CumulativePhase=0;
           for HH=1:length(WS)
              if(~isnan(LRTemp(HH)))
                 CumulativePhase=CumulativePhase+LRTemp(HH);
              end
           end
           PhaseDifference=md ( CumulativePhase );
           REST=Value-PhaseDifference;
           for HH=1:length(WS)
              if(~isnan(LRTemp(HH)))
                 LineReadout(WS(HH)).Phase=LineReadout(WS(HH)).PhaseDes + REST/sum(~isnan(LRTemp));
              end
           end
       end
    end
end

for II=1:length(LineReadout)
    if(isstruct(Line{II}.PS))
        Line{II}.PS.phase=LineReadout(II).Phase;
    end
end

end

Magnets.corr=lcaGetSmart(strcat(static(1).corrList_e,':BCTRL'));
Magnets.quad=lcaGetSmart(strcat(static(1).quadList_e,':BCTRL'));
Magnets.bend=lcaGetSmart(strcat(static(1).bendList_e,':BCTRL'));
Magnets.btrm=lcaGetSmart(strcat(static(1).btrimList_e,':BCTRL'));

end

function Phi=GetPhase_alternate(LineString)
    %use 'HXR' or 'SXR' as linestring
    %addpath (genpath('/home/physics/nuhn/wrk/matlab'))
    Phi=getUndCenterPhases(LineString);
end

function Phi=GetPhase(UL, LineReadout)
currentSegmentList = UL.Zach.UndConsts.currentSegmentCells;

PSdata             = UL.Zach.PSmanage ( UL.Zach.param, UL.Zach.PSdata );
phase_data         = phase_data_calc_phase(UL.Zach.param, PSdata);

PIdata             = UL.Zach.PIdata;

n                  = UL.Zach.UndConsts.SegmentCells ( end );
cellList           = ( 1 : n )';
Pgap               = ( cellList * 0 + NaN );
K                  = Pgap;
Ugap               = Pgap;
Phi_entr           = Pgap;
Phi_core           = Pgap;
Phi_exit           = Pgap;
Phi_cell           = Pgap;
Phi_drift          = Pgap;
Phi_ps             = Pgap;
Phi                = Pgap; % Phase between center of current and previous undulator
PhiCell_cc         = Pgap;
Phi_PSprefU        = Pgap;

DPHI               = cellList + NaN;
DPHI ( ismember ( cellList, UL.Zach.UndConsts.currentPSCells ) )   = lcaGet ( strcat ( UL.Zach.PVbase, num2str(UL.Zach.UndConsts.currentPSCells','%-d'), { UL.Zach.fmtDPHI } ) );

PSdata      = PSRead ( UL.Zach.line );
USdata      = UndRead ( UL.Zach.xray_line );

for j = 1 : PIdata.PHASentries
    PD              = PIdata.PHAS { j };
    c               = PD.cell;
    k               = find ( currentSegmentList == c );
    Pgap ( c )      = PSdata ( k, 4 );
end

for j = 1 : PIdata.USEGentries
    UD              = PIdata.USEG { j };
    c               = UD.cell;
    k               = find ( currentSegmentList == c );
    
    K         ( c ) = USdata ( k, 2 );
    Ugap      ( c ) = USdata ( k, 4 );
end

for c = cellList'
    Phi_entr  ( c ) = phase_data ( c ).phase_und_enter * 180 / pi;
    Phi_core  ( c ) = phase_data ( c ).phase_und_core  * 180 / pi;
    Phi_exit  ( c ) = phase_data ( c ).phase_und_exit  * 180 / pi;
    Phi_drift ( c ) = phase_data ( c ).phase_drift     * 180 / pi;
    
    if ( isnan ( Pgap ( c ) ) )
        Phi_ps    ( c ) = NaN;
    else
        Phi_ps    ( c ) = phase_data ( c ).phase_ps        * 180 / pi;
    end
    
    Phi_cell  ( c ) = phase_data ( c ).phase_cell      * 180 / pi;
end

betweenUndulators        = false;
inactiveUndulators       = 0;
inactiveUndulators_phi   = 0;
prevActiveUndulator      = 0;

for c = cellList';
    if ( isnan ( K ( c ) ) || Pgap ( c ) > 50 )
        if ( betweenUndulators )
            inactiveUndulators = inactiveUndulators + 1;
            
            inactiveUndulators_phi = inactiveUndulators_phi + Phi_drift ( c );
            
            if ( ~isnan ( Pgap ( c ) ) )
                inactiveUndulators_phi = inactiveUndulators_phi + Phi_ps ( c );
            end
        end
    else
        if ( betweenUndulators )
            PhiCell_cc ( c ) = Phi_core ( prevActiveUndulator ) / 2 + Phi_exit ( prevActiveUndulator ) + Phi_entr ( c ) + Phi_core ( c ) / 2;
            Phi_PSprefU   ( c ) = + Phi_ps ( prevActiveUndulator );
            Phi ( c ) = Phi_core ( prevActiveUndulator ) / 2 + Phi_exit ( prevActiveUndulator ) + Phi_ps ( prevActiveUndulator ) + Phi_entr ( c ) + Phi_core ( c ) / 2 + inactiveUndulators_phi;
        end
        
        betweenUndulators        = true;
        inactiveUndulators       = 0;
        inactiveUndulators_phi = 0;
        %        prevK                    = K ( c );
        prevActiveUndulator      = c;
    end
end

Phi = md ( Phi );
%result = [ cellList Ugap  K Pgap md(Phi_ps)  DPHI Phi ];
% 
% if ( nargin == 2 && strcmp ( command, 'list' ) )
%     fprintf ( '\n       LCLS-II %s Undulator Phase Matching %s\n',  undulatorLine, datestr ( now, 'mmmm dd, yyyy HH:MM:SS.FFF AM') );
%     fprintf ( '\n    cell    Undgap         K      PS gap     Phi PS      DPHI   center-center Phi\n' );
%     fprintf (   '     []      [mm]         []       [mm]       [deg]     [deg]          [deg]\n' );
%     
%     for p = 1 : n
%         fprintf ( '     %2.2d    %6.3f    %7.5f    %7.3f    %+7.3f    %+7.3f       %+7.3f\n', ...
%             cellList ( p ), Ugap ( p ), K ( p ), Pgap ( p ), md ( Phi_ps ( p ) ), DPHI ( p ), Phi ( p )  );
%     end
% end

end

function b = md ( a )

b = mod ( a + 180, 360 ) - 180;

end


function RestoreValues=SelectBBAMode(UL)
    RestoreValues=lcaGetSmart(UL.Basic.BBA_Lem_ModePV);
    lcaPutSmart(UL.Basic.BBA_Lem_ModePV,UL.Basic.BBA_Lem_Mode_On.');    
end

function PrepareForBBA(UL,GapState)
Harmonic=1; ins=0; insPhas=0;

if(GapState==1) %Go to the out position for every undulator, whatever it means.
    TargetState.Gap='out'; TargetState.Harmonic=1; UseRawSetting=1;
    for II=1:length(UL.slot)
        if(UL.slot(II).USEG.present)
            if(UL.slot(II).USEG.Type==3 || UL.slot(II).USEG.Type==4)
                NewDest=UL.slot(II).USEG.f.Set_State_struct(UL.slot(II).USEG,TargetState,UL.Basic.Reference_lambda_u,UseRawSetting);
                ins=ins+1;
                if(ins==1)
                    Destination(1)=NewDest;
                else
                    Destination(ins)=NewDest;
                end
            end
        end
        if(UL.slot(II).PHAS.present)
            TargetStatePhas.Gap=UL.slot(II).PHAS.GapOut;
            NewDestPhas=UL.slot(II).PHAS.f.Set_State_Struct(UL.slot(II).PHAS,TargetStatePhas);
            insPhas=insPhas+1;
            if(insPhas==1)
                DestinationPhas(1)=NewDestPhas;
            else
                DestinationPhas(insPhas)=NewDestPhas;
            end
        end
    end
    UL.f.UndulatorLine_Status_set_RAW(UL,Destination);
    UL.f.PhaseShifterLine_Gap_set_RAW(UL,DestinationPhas);
end
if(GapState==2) % Go to reference K and 0 taper.
    Harmonic=1; ins=0; insPhas=0;
    for II=1:length(UL.slot)
        if(UL.slot(II).USEG.present)
            if(UL.slot(II).USEG.Type==3 || UL.slot(II).USEG.Type==4)
                TargetState.K=UL.slot(II).USEG.CommissioningK;
                TargetState.Kend=UL.slot(II).USEG.CommissioningK;
                ins=ins+1;
                if(ins==1)
                    Destination=UL.slot(II).USEG.f.Set_K_struct(UL.slot(II).USEG,[TargetState.K,TargetState.Kend],Harmonic,UL.Basic.Reference_lambda_u);
                else
                    Destination(ins)=UL.slot(II).USEG.f.Set_K_struct(UL.slot(II).USEG,[TargetState.K,TargetState.Kend],Harmonic,UL.Basic.Reference_lambda_u);
                end
            end
        end
        if(UL.slot(II).PHAS.present)
            TargetStatePhas.Gap=UL.slot(II).PHAS.GapOut;
            NewDestPhas=UL.slot(II).PHAS.f.Set_State_Struct(UL.slot(II).PHAS,TargetStatePhas);
            insPhas=insPhas+1;
            if(insPhas==1)
                DestinationPhas(1)=NewDestPhas;
            else
                DestinationPhas(insPhas)=NewDestPhas;
            end
        end
    end
    
end
UL.f.UndulatorLine_K_set(UL,Destination,0);
UL.f.PhaseShifterLine_Gap_set_RAW(UL,DestinationPhas);
end
                         

function LineReadout=ReadWholeUndulator(UL,Updatephase)
if(nargin<2)
    Updatephase=0;
end
for II=1:length(UL.slot)
        if(UL.slot(II).USEG.present)
            [K,Kend]=UL.slot(II).USEG.f.Get_K(UL.slot(II).USEG,[UL.Basic.Reference_lambda_u,UL.Basic.K_range(2)]);
            LineReadout(II).K=K;
            LineReadout(II).Kend=Kend;
            LineReadout(II).StateString=UL.slot(II).USEG.f.Get_State_String(UL.slot(II).USEG,[UL.Basic.Reference_lambda_u,UL.Basic.K_range(2)]);
        else
            LineReadout(II).K=NaN;
            LineReadout(II).Kend=NaN;
            LineReadout(II).StateString='N/A';
        end
        if(UL.slot(II).PHAS.present)
            phase=UL.slot(II).PHAS.f.Get_Phase(UL.slot(II).PHAS);
            LineReadout(II).Phase=phase;
            LineReadout(II).PhaseDes=phase;
        else
            LineReadout(II).Phase=NaN;
            LineReadout(II).PhaseDes=NaN;
        end
        if(UL.slot(II).BEND.present)
            delay=UL.slot(II).BEND.f.get_Delay(UL.slot(II).BEND,UL);
            LineReadout(II).Delay=delay;
        else
            LineReadout(II).Delay=NaN;
        end
        LineReadout(II).slot=II;
end
if(Updatephase)  
    PVList={}; CellList=[];
    for AA=1:UL.slotlength
       if(UL.slot(AA).PHAS.present)
           CellList(end+1)=UL.slot(AA).PHAS.Cell_Number;
           PVList{end+1}=UL.slot(AA).PHAS.pv.GapAct;
       end
    end
    switch(UL.name(1))
        case 'H'
            LINE='HXR';
        case 'S'
            LINE='SXR';
    end
    Gaps=lcaGetSmart(PVList);
    VALS=PSgap2Phaseshift(LINE,CellList,Gaps);
    ins=0;
    for AA=1:numel(LineReadout)
       if(UL.slot(AA).PHAS.present)
           if(isnan(LineReadout(AA).Phase))
               continue
           end
           ins=ins+1;
           LineReadout(AA).Phase= VALS(ins);
       end
    end
    
%     Phi=GetPhase(UL, LineReadout);
%     PhaseShifters=cell2mat(UL.DeviceMap(:,4)); PhaseShifters(isnan(PhaseShifters))=0;
%     for II=1:length(Phi)
%         if(isnan(Phi(II)))
%             continue
%         else
%             CellTo=II;
%             CellFrom=II-1;
%             Value=Phi(II);
%             if(any(UL.slotcell(logical(UL.UsegPresent)) == CellFrom))
%                 %ok
%             else
%                 while(~any(UL.slotcell(logical(UL.UsegPresent)) == CellFrom))
%                     CellFrom=CellFrom-1;
%                     if(CellFrom==0), continue, end;
%                 end
%             end
%             if(CellFrom==0), continue, end;
%             %[CellFrom:CellTo]
%             AREA=CellFrom:(CellTo-1);
%             [~,WS,WA]=intersect(UL.slotcell,AREA);
%             LRTemp=[LineReadout(WS).PhaseDes];
%             if(sum(~isnan(LRTemp))==0)
%                 %do nothing, maybe all undulators are out? Report PHI DES as phase and forget.
%             elseif(sum(~isnan(LRTemp))==1)
%                 %WS(~isnan(LRTemp))
%                 LineReadout(WS(~isnan(LRTemp))).Phase=Value;
%             else
%                 CumulativePhase=0;
%                 for HH=1:length(WS)
%                     if(~isnan(LRTemp(HH)))
%                         CumulativePhase=CumulativePhase+LRTemp(HH);
%                     end
%                 end
%                 PhaseDifference=md ( CumulativePhase );
%                 REST=Value-PhaseDifference;
%                 for HH=1:length(WS)
%                     if(~isnan(LRTemp(HH)))
%                         LineReadout(WS(HH)).Phase=LineReadout(WS(HH)).PhaseDes + REST/sum(~isnan(LRTemp));
%                     end
%                 end
%             end
%         end
%     end
end

end

function Restore_all_K_values(UL, LineReadout)
Harmonic=1; ins=0;
if(numel(UL.slot)==numel(LineReadout))
    for II=1:length(UL.slot)
        if(UL.slot(II).USEG.present)
            if(LineReadout(II).K>0)    
            ins=ins+1;    
            NewDest=UL.slot(II).USEG.f.Set_K_struct(UL.slot(II).USEG,[LineReadout(II).K,LineReadout(II).Kend],Harmonic,UL.Basic.Reference_lambda_u);    
            if(ins==1)
                Destination(1)=NewDest;
            else
                Destination(ins)=NewDest;
            end
            end
        end
    end
end
UL.f.UndulatorLine_K_set(UL,Destination);
 
end

function MoveInSegments_struct(UL, CellID)
    if(nargin<3)
        RAW=0;
    end
    ins=0;
    for II=1:length(CellID)
        if(CellID(II)<=UL.slotlength)
           if(UL.slot(CellID(II)).USEG.present)
               ins=ins+1;
               NewDest = UL.slot(CellID(II)).USEG.f.Move_In_struct(UL.slot(CellID(II)).USEG);
               if(II==1)
                   Destination(1)=NewDest;
               else
                   Destination(end+1)=NewDest;
               end
                   
           end
        end
    end
    if(~RAW)
        UndulatorLine_K_set(UL,Destination);
    else
        UndulatorLine_Status_set_RAW(UL,Destination);
    end
end

function MoveOutSegments_struct(UL, CellID, RAW)
    if(nargin<3)
        RAW=1;
    end
    ins=0; UseRawSettings=1;
    TargetState.Harmonic=1;TargetState.Gap='out';
    for II=1:length(CellID)
        if(CellID(II)<=UL.slotlength)
           if(UL.slot(CellID(II)).USEG.present)
               ins=ins+1;
               NewDest=UL.slot(CellID(II)).USEG.f.Set_State_struct(UL.slot(CellID(II)).USEG, TargetState,UL.Basic.Reference_lambda_u, UseRawSettings);
               if(II==1)
                   Destination(1)=NewDest;
               else
                   Destination(end+1)=NewDest;
               end
           end
        end
    end
    if(~RAW)
        UndulatorLine_Status_set(UL,Destination);
    else
        UndulatorLine_Status_set_RAW(UL,Destination);
    end
end

function MoveInSegments(UL, CellID)
    for II=1:length(CellID)
        if(CellID(II)<UL.slotlength)
           if(UL.slot(CellID(II)).USEG.present)
               UL.slot(CellID(II)).USEG.f.Move_In(UL.slot(CellID(II)).USEG);
           end
        end
    end
end

function MoveOutSegments(UL, CellID)
    for II=1:length(CellID)
        if(CellID(II)<UL.slotlength)
           if(UL.slot(CellID(II)).USEG.present)
               UL.slot(CellID(II)).USEG.f.Move_Out(UL.slot(CellID(II)).USEG);
           end
        end
    end
end

function Set_phase_shifters(UL)
    %addpath (genpath('/home/physics/nuhn/wrk/matlab'))
    switch(UL(1).name(1))
        case 'S'
            undulatorLine='SXR';
        case 'H'
            undulatorLine='HXR';
    end
    ins=0; DestinationCell=zeros(1,sum(UL(1).UsegPresent));
    for II=1:length(UL(1).UsegPresent)
       if UL(1).UsegPresent(II)
           ins=ins+1;
           DestinationCell(ins)=UL(1).slot(II).USEG.Cell_Number;
       end
    end
    PSfiles=UL.Zach;
    PSfiles.undulatorLine=undulatorLine;
    LineReadout=Read_all_K_values(UL);
    UndSet ( undulatorLine, UL.slot(LineReadout(1).slot).USEG.Cell_Number, [LineReadout(1).K;LineReadout(1).Kend], 'cont', 1, 1, 'PSfiles', PSfiles);
    %KtoKAct ( undulatorLine, DestinationCell(1) ,1);    
end

function [OUT,LIST]=AnyUndulatorMoving(UL)
    PV=cell(sum(UL.UsegPresent),1);
    MovingVal=NaN*ones(sum(UL.UsegPresent),1);
    ins=0;
    for II=1:UL.slotlength
        if(UL.slot(II).USEG.present)
            ins=ins+1;
            PV{ins}=UL.slot(II).USEG.pv.Moving;
            MovingVal(ins)=UL.slot(II).USEG.MovingVAL;
        end
    end
    MovingList=lcaGetSmart(PV);
    LIST=MovingList==MovingVal;
    OUT=any(LIST);
    LIST=UL.UsegPresent(LIST);
end

function LineReadout=Read_all_K_values(UL)

for II=1:length(UL.slot)
    if(UL.slot(II).USEG.present)
        [K,Kend]=UL.slot(II).USEG.f.Get_K(UL.slot(II).USEG,[UL.Basic.Reference_lambda_u,UL.Basic.K_range(2)]);
        LineReadout(II).K=K;
        LineReadout(II).Kend=Kend;
    else
        LineReadout(II).K=NaN;
        LineReadout(II).Kend=NaN;
    end
    if(UL.slot(II).PHAS.present)
        phase=UL.slot(II).PHAS.f.Get_Phase(UL.slot(II).PHAS);
        LineReadout(II).Phase=phase;
    else
        LineReadout(II).Phase=NaN;
    end
    LineReadout(II).slot=II;
end




end

function LineReadout=Read_all_K_values_alternate(UL)

for II=1:length(UL.slot)
    if(UL.slot(II).USEG.present)
        [K,Kend]=UL.slot(II).USEG.f.Get_K_alternate(UL.slot(II).USEG,[UL.Basic.Reference_lambda_u,UL.Basic.K_range(2)]);
        LineReadout(II).K=K;
        LineReadout(II).Kend=Kend;
    else
        LineReadout(II).K=NaN;
        LineReadout(II).Kend=NaN;
    end
    if(UL.slot(II).PHAS.present)
        phase=UL.slot(II).PHAS.f.Get_Phase(UL.slot(II).PHAS);
        LineReadout(II).Phase=phase;
    else
        LineReadout(II).Phase=NaN;
    end
    LineReadout(II).slot=II;
end
end

function UL=HXU_Init(static,DispMessages)
    if(nargin>1), if(DispMessages), disp('Loading HXU functions'); end, end
    fh=ULT_UndulatorLine_functions;
    fh_HXU=ULT_HXU_functions;
    fh_SXU=ULT_SXU_functions;
    fh_PHAS=ULT_PhaseShifterFunctions;
    fh_BEND=ULT_chicane_functions;
    UL.f=fh;
    UL.Basic.DiscouragedK=2;
    UL.Basic.TDUNDPV='DUMP:LTUH:970:PNEUMATIC';
    UL.Basic.TDUND_In=0;
    UL.Basic.Reference_lambda_u=26; %reference period for the entire undulator line
    UL.Basic.K_range=[0.6,2.63];
    UL.Basic.UseContTaper=1;
    UL.Basic.DisplayRedLine=1; % default for this undulator line
    UL.Basic.ListenToSoftPVs=0 ;% default for this undulator line
    UL.Basic.UseSpontaneousRadiation=1;% default for this undulator line
    UL.Basic.UseWakeFields=0;% default for this undulator line
    UL.Basic.AddGainTaper=1;% default for this undulator line
    UL.Basic.GainTaperParameters=[1,NaN,-20];% default for this undulator line
    UL.Basic.AddPostSatTaper=1;% default for this undulator line
    UL.Basic.PostSatTaperParameters=[10,NaN,-40];% default for this undulator line
    UL.Basic.FoldingLength=24;% default for this undulator line
    UL.Basic.PostSaturationTaperShape={'Linear','Quadratic'};% default for this undulator line
    UL.Basic.PostSaturationTaperShapeValue=2;% default for this undulator line
    UL.Basic.Wakefieldmodel={'Undercompression','Overcompression'};% default for this undulator line
    UL.Basic.WakefieldmodelValue=1; % default for this undulator line
    UL.Basic.EBeamEnergy=13.76; % Default Energy for this undulator line (it trys to read from the machine when the line is selected)
    UL.Basic.EBeamCurrent=3000; % Default Energy for this undulator line (it trys to read from the machine when the line is selected)
    UL.Basic.EBeamCharge=180;% Default Energy for this undulator line (it trys to read from the machine when the line is selected)
    UL.Basic.EBeamEnergyPV='REFS:DMPH:400:EDES'; % Energy PV for this undulator line
    UL.Basic.EBeamCurrentPV='SIOC:SYS0:ML00:AO188'; % Current PV for this undulator line
    UL.Basic.EBeamChargePV='SIOC:SYS0:ML00:AO104';% Charge PV for this undulator line
    UL.Basic.EnergyBPMsLTU={'BPMS:LTUH:250:X','BPMS:LTUH:450:X'};
    UL.Basic.LaunchFeedbackPV='FBCK:FB03:TR04:MODE';
    UL.Basic.LaunchFeedback_On=1;
    UL.Basic.bykikPV='IOC:BSY0:MP01:BYKIKCTL';
    UL.Basic.bykik_On=0;
    UL.Basic.LaunchFeedback_X_PV='FBCK:FB03:TR04:S1DES';
    UL.Basic.LaunchFeedback_Y_PV='FBCK:FB03:TR04:S2DES';
    UL.Basic.LaunchFeedback_XANG_PV='FBCK:FB03:TR04:S3DES';
    UL.Basic.LaunchFeedback_YANG_PV='FBCK:FB03:TR04:S4DES';
    UL.Basic.BBA_Lem_ModePV={'SIOC:SYS0:ML01:AO141','SIOC:SYS0:ML01:AO405'};
    UL.Basic.BBA_Lem_Mode_On=[1,1];
    UL.Basic.RedLinePVs={};
    for IND=301:321
        UL.Basic.RedLinePVs{end+1}=strcat('SIOC:SYS0:ML04:AO',num2str(IND));
    end
    UL.Basic.f_Red_Line=@Red_Line; % Function that calculates the "Red line" for standard taper.
    UL.name='Hard X-ray Undulator Line';
    
    if(nargin>1), if(DispMessages), disp('Checking if some devices are not online'); end, end
    AreBendsReallyWorking={};
    for STD=1:length(static.bendList_e)
       AreBendsReallyWorking{end+1}=[static.bendList_e{STD},':BACT']; 
    end
    
    %Remove non-present devices:
    GAPACT=lcaGetSmart(strcat(static.phasList_e,':GapAct'));
    KACT=lcaGetSmart(strcat(static.undList_e,':KAct'));
    BACT=lcaGetSmart(AreBendsReallyWorking);
    
    if(nargin>1), if(DispMessages), disp('EXCLUDING SEGMENTS: '); disp(static.undList(isnan(KACT))); end, end
    
    static.undList(isnan(KACT))=[];
    static.undList_e(isnan(KACT))=[];
    static.zUnd(isnan(KACT))=[];
    static.lUnd(isnan(KACT))=[];
    
    if(nargin>1), if(DispMessages), disp('EXCLUDING PHASE SHIFTERS: '); disp(static.phasList(isnan(GAPACT))); end, end
    
    static.phasList(isnan(GAPACT))=[];
    static.phasList_e(isnan(GAPACT))=[];
    static.zPhas(isnan(GAPACT))=[];
    static.lPhas(isnan(GAPACT))=[];
    
    if(nargin>1), if(DispMessages), disp('EXCLUDING CHICANES: '); disp(static.bendList(isnan(BACT))); end, end
    
    static.bendList(isnan(BACT))=[];
    static.bendList_e(isnan(BACT))=[];
    static.zBend(isnan(BACT))=[];
    static.lBend(isnan(BACT))=[];
    
    
    UndCellNumber=[]; BPMCellNumber=[];  PHASCellNumber=[]; BENDlistNumber=[];
    for II=1:numel(static.undList)
        if(~isempty(static.undList{II}))
            UndCellNumber(end+1)=str2double(static.undList{II}((end-1):end));
        end
    end
    for II=1:numel(static.bpmList)
        if(~isempty(static.bpmList{II}))
            BPMCellNumber(end+1)=str2double(static.bpmList{II}((end-1):end));
        end
    end
    for II=1:numel(static.phasList)
        if(~isempty(static.phasList{II}))
            PHASCellNumber(end+1)=str2double(static.phasList{II}((end-1):end));
        end
    end
    for II=1:numel(static.bendList_e)
        if(~isempty(static.bendList_e{II}))
            Colons=strfind(static.bendList_e{II},':');
            BENDlistNumber(end+1)=str2double(static.bendList_e{II}(Colons(end)+(1:2)));
        end
    end
    %BENDlistNumber=unique(BENDlistNumber);
    
    if(nargin>1), if(DispMessages), disp('Setting Actual order to Cell order translation: '); end, end
   
    CN=min(UndCellNumber):1:max(UndCellNumber);
    UL.slotlength=length(CN);  
    for s=1:length(CN)
        if(s==1)
            UL.slot(s).Chamber.z_ini = static.zUnd(s) - static.lUnd(s)/2;
        else
            UL.slot(s).Chamber.z_ini = UL.slot(s-1).Chamber.z_end ;
        end
        if(s<length(CN)) %note that this is going to break if you have two chicanes in a row.
            if(any(UndCellNumber)==(CN(s)+1)) %the one after is an undulator, can use as end of cell
               CellID=find(UndCellNumber==(CN(s)+1),1,'first');
               UL.slot(s).Chamber.z_end = static.zUnd(CellID+1) - static.lUnd(CellID+1)/2;
            else % the one after isn't an undulator try ending cell at next BPM, if it doesn't work at end of undulator magnetic length
               if(any(BPMCellNumber==CN(s)))
                  CellID=find(BPMCellNumber==CN(s),1,'first'); 
                  UL.slot(s).Chamber.z_end = static.zBPM(CellID);
               else
                  CellID=find(UndCellNumber==(CN(s)),1,'first');
                  UL.slot(s).Chamber.z_end = UL.slot(s).Chamber.z_ini+static.lUnd(CellID)/2;
               end
            end
        else % this is the last one. Close the cell at end of undulator segment.
            CellID=find(UndCellNumber==(CN(s)),1,'first');
            UL.slot(s).Chamber.z_end=UL.slot(s).Chamber.z_ini + static.lUnd(CellID)/2;
        end
    UL.slot(s).Chamber.slot=s;
    UL.slot(s).Chamber.Cell_Number= CN(s);
    UL.slot(s).Chamber.x_rad = 2.5; % mm %adjust here for chicane part manually
    UL.slot(s).Chamber.y_rad = 10; % mm %adjust here for chicane part manually
    UL.slot(s).Chamber.material = 'Al'; % mm
    UL.slot(s).Chamber.wakefunction.time = linspace(0,1000,10001); %fs
    UL.slot(s).Chamber.wakefunction.longitudinal = 0*UL.slot(s).Chamber(1).wakefunction.time; %Find out units
    UL.slot(s).Chamber.wakefunction.transverse = 0*UL.slot(s).Chamber(1).wakefunction.time; %Find out units
    
    USEGID = find(UndCellNumber==CN(s));
    PHASID = find(PHASCellNumber==CN(s));
    BENDID = find(BENDlistNumber==CN(s));
    
    UL.slot(s).BEND.present=0; UL.DeviceMap{s,6}=false;
    
    if(~isempty(USEGID))     
        UL.UsegPresent(s,1)=1;
        UL.slot(s).USEG.present=1;
        UL.DeviceMap{s,1}=0;UL.DeviceMap{s,2}=0;UL.DeviceMap{s,3}=1;
        UL.slot(s).USEG.Cell_Number=UL.slot(s).Chamber.Cell_Number;
        UL.slot(s).USEG.Cell_String=num2str(UL.slot(s).Chamber.Cell_Number);
        UL.slot(s).USEG.PV=static.undList_e{USEGID};
        UL.slot(s).USEG.MADNAME=static.undList{USEGID};
        if(nargin>1), if(DispMessages), disp(['Undulator #',num2str(s),' ',UL.slot(s).USEG.PV,' in cell ',num2str(UL.slot(s).Chamber.Cell_Number)]); end, end
        UL.slot(s).USEG.Type=lcaGetSmart([UL.slot(s).USEG.PV,':TYPE']);
        UL.slot(s).USEG.Type=3;
        switch(UL.slot(s).USEG.Type)
            case 3 
                UL.slot(s).USEG.f=fh_HXU;
            case 4
                UL.slot(s).USEG.f=fh_SXU;
            otherwise
                UL.slot(s).USEG.f=fh_HXU;
        end
        CellID=find(UndCellNumber==(UL.slot(s).Chamber.Cell_Number),1,'first');
        UL.slot(s).USEG.z_ini=static.zUnd(CellID) - static.lUnd(CellID)/2;
        UL.slot(s).USEG.z_end=static.zUnd(CellID) + static.lUnd(CellID)/2;
        
        UL.slot(s).USEG=UL.slot(s).USEG.f.Useg_Init(UL.slot(s).USEG);
    else
        UL.UsegPresent(s,1)=0;
        UL.slot(s).USEG.present=0; UL.DeviceMap{s,1}=NaN;UL.DeviceMap{s,2}=NaN;UL.DeviceMap{s,3}=NaN;
    end
    if(~isempty(PHASID))
        UL.slot(s).PHAS.present=1; UL.DeviceMap{s,4}=1;
        UL.slot(s).PHAS.Cell_Number=UL.slot(s).Chamber.Cell_Number;
        UL.slot(s).PHAS.Cell_String=num2str(UL.slot(s).Chamber.Cell_Number);
        UL.slot(s).PHAS.PV=static.phasList_e{PHASID};
        UL.slot(s).PHAS.MADNAME=static.phasList{PHASID};
        if(nargin>1), if(DispMessages), disp(['Phase Shifter ',num2str(s),' ',UL.slot(s).PHAS.PV,' in cell ',num2str(UL.slot(s).Chamber.Cell_Number)]); end, end
        UL.slot(s).PHAS.Type=3; %Hard X-ray Init -> type = 3
        %CellID=find(UndCellNumber==(UL.slot(s).Chamber.Cell_Number),1,'first');
        UL.slot(s).PHAS.f=fh_PHAS;
        UL.slot(s).PHAS=fh_PHAS.Init_PHAS(UL.slot(s).PHAS);
    else
        UL.slot(s).PHAS.present=0; UL.DeviceMap{s,4}=NaN;
    end
    if(~isempty(BENDID))
        UL.slot(s).BEND.present=1; UL.DeviceMap{s,5}=1;
        UL.slot(s).BEND.Cell_Number=UL.slot(s).Chamber.Cell_Number;
        UL.slot(s).BEND.Cell_String=num2str(UL.slot(s).Chamber.Cell_Number);
        BendPV=static.bendList_e{BENDID(1)};
        Colons=strfind(BendPV,':');
        BendPV=BendPV(1:(Colons(end)+2));
        BtrimPV=regexprep(BendPV,'BEND','BTRM');
        if(nargin>1), if(DispMessages), disp(['Chicane  ',BendPV,' in cell ',num2str(UL.slot(s).Chamber.Cell_Number)]); end, end
        UL.slot(s).BEND.PV=BendPV;
        UL.slot(s).BEND.PVs={static.bendList_e{BENDID}};
        UL.slot(s).BEND.MorePV.MainBACT=strcat(UL.slot(s).BEND.PVs{1},':BACT');
        UL.slot(s).BEND.MorePV.AllMainBACT=strcat(UL.slot(s).BEND.PVs,':BACT');
        UL.slot(s).BEND.MorePV.MainDES=strcat(UL.slot(s).BEND.PVs{1},':BDES');
        UL.slot(s).BEND.MorePV.MainBCTRL=strcat(UL.slot(s).BEND.PVs{1},':BCTRL');
        UL.slot(s).BEND.MorePV.MainStat=strcat(UL.slot(s).BEND.PVs{1},':STAT');
        UL.slot(s).BEND.MorePV.MainStatMsg=strcat(UL.slot(s).BEND.PVs{1},':STATMSG');
        UL.slot(s).BEND.MADNAMES={static.bendList{BENDID}};
        UL.slot(s).BEND.TrimPV=BtrimPV;
        UL.slot(s).BEND.TrimPVs=regexprep({static.bendList_e{BENDID}},'BEND','BTRM');
        UL.slot(s).BEND.TRIMMADNAMES=strcat({static.bendList{BENDID}},'_TRIM');
        for OO=1:length(UL.slot(s).BEND.PVs)
           ID= find(strcmp(static.bendList_e,UL.slot(s).BEND.PVs{OO}));
           UL.slot(s).BEND.zval(OO)=static.zBend(ID);
           UL.slot(s).BEND.leffval(OO)=static.lBend(ID);
        end
        UL.slot(s).BEND.MorePV.TrimBACT=strcat(UL.slot(s).BEND.TrimPVs,':BACT');
        UL.slot(s).BEND.MorePV.TrimDES=strcat(UL.slot(s).BEND.TrimPVs,':BDES');
        UL.slot(s).BEND.MorePV.TrimBCTRL=strcat(UL.slot(s).BEND.TrimPVs,':BCTRL'); 
        UL.slot(s).BEND.Lm=UL.slot(s).BEND.leffval(1);
        UL.slot(s).BEND.dL=(UL.slot(s).BEND.zval(2) - UL.slot(s).BEND.zval(1))-UL.slot(s).BEND.leffval(1);
        UL.slot(s).BEND.z_ini=min(UL.slot(s).BEND.zval);
        UL.slot(s).BEND.z_end=max(UL.slot(s).BEND.zval);
        UL.slot(s).BEND.f=fh_BEND;
        UL.slot(s).BEND=UL.slot(s).BEND.f.init_Chicane(UL.slot(s).BEND);
    else
        UL.slot(s).BEND.present=0; UL.DeviceMap{s,5}=NaN;
    end
    end
    %Add Power Supplies information and BEND magnet information that is not
    %PV related.
    PSInserted=0;
    for II=length(UL.slot):-1:1
        if(UL.slot(II).BEND.present)
           PSInserted=PSInserted+1;
           if(PSInserted==1)
               UL.slot(II).BEND.PowerSupply.StateCommandPV='PSC:UNDH:MG01:STATE';
               UL.slot(II).BEND.PowerSupply.StatePV='PSC:UNDH:MG01:PSSTATE';
               UL.slot(II).BEND.MorePV.Delay='SIOC:SYS0:ML01:AO901';
               UL.slot(II).BEND.MorePV.R56='SIOC:SYS0:ML01:AO904';
               UL.slot(II).BEND.MorePV.X0='SIOC:SYS0:ML01:AO903';
               UL.slot(II).BEND.BCSS_AdjustString='HXRSS';
           end
        end
    end
    %Make Heinz-Dieter's spline structure for whole line.
    for II=1:length(UL.slot)
        if(UL.slot(II).USEG.present || UL.slot(II).PHAS.present)
            if(UL.slot(II).USEG.present)
                SplineData.USEG{UL.slot(II).USEG.Cell_Number}=UL.slot(II).USEG.splinedata;
                if(UL.slot(II).PHAS.present)
                    SplineData.PHAS{UL.slot(II).USEG.Cell_Number}=UL.slot(II).PHAS.splinedata;
                end
            else
                SplineData.PHAS{UL.slot(II).USEG.Cell_Number}=UL.slot(II).PHAS.splinedata;
            end
        end
    end
    SplineData.USEGentries=length(SplineData.USEG);
    SplineData.PHASentries=length(SplineData.PHAS);
    UL.SplineData=SplineData;
    %Make Zach data here using his functions
    UL.Zach.genpath{1}='/home/physics/nuhn/wrk/matlab';
    UL.Zach.genpath{2}='/home/physics/wolf';
    addpath ( genpath ( UL.Zach.genpath{1} ) );
    addpath ( genpath ( UL.Zach.genpath{2} ) );
    
    UL.Zach.param=cell_data_param();
    UL.Zach.line='H';
    UL.Zach.xray_line = 'HXR';
    UL.Zach.num_cell = UL.Zach.param.hxr_max_num_cell;
    UL.Zach.und_cell_num = UL.Zach.param.hxu_cell_num;
    UL.Zach.und_ser_num = hxr_ctrl_get_und_ser_num(UL.Zach.und_cell_num);
    UL.Zach.ps_cell_num = UL.Zach.param.hxps_cell_num;
    UL.Zach.ps_ser_num = hxr_ctrl_get_ps_ser_num(UL.Zach.ps_cell_num);
    UL.Zach.PSdata = cell_data_init(UL.Zach.param, UL.Zach.xray_line, UL.Zach.num_cell, UL.Zach.und_cell_num, UL.Zach.und_ser_num, UL.Zach.ps_cell_num, UL.Zach.ps_ser_num);
    UL.Zach.PSmanage = @ULT_hxr_ps_manage_update;
    UL.Zach.UndConsts = util_HXRUndulatorConstants;
    UL.Zach.PVbase = 'PHAS:UNDH:';
    UL.Zach.fmtDPHI = '95:DPHI';
    UL.Zach.currentSegmentList = UL.Zach.UndConsts.currentSegmentCells;
    UL.Zach.PIdata = getSplineData (UL.Zach.line, UL.Zach.currentSegmentList );
    
    for II=1:length(UL.slot)
        UL.slotcell(II)=UL.slot(II).Chamber.Cell_Number;
    end
end

function UL=SXU_Init(static,DispMessages)
    if(nargin>1), if(DispMessages), disp('Loading SXU functions'); end, end
    fh=ULT_UndulatorLine_functions;
    fh_HXU=ULT_HXU_functions;
    fh_SXU=ULT_SXU_functions;
    fh_PHAS=ULT_PhaseShifterFunctions;
    fh_BEND=ULT_chicane_functions;
    UL.f=fh;
    UL.Basic.DiscouragedK=2.5;
    UL.Basic.Reference_lambda_u=39; %reference period for the entire undulator line
    UL.Basic.K_range=[0.3,5.79];
    UL.Basic.UseContTaper=1;
    UL.Basic.DisplayRedLine=1; % default for this undulator line
    UL.Basic.ListenToSoftPVs=0 ;% default for this undulator line
    UL.Basic.UseSpontaneousRadiation=1;% default for this undulator line
    UL.Basic.UseWakeFields=0;% default for this undulator line
    UL.Basic.AddGainTaper=1;% default for this undulator line
    UL.Basic.GainTaperParameters=[1,NaN,-20];% default for this undulator line
    UL.Basic.AddPostSatTaper=1;% default for this undulator line
    UL.Basic.PostSatTaperParameters=[10,NaN,-40];% default for this undulator line
    UL.Basic.FoldingLength=24;% default for this undulator line
    UL.Basic.PostSaturationTaperShape={'Linear','Quadratic'};% default for this undulator line
    UL.Basic.PostSaturationTaperShapeValue=2;% default for this undulator line
    UL.Basic.Wakefieldmodel={'Undercompression','Overcompression'};% default for this undulator line
    UL.Basic.WakefieldmodelValue=1; % default for this undulator line
    UL.Basic.EBeamEnergy=8.000; % Default Energy for this undulator line (it trys to read from the machine when the line is selected)
    UL.Basic.EBeamCurrent=3000; % Default Energy for this undulator line (it trys to read from the machine when the line is selected)
    UL.Basic.EBeamCharge=180;% Default Energy for this undulator line (it trys to read from the machine when the line is selected)
    UL.Basic.EBeamEnergyPV='REFS:DMPS:400:EDES'; % Energy PV for this undulator line
    UL.Basic.EBeamCurrentPV='SIOC:SYS0:ML00:AO188'; % Current PV for this undulator line
    UL.Basic.EBeamChargePV='SIOC:SYS0:ML00:AO104';% Charge PV for this undulator line
    UL.Basic.LaunchFeedbackPV='FBCK:FB04:TR02:MODE';
    UL.Basic.LaunchFeedback_On=1;
    UL.Basic.TDUNDPV='DUMP:LTUS:972:PNEUMATIC';
    UL.Basic.TDUND_In=0;
    UL.Basic.BBA_Lem_ModePV={'SIOC:SYS0:ML01:AO141','SIOC:SYS0:ML01:AO406'};
    UL.Basic.EnergyBPMsLTU={'BPMS:LTUS:235:X','BPMS:LTUS:370:X'};
    UL.Basic.BBA_Lem_Mode_On=[1,1];
    UL.Basic.bykikPV='IOC:BSY0:MP01:BYKIKSCTL';
    UL.Basic.bykik_On=0;
    UL.Basic.LaunchFeedback_X_PV='FBCK:FB04:TR02:S1DES';
    UL.Basic.LaunchFeedback_Y_PV='FBCK:FB04:TR02:S2DES';
    UL.Basic.LaunchFeedback_XANG_PV='FBCK:FB04:TR02:S3DES';
    UL.Basic.LaunchFeedback_YANG_PV='FBCK:FB04:TR02:S4DES';
    UL.Basic.f_Red_Line=@Red_Line; % Function that calculates the "Red line" for standard taper.
    UL.Basic.RedLinePVs={};
    for IND=326:346
        UL.Basic.RedLinePVs{end+1}=strcat('SIOC:SYS0:ML04:AO',num2str(IND));
    end
    UL.name='Soft X-ray Undulator Line';
    
    if(nargin>1), if(DispMessages), disp('Checking if some devices are not online'); end, end
    
    AreBendsReallyWorking={};
    for STD=1:length(static.bendList_e)
       AreBendsReallyWorking{end+1}=[static.bendList_e{STD},':BACT']; 
    end
    
    %Remove non-present devices:
    GAPACT=lcaGetSmart(strcat(static.phasList_e,':GapAct'));
    KACT=lcaGetSmart(strcat(static.undList_e,':KAct'));
    BACT=lcaGetSmart(AreBendsReallyWorking);
    
    if(nargin>1), if(DispMessages), disp('EXCLUDING SEGMENTS: '); disp(static.undList(isnan(KACT))); end, end
    
    static.undList(isnan(KACT))=[];
    static.undList_e(isnan(KACT))=[];
    static.zUnd(isnan(KACT))=[];
    static.lUnd(isnan(KACT))=[];
    
    if(nargin>1), if(DispMessages), disp('EXCLUDING PHASE SHIFTERS: '); disp(static.phasList(isnan(GAPACT))); end, end
    
    static.phasList(isnan(GAPACT))=[];
    static.phasList_e(isnan(GAPACT))=[];
    static.zPhas(isnan(GAPACT))=[];
    static.lPhas(isnan(GAPACT))=[];
    
    if(nargin>1), if(DispMessages), disp('EXCLUDING CHICANES: '); disp(static.bendList(isnan(BACT))); end, end
    
    static.bendList(isnan(BACT))=[];
    static.bendList_e(isnan(BACT))=[];
    static.zBend(isnan(BACT))=[];
    static.lBend(isnan(BACT))=[];
    
%     GAPACT=lcaGetSmart(strcat(static.phasList_e,':GapAct'));
%     KACT=lcaGetSmart(strcat(static.undList_e,':KAct'));
%     static.undList(isnan(KACT))=[];
%     static.undList_e(isnan(KACT))=[];
%     static.zUnd(isnan(KACT))=[];
%     static.lUnd(isnan(KACT))=[];
%     
%     static.phasList(isnan(GAPACT))=[];
%     static.phasList_e(isnan(GAPACT))=[];
%     static.zPhas(isnan(GAPACT))=[];
%     static.lPhas(isnan(GAPACT))=[];
%     
    UndCellNumber=[]; BPMCellNumber=[];  PHASCellNumber=[]; BENDlistNumber=[];
    for II=1:numel(static.undList)
        if(~isempty(static.undList{II}))
            UndCellNumber(end+1)=str2double(static.undList{II}((end-1):end));
        end
    end
    for II=1:numel(static.bpmList)
        if(~isempty(static.bpmList{II}))
            BPMCellNumber(end+1)=str2double(static.bpmList{II}((end-1):end));
        end
    end
    for II=1:numel(static.phasList)
        if(~isempty(static.phasList{II}))
            PHASCellNumber(end+1)=str2double(static.phasList{II}((end-1):end));
        end
    end
    for II=1:numel(static.bendList_e)
        if(~isempty(static.bendList_e{II}))
            Colons=strfind(static.bendList_e{II},':');
            BENDlistNumber(end+1)=str2double(static.bendList_e{II}(Colons(end)+(1:2)));
        end
    end
    %BENDlistNumber=unique(BENDlistNumber);
    
    if(nargin>1), if(DispMessages), disp('Setting Actual order to Cell order translation: '); end, end
   
    CN=min(UndCellNumber):1:max(UndCellNumber);
    UL.slotlength=length(CN);  
    for s=1:length(CN)
        if(s==1)
            UL.slot(s).Chamber.z_ini = static.zUnd(s) - static.lUnd(s)/2;
        else
            UL.slot(s).Chamber.z_ini = UL.slot(s-1).Chamber.z_end ;
        end
        if(s<length(CN)) %note that this is going to break if you have two chicanes in a row.
            if(any(UndCellNumber)==(CN(s)+1)) %the one after is an undulator, can use as end of cell
               CellID=find(UndCellNumber==(CN(s)+1),1,'first');
               UL.slot(s).Chamber.z_end = static.zUnd(CellID+1) - static.lUnd(CellID+1)/2;
            else % the one after isn't an undulator try ending cell at next BPM, if it doesn't work at end of undulator magnetic length
               if(any(BPMCellNumber==CN(s)))
                  CellID=find(BPMCellNumber==CN(s),1,'first'); 
                  UL.slot(s).Chamber.z_end = static.zBPM(CellID);
               else
                  CellID=find(UndCellNumber==(CN(s)),1,'first');
                  UL.slot(s).Chamber.z_end = UL.slot(s).Chamber.z_ini+static.lUnd(CellID)/2;
               end
            end
        else % this is the last one. Close the cell at end of undulator segment.
            CellID=find(UndCellNumber==(CN(s)),1,'first');
            UL.slot(s).Chamber.z_end=UL.slot(s).Chamber.z_ini + static.lUnd(CellID)/2;
        end
    UL.slot(s).Chamber.slot=s;
    UL.slot(s).Chamber.Cell_Number= CN(s);
    UL.slot(s).Chamber.x_rad = 10; % mm %adjust here for chicane part manually
    UL.slot(s).Chamber.y_rad = 2.5; % mm %adjust here for chicane part manually
    UL.slot(s).Chamber.material = 'Al'; % mm
    UL.slot(s).Chamber.wakefunction.time = linspace(0,1000,10001); %fs
    UL.slot(s).Chamber.wakefunction.longitudinal = 0*UL.slot(s).Chamber(1).wakefunction.time; %Find out units
    UL.slot(s).Chamber.wakefunction.transverse = 0*UL.slot(s).Chamber(1).wakefunction.time; %Find out units
    
    USEGID = find(UndCellNumber==CN(s));
    PHASID = find(PHASCellNumber==CN(s));
    BENDID = find(BENDlistNumber==CN(s));
    
    UL.slot(s).BEND.present=0; UL.DeviceMap{s,6}=false;
    
    if(~isempty(USEGID))
        UL.UsegPresent(s,1)=1;
        UL.slot(s).USEG.present=1;
        UL.DeviceMap{s,1}=0;UL.DeviceMap{s,2}=0;UL.DeviceMap{s,3}=1;
        UL.slot(s).USEG.Cell_Number=UL.slot(s).Chamber.Cell_Number;
        UL.slot(s).USEG.Cell_String=num2str(UL.slot(s).Chamber.Cell_Number);
        UL.slot(s).USEG.PV=static.undList_e{USEGID};
        if(nargin>1), if(DispMessages), disp(['Undulator #',num2str(s),' ',UL.slot(s).USEG.PV,' in cell ',num2str(UL.slot(s).Chamber.Cell_Number)]); end, end
        UL.slot(s).USEG.Type=lcaGetSmart([UL.slot(s).USEG.PV,':TYPE']);
        UL.slot(s).USEG.Type=4;
        switch(UL.slot(s).USEG.Type)
            case 3 
                UL.slot(s).USEG.f=fh_HXU;
            case 4
                UL.slot(s).USEG.f=fh_SXU;
            otherwise
                UL.slot(s).USEG.f=fh_HXU;
        end
        CellID=find(UndCellNumber==(UL.slot(s).Chamber.Cell_Number),1,'first');
        UL.slot(s).USEG.z_ini=static.zUnd(CellID) - static.lUnd(CellID)/2;
        UL.slot(s).USEG.z_end=static.zUnd(CellID) + static.lUnd(CellID)/2;
        
        UL.slot(s).USEG=UL.slot(s).USEG.f.Useg_Init(UL.slot(s).USEG);
    else
        UL.UsegPresent(s,1)=0;
        UL.slot(s).USEG.present=0; UL.DeviceMap{s,1}=NaN;UL.DeviceMap{s,2}=NaN;UL.DeviceMap{s,3}=NaN;
    end
    if(~isempty(PHASID))
        UL.slot(s).PHAS.present=1; UL.DeviceMap{s,4}=1;
        UL.slot(s).PHAS.Cell_Number=UL.slot(s).Chamber.Cell_Number;
        UL.slot(s).PHAS.Cell_String=num2str(UL.slot(s).Chamber.Cell_Number);
        UL.slot(s).PHAS.PV=static.phasList_e{PHASID};
        if(nargin>1), if(DispMessages), disp(['Phase Shifter ',num2str(s),' ',UL.slot(s).PHAS.PV,' in cell ',num2str(UL.slot(s).Chamber.Cell_Number)]); end, end
        UL.slot(s).PHAS.Type=4; %SXR Undulator line phase shifter type = 4
        %CellID=find(UndCellNumber==(UL.slot(s).Chamber.Cell_Number),1,'first');
        UL.slot(s).PHAS.f=fh_PHAS;
        UL.slot(s).PHAS=fh_PHAS.Init_PHAS(UL.slot(s).PHAS);
    else
        UL.slot(s).PHAS.present=0; UL.DeviceMap{s,4}=NaN;
    end
    if(~isempty(BENDID))
        UL.slot(s).BEND.present=1; UL.DeviceMap{s,5}=1;
        UL.slot(s).BEND.Cell_Number=UL.slot(s).Chamber.Cell_Number;
        UL.slot(s).BEND.Cell_String=num2str(UL.slot(s).Chamber.Cell_Number);
        BendPV=static.bendList_e{BENDID(1)};
        Colons=strfind(BendPV,':');
        BendPV=BendPV(1:(Colons(end)+2));
        BtrimPV=regexprep(BendPV,'BEND','BTRM');
        if(nargin>1), if(DispMessages), disp(['Chicane  ',BendPV,' in cell ',num2str(UL.slot(s).Chamber.Cell_Number)]); end, end
        UL.slot(s).BEND.PV=BendPV;
        UL.slot(s).BEND.PVs={static.bendList_e{BENDID}};
        UL.slot(s).BEND.MADNAMES={static.bendList{BENDID}};
        UL.slot(s).BEND.TrimPV=BtrimPV;
        UL.slot(s).BEND.TrimPVs=regexprep({static.bendList_e{BENDID}},'BEND','BTRM');
        UL.slot(s).BEND.TRIMMADNAMES=strcat({static.bendList{BENDID}},'_TRIM');
        for OO=1:length(UL.slot(s).BEND.PVs)
           ID= find(strcmp(static.bendList_e,UL.slot(s).BEND.PVs{OO}));
           UL.slot(s).BEND.zval(OO)=static.zBend(ID);
           UL.slot(s).BEND.leffval(OO)=static.lBend(ID);
        end
        UL.slot(s).BEND.MorePV.MainBACT=strcat(UL.slot(s).BEND.PVs{1},':BACT');
        UL.slot(s).BEND.MorePV.AllMainBACT=strcat(UL.slot(s).BEND.PVs,':BACT');
        UL.slot(s).BEND.MorePV.MainDES=strcat(UL.slot(s).BEND.PVs{1},':BDES');
        UL.slot(s).BEND.MorePV.MainBCTRL=strcat(UL.slot(s).BEND.PVs{1},':BCTRL');
        UL.slot(s).BEND.MorePV.MainStat=strcat(UL.slot(s).BEND.PVs{1},':STAT');
        UL.slot(s).BEND.MorePV.MainStatMsg=strcat(UL.slot(s).BEND.PVs{1},':STATMSG');
        UL.slot(s).BEND.MorePV.TrimBACT=strcat(UL.slot(s).BEND.TrimPVs,':BACT');
        UL.slot(s).BEND.MorePV.TrimDES=strcat(UL.slot(s).BEND.TrimPVs,':BDES');
        UL.slot(s).BEND.MorePV.TrimBCTRL=strcat(UL.slot(s).BEND.TrimPVs,':BCTRL'); 
        UL.slot(s).BEND.Lm=UL.slot(s).BEND.leffval(1);
        UL.slot(s).BEND.dL=(UL.slot(s).BEND.zval(2) - UL.slot(s).BEND.zval(1))-UL.slot(s).BEND.leffval(1);
        UL.slot(s).BEND.z_ini=min(UL.slot(s).BEND.zval);
        UL.slot(s).BEND.z_end=max(UL.slot(s).BEND.zval);
        UL.slot(s).BEND.f=fh_BEND;
        UL.slot(s).BEND=UL.slot(s).BEND.f.init_Chicane(UL.slot(s).BEND);
    else
        UL.slot(s).BEND.present=0; UL.DeviceMap{s,5}=NaN;
    end
    end
    %Add Power Supplies information and BEND magnet information that is not
    %PV related.
    PSInserted=0;
    for II=length(UL.slot):-1:1
        if(UL.slot(II).BEND.present)
           PSInserted=PSInserted+1;
           if(PSInserted==1)
               UL.slot(II).BEND.PowerSupply.StateCommandPV='PSC:UNDS:MG01:STATE';
               UL.slot(II).BEND.PowerSupply.StatePV='PSC:UNDS:MG01:PSSTATE';
               UL.slot(II).BEND.MorePV.Delay='SIOC:SYS0:ML01:AO809';
               UL.slot(II).BEND.MorePV.R56='SIOC:SYS0:ML01:AO813';
               UL.slot(II).BEND.MorePV.X0='SIOC:SYS0:ML01:AO812';
               UL.slot(II).BEND.BCSS_AdjustString='SXRSS';
           end
        end
    end
    %Make Heinz-Dieter's spline structure for whole line.
    for II=1:length(UL.slot)
        if(UL.slot(II).USEG.present || UL.slot(II).PHAS.present)
            if(UL.slot(II).USEG.present)
                SplineData.USEG{UL.slot(II).USEG.Cell_Number}=UL.slot(II).USEG.splinedata;
                if(UL.slot(II).PHAS.present)
                    SplineData.PHAS{UL.slot(II).USEG.Cell_Number}=UL.slot(II).PHAS.splinedata;
                end
            else
                SplineData.PHAS{UL.slot(II).PHAS.Cell_Number}=UL.slot(II).PHAS.splinedata;
            end
        end
    end
    SplineData.USEGentries=length(SplineData.USEG);
    SplineData.PHASentries=length(SplineData.PHAS);
    UL.SplineData=SplineData;
    %Make Zach data here using his functions
    UL.Zach.genpath{1}='/home/physics/nuhn/wrk/matlab';
    UL.Zach.genpath{2}='/home/physics/wolf';
    addpath ( genpath ( UL.Zach.genpath{1} ) );
    addpath ( genpath ( UL.Zach.genpath{2} ) );
    
    UL.Zach.param=cell_data_param();
    UL.Zach.line='S';
    UL.Zach.xray_line = 'SXR';
    UL.Zach.num_cell = UL.Zach.param.sxr_max_num_cell;
    UL.Zach.und_cell_num = UL.Zach.param.sxu_cell_num;
    UL.Zach.und_ser_num = sxr_ctrl_get_und_ser_num(UL.Zach.und_cell_num);
    UL.Zach.ps_cell_num = UL.Zach.param.sxps_cell_num;
    UL.Zach.ps_ser_num = sxr_ctrl_get_ps_ser_num(UL.Zach.ps_cell_num);
    UL.Zach.PSdata = cell_data_init(UL.Zach.param, UL.Zach.xray_line, UL.Zach.num_cell, UL.Zach.und_cell_num, UL.Zach.und_ser_num, UL.Zach.ps_cell_num, UL.Zach.ps_ser_num);
    UL.Zach.PSmanage = @ULT_sxr_ps_manage_update;
    UL.Zach.UndConsts = util_SXRUndulatorConstants;
    UL.Zach.PVbase = 'PHAS:UNDS:';
    UL.Zach.fmtDPHI = '70:DPHI';
    UL.Zach.currentSegmentList = UL.Zach.UndConsts.currentSegmentCells;
    UL.Zach.PIdata = getSplineData (UL.Zach.line, UL.Zach.currentSegmentList );
    
    for II=1:length(UL.slot)
        UL.slotcell(II)=UL.slot(II).Chamber.Cell_Number;
    end
    
end

function UL=UUT_UnknownBeamLine_Init(UL)
    UL=UUT_HXU_Init(UL); % se una linea e' sconosciuta viene trattata come la linea di LCLS-I.
end

function RedLineOutput=Red_Line(UL,Input,PhyConsts)

SpontRamp = PhyConsts.c^3 * PhyConsts.Z_0 * PhyConsts.echarge / ( 12 * pi * PhyConsts.mc2_e^4 );  % 1/(T^2 Vm)
% ku                 = 2 * pi / UL.Reference_lambda_u;
% Bact               = ( PhyConsts.mc2_e * ku ) * Kact / PhyConsts.c;

cur_Spont_dE       = 0;
cur_Wake_dE        = 0;

try
    avgCore_WakeRate   = util_UndulatorWakeAmplitude ( Input.MODEL_PEAK_CURRENT / 1000, Input.MODEL_BUNCH_CHARGE, Input.WakefieldModel ) * 1000;
catch
    avgCore_WakeRate   = 1;
end

if(Input.USE_ALL_SEGMENTS)
    No_segments=0;
    Input.FirstUndulatorInfo.FirstUndulatorIn(1)=1;
    Kini=Input.First_K(1);
    for LL=1:length(Input.ULReadOut)
        if(~isnan(Input.ULReadOut(LL).K(1)))
            Input.ULReadOut(LL).K=5; %it's only a large enough K to be in, without rewriting it in a smarter way.
            Input.ULReadOut(LL).Kend=5;
        end
               
    end
else
    if(isnan(Input.FirstUndulatorInfo.FirstUndulatorIn(1))) %no undulator in has been found, no redline should be displayed.
        No_segments=1;
        Kini=0;
    else
        No_segments=0;
        Kini=Input.First_K(1);
    end
end

GainTaperSlots=[]; QuadraticTaperSlots=[];
SegmentTaperLengthGain=[];SegmentTaperLengthQuadratic=[];

for s=1:UL.slotlength
    
    OUT.EnergyLoss(s).Spont_dE_ini=cur_Spont_dE;
    OUT.EnergyLoss(s).Wake_dE_ini=cur_Wake_dE;
   
    if (Input.USE_WAKEFIELDS_BOX) 
        DE_wake_dz = avgCore_WakeRate;                                                 % V/m        
        cur_Wake_dE = cur_Wake_dE + DE_wake_dz * (UL.slot(s).Chamber.z_end-UL.slot(s).Chamber.z_ini);%UL.slot(s).Chamber.WakeSegmentLength;
    end
    
    if(UL.slot(s).USEG.present) % if there is an undulator in slot compute radiation losses.
        
        if((s>=Input.GAIN_TAPER_START_SEGMENT) && (s<=Input.GAIN_TAPER_END_SEGMENT))
            GainTaperSlots(end+1)=s;
            SegmentTaperLengthGain(end+1)=UL.slot(s).USEG.SegmentLength; 
        else
            GainTaperSlots(end+1)=s;
            SegmentTaperLengthGain(end+1)=0;
        end
        if((s>=Input.POST_TAPER_START_SEGMENT) && (s<=Input.POST_TAPER_END_SEGMENT))
            QuadraticTaperSlots(end+1)=s;
            SegmentTaperLengthQuadratic(end+1)=UL.slot(s).USEG.SegmentLength;
        else
            QuadraticTaperSlots(end+1)=s;
            SegmentTaperLengthQuadratic(end+1)=0;
        end
        
        Keff=[Input.ULReadOut(s).K(1),Input.ULReadOut(s).Kend(1)];
        K=UL.slot(s).USEG.f.keff_and_harm_to_k(UL.slot(s).USEG,Keff,1,UL.Basic.Reference_lambda_u);  %USEG,Keff,Harmonic,Ref_period
        if(any(isnan(K))), K=[0,0]; end
        Kact=Input.First_K(1);
        Kold=mean(K);
        ku=2*pi/(UL.slot(s).USEG.Period/1000); %/1000 because USEG.Period is in mm.
        Bact=(PhyConsts.mc2_e*ku)*Kact/PhyConsts.c; 
        if (Input.USE_SPONT_RAD_BOX)
            DE_spont_dz=-SpontRamp*(Input.MODEL_BEAM_ENERGY * 10^9)^2*Bact^2;
            cur_Spont_dE   = cur_Spont_dE + DE_spont_dz * UL.slot(s).USEG.SegmentLength;
        end
        % UNCOMMENT THIS AT SOME POINT. IT HAS BEEN COMMENTED FOR TESTS
        if(Kold>UL.slot(s).USEG.Kout)
           UndulatorSlotIN(s)=1;
        else
           UndulatorSlotIN(s)=0;
        end
        UndulatorSlotIN(s)=1;
    else
        UndulatorSlotIN(s)=0;
        QuadraticTaperSlots(end+1)=s;
        SegmentTaperLengthQuadratic(end+1)=0;
        GainTaperSlots(end+1)=s;
        SegmentTaperLengthGain(end+1)=0;
    end

    OUT.EnergyLoss(s).Spont_dE_end = cur_Spont_dE;
    OUT.EnergyLoss(s).Wake_dE_end  = cur_Wake_dE;
end

ToalLengthAdditionalLinear=sum(SegmentTaperLengthGain);
ToalLengthQuadratic=sum(SegmentTaperLengthQuadratic);

TapAmp= Input.GAIN_TAPER_AMPLITUDE * 1e6; % Sara' 1 MeV?
TapAmpPost= Input.POST_TAPER_AMPLITUDE * 1e6; %Sara' magari 20 MeV?

EnergyLoss.Additional_dE_end=cumsum(SegmentTaperLengthGain)/ToalLengthAdditionalLinear*TapAmp;
EnergyLoss.Additional_dE_ini=[0,EnergyLoss.Additional_dE_end(1:(end-1))];

switch(Input.POST_TAPER_MENU_VALUE)
    case 1
        EnergyLoss.PostSat_dE_end = cumsum(SegmentTaperLengthQuadratic)/ToalLengthQuadratic*TapAmpPost; %Linear Losses
    case 2
        EnergyLoss.PostSat_dE_end = (cumsum(SegmentTaperLengthQuadratic)/ToalLengthQuadratic).^2*TapAmpPost;% 2 * TapAmp * zposition / sectionLength^2;
    otherwise
        EnergyLoss.PostSat_dE_end = (cumsum(SegmentTaperLengthQuadratic)/ToalLengthQuadratic).^2*TapAmpPost;% 2 * TapAmp * zposition / sectionLength^2;
        disp('unexpected line of code reached. Shape of redline post saturation taper.')
end
EnergyLoss.PostSat_dE_ini = [0,EnergyLoss.PostSat_dE_end(1:(end-1))];

ExpectedEnergy_ini=zeros(size(EnergyLoss.Additional_dE_end));
ExpectedEnergy_end=zeros(size(EnergyLoss.Additional_dE_end));

if(Input.USE_WAKEFIELDS_BOX)
    ExpectedEnergy_ini=ExpectedEnergy_ini+[OUT.EnergyLoss(:).Wake_dE_ini];
    ExpectedEnergy_end=ExpectedEnergy_end+[OUT.EnergyLoss(:).Wake_dE_end];
end
if(Input.USE_SPONT_RAD_BOX)
    ExpectedEnergy_ini=ExpectedEnergy_ini+[OUT.EnergyLoss(:).Spont_dE_ini];
    ExpectedEnergy_end=ExpectedEnergy_end+[OUT.EnergyLoss(:).Spont_dE_end];
end
if(Input.ADD_POST_TAPER_BOX)
    ExpectedEnergy_ini=ExpectedEnergy_ini+EnergyLoss.PostSat_dE_ini;
    ExpectedEnergy_end=ExpectedEnergy_end+EnergyLoss.PostSat_dE_end;
end
if(Input.ADD_GAIN_TAPER_BOX)
    ExpectedEnergy_ini=ExpectedEnergy_ini+EnergyLoss.Additional_dE_ini;
    ExpectedEnergy_end=ExpectedEnergy_end+EnergyLoss.Additional_dE_end;
end

if(~No_segments) % there are segments, do some red-line
    RedLineOutput.Failed=0;
    EnergyOffset=ExpectedEnergy_ini(Input.FirstUndulatorInfo.FirstUndulatorIn(1));
    ExpectedEnergy_ini=Input.MODEL_BEAM_ENERGY*10^9 -EnergyOffset + ExpectedEnergy_ini;
    ExpectedEnergy_end=Input.MODEL_BEAM_ENERGY*10^9 -EnergyOffset + ExpectedEnergy_end;
    CONSTANT=(1+Kini^2/2)/2/((ExpectedEnergy_ini(Input.FirstUndulatorInfo.FirstUndulatorIn(1))/PhyConsts.mc2_e)^2);
    RedLineOutput.K= sqrt(4*CONSTANT*(ExpectedEnergy_ini/PhyConsts.mc2_e).^2 -2);
    RedLineOutput.Kend= sqrt(4*CONSTANT*(ExpectedEnergy_end/PhyConsts.mc2_e).^2 -2);
    RedLineOutput.K(1:(Input.FirstUndulatorInfo.FirstUndulatorIn(1)-1))=NaN;
    RedLineOutput.Kend(1:(Input.FirstUndulatorInfo.FirstUndulatorIn(1)-1))=NaN;
    RedLineOutput.K(~UndulatorSlotIN)=NaN;
    RedLineOutput.Kend(~UndulatorSlotIN)=NaN;
    RedLineOutput.ExpectedEnergy_ini=ExpectedEnergy_ini;
    RedLineOutput.ExpectedEnergy_end=ExpectedEnergy_end;
    if(~Input.USE_CONT_TAPER)
        RedLineOutput.Kend=RedLineOutput.K;
    end
    RedLineOutput.Ktable=[RedLineOutput.K;RedLineOutput.Kend].';
else
    RedLineOutput.Failed=1;
end

end

function UndulatorLine_K_set(UL,Destination,nowait)
    %This function is used to set K in many undulator at once, change phase
    %shifters and correctors. It call Heinz-Dieter's function UndSet with
    %proper parameters.
    %addpath (genpath('/home/physics/nuhn/wrk/matlab'))
    
    if(nargin<3)
        nowait=1;
    end
    
    PSfiles=UL.Zach;
    
    switch(UL(1).name(1))
        case 'S'
            undulatorLine='SXR';
        case 'H'
            undulatorLine='HXR';
    end
    PSfiles.undulatorLine=undulatorLine;
    desCellList=[Destination.Cell];
    desKvalues(1,:)=[Destination.K];
    desKvalues(2,:)=[Destination.Kend];
    if(isfield(Destination,'Gap'))
        desGapvalues(1,:)=[Destination.Gap];
        desGapvalues(2,:)=[Destination.Taper];
        desGapvalues(3,:)=[Destination.GapEnd];
    end
    desTaperMode='step';
    noPlot=1; 
    tic
    disp(['UndSet being called with syntax UndSet ( undulatorLine, desCellList, desKvalues, desTaperMode, noPlot, nowait, ''PSfiles'', PSfiles); at ',datestr(now)]);
    UndSet ( undulatorLine, desCellList, desKvalues, desTaperMode, noPlot, nowait, 'PSfiles', PSfiles);%, printTo_e_Log, Comment )
    B=toc;
    disp(['UndSet call performed in ',num2str(B),' seconds']);
    
end

function UndulatorLine_Status_set(UL,Destination)
    %this is going to set "raw parameters, like gap, or row positions".
    switch(UL(1).name(1))
        case 'S'
            undulatorLine='SXR';
        case 'H'
            undulatorLine='HXR';
    end
    desCellList=[];
    for II=1:length(Destination)
       if(Destination(II).Type==3 || Destination(II).Type==4)
           desCellList(end+1)=Destination(II).Cell;
           desGapvalues(1,II)=Destination(II).Gap;
           desGapvalues(2,II)=Destination(II).GapEnd;
       end
    end
    nowait=1;
    UndGapSet(undulatorLine, desCellList, desGapvalues, nowait);

end

function UndulatorLine_Status_set_RAW(UL,Destination)
    %this is going to set "raw parameters, like gap, or row positions".
    switch(UL(1).name(1))
        case 'S'
            undulatorLine='SXR';
        case 'H'
            undulatorLine='HXR';
    end
    desCellList=[];
    for II=1:length(Destination)
       if(Destination(II).Type==3 || Destination(II).Type==4)
           desCellList(end+1)=Destination(II).Cell;
           desGapvalues(1,II)=Destination(II).Gap;
           desGapvalues(2,II)=Destination(II).GapEnd;
       end
    end
    nowait=1;
    try %that's stupid, but util gap upstream and downstream is available in raw...
        UndGapSetRaw( undulatorLine, desCellList, desGapvalues, nowait );
    catch
        UndGapSetRaw( undulatorLine, desCellList, desGapvalues(1,:), nowait );
    end
end

function PhaseShifterLine_Gap_set_RAW(UL,Destination)
    switch(UL(1).name(1))
        case 'S'
            undulatorLine='SXR';
        case 'H'
            undulatorLine='HXR';
    end
    desCellList=[Destination.Cell];
    desGapvalues=[Destination.Gap];
    nowait=1;   
    PSGapSet(undulatorLine, desCellList, desGapvalues, nowait);
end

function PhaseShifterLine_Gap_set(UL,Destination)
    switch(UL(1).name(1))
        case 'S'
            undulatorLine='SXR';
        case 'H'
            undulatorLine='HXR';
    end
    desCellList=[Destination.Cell];
    desGapvalues=[Destination.Gap];
    nowait=1;   
    PSGapSet(undulatorLine, desCellList, desGapvalues, nowait);
end

function [cell_data] = ULT_hxr_ps_manage_update(param, cell_data)

%Get the cell numbers of cells with installed undulators and phase shifters
und_cell_num = param.hxu_cell_num;
ps_cell_num = param.hxps_cell_num;

%Get the undulator temperatures
[und_temp] = hxr_ctrl_get_und_temp(und_cell_num);

%Get the phase shifter temperatures
[ps_temp] = hxr_ctrl_get_ps_temp(ps_cell_num);

%Update the temperatures in cell_data
[cell_data] = cell_data_temp_update(param, cell_data, und_cell_num, und_temp, ps_cell_num, ps_temp);

%Get the undulator desired gap values
[und_gap_des] = hxr_ctrl_get_und_gap_des(und_cell_num);

%Update the undulator gap values
[cell_data] = cell_data_und_gap_update(param, cell_data, und_cell_num, und_gap_des);

%Get the undulator desired taper values
[und_taper_des] = hxr_ctrl_get_und_taper_des(und_cell_num);

%Update the undulator taper values and exit end K and gap values
[cell_data] = cell_data_und_taper_update(param, cell_data, und_cell_num, und_taper_des);

%Check that the updated cell_data K values agree with the control system
ctrl_und_k_des = hxr_ctrl_get_und_k_des(und_cell_num);
cell_und_k_des = [cell_data(und_cell_num).und_k_des];
k_diff = ctrl_und_k_des' - cell_und_k_des;

%Get the desired additional phase shifter phase
[ps_add_phase] = hxr_ctrl_get_ps_add_phase(ps_cell_num);

%Update the additional phase added by the phase shifters
[cell_data] = cell_data_ps_add_phase_update(param, cell_data, ps_cell_num, ps_add_phase);

%Update the phase shifter PI values
[cell_data] = cell_data_ps_pi_update(param, cell_data);

end


function [cell_data] = ULT_sxr_ps_manage_update(param, cell_data)

%Get the cell numbers of cells with installed undulators and phase shifters
und_cell_num = param.sxu_cell_num;
ps_cell_num = param.sxps_cell_num;

%Get the undulator temperatures
[und_temp] = sxr_ctrl_get_und_temp(und_cell_num);

%Get the phase shifter temperatures
[ps_temp] = sxr_ctrl_get_ps_temp(ps_cell_num);

%Update the temperatures in cell_data
[cell_data] = cell_data_temp_update(param, cell_data, und_cell_num, und_temp, ps_cell_num, ps_temp);

%Get the undulator desired gap values
[und_gap_des] = sxr_ctrl_get_und_gap_des(und_cell_num);

%Update the undulator gap values
[cell_data] = cell_data_und_gap_update(param, cell_data, und_cell_num, und_gap_des);

%Get the undulator desired taper values
[und_taper_des] = sxr_ctrl_get_und_taper_des(und_cell_num);

%Update the undulator taper values and exit end K and gap values
[cell_data] = cell_data_und_taper_update(param, cell_data, und_cell_num, und_taper_des);

%Check that the updated cell_data K values agree with the control system
ctrl_und_k_des = sxr_ctrl_get_und_k_des(und_cell_num);
cell_und_k_des = [cell_data(und_cell_num).und_k_des];
k_diff = ctrl_und_k_des' - cell_und_k_des;

%Get the desired additional phase shifter phase
[ps_add_phase] = sxr_ctrl_get_ps_add_phase(ps_cell_num);

%Update the additional phase added by the phase shifters
[cell_data] = cell_data_ps_add_phase_update(param, cell_data, ps_cell_num, ps_add_phase);

%Update the phase shifter PI values
[cell_data] = cell_data_ps_pi_update(param, cell_data);

end
