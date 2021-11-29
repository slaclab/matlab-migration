function fh=ULT_PhaseShifterFunctions
    fh.Get_Phase=@Get_Phase;
    fh.Get_State=@Get_State;
    fh.Set_State_Struct=@Set_State_Struct;
    fh.Set_Phase=@Set_Phase;
    fh.Init_PHAS=@Init_PHAS;
    fh.LoadSplineFile=@LoadSplineFile;
    fh.Get_Gap=@Get_Gap;
    fh.Set_Gap=@Set_Gap;
end

function OUT=Get_Gap(PHAS)
    OUT=lcaGetSmart(PHAS.pv.GapAct);
end

function Dest=Set_State_Struct(PHAS,TargetState)
    if(ischar(TargetState))
       if(strcmpi(TargetState,'out'))
           Dest.Gap=100;
       end
    else
    Dest.Gap=TargetState.Gap;
    end
    Dest.Cell=PHAS.Cell_Number;
end

function PHAS=Init_PHAS(PHAS)
    PHAS.GapOut=100;
    PHAS.pv.PDes=[PHAS.PV,':DPHI'];
    PHAS.pv.PIAct=[PHAS.PV,':PIAct'];
    PHAS.pv.PIDes=[PHAS.PV,':PIDes'];
    PHAS.pv.GapDes=[PHAS.PV,':GapDes'];
    PHAS.pv.GapAct=[PHAS.PV,':GapAct'];
    PHAS.pv.Go=[PHAS.PV,':Go.PROC'];
    PHAS.pv.ConvertPI2Gap=[PHAS.PV,':ConvertPI2Gap.PROC'];  
    switch PHAS.Type
        case 3  
            PHAS.splinefiles.pivsgap_spline =['/u1/lcls/epics/ioc/data/','ioc-undh-uc',PHAS.Cell_String,'/datafiles/hxps_cell',PHAS.Cell_String,'_pivsgap_spline.dat'];  
            PHAS.splinefiles.i1x_vs_gap=['/u1/lcls/epics/ioc/data/','ioc-undh-uc',PHAS.Cell_String,'/datafiles/hxps_cell',PHAS.Cell_String,'_i1xvsgap_spline.dat'];    
            PHAS.splinefiles.i2x_vs_gap=['/u1/lcls/epics/ioc/data/','ioc-undh-uc',PHAS.Cell_String,'/datafiles/hxps_cell',PHAS.Cell_String,'_i2xvsgap_spline.dat'];    
            PHAS.splinefiles.i1y_vs_gap=['/u1/lcls/epics/ioc/data/','ioc-undh-uc',PHAS.Cell_String,'/datafiles/hxps_cell',PHAS.Cell_String,'_i1yvsgap_spline.dat'];    
            PHAS.splinefiles.i2y_vs_gap=['/u1/lcls/epics/ioc/data/','ioc-undh-uc',PHAS.Cell_String,'/datafiles/hxps_cell',PHAS.Cell_String,'_i2yvsgap_spline.dat'];  
            PHAS.splinefiles.orbitCorrection_vs_gap=['/u1/lcls/matlab/undulator/XYcorrSplineData/GapCorr_H_',regexprep(PHAS.PV,':','_'),'.dat'];
            PHAS.splinedata.cell=PHAS.Cell_Number;
            PHAS.splinedata.PI_vs_gap=LoadSplineFile(PHAS.splinefiles.pivsgap_spline,8);
            PHAS.splinedata.i1x_vs_gap=LoadSplineFile(PHAS.splinefiles.i1x_vs_gap,2);
            PHAS.splinedata.i2x_vs_gap=LoadSplineFile(PHAS.splinefiles.i2x_vs_gap,3);
            PHAS.splinedata.i1y_vs_gap=LoadSplineFile(PHAS.splinefiles.i1y_vs_gap,4);
            PHAS.splinedata.i2y_vs_gap=LoadSplineFile(PHAS.splinefiles.i2y_vs_gap,5);
            PHAS.splinedata.PhasOrbitCorrection_vs_gap=LoadSplineFile(PHAS.splinefiles.orbitCorrection_vs_gap,9);
        case 4
            PHAS.splinefiles.pivsgap_spline =['/u1/lcls/epics/ioc/data/','sioc-unds-mc',PHAS.Cell_String,'/datafiles/sxps_cell',PHAS.Cell_String,'_pivsgap_spline.dat'];
            PHAS.splinefiles.i1x_vs_gap=['/u1/lcls/epics/ioc/data/','sioc-unds-mc',PHAS.Cell_String,'/datafiles/sxps_cell',PHAS.Cell_String,'_i1xvsgap_spline.dat'];   
            PHAS.splinefiles.i2x_vs_gap=['/u1/lcls/epics/ioc/data/','sioc-unds-mc',PHAS.Cell_String,'/datafiles/sxps_cell',PHAS.Cell_String,'_i2xvsgap_spline.dat'];     
            PHAS.splinefiles.i1y_vs_gap=['/u1/lcls/epics/ioc/data/','sioc-unds-mc',PHAS.Cell_String,'/datafiles/sxps_cell',PHAS.Cell_String,'_i1yvsgap_spline.dat'];  
            PHAS.splinefiles.i2y_vs_gap=['/u1/lcls/epics/ioc/data/','sioc-unds-mc',PHAS.Cell_String,'/datafiles/sxps_cell',PHAS.Cell_String,'_i2yvsgap_spline.dat'];    
            PHAS.splinefiles.orbitCorrection_vs_gap=['/u1/lcls/matlab/undulator/XYcorrSplineData/GapCorr_S_',regexprep(PHAS.PV,':','_'),'.dat'];
            PHAS.splinedata.cell=PHAS.Cell_Number;
            PHAS.splinedata.PI_vs_gap=LoadSplineFile(PHAS.splinefiles.pivsgap_spline,8);
            PHAS.splinedata.i1x_vs_gap=LoadSplineFile(PHAS.splinefiles.i1x_vs_gap,2);
            PHAS.splinedata.i2x_vs_gap=LoadSplineFile(PHAS.splinefiles.i2x_vs_gap,3);
            PHAS.splinedata.i1y_vs_gap=LoadSplineFile(PHAS.splinefiles.i1y_vs_gap,4);
            PHAS.splinedata.i2y_vs_gap=LoadSplineFile(PHAS.splinefiles.i2y_vs_gap,5);
            PHAS.splinedata.OrbitCorrection_vs_gap=LoadSplineFile(PHAS.splinefiles.orbitCorrection_vs_gap,9);
    end
    
