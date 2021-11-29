function [ T ] = nttable2table( jpvStructure )
% nttable2table Converts a given instance of an EPICS NTTable PVStructure 
% Java object, to a matlab table type. 
%
%   T = nttable2table(inputObj)
%     inputObj must be a Java EPICS PVStructure with the normative type (NT)
%              NTTable.
%   T will be returned as a matlab table.
%
% Refs: http://epics-pvdata.sourceforge.net/alpha/normativeTypes/normativeTypes.html
%--------------------------------------------------------------------      
% Auth: G White 30-Aug-2015
% TODO: Add try/catch error handling and logging
%

% First check that inputObj is a pvStructure conforming to 
% epics:nt/NTTable:1.0 [1]. Then convert the given java pvStructure to
% a matlab structure, and then from structure to table (shoud be very
% cheap). Assign the column names from nttable labels.
%
if (strcmp(jpvStructure.getStructure().getID(),'epics:nt/NTTable:1.0'))
    
    S = nttable2struct( jpvStructure );
    T = struct2table( S.value );
    T.Properties.VariableNames = S.labels;
  
else
     disp 'The input object does not properly self-describe as an NTTable!'
     T = []; %for the time being - testing
end


