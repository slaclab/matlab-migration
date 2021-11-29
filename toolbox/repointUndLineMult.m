function posChanges = repointUndLineMult ( undulatorLine, startCell, ZigZag, kicker, Comment ) % add optional parameter comment.
%
%  posChanges = repointUndLineMult(undulatorLine,startCell,ZigZag[[,kicker],Comment] );
%
% Moves up to 34 girders as 1 or more straight line sections, 
% keeping their relative alignment with respect to  straight line sections
% intact.
% 
% The input parameters are:
%
% undulatorLine = 
% startCell     = string: either 'HXR' or 'SXR'; (Default is 'HXR' )
% ZigZag        = { celln, dxn, dyn };
% kicker        = string: either 'mover' or 'corr'; (Default is 'corr')
% Comment       = string; (Default = 'HXR Repointing Changes')
%                 The Comment is used when eLog printing is done.
%
% === ZigZag contains 0 to 33 of the following items separated by ";" =====
% celln = cell of QU to complete first cell and start next (if any)
% dxn   = change in x - displacement of QU[cell2]  [microns]
% dyn   = change in y - displacement of QU[cell2]  [microns]
% =========================================================================
%
% The following defaults apply
%
% repointUndLineMult;    
%        => repointUndLineMult('HXR',13,{46,0,0},'corr');
%
% repointUndLineMult(29); 
%        => repointUndLineMult('HXR',29,{46,0,0},'corr');
%
% repointHXRLineMult(100, 150); 
%        => repointUndLineMult('HXR',13,{46,100,150},'corr');
%
% repointHXRLineMult({45,100, 150});
%        => repointUndLineMult('HXR',13,{45,100,150},'corr');
%
% The quadrupole on the start girder (startCell), which is assumed to be on
% the LTUH or LTUS beam axis, kicks the beam into the first tilted cell,
% which starts with the next girder. The displacements specified in the
% ZigZag array always refer to the beam positions at the quadrupole
% location of the specified girder (celln) and are relative to the LTUH or
% LTUS beam axis.
% 
% Example:
% repointUndLineMult('HXR',13,{ 29,50,30;46,150,100}); 
%
% This command will repoint the undulators in 2 straight sections,
% i.e. with kincks after girders in cells 13 and 29: Girders in
% cells 14 - 29 will get repointed such that the beam axis stays centered
% in QU13 but will change along a straight line until QU29; Girders 30 - 46
% will get repointed such that the beam axis will change along a straight
% line until QU46. QU29 will be moved by a total of 50 microns in x and
% 30 microns in y, while QU46 will be moved by a total of 150 microns
% in x and 100 microns in y.
%
% The beam trajectory will be corrected at each quadrupole that is
% at the kinck location. The correction can either be done by an
% additional change in quadrupole position ('mover') or by the
% associated dipole corrector coils on that quadrupole. While the
% latter option is applied by default the former needs to be specified.
%
% Example:
% repointUndLineMult('HXR',13,{ 29,50,30;46,150,100}, 'mover' ); 
%
% The equivalents of the above examples for the SXR lines are:
% repointUndLineMult ( 'SXR' );  
%        => repointUndLineMult('SXR',26,{47,0,0},'corr'BPM);
%
% repointUndLineMult( 'SXR', 40);
%        => repointUndLineMult('SXR',40,{47,0,0},'corr');
%
% repointUndLineMult( 'SXR', 100, 150);     
%        => repointUndLineMult('SXR',26,{47,100,150},'corr');
%
% repointUndLineMult('SXR',{46, 100, 150}); 
%        => repointUndLineMult('SXR',26,{46,100,150},'corr');
%
% repointUndLineMult('SXR',26,{ 39,50,30;47,150,100}); 
%
% repointUndLineMult('SXR',26,{ 39,50,30;47,150,100}, 'mover' ); 
%
%
% The output parameters are:
%
% posChanges = 34 x 6 array of quad position and angle changes.
%               posChanges ( :, 1 ) = quad x changes
%               posChanges ( :, 2 ) = quad y changes
%               posChanges ( :, 3 ) = quad z positions
%               posChanges ( :, 4 ) = quad pitch changes
%               posChanges ( :, 5 ) = quad yaw changes
%               posChanges ( :, 6 ) = quad roll values
% The changes are reported in units of microns.
%
% Last updated by Heinz-Dieter Nuhn on September 30, 2020.

global result;

addpath ( genpath ( '/home/physics/nuhn/wrk/matlab' ) );

lcaSetSeverityWarnLevel ( 5 );

result.controlPermit        = true; % Are we allowed to change controls parameters? 
result.BYKIKPermit          = false; % Can we use BYKIK?
result.OnlineParmsUsePermit = true; % Are beam related PVs usable?
result.useCamsPermit        = true; % Are we allowed to move cam motors?
result.useRFBPMsPermit      = true; % Can the RFBPMs be read?
result.OnlineQuadUsePermit  = true; % Are quadrupole parameters available?
result.verbose              = false;
result.plotPositionChanges  = true;
fig_to_Files                = false;
printTo_e_Log               = false;
PhysicsConsts               = util_PhysicsConstants;
HXRConsts                   = util_HXRUndulatorConstants;
frstMovableHXRQuadCell      = min ( HXRConsts.movableQuadCells );
lastMovableHXRQuadCell      = max ( HXRConsts.movableQuadCells );

if ( ~exist ( 'undulatorLine', 'var' ) )
    undulatorLine = 'HXR';
