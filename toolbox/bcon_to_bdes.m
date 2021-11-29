%bcon_to_bdes.m

function result = bcon_to_bdes(m); % m is magnet list

if ~iscell(m)
    m = {m};
end

num = length(m);


bcon = cell(num,1);
bdes = cell(num,1);
ctrl = cell(num,1);

for n = 1:num
    bcon{n,1} = [m{n}, ':BCON'];
    bdes{n,1} = [m{n}, ':BDES'];
    ctrl{n,1} = [m{n}, ':CTRL'];
end


tmp = lcaGet(bcon); % get bcon values
lcaPut(bdes, tmp);
lcaPut(ctrl, 'TRIM');
