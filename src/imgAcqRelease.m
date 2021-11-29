% Releases your image Acq Reservation made with imgAcqReserve

% Mike Zelazny (zelazny@stanford.edu)

try
    lcaPut ('PROF:PM00:1:DONE',1);
    pause(0.5); % Give soft IOC some time to release
catch
end