else
    if ( isnumeric ( undulatorLine ) )
        if ( exist ( 'startCell', 'var' ))
            if ( exist ( 'ZigZag', 'var' ) || ~isnumeric ( startCell ) )
                error ( 'First argument must be ''HXR'' or ''SXR''.' );
            end
            
            xmove         = undulatorLine;
            ymove         = startCell; 
            startCell     = frstMovableHXRQuadCell;  
            ZigZag        = { lastMovableHXRQuadCell, xmove, ymove };
        else
            startCell     = undulatorLine;
        end
        
        undulatorLine = 'HXR';
    elseif ( iscell ( undulatorLine ) )
        ZigZag            = undulatorLine;
        undulatorLine     = 'HXR';
        startCell         = frstMovableHXRQuadCell;
    end
end

Line        = upper ( undulatorLine ( 1 ) );

if ( Line == 'H' )
    UndConsts               = util_HXRUndulatorConstants;
    fmtXCOR                 = 'XCOR:UNDH:%d80';
    fmtYCOR                 = 'YCOR:UNDH:%d80';
    fmtQUAD                 = 'QUAD:UNDH:%d80:BACT';
    
    if ( result.OnlineParmsUsePermit )
        BeamEnergy   = lcaGet ( 'REFS:DMPH:400:EDES' ) * 1e9;  % eV
    else
        BeamEnergy   = 10e9;
    end
else
    UndConsts               = util_SXRUndulatorConstants;
    fmtXCOR                 = 'XCOR:UNDS:%d80';
    fmtYCOR                 = 'YCOR:UNDS:%d80';
    fmtQUAD                 = 'QUAD:UNDS:%d80:BACT';
    
    if ( result.OnlineParmsUsePermit )
        BeamEnergy   = lcaGet ( 'REFS:DMPS:400:EDES' ) * 1e9;  % eV
    else
        BeamEnergy   = 10e9;
    end
end

if ( Line ~='H' && Line ~='S' )
    display ( undulatorLine );
    error ( 'only ''HXR'' or ''SXR'' are allowed as first input parameter' );
end

frstMovableQuadCell         = min ( UndConsts.movableQuadCells );
lastMovableQuadCell         = max ( UndConsts.movableQuadCells );
cellList                    = UndConsts.allCamStages;
cells                       = length ( cellList );

if ( ~exist ( 'startCell', 'var' ) )
    startCell = frstMovableQuadCell;
    ZigZag    = { lastMovableQuadCell, 0, 0 };
else
    if ( iscell ( startCell ) )
        switch nargin
            case 1,
            case 2,
                if ( exist ( 'ZigZag', 'var' ) )
                    if ( ischar ( ZigZag ) )
                        kicker = ZigZag;
                        clear ('ZigZag' );
                    else
                        error ( 'Wrong type of argument' );
                    end
                end
            case 3,
                if ( exist ( 'kicker', 'var' ) )
                    error ( 'Wrong type of argument' );
                else
                    if ( ischar ( ZigZag ) )
                        kicker = ZigZag;
                        clear ('ZigZag' );
                    else
                        error ( 'Wrong type of argument' );
                    end
                end
            otherwise,
                error ( 'Wrong number of arguments' );
        end
        
        ZigZag = startCell;
        clear ( 'startCell' );

        startCell = frstMovableQuadCell;        
    elseif ( ischar ( startCell ) )
        if ( nargin ~= 1 )
            error ( 'Wrong number of arguments' );
        end

        ZigZag = { lastMovableQuadCell, 0, 0 };false
        kicker    = startCell;
        clear ( 'startCell' );
        startCell = frstMovableQuadCell;
    else
        if ( ~exist ( 'ZigZag', 'var' ) )
           ZigZag = { lastMovableQuadCell, 0, 0 };
        else
            if ( ischar ( ZigZag ) )
                if ( nargin ~= 2 )
                    error ( 'Wrong number of arguments' );
                end
                
                kicker = ZigZag;
                clear ( 'ZigZag' );

                ZigZag = { lastMovableQuadCell, 0, 0 };
            else            
                if ( ~iscell ( ZigZag ) )
                    dx        = startCell;
                    dy        = ZigZag;
                    clear ( 'startCell', 'ZigZag' );
                    startCell = frstMovableQuadCell;               
                    ZigZag    = { lastMovableQuadCell, dx, dy }; 
                end
            end
        end
    end
end

if ( exist ( 'kicker', 'var' ) )
    if ( ~ischar ( kicker ) )
        error ( 'Wrong type of argument' );
    end
else
    kicker = 'corr';
end

kicker = lower ( kicker );

switch kicker
    case 'mover',
        result.useMovers = true;
    case 'corr';
        result.useMovers = false;
    otherwise,
        error ( 'kicker needs to be ''mover'' or ''corr''' );
end

[ nKickQuads, m ] = size ( ZigZag );

if ( nKickQuads < 1 ) 
    ZigZag = { lastMovableQuadCell, 0, 0};
    [ nKickQuads, m ] = size ( ZigZag );
end

if ( ~ ismember ( startCell, UndConsts.movableQuadCells ) )
    error ( 'startCell does not contain a movable quadrupole.' );
end

if ( nKickQuads < 1 ) 
    error ( 'At least 1 position needs to be specified.' );
end

if ( m ~= 3 ) 
    error ( 'Specify only girder dx and dy for each position' );
end

