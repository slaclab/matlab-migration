% Used to test buffAcq - Zelazny
region = 'NDRFACET';
pulses = 10;

% Get a list of BPM Names
device_list = readOrbit(region);

bpm_names = cell(0);
for i=52:length(device_list) % 52 to skip multiplexed DR BPMS
    if length(device_list{i}) > 12 % to get around parse error in Aida for 2 digit unit numbers
        bpm_names{end+1} = device_list{i};
    end
end

disp(sprintf('Found %d BPMS for %s', length(bpm_names), region));

bpm_names = cell(0);
bpm_names{end+1}='BPMS:LI02:201';
bpm_names{end+1}='BPMS:LI03:301';
bpm_names{end+1}='BPMS:LI04:401';
bpm_names{end+1}='BPMS:LI05:501';
%bpm_names{end+1}='BPMS:DR13:94';
bpm_names{end+1}='TORO:LI04:915';
bpm_names{end+1}='TORO:LI02:111';
%bpm_names{end+1}='SBST:LI07:1';
%bpm_names{end+1} = 'KLYS:LI05:51';

[ data ] = buffAcq(region, bpm_names, pulses);

for i = 1:length(data)

    disp(sprintf('PULSE ID = %d',data(i).pulse_id));

    if isfield(data(i),'bpms')
        for j = 1:length(data(i).bpms)
            disp(sprintf('   %s X=%f Y=%f TMIT=%f STAT=%X GOODMEAS=%d' ...
                , char(data(i).bpms(j).name) ...
                , data(i).bpms(j).x ...
                , data(i).bpms(j).y ...
                , data(i).bpms(j).tmit ...
                , data(i).bpms(j).stat ...
                , data(i).bpms(j).goodmeas ...
                ));
        end
    end

    if isfield(data(i),'toro')
        for j = 1:length(data(i).toro)
            disp(sprintf('   %s TMIT=%f STAT=%X GOODMEAS=%d' ...
                , char(data(i).toro(j).name) ...
                , data(i).toro(j).tmit ...
                , data(i).toro(j).stat ...
                , data(i).toro(j).goodmeas ...
                ));
        end
    end

    if isfield(data(i),'klys')
        for j = 1:length(data(i).klys)
            disp(sprintf('   %s PHASE=%f STAT=%X' ...
                , char(data(i).klys(j).name) ...
                , data(i).klys(j).phase ...
                , data(i).klys(j).stat ...
                ));
        end
    end

    if isfield(data(i),'sbst')
        for j = 1:length(data(i).sbst)
            disp(sprintf('   %s PHASE=%f STAT=%X' ...
                , char(data(i).sbst(j).name) ...
                , data(i).sbst(j).phase ...
                , data(i).sbst(j).stat ...
                ));
        end
    end

end