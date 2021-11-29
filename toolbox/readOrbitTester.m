% Used to test readorbit - Zelazny

region = 'NDRFACET';
region = 'INJ_ELEC';
region = 'ELECEP01';

[ bpm_names, x, y, z, tmit, hsta, stat ] = readOrbit(region);

disp(sprintf('Found %d BPMS for %s', length(bpm_names), region));

for i = 1:length(bpm_names)

    disp(sprintf('%d:%s X=%f Y=%f Z=%f TMIT=%f HSTA=%4.4X STAT=%4.4X' ...
        , i ...
        , char(bpm_names(i)) ...
        , x(i) ...
        , y(i) ...
        , z(i) ...
        , tmit(i) ...
        , hsta(i) ...
        , stat(i) ...
        ));

end

% set PVs or die trying

for i = 1:length(bpm_names)

    lcaPut(sprintf('%s:X%d',char(bpm_names(i)),getBPMD(region)), x(i));
    lcaPut(sprintf('%s:Y%d',char(bpm_names(i)),getBPMD(region)), y(i));
    lcaPut(sprintf('%s:Z%d',char(bpm_names(i)),getBPMD(region)), z(i));
    lcaPut(sprintf('%s:TMIT%d',char(bpm_names(i)),getBPMD(region)), tmit(i));
    lcaPut(sprintf('%s:HSTA%d',char(bpm_names(i)),getBPMD(region)), hsta(i));
    lcaPut(sprintf('%s:STAT%d',char(bpm_names(i)),getBPMD(region)), stat(i));

end