for j = 1 : nKickQuads
    if ( ~ismember ( ZigZag { j, 1 }, cellList ) )
        error ( 'Position %d is out of range [%d, %d]', j, frstMovableQuadCell, lastMovableQuadCell ); 
    end
end

if ( nKickQuads > 1 )
    for j = 2 : nKickQuads
        if ( ZigZag { j, 1 } <= ZigZag { j - 1, 1 } )
            error ( 'Position %d in ZigZag array is not after position %d', j, j - 1 ); 
        end
    end
end

if ( ~exist ( 'Comment', 'var' ) )
    Comment = sprintf ( '%s Repointing Changes', undulatorLine );
end

posChanges                 = zeros ( cells, 6 );

quad_zp                    = zeros ( 1, cells ); % Quadrupole z posiitons
us_zp                      = zeros ( 1, cells ); % upstream undulator end z positions
ds_zp                      = zeros ( 1, cells ); % downstream undulator end z positions

dCorrX                     = struct ( [] ); 
dCorrY                     = struct ( [] ); 

% dCorrX(:).PV  => base PV
% dCorrX(:).UL  => upper limit
% dCorrX(:).LL  => lower limit
% dCorrX(:).dsp => setpoint change request
% dCorrX(:).rb1 => initial readback
% dCorrX(:).sp  => new set point
% dCorrX(:).rb2 => final readback

for celNumber = 1 : cells
    cellNo = cellList ( celNumber );
    
    if ( Line == 'H' )
        k                     = cellNo - UndConsts.cellOffset;
        quad_zp ( celNumber ) = UndConsts.Z_QUAD { k };
        us_zp   ( celNumber ) = UndConsts.Z_QUAD { k } - UndConsts.dz_quad_us_start;
        ds_zp   ( celNumber ) = UndConsts.Z_QUAD { k } - UndConsts.dz_quad_us_start + UndConsts.SegmentLength;
    else        
        if ( cellNo == 100 )
            k                     = 35 - UndConsts.cellOffset;
%            k                     = find ( cellList == 35 );
            quad_zp ( celNumber ) = NaN;
            us_zp   ( celNumber ) = UndConsts.Z_QUAD { k } - UndConsts.dz_quad_us_start;
            ds_zp   ( celNumber ) = UndConsts.Z_QUAD { k } - UndConsts.dz_quad_us_start + UndConsts.SegmentLength;
        elseif ( cellNo ~= 35 )
            quad_zp ( celNumber ) = UndConsts.Z_QUAD { celNumber };
            us_zp   ( celNumber ) = UndConsts.Z_QUAD { celNumber } - UndConsts.dz_quad_us_start;
            ds_zp   ( celNumber ) = UndConsts.Z_QUAD { celNumber } - UndConsts.dz_quad_us_start + UndConsts.SegmentLength;
        else
            quad_zp ( celNumber ) = UndConsts.Z_QUAD { celNumber };
            us_zp   ( celNumber ) = NaN;
            ds_zp   ( celNumber ) = NaN;
        end
    end
end

MSG = sprintf ( 'Executing command >> %s(''%s'',%+.0f,{', mfilename, undulatorLine, startCell );

for j = 1 : nKickQuads
    MSG = sprintf ( '%s%+.0f,%+.1f,%+.1f', MSG, ZigZag { j, 1 }, ZigZag { j, 2 }, ZigZag { j, 3 } );
    
    if ( j < nKickQuads )
        MSG = sprintf ( '%s;', MSG );
    end
end

MSG = sprintf ( '%s}, ''%s'');', MSG, kicker );

fprintf ( '%s\n', MSG );

command = MSG;

XquadKickMove                = zeros ( 1, nKickQuads );
YquadKickMove                = zeros ( 1, nKickQuads );
kickQuad                     = struct ( [] ); 
CamAngles_rb                 = readCamAngles ( undulatorLine, cellList );
QuadAlignment_rb             = CamAngles2QuadAlignment ( undulatorLine, cellList, CamAngles_rb );
QuadAlignment_sp             = QuadAlignment_rb;

% The startCell girder will not be repointed but will be the first kick
% girder. If 'mover' is selected, the startCell quadrupole will be moved to
% kick the beam into the first tilted girder section.
kickQuad ( 1 ).c             = startCell;
kickQuad ( 1 ).x             = 0;
kickQuad ( 1 ).y             = 0;
kickQuad ( 1 ).yaw           = 0;
kickQuad ( 1 ).pitch         = 0;

for j = 2 : nKickQuads + 1
    kickQuad ( j ).c         = ZigZag { j - 1, 1 };
    kickQuad ( j ).x         = ZigZag { j - 1, 2 };
    kickQuad ( j ).y         = ZigZag { j - 1, 3 };
end

for j = 2 : nKickQuads + 1
    QuadDist                 = quad_zp ( kickQuad ( j ).c - UndConsts.cellOffset ) - quad_zp ( kickQuad ( j - 1 ).c - UndConsts.cellOffset );  % [m]
    kickQuad ( j ).yaw       = ( kickQuad ( j ).x - kickQuad ( j - 1 ).x ) * 1e-6 / QuadDist; % [rad]
    kickQuad ( j ).pitch     = ( kickQuad ( j ).y - kickQuad ( j - 1 ).y ) * 1e-6 / QuadDist; % [rad]
end

for j = 1 : nKickQuads
    kickQuad ( j ).yawkick   = kickQuad ( j + 1 ).yaw   - kickQuad ( j ).yaw;
    kickQuad ( j ).pitchkick = kickQuad ( j + 1 ).pitch - kickQuad ( j ).pitch;
