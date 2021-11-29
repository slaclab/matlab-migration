% run Matlab script specified in SIOC:SYS0:ML00:CA201
script = char(lcaGet('SIOC:SYS0:ML00:CA201'));
lcaPut('SIOC:SYS0:ML00:CA201', double(int8('Enter File To Run')));
if ~isempty(findstr('.m',script))
    script = script(1:findstr('.m',script)-1);
    run(script)
end
if ~isempty(findstr('.fig',script))
    lcaPut('SIOC:SYS0:ML00:CA201', double(int8('Enter .m File To Run')));
end

