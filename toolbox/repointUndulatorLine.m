function repointUndulatorLine ( dx1, dy1, dx2, dy2 )
%
%  repointUndulatorLine ( dx1, dy1, dx2, dy2 );
%
% Moves all 33 undulators segments keeping their
% relative alignment with respect to a straight
% line intact.
%
% The input parameters are:
% dx1 = change in x - position of BFW01 [microns] 
% dy1 = change in x - position of BFW01 [microns] 
% dx2 = change in x - position of QU33  [microns]
% dy2 = change in x - position of QU33  [microns]
%
% The function uses the LTU correctors
%  XCOR:LTU1:758
%  XCOR:LTU1:878
%  YCOR:LTU1:747
%  YCOR:LTU1:857
%  and the DMP correctors
%  xxx
% To keep the trajectory on the moving straight line.
%
% Last updated by Heinz-Dieter Nuhn on January 20, 2015.

global result;

result.BYKIKPermit  = true;
result.motionPermit = true;
result.correctExit  = false;

geo                 = girderGeo;
UndConsts           = util_UndulatorConstants;
segmentList         = 1 : 33;
segments            = length ( segmentList );

bfw_zp              = zeros ( 1, segments );
quad_zp             = zeros ( 1, segments );

[ bfw_rb quad_rb ]  = girderAxisFromCamAngles ( segmentList, geo.bfwz, geo.quadz );

for segment = segmentList
    bfw_zp  ( segment ) = UndConsts.Z_BFW  { segment };
    quad_zp ( segment ) = UndConsts.Z_QUAD { segment };
end

if ( ~exist ( 'dx1', 'var' ) )
    dx1 = 0;
end

if ( ~exist ( 'dx2', 'var' ) )
    dx2 = 0;
end
if ( ~exist ( 'dy1', 'var' ) )
    dy1 = 0;
end

if ( ~exist ( 'dy2', 'var' ) )
    dy2 = 0;
end

fprintf ( 'Executing command >> %s ( %+4.0f, %+4.0f, %+4.0f, %+4.0f );\n', mfilename, dx1, dy1, dx2, dy2  );

Dist  = quad_zp ( 33 ) - bfw_zp ( 1 );  % [m]
Yaw   = ( dx2 - dx1 ) * 1e-6 / Dist;    % [rad]
Pitch = ( dy2 - dy1 ) * 1e-6 / Dist;    % [rad]

bfw_sp  = bfw_rb;
quad_sp = quad_rb;

dxb = dx1;                                                   % [microns]
dyb = dy1;                                                   % [microns]
dxq = dxb + ( quad_zp ( 33 ) - bfw_zp ( 1 ) ) * Yaw   * 1e6; % [microns] 
dyq = dyb + ( quad_zp ( 33 ) - bfw_zp ( 1 ) ) * Pitch * 1e6; % [microns]

%bfw_sp  ( segmentList, 1 ) = bfw_sp  ( segmentList, 1 ) + dx1 / 1000 + ( ( bfw_zp  ( segmentList ) - bfw_zp  ( 1 ) ) * Yaw )   * 1e3; % [mm]
%bfw_sp  ( segmentList, 2 ) = bfw_sp  ( segmentList, 2 ) + dy1 / 1000 + ( ( bfw_zp  ( segmentList ) - bfw_zp  ( 1 ) ) * Pitch ) * 1e3; % [mm]
%quad_sp ( segmentList, 1 ) = quad_sp ( segmentList, 1 ) + dx1 / 1000 + ( ( quad_zp ( segmentList ) - bfw_zp  ( 1 ) ) * Yaw )   * 1e3; % [mm]
%quad_sp ( segmentList, 2 ) = quad_sp ( segmentList, 2 ) + dy1 / 1000 + ( ( quad_zp ( segmentList ) - bfw_zp  ( 1 ) ) * Pitch ) * 1e3; % [mm]    

