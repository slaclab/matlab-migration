function new_result = scanBFW_8figs ( slot, wire, startPos, finalPos, stepSize, varargin )
% scanBFW_8figs is a Matlab function for
%   scanning one of the 66 BFW wires in the undulator system
%   while generating a correlation plot to one of the beam loss
%   detectors.
%   Input units are interpreted as microns !

clear result;

global result;
global abortRequest;
global PhyConsts;

result.success         = false;
new_result             = result;

result.motionPermit    = false;
result.BYKIKPermit     = false;
result.WireCardPermit  = false;
result.alignBFW        = false;
result.savingPlots     = true;
result.savingMat       = true;
result.savingReport    = true;
result.printTo_e_Log   = false;

result.ignoreCharge    = true;
result.useTrajectory   = false;

abortRequest           = false;
result.reportStatus    = false;

result.BYKIKenabled    = 0;
result.CardIn          = 0;
result.scanPos         = NaN;

result.BYKIKwait       = 0.2;
result.Cardwait        = 3;
result.chargewait      = 5;
result.trajectorywait  = 2;

result.GUIfig          = gcf;
result.PLTfig          = 2;

result.chargePV        = 'BPMS:UND1:190:TMIT';
PhyConsts              = util_PhysicsConstants;
result.fp              = '/home/physics/nuhn/wrk/matlab/iocsim/'; % File path for output files.
result.BeamEnergyPV    = 'BEND:DMP1:400:BACT';
result.BeamEnergy      = lcaGet ( result.BeamEnergyPV );    % GeV
result.BYKIKenabled    = beamEnabled;
result.scanPos         = NaN;

result.scopeDelay      = 0; % s; 0 implies polling for the end of previous data taking
result.scopeAverages   = 5; % number of averages
result.plotRows        = 2;
result.plotCols        = 4;
result.plots           = result.plotRows * result.plotCols;
result.relW            = 0.5; % window width in terms of screen width
result.pltR            = [ 2, 2, 2, 2, 1, 1, 1, 1 ];
result.pltC            = [ 1, 2, 3, 4, 1, 2, 3, 4 ];

result.ylabelText      = cell  ( 1, result.plots );
result.scopePV         = cell  ( result.plots, 1 );
result.scopeChannel    = zeros ( result.plots, 1 );


result.inputSources   = {  ...
                          1,  1, 1, 'SCOP:UND1:BLF1',       'scope PEP-BLM01';        ...
                          1,  1, 2, 'SCOP:UND1:BLF1',       'scope ANL-BLM01';        ...
                          1,  1, 3, 'SCOP:UND1:BLF1',       'scope PEP-BLM09';        ...
                          1,  1, 4, 'SCOP:UND1:BLF1',       'scope ANL-BLM09';        ...
                          1,  2, 1, 'SCOP:UND1:BLF2',       'scope PEP-BLM17';        ...
                          1,  2, 2, 'SCOP:UND1:BLF2',       'scope PEP-BLM25';        ...
                          1,  2, 3, 'SCOP:UND1:BLF2',       'scope ANL-BLM25';        ...
                          1,  2, 4, 'SCOP:UND1:BLF2',       'scope ANL-BLM33';        ...
                          1,  3, 1, 'UBLF:UND1:500:BLF1',   'US-BTH';           ...
                          1,  3, 2, 'UBLF:UND1:500:BLF1',   'UD-BTH';           ...
                          1,  3, 3, 'UBLF:UND1:500:BLF1',   'U01-U16';          ...
                          1,  3, 4, 'UBLF:UND1:500:BLF1',   'U17-U33';          ...
                          1,  4, 1, 'PMT:DMP1:430:QDCRAW',  'DMP Cerenkov';     ...
                          1,  5, 1, 'PMT:DMP1:431:QDCRAW',  'DMP Scintillator'; ...
                          1,  6, 1, 'PMT:LTU1:715:QDCRAW',  'LTUus BLF integr'; ...  % Integrated BLF Upstream LTU
                          1,  7, 1, 'PMT:LTU1:715:QDCRAW',  'LTUds BLF integr'; ...  % Integrated BLF Upstream LTU
                          1,  8, 1, 'PMT:LTU1:755:QDCRAW'   'U01-U16 integr';   ...   
                          1,  9, 1, 'PMT:LTU1:970:QDCRAW',  'U17-U33 integr';   ...  % Integrated BLF Upstream Undulator
                          2,  0, 0, 'BLM:UND1:120:LOSS_1',  'ANL-BLM01';        ...
                          2,  0, 0, 'BLM:UND1:920:LOSS_1',  'ANL-BLM09';        ...
                          2,  0, 0, 'BLM:UND1:1720:LOSS_1', 'ANL-BLM17';        ...
                          2,  0, 0, 'BLM:UND1:2520:LOSS_1', 'ANL-BLM25';        ...
                          2,  0, 0, 'BLM:UND1:3320:LOSS_1', 'ANL-BLM33';        ...
                          2,  0, 0, 'BLM:UND1:121:LOSS_1',  'PEP-BLM01';        ...
                          2,  0, 0, 'BLM:UND1:221:LOSS_1',  'PEP-BLM02';        ...
                          2,  0, 0, 'BLM:UND1:321:LOSS_1',  'PEP-BLM03';        ...
                          2,  0, 0, 'BLM:UND1:421:LOSS_1',  'PEP-BLM04';        ...
                          2,  0, 0, 'BLM:UND1:521:LOSS_1',  'PEP-BLM05';        ...
                          2,  0, 0, 'BLM:UND1:621:LOSS_1',  'ANL-BLM06';        ...
                          2,  0, 0, 'BLM:UND1:721:LOSS_1',  'ANL-BLM07';        ...
                          2,  0, 0, 'BLM:UND1:821:LOSS_1',  'ANL-BLM08';        ...
                          2,  0, 0, 'BLM:UND1:921:LOSS_1',  'PEP-BLM09';        ...
                          2,  0, 0, 'BLM:UND1:1021:LOSS_1', 'ANL-BLM10';        ...
                          2,  0, 0, 'BLM:UND1:1121:LOSS_1', 'ANL-BLM11';        ...
                          2,  0, 0, 'BLM:UND1:1221:LOSS_1', 'ANL-BLM12';        ...
                          2,  0, 0, 'BLM:UND1:1321:LOSS_1', 'ANL-BLM13';        ...
                          2,  0, 0, 'BLM:UND1:1421:LOSS_1', 'ANL-BLM14';        ...
                          2,  0, 0, 'BLM:UND1:1521:LOSS_1', 'ANL-BLM15';        ...
                          2,  0, 0, 'BLM:UND1:1621:LOSS_1', 'ANL-BLM16';        ...
                          2,  0, 0, 'BLM:UND1:1721:LOSS_1', 'PEP-BLM17';        ...
                          2,  0, 0, 'BLM:UND1:1821:LOSS_1', 'ANL-BLM18';        ...
                          2,  0, 0, 'BLM:UND1:1921:LOSS_1', 'ANL-BLM19';        ...
                          2,  0, 0, 'BLM:UND1:2021:LOSS_1', 'ANL-BLM20';        ...
                          2,  0, 0, 'BLM:UND1:2121:LOSS_1', 'ANL-BLM21';        ...
                          2,  0, 0, 'BLM:UND1:2221:LOSS_1', 'ANL-BLM22';        ...
                          2,  0, 0, 'BLM:UND1:2321:LOSS_1', 'ANL-BLM23';        ...
                          2,  0, 0, 'BLM:UND1:2421:LOSS_1', 'ANL-BLM24';        ...
                          2,  0, 0, 'BLM:UND1:2521:LOSS_1', 'PEP-BLM25';        ...
                          2,  0, 0, 'BLM:UND1:2621:LOSS_1', 'ANL-BLM26';        ...
                          2,  0, 0, 'BLM:UND1:2721:LOSS_1', 'ANL-BLM27';        ...
                          2,  0, 0, 'BLM:UND1:2821:LOSS_1', 'ANL-BLM28';        ...
                          2,  0, 0, 'BLM:UND1:2921:LOSS_1', 'ANL-BLM29';        ...
                          2,  0, 0, 'BLM:UND1:3021:LOSS_1', 'ANL-BLM30';        ...
                          2,  0, 0, 'BLM:UND1:3121:LOSS_1', 'ANL-BLM31';        ...
                          2,  0, 0, 'BLM:UND1:3221:LOSS_1', 'ANL-BLM32';        ...
                          2,  0, 0, 'BLM:UND1:3321:LOSS_1', 'PEP-BLM33';        ...
                              };

