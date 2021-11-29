function imgUtil_notifyLastError()
lastErr = lasterror();
if isempty(lastErr.message)
    return;
end
% only if there is an actual error message
str = sprintf('identifier: ''%s''', lastErr.identifier);
disp(str);
imgUtil_log(str);

str = sprintf('message: ''%s''', lastErr.message);
disp(str);
imgUtil_log(str);

disp('stack =>');
stack = lastErr.stack;
stackSize = size(stack, 1);
for i=1:stackSize
    str = sprintf('%s:%d [%s]', stack(i).file, stack(i).line, stack(i).name);
    disp(str);
    imgUtil_log(str);
    disp('---');
end
