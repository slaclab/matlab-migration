function [Xs, Ys, Ts, names] = orbitFromScore(configNumber)
%function [Xs, Ys, Ts, names] = orbitFromScore(configNumber)
% Inputs: configNumber Config Number for BSA region with BPM orbit data
% 
%example:  [Xs, Ys, Ts, names] = orbitFromScore(482373);

arg.accelerator = 'SYS0';
arg.Snap_id = configNumber;
arg.region = 'BSA';

[data, comment, ts, title] = FromSCORE(arg);
data = [data{:}];
names = {data.readbackName};
 xI = regexp(names,'BPMS:[\w]+:+[\w]+:X'); xI = cellfun(@any,xI);
 yI = regexp(names,'BPMS:[\w]+:+[\w]+:Y'); yI = cellfun(@any,yI);
 tI = regexp(names,'BPMS:[\w]+:+[\w]+:TMIT'); tI = cellfun(@any,tI);

 Xs = sortedVals(data,xI);
 Ys = sortedVals(data,yI);
 [Ts names] = sortedVals(data,tI);
 names = strrep(names,':TMIT','');
 
 
end

function [x names] = sortedVals(data,xI)
z = model_rMatGet({data(xI).aliasName} ,[],[],'Z');
[z1 sortI] = sort(z);
vals = [data(xI).readbackVal];
x = vals(sortI);
names = {data(xI).readbackName};
names = names(sortI);
end