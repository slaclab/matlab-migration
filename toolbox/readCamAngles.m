function [ camAngleReadbacks ] = readCamAngles ( undulatorLine, cellList )
% 
% [camAngleReadbacks] = readCamAngles(UndulatorLine,cellList)
%
% Return the cam angles in radians for segments in the list
%
% undulatorLine is a character string, eg. 'HXR' or 'SXR'.
% cellList is an array of cell numbers, e.g.  [13, 16:20, 22] 
% camAngleReadbacks = [phi1 phi2 phi3 phi4 phi5;... ] (radians) from motor
% readback. Row n coresponds to the cell number in the nth entry of the
% cellList

% construct PVs
cams  = 5;
cells = length ( cellList );

Vpvs = cell ( cams * cells, 1 );
Apvs = cell ( cams * cells, 1 );
Line = upper ( undulatorLine ( 1 ) );

if ( Line == 'H' )
    fmtV = 'MOVR:UNDH:%d50:CM%dMOTOR.RBV';
    fmtA = 'MOVR:UNDH:%d50:CM%dREADDEG.SEVR';
else
    fmtV    = 'MOVR:UNDS:%d80:CM%d:MOTR.RBV';
    fmtV100 = 'MOVR:UNDS:%d50:CM%d:MOTR.RBV';
%    fmtV    = 'MOVR:UNDS:%d80:CM%d:READDEG';
%    fmtV100 = 'MOVR:UNDS:%d50:CM%d:READDEG';
    fmtA    = 'MOVR:UNDS:%d80:CM%d:MOTR.SEVR';
    fmtA100 = 'MOVR:UNDS:%d50:CM%d:MOTR.SEVR';
%    fmtA    = 'MOVR:UNDS:%d80:CM%dREADDEG.SEVR';
%    fmtA100 = 'MOVR:UNDS:%d50:CM%dREADDEG.SEVR';
end

for p = 1 : cells
    for camNo = 1 : cams
        cellNo = cellList ( p ); 
        if ( cellNo == 100 )
            Vpv = sprintf ( fmtV100, 35, camNo );
            Vpvs ( cams * ( p - 1 ) + camNo, 1 ) = { Vpv };
            Apv = sprintf ( fmtA100, 35, camNo );
            Apvs ( cams * ( p - 1 ) + camNo, 1 ) = { Apv };
        else
            Vpv = sprintf ( fmtV, cellNo, camNo );
            Vpvs ( cams * ( p - 1 ) + camNo, 1 ) = { Vpv };
            Apv = sprintf ( fmtA, cellNo, camNo );
            Apvs ( cams * ( p - 1 ) + camNo, 1 ) = { Apv };
        end
    end
end

[ camAngleReadbacks, ~ ]      = lcaGetSmart ( Vpvs );

%The following command is temporarily disabled until the alarm system is
%correctly set up.
%[ camAngleReadbackAlarms, ~ ] = lcaGetSmart ( Apvs, 0, 'double' )
%camAngleReadbacks ( camAngleReadbackAlarms ~= 0 ) = NaN;

camAngleReadbacks             = ( pi / 180 ) * camAngleReadbacks;
camAngleReadbacks             = reshape ( camAngleReadbacks, cams, cells );
camAngleReadbacks             = camAngleReadbacks';

end
