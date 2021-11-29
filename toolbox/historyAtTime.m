function [values, valStruct] = historyAtTime(pvs,time)
% function  [VALUES VALSTRUCT] = historyAtTime(PV,TIME)
% Retreives history value of PV at TIME
%
% Inputs:
%       PVS: cell with pv names
%       TIME: time in format YYYY-MM-DDTHH:MM:SS.SSS (2018-12-06T10:00:00.000)
% 
% Output:
%        VALUES pv values from  archive
%        VALSTRUCT full data set from archive
%   
% References:
%  http://slacmshankar.github.io/epicsarchiver_docs/userguide.html
% Author: William Colocho, Aug 10, 2018

postStr = sprintf('%s,' ,pvs{:}); postStr(end) = [];
data = urlread(['http://lcls-archapp.slac.stanford.edu/retrieval/data/getDataAtTime?at=' time '-07:00&includeProxies=true'], 'post', {'pv'; postStr}) ;      

valStruct = jsondecode(data);

for ii = 1:length(pvs)
    pvField = strrep(pvs{ii},':','_');
    values(ii) = valStruct.(pvField).val;
end
   

