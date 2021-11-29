% Check if your image acquisition is complete.

% Mike Zelazny (zelazny@slac.stanford.edu)

function [done] = imgAcqDone

try
    if isequal(lcaGet('PROF:PM00:1:GO'), {'Waiting'})
        done = true;
    else
        done = false;
    end
catch
    done = false;
end
