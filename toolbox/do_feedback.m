%do_feedback.m

function result = do_feedback(input_struct, output_struct,...
    fbcontrol_struct, fbmat,  active)

control_pv = 'SIOC:SYS0:ML00:AO945';
lcaPut([control_pv, '.DESC'], 'Feedback Control');
lcaPut([control_pv, '.PREC'], 3);


% Define e-def
eDefNumber = eDefReserve('system_feedback');
eDefParams(eDefNumber, fbcontrol_struct.averages, 1,...
    {''}, {''}, {''}, {''});


% now parse names

%gain = fbcontrol_struct.gain;

num_input_pvs = length(input_struct.pvs);
num_output_pvs = length(output_struct.pvs);


result.starting_outputs = lcaGet(output_struct.pvs); % initial settings of outputs
m =0;
while 1 % main loop
    gain1 = lcaGet(control_pv);
    if gain1 == 0
        disp('feedback gain 0');
        pause(1);
    elseif gain1 < 0
        disp('exiting program');
        break;
    end
    gain = gain1 * ones(num_output_pvs,1);
    m = m + 1;
    last_outputs = lcaGet(output_struct.pvs);
    result.acqTime = eDefAcq(eDefNumber, fbcontrol_struct.timeout);
    tmp = lcaGet(input_struct.pvs);
    check_signal  = lcaGet(fbcontrol_struct.check_pv);
    indata = (tmp - input_struct.offset).* input_struct.scale;
    %indata(num_input_pvs+1) = 1; % acc column of 1s
    
    dx = indata'* fbmat;
    outchange = -dx' .* output_struct.scale;
    output = last_outputs + outchange .* gain;

    if active
        if (check_signal < fbcontrol_struct.check_low)
            disp('tmit too low')
        elseif (check_signal > fbcontrol_struct.check_high)
            disp('tmit too high')
        else
            lcaput(output_struct.pvs, output);
        end
    end
    pause(fbcontrol_struct.delay);
    err = std(dx);
    disp(err);
    if m == fbcontrol_struct.cycles
        break
    end
end

result.indata = indata;
result.dx = dx;
result.outchange = outchange;
result.last_outputs = last_outputs;
result.output = output;
eDefRelease(eDefNumber);