end

% The following 4 parameters are only used to visualize
% the angle changes in the plots.
xUpstreamUndMove            = zeros ( 1, cells );
yUpstreamUndMove            = zeros ( 1, cells );
xDownstreamUndMove          = zeros ( 1, cells );
yDownstreamUndMove          = zeros ( 1, cells );

totalQuadMoveX              = zeros ( 1, cells );
totalQuadMoveY              = zeros ( 1, cells );
totalQuadMoveYaw            = zeros ( 1, cells );
totalQuadMovePitch          = zeros ( 1, cells );

totalCorrEquiQuadMoveX      = zeros ( 1, cells );
totalCorrEquiQuadMoveY      = zeros ( 1, cells );

for j = 1 : nKickQuads
    c0 = kickQuad ( j ).c - UndConsts.cellOffset;
        
    for celNumber             = kickQuad ( j ).c : kickQuad ( j + 1 ).c
        c1                    = celNumber - UndConsts.cellOffset;
        
        totalQuadMoveX ( c1 ) = kickQuad ( j ).x / 1000 + ( quad_zp ( c1 ) - quad_zp ( c0 ) ) * kickQuad ( j + 1 ).yaw   * 1e3; % [mm]
        totalQuadMoveY ( c1 ) = kickQuad ( j ).y / 1000 + ( quad_zp ( c1 ) - quad_zp ( c0 ) ) * kickQuad ( j + 1 ).pitch * 1e3; % [mm]
        
        if ( celNumber == kickQuad ( j ).c )
            totalQuadMoveYaw   ( c1 ) = kickQuad ( j ).yaw;
            totalQuadMovePitch ( c1 ) = kickQuad ( j ).pitch;
        else
            totalQuadMoveYaw   ( c1 ) = kickQuad ( j + 1 ).yaw;
            totalQuadMovePitch ( c1 ) = kickQuad ( j + 1 ).pitch;
        end
        
        xUpstreamUndMove   ( c1 ) = kickQuad ( j ).x / 1000 + ( quad_zp ( c1 ) - quad_zp ( c0 ) - UndConsts.dz_quad_us_start )                           * kickQuad ( j + 1 ).yaw   * 1e3; % [mm]
        yUpstreamUndMove   ( c1 ) = kickQuad ( j ).y / 1000 + ( quad_zp ( c1 ) - quad_zp ( c0 ) - UndConsts.dz_quad_us_start )                           * kickQuad ( j + 1 ).pitch * 1e3; % [mm]    
        xDownstreamUndMove ( c1 ) = kickQuad ( j ).x / 1000 + ( quad_zp ( c1 ) - quad_zp ( c0 ) - UndConsts.dz_quad_us_start + UndConsts.SegmentLength ) * kickQuad ( j + 1 ).yaw   * 1e3; % [mm]
        yDownstreamUndMove ( c1 ) = kickQuad ( j ).y / 1000 + ( quad_zp ( c1 ) - quad_zp ( c0 ) - UndConsts.dz_quad_us_start + UndConsts.SegmentLength ) * kickQuad ( j + 1 ).pitch * 1e3; % [mm]    
    end
end

% Fill the posChanges array that the function will return
posChanges ( :, 1, 1 ) = quad_zp          ( 1 : cells ) - UndConsts.SegmentLength;
posChanges ( :, 2, 1 ) = quad_zp          ( 1 : cells );
posChanges ( :, 1, 2 ) = xUpstreamUndMove ( 1 : cells ) * 1e3;
posChanges ( :, 2, 2 ) = totalQuadMoveX   ( 1 : cells ) * 1e3;
posChanges ( :, 1, 3 ) = yUpstreamUndMove ( 1 : cells ) * 1e3;
posChanges ( :, 2, 3 ) = totalQuadMoveY   ( 1 : cells ) * 1e3;   

Brho         = BeamEnergy / PhysicsConsts.c;           % Tm

for j = 1 : nKickQuads
    dCorrX ( j ).PV = sprintf ( fmtXCOR, kickQuad ( j ).c );
    dCorrY ( j ).PV = sprintf ( fmtYCOR, kickQuad ( j ).c );
end

if ( result.OnlineParmsUsePermit )
    for j = 1 : nKickQuads
        dCorrX ( j ).UL = lcaGet ( strcat ( dCorrX ( j ).PV, ':BDES.HOPR' ) );
        dCorrY ( j ).UL = lcaGet ( strcat ( dCorrY ( j ).PV, ':BDES.HOPR' ) );
        dCorrX ( j ).LL = lcaGet ( strcat ( dCorrX ( j ).PV, ':BDES.LOPR' ) );
        dCorrY ( j ).LL = lcaGet ( strcat ( dCorrY ( j ).PV, ':BDES.LOPR' ) );
    end
else
    for j = 1 : nKickQuads
        dCorrX ( j ).UL = +0.0055;
        dCorrY ( j ).UL = +0.0055;
        dCorrX ( j ).LL = -0.0055;
        dCorrY ( j ).LL = -0.0055;
    end
end