%result.monitorSources  = { ...
%                           'ANL-BLM26'; ...
%                           'ANL-BLM27'; ...
%                           'ANL-BLM28'; ...
%                           'ANL-BLM29'; ...
%                           'ANL-BLM30'; ...
%                           'ANL-BLM31'; ...
%                           'ANL-BLM32'; ...
%                           'ANL-BLM33'; ...
%                           };

 result.monitorSources  = { ...
                            'ANL-BLM11';        ...
                            'ANL-BLM15';        ...
                            'ANL-BLM20';          ...
                            'PEP-BLM33';          ...
                            'DMP Cerenkov';     ...
                            'DMP Scintillator'; ...
                            'ANL-BLM25';   ...
                            'ANL-BLM33';   ...
                            };

if ( length ( result.monitorSources ) ~= result.plots )
     error ( 'Insufficient number of monitor sources.' );
end
                       
result.monitorChannels = zeros ( result.plots, result.plotRows ); 

result.inputSRCcount   = length ( result.inputSources );

result.scopePVs        = cell ( 1, result.plots );
result.scopeSource     = cell ( result.plots, 4 );

for j = 1 : result.plots
    for k = 1 : 4
        result.scopeSource { j, k } = '-';
    end
end

for j = 1 : result.inputSRCcount
    if ( result.inputSources { j, 1 } == 1 )
        result.scopeSource { result.inputSources { j, 2 }, result.inputSources { j, 3 } } = result.inputSources { j, 5 }; 
        result.scopePVs { result.inputSources { j, 2 } } = result.inputSources { j, 4 }; 
    end
end

for j = 1 : result.plots
    monitorSource = '';
    
    for k = 1 : result.inputSRCcount
        if ( strcmp ( result.monitorSources { j }, result.inputSources { k, 5 } ) )
            fprintf ( '"%s" for "%s" (%d)\n', result.monitorSources { j }, result.inputSources { k, 5 }, k  );
            monitorSource = result.inputSources { k, 5 };

            result.monitorChannels ( j, 1 ) = result.inputSources { k, 2 };
            result.monitorChannels ( j, 2 ) = result.inputSources { k, 3 };

            result.scopeID      ( j ) = result.inputSources    { k, 2 };
            result.scopeChannel ( j ) = result.inputSources    { k, 3 };    
            result.scopePV      { j } = result.inputSources    { k, 4 };

            continue;
        end
    end

    if ( isempty ( monitorSource ) )
        error ( 'monitor source %s not found.', result.monitorSources { j } );
    end    
end

%result.monitorChannels = [ 2, 3; 2, 4; 3, 3; 3, 4; ...
%                           4, 1; 5, 1; 8, 1; 9, 1 ];
%
%result.scopePVs        = { ...
%                           'SCOP:UND1:BLF1', ...
%                           'SCOP:UND1:BLF2' ...
%                           'UBLF:UND1:500:BLF1', ...
%                           'PMT:DMP1:430:QDCRAW', ...
%                           'PMT:DMP1:431:QDCRAW', ...
%                           'PMT:LTU1:715:QDCRAW', ...  % Integrated BLF Upstream LTU
%                           'PMT:LTU1:755:QDCRAW' ...   
%                result.useTrajectory   = false;
           'PMT:LTU1:970:QDCRAW', ...  % Integrated BLF Upstream Undulator
%                           'PMT:UND1:1690:QDCRAW' ...   
%                              };
%result.scopeSource     = { ...
%                         { 'PEP-BLM01',        'ANL-BLM01', 'PEP-BLM09', 'ANL-BLM09' }, ...
%                         { 'PEP-BLM17',        'PEP-BLM25', 'ANL-BLM25', 'ANL-BLM33' }, ...
%                         { 'US-BTH',           'DS-BTH',    'U01-U16',   'U17-U33'   }, ...
%                         { 'DMP Cerenkov',     '-',         '-',         '-'         }, ...
%                         { 'DMP Scintillator', '-',         '-',         '-'         }, ...
%                         { 'LTUus BLF integr', '-',         '-',         '-'         }, ...
%                         { 'LTUds BLF integr', '-',         '-',         '-'         }, ...
%                         { 'U01-U16 itegr',    '-',         '-',         '-'         }, ...
%                         { 'U17-U33 itegr',    '-',         '-',         '-'         }  ...
%                         };

result.refDetectors    = { 'DMP Cerenkov', 'DMP Scintillator' };
result.ChargeThreshold = 0.100; % nC
result.pathTol         = 150;  % microns maximum acceptable trajectory rms value.
result.hitTol          =  20;  % microns
result.clearOtherBy    = 100;  % microns; Amount by which to move the non-scanned wire away
                               % from the beam (more negative) in order to avoid interference.
result.slots           = 33;
result.bpms            = result.slots + 1;
dateString             = sprintf ( '%s', datestr ( now, 'yyyy-mm-dd-HHMM' ) );
result.date            = dateString;
result.axesNames       = { 'X', 'Y' };

result.RFBPM.averages  = 10;
result.RFBPM.PV        = cell  ( 2, result.bpms );
result.RFBPM.Nm        = cell  ( 2, result.bpms );
result.RFBPM.EU        = cell  ( 2, result.bpms );

