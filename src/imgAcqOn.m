% Request image acquisition.  This will cause MPS to request burst mode.
% Your progress can be checked by viewing PROF:PM00:1:STATUS.

% Mike Zelazny (zelazny@stanford.edu)

try
    lcaPut ('PROF:PM00:1:GO',1);
catch
end