for j = 1 : nKickQuads
    if ( result.OnlineQuadUsePermit )
        QuadStrength       = lcaGetSmart ( sprintf ( fmtQUAD, kickQuad ( j ).c ) ) / 10;    % T
    else
        if ( any ( ismember ( UndConsts.QFs, kickQuad ( j ).c ) ) )
            QuadStrength = +3;  % T
        elseif ( andy ( ismember ( UndConsts.QDs, kickQuad ( j ). c ) ) )
            QuadStrength = -3;  % T
        else
            QuadStrength =  0;
        end
        
        %        QuadStrength       = 3 * ( -1 )^kickQuad ( j ).c;  % T
    end
    
    %calculate quadrupole moves needed to kick the beam into the repointed
    %beamline.
    XquadKickMove ( j )    =   kickQuad ( j ).yawkick   * Brho / QuadStrength * 1e6; % microns
    YquadKickMove ( j )    = - kickQuad ( j ).pitchkick * Brho / QuadStrength * 1e6; % microns 

    %calculate corrector strengths needed to kick the beam into the
    %repointed beamline.
    %Note: Correctors are designed such that a positive amplitude gives
    % a positive kick in either plane.  
    dCorrX ( j ).dsp       =   kickQuad ( j ).yawkick   * Brho * 10; % kGm
    dCorrY ( j ).dsp       =   kickQuad ( j ).pitchkick * Brho * 10; % kGm
    
    k                      =   kickQuad ( j ).c - UndConsts.cellOffset;
        
    if ( result.useMovers )
        qZs                   = cell2mat ( UndConsts.Z_QUAD );
        qZs ( isnan ( qZs ) ) = [];
        
        QuadSep               = mean ( diff ( qZs ) ) * 1000;

        totalQuadMoveX ( k )  = totalQuadMoveX ( k ) + XquadKickMove ( j ) / 1000; % mm
        totalQuadMoveY ( k )  = totalQuadMoveY ( k ) + YquadKickMove ( j ) / 1000; % mm
                
        if ( j > 1 ) % i.e., if this is not the first kickQuad
            totalQuadMoveYaw   ( k ) = totalQuadMoveYaw   ( k ) + ( totalQuadMoveX ( k ) - totalQuadMoveX ( k - 1 ) ) / QuadSep; % [rad]
            totalQuadMovePitch ( k ) = totalQuadMovePitch ( k ) + ( totalQuadMoveY ( k ) - totalQuadMoveY ( k - 1 ) ) / QuadSep; % [rad]
        else
            totalQuadMoveYaw   ( k ) = totalQuadMoveYaw   ( k ) + totalQuadMoveX ( k ) / QuadSep; % [rad]
            totalQuadMovePitch ( k ) = totalQuadMovePitch ( k ) + totalQuadMoveY ( k ) / QuadSep; % [rad]
        end

        totalQuadMoveYaw   ( k + 1 ) = totalQuadMoveYaw   ( k + 1 ) - XquadKickMove ( j ) / 1000 / QuadSep; % [rad]
        totalQuadMovePitch ( k + 1 ) = totalQuadMovePitch ( k + 1 ) - YquadKickMove ( j ) / 1000 / QuadSep; % [rad]
        
        fprintf ( 'Moving QU%2.2d by distance (% +6.1f µm,% +6.1f µm).\n', ...
            kickQuad      ( j ).c, ...
            XquadKickMove ( j ), ...
            YquadKickMove ( j ) );
    else
        % Calculate quad displacements totalCorrEquiQuadMoveX, totalCorrEquiQuadMoveY that are equivalent to the
        % corrector strengths.
        totalCorrEquiQuadMoveX ( k ) = totalQuadMoveX ( k ) + dCorrX ( j ).dsp / 10 / QuadStrength * 1e6 / 1000; % microns
        totalCorrEquiQuadMoveY ( k ) = totalQuadMoveY ( k ) - dCorrY ( j ).dsp / 10 / QuadStrength * 1e6 / 1000; % microns

        fprintf ( 'Changing COR%2.2d by (% +8.6f kGm,% +8.6f kGm).\n', ...
            kickQuad ( j ).c, ...
            dCorrX ( j ).dsp, ...
            dCorrY ( j ).dsp  ...
        );
    end
end

for j = 1 : nKickQuads
    if ( result.OnlineQuadUsePermit )
        dCorrX ( j ).rb1 = lcaGet ( strcat ( dCorrX ( j ).PV, ':BACT' ) );
        dCorrY ( j ).rb1 = lcaGet ( strcat ( dCorrY ( j ).PV, ':BACT' ) );
    else
        dCorrX ( j ).rb1 = 0;
        dCorrY ( j ).rb1 = 0;
    end

    dCorrX ( j ).sp  = dCorrX ( j ).rb1 + dCorrX ( j ).dsp;
    dCorrY ( j ).sp  = dCorrY ( j ).rb1 + dCorrY ( j ).dsp;
end

if ( result.verbose )
    for j = 1 : nKickQuads
        fprintf ( '%d: rb1: %+9.7f; sp: %+9.7f\n', j, dCorrX ( j ).rb1, dCorrX ( j ).sp )
    end

    for j = 1 : nKickQuads
        fprintf ( '%d: rb1: %+9.7f; sp: %+9.7f\n', j, dCorrY ( j ).rb1, dCorrY ( j ).sp )
    end
end

