function status = TDUND(command)
%
% command is 'IN' or 'OUT'. When called this command will put TDUND IN  or OUT
% e.g. TDUND('IN') will put the dump in the beamline and block the beam.
%
% If no input argument is given it will return the present status 

if nargin==0
    status = lcaGet('DUMP:LTU1:970:TDUND_PNEU');
else
    command = upper(command);
    lcaPut('DUMP:LTU1:970:TDUND_PNEU',command);% remove TDUND
    status = command;
end

