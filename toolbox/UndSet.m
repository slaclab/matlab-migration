function success = UndSet ( undulatorLine, desCellList, desKvalues, desTaperMode, noPlot, nowait, varargin )
% 
% success = UndSet(UndulatorLine,cellList,desKvalues[,taperMode[,noPlot[,nowait[,optional parameters]]])
%
% This is the main function to set the undulator gaps, which implements all
% needed functionalities to make the FEL operate successfully: 
% (1) it sets the upstream undulator gaps to their requested values
% (2) it sets the undulator tapers
% (3) it sets the phase shifters according to the undulator gaps
% (4) it sets the 'A' coefficients of the XCOR and YCOR devices
% (temporarily these 'A' coefficients are set to 0)
% (5) for the HXR line, it sets the RFBPM .C offsets to compensate for
%     RFBPM moves due to undulator gap dependent girder deformations.
% 
% 
% Proper temperature corrections algorithms are used to calculate taper
% amplitudes from K values and for calculation the required phase shifter
% amplitudes.
% The function returns success = true, if the PVs have been successfully
% changed otherwise success will be returned as false.
%
% - undulatorLine is a character string, i.e., either 'HXR' or 'SXR'.
% - desCellList is an array of n cell numbers, e.g.  [13, 16:20, 22],
%   for which new values are provided in the next argument. 
% - desKvalues is a 1xn or 2xn array of new K value.
%      The first row should contain the desired (upstream) K values.
%      In case a 2xn array is provided:
%         That second row should contain the downstream K values.
%         The taperMode parameter will be ignored and taper values for the
%         undulators in the specified segments will be calculated from the
%         difference between the upstream K values up to the allowed limit.
% - desTaperMode is an optional parameter. It can have the values 'step'
%   (for step or LCLS-I type taper, i.e. no taper within an undulator), 
%   'cont' (continuous taper, i.e., the K value changes along the undulator
%   and the K value at the end of the undulator will be set to be equal to
%   the K value at the beginning of the downstream undulator), or 'keep'
%   (keep the current taper values).
%   'step' is the default if the parameter is omitted.
% - noPlot is an optional parameter. It can only be given if taperMode was
%   given. It can have the values true or false. If it is true plotting
%   will be surpressed, otherwise a plot will be produced.
% - nowait is an optional parameter. If present and true, the function will
%   return immediatly after starting the gap motions and will not wait for
%   the successful completion of it.
% - optional parameters are in the form of name value pairs. The pairs
%   can be added in any sequence. Accepted names are:
% - 'printTo_e_Log', values: true or false; default: false. This parameter
%   will be ignored if the noPlot option is set to true. If the noPlot
%   option is set to false and the printTo_e_Log option is given
%   (with any value), the plot will be sent to physics elog with a standard
%   comment line.
% - 'Comment', value: a string. This parameter will be ignored
%   if the noPlot option is set to true.  If the noPlot option is set to
%   false, the printTo_e_Log option is given and this parameter is given
%   the string provided will be incorporated as title in the message
%   printed to the physics e_Log. If this parameter is omitted and printing
%   to_e_Log takes place, a default string will be used.
% - 'plotMode', values: 'K' or 'gap'; default: 'gap';
% - 'axisMode', values: 'c' or 'z'; default: 'c';
% - 'fig_to_Files', values: true or false; default: false;
% - 'saveMovie', values: true or false; default: false;
% - 'saveData', values: true or false; default: false;
% - 'useGapsPermit', values: true or false; default: true;
% - 'PSfiles', structure with members
%           undulatorLine
%           param
%           PSdata
% - 'PSconst', values: true or false; default: false;
%        true means that the phase shifter will not be moved.
% - 'PSgaps', values: array of gap valaues; Not yet implemented.
%        true means that the phase shifter will not be moved.
%
% Last changed by Heinz-Dieter Nuhn, 7/3/2021

%addpath ( '/home/physics/nuhn/wrk/matlab/Ks', ...
%          '/home/physics/nuhn/wrk/matlab/cams', ...
%          '/home/physics/nuhn/wrk/matlab/RFBPMs', ...
%          '/home/physics/nuhn/wrk/matlab/RADFETs' ...
%          );
      
%addpath ( '/home/physics/wolf/PhaseShifterManagerNew/HXR', ...
%          '/home/physics/wolf/PhaseShifterManagerNew/SXR', ...
%          '/home/physics/wolf/PhaseShifterManagerNew/Lib', ...
%          '/home/physics/wolf/PhaseShifterManagerNew/Lib/CellData', ...
%          '/home/physics/wolf/PhaseShifterManagerNew/Lib/EscanData', ...
%          '/home/physics/wolf/PhaseShifterManagerNew/Lib/HXRControl', ...
%          '/home/physics/wolf/PhaseShifterManagerNew/Lib/JumpAnal', ...
%          '/home/physics/wolf/PhaseShifterManagerNew/Lib/PhaseData', ...
%          '/home/physics/wolf/PhaseShifterManagerNew/Lib/SXRControl', ...
%          '/home/physics/wolf/PhaseShifterManagerNew/Lib/TunnelFieldMeas' ...
%          );

addpath ( genpath ( '/home/physics/nuhn/wrk/matlab' ), genpath ( '/home/physics/wolf/PhaseShifterManagerR2' ) );
%addpath ( genpath ( '/home/physics/nuhn/wrk/matlab' ), genpath ( '/home/physics/wolf/PhaseShifterManagerNew' ) );
%addpath ( genpath ( '/home/physics/wolf/PhaseShifterManagerNew' ) );

lcaSetSeverityWarnLevel ( 5 );

useGapsPermit  = true; % Are we allowed to move gap motors?
success        = true;
updateCoffsets = true;
updateEFCs     = false; % This is now done in EPICS 6/4/2020
verbose        = true;
updateCorrs    = false; % Not yet implemented

if ( useGapsPermit )
    saveData   = false;
    saveMovie  = false;
end

monitorDelay   = 0.1;

if ( useGapsPermit && saveMovie )
    monitorDelay = 0.03;
end

if ( updateCorrs )
    load ( '/u1/lcls/matlab/undulator/XYcorrSplineData/UndQuadCorrData.mat', 'UndQuadCorrData' );
end

%plotKconfig          = true;
plotinit             = true;
PSconst              = false;
PSgiven              = false;
const.stepMode       = 1;
const.contMode       = 2;
const.keepMode       = 3;
const.variMode       = 4;
const.plotK          = 5;
const.plotgap        = 6;
const.zaxis          = 7;
const.caxis          = 8;
DeviceParms.plotMode = const.plotgap;
DeviceParms.axisMode = const.caxis;
fig_to_Files         = false;
printTo_e_Log        = false;
Comment              = sprintf ( '%s Undulator Motion Report', undulatorLine );

if ( strcmp ( undulatorLine, 'HXR' ) || strcmp ( undulatorLine, 'SXR' ) )
    Line                 = upper ( undulatorLine ( 1 ) );
else
    display ( undulatorLine );
    error ( 'undulatorLine can only by ''HXR'' or ''SXR''.' );
end

inputParms           = parseVarArgs ( varargin, const );

if ( isfield ( inputParms, 'axisMode' ) )
    DeviceParms.axisMode = inputParms.axisMode;    
end

if ( isfield ( inputParms, 'plotMode' ) )
    DeviceParms.plotMode = inputParms.plotMode;    
end

if ( isfield ( inputParms, 'fig_to_Files' ) )
    fig_to_Files = inputParms.fig_to_Files;    
end

if ( isfield ( inputParms, 'printTo_e_Log' ) )
    printTo_e_Log = inputParms.printTo_e_Log;    
end

if ( isfield ( inputParms, 'Comment' ) )
    if ( DeviceParms.plotMode == const.plotK )
        Comment = sprintf ( '%s Undulator Motion Report', undulatorLine );
    else
        Comment = sprintf ( '%s Undulator and Phase Shifter Motion Report', undulatorLine );
    end
end

if ( isfield ( inputParms, 'saveMovie' ) )
    saveMovie = inputParms.saveMovie;    
end

if ( isfield ( inputParms, 'saveData' ) )
    saveData = inputParms.saveData;    
end

if ( isfield ( inputParms, 'useGapsPermit' ) )
    useGapsPermit = inputParms.useGapsPermit;    
end

if ( isfield ( inputParms, 'PSfiles' ) )
    if ( strcmp ( inputParms.PSfiles.undulatorLine, undulatorLine ) )
        gotPSfiles = true;
        param      = inputParms.PSfiles.param; 
        PSdata     = inputParms.PSfiles.PSdata; 
    else
        fprintf ( 'PSfiles are for the other undulatorLine.\n' );
        gotPSfiles = false;
    end
else
    gotPSfiles = false;
end

%gotPSfiles = false;

if ( ~gotPSfiles )
    param                = cell_data_param ( );
end

if ( isfield ( inputParms, 'PSconst' ) )
    PSconst = inputParms.PSconst;
end

% construct PVs
if ( Line == 'H' )
    UndConsts               = util_HXRUndulatorConstants;
    
    if ( ~gotPSfiles && ~PSconst )
        PSdata                  = hxr_ps_manage_init ( );
    end
    
    if ( ~PSconst )
        PSmanage                = @hxr_ps_manage_update;
        DeviceParms.PS_CELL_NUM = param.hxps_cell_num;
    end
    
    fmtPVbase               = 'USEG:UNDH:';
    fmtGap                  = 'USEG:UNDH:%d50:GapDes';
    fmtK                    = 'USEG:UNDH:%d50:KDes';
    fmtT                    = 'USEG:UNDH:%d50:TaperDes';
    fmtC                    = 'USEG:UNDH:%d50:ConvertK2Gap.PROC';
    fmtS                    = 'USEG:UNDH:%d50:Stop';
    fmtG                    = 'USEG:UNDH:%d50:Go.VAL';
    fmtM                    = 'USEG:UNDH:%d50:DeviceActive';
    fmtI                    = 'USEG:UNDH:%d50:IdControlMsg';
    fmtE                    = 'USEG:UNDH:%d50:UndulatorError';
    fmtEPS                  = 'PHAS:UNDH:%d95:PhaseShifterError';    
    fmtMPS                  = 'PHAS:UNDH:%d95:Motor.DMOV';    
else
    UndConsts               = util_SXRUndulatorConstants;

    if ( ~gotPSfiles  && ~PSconst )
        PSdata                  = sxr_ps_manage_init ( );
    end
    
    if ( ~PSconst )
        PSmanage                = @sxr_ps_manage_update;
        DeviceParms.PS_CELL_NUM = param.sxps_cell_num;
    end
    
    fmtPVbase               = 'USEG:UNDS:';
    fmtGap                  = 'USEG:UNDS:%d50:GapDes';
    fmtK                    = 'USEG:UNDS:%d50:KDes';
    fmtT                    = 'USEG:UNDS:%d50:TaperDes';
    fmtC                    = 'USEG:UNDS:%d50:ConvertK2Gap.PROC';
    fmtS                    = 'USEG:UNDS:%d50:Stop';
    fmtG                    = 'USEG:UNDS:%d50:Go.VAL';
    fmtM                    = 'USEG:UNDS:%d50:GapDmov';
    fmtE                    = 'USEG:UNDS:%d50:USPOSY:Fault';
    fmtA                    = 'USEG:UNDS:%d50:ActiveMode';
    fmtV                    = 'USEG:UNDS:%d50:VCTStop';
    fmtCenter               = 'USEG:UNDS:%d50:CtrLnGo';
    fmtCenterStatus         = 'USEG:UNDS:%d50:UndCentered';
    fmtUSVAct               = 'USEG:UNDS:%d50:US:VAct.SEVR';
    fmtDSVAct               = 'USEG:UNDS:%d50:DS:VAct.SEVR';
    fmtEPS                  = 'MOC:UNDS:%d80:PS:Fault';
    fmtMPS                  = 'PHAS:UNDS:%d70:Motr.DMOV';    
end


splineFileName                     = '/u1/lcls/matlab/ULT_GuiData/UL.mat';

if ( exist ( splineFileName, 'file' ) )
    load ( splineFileName, '-mat', 'ul' );
    
    if ( Line == 'H' )
        SplineData.USEG        = ul ( 1 ).SplineData.USEG ( UndConsts.currentSegmentCells );
        PhasCells = UndConsts.currentSegmentCells;
        PhasCells ( PhasCells == 46 ) = [];
        SplineData.PHAS = ul ( 1 ).SplineData.PHAS ( PhasCells );
    else
        SplineData.USEG = ul ( 2 ).SplineData.USEG ( UndConsts.currentSegmentCells );
        PhasCells = UndConsts.currentSegmentCells;
        PhasCells ( PhasCells == 47 ) = [];
        SplineData.PHAS = ul ( 2 ).SplineData.PHAS ( PhasCells );
    end
    
    SplineData.USEGentries = length ( SplineData.USEG );
    SplineData.PHASentries = length ( SplineData.PHAS );
else
    SplineData                    = getSplineData ( undulatorLine, UndConsts.currentSegmentCells );
end

initU                             = UndRead ( undulatorLine );

T.mean                            = lcaGetSmart ( strcat ( fmtPVbase, num2str ( UndConsts.currentSegmentCells', '%-d' ), { '50:MeanTemp' } ) );
T.MMF                             = lcaGetSmart ( strcat ( fmtPVbase, num2str ( UndConsts.currentSegmentCells', '%-d' ), { '50:MMFTemp' } ) );
T.Kcoeff                          = lcaGetSmart ( strcat ( fmtPVbase, num2str ( UndConsts.currentSegmentCells', '%-d' ), { '50:KTempCoeff' } ) );

if ( DeviceParms.plotMode == const.plotK )
    figName = sprintf ( '%s_%s_Undulator_K_change', datestr ( now,'yyyy-dd-mm_HHMMSS' ), undulatorLine );    
else
    figName = sprintf ( '%s_%s_Undulator_and_PhaseShifter_gap_motion', datestr ( now,'yyyy-dd-mm_HHMMSS' ), undulatorLine );    
end
        
% check input consistency
desCells       = length ( desCellList );
[ Krows, Ks ]  = size ( desKvalues );

if ( desCells ~= Ks )
    display ( [ desCellList; desKvalues ] );
    error ( 'desCellList and desKList don''t have the same number of elements' );
end

useCells  = UndConsts.currentSegmentCells ( ismember ( UndConsts.currentSegmentCells, desCellList ) == 1 );
        
if ( length ( useCells ) ~= length ( desCellList ) )
    currentSegmentCells = UndConsts.currentSegmentCells;
    display ( [ desCellList currentSegmentCells ] );
    error ( 'Data is not available for all requested cells!' );
end

if ( Krows == 2 )
    taperMode = const.variMode;
elseif ( Krows ~= 1 )
    display ( desKvalues );
    error ( 'Wrong number of rows in desKvalues, should be 1 or 2' );
else
    taperMode = 0; % temporarily set to 0.
end

desKList = desKvalues ( 1, : );

desGapList = desKList * 0;

for j = 1 : length ( desGapList )
   desGapList ( j ) = K_to_gap ( j, SplineData.USEG, desKList ( j ), T );
end

maxGap  = max ( desGapList );
minGap  = min ( desGapList );

if ( ~taperMode )
    if ( nargin >= 4 && exist ( 'desTaperMode', 'var' )  && ~isempty ( desTaperMode ) )
        if ( strcmp ( desTaperMode, 'step' ) ) 
            taperMode = const.stepMode;
        elseif ( strcmp ( desTaperMode,  'cont' ) )
            taperMode = const.contMode;
        elseif ( strcmp ( desTaperMode,  'keep' ) )
            taperMode = const.keepMode;
        else
            fprintf ( 'Unkown desTaperMode: %s\nWill use step taper.\n', desTaperMode );
            taperMode = const.stepMode;
        end    
    else
        taperMode = const.stepMode;
    end
end

if ( taperMode == const.variMode )
    desDnKList   = desKvalues ( 2, : );
    desDnGapList = desKList * 0;

    for j = 1 : length ( desGapList )
        desDnGapList ( j ) = K_to_gap ( j, SplineData.USEG, desDnKList ( j ), T );
    end

    maxDnGap = max ( desDnGapList );
    minDnGap = min ( desDnGapList );

    maxGap  = max ( maxGap, maxDnGap );
    minGap  = min ( minGap, minDnGap );
%    maxDnK = max ( desKvalues ( 2, : ) );
%    minDnK = min ( desKvalues ( 2, : ) );

%    maxK  = max ( maxK, maxDnK );
%    minK  = min ( minK, minDnK );
else
    maxGap  = max ( maxGap );
    minGap  = min ( minGap );   
%    maxK  = max ( maxK );
%    minK  = min ( minK );   
end

%if ( maxK > UndConsts.Kmax || minK < UndConsts.Kmin )
if ( maxGap > UndConsts.maxUndGap || minGap < UndConsts.minUndGap )
%    display ( desKvalues )
%    error ( 'At least one K value is out of range.' );
    display ( desGapList );
    
    if ( taperMode == const.variMode )
        display ( desDnGapList );
    end
    
    fprintf ( 'At least one K value requires an out of range gap.' );
    
end

if ( any ( ~ismember ( desCellList, UndConsts.currentSegmentCells ) ) )
    display ( UndConsts.currentSegmentCells );
    display ( desCellList );
    fprintf ( 'At least one undulator in cellList is currently not available.\n' );
    error ( 'The available gap range is [%.3f, %.3f].', UndConsts.minUndGap, UndConsts.maxUndGap  );
    
%    success = false;
%    return
end

if ( nargin >= 5 && exist ( 'noPlot', 'var' )  && ~isempty ( noPlot ) )
    if ( noPlot ) 
        makePlots = false;
    else
        makePlots = true;
    end
else
    makePlots = true;
end

if ( nargin >= 6 && exist ( 'nowait', 'var' ) )
    if ( nowait ) 
        nowait_switch = true;
    else
        nowait_switch = false;
    end    
else
    nowait_switch = false;
end

if ( nowait_switch )
    verbose       = false;
end

DeviceParms.currentSegmentCells        = UndConsts.currentSegmentCells;
DeviceParms.currentSegmentCellCount    = length ( DeviceParms.currentSegmentCells );
isdesListMember_in_currentSegmentCells = ismember ( DeviceParms.currentSegmentCells, desCellList );

currentPSCells                         = UndConsts.currentPSCells;
DeviceParms.currentPSCellCount         = length ( currentPSCells );
desPScellList                          = intersect ( currentPSCells, desCellList );
desPScells                             = length ( desPScellList );

K_PVs                                  = cell ( desCells,   1 );
T_PVs                                  = cell ( desCells,   1 );
C_PVs                                  = cell ( desCells,   1 );
S_PVs                                  = cell ( desCells,   1 );
G_PVs                                  = cell ( desCells,   1 );
M_PVs                                  = cell ( desCells,   1 );
E_PVs                                  = cell ( desCells,   1 );
EPS_PVs                                = cell ( desPScells, 1 );
MPS_PVs                                = cell ( desPScells, 1 );

if ( Line == 'H' )
    I_PVs                              = cell ( desCells, 1 );
else
    A_PVs                              = cell ( desCells,   1 );
    V_PVs                              = cell ( desCells,   1 );
    Center_PVs                         = cell ( desCells,   1 );
    CenterStatus_PVs                   = cell ( desCells,   1 );
end

for p = 1 : desCells
    cellNo         = desCellList ( p ); 

    Gap_PV         = sprintf ( fmtGap, cellNo );
    Gap_PVs ( p )  = { Gap_PV };
    K_PV           = sprintf ( fmtK, cellNo );
    K_PVs ( p )    = { K_PV };
    T_PV           = sprintf ( fmtT, cellNo );
    T_PVs ( p )    = { T_PV };
    C_PV           = sprintf ( fmtC, cellNo );
    C_PVs ( p )    = { C_PV };
    S_PV           = sprintf ( fmtS, cellNo );
    S_PVs ( p )    = { S_PV };
    G_PV           = sprintf ( fmtG, cellNo );
    G_PVs ( p )    = { G_PV };
    M_PV           = sprintf ( fmtM, cellNo );
    M_PVs ( p )    = { M_PV };
    E_PV           = sprintf ( fmtE, cellNo );
    E_PVs ( p )    = { E_PV };
    
    if ( Line == 'H' )
        I_PV                   = sprintf ( fmtI, cellNo );
        I_PVs ( p )            = { I_PV };
    else
        A_PV                   = sprintf ( fmtA, cellNo );
        A_PVs ( p )            = { A_PV };
        V_PV                   = sprintf ( fmtV, cellNo );
        V_PVs ( p )            = { V_PV };
        Center_PV              = sprintf ( fmtCenter, cellNo );
        Center_PVs ( p )       = { Center_PV };
        
        CenterStatus_PV        = sprintf ( fmtCenterStatus, cellNo );
        CenterStatus_PVs ( p ) = { CenterStatus_PV };

        USVAct_PV              = sprintf ( fmtUSVAct, cellNo );
        USVAct_PVs ( p )       = { USVAct_PV };
        DSVAct_PV              = sprintf ( fmtDSVAct, cellNo );
        DSVAct_PVs ( p )       = { DSVAct_PV };
    end
end

for p              = 1 : desPScells
    cellNo         = desPScellList ( p ); 

    EPS_PV         = sprintf ( fmtEPS, cellNo );
    EPS_PVs ( p )  = { EPS_PV };
    MPS_PV         = sprintf ( fmtMPS, cellNo );
    MPS_PVs ( p )  = { MPS_PV };
end

%if ( ~exist ( 'printTo_e_Log', 'var' ) )
%    printTo_e_Log = false;
%end

%if ( ~exist ( 'Comment', 'var' ) )
%    if ( DeviceParms.plotMode == const.plotK )
%        Comment = sprintf ( '%s Undulator Motion Report', undulatorLine );
%    else
%        Comment = sprintf ( '%s Undulator and Phase Shifter Motion Report', undulatorLine );
%    end
%end

if ( verbose )
    fprintf ( 'Executing command:\n' );

    command = sprintf ( '%s(''%s'',[', mfilename, undulatorLine );

    for j = 1 : desCells    
        command = sprintf ( '%s%d', command, desCellList ( j ) );

        if ( j == desCells )
            command = sprintf ( '%s],', command );
        else
            command = sprintf ( '%s,', command );
        end
    end

    command = sprintf ( '%s[', command );

    for j = 1 : Ks    
        command = sprintf ( '%s%.4f', command, desKList ( j ) );
    
        if ( j == Ks )
            command = sprintf ( '%s]', command );
        else
            command = sprintf ( '%s,', command );
        end
    end

    if ( taperMode )
         command = sprintf ( '%s,''%s''', command, taperMode );
    else
         command = sprintf ( '%s,''%s''', command, 'step' );
    end 
    
    if ( makePlots )
        command = sprintf ( '%s,true', command );
    else
        command = sprintf ( '%s,false', command );
    end

    if ( nowait_switch )
        command = sprintf ( '%s,true', command );
    else
        command = sprintf ( '%s,false', command );
    end

    if ( printTo_e_Log )
        command = sprintf ( '%s,true', command );
    else
        command = sprintf ( '%s,false', command );
    end

    command = sprintf ( '%s,''%s'');', command, Comment );

    fprintf ( '%s\n', command );
end

if ( useGapsPermit )
    if ( nowait_switch )
        monitorMotion = false;
        makePlots     = false;
            
        fprintf ( 'No plots will be produced, because nowait is requested.\n' );
    else
        monitorMotion = true;
    end
end

if ( Line == 'H' )
    undStatus = lcaGet ( E_PVs );
else
    undStatus = lcaGet ( E_PVs ) ~= 0;
end

movableUndulator_in_desList_Index = find ( undStatus == 0 );
movableUndulatorCount             = length ( movableUndulator_in_desList_Index );
monitorUndulatorList              = desCellList ( movableUndulator_in_desList_Index );

%fprintf ( 'Number of movable undulators in desCellList: %d\n', movableUndulatorCount );

if ( ~movableUndulatorCount )
    useGapsPermit                 = false;
    
    fprintf ( 'Setting internal flag, useGapPermit, to false, \nbecause none of the undulators is movable.\n' );
end

PS_Status                         = lcaGetSmart ( EPS_PVs ) == 0;

movablePS_in_desPSList_Index      = find ( PS_Status );
movablePS_Count                   = length ( movablePS_in_desPSList_Index );
monitorPS_List                    = desPScellList ( movablePS_in_desPSList_Index );

%fprintf ( 'Number of movable phase shifters in desCellList: %d\n', movablePS_Count );

% The gap_to_K function will not work if an undulator gap is above the
% maximum operational gap. The actual current data are, therefore, reset to
% that limit to make the function work. This will not affect the outcome of
% the function, because only the K values of the requested undulators will
% be changed to new values with gaps inside the permitted range.
for p = 1 : length ( initU ( :, 2 ) )
    if ( initU ( p, 4 ) > UndConsts.maxOprUndGap )
        initU ( p, 4 )            = UndConsts.maxOprUndGap;
        initU ( p, 2 )            = gap_to_K ( p, SplineData.USEG, UndConsts.maxOprUndGap, T );
    end
end

targetU                                               = initU;
targetU ( isdesListMember_in_currentSegmentCells, 2 ) = desKList;
US_initK                                              = initU ( :, 2 );
US_initgap                                            = initU ( :, 4 );
inittaper                                             = initU ( :, 6 );
DS_initgap                                            = US_initgap + inittaper;
US_targetK                                            = targetU ( :, 2 );

DS_initK                                              = zeros ( DeviceParms.currentSegmentCellCount, 1 );
US_targetgap                                          = zeros ( DeviceParms.currentSegmentCellCount, 1 );
DS_targetgap                                          = zeros ( DeviceParms.currentSegmentCellCount, 1 );
DeviceParms.UndStart_z                                = zeros ( DeviceParms.currentSegmentCellCount, 1 );
DeviceParms.PSStart_z                                 = zeros ( DeviceParms.currentPSCellCount, 1 );

for p = 1 : DeviceParms.currentSegmentCellCount
    cellNo                           = DeviceParms.currentSegmentCells ( p );     
    k                                = find ( UndConsts.allCamStages == cellNo );
    
    US_targetgap ( p )               = K_to_gap ( p, SplineData.USEG, US_targetK ( p ), T );
    DS_initK ( p )                   = gap_to_K ( p, SplineData.USEG, DS_initgap ( p ), T );
    DeviceParms.UndStart_z ( p )     = UndConsts.Z_US { k };
end

for p = 1 : DeviceParms.currentPSCellCount
    cellNo                           = currentPSCells ( p ); 
    k                                = find ( UndConsts.allCamStages == cellNo );
    
    DeviceParms.PSStart_z ( p )      = UndConsts.Z_PS { k };
end

DeviceParms.UndEnd_z                 = DeviceParms.UndStart_z + UndConsts.SegmentLength;
DS_targetK                           = DS_initK;


if ( taperMode == const.keepMode )
    targettaper                      = inittaper;
else
    if ( taperMode == const.contMode )
        DS_targetK ( 1 : end - 1 )   = US_targetK ( 2 : end );
    elseif ( taperMode == const.stepMode )
        DS_targetK                   = US_targetK;
    else
        DS_targetK ( isdesListMember_in_currentSegmentCells ) = desKvalues ( 2, : );  
    end

    for p = 1 : DeviceParms.currentSegmentCellCount
        DS_targetgap ( p )           = K_to_gap ( p, SplineData.USEG, DS_targetK ( p ), T );
    end

    targettaper                      = DS_targetgap - US_targetgap;
    targettaper ( end )              = targettaper ( end - 1 );
end

if ( max ( targettaper ) > UndConsts.maxtaper || min ( targettaper ) < UndConsts.mintaper  )
    targettaper ( targettaper > UndConsts.maxtaper ) = UndConsts.maxtaper;
    targettaper ( targettaper < UndConsts.mintaper ) = UndConsts.mintaper;
end

for p = 1 : DeviceParms.currentSegmentCellCount
    DS_targetgap ( p )               = US_targetgap ( p ) + targettaper ( p );
    DS_targetK   ( p )               = gap_to_K ( p, SplineData.USEG, DS_targetgap ( p ), T );
end

targetU ( :, 4 )                     = US_targetgap';
targetU ( :, 6 )                     = targettaper';

% set undulator desK PVs as input for the phase shifter gap calculation
% algorithm (no gap motion yet!)
newKvalues = targetU ( isdesListMember_in_currentSegmentCells, 2 );
newgvalues = targetU ( isdesListMember_in_currentSegmentCells, 4 );
newtvalues = targetU ( isdesListMember_in_currentSegmentCells, 6 );

if ( Line == 'H' )
    movingIndex   = 1 : DeviceParms.currentSegmentCellCount;
    movingGaps = lcaGet ( M_PVs, 0, 'double' );    
    movingIndex   = movingIndex ( movingGaps ~= 0 );
    
    if ( any ( movingIndex ) )
        fprintf ( 'Undulators were not ready:\n' );

        for j = 1 : DeviceParms.currentSegmentCellCount 
            fprintf ( '%2.2d ', DeviceParms.currentSegmentCells ( j ) )
        end
        
        fprintf ( '\n' );
    end
end

if ( Line == 'S' )
% Stop Chamber Tracking Mode, i.e. set undulator to Active Mode.
    ActiveMode = lcaGetSmart ( A_PVs, 0, 'double' );

    if ( ~isempty ( ActiveMode ( ~ActiveMode ) ) )
        nonActiveIndex = find ( ~ActiveMode );
        nonActiveCount = length ( nonActiveIndex );
        nonActiveV_PVs = cell ( nonActiveCount, 1 );
        
        for j = 1 : nonActiveCount
            k = nonActiveIndex ( j );
            nonActiveV_PVs { j } = V_PVs { k };
        end
    
        lcaPutSmart ( nonActiveV_PVs, 1 ); pause ( 1.0 );
    
        ActiveMode = lcaGetSmart ( A_PVs, 0, 'double' );

        if ( ~isempty ( ActiveMode ( ~ActiveMode ) ) )
            display ( [ DeviceParms.currentSegmentCells' ActiveMode ] );
            error ( 'Not all undulators went to active mode' );
        end
    end
end

lcaPutSmart ( S_PVs, 1 ); pause ( 0.1 );
lcaPutSmart ( T_PVs, newtvalues );
lcaPutSmart ( K_PVs, newKvalues ); pause ( 0.1 );
lcaPutSmart ( C_PVs, 1 ); pause ( 0.1 );
lcaPutSmart ( Gap_PVs, newgvalues ); pause ( 0.1 ); % Overwriting EPICS gap calculation
pause ( 1.0 );

%if ( useGapsPermit )
%     % Instruct the undulators to start moving their gaps    
%    lcaPut ( G_PVs, 1 );
%    
%    fprintf ('Undulator gap motion started.\n' );
%end

%US.targetgap

if ( ~PSconst )
% calculate phase shifter gaps
    PSdata             = PSmanage ( param, PSdata );
    DeviceParms.PS_GAP = [ PSdata(DeviceParms.PS_CELL_NUM).ps_gap_des ] * 1000; % [mm] 
    DeviceParms.PS_PI  = [ PSdata(DeviceParms.PS_CELL_NUM).ps_pi_des ]  * 10^9; % [T^2mm^3]
    DeviceParms.PS_DES = [ PSdata(DeviceParms.PS_CELL_NUM).ps_phase_des ];
end

if ( makePlots )
    if ( saveMovie )
        videoFileName       = [ figName '.avi' ];
        videoFile           = VideoWriter ( videoFileName );
        videoFile.FrameRate = 3.6;
        
        open ( videoFile )
    end
    
    fig = figure ( 2 );
    clf ( fig ); set ( fig, 'color', [ 1 1 1 ] );
        
    hold on;
    grid on;
    
    if ( Line == 'H' )
        DeviceParms.UndStart_c = ( DeviceParms.UndStart_z - UndConsts.refPos ) / UndConsts.CellLength + 0.5 + UndConsts.cellOffset;
        DeviceParms.UndEnd_c   = ( DeviceParms.UndEnd_z   - UndConsts.refPos ) / UndConsts.CellLength + 0.5 + UndConsts.cellOffset;
    else
        DeviceParms.UndStart_c = ( DeviceParms.UndStart_z - UndConsts.refPos ) / UndConsts.CellLength + 1.2 + UndConsts.cellOffset;
        DeviceParms.UndEnd_c   = ( DeviceParms.UndEnd_z   - UndConsts.refPos ) / UndConsts.CellLength + 1.2 + UndConsts.cellOffset;
    end
    
    if ( DeviceParms.axisMode == const.zaxis )
        Ax            = DeviceParms.UndStart_z;
        Bx            = DeviceParms.UndEnd_z;
    else
        Ax            = DeviceParms.UndStart_c;
        Bx            = DeviceParms.UndEnd_c;
    end
        
    if ( DeviceParms.plotMode == const.plotK )
        Aiy           = US_initK;
        Biy           = DS_initK;
        Aty           = US_targetK;
        Bty           = DS_targetK;

        ftns          = 3;
        ftn           = cell ( 2, ftns );

        ftn { 2, 01 } = 'initial USEG K';
        ftn { 2, 02 } = 'desired USEG K';
        ftn { 2, 03 } = 'final USEG K';
    else
        Aiy           = US_initgap;
        Biy           = DS_initgap;
        Aty           = US_targetgap;
        Bty           = DS_targetgap;

        ftns          = 6;
        ftn           = cell ( 2, ftns );

        ftn { 2, 01 } = 'initial USEG gap';
        ftn { 2, 02 } = 'desired USEG gap';
        ftn { 2, 03 } = 'final USEG gap';
        ftn { 2, 04 } = 'initial PHAS gap';
        ftn { 2, 05 } = 'desired PHAS gap';
        ftn { 2, 06 } = 'final PHAS gap';
    end
    
    if ( plotinit )
        for p = 1 : DeviceParms.currentSegmentCellCount        
            ftn { 1, 01 } = plot ( [ Ax(p) Bx(p) ], [ Aiy(p) Biy(p) ], '-k', 'linewidth', 4, 'Color', [ 0.7 0.7 0.7] );
        end
    end
    
    for p = 1 : DeviceParms.currentSegmentCellCount
        ftn { 1, 02 } = plot ( [ Ax(p) Bx(p) ], [ Aty(p) Bty(p) ], '-r', 'linewidth', 2  );
    end
        
    if ( DeviceParms.plotMode == const.plotK )
%        ytickformat('%.5f');
        title ( sprintf ( 'LCLS-II %s K changes on %s', undulatorLine, datestr ( now, 'mmmm dd, yyyy HH:MM:SS.FFF AM') ) );
        ylabel ( 'K values' );
    else
%        ytickformat('%.4f');
        title ( sprintf ( 'LCLS-II %s gap changes on %s', undulatorLine, datestr ( now, 'mmmm dd, yyyy HH:MM:SS.FFF AM') ) );
        ylabel ( 'gap values (mm)' );
    end
    
    if ( DeviceParms.axisMode == const.zaxis )
        xlabel ( 'z positions (m)' );
    else
        xlabel ( 'cell numbers' );
    end
    
% plot the initial and target and phase shifter gap values

    initP                   = PSRead ( undulatorLine );
    DeviceParms.init_PS_GAP = initP ( :, 4 );
    
    for c = 1 : length ( DeviceParms.init_PS_GAP )
        p = DeviceParms.PS_CELL_NUM ( c );
        
        if ( DeviceParms.plotMode == const.plotgap )
            if ( DeviceParms.axisMode == const.zaxis )
                PS_z = DeviceParms.PSStart_z ( c );

                ftn { 1, 04 } = plot ( PS_z, DeviceParms.init_PS_GAP ( c ), 'sk', 'MarkerFaceColor', [ 0.7, 0.7, 0.7 ] );
            else
                if ( Line == 'H' )
                    PS_c = ( UndConsts.Z_PS { p - UndConsts.cellOffset } - UndConsts.firstQuadz ) / UndConsts.CellLength + 0.98 + UndConsts.cellOffset;
                else
                    PS_c = ( UndConsts.Z_PS { p - DeviceParms.PS_CELL_NUM ( 1 ) + 1  } - UndConsts.firstQuadz ) / UndConsts.CellLength + 2.14 + UndConsts.cellOffset;
                end
      
                ftn { 1, 04 } = plot ( PS_c, DeviceParms.init_PS_GAP ( c ), 'sk', 'MarkerFaceColor', [ 0.7, 0.7, 0.7 ] );
            end            
        end
    end
    
    for c = 1 : length ( DeviceParms.PS_GAP )
        p = DeviceParms.PS_CELL_NUM ( c );     
        
        if ( DeviceParms.plotMode == const.plotgap )
            if ( DeviceParms.axisMode == const.zaxis )
                PS_z = DeviceParms.PSStart_z ( c );

                ftn { 1, 05 } = plot ( PS_z, DeviceParms.PS_GAP ( c ),   'sr' );
            else
                if ( Line == 'H' )
                    PS_c = ( UndConsts.Z_PS { p - UndConsts.cellOffset } - UndConsts.firstQuadz ) / UndConsts.CellLength + 0.98 + UndConsts.cellOffset;
                else
                    PS_c = ( UndConsts.Z_PS { p - DeviceParms.PS_CELL_NUM ( 1 ) + 1 } - UndConsts.firstQuadz ) / UndConsts.CellLength + 2.14 + UndConsts.cellOffset;
                end

                ftn { 1, 05 } = plot ( PS_c, DeviceParms.PS_GAP ( c ),   'sr' );
            end            
        end
    end
    
    drawnow;   
    [ ftn, plotHandles ] = plotDataPoints ( undulatorLine, DeviceParms, const, UndConsts, SplineData, T, ftn, 3, 6, 3, '-b', 'xb', [] );
end            
  
%xxx
dUNDgvalues                      = abs ( newgvalues - US_initgap ( isdesListMember_in_currentSegmentCells ) );
currentSegmentCellIndex          = 1 : DeviceParms.currentSegmentCellCount;

if ( ~PSconst )
    lastP                            = PSRead  ( undulatorLine );
    monitorPS_in_currentPSCell_Index = currentSegmentCellIndex ( ismember ( currentPSCells, monitorPS_List ) );
    dPHAgvalues                      = abs ( DeviceParms.PS_GAP ( monitorPS_in_currentPSCell_Index ) - lastP ( monitorPS_in_currentPSCell_Index, 4 )' )';
    timeLimit                        = max ( max ( dUNDgvalues ), max ( dPHAgvalues ) ) * 2.5 + 15;
else
    timeLimit                        = max ( dUNDgvalues )  * 2.5 + 15;
end

text1_handle = 0;
text2_handle = 0;
text3_handle = 0;

if ( useGapsPermit )
    if ( ~PSconst )
        desPScellList                                 = DeviceParms.PS_CELL_NUM;
%        isdesPSListMember_in_currentPSCells           = ismember ( currentPSCellList, desPSCellList );
    
        desPScellList      ( DeviceParms.PS_PI == 0 ) = [];
        DeviceParms.PS_GAP ( DeviceParms.PS_PI == 0 ) = [];
        DeviceParms.PS_PI  ( DeviceParms.PS_PI == 0 ) = [];

        % Instruct phase shifters to change their phase integrals to the new
        % values
        PSSet ( undulatorLine, desPScellList, DeviceParms.PS_PI, 'nowait' );
    end
    
    % Instruct the undulators to start moving their gaps    
    lcaPut ( G_PVs, 1 );

    if ( monitorMotion )
        startTime        = now;
        
        undMovingStarted = 0;
        maxabsdK         = 1;
        maxabsdPI        = 1;

        if ( Line == 'H' )
            Kprecision = 0.5 * min ( newKvalues ) * 2.3e-4;
        else
            Kprecision = 0.5 * min ( newKvalues ) * 3.0e-4;
        end
        
        if ( ~PSconst && max ( DeviceParms.PS_GAP ) < 30 )
            PIprecision = 0.6;
        else 
            PIprecision = 1.0;
        end
            
        currentSegmentCellIndex = 1 : DeviceParms.currentSegmentCellCount;
%        currentPSCellIndex      = 1 : DeviceParms.currentPSCellCount;

        monitorUndulatorList                             = intersect ( monitorUndulatorList, DeviceParms.currentSegmentCells );
        monitorUndulatorList_in_currentSegmentCell_Index = currentSegmentCellIndex ( ismember ( DeviceParms.currentSegmentCells, monitorUndulatorList ) );

        monitorUndulatorList_in_desList_Index            = currentSegmentCellIndex ( ismember ( desCellList, monitorUndulatorList ) );

        monitorPS_List                                   = intersect ( monitorPS_List, DeviceParms.currentSegmentCells );
%        monitorPS_in_currentSegmentCell_Index            = currentSegmentCellIndex ( ismember ( DeviceParms.currentSegmentCells, monitorPS_List ) );
        monitorPS_in_currentPSCell_Index                 = currentSegmentCellIndex ( ismember ( currentPSCells, monitorPS_List ) );

        moving = 1;
        
        while ( moving )
            pause ( monitorDelay );
            
            seconds                           = ( now - startTime ) * 24 * 3600;
            lastU                             = UndRead ( undulatorLine );            
            lastP                             = PSRead  ( undulatorLine );

            if ( makePlots )
                figure ( fig );
                [ ftn, plotHandles ]          = plotDataPoints ( undulatorLine, DeviceParms, const, UndConsts, SplineData, T, ftn, 3, 6, 3, '-b', 'xb', plotHandles );

                if ( saveMovie )
                    Frame = getframe ( gcf );
                    writeVideo ( videoFile, Frame );
                end
            end            
            
%            dK                                = newKvalues  - lastU ( monitorUndulatorList_in_currentSegmentCell_Index, 2 );
            dK                                = newKvalues ( monitorUndulatorList_in_desList_Index )  - lastU ( monitorUndulatorList_in_currentSegmentCell_Index, 2 );
            dPI                               = DeviceParms.PS_PI ( monitorPS_in_currentPSCell_Index ) - lastP ( monitorPS_in_currentPSCell_Index, 2 )';
            
            monitordK                         = dK;
            monitordPI                        = dPI;

            maxabsdK                          = max ( abs ( monitordK ) );
            maxabsdPI                         = max ( abs ( monitordPI ) );
            
            maxabsdKid                        = find ( abs ( monitordK )  == maxabsdK,  1 ); 
            maxabsdPIid                       = find ( abs ( monitordPI ) == maxabsdPI, 1 );

            maxabsdKcellNo                    = monitorUndulatorList ( maxabsdKid );            
            maxabsdPIcellNo                   = monitorPS_List ( maxabsdPIid )'; 

            if ( makePlots )
                fprintf ( repmat ( '\b', 1, 66 ) );
                textStr1                          = sprintf ( 'max |dK| %7.5f (%2.2d);',         maxabsdK,   maxabsdKcellNo );
                textStr2                          = sprintf ( 'max |dPI| %4.2f T^2mm^3 (%2.2d)', maxabsdPI , maxabsdPIcellNo );
                textStr3                          = sprintf ( 'dt=%5.1f s', seconds );
                fprintf ( '%s%s[%s]', textStr1, textStr2, textStr3 );
            
                figure ( fig );
                axes_handle = get ( gcf, 'CurrentAxes' );
                textPos1                          = estimatePosition ( -14, -10,  axis ( axes_handle ) );
                textPos2                          = estimatePosition ( 111, -10,  axis ( axes_handle ) );
                textPos3                          = estimatePosition (  99,   3,  axis ( axes_handle ) );
%                textStr                           = sprintf ( 'End Photon Energy:   %.1f eV', PhEnergyEnd );

                v = ver ( 'MATLAB' );
                
                if ( strcmp ( v.Release, '(R2012a)' ) )
                    if ( text1_handle )
                        delete ( text1_handle );
                    end

                    if ( text2_handle )
                        delete ( text2_handle );
                    end
            
                    if ( text3_handle )
                        delete ( text3_handle );
                    end

                    text1_handle                  = text ( textPos1 ( 1 ), textPos1 ( 2 ), textStr1, 'HorizontalAlignment', 'left',  'FontSize', 9, 'Parent', axes_handle );
                    text2_handle                  = text ( textPos2 ( 1 ), textPos2 ( 2 ), textStr2, 'HorizontalAlignment', 'right', 'FontSize', 9, 'Parent', axes_handle );
                    text3_handle                  = text ( textPos3 ( 1 ), textPos3 ( 2 ), textStr3, 'HorizontalAlignment', 'right', 'FontSize', 9, 'Parent', axes_handle );
                else                    
                    if ( ~isstruct( text1_handle ) )
                        text1_handle              = text ( textPos1 ( 1 ), textPos1 ( 2 ), textStr1, 'HorizontalAlignment', 'left',  'FontSize', 9, 'FontName', 'FixedWidth', 'Parent', axes_handle );
                    else
%                        text1_handle.String       = textStr1;
                        delete ( text1_handle );
                        text1_handle              = text ( textPos1 ( 1 ), textPos1 ( 2 ), textStr1, 'HorizontalAlignment', 'left',  'FontSize', 9, 'FontName', 'FixedWidth', 'Parent', axes_handle );
                    end
                    
                    if ( ~isstruct ( text2_handle ) )
                        text2_handle              = text ( textPos2 ( 1 ), textPos2 ( 2 ), textStr2, 'HorizontalAlignment', 'left',  'FontSize', 9, 'Parent', axes_handle );
                    else
                        text2_handle.String       = textStr2;
                    end
                    
                    if ( ~isstruct ( text3_handle ) )
                        text3_handle              = text ( textPos3 ( 1 ), textPos3 ( 2 ), textStr3, 'HorizontalAlignment', 'left',  'FontSize', 9, 'Parent', axes_handle );
                    else
                        text3_handle.String       = textStr3;
                    end
                    
                    text1_handle
                end
            end
            
            if ( seconds > 360 )
                break;
            end
            
            if ( Line == 'H' )
                movingGaps                    = lcaGetSmart ( M_PVs, 0, 'double' );
                moving                        = max ( movingGaps );
                GapStatus                     = getGapStatus ( I_PVs );
                allAtDest                     = min ( GapStatus );
            else
                movingGaps                    = SXRGapsMovingActive ( M_PVs );
                moving                        = max ( movingGaps );
                allAtDest                     = max ( SXRGapsMovingDone ( M_PVs ) );
            end

            if (  any ( desPScells ) )
                movingPhaseShifters           = ~lcaGetSmart ( MPS_PVs );
            else
                movingPhaseShifters           = 0;
            end
            
            PSmoving                          = max ( movingPhaseShifters );
            moving                            = max ( PSmoving, moving );
            allAtDest                         = min ( allAtDest, ~moving );
            
            if ( ~undMovingStarted && seconds > 20 )
                success                       = false;
                break;
            end
    
            if ( ~undMovingStarted && moving )
                undMovingStarted              = true;
            end
    
            if ( seconds > timeLimit )
                success                       = false;
                break;
            end
            
            if ( undMovingStarted && allAtDest && ( maxabsdK > Kprecision || maxabsdPI > PIprecision ))
                success                       = false;
                break;
            end
        end

        seconds                               = ( now - startTime ) * 24 * 3600;
        
        fprintf ( repmat ( '\b', 1, 66 ) );
        
        if ( success )
            fprintf ( 'Target K (dK=%.5f) and PI (dPI=%.2f T^2mm^3) values were reached in %.1f seconds.      \n',     maxabsdK, maxabsdPI, seconds );
        else
            fprintf ( 'Target K (dK=%.5f) and PI (dPI=%.2f T^2mm^3) values were NOT reached in %.1f seconds.      \n', maxabsdK, maxabsdPI, seconds );
            fprintf ( 'dK/Ktol = %.1f dPI/PItol = %.1f\n', maxabsdK / Kprecision, maxabsdPI / PIprecision );
        end
    
        % save data
        
        if ( saveData )
            fn_USEG  = sprintf ( '%s_UndSet_test_USEG.txt', undulatorLine );
            fn_PHAS  = sprintf ( '%s_UndSet_test_PHAS.txt', undulatorLine );
            fid_USEG = fopen ( fn_USEG, 'a' );
            fid_PHAS = fopen ( fn_PHAS, 'a' );

            if ( ~fid_USEG )
                error ( 'unable to save USEG data' );
            end
    
            if ( ~fid_PHAS )
                error ( 'unable to save PHAS data' );
            end
            
            for c = 1 : desPScells
                cel = desCellList ( c );
    
                fprintf ( fid_USEG, '%s;cell %2.2d;Kreq:%7.5f;Kstart:%7.5f;Kend:%7.5f;Kerr:%+7.5f;gstart:%7.5f mm;gend:%7.5f mm;(%.1f s)\n', datestr ( now(), 'mm/dd/yyyy HH:MM' ), cel, newKvalues ( c ), initU ( c, 2 ), lastU ( c, 2 ), lastU ( c, 2 ) - newKvalues ( c ), initU ( c, 4 ), lastU ( c, 4 ), seconds ); 
            end

            if ( ~PSconst )
                for c = 1 : length ( DeviceParms.PS_GAP )
                    cel = DeviceParms.PS_CELL_NUM ( c );
    
                    fprintf ( fid_PHAS, '%s;cell %2.2d;PIreq:%6.1f T^2mm^3;PIstart:%6.1f T^2mm^3;PIend:%6.1f T^2mm^3;PIerr:%+5.2f T^2mm^3;gstart:%7.5f mm;gend:%7.5f mm;(%.1f s)\n', datestr ( now(), 'mm/dd/yyyy HH:MM' ), cel, DeviceParms.PS_PI ( c ), initP ( c, 2 ), lastP ( c, 2 ), lastP ( c, 2 ) - DeviceParms.PS_PI ( c ), initP ( c, 4 ), lastP ( c, 4 ), seconds ); 
                end
            end
            
            fclose ( fid_USEG );
            fclose ( fid_PHAS );

            fprintf ( 'Saved data in %s\n', fn_USEG );
            fprintf ( 'Saved data in %s\n', fn_PHAS );
        end
    end
    
    if ( Line == 'S' )
        centered = lcaGet ( CenterStatus_PVs, 0, 'double' );
        
        if ( any ( ~centered ) )
%            USVAct          = lcaGet ( USVAct_PVs, 0, 'double' );
%            DSVAct          = lcaGet ( DSVAct_PVs, 0, 'double' );

%            if ( any ( ~USVAct ) || any ( ~DSVAct ) )
%                pause ( 1.0 );
%            end

%            lcaPut ( Center_PVs, 1 ); % Recenter undulators on vacuum chamber, if necessary.
        end
    end

else
    fprintf ( 'No gap move occured because switch ''useGapsPermit'' is set ''false''\n' );
end

if ( updateCoffsets && Line == 'H' )
    fprintf ( 'Updating RFBPM .C offsets.\n' );
    
    Csplines   = getHXR_BPMpos_vs_gap;   
    lastU      = UndRead ( undulatorLine );
    USEG_cells = lastU ( isdesListMember_in_currentSegmentCells, 1 )';
    USEG_gaps  = lastU ( isdesListMember_in_currentSegmentCells, 4 );
    gapCount   = length ( USEG_gaps ); 

    Xvalues    = zeros (gapCount, 1 );
    Yvalues    = zeros ( gapCount, 1 );
        
    for j = 1 : gapCount
        g             = USEG_gaps ( j );
        
        Xg            = Csplines.X ( :, 1 );
        XC            = Csplines.X ( :, 2 );
        Yg            = Csplines.Y ( :, 1 );
        YC            = Csplines.Y ( :, 2 );
        
        Xvalues ( j ) = spline ( Xg, XC, g );
        Yvalues ( j ) = spline ( Yg, YC, g );
    end
    
    setRFBPMoffsets ( undulatorLine, USEG_cells, 'X', 'C', Xvalues );
    setRFBPMoffsets ( undulatorLine, USEG_cells, 'Y', 'C', Yvalues );
end

if ( updateCorrs )
% update correctors;
    fprintf ( 'Updating Correctors:\n' );
    tic

    lastU                = UndRead ( undulatorLine );
    lastP                = PSRead  ( undulatorLine );

    USEG_gap             = lastU ( isdesListMember_in_currentSegmentCells, 4 );
    PHAS_gap             = lastP ( : , 4 );
        
    URgap                = 100; % mm; undulator BBA gap
    PRgap                = 100; % mm; phase shifter BBA gap

    Correctors           = { 'XCOR', 'YCOR' };
    movableQuadCellCount = length ( UndConsts.movableQuadCells );
        
    sumPV                = cell  ( 2 * movableQuadCellCount, 1 );
    sumBL                = zeros ( 2 * movableQuadCellCount, 1 );

    for c = 1 : 2
        Cor              = Correctors { c };
    
        for j = 1 : movableQuadCellCount
            pos          = ( c - 1 ) * movableQuadCellCount + j;
            cellNo       = UndConsts.movableQuadCells ( j );
            corrData     = UndQuadCorrData.( undulatorLine ).( Cor ) { cellNo };
            
            if ( ~isempty ( corrData ) )                
                for k = 1 : 4
                    if ( isfield ( corrData, (char ( 64 + k ) ) ) )
                        data          = corrData.( char ( 64 + k ) );
                        cellIdx       = find ( desCellList == data.srcCell );
                    
                        if ( isempty ( cellIdx ) )
                            sumBL ( pos ) = NaN;
                            break;
                        end
                    
                        PV            = data.PV;
                        sumPV { pos } = PV ( 1 : end - 2 );

                        if ( strcmp ( data.srcDev, 'USEG' ) )
                            Ugap          = USEG_gap ( cellIdx );
                            sumBL ( pos ) = sumBL ( pos ) ...
                                        + spline ( data.gap, data.BL, Ugap ) ...
                                        - spline ( data.gap, data.BL, URgap );
%                                        + spline ( data.gap, data.BL, Ugap );
                        else                        
                            Pgap          = PHAS_gap ( cellIdx );
                            sumBL ( pos ) = sumBL ( pos ) ...
                                        + spline ( data.gap, data.BL, Pgap ) ...
                                        - spline ( data.gap, data.BL, PRgap );
%                                        + spline ( data.gap, data.BL, Pgap );
                        end
                    end
                end
            else
                sumBL ( pos ) = NaN;
            end
        end
    end

    index   = find ( ~isnan ( sumBL ) );
    entries = length ( index );

    PVs   = cell  ( entries, 1 );
    BLs   = zeros ( entries, 1 );

    for k = 1 : entries
        j = index ( k );
        PVs { k } = sumPV { j };
%        BLs ( k ) = sumBL ( j );
        BLs ( k ) = sumBL ( j ) * 0; % Removed for first beam through the undulator line, because correction already done by quad moves. Need to be reactivated after BBA.
    end

    success = true;

    try
        lcaPutSmart ( PVs, BLs );
    catch ME
        success = false;
        MSG     = ME.identifier;
        Stack   = ME.stack;
    end

    if ( ~success )
        display ( Stack );
        fprintf ( 'Unable to set corrector coefficients (%s).\n', MSG );
    else
        actBLs = lcaGetSmart ( PVs );
    
        for k = 1 : entries
            fprintf ( '%s: %+6.1f (%+6.1f)\n', PVs { k }, actBLs ( k ) * 10^5, ( actBLs ( k ) - BLs ( k ) ) * 10^5 );
        end
    end
    
    toc
end

% Update EFCs

if ( updateEFCs )
    fprintf ( 'Updating EFCs:\n' );

    tic

%    if ( Line == 'H' )
        activeCellList = lastU ( isdesListMember_in_currentSegmentCells, 1 );
        activeGapList  = lastU ( isdesListMember_in_currentSegmentCells, 4 );
        [ dI1, dI2 ] = setPipeCorrectionCurrents ( undulatorLine, activeCellList, activeGapList );

        if ( max ( abs ( dI1 ) ) > 0.001 || max ( abs ( dI2 ) ) > 0.001 )
            display ( '     cells     gaps      dI1       dI2' );
            display ( [ activeCellList activeGapList dI1 dI2 ] );
            fprintf ( 'EFCs did not reach requested values.\n' );
        end
%    else
%        fprintf ( 'Pipe correction data is currently not available for the SXR line.\n' );
%    end

    toc
end
%

if ( makePlots )
    figure ( fig );
    
    [ ftn, ~ ] = plotDataPoints ( undulatorLine, DeviceParms, const, UndConsts, SplineData, T, ftn, 3, 6, 3, '-b', 'xb', plotHandles );

    if ( saveMovie )
        Frame = getframe ( gcf );
        writeVideo ( videoFile, Frame );
    end

    % post plot legend
    legendElements = 0;

    for p = 1 : ftns
        if ( ~isempty ( ftn { 1, p } ) )
            legendElements = legendElements + 1;
        end
    end
    
    legendPlot = zeros ( 1, legendElements );
    legendText = cell  ( 1, legendElements );

    nEl = 0;

    for p = 1 : ftns
        if ( ~isempty ( ftn { 1, p } ) )
            nEl = nEl + 1;
            legendPlot ( nEl ) = ftn { 1, p };
            legendText { nEl } = ftn { 2, p };
        end
    end

    legend ( legendPlot, legendText, 'Location', 'best', 'FontSize', 7 );
    
    hold off;
    
    if ( printTo_e_Log )
        util_printLog_wComments(gcf,'Nuhn',Comment,command);

        fprintf ( 'sent plots to physics-lclslog.\n' );
    else
        fprintf ( 'Not sending plots to physics-lclslog.\n' );
    end

    if ( fig_to_Files )
        print ( fig, '-dpdf',  '-r300', figName ); 
        print ( fig, '-djpeg', '-r300', figName ); 
            
        fprintf ( 'Sent figure to files %s (.pdf, .jpg).\n', figName );
    else
        fprintf ( 'Not sending plots to file.\n' );
    end
    
    if ( saveMovie )
        close ( videoFile );
        
        fprintf (  'Saved movie to "%s".\n', videoFileName );
    else
        fprintf (  'Did not save movie.\n' );
    end
end

end


function status = getGapStatus ( I_PVs )

n = length ( I_PVs );

I = lcaGet ( I_PVs );

status = zeros ( 1, n );

for g = 1 : n
    if ( strcmp ( I { g }, 'Device At Destination' ) )
        status ( g ) = 1;
    else
        status ( g ) = 0;
    end    
end

end


function status = SXRGapsMovingDone ( M_PVs )

n = length ( M_PVs );

M = lcaGet ( M_PVs );

movingDone = zeros ( 1, n );

for g = 1 : n
    if ( strcmp ( M { g }, 'Done Moving' ) )
        movingDone ( g ) = 1;
    else
        movingDone ( g ) = 0;
    end
end

status = max ( movingDone );

end


function status = SXRGapsMovingActive ( M_PVs )

n = length ( M_PVs );

M = lcaGet ( M_PVs );

movingGaps = zeros ( 1, n );

for g = 1 : n
    if ( strcmp ( M { g }, 'Moving' ) )
        movingGaps ( g ) = 1;
    else
        movingGaps ( g ) = 0;
    end
end

status = max ( movingGaps );

end


function g = K_to_gap ( j, D, K_tunnel, T )

dT       = T.mean ( j ) - T.MMF ( j );
C        = 1 + T.Kcoeff ( j ) * dT;
K_MMF    = K_tunnel / C;
spline_K = D { j }.K_vs_gap.K;
spline_g = D { j }.K_vs_gap.gap;

if ( K_MMF > max ( spline_K ) )
    K_MMF = max ( spline_K ) * ( 1 - 0.00001 );
end

if ( K_MMF < min ( spline_K ) )
    K_MMF = min ( spline_K ) * ( 1 + 0.00001 );
end

g        = spline (spline_K, spline_g, K_MMF );    

end


function K_tunnel = gap_to_K ( j, D, g, T )

spline_K = D { j }.K_vs_gap.K;
spline_g = D { j }.K_vs_gap.gap;

if ( g > max ( spline_g ) )
   g = max ( spline_g ) * ( 1 - 0.00001 );
end

if ( g < min ( spline_g ) )
   g = min ( spline_g ) * ( 1 + 0.00001 );
end

K_MMF    = spline ( spline_g, spline_K, g );    
dT       = T.mean ( j ) - T.MMF ( j );
C        = 1 + T.Kcoeff ( j ) * dT;
K_tunnel = K_MMF * C;

end


function [ ftn, plotHandles ] = plotDataPoints ( undulatorLine, DeviceParms, const, UndConsts, SplineData, T, ftn, a, b, c, lineUnd, linePS, plotHandles )

undulatorLine                  = upper ( undulatorLine );
Line                           = undulatorLine ( 1 );
lastU                          = UndRead ( undulatorLine );
    
% This plot will not work if an undulator gap is above 100 mm. The
% actual current data are therefore reset to that limit make the function
% work. 
for p = 1 : length ( lastU ( :, 2 ) )
    if ( lastU ( p, 4 ) > 100.0 )
        lastU ( p, 4 ) = 100.0;
        lastU ( p, 2 ) = gap_to_K ( p, SplineData.USEG, 100.0, T );
    end
end

US_lastK                       = lastU ( :, 2 );
US_lastgap                     = lastU ( :, 4 );
lasttaper                      = lastU ( :, 6 );
DS_lastgap                     = US_lastgap + lasttaper;
DS_lastK                       = zeros ( DeviceParms.currentSegmentCellCount, 1 );

plotsCount                     = 0;

if ( DeviceParms.plotMode == const.plotgap )
    lastP                   = PSRead ( undulatorLine );
    DeviceParms.last_PS_GAP = lastP ( :, 4 );
end
    
if ( ~isfield ( plotHandles, 'count' ) )
    if ( DeviceParms.plotMode == const.plotgap )
        plotHandles.count = DeviceParms.currentSegmentCellCount + length ( DeviceParms.PS_GAP );
    else
        plotHandles.count = DeviceParms.currentSegmentCellCount;
    end
    
    plotHandles.h         = zeros ( 1, plotHandles.count );
else
    for j = 1 : plotHandles.count
        delete ( plotHandles.h ( j ) );
    end
end

for p = 1 : DeviceParms.currentSegmentCellCount
    DS_lastK ( p )         = gap_to_K ( p, SplineData.USEG, DS_lastgap ( p ), T );
end    

%xx = [ US_lastgap US_lastK lasttaper DS_lastgap DS_lastK ];
%xx

if ( DeviceParms.axisMode == const.zaxis )
    Ax = DeviceParms.UndStart_z;
    Bx = DeviceParms.UndEnd_z;
else
    Ax = DeviceParms.UndStart_c;
    Bx = DeviceParms.UndEnd_c;
end
        
if ( DeviceParms.plotMode == const.plotK )
    Ay = US_lastK;
    By = DS_lastK;

    ftn { 2, c } = 'final USEG K';
else
    Ay = US_lastgap;
    By = DS_lastgap;

    ftn { 2, c } = 'final USEG gap';
end

for p = 1 : DeviceParms.currentSegmentCellCount        
    plotsCount                   = plotsCount + 1;  
    plotHandles.h ( plotsCount ) = plot ( [ Ax(p) Bx(p) ], [ Ay(p) By(p) ], lineUnd );
end

ftn { 1, a } = plotHandles.h ( plotsCount );

for c = 1 : length ( DeviceParms.PS_GAP )
    p = DeviceParms.PS_CELL_NUM ( c );     
        
    if ( DeviceParms.plotMode == const.plotgap )
        plotsCount = plotsCount + 1;
        
        if ( DeviceParms.axisMode == const.zaxis )
            PS_z = DeviceParms.PSStart_z ( c );

            plotHandles.h ( plotsCount ) = plot ( PS_z, DeviceParms.last_PS_GAP ( c ),   linePS );
        else
            if ( Line == 'H' )
                PS_c = ( UndConsts.Z_PS { p - UndConsts.cellOffset } - UndConsts.firstQuadz ) / UndConsts.CellLength + 0.98 + UndConsts.cellOffset;
            else
                PS_c = ( UndConsts.Z_PS { p - DeviceParms.PS_CELL_NUM ( 1 ) + 1 } - UndConsts.firstQuadz ) / UndConsts.CellLength + 2.14 + UndConsts.cellOffset;
            end

            plotHandles.h ( plotsCount ) = plot ( PS_c, DeviceParms.last_PS_GAP ( c ),   linePS );
        end        
    end
    
    ftn { 1, b } = plotHandles.h ( plotsCount );
end

end 


function pos = estimatePosition ( pctX, pctY, frame )

X0 = frame ( 1 );
Y0 = frame ( 3 );
W  = frame ( 2 ) - frame ( 1 );
H  = frame ( 4 ) - frame ( 3 );

X = X0 + W * pctX / 100;
Y = Y0 + H * pctY / 100;

pos = [ X, Y ];

end


function s = parseVarArgs ( args, const )

validParameters = { 'printTo_e_Log', 'Comment',       'plotMode', ...
                    'axisMode',      'fig_to_files' , 'saveMovie', ...
                    'saveData',      'useGapsPermit', 'PSfiles' };

n = length ( args );

if ( ~n )
    s = [];
    return;
end

if ( floor ( n / 2 ) * 2 ~= n )
    error ( 'There needs to be an even number of optional arguments' );
end

for i = 1 : 2 : n
    name  = cell2mat ( args ( i ) );
    value = cell2mat ( args ( i + 1 ) );
    
    switch name        
        case 'printTo_e_Log'
            if ( ~isnumeric ( value ) && ~ islogical ( value ) )
                error ( 'Value for parameter ''%s'' must be true or false.', name );                
            else
               if ( value )
                   s.printTo_e_Log = true;
               else
                   s.printTo_e_Log = false;
               end
            end
        case 'Comment'
            s.Comment = value;
        case 'axisMode'
            if ( strcmp ( value, 'c' )  )
                s.axisMode = const.caxis;
            elseif ( strcmp ( value, 'z' )  )
                s.axisMode = const.zaxis;
            else
                error ( 'Value for parameter ''%s'' must be ''c'' or ''z''.', name );                
           end
        case 'plotMode'
            if ( strcmp ( value, 'gap' )  )
                s.plotMode = const.plotgap;
            elseif ( strcmp ( value, 'K' )  )
                s.plotMode = const.plotK;
            else
                error ( 'Value for parameter ''%s'' must be ''gap'' or ''K''.', name );                
           end
        case 'fig_to_Files'
            if ( ~isnumeric ( value ) && ~ islogical ( value ) )
                error ( 'Value for parameter ''%s'' must be true or false.', name );                
            else
               if ( value )
                   s.fig_to_Files = true;
               else
                   s.fig_to_Files = false;
               end
            end
        case 'saveMovie'
            if ( ~isnumeric ( value ) && ~ islogical ( value ) )
                error ( 'Value for parameter ''%s'' must be true or false.', name );                
            else
               if ( value )
                   s.saveMovie = true;
               else
                   s.saveMovie = false;
               end
            end
        case 'saveData'
            if ( ~isnumeric ( value ) && ~ islogical ( value ) )
                error ( 'Value for parameter ''%s'' must be true or false.', name );                
            else
               if ( value )
                   s.saveData = true;
               else
                   s.saveData = false;
               end
            end
        case 'useGapsPermit'
            if ( ~isnumeric ( value ) && ~ islogical ( value ) )
                error ( 'Value for parameter ''%s'' must be true or false.', name );                
            else
               if ( value )
                   s.useGapsPermit = true;
               else
                   s.useGapsPermit = false;
               end
            end
        case 'PSfiles'
            s.PSfiles = value;
        case 'PSconst'
            if ( ~isnumeric ( value ) && ~ islogical ( value ) )
                error ( 'Value for parameter ''%s'' must be true or false.', name );                
            else
               if ( value )
                   s.PSconst = true;
               else
                   s.PSconst = false;
               end
            end
        otherwise
            display ( validParameters );
            error ( 'Parameter ''%s'' is not valid.', name );
    end
end

end