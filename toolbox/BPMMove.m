function success = BPMMove ( undulatorLine, BPMList, dx, dy  )
%
% succes=BPMMove( undulatorLine,cellList,dx,dy);
%
% Moves cam stages such that the BPMs move by the requested amount
% given in dx and dy. Note: the moves are relative NOT absolute.
%
% - undulatorLine is a character string, eg. 'HXR' or 'SXR'.
% - cellList is a row array of cell numbers, such as 30:40;
% - dx is a row array of requested horizontal BPM moves [mm] 
% - dy is a row array of requested vertical BPM moves [mm] 
% For the HXR beamline:
%   For all but the first girder, the movements will be pivoted with
%   respect to the center of the quadrupole on the upstream girder. The
%   quadrupole next to the requested BPM will be moved by about the same
%   amount as the BPM itself. For the first girder, the movement depends on
%   which BPM was selected for move:
%   (1) if only the first regular girder BPM is to be moved, the move will
%       be pivoted around an upstream position where a quadrupole would be
%       for downstream girders.
%   (2) if only the upstream BPM (RFBHX12) is to be moved, the move will be
%       pivoted around the center of the downstream quadrupole on the same
%       girder.
%   (3) if both BPMs on the first girder are to be moved at the same time,
%       that request will fully define the girder move.
% For the SXR beamline:
%   For all movable BPMs, the interspace stand will be moved without pitch 
%   and yaw such that the BPM and the quadrupole on each interspace stand
%   will be moved by the same amount.
%
% Last modified on 5/18/2021 by Heinz-Dieter Nuhn

addpath ( genpath ( '/home/physics/nuhn/wrk/matlab' ) );

undulatorLines = { 'HXR'; 'SXR' };

Line           = upper ( strtrim ( undulatorLine ) );

if ( ~ismember ( Line, undulatorLines ) )
    display ( undulatorLine );
    error ( 'only ''HXR'' or ''SXR'' are allowed as first input parameter' );
end

Line = Line ( 1 );

if ( Line == 'H' )
    geo              = HXRGeo;
    UndConsts        = util_HXRUndulatorConstants;
    XtraBPM          = UndConsts.cellOffset;
    movableBPMcells  = [ XtraBPM UndConsts.movableQuadCells ];    
else
    geo              = SXRGeo; 
    UndConsts        = util_SXRUndulatorConstants;
    movableBPMcells  = UndConsts.allCamStages;
end

BPMs                 = length ( BPMList );
dx_values            = length ( dx );
dy_values            = length ( dy );

if ( dx_values ~= dy_values )
    display ( [ dx_value, dy_value ] );
    error ( 'Different number of values are given in dx and dy arrays' );
end

if ( dx_values ~= BPMs && dx_values ~= 1 )
    display ( BPMList );
    display ( angleList );
    error ( 'The number of angles does not match the number of rows in cellsList');
end

if ( BPMs ~= length ( unique ( BPMList ) ) )
    display ( BPMList );
    error ( 'Cell numbers are not unique.' );
end

if ( any ( ~ismember ( BPMList, movableBPMcells ) ) )
    display ( BPMList );
    error ( 'Some of the specified cells don''t contain movable BPMs' );
end

if ( dx_values == 1 && BPMs > 1 )
    xMoves = ( 1 : BPMs ) * 0 + dx;
    yMoves = ( 1 : BPMs ) * 0 + dy;
else
    xMoves = dx;
    yMoves = dy;
end

stageList   = BPMList; % These will be the stages to be moved
regularBPMs = BPMList; % These will be the BPMs with no extra treatment

if ( Line == 'H' )
    BPMscenario = 1; 

    if ( ismember ( XtraBPM, BPMList ) )        
        regularBPMs ( regularBPMs == XtraBPM )          = [];
        
        if ( ismember ( XtraBPM + 1, BPMList ) )
            BPMscenario                                 = 3;
            stageList ( stageList == XtraBPM )          = []; % XtraBPM does not have its own stage.
            regularBPMs ( regularBPMs == XtraBPM + 1 )  = [];
        else
            BPMscenario                                 = 2;
            stageList ( stageList == XtraBPM )          = XtraBPM + 1;
        end
    end
end

iniQuadAlignments      = CamAngles2QuadAlignment ( undulatorLine, stageList, readCamAngles ( undulatorLine, stageList ) );

if ( Line == 'H' )
    quadztobpmz = ( cell2mat ( UndConsts.Z_BPM )  - cell2mat ( UndConsts.Z_QUAD ) ) * 1000;
    quadztobpmz = mean ( quadztobpmz ( ismember ( stageList, UndConsts.allCamStages ) ) );
else
    quadztobpmz = geo.quadztobpmz;
end

%QuadSep                = UndConsts.CellLength * 1000;
%BPMtoPrevGirderQuadSep = QuadSep + geo.quadztobpmz;

% Regular BPMs are all of the SXR BPMS and those HXR BPMs, beyond the
% first girder or, if only the downstream BPM is selected on the first
% girder all BPMs except the extra BPM at the beginning of the first girder.

