function [XCORs, YCORs] = fbGetCORNames_SLC(config)
%
% get the XCOR and YCOR slc device names
%
%actuator PVs
numactPVs = length(config.act.chosenactPVs);

x = 0; y = 0; YCORs = []; YCORs = [];
%find the XCOR and YCOR actuators
for i=1:numactPVs
    if (~isempty(cell2mat(strfind(config.act.chosenactPVs(i), 'XCOR'))))
        x = x+1;
        XCORs{x,1} = regexprep(config.act.chosenactPVs{i,1}, ':\w*', '', 3);
    elseif (~isempty(cell2mat(strfind(config.act.chosenactPVs(i), 'YCOR'))))
        y = y+1;
        YCORs{y,1} = regexprep(config.act.chosenactPVs{i,1}, ':\w*', '', 3);
   end
end
XCORs=model_nameConvert(XCORs, 'SLC');
YCORs=model_nameConvert(YCORs, 'SLC');

