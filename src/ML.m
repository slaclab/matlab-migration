function [ matlabResult ] = ML( pvaResult )
    % Unpack using java first if this is still a PVStructure
    if ( isa(pvaResult, 'org.epics.pvdata.factory.BasePVStructure'))
        pvaResult = edu.stanford.slac.aida.client.AidaPvaClientUtils.pvaUnpack(pvaResult);
    end

    % If this is a Java array then convert to a matlab array and return
    if (isa(pvaResult, 'java.lang.Object[]'))
        matlabResult = toArray(pvaResult);

    % If this is a PvaTable then convert to a matlab structure
    elseif ( isa(pvaResult, 'edu.stanford.slac.aida.client.PvaTable'))
        matlabResult = struct;
        matlabResult.size = pvaResult.size.intValue;
        matlabResult.labels = toArray(pvaResult.labels);
        if ( pvaResult.units.length )
            matlabResult.units = toArray(pvaResult.units);
        else
            matlabResult.units = [];
        end
        if ( pvaResult.descriptions.length )
            matlabResult.descriptions = toArray(pvaResult.descriptions);
        else
            matlabResult.descriptions = [];
        end
        matlabResult.fieldnames = toArray(pvaResult.fieldNames);
        matlabResult.values = [];
        for fieldNumber = 1:pvaResult.fieldNames.length
            fieldName = pvaResult.fieldNames(fieldNumber);
            vector = toArray(pvaResult.get(fieldName));
            matlabResult.values = setfield(matlabResult.values, char(fieldName), vector);
        end

    % A java type will never be returned but we keep these just in case
    elseif (isa(pvaResult, 'java.lang.Byte'))
        matlabResult = pvaResult.byteValue;

    elseif (isa(pvaResult, 'java.lang.Boolean'))
        matlabResult = pvaResult.booleanValue;

    elseif (isa(pvaResult, 'java.lang.Short'))
        matlabResult = pvaResult.shortValue;

    elseif (isa(pvaResult, 'java.lang.Integer'))
        matlabResult = pvaResult.intValue;

    elseif (isa(pvaResult, 'java.lang.Long'))
        matlabResult = pvaResult.longValue;

    elseif (isa(pvaResult, 'java.lang.Float'))
        matlabResult = pvaResult.floatValue;

    elseif (isa(pvaResult, 'java.lang.Double'))
        matlabResult = pvaResult.doubleValue;

    elseif (isa(pvaResult, 'java.lang.String'))
        matlabResult = char(pvaResult) ;

    else
        matlabResult = pvaResult;
    end
end
