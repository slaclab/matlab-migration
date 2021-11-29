[ system, accelerator ] = getSystem;
calc_aidalist = aidalist(sprintf('SIOC:%s:ML0%s:CALC%s',system,'%','%'));
calc_stat_pvs = cell(0);
calc_sevr_pvs = cell(0);
calc_calc_pvs = cell(0);
calc_desc_pvs = cell(0);
calc_inpa_pvs = cell(0);
calc_inpb_pvs = cell(0);
calc_inpc_pvs = cell(0);
calc_inpd_pvs = cell(0);
calc_inpe_pvs = cell(0);
calc_inpf_pvs = cell(0);
calc_inpg_pvs = cell(0);
calc_inph_pvs = cell(0);
calc_inpi_pvs = cell(0);
calc_inpj_pvs = cell(0);
calc_inpk_pvs = cell(0);
calc_inpl_pvs = cell(0);
for i = 1 : length(calc_aidalist)
    calc_stat_pvs{end+1} = sprintf('%s.STAT',calc_aidalist{i});
    calc_sevr_pvs{end+1} = sprintf('%s.SEVR',calc_aidalist{i});
    calc_calc_pvs{end+1} = sprintf('%s.CALC',calc_aidalist{i});
    calc_desc_pvs{end+1} = sprintf('%s.DESC',calc_aidalist{i});
    calc_inpa_pvs{end+1} = sprintf('%s.INPA',calc_aidalist{i});
    calc_inpb_pvs{end+1} = sprintf('%s.INPB',calc_aidalist{i});
    calc_inpc_pvs{end+1} = sprintf('%s.INPC',calc_aidalist{i});
    calc_inpd_pvs{end+1} = sprintf('%s.INPD',calc_aidalist{i});
    calc_inpe_pvs{end+1} = sprintf('%s.INPE',calc_aidalist{i});
    calc_inpf_pvs{end+1} = sprintf('%s.INPF',calc_aidalist{i});
    calc_inpg_pvs{end+1} = sprintf('%s.INPG',calc_aidalist{i});
    calc_inph_pvs{end+1} = sprintf('%s.INPH',calc_aidalist{i});
    calc_inpi_pvs{end+1} = sprintf('%s.INPI',calc_aidalist{i});
    calc_inpj_pvs{end+1} = sprintf('%s.INPJ',calc_aidalist{i});
    calc_inpk_pvs{end+1} = sprintf('%s.INPK',calc_aidalist{i});
    calc_inpl_pvs{end+1} = sprintf('%s.INPL',calc_aidalist{i});
end
calc_stat = lcaGetSmart(calc_stat_pvs');
calc_sevr = lcaGetSmart(calc_sevr_pvs');
calc_calc = lcaGetSmart(calc_calc_pvs');
calc_desc = lcaGetSmart(calc_desc_pvs');
calc_inpa = lcaGetSmart(calc_inpa_pvs');
calc_inpb = lcaGetSmart(calc_inpb_pvs');
calc_inpc = lcaGetSmart(calc_inpc_pvs');
calc_inpd = lcaGetSmart(calc_inpd_pvs');
calc_inpe = lcaGetSmart(calc_inpe_pvs');
calc_inpf = lcaGetSmart(calc_inpf_pvs');
calc_inpg = lcaGetSmart(calc_inpg_pvs');
calc_inph = lcaGetSmart(calc_inph_pvs');
calc_inpi = lcaGetSmart(calc_inpi_pvs');
calc_inpj = lcaGetSmart(calc_inpj_pvs');
calc_inpk = lcaGetSmart(calc_inpk_pvs');
calc_inpl = lcaGetSmart(calc_inpl_pvs');
disp('************* CALC errors');
for i = 1 : length(calc_aidalist)
    if isequal('CALC',calc_stat{i})
        disp(sprintf('Problem with %s STAT=%s SEVR=%s CALC="%s" DESC="%s"', ...
            calc_aidalist{i}, calc_stat{i}, calc_sevr{i}, calc_calc{i}, calc_desc{i}));
    end
end
disp('************* LINK errors');
for i = 1 : length(calc_aidalist)
    if isequal('LINK',calc_stat{i})
        disp(sprintf('Problem with %s STAT=%s SEVR=%s CALC="%s" DESC="%s"', ...
            calc_aidalist{i}, calc_stat{i}, calc_sevr{i}, calc_calc{i}, calc_desc{i}));
        if ~isempty(calc_inpa{i})
            disp(sprintf('     INPA=%s', calc_inpa{i}));
        end
        if ~isempty(calc_inpb{i})
            disp(sprintf('     INPB=%s', calc_inpb{i}));
        end
        if ~isempty(calc_inpc{i})
            disp(sprintf('     INPC=%s', calc_inpc{i}));
        end
        if ~isempty(calc_inpd{i})
            disp(sprintf('     INPD=%s', calc_inpd{i}));
        end
        if ~isempty(calc_inpe{i})
            disp(sprintf('     INPE=%s', calc_inpe{i}));
        end
        if ~isempty(calc_inpf{i})
            disp(sprintf('     INPF=%s', calc_inpf{i}));
        end
        if ~isempty(calc_inpg{i})
            disp(sprintf('     INPG=%s', calc_inpg{i}));
        end
        if ~isempty(calc_inph{i})
            disp(sprintf('     INPH=%s', calc_inph{i}));
        end
        if ~isempty(calc_inpi{i})
            disp(sprintf('     INPI=%s', calc_inpi{i}));
        end
        if ~isempty(calc_inpj{i})
            disp(sprintf('     INPJ=%s', calc_inpj{i}));
        end
        if ~isempty(calc_inpk{i})
            disp(sprintf('     INPK=%s', calc_inpk{i}));
        end
        if ~isempty(calc_inpl{i})
            disp(sprintf('     INPL=%s', calc_inpl{i}));
        end
    end
end