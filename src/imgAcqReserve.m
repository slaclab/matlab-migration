% Reserve image Acquisition. Needed to read beam synchronous images.
%
% Michael Zelazny (zelazny@slac.stanford.edu).
% 
% Name is a unique name for your image acquisition request.
% 
% If successful, this function returns true.  Otherwise this function 
% returns false.

function [success] = imgAcqReserve (Name)

% Assume failure
success = false;

% Is image Acq available?
if strcmp ('Ready', lcaGet ('PROF:PM00:1:CTRL'))

    % Wait for soft IOC to assign Name
    while strcmp ('<Empty>', lcaGet ('PROF:PM00:1:NAME'))
        % Write NAME
        lcaPut ('PROF:PM00:1:NAME', Name);
        pause (0.1);
    end

    % Make sure I was the one who got it
    if strcmp (Name, lcaGet ('PROF:PM00:1:NAME'))
        % Make sure no one else can interrupt me
        if strcmp ('Busy', lcaGet ('PROF:PM00:1:CTRL'))
            success = true;
        end
    end
end