for segment = segmentList
    bfw_sp  ( segment, 1 ) = bfw_sp  ( segment, 1 ) + dx1 / 1000 + ( ( bfw_zp  ( segment ) - bfw_zp  ( 1 ) ) * Yaw )   * 1e3; % [mm]
    bfw_sp  ( segment, 2 ) = bfw_sp  ( segment, 2 ) + dy1 / 1000 + ( ( bfw_zp  ( segment ) - bfw_zp  ( 1 ) ) * Pitch ) * 1e3; % [mm]
    quad_sp ( segment, 1 ) = quad_sp ( segment, 1 ) + dx1 / 1000 + ( ( quad_zp ( segment ) - bfw_zp  ( 1 ) ) * Yaw )   * 1e3; % [mm]
    quad_sp ( segment, 2 ) = quad_sp ( segment, 2 ) + dy1 / 1000 + ( ( quad_zp ( segment ) - bfw_zp  ( 1 ) ) * Pitch ) * 1e3; % [mm]    
end

maxCAMrequest = max ( max ( max ( bfw_sp ( :, 1 : 2 ), quad_sp  ( :, 1 : 2 ) ) ) );
minCAMrequest = min ( min ( min ( bfw_sp ( :, 1 : 2 ), quad_sp  ( :, 1 : 2 ) ) ) );

if ( maxCAMrequest > 1.400 || minCAMrequest < -1.400 )
   error ( 'Motion request would required some girder to move outside of +/- 1.4 mm range.' );
end

iniRFBPMoffsetPVs;

if ( result.motionPermit )
    if ( result.BYKIKPermit )
        if ( beamEnabled )
           disableBeam;
        end
    
        if ( beamEnabled )
            error ( 'Was unable to operate BYKIK' );
        end
    end

    MSG01 = sprintf ( 'Executing command >> %s ( %+4.0f, %+4.0f, %+4.0f, %+4.0f );\n', mfilename, dx1, dy1, dx2, dy2  );
    disp_log ( MSG01 );
    
    RFBPMoffsets = getRFBPMoffsets;

    fprintf ( 'About to change QU33 by ( %+7.1f, %+7.1f ) microns \n', ...
        ( quad_sp ( 33, 1 ) - quad_rb ( 33, 1 ) ) * 1e3, ( quad_sp ( 33, 2 ) - quad_rb ( 33, 2 ) ) * 1e3 );
    
    girderAxisSet  ( segmentList, bfw_sp,  quad_sp );
    girderCamWait  ( segmentList );

    adjustLaunch ( [ dxb/1e6, Yaw, dyb/1e6, Pitch ] );
    
    if ( result.correctExit )
        correctExit  ( [ dxq/1e6, Yaw, dyq/1e6, Pitch ] );
    end
    
    setRFBPMoffsets  ( RFBPMoffsets );
    preBPMcorrection ( RFBPMoffsets, dx1, Yaw, dy1, Pitch );

    [ bfw_fn quad_fn ]  = girderAxisFromCamAngles ( segmentList, geo.bfwz, geo.quadz ); % [mm]

    disp_log ( sprintf ( '%s: Repointing completed:\n', mfilename ) );
    
    dx_bfw_01  = ( bfw_fn  ( 01, 1 ) - bfw_rb  ( 01, 1 ) ) * 1e3; % [microns]
    dy_bfw_01  = ( bfw_fn  ( 01, 2 ) - bfw_rb  ( 01, 2 ) ) * 1e3; % [microns]
    dx_quad_33 = ( quad_fn ( 33, 1 ) - quad_rb ( 33, 1 ) ) * 1e3; % [microns]
    dy_quad_33 = ( quad_fn ( 33, 2 ) - quad_rb ( 33, 2 ) ) * 1e3; % [microns]
    Yaw_act    = ( dx_quad_33 - dx_bfw_01 ) / Dist; % [micro-rad]
    Pitch_act  = ( dy_quad_33 - dy_bfw_01 ) / Dist; % [micro-rad]
    
    MSG02 = sprintf ( '                       moved BFW01 by ( %+7.1f, %+7.1f ) microns \n', dx_bfw_01, dy_bfw_01 );
    disp_log ( MSG02 );

    MSG03 = sprintf ( '                              QU33 by ( %+7.1f, %+7.1f ) microns \n', dx_quad_33, dy_quad_33 );
    disp_log ( MSG03 );

    disp_log ( sprintf ( '%s: Total rotation: ( %+7.1f, %+7.1f ) micro-rad\n', mfilename, Yaw_act, Pitch_act ) );

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


