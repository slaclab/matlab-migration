%multi_taper.m

function out = multi_taper(in)
persistent initial_vals

% in.knob is the number entered into the knob
% ENTER THE PVS YOU WANT TO CONTROL. 

out.pvs{1,1} = 'USEG:UND1:2850:TMXPOSC';
out.pvs{2,1} = 'USEG:UND1:2950:TMXPOSC';
out.pvs{3,1} = 'USEG:UND1:3050:TMXPOSC';
out.pvs{4,1} = 'USEG:UND1:3150:TMXPOSC';
out.pvs{5,1} = 'USEG:UND1:3250:TMXPOSC';
out.pvs{6,1} = 'USEG:UND1:3350:TMXPOSC';



out.num_pvs = 6; % ENTER NUMBER OF PVs
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

for n = 1:out.num_pvs
  out.val(n,1) = initial_vals(n,1) + n/out.num_pvs * in.knob;
end



%Put code in CVS or otherwise in th matlab search path
