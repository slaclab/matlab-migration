function epicsSimul_lcaPut(pv, val, varargin)

global epicsDataBase epicsUseAida epicsVerbose
global da

if isempty(epicsDataBase), epicsSimul_clear;end

pvList=cellstr(pv);

if epicsUseAida

    for j=1:length(pvList)
        v=val(max(1,min(j,end)):min(j,end),:);
        if ~any(strcmp(pvList{j},'.'))
            str=[pvList{j} ':VAL'];
        else
            str=strrep(pvList{j},'.',':');
        end
        try
            pvaSet(str, v);
        catch e
            handleExceptions(e);
        end
    end
    return
end

for j=1:length(pvList)
    pos=strcmp(epicsDataBase(:,1),pvList{j});
    if ~any(pos)
        epicsDataBase{end+1,1}=pvList{j};pos(end+1)=true;
    end
    v=val(max(1,min(j,end)):min(j,end),:);
    if iscell(v), v=char(v);end
    if epicsVerbose, disp(['Setting ' epicsDataBase{pos,1} ' to ' num2str(v)]);end
    epicsDataBase{pos,2}=v;
end
