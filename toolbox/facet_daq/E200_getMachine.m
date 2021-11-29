function state = E200_getMachine()

E200_nonBSA_list;
PV_list = nonBSA_list(:,1);
DESC = nonBSA_list(:,2);
PV_pretty = nonBSA_list(:,3);

nonBSA = lcaGetSmart(PV_list);
for i = 1:size(PV_list)
    name = regexprep(PV_pretty(i), ':', '_');
    name = regexprep(name, '\.', '_','once');
    state.(char(name)).dat = nonBSA(i);
    state.(char(name)).desc = DESC{i};
    % state.(char(name)).PV = PV_list{i};
end
