function [epics_data,param] = E200_getEPICS(myeDefNumber,param)

E200_BSA_list;
PV_list = BSA_list(:,1);
eDefOff(myeDefNumber);

lcaSetTimeout(0.1);

pulses = lcaGetSmart(sprintf('PATT:SYS1:1:PULSEIDHST%d.NUSE',myeDefNumber));

for j = 1:length(PV_list)
    temp = lcaGetSmart(sprintf('%sHST%d',char(PV_list(j)),myeDefNumber));
    name = regexprep(PV_list(j), ':', '_');
    if numel(temp)==1
        warning(['Bad BSA PV: ' char(name)]);
        if isfield(param,'warnings')
            param.warnings(end+1) = {['Bad BSA PV: ' char(name)]};
        else
            param.warnings = cell(0,1);
            param.warnings(end+1) = {['Bad BSA PV: ' char(name)]};
        end
    end
    for i = 1:pulses
	if numel(temp)==1
           epics_data(i).(char(name)) = 0;
        else
           epics_data(i).(char(name)) = temp(i);
	end
    end
end
eDefRelease(myeDefNumber);
