function [ rawvalues, charges, minCharge, avgCharge ] = readLossMonitors ( PVs, Channels, scopeAverages, scopeDelay, BPMPV )

PhyConsts = util_PhysicsConstants;

beamrate  = lcaGet ( 'EVNT:SYS0:1:LCLSBEAMRATE' );

BPM       = strrep ( BPMPV, ':X', '' ); 
BPM       = strrep ( BPM,   ':Y', '' ); 

nChannels = length ( Channels );

rawvalues = zeros ( nChannels, scopeAverages );
charges   = zeros ( nChannels, scopeAverages );
minCharge = min  ( charges );
avgCharge = mean ( charges );

scopeIndex = find ( Channels ~= 0 );
lnkNdIndex = find ( Channels == 0 );

if ( ~beamrate )
    return;
end

if ( any ( scopeIndex ) )
    nScopes      = length ( scopeIndex );
    scopeChannel = zeros ( 1, nScopes );
    scopePV      = cell  ( 1, nScopes );
    
    for j = 1 : nScopes
        scopeChannel ( j ) = Channels ( scopeIndex ( j ) );
        scopePV      { j } = PVs      { scopeIndex ( j ) };
    end
    
    [ maxAv, minAv, maxArray, minArray, BPM_Array ] = traceAmpl ( scopePV, scopeChannel, scopeAverages, scopeDelay, BPM );

    for j = 1 : nScopes
        charges   ( scopeIndex ( j ), : ) = BPM_Array ( 3, : ) * PhyConsts.echarge * 1e9; % [nC]
        rawvalues ( scopeIndex ( j ), : ) = maxArray ( j, : );
    end
end

if ( any ( lnkNdIndex ) )
    nlnkNds = length ( lnkNdIndex );

    reqPVs = cell ( 1 , nlnkNds + 1 );

    for s = 1 : scopeAverages
        for j = 1 : nlnkNds
            reqPVs { j } = PVs { lnkNdIndex ( j ) };       
        end
    
        reqPVs { nlnkNds + 1 } = strcat ( BPM, ':TMIT' );
    
        values = lcaGet ( reqPVs' );
    
        for j = 1 : nlnkNds
            charges   ( lnkNdIndex ( j ), s ) = values ( nlnkNds + 1 ) * PhyConsts.echarge * 1e9; % [nC]
            rawvalues ( lnkNdIndex ( j ), s ) = values ( j );
        end
        
        if ( s < scopeAverages )
            pause ( 1 / beamrate );
        end
    end
end

minCharge = min  ( charges );
avgCharge = mean ( charges );

end