for celNumber = 1 : cells
    if ( Line == 'H' )
        QuadAlignment_sp ( celNumber, 1 ) = QuadAlignment_sp ( celNumber, 1 ) + totalQuadMoveX     ( celNumber ); % [mm]
        QuadAlignment_sp ( celNumber, 2 ) = QuadAlignment_sp ( celNumber, 2 ) + totalQuadMoveY     ( celNumber ); % [mm]
        QuadAlignment_sp ( celNumber, 4 ) = QuadAlignment_sp ( celNumber, 4 ) + totalQuadMovePitch ( celNumber ); % [rad]
        QuadAlignment_sp ( celNumber, 5 ) = QuadAlignment_sp ( celNumber, 5 ) + totalQuadMoveYaw   ( celNumber ); % [rad]
    else 
        cellNo = cellList ( celNumber );
        
        if ( cellNo == 100 )
            k  = 35 - UndConsts.cellOffset;

            QuadAlignment_sp ( celNumber, 1 ) = QuadAlignment_sp ( celNumber, 1 ) + totalQuadMoveX     ( k ); % [mm]
            QuadAlignment_sp ( celNumber, 2 ) = QuadAlignment_sp ( celNumber, 2 ) + totalQuadMoveY     ( k ); % [mm]
            QuadAlignment_sp ( celNumber, 4 ) = QuadAlignment_sp ( celNumber, 4 ) + totalQuadMovePitch ( k ); % [rad]
            QuadAlignment_sp ( celNumber, 5 ) = QuadAlignment_sp ( celNumber, 5 ) + totalQuadMoveYaw   ( k ); % [rad]
        else
            QuadAlignment_sp ( celNumber, 1 ) = QuadAlignment_sp ( celNumber, 1 ) + totalQuadMoveX     ( celNumber ); % [mm]
            QuadAlignment_sp ( celNumber, 2 ) = QuadAlignment_sp ( celNumber, 2 ) + totalQuadMoveY     ( celNumber ); % [mm]
            QuadAlignment_sp ( celNumber, 4 ) = QuadAlignment_sp ( celNumber, 4 ) + totalQuadMovePitch ( celNumber ); % [rad]
            QuadAlignment_sp ( celNumber, 5 ) = QuadAlignment_sp ( celNumber, 5 ) + totalQuadMoveYaw   ( celNumber ); % [rad]
        end
    end
end

deltaQuadAlignment_sp_rb =  subtractAlignments ( QuadAlignment_sp, QuadAlignment_rb );

changeIndex = findNonZeroAlignments ( deltaQuadAlignment_sp_rb );

if ( result.plotPositionChanges )
    fig = figure ( 2 );
    clf ( fig ); set ( fig, 'color', [ 1 1 1 ] );
    hold on;
    grid on;

    range = zeros ( 1, nKickQuads );
    
    for j = 1 : nKickQuads
        range ( j )= kickQuad ( j ).c - UndConsts.cellOffset;
    end
    
    if ( result.useMovers )
        plot ( quad_zp ( range ), totalQuadMoveX         ( range ) * 1e3, 'sr', ... % dCorrX
               quad_zp ( range ), totalQuadMoveY         ( range ) * 1e3, 'sb', 'MarkerSize', 10 );
    else
        plot ( quad_zp ( range ), totalCorrEquiQuadMoveX ( range ) * 1e3, 'dr', ...
               quad_zp ( range ), totalCorrEquiQuadMoveY ( range ) * 1e3, 'db', 'MarkerSize', 10 );
    end

    plotAlignments ( undulatorLine, cellList, deltaQuadAlignment_sp_rb );
    
    hold off;

    if ( printTo_e_Log )
        util_printLog_wComments ( gcf, 'Nuhn', Comment, command );

        fprintf ( 'sent plots to physics-lclslog.\n' );
    else
        fprintf ( 'Not sending plots to physics-lclslog.\n' );
    end

    if ( fig_to_Files )
        figName = sprintf ( '%s_UndulatorRepointing', datestr ( now,'yyyy-dd-mm_HHMMSS' ) );    

        print ( fig, '-dpdf',  '-r300', figName ); 
        print ( fig, '-djpeg', '-r300', figName ); 
            
        fprintf ( 'Sent figure to files %s (.pdf, .jpg).\n', figName );
    else
        fprintf ( 'Not sending plots to file.\n' );
    end
end

listAlignments ( undulatorLine, cellList, QuadAlignment_sp );

CamAngles_sp = Alignment2CamAngles ( undulatorLine, cellList, QuadAlignment_sp );

%CamAngles_df = CamAngles_rb - CamAngles_sp;

