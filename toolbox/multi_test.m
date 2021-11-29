%multi_test.m

function out = multi_test(in)
persistent initial_vals

% in.knob is the number entered into the knob
% ENTER THE PVS YOU WANT TO CONTROL. 
out.pvs{1,1} = 'SIOC:SYS0:ML00:AO077';
out.pvs{2,1} = 'SIOC:SYS0:ML00:AO078';
out.num_pvs = 2; % ENTER NUMBER OF PVs
out.egu = 'Test'; % engineering units for knob (display only)

% this is called when the knob is first initialized, Usually used to record
% initial values for differential knobs. 
if in.initialize % First cycle
    initial_vals = lcaGet(out.pvs); %read initial pvs values directly
end


% the calculated outputs
% put any function of the in.knob and thin initial values into the outputs
% (out.val). 
%ENTER THE CALCULATION YOU WANT
coef1 = 2;
coef2 = 3;
out.val(1,1) =  initial_vals(1,1) + coef1 * in.knob; % the calculation
out.val(2,1) =  initial_vals(2,1) + coef2 * in.knob;

%Put code in CVS or otherwise in th matlab search path
