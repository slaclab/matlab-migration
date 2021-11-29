% return the severity strings from lcaGetStatus
% Diane Fairley(dfairley@stanford.edu)

function [sevrString, sevr] = fbGetSevrString (pv)

% Input arguments:
%   pv - cell array column vector of EPICS pv names. Example(s):
%       (1) pv = {'DOES:NOT:EXIST'};
%       (2) pv = {'DOES:NOT:EXIST';'ALSO:DOES:NOT:EXIST'};
%       (3) pv = 'DOES:NOT:EXIST'; pv{end+1}='ALSO:DOES:NOT:EXIST';
% Output arguments:
%   sevrString cell array column vector - value(s) returned from lcaGetStatus 
%   sevr column vector of sevr values returned from lcaGetStatus

sevr = lcaGetStatus (pv);

npv = size(pv,1); % 1 for first dimension
sevrString = cell(npv,1);

for eachpv = 1:npv
    if (isequal(sevr(eachpv), 0)) % no alarm 
        sevrString{eachpv} = 'no_alarm';
    elseif (isequal(sevr(eachpv), 1)) % minor alarm
        sevrString{eachpv} = 'minor_alarm';
    elseif (isequal(sevr(eachpv),2)) % major alarm
        sevrString{eachpv} = 'major_alarm';
    elseif (isequal(sevr(eachpv),3)) % invalid alarm
        sevrString{eachpv} = 'invalid_alarm';
    else % invalid or unavailable 
    end

end