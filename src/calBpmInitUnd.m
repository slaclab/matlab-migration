function [mov, und] = calBpmInitUnd(und, cal_prefix, c)

und.cams_i = readCamAngles( und.str, und.list );

% Calculate girder steps
range = lcaGet( [cal_prefix ':MVRANGE']); % User defined mover range
mov.steps = [];
mov.offsets = [];
for j = 1:(c.NSTEPS-1);
    mov.steps = [mov.steps, range/(c.NSTEPS-1)]; % Each step in scan
    mov.offsets = [mov.offsets, -(range/2) + (j-1)*(range/(c.NSTEPS-1))]; % Total offset from starting point at each step
end
mov.steps =   [-range/2,mov.steps]; % Add initial move
mov.offsets = [mov.offsets,range/2];
mov.restore = -range/2;
    
end

