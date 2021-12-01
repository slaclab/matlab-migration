pv_list = aidalist('%','VAL');
for i = 1 : size(pv_list,2)
    disp(sprintf('%d - %s', i, char(pv_list(i))));
    lcaGetSmart(strtok(pv_list(i),'/'))
end