function adjustLaunch ( BFW01posChange )
%
% BFW01posChange ( 1 ) = x  [m]   @ BFW01
% BFW01posChange ( 2 ) = x' [rad] @ BFW01
% BFW01posChange ( 3 ) = y  [m]   @ BFW01
% BFW01posChange ( 4 ) = y' [rad] @ BFW01
%

global modelSource;
global modelOnline;

PhyConsts   = util_PhysicsConstants;
modelSource = 'EPICS';
modelOnline = 0;

BeamEnergy  = lcaGet ( 'BEND:DMP1:400:BACT' );    % GeV
Brho        = BeamEnergy * 1e9 / PhyConsts.c;     % Tm

COR_PVs     = { 'XCOR:LTU1:758', 'XCOR:LTU1:878', 'YCOR:LTU1:747', 'YCOR:LTU1:857' }';
%COR_PVs     = { 'XCOR:LTU1:818', 'XCOR:LTU1:878', 'YCOR:LTU1:837',
%'YCOR:LTU1:857' }';
BFW_PV      = { 'BFW:UND1:110' };
pos_SIG     = { 'x', 'x''', 'y', 'y''' };
pos_EGU     = { 'microns', 'micro-rad', 'microns', 'micro-rad'};

XC1         = 1;
XC2         = 2;
YC1         = 3;
YC2         = 4;

R           = model_rMatGet ( COR_PVs, BFW_PV );

XC1_R12     = R ( 1, 2, XC1 );
YC1_R12     = R ( 1, 2, YC1 );
XC2_R12     = R ( 1, 2, XC2 );
YC2_R12     = R ( 1, 2, YC2 );
XC1_R22     = R ( 2, 2, XC1 );
YC1_R22     = R ( 2, 2, YC1 );
XC2_R22     = R ( 2, 2, XC2 );
YC2_R22     = R ( 2, 2, YC2 );

M           = [ XC1_R12, XC2_R12,       0,       0; ...
                XC1_R22, XC2_R22,       0,       0; ...
                      0,       0, YC1_R12, YC2_R12; ...
                      0,       0, YC1_R22, YC2_R22 ];

%kik_COR     = inv ( M ) * BFW01posChange';
kik_COR     = M \ BFW01posChange';
BL_COR      = kik_COR * Brho * 10; % kGm
BL_INI      = lcaGet ( strcat ( COR_PVs, ':BACT' ) );
BL_NEW      = BL_COR + BL_INI;

fprintf ( 'Required kicks:\n' );

for j = 1 : length ( COR_PVs )
    fprintf ( ' %s = %+8.4f micro-rad (%+9.6f kGm)\n', COR_PVs { j }, kik_COR ( j ) * 1e6, BL_COR ( j ) );
end

fprintf ( 'in order for the following changes at %s\n', BFW_PV { 1 } );

for j = 1 : length ( pos_SIG )
    fprintf ( ' %s = %+7.4f %s\n', pos_SIG { j }, BFW01posChange ( j ) * 1e6, pos_EGU { j } );
end

% Apply corrector adjustments

for j = 1 : length ( COR_PVs )
    fprintf ( 'About to change %s from %+9.6f kGm to %+9.6f kGm by %+9.6f kGm\n', ...
        COR_PVs { j }, BL_INI ( j ), BL_NEW ( j ), BL_COR ( j ) );
%    trim_magnet ( strrep ( COR_PVs { j }, BL_COR ( j ), 'T' ) );
end

%trim_magnet ( COR_PVs, BL_NEW, 'T' );
control_magnetSet ( COR_PVs, BL_NEW, 'action', 'TRIM' );

%pause ( 2.0 );

% enable Undulator launch feedback

end


function correctExit ( QU33posChange )
%
% QU33posChange ( 1 ) = x  [m]   @ QU33
% QU33posChange ( 2 ) = x' [rad] @ QU33
% QU33posChange ( 3 ) = y  [m]   @ QU33
% QU33posChange ( 4 ) = y' [rad] @ QU33
%

global modelSource;
global modelOnline;

