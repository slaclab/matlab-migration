function [ M ] = ntmatrix2matrix( ntmatrix )
% NTMATRIX2MATRIX converts an input NTMatrix to a matlab marix.
%
%   The input argument must be a Java object of type PvStrcuture as define
% and undertsood by the EPICS PVdata software suite, and further that 
% PVStructure must identify itslef as being a valid NTMatrix. That is,
% the PVStructure must conform to the syntax defined in [1]. An NTMatrix
% is an EPICS PVStructure that describes a matrix, and may be populated with
% values as a matrix. Such objects are intended for interoperable 
% communications by pvAccess between EPICS endpoints.
%
% [1] http://epics-pvdata.sourceforge.net/alpha/normativeTypes/
% normativeTypes.html#ntmatrix

% Auth: G White 25-Feb-2014 
% Mod:
% TODO: Add try/catch error handling and logging
%

import('org.epics.pvdata.*');
import('org.epics.pvdata.pv.*');


% First we need to check that inputObj is a NTMatrix
if (strcmp(getNType(ntmatrix),'NTMatrix'))
    
    % Get the introspection interface
    % str = inputObj.getStructure();
    
    vals=ntmatrix.getSubField('value');
    doubleArray=DoubleArrayData;
    datalen=vals.getLength();
    vals.get(0,datalen,doubleArray);
    values=doubleArray.data;
    
    dim=ntmatrix.getSubField('dim');
    if ( dim == 0 )
        M=reshape(values,1,datalen)';
    else
        intArray=IntArrayData;
        dimlen=dim.getLength();
        dim.get(0,dimlen,intArray);
        if ( dimlen == 1)
            M=reshape(values,1,intArray.data(1))';
        else
            M=reshape(values,intArray.data(1),intArray.data(2))';
        end
    end
 
else
    disp 'The input object does not properly self-describe as an NTMatrix!'
    M = []; 
end

end

