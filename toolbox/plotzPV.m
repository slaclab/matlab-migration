function plotzPV( pv )
%function plotzPV( pv )
% Parse PV and call plotz.m

% William Colocho
[prim, remain] = strtok(pv,':');
remain = remain(2:end);
[location, remain] = strtok(remain, ':');
remain = remain(2:end);
[unit, remain]  = strtok(remain, ':');
remain = remain(2:end);
secn = strtok(remain, ':');
plotz(prim, secn) ;