result.SliderPosPV     = cell  ( 1, result.slots );
result.SliderPos       = zeros ( 1, result.slots );

for k = 1 : result.slots
    result.SliderPosPV { k } = sprintf ( 'USEG:UND1:%d50:TMXPOSC', k );
end

result.SliderPos   ( slot ) = lcaGet ( result.SliderPosPV { slot } );

geo                    = girderGeo;
 
for xy = 1 : 2
    result.RFBPM.PV { xy, 1 }  = sprintf ( 'BPMS:UND1:100:%s', result.axesNames { xy } );
    result.RFBPM.Nm { xy, 1 }  = sprintf ( 'RFU00_%s',         result.axesNames { xy } );
    result.RFBPM.EU { xy, 1 }  = 'mm';
end
    
for b = 2 : result.bpms
    for xy = 1 : 2
        result.RFBPM.PV { xy, b }  = sprintf ( 'BPMS:UND1:%d90:%s', b - 1, result.axesNames { xy } );
        result.RFBPM.Nm { xy, b }  = sprintf ( 'RFU%2.2d_%s',       b - 1, result.axesNames { xy } );
        result.RFBPM.EU { xy, b }  = 'mm';
    end
end

if ( slot < 1 || slot > result.slots )
    error ( 'slot number (%2.dd) out of range', slot );
end

if ( ~ischar ( wire ) )
    error ( 'wire variable needs to be "x" or "y"' );
end

result.maxRange =  1500;
result.minRange = -1500;
wire             = lowcase ( wire );

if ( strcmp ( wire, 'x' ) )
    result.xy = 1;
elseif ( strcmp ( wire, 'y' ) )
    result.xy = 2;
else
    error ( 'wire variable needs to be "x" or "y"' );
end

if ( startPos < result.minRange || startPos > result.maxRange )
    error ( 'startPos out of range [%f,%f].', result.minRange, result.maxRange );
end

if ( finalPos < result.minRange || finalPos > result.maxRange )
    error ( 'finalPos out of range [%f,%f].', result.minRange, result.maxRange );
end

if ( startPos >= finalPos  )
    error ( 'finalPos must be larger than startPos.' );
end

movingRange = finalPos - startPos;

if ( stepSize > movingRange  )
    error ( 'stepSize needs to be smaller than the moving range.' );
end

result.slot       = slot;
result.wire       = wire;
result.finalPos   = finalPos;
result.startPos   = startPos;
result.stepSize   = stepSize;

if ( nargin > 6 && strcmp ( varargin { 1 }, 'reportStatus' ) )
    result.handles        = varargin { 2 };
    result.reportStatus   = true;
    getSwitches
end

result.wireCardPV = sprintf ( 'BFW:UND1:%d10:ACTC', result.slot );
result.fn         = sprintf ( '%s_BFW%2.2d-%s-WireScan.txt', dateString, result.slot, upper ( wire ) );

result.Ri = getOptics;

result.CardIn     = getWireCardStatus ();
refDetCount       = 0;

if ( result.alignBFW )
    refDetCount = length ( result.refDetectors );

    if ( refDetCount > 1 )
        DetID = zeros ( 1, refDetCount );
        
        for j = 1 : refDetCount            
            for k = 1 : result.plots
                if ( result.scopeID ( k ) )
                    if ( strcmp ( result.scopeSource { result.monitorChannels ( k, 1 ), result.monitorChannels ( k, 2 ) }, result.refDetectors { j } ) )
                        DetID ( j ) = k;
                        break;
                    end
                end
            end
        end
        
        for j = 1 : refDetCount
            if ( ~DetID ( j ) )
                result.alignBFW = false;
                fprintf ( 'BFW alignment option disabled because of missing detectors.\n' );
                break;
            end
        end
            
        if ( result.alignBFW )
            fprintf ( 'Found reference detectors\n' );
                
            for j = 1 : refDetCount
                fprintf ( 'ID(%d) = %d\n', j, DetID ( j ) );
            end
        end
    else
        result.alignBFW = false;
        fprintf ( 'BFW alignment option disabled because insufficient (<2) number of detectors.\n' );
    end
else
    fprintf ( 'BFW alignment option was disabled.\n' );
end

% get hardware components ready for beam

[ Slots, quad_0_array, bfw_0_array, bfw_C_array ]  = getInitialGirderSettings;

% read initial wire position

[ quad_rbi, bfw_rbi, roll_rbi ] = girderAxisFromCamAngles ( result.slot, geo.quadz, geo.bfwz );

result.quad_rbi       = quad_rbi;
result.bfw_rbi        = bfw_rbi;
result.roll_rbi       = roll_rbi;
result.quad_sp        = result.quad_rbi;
result.bfw_sp         = result.bfw_rbi;
result.x0             = result.bfw_rbi ( result.xy ) + bfw_C_array ( result.slot, result.xy ) - bfw_0_array ( result.slot, result.xy );
result.xrel           = ( result.startPos : result.stepSize : result.finalPos );
result.x              = result.xrel + result.x0 * 1000;
result.dxbeam         = result.xrel * 0;
result.xcor           = result.dxbeam;
result.samples        = length ( result.x );
result.y              = zeros  ( result.plots, result.samples );
result.rawvalues      = zeros  ( result.samples, result.plots, result.scopeAverages );
result.charges        = zeros  ( result.samples, result.plots, result.scopeAverages );
result.minCharge      = zeros ( result.samples );
result.avgCharge      = zeros  ( 1, result.samples );
result.RFBPM.path1    = cell   ( 1, result.samples );
result.RFBPM.path2    = cell   ( 1, result.samples );
result.alignThis      = false;
result.Bckd_rawvalues = zeros ( result.samples, result.plots, result.scopeAverages );
result.Bckd_charges   = zeros ( result.samples, result.plots, result.scopeAverages );
result.Bckd_avgCharge = zeros ( result.samples );


result.titleText  = sprintf ( 'BFW %2.2d: %s Wire Scan', result.slot, upper ( wire ) );
result.xlabelText = sprintf ( '%s / µm (wrt %+7.1f µm)', wire, result.x0 * 1000 );

% Save initial trajectory

if ( result.useTrajectory )
    result.RFBPM.path0 = getTrajectory ( result.RFBPM.PV, result.pathTol / 1000 );
end

% Indicate status of motionPermit flag.

if ( ~abortRequest )
    if ( result.motionPermit )
        fprintf ( 'Will move girders.\n' );
    else
        if ( result.reportStatus )
            reportStatus ( 'GIRDER MOTION INHIBITED' );
        end
        
        fprintf ( 'Test mode: NO GIRDER MOTION WILL OCCUR.\n' );
        result.alignBFW = false;
    end
else
    abortScan;
    return;
end

% move BFW to first scan location and activate.

result.scanning = true;