end

function phase=Get_Phase(PHAS)
    phase=lcaGetSmart(PHAS.pv.PDes);
end

function State=Get_State(PHAS)
    State.PIAct=lcaGetSmart(PHAS.pv.PIAct);
    State.PIDes=lcaGetSmart(PHAS.pv.PIDes);
    State.phaseDes=lcaGetSmart(PHAS.pv.PDes);
    State.phase=NaN;
    State.GapAct=lcaGetSmart(PHAS.pv.GapAct);
    State.GapDes=lcaGetSmart(PHAS.pv.GapDes);
end

function OUT=Set_Phase(PHAS,phase)
    lcaPutSmart(PHAS.pv.PDes,phase); OUT=1;
end

function OUT=Set_Gap(PHAS,GapDes)
    if(nargin<3)
        if(PHAS.Type==3)
            OUT=PSGapSet('HXR', PHAS.Cell_Number, GapDes);
        else
            OUT=PSGapSet('SXR', PHAS.Cell_Number, GapDes);
        end 
    end
    OUT=1;
    if(PHAS.Type==3)
        OUT=PSGapSet('HXR', PHAS.Cell_Number, GapDes, 0);
    else
        OUT=PSGapSet('SXR', PHAS.Cell_Number, GapDes, 0);
    end
end

function [SP_OUT,Table]=LoadSplineFile(file,type)
    FID=fopen(file);
    if(FID==-1)
       disp('File Not Found') 
    end
    %Always
    SP_OUT.SerialNumber='';SP_OUT.Dataset=1;SP_OUT.MMFtemp='';SP_OUT.MMFtemp_unit='C'; ColumnSize=2;
    [status,SNfn]=system(['readlink ',file]);
    POS=strfind(SNfn,'_D');
    SP_OUT.Dataset=str2double(SNfn(POS+2));
    PS=0;
    
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
            SP_OUT.gap_unit='mm'; SP_OUT.PI_unit='T^2mm^3'; var1='gap'; var2='PI';
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
                   PS=1;
               else
                   SP_OUT.SN=str2double(SP_OUT.SerialNumber((end-2):end));
               end
           end
           STR=strfind(LINE,'# Temperature:');
           if(~isempty(STR))
               SP_OUT.MMFtemp=regexprep(LINE((length('# Temperature:')+STR):end),{' ','C','F'},'');
               PlusLocation=strfind(SP_OUT.MMFtemp,'+'); 
               if(~isempty(PlusLocation))
                   SP_OUT.MMFtemp=SP_OUT.MMFtemp(1:(PlusLocation(1)-1));
               end
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
    if(PS)
       if((type>=2) && (type<=5))
           SP_OUT=rmfield(SP_OUT,'MMFtemp_unit');
           SP_OUT=rmfield(SP_OUT,'MMFtemp');
       end
    end
end



%Done
