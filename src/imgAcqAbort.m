% Aborts your image Acq Request made with imgAcqOn

% Mike Zelazny (zelazny@stanford.edu)

try
    lcaPut ('PROF:PM00:1:STOP',1);
catch
end