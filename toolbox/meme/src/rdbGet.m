function result = rdbGet( pvname )

%% RDBGET Gets a table of values from an EPICS relational database service.
%
% struct = rdbGet(pvname)
%
% The returned result value is a matlab struct resembling an EPICS
% NTTable type [1]; that is, a field of column names, and then a field
% named "value" which itself is a struct of arrays, each array holding
% the data of one column.
%
% REFERENCES: 
%   [1] <a href="matlab:
%   web('http://epics-pvdata.sourceforge.net/alpha/normativeTypes/normativeTypes.html#nttable')">EPICS Normative Types</a>
%

% TODO: 
%   * change rdbGet to return matlab table using nttable2table (when prod
%   matlab knows table)
%   * quazi-vectorize rdbGet, so if you supply > 1 queryname, it does them all
%    (in sequence, or parfor, or (when EasyPVA does multi) in multiget). 
%        
% ------------------------------------------------------------------------
% Auth: Greg White (SLAC), T. Korhonen (PSI), 
% Mod:  G. White, SLAC,  1-Sep-2015
%       Converted to pvname = query name
%       G. White, SLAC, 20-May-2014
%       Re-write to implement in terms of wrapper of erpc.
%       G. White, SLAC, 25-Apr-2014
%       Re-write for proper error handling.  
%       G. White, SLAC, 25-Feb-2014
%       Cleanup, add comments and header
% ========================================================================

summerr='MEME:rdbGet:summerr';

result = struct([]); % Init return variable to empty struct.

try
    rdb_nturi = nturi(pvname);
    data_nttable = erpc( rdb_nturi );
    result = nttable2struct( data_nttable );
catch ex
    error( summerr,'Unable to get database data for %s; %s. Check PV name.',...
    char(pvname), ex.message);   
end
