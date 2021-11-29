function imgUtil_log(message)
if nargin < 1
    message = [];
end
if isempty(message)
    return;
end
facility = 'Image Management';

try
    myErrInstance = getLogger(facility);
    put2log(message);
catch
    % just in case Err isn't available
end
