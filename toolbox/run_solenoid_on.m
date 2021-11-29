%count 

lcaPut('TRIG:LI20:EX01:FP2_TCTL',1);

while lcaGet('SIOC:SYS1:ML00:AO193')
    %while pv is alive
    tic
    %check state
    state=lcaGet('TRIG:LI20:EX01:FP2_TCTL');

    if strcmp(state,'Disabled')
        state =0;
    elseif strcmp(state,'Enabled')
        state =1;
    else
        error('how did you get here?!')
    end 


    %check rate 
    curr_rate=get_rate(lcaGet('EVR:LI20:EX01:EVENT14CTRL.ENM'));
    counter_value = lcaGet('SIOC:SYS1:ML00:AO194');
    new_value = counter_value+state;
    disp(['Pulse number: ' num2str(new_value)]);

    %set new value
    lcaPut('SIOC:SYS1:ML00:AO194',new_value);
    time_per_cycle=toc;
    
    pause(1/curr_rate-time_per_cycle)

end

%lcaPut('TRIG:LI20:EX01:FP2_TCTL',0);