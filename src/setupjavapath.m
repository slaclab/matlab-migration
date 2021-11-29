function setupjavapath(jar)
% adds jar to the dymanic java class path, if not already added
% Author: Mike Zelazny x3673

%
% Connect to message log
%
Logger = getLogger('setupjavapath.m');

%
% Determine caller (for later finger pointing)
%
stack = dbstack; % call stack
if length(stack) > 1
    caller = stack(2).file;
else
    caller = getenv('PHYSICS_USER');
end

javaclasspath_s = javaclasspath('-all');
present = max(strcmp(javaclasspath_s,jar));

if (present)
    put2log(sprintf('%s already in java class path', jar));
else
    javaaddpath(jar);
    javaclasspath_s = javaclasspath('-all');
    present = max(strcmp(javaclasspath_s,jar));
    if (present)
        put2log(sprintf('%s successfully added to java class path', jar));
    else
        put2log(sprintf('Sorry, %s unable to add %s to java class path.',caller,jar));
    end
end