PhyConsts   = util_PhysicsConstants;
modelSource = 'EPICS';
modelOnline = 0;

BeamEnergy  = lcaGet ( 'BEND:DMP1:400:BACT' );    % GeV
Brho        = BeamEnergy * 1e9 / PhyConsts.c;     % Tm

QUAD_PV     = { 'QUAD:UND1:3380' };
COR_PVs     = { 'XCOR:DMP1:201', 'XCOR:DMP1:392', 'YCOR:DMP1:298', 'YCOR:DMP1:391' }';
pos_SIG     = { 'x', 'x''', 'y', 'y''' };
pos_EGU     = { 'microns', 'micro-rad', 'microns', 'micro-rad'};

XC1         = 1;
XC2         = 2;
YC1         = 3;
YC2         = 4;

R           = model_rMatGet ( COR_PVs, QUAD_PV );

XC1_R12     = R ( 1, 2, XC1 );
YC1_R12     = R ( 1, 2, YC1 );
XC2_R12     = R ( 1, 2, XC2 );
YC2_R12     = R ( 1, 2, YC2 );
XC1_R22     = R ( 2, 2, XC1 );
YC1_R22     = R ( 2, 2, YC1 );
XC2_R22     = R ( 2, 2, XC2 );
YC2_R22     = R ( 2, 2, YC2 );

M           = [ XC1_R12, XC2_R12,       0,       0; ...
                XC1_R22, XC2_R22,       0,       0; ...
                      0,       0, YC1_R12, YC2_R12; ...
                      0,       0, YC1_R22, YC2_R22 ];

kik_COR     = -1 * inv ( M ) * QU33posChange';
BL_COR      = kik_COR * Brho * 10; % kGm
BL_INI      = lcaGet ( strcat ( COR_PVs, ':BACT' ) );
BL_NEW      = BL_COR + BL_INI;

fprintf ( 'Required kicks:\n' );

for j = 1 : length ( COR_PVs )
    fprintf ( ' %s = %+8.4f micro-rad (%+9.6f kGm)\n', COR_PVs { j }, kik_COR ( j ) * 1e6, BL_COR ( j ) );
end

fprintf ( 'in order to correct for the following changes at %s\n', QUAD_PV { 1 } );

for j = 1 : length ( pos_SIG )
    fprintf ( ' %s = %+7.4f %s\n', pos_SIG { j }, QU33posChange ( j ) * 1e6, pos_EGU { j } );
end

% disable Undulator launch feedback [NOT NECESSARY IF BEAM IS DISABLED]

for j = 1 : length ( COR_PVs )
    fprintf ( 'About to change %s from %+9.6f kGm to %+9.6f kGm by %+9.6f kGm\n', ...
        COR_PVs { j }, BL_INI ( j ), BL_NEW ( j ), BL_COR ( j ) );
end

%trim_magnet ( COR_PVs, BL_NEW, 'T' );
control_magnetSet ( COR_PVs, BL_NEW, 'action', 'TRIM' );

%pause ( 2.0 );

% enable Undulator launch feedback

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

function iniRFBPMoffsetPVs

global RFBPMoffsetPVs;

RFBPMoffsetPVs.verbose     = false;
RFBPMoffsetPVs.preBPMs     =  3;
RFBPMoffsetPVs.nGirders    = 33;
RFBPMoffsetPVs.nBPMs       = RFBPMoffsetPVs.preBPMs + RFBPMoffsetPVs.nGirders;
RFBPMoffsetPVs.nPVs        = 2 * RFBPMoffsetPVs.nBPMs;
RFBPMoffsetPVs.index       = zeros ( 2, RFBPMoffsetPVs.nBPMs );

RFBPMoffsetPVs.BPMoffset   = cell ( RFBPMoffsetPVs.nPVs, 1 );
RFBPMoffsetPVs.CAMoffset   = cell ( RFBPMoffsetPVs.nPVs, 1 );
RFBPMoffsetPVs.SLDoffset   = cell ( RFBPMoffsetPVs.nPVs, 1 );
RFBPMoffsetPVs.PNToffset   = cell ( RFBPMoffsetPVs.nPVs, 1 );