if ( max ( max ( isnan ( CamAngles_sp ) ) ) == 1 )
    zz = max ( isnan ( CamAngles_sp' ) );
    out_of_range_cells = cellList ( zz );
    display ( out_of_range_cells );
    error ( 'The requested motion is out of range in some cells.' );
end

if ( ~result.useMovers )
    for j = 1 : nKickQuads
        if ( dCorrX ( j ).sp > dCorrX ( j ).UL || dCorrX ( j ).sp <  dCorrX ( j ).LL )
            error ( 'Corrector %s [%f kGm] to move outside limits [%f kGm, %f kGm].', ...
                dCorrX ( j ).PV, dCorrX ( j ).sp, dCorrX ( j ).LL, dCorrX ( j ).UL );
        end

        if ( dCorrY ( j ).sp > dCorrY ( j ).UL || dCorrY ( j ).sp <  dCorrY ( j ).LL )
            error ( 'Corrector %s [%f kGm] to move outside limits [%f kGm, %f kGm].', ...
                dCorrY ( j ).PV, dCorrY ( j ).sp, dCorrX ( j ).LL, dCorrY ( j ).UL );
        end
    end
end

if ( result.BYKIKPermit )
    if ( beamEnabled )
        disableBeam;
    end
            
    if ( beamEnabled )
        error ( 'Was unable to operate BYKIK' );
    end
end

if ( result.useRFBPMsPermit )
    XRFBPMoffsets = readRFBPMoffsets ( undulatorLine, 'X' );
    YRFBPMoffsets = readRFBPMoffsets ( undulatorLine, 'Y' );
end
    
for c = 1 : cells
    celNumber = cellList ( c );

    if ( Line == 'H' )
        fprintf ( '%s   starting to move  QU%2.2d by ( %+7.1f, %+7.1f ) microns \n', mfilename, celNumber, ...
                deltaQuadAlignment_sp_rb ( c, 1 ) * 1e3, deltaQuadAlignment_sp_rb ( c, 2 ) * 1e3 );
    else
        if ( celNumber == 100 )
            fprintf ( '%s   starting to move  SS35 by ( %+7.1f, %+7.1f ) microns \n', mfilename, ...
                deltaQuadAlignment_sp_rb ( c, 1 ) * 1e3, deltaQuadAlignment_sp_rb ( c, 2 ) * 1e3 );
        else
            fprintf ( '%s   starting to move  QU%2.2d by ( %+7.1f, %+7.1f ) microns \n', mfilename, celNumber, ...
                deltaQuadAlignment_sp_rb ( c, 1 ) * 1e3, deltaQuadAlignment_sp_rb ( c, 2 ) * 1e3 );
        end
    end
end
    
if ( ~result.useMovers )
    COR_CTRL_PVs = cell  ( 1, 2 * nKickQuads );
    COR_PVs      = cell  ( 1, 2 * nKickQuads );
    BL_NEW       = zeros ( 1, 2 * nKickQuads );
                
    for j = 1 : nKickQuads
        COR_CTRL_PVs { j              } = strcat ( dCorrX ( j ).PV, ':BCTRL' );
        COR_CTRL_PVs { j + nKickQuads } = strcat ( dCorrY ( j ).PV, ':BCTRL' );
            
        COR_PVs      { j              } = dCorrX ( j ).PV;
        COR_PVs      { j + nKickQuads } = dCorrY ( j ).PV;
            
        BL_NEW       ( j              ) = dCorrX ( j ).sp;
        BL_NEW       ( j + nKickQuads ) = dCorrY ( j ).sp;
    end

    if ( result.verbose )
        for j = 1 : 2 * nKickQuads
            fprintf ( '%s: %f\n', COR_PVs { j }, BL_NEW  ( j ) );
        end
    end

    if ( result.OnlineQuadUsePermit && result.controlPermit )
%    	control_magnetSet ( COR_PVs, BL_NEW, 'action', 'TRIM' );
    	lcaPutSmart ( COR_CTRL_PVs, BL_NEW );
    end
end

% Verify that all cam system are availalbe for the move.
if ( result.useCamsPermit && result.controlPermit )
%    camMotorStatus = getCMstatus ( undulatorLine, cellList ( changeIndex ) );

%    if ( any ( camMotorStatus ) )
%        if ( min ( min ( camMotorStatus ) ) == 0 )
%            fprintf ( '\n\nERROR: Some of the cam systems needed for the requested repointing are in an error state.\n' );
%            fprintf ( '       No repointing executed.\n' );
%            return;
%        end
%    end
    
    setCamAngles ( undulatorLine, cellList ( changeIndex ), CamAngles_sp ( changeIndex, : ) );
end

if ( result.useRFBPMsPermit )    
    updateRFBPMoffsets ( undulatorLine, XRFBPMoffsets, YRFBPMoffsets );

    if ( result.useMovers )
        correctRFBPM_D_offsets ( undulatorLine, [ kickQuad(1:nKickQuads).c ], XquadKickMove / 1000, YquadKickMove / 1000 );
    end
end

MSG = sprintf ( 'Executed command >> %s (''%s'',%+.0f,{', mfilename, undulatorLine,startCell );

for j = 1 : nKickQuads
    MSG = sprintf ( '%s%+.0f,%+.1f,%+.1f', MSG, ZigZag { j, 1 }, ZigZag { j, 2 }, ZigZag { j, 3 } );
    
    if ( j < nKickQuads )
        MSG = sprintf ( '%s;', MSG );
    end
end

MSG = sprintf ( '%s}, ''%s'');', MSG, kicker );

%fprintf ( '%s\n', MSG );

if ( result.controlPermit )
	disp_log ( MSG );
else
	fprintf ( '%s\n', MSG );
end

QuadAlignment_fn         = CamAngles2QuadAlignment ( undulatorLine, cellList );
deltaQuadAlignment_fn_rb = subtractAlignments ( QuadAlignment_fn, QuadAlignment_rb );

for c = 1 : cells
    celpos = cellList ( c );
        
    if ( Line == 'H' )
        fprintf ( '%s            moved  QU%2.2d by ( %+7.1f, %+7.1f ) microns \n', mfilename, celpos, ...
                deltaQuadAlignment_fn_rb ( c, 1 ) * 1e3, deltaQuadAlignment_fn_rb ( c, 2 ) * 1e3 );
    else
        if ( celpos == 100 )
            fprintf ( '%s            moved  SS35 by ( %+7.1f, %+7.1f ) microns \n', mfilename, ...
                    deltaQuadAlignment_fn_rb ( c, 1 ) * 1e3, deltaQuadAlignment_fn_rb ( c, 2 ) * 1e3 );
        else
            fprintf ( '%s            moved  QU%2.2d by ( %+7.1f, %+7.1f ) microns \n', mfilename, celpos, ...
                    deltaQuadAlignment_fn_rb ( c, 1 ) * 1e3, deltaQuadAlignment_fn_rb ( c, 2 ) * 1e3 );
        end
    end
end

Fst      = startCell - UndConsts.cellOffset; % Only the range affected by the ZigZag input determines total change angles.
Lst      = ZigZag { nKickQuads, 1 } - UndConsts.cellOffset;

totDist  = quad_zp ( Lst ) - us_zp ( Fst );  % [m]

totYaw   = ( deltaQuadAlignment_fn_rb ( Lst, 1 ) - deltaQuadAlignment_fn_rb ( Fst, 1 ) ) * 1e3 / totDist; % [micro-rad]
totPitch = ( deltaQuadAlignment_fn_rb ( Lst, 2 ) - deltaQuadAlignment_fn_rb ( Fst, 2 ) ) * 1e3 / totDist; % [micro-rad]

fprintf ( '%s           total rotation: ( %+7.1f, %+7.1f ) micro-rad \n', mfilename, totYaw, totPitch );
        
if ( result.controlPermit )
    if ( result.BYKIKPermit )
        if ( ~beamEnabled )
        	enableBeam;
        end
    
        if ( ~beamEnabled )
            error ( 'Was unable to operate BYKIK' );
        end
    end
end

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
    
    pause ( 0.2 );
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

beamPermission = lcaGet ( BYKIK_PV );

if ( strcmp ( beamPermission { 1 }, 'Yes' ) )
    enabled = true;  % Beam is allowed pass BYKIK
else
    enabled = false; % Beam is blocked by BYKIK
end

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


 function success = correctRFBPM_D_offsets ( undulatorLine, cells, xcors, ycors )

X_offsets = readRFBPMoffsets ( undulatorLine, 'X' );
Y_offsets = readRFBPMoffsets ( undulatorLine, 'Y' );

BPMcells  = X_offsets ( :, 1 );

AdjustedCells   = BPMcells ( ismember ( BPMcells, cells ) );

newX_D_offsets = X_offsets ( AdjustedCells, 8 ) + xcors';
newY_D_offsets = Y_offsets ( AdjustedCells, 8 ) + ycors';

Xsuccess = setRFBPMoffsets ( undulatorLine, AdjustedCells, 'X', 'D', newX_D_offsets );
Ysuccess = setRFBPMoffsets ( undulatorLine, AdjustedCells, 'Y', 'D', newY_D_offsets );

success = Xsuccess & Ysuccess;

end


function updateRFBPMoffsets ( undulatorLine, Xbefore_offsets, Ybefore_offsets )

verbose = true;

Xafter_offsets = readRFBPMoffsets ( undulatorLine, 'X' );
Yafter_offsets = readRFBPMoffsets ( undulatorLine, 'Y' );

cellList       = Xafter_offsets ( :, 1 );
cells          = length ( cellList );

difXCAMoffsets = Xafter_offsets  ( :, 4 ) - Xbefore_offsets ( :, 4 );
newXPNToffsets = Xbefore_offsets ( :, 8 ) - difXCAMoffsets;

difYCAMoffsets = Yafter_offsets  ( :, 4 ) - Ybefore_offsets ( :, 4 );
newYPNToffsets = Ybefore_offsets ( :, 8 ) - difYCAMoffsets;

if ( verbose )
    fmt            = { 'AOFF'; 'OFF.B'; 'OFF.C'; 'OFF.D' };
    Line           = upper ( undulatorLine ( 1 ) );

    if ( Line == 'H' )
        UndConsts = util_HXRUndulatorConstants;
    else
        UndConsts = util_SXRUndulatorConstants;
    end

    fprintf ( 'Setting the following RFBPM offsets:\n' );

    for c               = 1 : cells
        cellNo          = cellList ( c );
        special         = find ( UndConsts.specialRFBPMs == cellNo );

        if ( special )
            thisfmt         = [ UndConsts.specialRFBPMbases{special} fmt{4} ];
        else
            thisfmt         = [ UndConsts.regRFBPMbase fmt{4} ];
        end
            
        fprintf ( '%s from %+7.4f mm to %+7.4f mm (change: %+7.4f mm)\n', ...
            sprintf ( thisfmt, cellNo, 'X' ), Xafter_offsets  ( c, 8 ), newXPNToffsets ( c ), -difXCAMoffsets ( c ) );
            
        fprintf ( '%s from %+7.4f mm to %+7.4f mm (change: %+7.4f mm)\n', ...
            sprintf ( thisfmt, cellNo, 'Y' ), Yafter_offsets  ( c, 8 ), newYPNToffsets ( c ), -difYCAMoffsets ( c ) );
    end
end

idx = find ( ~isnan ( newXPNToffsets ) );

%function  success = setRFBPMoffsets ( undulatorLine, cellList, coordinate, offsetLabels, offsets )

setRFBPMoffsets ( undulatorLine, cellList ( idx ), 'X', 'D', newXPNToffsets ( idx ) );
setRFBPMoffsets ( undulatorLine, cellList ( idx ), 'Y', 'D', newYPNToffsets ( idx ) );

%lcaPut ( RFBPMoffsetPVs.PNToffset, new_offsets.PNT );

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


function NonZeroIndex = findNonZeroAlignments ( A )

[ n, ~ ] = size ( A );

B = zeros ( n, 1 );

for j = 1 : n;
    B ( j ) = sum ( A ( j, [ 1 2 4 5 6 ] ).^2 );
end

NonZeroIndex = find ( B ~= 0 );

end
