function CAM = getArchivedGirderPositions ( timeStamp )
%
% Usage:
% >> [ CAM ] = getArchivedGirderPositions ( '02/24/2009 16:30:00' );
%

segmentList   = 1 : 33;

listPositions = false;
segments      = length ( segmentList );

if ( ~exist ( 'timeStamp', 'var' ) )
    CAM.finalTime = sprintf ( '%s', datestr ( now,'mm/dd/yyyy HH:MM:SS' ) );
else
    CAM.finalTime = timeStamp;
end

CAM.finalTime = sprintf ( '%s', datestr ( datenum ( CAM.finalTime ),'mm/dd/yyyy HH:MM:SS' ) );
CAM.startTime = sprintf ( '%s', datestr ( datenum ( CAM.finalTime ) - 0.25/24,'mm/dd/yyyy HH:MM:SS' ) );
range      = 'last';

fprintf ( 'Executing command:\n' );
fprintf ( '%s ( ''%s'' );\n', mfilename, CAM.finalTime );

CAM.motors      = { '1', '2', '3', '4', '5' };
CAM.segmentList = segmentList;
CAM.segments    = segments;
CAM.nmot        = length ( CAM.motors );
CAM.PVindex     = zeros ( CAM.segments, CAM.nmot );
CAM.nPVs        = CAM.segments * CAM.nmot; 
CAM.PVs         = cell ( CAM.nPVs, 1 );

PVindex         = 0;

for s = 1 : CAM.segments
    slot = segmentList ( s );

    for m = 1 : CAM.nmot
        PVindex              = PVindex + 1;
        CAM.PVindex ( s, m ) = PVindex;
        CAM.PVs { PVindex }  = sprintf ( 'USEG:UND1:%d50:CM%sMOTOR.RBV', slot, CAM.motors { m } );
    end
end

[ CAM.data, success ] = readArchivedData ( CAM, CAM.startTime, CAM.finalTime, range );

if ( ~success )
    error ( 'Unable to read archived CAM data.' );
end

CAM.data    = interpolateArchivedData ( CAM.data, CAM.startTime, CAM.finalTime );
CAM.values = array2CAM ( CAM.data, CAM.segmentList, CAM.PVindex, girderGeo );

if ( listPositions )
    fprintf ( 'Girder Position Listing: Matlab (EPICS) variables in microns.\n' );
    
    for s = 1 : segments
        jb = ( s - 1 ) * 2 + 1;
        jq = ( s - 1 ) * 2 + 2;

        refdate = datestr ( CAM.values.t ( end ), 'dd-mmm-yyyy HH:MM:SS' );

        fprintf ( '%s; g%2.2d; xq: %+5.0f, yq: %+5.0f; xb: %+5.0f, yb: %+5.0f\n', ...
            refdate, s, ...
            CAM.values.x { jb } ( end ), ...
            CAM.values.y { jb } ( end ), ...
            CAM.values.x { jq } ( end ),...
            CAM.values.y { jq } ( end ) );        
    end
end

    
end


function [ ArchivedData, success ] = readArchivedData ( PVinfo, startTime, finalTime, range )

ArchivedData = cell ( 2, PVinfo.nPVs );
success      = true;
timeRange    = { startTime; finalTime };

for PV = 1 : PVinfo.nPVs

    try
        [ time, T ] = history ( PVinfo.PVs { PV }, timeRange, 'verbose', 0 );
    catch
        success = false;
    end

    if ( ~success )
       fprintf ( 'Failed getting AIDA parameter => %s (%s - %s)\n', AIDA_Name, timeRange { 1 }, timeRange { 2 } );
       return;
    end

    if ( strcmp ( range, 'last' ) )
        ArchivedData { 1, PV } = T ( length ( T ) );
        ArchivedData { 2, PV } = time ( length ( T ) );
    else
        ArchivedData { 1, PV } = T;
        ArchivedData { 2, PV } = time;
    end
end

end


function newCAMdata = interpolateArchivedData ( CAMdata, start, final )