nBPMs = RFBPMoffsetPVs.nBPMs;

%1%UnitStr = cell  ( nBPms, 1 );
%1%UnitStr { 1 }  = 'LTU1:910';
%1%UnitStr { 2 }  = 'LTU1:960';
%1%UnitStr { 3 }  = 'UND1:100';
%1%for g = 1 : RFBPMoffsetPVs.nGirders
%1%    UnitStr { g + 3 }  = sprintf ('UND1:%d90', g );;
%1%end

index = 0;

index                                  = index + 1;

RFBPMoffsetPVs.index     ( 1, index )  = 1;
RFBPMoffsetPVs.index     ( 2, index )  = 1 + nBPMs;

RFBPMoffsetPVs.BPMoffset {         1 } = sprintf ( 'BPMS:LTU1:910:XAOFF'  );
RFBPMoffsetPVs.BPMoffset { nBPMs + 1 } = sprintf ( 'BPMS:LTU1:910:YAOFF'  );
RFBPMoffsetPVs.CAMoffset {         1 } = sprintf ( 'BPMS:LTU1:910:XOFF.B' );
RFBPMoffsetPVs.CAMoffset { nBPMs + 1 } = sprintf ( 'BPMS:LTU1:910:YOFF.B' );
RFBPMoffsetPVs.SLDoffset {         1 } = sprintf ( 'BPMS:LTU1:910:XOFF.C' );
RFBPMoffsetPVs.SLDoffset { nBPMs + 1 } = sprintf ( 'BPMS:LTU1:910:YOFF.C' );
RFBPMoffsetPVs.PNToffset {         1 } = sprintf ( 'BPMS:LTU1:910:XOFF.D' );
RFBPMoffsetPVs.PNToffset { nBPMs + 1 } = sprintf ( 'BPMS:LTU1:910:YOFF.D' );

index                                  = index + 1;

RFBPMoffsetPVs.index     ( 1, index )  = 2;
RFBPMoffsetPVs.index     ( 2, index )  = 2 + nBPMs;

RFBPMoffsetPVs.BPMoffset {         2 } = sprintf ( 'BPMS:LTU1:960:XAOFF'  );
RFBPMoffsetPVs.BPMoffset { nBPMs + 2 } = sprintf ( 'BPMS:LTU1:960:YAOFF'  );
RFBPMoffsetPVs.CAMoffset {         2 } = sprintf ( 'BPMS:LTU1:960:XOFF.B' );
RFBPMoffsetPVs.CAMoffset { nBPMs + 2 } = sprintf ( 'BPMS:LTU1:960:YOFF.B' );
RFBPMoffsetPVs.SLDoffset {         2 } = sprintf ( 'BPMS:LTU1:960:XOFF.C' );
RFBPMoffsetPVs.SLDoffset { nBPMs + 2 } = sprintf ( 'BPMS:LTU1:960:YOFF.C' );
RFBPMoffsetPVs.PNToffset {         2 } = sprintf ( 'BPMS:LTU1:960:XOFF.D' );
RFBPMoffsetPVs.PNToffset { nBPMs + 2 } = sprintf ( 'BPMS:LTU1:960:YOFF.D' );

index                                  = index + 1;

RFBPMoffsetPVs.index     ( 1, index )  = 3;
RFBPMoffsetPVs.index     ( 2, index )  = 3 + nBPMs;

RFBPMoffsetPVs.BPMoffset {         3 } = sprintf ( 'BPMS:UND1:100:XAOFF'  );
RFBPMoffsetPVs.BPMoffset { nBPMs + 3 } = sprintf ( 'BPMS:UND1:100:YAOFF'  );
RFBPMoffsetPVs.CAMoffset {         3 } = sprintf ( 'BPMS:UND1:100:XOFF.B' );
RFBPMoffsetPVs.CAMoffset { nBPMs + 3 } = sprintf ( 'BPMS:UND1:100:YOFF.B' );
RFBPMoffsetPVs.SLDoffset {         3 } = sprintf ( 'BPMS:UND1:100:XOFF.C' );
RFBPMoffsetPVs.SLDoffset { nBPMs + 3 } = sprintf ( 'BPMS:UND1:100:YOFF.C' );
RFBPMoffsetPVs.PNToffset {         3 } = sprintf ( 'BPMS:UND1:100:XOFF.D' );
RFBPMoffsetPVs.PNToffset { nBPMs + 3 } = sprintf ( 'BPMS:UND1:100:YOFF.D' );

