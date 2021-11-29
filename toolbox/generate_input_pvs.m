%generate_input_pvs.m
%


function result = generate_input_pvs(sections)

result.pvs = cell(0);
result.name = cell(0);
result.scale = 0;

j = 0;


if sections.longitudinal
    j = j + 1;
    result.pvs{j,1} = 'BPMS:IN20:731:X';
    result.name{j,1} = 'DL1 Energy';
    result.scale(j,1) = 1;
    result.sync(j,1) = 1; % does this support synchronous acquisition
    result.offset(j,1) = 0;
    j = j + 1;
    result.pvs{j,1} = 'BPMS:LI21:233:X';
    result.name{j,1} = 'BC1 Energy';
    result.scale(j,1) = 1;
    result.sync(j,1) = 1;
    result.offset(j,1) = 0;
%     j = j + 1;
%     result.pvs{j,1} = 'BLEN:LI21:280:BL12C_S_SUM';
%     result.name{j,1} = 'Bunch Length 90GHz diode';
%     result.scale(j,1) = 1e-6;
%     result.sync(j,1) = 0;
%     result.offset(j,1) = 6e6;
    j = j + 1;
    result.pvs{j,1} = 'BLEN:LI21:280:BL12D_S_SUM';
    result.name{j,1} ='Bunch Length 300GHz diode';
    result.scale(j,1) = 1e-7;
    result.sync(j,1) = 0;
    result.offset(j,1) = 4.5e7;
end


if sections.injector_orbit
    %bpmnums = [221, 235, 371, 425, 511, 525, 581, 631, 651];
%     bpmnums = [221, 235, 371, 425, 511, 581, 631, 651];
     bpmnums = [371, 425, 511, 581, 631, 651];
%     bpmnames = {'BPM2', 'BPM3', 'BPM5', 'BPM6', 'BPM8', 'BPM10', ...
%         'BPM11', 'BPM12'};
    %     bpmnames = {'BPM2', 'BPM3', 'BPM5', 'BPM6', 'BPM8', 'BPM9', 'BPM10', ...
    %         'BPM11', 'BPM12'};
    bpmnames = {'BPM5', 'BPM6', 'BPM8', 'BPM10', ...
        'BPM11', 'BPM12'};
    nbpms = length(bpmnums);
    for k = 1:nbpms
        j = j + 1;
        result.pvs{j,1} = ['BPMS:IN20:' , num2str(bpmnums(k)), ':X'];
        result.name{j,1} = [bpmnames{k}, ' X'];
        result.scale(j,1) = 1;
        result.sync(j,1) = 1;
        result.offset(j,1) =0;
        j = j + 1;
        result.pvs{j,1} = ['BPMS:IN20:', num2str(bpmnums(k)), ':Y'];
        result.name{j,1} = [bpmnames{k}, ' Y'];
        result.scale(j,1) = 1;
        result.sync(j,1) = 1;
        result.offset(j,1) = 0;
    end
end


if sections.sec21_orbit
    bpmnums = [771, 781];
    bpmnames = {'BPM14', 'BPM15'};
    nbpms = length(bpmnums);
    for k = 1:nbpms
        j = j + 1;
        result.pvs{j,1} = ['BPMS:IN20:' , num2str(bpmnums(k)), ':X'];
        result.name{j,1} = [bpmnames{k}, ' X'];
        result.scale(j,1) = 1;
        result.sync(j,1) = 1;
        result.offset(j,1) = 0;
        j = j + 1;
        result.pvs{j,1} = ['BPMS:IN20:', num2str(bpmnums(k)), ':Y'];
        result.name{j,1} = [bpmnames{k}, ' Y'];
        result.scale(j,1) = 1;
        result.sync(j,1) = 1;
        result.offset(j,1) = 0;
    end
    bpmnums = [131, 161, 201, 278, 301];
    bpmnames = {'BPMA11', 'BPMA12', 'BPM21201', 'BPMM12', 'BPM21301'};
    nbpms = length(bpmnums);
    for k = 1:nbpms
        j = j + 1;
        result.pvs{j,1} = ['BPMS:LI21:' , num2str(bpmnums(k)), ':X'];
        result.name{j,1} = [bpmnames{k}, ' X'];
        result.scale(j,1) = 1;
        result.sync(j,1) = 1;
        result.offset(j,1) = 0;
        j = j + 1;
        result.pvs{j,1} = ['BPMS:LI21:', num2str(bpmnums(k)), ':Y'];
        result.name{j,1} = [bpmnames{k}, ' Y'];
        result.scale(j,1) = 1;
        result.sync(j,1) = 1;
        result.offset(j,1) = 0;
    end
end

