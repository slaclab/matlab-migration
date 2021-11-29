%generate_output_pvs.m




function result = generate_output_pvs(sections)

result.pvs = cell(0);
result.name = cell(0);
result.range = 0;
result.scale = 0;

j = 0;

if sections.longitudinal
    j = j + 1;
    result.pvs{j,1} = 'ACCL:IN20:400:L0B_ADES';
    result.name{j,1} = 'L0B Amplitude Control';
    result.scale(j,1) = 1;
    result.range(j,1) = 2;
    j = j + 1;
    result.pvs{j,1} = 'ACCL:LI21:1:L1S_ADES';
    result.name{j,1} = 'L1S Amplitude Control';
    result.scale(j,1) = 1;
    result.range(j,1) = 3;
    j = j + 1;
    result.pvs{j,1} = 'ACCL:LI21:1:L1S_PDES';
    result.name{j,1} = 'L1S Phase control';
    result.scale(j,1) = 1;
    result.range(j,1) = 3;
end

if sections.injector_orbit
    %magnums = [121, 221, 311, 341, 381, 411, 491, 521, 641];
    magnums = [311,  381, 411, 521, 641];
    %magnames = {'00', '01', '02', '03', '04', '05', '06', '07', '08'};
    magnames = {'02', '04', '05', '07', '08'};
    
     scx = [.003, .007, .006, .003, .006];
    nummags = length(magnums);
    for k = 1:nummags
        j = j + 1;
        result.pvs{j,1} = ['XCOR:IN20:', num2str(magnums(k)), ':BCTRL'];
        result.name{j,1} = ['XC', magnames{k}];
        result.range(j,1) = .25;
        result.scale(j,1) = scx(k);
        j = j + 1;
        result.pvs{j,1} = ['YCOR:IN20:', num2str(magnums(k)+1), ':BCTRL'];
        result.name{j,1} = ['YC', magnames{k}];
        result.range(j,1) = .25;
        result.scale(j,1) = scx(k);
    end
end


if sections.sec21_orbit
    magnums = [721, 761];
    magnames = {'09', '10'};
    scx = [.010 .010];
    nummags = length(magnums);
    for k = 1:nummags
        j = j + 1;
        result.pvs{j,1} = ['XCOR:IN20:', num2str(magnums(k)), ':BCTRL'];
        result.name{j,1} = ['XC', magnames{k}];
        result.range(j,1) = .25;
        result.scale(j,1) = scx(k);
        j = j + 1;
        result.pvs{j,1} = ['YCOR:IN20:', num2str(magnums(k)+1), ':BCTRL'];
        result.name{j,1} = ['YC', magnames{k}];
        result.range(j,1) = .25;
        result.scale(j,1) = scx(k);
    end
    magnums = [101, 135, 165, 191, 275];
    magnames_x = {'XC11', 'XCA11', 'XCA12', 'XCM11', 'XCM13' };
    magnames_y = {'YC11', 'YCA11', 'YCA12', 'YCM11', 'YCM12'};
    
    nummags = length(magnums);
    for k = 1:nummags
        j = j + 1;
        result.pvs{j,1} = ['XCOR:LI21:', num2str(magnums(k)), ':BCTRL'];
        result.name{j,1} = magnames_x{k};
        result.range(j,1) = .25;
        result.scale(j,1) = .010;
        j = j + 1;
        result.pvs{j,1} = ['YCOR:LI21:', num2str(magnums(k)+1), ':BCTRL'];
        % CLUDGE
           if k == 6
               result.pvs{j,1} = 'YCOR:LI21:325:BCTRL'; % NASTY CLUDGE!
           end
        %
        result.name{j,1} = magnames_y{k};
        result.range(j,1) = .25;
        result.scale(j,1) = .007;
    end


end