for SN = 1 : RFBPMoffsetPVs.nGirders
    jX = SN +  RFBPMoffsetPVs.preBPMs;
    jY = SN +  RFBPMoffsetPVs.preBPMs + nBPMs;
    
    index                                  = index + 1;

    RFBPMoffsetPVs.index     ( 1, index )  = jX;
    RFBPMoffsetPVs.index     ( 2, index )  = jY;

    RFBPMoffsetPVs.BPMoffset { jX } = sprintf ( 'BPMS:UND1:%d90:XAOFF',  SN );
    RFBPMoffsetPVs.BPMoffset { jY } = sprintf ( 'BPMS:UND1:%d90:YAOFF',  SN );
    RFBPMoffsetPVs.CAMoffset { jX } = sprintf ( 'BPMS:UND1:%d90:XOFF.B', SN );
    RFBPMoffsetPVs.CAMoffset { jY } = sprintf ( 'BPMS:UND1:%d90:YOFF.B', SN );
    RFBPMoffsetPVs.SLDoffset { jX } = sprintf ( 'BPMS:UND1:%d90:XOFF.C', SN );
    RFBPMoffsetPVs.SLDoffset { jY } = sprintf ( 'BPMS:UND1:%d90:YOFF.C', SN );
    RFBPMoffsetPVs.PNToffset { jX } = sprintf ( 'BPMS:UND1:%d90:XOFF.D', SN );
    RFBPMoffsetPVs.PNToffset { jY } = sprintf ( 'BPMS:UND1:%d90:YOFF.D', SN );
end

if ( RFBPMoffsetPVs.verbose )
    for j = 1 : RFBPMoffsetPVs.nPVs
        fprintf ( '%2.2d: %s\n', j, RFBPMoffsetPVs.BPMoffset { j } );
        fprintf ( '%2.2d: %s\n', j, RFBPMoffsetPVs.CAMoffset { j } );
        fprintf ( '%2.2d: %s\n', j, RFBPMoffsetPVs.SLDoffset { j } );
        fprintf ( '%2.2d: %s\n', j, RFBPMoffsetPVs.PNToffset { j } );
    end
end

end

function offsets = getRFBPMoffsets

global RFBPMoffsetPVs;

offsets.BPM = lcaGetSmart ( RFBPMoffsetPVs.BPMoffset );
offsets.CAM = lcaGetSmart ( RFBPMoffsetPVs.CAMoffset );
offsets.SLD = lcaGetSmart ( RFBPMoffsetPVs.SLDoffset );
offsets.PNT = lcaGetSmart ( RFBPMoffsetPVs.PNToffset );

for j = 1 : RFBPMoffsetPVs.nBPMs
    jx = RFBPMoffsetPVs.index     ( 1, j );
    jy = RFBPMoffsetPVs.index     ( 2, j );
    
    fprintf ( 'BPM %2.2d: (%+6.3f,%+6.3f); CAM: (%+6.3f,%+6.3f); SLD: (%+6.3f,%+6.3f); PNT: (%+6.3f,%+6.3f).\n', ...
               j - 3, ...
               offsets.BPM ( jx ), offsets.BPM ( jy ), ...
               offsets.CAM ( jx ), offsets.CAM ( jy ), ...
               offsets.SLD ( jx ), offsets.SLD ( jy ), ...
               offsets.PNT ( jx ), offsets.PNT ( jy )  ...
            );
end

end


function setRFBPMoffsets ( before_offsets )

global RFBPMoffsetPVs;

verbose = true;

after_offsets   = getRFBPMoffsets;

dif_offsets.PNT = before_offsets.CAM - after_offsets.CAM;
new_offsets.PNT = after_offsets.PNT  + dif_offsets.PNT;

