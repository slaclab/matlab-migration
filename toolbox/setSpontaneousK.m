function setSpontaneousK ( undulatorLine, K, scramblePct )
% 
% UndRead(undulatorLine,K,scramblePct)
%
% Sets all K values of the undulatorLine to the same average value but
% allows them to be scattered around that average value to suppress lasing
% in support of the production of spontaneous radiation.
%
% undulatorLine is a character string, eg. 'HXR' or 'SXR'.
%
% K the average K value:
%
% cramblePct the percentage by which the K value will be randomly scattered
% around the average, i.e. K_i = K ( 1 +/- r_i ),
% where r_i is a value from a flat random distribution of range
% +/-scramplePct/100.
%
% Examples:
% 
% UndRead('HXR',2.44,5)
% UndRead('HXR',5.00,5)
% 
% Last changed by Heinz-Dieter Nuhn, 9/24/2020

addpath ( genpath ( '/home/physics/nuhn/wrk/matlab' ) );

if ( strcmp ( undulatorLine, 'HXR' ) || strcmp ( undulatorLine, 'SXR' ) )
    Line                 = upper ( undulatorLine ( 1 ) );
else
    display ( undulatorLine );
    error ( 'undulatorLine can only be ''HXR'' or ''SXR''.' );
end

% construct PVs
if ( Line == 'H' )
    UndConsts = util_HXRUndulatorConstants;
else
    UndConsts = util_SXRUndulatorConstants;   
end

cellList = UndConsts.SegmentCells;

UndSet ( undulatorLine, cellList, K * ( 1 + scramblePct / 100 * ( rand ( 1, length ( cellList ) ) - 0.5 ) * 2 ), 'step', 0, 0, 'plotMode', 'K' );

end
