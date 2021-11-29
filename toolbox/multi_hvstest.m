%multi_hvstest.m

function out = multi_hvstest(in)
persistent initial_vals

% in.knob is the number entered into the knob
% ENTER THE PVS YOU WANT TO CONTROL. 
out.pvs{1,1} = 'XCOR:BSY0:34:BCTRL';
out.pvs{2,1} = 'XCOR:BSY0:60:BCTRL';
out.pvs{3,1} = 'XCOR:BSY0:87:BCTRL';
out.num_pvs = 3; % ENTER NUMBER OF PVs
out.egu = 'mm'; % engineering units for knob (display only)

% this is called when the knob is first initialized, Usually used to record
% initial values for differential knobs. 
if in.initialize % First cycle
    initial_vals = lcaGet(out.pvs); %read initial pvs values directly
end


% the calculated outputs
% put any function of the in.knob and thin initial values into the outputs
% (out.val). 
%ENTER THE CALCULATION YOU WANT
coef1 = -3;
coef2 = 3;
coef3 = 3;
out.val(1,1) =  initial_vals(1,1) + coef1 * in.knob; % the calculation
out.val(2,1) =  initial_vals(2,1) + coef2 * in.knob;
out.val(3,1) =  initial_vals(3,1) + coef3 * in.knob;
%Put code in CVS or otherwise in th matlab search path
