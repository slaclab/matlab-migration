function omglazerzpewpew
% This program, omglazerzpewpew.m, fills a truth table based upon what laser
% is in use and if that laser is in bucket mode (setting the bucket mode
% parameter on the Matlab Support PV). The edm displays on CUDTV01 (the
% LCLS injector map display) are grouped with logic to display based upon
% the value of the Table Val (Matlab Support PV AO678) which represents a
% value in the Truth Table.

fprintf('\nStarting program...\nFilling CUDTV01 laser oscillator display truth table...\n\n');
pause(2);
    buckit = lcaGetSmart('SIOC:SYS0:ML00:AO675',0,'Double');
    display(buckit);
    lazer = lcaGetSmart('LASR:LR20:1:MODE',0,'Double');
    display(lazer);
pause(2);
fprintf('\nI am going to run silent now, unless something goes wrong\n');

try
while 1

    if lazer==0
        if buckit==0
            lcaPutSmart('SIOC:SYS0:ML00:AO678',0); % Thales, no bucket
        elseif buckit==1
            lcaPutSmart('SIOC:SYS0:ML00:AO678',1); % Thales, bucket
        end
    elseif lazer==1
        if buckit==0
            lcaPutSmart('SIOC:SYS0:ML00:AO678',2); % Coherent, no bucket
        elseif buckit==1
            lcaPutSmart('SIOC:SYS0:ML00:AO678',3); % Coherent, bucket
        end
    else
        fprintf('I cannot determine the state of the laser in use and/or the bucket mode parameter, at this time\n');
    end
        buckit = lcaGetSmart('SIOC:SYS0:ML00:AO675',0,'Double');
        lazer = lcaGetSmart('LASR:LR20:1:MODE',0,'Double');
        pause(2);
end

fprintf('\nFor some reason, I am no longer looping.  Something has happened to me\n');
catch
    fprintf('\nError looping. Writing error code to branch value...\n');
    lcaPutSmart('SIOC:SYS0:ML00:AO678',66);
end

end