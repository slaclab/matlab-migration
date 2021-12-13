function [val, ts] = epicsSimul_lcaGet(pv, varargin)

global epicsDataBase epicsUseAida epicsVerbose

if isempty(epicsDataBase), epicsSimul_clear;end

pvList=cellstr(pv);

if epicsUseAida
    val=cell(size(pvList));ts=zeros(size(pvList));
    for j=1:length(pvList)
        if ~any(strcmp(pvList{j},'.'))
            str=[pvList{j} ':VAL'];
        else
            str=strrep(pvList{j},'.',':');
        end
        try
            val(j,:)=toArray(pvaGet(str,AIDA_DOUBLE_ARRAY));
        catch
            val(j,:)={NaN};
        end
        ts(j)=now;
    end
    val=cell2mat(val);
    return
end

val=cell(size(pvList));ts=zeros(size(pvList));
for j=1:length(pvList)
    pos=strcmp(epicsDataBase(:,1),pvList{j});
    if ~any(pos)
        epicsDataBase(end+1,:)={pvList{j} NaN};pos(end+1)=true;
    end
    val(j)=epicsDataBase(pos,2);
    if all(isnan(val{j}))
        val(j)={randn(1,size(val{j},2))};
        if epicsVerbose, disp(['Rand ' pvList{j}]);end
        if any(strfind(pvList{j},'.EGU')) || any(strfind(pvList{j},'.DESC'))
            val(j)={' '};
        end
    end
    ts(j)=now;
end

isNum=cellfun(@isnumeric,val) | cellfun(@islogical,val);
valSize=cellfun('size',val,2);
if ~all(valSize == max(valSize)) && all(isNum)
    for j=1:length(pvList)
        val{j}(1,end+1:max(valSize))=0;
    end
end
%if (all(isNum) || numel(val) == 1), val=vertcat(val{:});end
if all(isNum), val=vertcat(val{:});end

if nargin > 1 && varargin{1} > 0 && all(isNum)
    val(:,varargin{1}+1:end)=[];
end