startTime   = datenum ( start );
finalTime   = datenum ( final );
n           = length ( CAMdata );
newCAMdata  = cell ( 2, n );
dt          = 1e-9;
timeStep    = 1 / ( 3600 * 24 ); % 1 second
newTime     = startTime : timeStep : finalTime;


for j = 1 : n
    entries = length ( CAMdata { 1, j } );
    m       = entries;

    for k = 2 : entries 
        if ( CAMdata { 2, j } ( k ) == CAMdata { 2, j } ( k - 1 ) )
            for s = k : entries
                CAMdata { 2, j } ( s ) = CAMdata { 2, j } ( s ) + dt;
            end
        end
    end
    
    if ( CAMdata { 2, j } ( 1 ) > startTime )
        m      = m + 1;
        mstart = 2;
    else
        mstart = 1;
    end
    
    if ( CAMdata { 2, j } ( entries ) < finalTime )
        m      = m + 1;
    end
    
    newCAMdata { 1, j } = zeros ( 1, m );
    newCAMdata { 2, j } = zeros ( 1, m );
    
    if ( CAMdata { 2, j } ( 1 ) > startTime )
        newCAMdata { 1, j } ( 1 ) = CAMdata { 1, j } ( 1 );
        newCAMdata { 2, j } ( 1 ) = startTime;
    end
    
    if ( CAMdata { 2, j } ( entries ) < finalTime )
        newCAMdata { 1, j } ( m ) = CAMdata { 1, j } ( entries );
        newCAMdata { 2, j } ( m ) = finalTime;
    end
    
    for k = 1 : entries
        newCAMdata { 1, j } ( k + mstart - 1 ) = CAMdata { 1, j } ( k );
        newCAMdata { 2, j } ( k + mstart - 1 ) = CAMdata { 2, j } ( k );
    end
    
    newCAMdata { 1, j } = interp1 ( newCAMdata { 2, j }, newCAMdata { 1, j }, newTime );
    newCAMdata { 2, j } = newTime;
end

end


function CAM = array2CAM ( array, segmentList,  PVindex, geo )

segments  = length ( segmentList );
m         = length ( array { 1, 1 } );

angles    = zeros ( m, 5 );

CAM.x     = cell ( 1, 2 * segments );
CAM.y     = cell ( 1, 2 * segments );
CAM.r     = cell ( 1, 2 * segments );


for s = 1 : segments
    jb = ( s - 1 ) * 2 + 1;
    jq = ( s - 1 ) * 2 + 2;

    prevA = zeros ( 1, 5 ) + 1e3;

    for j = 1 : 5
        angles ( :, j ) = array { 1, PVindex ( s, j ) } * pi / 180;
    end

    times = array { 2, PVindex ( s, j ) };
    
    p  = 0;    
    T  = zeros ( 1, m );
    xb = zeros ( 1, m );
    yb = zeros ( 1, m );
    rb = zeros ( 1, m );
    xq = zeros ( 1, m );
    yq = zeros ( 1, m );
    rq = zeros ( 1, m );
    
    for k = 1 : m
        thisA = angles ( k, : );        
        thisT = times  ( k );

        if ( sum ( thisA - prevA ) ~= 0  )
            [ b, rb ] = girderAngle2Axis ( geo.bfwz,  thisA );
            [ q, rq ] = girderAngle2Axis ( geo.quadz, thisA );
            
            p         = p + 1;            
            T ( p )   = thisT;
            
            xb ( p )  = b ( 1 ) * 1e3;
            yb ( p )  = b ( 2 ) * 1e3;
            rb ( p )  = rb      * 1e3;
    
            xq ( p ) = q ( 1 ) * 1e3;
            yq ( p ) = q ( 2 ) * 1e3;
            rq ( p ) = rq      * 1e3;        
            
            prevA = thisA; 
        end
    end
        
    CAM.t        =  T ( 1 : p );
    CAM.x { jb } = xb ( 1 : p );
    CAM.x { jq } = xq ( 1 : p );
    CAM.y { jb } = yb ( 1 : p );
    CAM.y { jq } = yq ( 1 : p );
    CAM.r { jb } = rb ( 1 : p );
    CAM.r { jq } = rq ( 1 : p );
end

end