if ( result.motionPermit )
    if ( result.reportStatus )
        reportStatus ( 'Moving BFW to initial position' );
    end
    
    result.yx = ~( result.xy - 1 ) + 1; 
    result.bfw_sp ( result.xy ) = result.x ( 1 ) / 1000;
    result.bfw_sp ( result.yx ) = result.bfw_rbi ( result.yx ) - result.clearOtherBy / 1000;
    
    fprintf ( 'Moving BFW%2.2d from (%7.4f, %7.4f, %7.4f)\n', result.slot,  result.bfw_rbi );  
    fprintf ( '               to (%7.4f, %7.4f, %7.4f) INITIAL SCAN POSITION\n',        result.bfw_sp );  

    girderAxisSet( result.slot, result.quad_sp, result.bfw_sp );
    girderCamWait ( result.slot );

    [ quad_rb2, bfw_rb2, roll_rb2 ] = girderAxisFromCamAngles ( result.slot, geo.quadz, geo.bfwz );
    
    fprintf ( 'Moved BFW%2.2d to    (%7.4f, %7.4f, %7.4f)\n', result.slot,  bfw_rb2 );  
    fprintf ( '      goal was    (%7.4f, %7.4f, %7.4f)\n',        result.bfw_sp );

    if ( beamEnabled )
        disableBeam;
    end    
else
    result.bfw_sp ( result.xy ) = result.x ( 1 ) / 1000;    
    fprintf ( 'Testing BFW%2.2d scanning. Initial target location (%7.4f, %7.4f, %7.4f)\n', result.slot,  result.bfw_sp );
end

if ( ~getWireCardStatus () && result.WireCardPermit )
    insertWireCard ();
end
    
 if ( result.reportStatus )
    reportStatus;
end   

if ( result.savingReport )
    fid = fopen ( sprintf ( '%s%s', result.fp, result.fn ), 'w' );

    if ( fid )
        fprintf ( fid, '%s\r\n', result.fn );
    
        if ( result.motionPermit )
            fprintf ( fid, 'Moving girders.\r\n' );
        else
            fprintf ( fid, 'Test mode: NO GIRDER MOTION OCCURS.\r\n' );
        end
    end
end

%error ( 'Test1' );

for k = 1 : result.plots
    if ( result.scopeID ( k ) )
        result.ylabelText   { k } = sprintf ( '%s:CH%d:%s/V/nC (%d avgs)', ...
                                       result.scopePV { k }, ...
                                       result.scopeChannel ( k ), ...
                                       result.scopeSource { result.scopeID ( k ), result.scopeChannel ( k ) }, ...
                                       result.scopeAverages );
    else
        result.ylabelText   { k } = sprintf ( '%s:%s/V/nC (%d avgs)', ...
                                       result.scopePV { k }, ...
                                       result.monitorSources { k }, ...
                                       result.scopeAverages );
    end

    result.ylabelText  { k } = strrep ( result.ylabelText { k }, '_', '\_' );
    
    if ( result.savingReport )
        if ( fid > 0 )
            fprintf ( fid, '%%%s\r\n', result.ylabelText { k } ); 
        end
    end
end

if ( result.savingReport )
    if ( fid > 0 )
        fclose ( fid );
    end
end

[ fig, pos ] = makeFigure ( result.plotRows, result.plotCols, result.pltR, result.pltC, result.relW );

fig_1 = subplot ( 'Position', pos { 1 }, 'Parent', fig );

title ( fig_1, result.titleText );

correlationPlot ( fig_1, result.xrel ( 1 ) - result.x0, result.y ( 1, 1 ), 'r', result.titleText, result.xlabelText, result.ylabelText { 1 }, result.startPos, result.finalPos );

for k = 1 : result.plots
    fig_k = subplot ( 'Position', pos { k }, 'Parent', result.PLTfig );
    correlationPlot ( fig_k, result.xrel ( 1 ) - result.x0, result.y ( k, 1 ) , 'r', result.titleText, result.xlabelText, result.ylabelText { k }, result.startPos, result.finalPos );
end

bfw_rb = result.bfw_rbi;

if ( result.savingReport )
    fid = fopen ( sprintf ( '%s%s', result.fp, result.fn ), 'a' );
end

for k = 1 : result.plots
    result.fitP { k } = [ 0 0 0 0 ];
end

if ( result.reportStatus )
    reportStatus ( 'Starting Scan' );
end