if ( verbose )
    fprintf ( 'Setting the following RFBPM offsets:\n' );

    for j = 1 : RFBPMoffsetPVs.nPVs
        fprintf ( '%s from %+7.4f mm to %+7.4f mm (change: %+7.4f mm)\n', ...
            RFBPMoffsetPVs.PNToffset { j }, after_offsets.PNT ( j ), new_offsets.PNT ( j ), dif_offsets.PNT ( j ) );
    end
end

lcaPutSmart ( RFBPMoffsetPVs.PNToffset, new_offsets.PNT );

final_offsets   = getRFBPMoffsets;

for j = 1 : RFBPMoffsetPVs.nPVs
    if ( new_offsets.PNT ( j ) ~= final_offsets.PNT ( j ) )
        fprintf ( 'Error: %s: expected %f found %f\n', RFBPMoffsetPVs.PNToffset { j }, new_offsets.PNT ( j ), final_offsets.PNT ( j ) );
    end
end

end


function preBPMcorrection ( before_offsets, dx1, Yaw, dy1, Pitch )
% dx1   [mircrons]
% Yaw   [rad]
% dx1   [mircrons]
% Pitch [rad]

global RFBPMoffsetPVs;

UndConsts     = util_UndulatorConstants;
verbose       = true;

nBPMs         = RFBPMoffsetPVs.nBPMs;

PNTprePVs       = cell  ( 4, 1 );
dif_offsets.PNT = zeros ( 4, 1 );
new_offsets.PNT = zeros ( 4, 1 );

index                = [ 1, nBPMs+1, 2, nBPMs+2 ];

zRFB07 = 508.56; % [m]
zRFB08 = 511.26; % [m]

dif_offsets.PNT  ( 1 ) = dx1 / 1000 + Yaw   * ( zRFB07 - UndConsts.Z_BFW  { 1 } ) * 1000; % [mm]
dif_offsets.PNT  ( 2 ) = dy1 / 1000 + Pitch * ( zRFB07 - UndConsts.Z_BFW  { 1 } ) * 1000; % [mm]
dif_offsets.PNT  ( 3 ) = dx1 / 1000 + Yaw   * ( zRFB08 - UndConsts.Z_BFW  { 1 } ) * 1000; % [mm]
dif_offsets.PNT  ( 4 ) = dy1 / 1000 + Pitch * ( zRFB08 - UndConsts.Z_BFW  { 1 } ) * 1000; % [mm]

PNTprePVs { 1 } = RFBPMoffsetPVs.PNToffset { index ( 1 ) };
PNTprePVs { 2 } = RFBPMoffsetPVs.PNToffset { index ( 2 ) };
PNTprePVs { 3 } = RFBPMoffsetPVs.PNToffset { index ( 3 ) };
PNTprePVs { 4 } = RFBPMoffsetPVs.PNToffset { index ( 4 ) };

new_offsets.PNT  ( 1 ) = before_offsets.PNT ( index ( 1 ) )  - dif_offsets.PNT  ( 1 );
new_offsets.PNT  ( 2 ) = before_offsets.PNT ( index ( 2 ) )  - dif_offsets.PNT  ( 2 );
new_offsets.PNT  ( 3 ) = before_offsets.PNT ( index ( 3 ) )  - dif_offsets.PNT  ( 3 );
new_offsets.PNT  ( 4 ) = before_offsets.PNT ( index ( 4 ) )  - dif_offsets.PNT  ( 4 );

if ( verbose )
    fprintf ( 'Correcting the following RFBPM offsets:\n' );

    for j = 1 : 4
        fprintf ( '%s from %+7.4f mm to %+7.4f mm (change: %+7.4f mm)\n', ...
            PNTprePVs { j }, before_offsets.PNT ( index ( j ) ), new_offsets.PNT ( j ), dif_offsets.PNT ( j ) );
    end
end

lcaPutSmart ( PNTprePVs, new_offsets.PNT );

final_offsets   = getRFBPMoffsets;

for j = 1 : 4
    if ( new_offsets.PNT ( j ) ~= final_offsets.PNT ( index ( j ) ) )
        fprintf ( 'Error: %s: expected %f mm found %f mm.\n', PNTprePVs { j }, new_offsets.PNT ( j ), final_offsets.PNT ( index ( j ) ) ) 
    end
end

end

