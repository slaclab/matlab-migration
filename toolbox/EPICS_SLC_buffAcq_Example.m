% EPICS_SLC_buffAcq Example - Zelazny

Logger = getLogger('EPICS SLC buffAcq Example');

epics_pv_list = cell(0);
epics_pv_list{end+1} = 'PMT:LI20:3179:QDCRAW';
epics_pv_list{end+1} = 'BLEN:LI20:3158:ARAW';
epics_pv_list{end+1} = 'BLEN:LI20:3158:BIMAX';
epics_pv_list{end+1} = 'BLEN:LI20:3158:AIMAX';
epics_pv_list{end+1} = 'BLEN:LI20:3158:BRAW';
epics_pv_list{end+1} = 'PATT:SYS1:1:PULSEID';

SLC_device_list = cell(0);
SLC_device_list{end+1}='BPMS:DR12:324';
SLC_device_list{end+1}='BPMS:LI03:301';
SLC_device_list{end+1}='BPMS:LI04:401';
SLC_device_list{end+1}='BPMS:LI05:501';
SLC_device_list{end+1}='TORO:LI04:915';
SLC_device_list{end+1}='SBST:LI02:1';
SLC_device_list{end+1}='KLYS:LI03:31';
SLC_device_list{end+1}='BPMS:DR13:56';

data = EPICS_SLC_buffAcq('NDRFACET', epics_pv_list, SLC_device_list, 10);

%epics_pv_list = cell(0);

%SLC_device_list = cell(0);
%SLC_device_list{end+1}='BPMS:LI00:415';

%data = EPICS_SLC_buffAcq('INJ_ELEC', epics_pv_list, SLC_device_list, 20);

%epics_pv_list = cell(0);

%SLC_device_list = cell(0);
%SLC_device_list{end+1}='BPMS:EP01:185';

%data = EPICS_SLC_buffAcq('ELECEP01', epics_pv_list, SLC_device_list, 20);

if ~isequal(0,data)
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

        if isfield(data(i),'epics')
            for j = 1:length(data(i).epics)
                disp(sprintf('   %s=%f' ...
                    , char(data(i).epics(j).name) ...
                    , data(i).epics(j).data ...
                    ));
            end
        end
    end
end