for j = 1 : result.samples
    if ( abortRequest )
        figure ( result.PLTfig );
        break;
    end
    
    result.scanPos = result.xrel ( j );
    
    result.bfw_sp ( result.xy ) = result.x ( j ) / 1000;
    
    if ( result.motionPermit )
        fprintf ( 'Moving BFW%2.2d from (%7.4f, %7.4f, %7.4f)\n', result.slot,  bfw_rb );  
        fprintf ( '               to (%7.4f, %7.4f, %7.4f)\n',        result.bfw_sp );  

        girderAxisSet( result.slot, result.quad_sp, result.bfw_sp );
        girderCamWait ( result.slot );
    else
        fprintf ( 'Testing BFW%2.2d scanning. Target location (%7.4f, %7.4f, %7.4f).\n', result.slot,  result.bfw_sp );
    end

    result.minCharge ( j ) = 0;
    
    while ( ( result.ignoreCharge || ( result.minCharge ( j ) < result.ChargeThreshold ) ) && ~abortRequest )
        if ( ~result.ignoreCharge )
            charge = getCharge;    
            fprintf ( ' Q = %f nC\n', charge );
        end
        
        if ( beamEnabled )
            disableBeam;
        end

        if ( result.reportStatus )
            reportStatus;
        end

        result = takeBackgroundReadings ( result, j );
        
        if ( ~beamEnabled )
            enableBeam;
        end
        
        pause(1)
        
        if ( result.reportStatus )
            reportStatus;
        end

        if ( result.useTrajectory )
            result.RFBPM.path1 = getTrajectory ( result.RFBPM.PV, result.pathTol / 1000 );
        end
        
        result             = takeSignalReadings     ( result, j );
        
        if ( result.useTrajectory )
            result.RFBPM.path2 = getTrajectory ( result.RFBPM.PV );
        end
        
        if ( beamEnabled )
            disableBeam;
        end
        
        if ( result.reportStatus )
            reportStatus;
        end
        
        if ( result.ignoreCharge )
            break;
        end
    end

    if ( ~abortRequest )
        if ( result.useTrajectory )
            result.dxbeam ( j ) = 1000 * ( result.RFBPM.path1.path ( result.xy, result.slot ) + result.RFBPM.path2.path ( result.xy, result.slot ) ) / 2;        
            result.avg_dxbeam   = mean ( result.dxbeam ( 1 : j ) );
    
            beamcorr = result.avg_dxbeam;
            fprintf ( 'Using average bpm reading of %6.4f µm as correction.\n', result.avg_dxbeam );
        else
            beamcorr  = 0;
        end
    
        if ( abortRequest )
            figure ( result.PLTfig );
            break;
        end
    
        fprintf ( 'Plotting point %d.\n', j );
        
        for k = 1 : result.plots
            fig_k = subplot ( 'Position', pos { k }, 'Parent', result.PLTfig );

            result.fitP { k } = correlationPlot ( fig_k, result.xrel ( 1 : j ) - beamcorr, result.y ( k, 1 : j ), 'ro', ...
                                         result.titleText, result.xlabelText, result.ylabelText { k }, ...
                                     result.startPos, result.finalPos );        
        end

        [ quad_rb2, bfw_rb2, roll_rb2 ] = girderAxisFromCamAngles ( result.slot, geo.quadz, geo.bfwz );

        if ( result.savingReport )
            if ( fid > 0 )
                fprintf ( fid, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n', result.x ( j ) - result.x0 * 1000, result.y ( 1 : k, j ) ); 
            end
        end
    
        bfw_rb = bfw_rb2;
    
        if ( result.motionPermit )
            fprintf ( 'Moved BFW%2.2d to    (%7.4f, %7.4f, %7.4f); Q = %f nC\n', result.slot,  bfw_rb2, charge );  
            fprintf ( '      goal was    (%7.4f, %7.4f, %7.4f)\n',        result.bfw_sp );
        end
    end
end

if ( result.reportStatus )
    result.scanning = false;

    if ( abortRequest )
        reportStatus ( 'Aborting scan...' );
    else
        reportStatus ( 'Scan Complete' );
    end
end   

if ( ~abortRequest )
    for k = 1 : result.plots
        if ( length ( result.fitP { k } ) == 4 )
            fprintf (      'A: %+10.3f; m: %+4.0f µm; s: %+5.1f µm; B: %+10.3f (%s)\n', result.fitP { k }, result.ylabelText { k } );

            if ( result.savingReport )
                if ( fid > 0 )
                    fprintf ( fid, 'A: %+10.3f; m: %+4.0f µm; s: %+5.1f µm; B: %+10.3f (%s)\n', result.fitP { k }, result.ylabelText { k } );
                end
            end
        end
    end

    if ( result.alignBFW )
        result.alignThis    = true;
        signalAmp    = zeros ( 1, refDetCount );
        hitPositions = zeros ( 1, refDetCount );
        beamWidth    = zeros ( 1, refDetCount );
        signalBase   = zeros ( 1, refDetCount );
    
        for j = 1 : refDetCount
            signalAmp    ( j ) = result.fitP { DetID ( j ) } ( 1 );
            hitPositions ( j ) = result.fitP { DetID ( j ) } ( 2 ); 
            beamWidth    ( j ) = result.fitP { DetID ( j ) } ( 3 );
            beamBase     ( j ) = result.fitP { DetID ( j ) } ( 4 );
        end
    
        avgSigAmp = mean ( signalAmp    );
        avgHitPos = mean ( hitPositions ); 
        avgWidth  = mean ( beamWidth    );
        avgBase   = mean ( beamBase     );
    
        for j = 1 : refDetCount
            if ( abs ( avgHitPos - hitPositions ( j ) ) > result.hitTol )
                result.alignThis = false;
                fprintf ( 'Alignment skipped because hits don''t agree within tolerance.\n' );
                break;
            end
        end
    
        if ( result.alignThis && ( avgHitPos < result.startPos || avgHitPos > result.finalPos ) )
            fprintf ( 'Alignment skipped because hits are outside of window (%f ouside  %f <> %f).\n', avgHitPos, result.startPos, result.finalPos );
            result.alignThis = false;
        end
    
        if ( result.alignThis && ( avgWidth >  100 || avgWidth < 5 ) )
            fprintf ( 'Alignment skipped because beam width are out of range (%f ouside  %f <> %f).\n', avgWidth, 5, 100 );
            result.alignThis = false;
        end
        
        if ( result.alignThis && avgSigAmp < 0 )
            fprintf ( 'Alignment skipped because average signal amplitude negative.\n' );
            result.alignThis = false;
        end
    
        if ( result.alignThis )
            alignPos = avgHitPos / 1000 + result.x0;
        
            result.bfw_sp               = result.bfw_rbi;
            result.bfw_sp ( result.xy ) = alignPos - bfw_C_array ( result.slot, result.xy ) + bfw_0_array ( result.slot, result.xy );
            result.alignmentCorrection  = ( result.bfw_sp ( result.xy ) - result.bfw_rbi ( result.xy ) ) * 1000;
        
            fprintf ( 'Moving upstream end of girder by %6.4f µm for alignment based on BFW scan.\n', result.alignmentCorrection );
        
            result.AlignmentDone = true;
        else
            result.bfw_sp        = result.bfw_rbi;
        end
    else
        result.bfw_sp        = result.bfw_rbi;
        result.AlignmentDone = false;
    end

    if ( result.savingReport &&  fid > 0 )
        fclose ( fid );
        fprintf ( 'saved report to file %s.\n', result.fn );
    else
        fprintf ( 'Not saving report to file.\n' );
    end

    hold off;

    % deactivate BFW and move to back to original or aligned location.

    if ( result.motionPermit )
        withdrawWireCard;
        enableBeam;

        if ( result.reportStatus )
            if ( abortRequest )
                reportStatus ( 'Aborting scan...' );
            else
                reportStatus ( 'Scan Complete' );
            end
        end   

        fprintf ( 'Moving BFW%2.2d from (%7.4f, %7.4f, %7.4f)\n', result.slot,  bfw_rb );  
    
        if ( result.alignBFW )
            if ( result.alignThis )
                if ( result.reportStatus )
                    reportStatus ( 'Moving BFW to aligned position' );
                end   

                fprintf ( '               to (%7.4f, %7.4f, %7.4f) ALIGNED POSITION\n',        result.bfw_sp );
            else
                if ( result.reportStatus )
                    reportStatus ( 'Moving BFW back to initial position.' );
                end   

                fprintf ( '               to (%7.4f, %7.4f, %7.4f) ORIGINAL POSITION\n',        result.bfw_sp );
            end
        end
    
        girderAxisSet( result.slot, result.quad_rbi, result.bfw_sp );
        girderCamWait ( result.slot );

        [ quad_rb2, bfw_rb2, roll_rb2 ] = girderAxisFromCamAngles ( result.slot, geo.quadz, geo.bfwz );
    
        fprintf ( 'Moved BFW%2.2d to    (%7.4f, %7.4f, %7.4f); Q = %f nC\n', result.slot,  bfw_rb2, charge );  
        fprintf ( '      goal was    (%7.4f, %7.4f, %7.4f)\n',        result.bfw_sp );
    end

% save figures

    if ( result.savingPlots )
        figName = sprintf ( '%s%s', result.fp, regexprep ( result.fn, '.txt', '' ) );
        
        if ( any ( find ( findobj == fig ) ) )    % Avoid problems in case the user closed the figure before the guiwindow.
            print ( fig, '-dpsc',  '-r300', figName );
            print ( fig, '-dpdf',  '-r300', figName );
            print ( fig, '-djpeg', '-r300', figName );    
            fprintf ( 'saved plots to files "%s".\n', figName );
        end
    else
        fprintf ( 'Not saving plots to file.\n' );
    end

    if ( result.printTo_e_Log )
        print (fig, '-dpsc2', '-Pphysics-lclslog', '-adobecset' );
        fprintf ( 'sent plots to physics-lclslog.\n' );
    else
        fprintf ( 'Not sending plots to physics-lclslog.\n' );
    end

    result.success = true;

    if ( result.savingMat )
        matName = sprintf ( '%s%s', result.fp, regexprep ( result.fn, '.txt', '.mat' ) );
        save ( matName, 'result' );
        fprintf ( 'saved data to file "%s".\n', matName );
    else
        fprintf ( 'Not saving data to ''.mat'' data to file.\n' );
    end

    new_result     = result;
else
    figure ( result.PLTfig );
    abortScan;
end

if ( result.reportStatus )
    reportStatus;
end   

end


function Ri = getOptics

global modelSource;
global modelOnline;

modelSource = 'EPICS';
modelOnline = 0;

slots       = 33;

BFW_PVs     = cell ( 1, slots     );
Ri          = cell ( 1, slots - 1 );
from        = cell ( 1, slots - 1 );
to          = cell ( 1, slots - 1 );

for j = 1 : slots
    BFW_PVs { j } = sprintf ( 'BFW:UND1:%d10', j );
    
    if ( j < slots )
        from { j }     = BFW_PVs { j };
    end
    
    if ( j > 1 )
        to   { j - 1 } = BFW_PVs { j };
    end
end

%for j = 1 : slots - 1
%    fprintf ( 'From "%s" to "%s"\n', from { j }, to { j } );
%end

Ri = model_rMatGet ( from, to );

end


function [ fig, pos ] = makeFigure ( rows, cols, pltR, pltC, relW )

global result;

%result.relW = 1;
pltW  = 1 / cols;
pltH  = 1 / rows;
frmW  = 0.7 * pltW;
frmH  = 0.7 * pltH;

scrsz = get ( 0, 'ScreenSize' );

figW  = scrsz ( 3 ) * 0.95 * relW;
figH  = scrsz ( 4 ) * 0.95; 

figX  = ( scrsz ( 3 ) * relW - figW ) / 2;
figY  = ( scrsz ( 4 )        - figH ) / 2;

PLTfig = findobj ( 'Name', 'BFW scans' );

if ( any ( PLTfig ) )
    delete ( PLTfig )
end

fig = figure ( result.PLTfig );
%set ( result.PLTfig, 'Position', [ figX, figY, figW, figH ] )
%set ( result.PLTfig, 'Name', 'BFW scans' );
set ( fig, 'Visible', 'Off' );
set ( fig, 'Position', [ figX, figY, figW, figH ] )
set ( fig, 'Name', 'BFW scans' );

n   = rows * cols;

pos = cell ( 1, n );

for k = 1 : n
    pltX = ( pltC ( k ) - 1 ) * pltW + ( pltW - frmW ) / 2 + 0.02;
    pltY = ( pltR ( k ) - 1 ) * pltH + ( pltH - frmH ) / 2;
    
    pos { k } = [ pltX, pltY, frmW, frmH ];
end

end


function fitP = correlationPlot ( fig, x, y, mode, titleText, xlabelText, ylabelText, xmin, xmax )

PLTfig = findobj ( 'Name', 'BFW scans' );

if ( any ( PLTfig ) )
    set ( PLTfig, 'Visible', 'On' );
end

hold ( fig, 'off' );

fitP = [ 0, 0, 0, 0 ];
n    = length ( x );

if ( n > 5 )
    doFit = true;
else
    doFit = false;
end

plot ( x, y, mode, 'Parent', fig );
    
hold ( fig, 'on' );
grid ( fig, 'on' );

if ( doFit )
    fitP = fitData ( x, y );
    s    = min ( x ) : 1 : max ( x );
    fitF = fitP ( 1 ) * exp ( -( s - fitP ( 2 ) ).^2 ./ ( 2 * fitP ( 3 )^2 ) ) + fitP ( 4 );
    plot ( s, fitF, 'Parent', fig );
end

v = axis;

v ( 1 ) = xmin;
v ( 2 ) = xmax;

axis ( v );

title  ( titleText, 'Position', estimatePosition ( 50, 105, axis ), ...
                    'HorizontalAlignment', 'center', 'FontSize', 11, ...
                    'Parent', fig );
xlabel ( xlabelText, 'FontSize', 10, 'Parent', fig );
ylabel ( ylabelText, 'FontSize', 10, 'Parent', fig );

set ( fig, 'FontSize', 10 );

if ( doFit && length ( fitP ) == 4 )
%    textPos = estimatePosition ( 50, 101, axis ( ) );
    textPos = estimatePosition ( 50, 101, axis ( fig ) );
    textStr = sprintf ( 'A: %+10.3f; m: %+4.0f µm; s: %+5.1f µm; B: %+10.3f\n', fitP );
    text ( textPos ( 1 ), textPos ( 2 ), textStr, 'HorizontalAlignment', 'center', 'FontSize', 8, 'Parent', fig );
end

%reply = input('Do you want more? Y/N [Y]: ', 's');

end


function pos = estimatePosition ( pctX,pctY, frame )

X0 = frame ( 1 );
Y0 = frame ( 3 );
W  = frame ( 2 ) - frame ( 1 );
H  = frame ( 4 ) - frame ( 3 );

X = X0 + W * pctX / 100;
Y = Y0 + H * pctY / 100;

pos = [ X, Y ];

end


function Estimates = fitData ( x, y )

B = y ( 1 );

u = max ( y );
d = min ( y );

if ( abs ( u - B ) > abs ( d - B ) )
    c = find ( y == max ( y ) );
else
    c = find ( y == min ( y ) );
end

A = y ( c ) - B;
m = x ( c );
s = 70;

Starting = [ A m s B ];
%options   = optimset ( 'Display', 'iter' );
options   = optimset ( 'Display', 'none' );
Estimates = fminsearch ( @Gaussian1Dfit, Starting, options, x, y );

end


function enabled = BYKIK_STATUS ( mode )

global result;

% Return true if beam is permitted to the Undulator Hall.

BYKIK_PV = 'IOC:BSY0:MP01:BYKIKCTL';

enabled = checkBeamPermission ( BYKIK_PV );

switch mode
    case 0
        if ( ~enabled )
            fprintf ( 'Beam was already disabled\n' );
        end        
    case 1
        if ( enabled )
            fprintf ( 'Beam was already enabled\n' );
        end        
end

if ( result.BYKIKPermit && ( mode == 0 || mode == 1 ) )
    lcaPut ( BYKIK_PV, mode );
    
    pause ( result.BYKIKwait );
end

enabled = checkBeamPermission ( BYKIK_PV );

switch mode
    case 0
        if ( enabled )
            fprintf ( 'Beam disabling FAILED\n' );
        else
            fprintf ( 'Beam disabled.\n' );
        end        
    case 1
        if ( ~enabled )
            fprintf ( 'Beam enabling FAILED\n' );
        else
            fprintf ( 'Beam enabled.\n' );
        end        
end

end


function enabled = checkBeamPermission ( BYKIK_PV )

global result;

beamPermission = lcaGet ( BYKIK_PV );

if ( strcmp ( beamPermission { 1 }, 'Yes' ) )
    enabled = true;  % Beam is allowed pass BYKIK
else
    enabled = false; % Beam is blocked by BYKIK
end

result.BYKIKenabled = enabled;

end


function disableBeam

BYKIK_STATUS ( 0 );

end


function enableBeam

BYKIK_STATUS ( 1 );

end


function enabled = beamEnabled

% returns true if beam is allowed to pass through BYKIK

enabled = BYKIK_STATUS ( 2 );

end


function insertWireCard

global result;

result.WireCardPermit

if ( result.WireCardPermit )
    lcaPut ( result.wireCardPV, 1 );
    pause ( result.Cardwait );
end

getWireCardStatus ( true );

end


function withdrawWireCard

global result;

if ( result.WireCardPermit )
    lcaPut ( result.wireCardPV, 0 );
    pause ( result.Cardwait );
end

getWireCardStatus ( true );

end


function inserted = getWireCardStatus ( v )

global result;

if ( exist ( 'v', 'var' ) )
    verbose = v;
else
    verbose = false;
end

BFWpos = lcaGet ( result.wireCardPV );

if ( isempty ( strfind ( BFWpos { 1 }, 'Inactive' ) ) && isempty ( strfind ( BFWpos { 1 }, 'Out' ) ) )
    inserted = true;
else
    inserted = false;
end

if ( verbose )
    fprintf ( 'Wire card for BFW%2.2d is %s\n', result.slot, BFWpos { 1 } );
end

result.CardIn = inserted;

end


function charge = getCharge

global result;
global PhyConsts;
global abortRequest;

waitLoops  = 0;
wasEnabled = beamEnabled;

if ( ~wasEnabled  )
    enableBeam;
end

if ( ~beamEnabled )
    withdrawWireCard;
    
    if ( result.BYKIKPermit )
        error ( 'Was unable to operate BYKIK' );
    end
end

charge           = save_lcaGet ( result.chargePV ) * PhyConsts.echarge * 1e9; % [nC]
wireCardInserted = getWireCardStatus ();

if ( beamEnabled && wireCardInserted )
    fprintf ( ' test point getCharge B\n' );
    disableBeam;
end

if ( beamEnabled && wireCardInserted )
    withdrawWireCard;
    
    if ( result.BYKIKPermit )
        error ( 'Was unable to operate BYKIK' );
    end
end

if ( charge < result.ChargeThreshold )
    if ( result.ignoreCharge )
        fprintf ( 'Charge too low: %f nC. Continuing anyway ... \n', charge );
    else
        while ( charge < 0.05 && ~abortRequest && ~result.ignoreCharge )
            fprintf ( 'Charge too low: %f nC. Waiting ... \n', charge );
            pause ( result.chargewait );
            waitLoops = waitLoops + 1;
            
            if ( ~beamEnabled )
                fprintf ( ' test point getCharge C\n' );
                enableBeam;  
            end

            
            charge = save_lcaGet ( result.chargePV ) * PhyConsts.echarge * 1e9; % [nC]
                
            if ( beamEnabled && wireCardInserted )
                fprintf ( ' test point getCharge D\n' );                
                disableBeam;
            end

            if ( beamEnabled && wireCardInserted)
                withdrawWireCard;
                error ( 'Was unable to operate BYKIK' );
            end
        end
    end
end

if ( wasEnabled )
    if ( ~beamEnabled )
        fprintf ( ' test point getCharge E\n' );
        enableBeam;
    end
else
    if ( beamEnabled )
        disableBeam;
    end
end

if ( waitLoops )
    fprintf ( '... got charge : %f nC after %d attempts.\n', charge, waitLoops );
end

end


function [ v, t ] = save_lcaGet ( PV )

success = true;
v       = 0;

try
   [ v, t ] = lcaGet ( PV );
catch
    success = false;
end

avg_v = mean ( v );

if ( ~success || isnan ( avg_v ) )
    v = 0;
    t = 0;
end

end


function t = getTrajectory ( PVarray, pathTolerance )
% pathTol is an optional argument. If present, the
% function will keep waitng for a trajecory with 
% a total rms below pathTol. The dimension of pathTol
% is [mm]

global abortRequest;
global result;

if ( ~exist ( 'pathTolerance', 'var' ) )
    pathTol = 1e10;
else
    pathTol = pathTolerance;
end

%result.RFBPM.averages  = 10;

[ n, m ] = size ( PVarray );

PVlist = cell  ( n * m, 1 );
t.path = zeros ( n, m );

for b = 1 : m
    for xy = 1 : n
        PVlist { ( xy - 1 ) * m + b } = PVarray { xy, b }; 
    end
end

wasDisabled      = ~beamEnabled ();
wireCardInserted = getWireCardStatus ();

fprintf ('get Trajectory. beam status = %d (was %d)\n', wireCardInserted, wasDisabled );

if ( wasDisabled )
    enableBeam;
end

if ( ~beamEnabled () )
    if ( wireCardInserted)
        withdrawWireCard ();
    end

    if ( result.BYKIKPermit )
        error ( 'Was unable to operate BYKIK' );
    end
end

waitLoops = 0;

trajectory = save_lcaGet ( PVlist );
    
if ( length ( trajectory ) ~= 2 * m )
    pathrms = 2 * pathTol;

    if ( ~result.useTrajectory )
        trajectory = zeros ( 1, 2 * m );
    end
else
    pathrms = std ( trajectory );    
end


while ( pathrms > pathTol && result.useTrajectory && ~abortRequest )
    t.charge   = getCharge;    
    trajectory = save_lcaGet ( PVlist );
    
    if ( length ( trajectory ) ~= 2 * m )
        pathrms = 2 * pathTol;
    else
        pathrms = std ( trajectory );
    end
    
    if ( pathrms > pathTol )
        if ( beamEnabled )
            fprintf ( ' test point getTrajectory B\n' );
            disableBeam;
        end
        
        if ( beamEnabled && getWireCardStatus )
            withdrawWireCard;
            
            if ( result.BYKIKPermit )
                error ( 'Was unable to operate BYKIK' );
            end
        else
            fprintf ( 'Trajectory rms (%6.4f mm ) is larger than tolerance ( %6.5f mm ). Waiting for a better steered beam ...\n', pathrms, pathTol );
            waitLoops = waitLoops + 1;
            pause ( result.trajectorywait );

            if ( abortRequest )
                break;
            end
        end
        
        if ( ~beamEnabled )
            enableBeam;
        end
    end
end

if ( ~abortRequest )
    if ( wasDisabled )
        if ( beamEnabled )
            fprintf ( ' test point getTrajectory D\n' );
            disableBeam;
        end
    
        if ( beamEnabled && wireCardInserted )
            withDrawWireCard; % Make an attempt to remove the wire because BYKIK insertion failed.
            error ( 'Unable to disable beam while wire was inserted.' );
        end    
    else
        if ( ~beamEnabled )
            enableBeam;
        end
    end

    if ( length ( trajectory ) ~= 2 * m )
        t.parth = zeros ( n, m );
        status = 'stopped waiting for trajectory';
    else
        for b = 1 : m
            for xy = 1 : n
                t.path ( xy, b ) = trajectory ( ( xy - 1 ) * m + b ); 
            end
        end
        
        status = 'got trajectory';
    end
    
    if ( waitLoops )
        fprintf ( '... %s : %6.4f mm after %d attempts.\n', status, pathrms, waitLoops );
    end

    t.rms = std  ( t.path,  0, 2 )';
    t.avg = mean ( t.path,     2 )';
    t.max = max  ( t.path, [], 2 )';
    t.min = min  ( t.path, [], 2 )';
end

end


function abortScan 

global result

geo = girderGeo;

if ( result.motionPermit )
    withdrawWireCard;
    
    if ( result.reportStatus )
        reportStatus ( 'Scan abort -> wire card out' );
    end

    enableBeam;
    
    if ( result.reportStatus )
        reportStatus ( 'Scan abort -> BYKIK disabled' );
    end

    fprintf ( 'Moving BFW%2.2d from (%7.4f, %7.4f, %7.4f)\n', result.slot,  result.bfw_rbi );  
    fprintf ( '               to (%7.4f, %7.4f, %7.4f) ORIGINAL POSITION\n', result.bfw_rbi );
    
    girderAxisSet( result.slot, result.quad_rbi, result.bfw_rbi );
    girderCamWait ( result.slot );

    [ quad_rb2, bfw_rb2, roll_rb2 ] = girderAxisFromCamAngles ( result.slot, geo.quadz, geo.bfwz );
    
    fprintf ( 'Moved BFW%2.2d to    (%7.4f, %7.4f, %7.4f)\n', result.slot,  bfw_rb2 );  
    fprintf ( '      goal was    (%7.4f, %7.4f, %7.4f)\n',    result.bfw_rbi );
end

PLTfig = findobj ( 'Name', 'BFW scans' );

if ( any ( PLTfig ) )
    delete ( PLTfig )
end

result.scanPos  = NaN;

if ( result.reportStatus )
    reportStatus ( 'Scan abort completed.' );
end

fprintf ( 'Scan abort completed.\n' );

end


function reportStatus ( info )

global result;

figure ( result.GUIfig );

handles = result.handles;

if ( exist ( 'info', 'var' ) )
    set ( handles.INFO_AREA, 'String', info );
else
    if ( result.scanning )
        if ( ~isnan ( result.scanPos ) )
            set ( handles.INFO_AREA, 'String', sprintf ( 'scanning BFW%2.2d-%s at %+7.1f µm', ...
                result.slot, upper ( result.wire ), result.scanPos ) );
        else
            set ( handles.INFO_AREA, 'String', sprintf ( 'scanning BFW%2.2d-%s', ...
                result.slot, upper ( result.wire ) ) );
        end
    else
        set ( handles.INFO_AREA, 'String', '' );
    end
end

if ( result.CardIn && result.scanning )
    set ( handles.WIRECARD_POSITION, 'String', 'Wire Card Inserted' );
else
    set ( handles.WIRECARD_POSITION, 'String', '' );
end

if ( result.BYKIKenabled || ~result.scanning )
    set ( handles.BYKIK_STATUS, 'String', '' );
else
    set ( handles.BYKIK_STATUS, 'String', 'Beam Disabled' );
end

refresh;

PLTfig = findobj ( 'Name', 'BFW scans' );

if ( any ( PLTfig ) )
    figure ( PLTfig )
end

end


function getSwitches

global result;

handles = result.handles;

result.BYKIKPermit    = get ( handles.BYKIK_PERMIT_BOX,         'Value' );
result.WireCardPermit = get ( handles.WIRE_CARD_PERMIT_BOX,     'Value' );
result.alignBFW       = get ( handles.ALIGN_BFW_BOX,            'Value' );
result.printTo_e_Log  = get ( handles.PRINT_TO_ELOG_BOX,        'Value' );
result.motionPermit   = get ( handles.GIRDER_MOTION_PERMIT_BOX, 'Value' );
result.ignoreCharge   = get ( handles.IGNORE_CHARGE_BOX,        'Value' );
result.useTrajectory  = get ( handles.USE_ORBIT_THRESHOLD_BOX,  'Value' );

end


function result = takeBackgroundReadings ( result, j )

[ rawvalues, charges, minCharge, avgCharge ] = ...
           readLossMonitors ( ...
           result.scopePV, ...
           result.scopeChannel, ...
           result.scopeAverages, ...
           result.scopeDelay, ...
           result.RFBPM.PV { result.xy, result.slot } );

%       rawvalues
%       charges
result.Bckd_rawvalues ( j, :, : ) = rawvalues;

for c = 1 : result.plots
    result.Bckd_charges   ( j, c, : ) = charges ( c, : );
end

result.minCharge      ( j )       = min ( minCharge );
result.Bckd_avgCharge ( j )       = mean ( avgCharge );
    
end


function result = takeSignalReadings ( result, j )

[ rawvalues, charges, minCharge, avgCharge ] = ...
           readLossMonitors ( ...
           result.scopePV, ...
           result.scopeChannel, ...
           result.scopeAverages, ...
           result.scopeDelay, ...
           result.RFBPM.PV { result.xy, result.slot } );
               
result.rawvalues ( j, :, : ) = rawvalues;

for c = 1 : result.plots
    result.charges   ( j, c, : ) = charges ( c, : );
end
result.minCharge ( j )       = min ( minCharge );
result.avgCharge ( j )       = mean ( avgCharge );
    
for p = 1 : result.plots    
    for k = 1 : result.scopeAverages
        result.y ( p, j ) = 0;

        count = 0;
        
        if ( charges ( p, k ) > result.ChargeThreshold )
            result.y ( p, j ) = result.y ( p, j )  + ...
                ( result.rawvalues ( j, p, k ) - result.Bckd_rawvalues ( j, p, k ) ) / result.charges ( j, p, k );
%            result.y ( p, j ) = result.y ( p, j )  + result.rawvalues ( j, p, k ) / charges ( p, k );
            count = count + 1;
        end
        
        if ( count )
            result.y ( p, j ) = result.y ( p,j ) / count;
        end
    end
end

end