regularBPMcount = length ( regularBPMs );

if ( Line == 'H' )
    newBPMAlignments  = changeAlignmentZ ( quadztobpmz, iniQuadAlignments );
    
    if ( regularBPMcount )     % regular HXR RFBPMs
        for j = 1 : regularBPMcount
            idA                         = find ( BPMList   == regularBPMs ( j ) );
            idB                         = find ( stageList == regularBPMs ( j ) );
            
            idA                         = idA ( 1 );
            idB                         = idB ( 1 );
       
            dbpmdx                      = xMoves ( idA ); % [m]
            dbpmdy                      = yMoves ( idA ); % [m]   
    
            newBPMAlignments ( idB, 1 ) = newBPMAlignments ( idB, 1 ) + dbpmdx;
            newBPMAlignments ( idB, 2 ) = newBPMAlignments ( idB, 2 ) + dbpmdy;
        
            girderID                    = find ( UndConsts.allCamStages == regularBPMs ( j ) );

            if ( girderID > 1 )
                BPMtoPrevGirderQuadSep  = ( UndConsts.Z_BPM { girderID } - UndConsts.Z_QUAD { girderID - 1 } ) * 1000;
            else
% Locate the pivot point to the center of the virtual upstream quadrupole.
% That distance in LCLS is equal to the distance betweeen the centers of
% the 3rd and the 4th quadrupole spanning a long break section. This is
% implemented here because during commissioning the first 10 girders are
% still of the old type with the old spacing. With the new HXR girders all
% spacing are idendical and this consideration is not necessary.

                BPMtoPrevGirderQuadSep  = ( UndConsts.Z_BPM { 4 }        - UndConsts.Z_QUAD { 3 } ) * 1000;
%                BPMtoPrevGirderQuadSep  = ( geo.quadzB - geo.bpm00z )
            end
        
            dpitch                      = dbpmdy / BPMtoPrevGirderQuadSep; % [rad]
            dyaw                        = dbpmdx / BPMtoPrevGirderQuadSep; % [rad]

            newBPMAlignments ( idB, 4 ) = newBPMAlignments ( idB, 4 ) + dpitch;
            newBPMAlignments ( idB, 5 ) = newBPMAlignments ( idB, 5 ) + dyaw;
        end
    end
    
    if ( BPMscenario == 2 )     % XtraBPM but not XtraBPM + 1, i.e., only the upstream BPM on the first girder
        idA                             = find ( BPMList   == XtraBPM );
        idB                             = find ( stageList == XtraBPM + 1 );

        dpitch                          = - yMoves ( idA ) / ( geo.quadzB + quadztobpmz - geo.bpm00z ); % [rad]
        dyaw                            = - xMoves ( idA ) / ( geo.quadzB + quadztobpmz - geo.bpm00z ); % [rad]

        newBPMAlignments ( idB, 4 )     = newBPMAlignments ( idB, 4 ) + dpitch;
        newBPMAlignments ( idB, 5 )     = newBPMAlignments ( idB, 5 ) + dyaw;        
    elseif ( BPMscenario == 3 ) % both XtraBPM and XtraBPM + 1, i.e., both BPMs on the first girder
        idA1                            = find ( BPMList   == XtraBPM );
        idA2                            = find ( BPMList   == XtraBPM + 1 );
        idB                             = find ( stageList == XtraBPM + 1 );

        dpitch                          = ( yMoves ( idA2 ) - yMoves ( idA1 ) ) / ( geo.quadzB - geo.bpm00z + geo.quadztobpmz ); % [rad]
        dyaw                            = ( xMoves ( idA2 ) - xMoves ( idA1 ) ) / ( geo.quadzB - geo.bpm00z + geo.quadztobpmz ); % [rad]

        newBPMAlignments ( idB, 1 )     = newBPMAlignments ( idB, 1 ) + xMoves ( idA2 );
        newBPMAlignments ( idB, 2 )     = newBPMAlignments ( idB, 2 ) + yMoves ( idA2 );
        newBPMAlignments ( idB, 4 )     = newBPMAlignments ( idB, 4 ) + dpitch;
        newBPMAlignments ( idB, 5 )     = newBPMAlignments ( idB, 5 ) + dyaw;
    end
else % Line = 'S'
    newBPMAlignments                    = iniQuadAlignments ;

    for j = 1 : regularBPMcount
        idA                             = find ( BPMList   == regularBPMs ( j ) );
        idB                             = find ( stageList == regularBPMs ( j ) );
       
        newBPMAlignments ( idB, 1 )     = newBPMAlignments ( idB, 1 ) + xMoves ( idA ); % [mm];
        newBPMAlignments ( idB, 2 )     = newBPMAlignments ( idB, 2 ) + yMoves ( idA ); % [mm] ;        
    end
end

success = setCamAngles ( undulatorLine, stageList, Alignment2CamAngles (  undulatorLine, stageList, newBPMAlignments ) );

end