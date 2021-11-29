function lines = matlabPVsearch(fragment)
%
% function lines = matlabPVsearch(fragment)
%
% Returns all Matlab EPICs PVs with descriptions that contain the string
% "fragment".
%
% Useful for finding a particular Matlab EPICs soft PV
% 
% Example: lines = MatlabPVsearch('pow') returns PVs and the descriptions
% with the lines with "power" in them. Not case sensitive.

% check input
if ~isstr(fragment)
    try
        fragment = num2str(fragment); %try to fix it
    catch
        display('Fragment should be string')
    end
end
fragment = upper(fragment);

% make pvs
for q=1:999
    pvs(q,1) = {sprintf('SIOC:SYS0:ML00:AO%03d',q)};
    pvsComment(q,1) = {sprintf('SIOC:SYS0:ML00:SO%04d',q)}; %SIOC:SYS0:ML00:SO0001
    pvsShort(q,1) = {sprintf('AO%03d',q)}; % short name
end
pvsDesc = strcat(pvs,'.DESC');

% get all
descriptions = lcaGetSmart(pvsDesc);
comments = lcaGetSmart(pvsComment);% for future

% search for fragment
hits = strfind(upper(descriptions),fragment);% returns cell array with empty cells if no hits

% construct output
hitIndex = [];
for q=1:999
    if  ~isempty( (hits{q}>0) );
        allLines{q}= [pvsShort{q} '  ' descriptions{q}];
        hitIndex = [hitIndex q];
    end
end
if isempty(hitIndex)
    lines = 'Searched, but nothing found';
    return
end
lines = char(allLines(hitIndex(:)));
