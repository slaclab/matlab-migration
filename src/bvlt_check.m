s = 26;

for i = 1:8

    proc_pv = sprintf('KLYS:LI%d:%d1:MKBVFTPJAPROC', s, i);
    ftp_raw_pv = sprintf('KLYS:LI%d:%d1:FTP21JARAW', s, i);
    bvlt_raw_pv = sprintf('KLYS:LI%d:%d1:PHAS_FAST_RAW', s, i);

    bvlt_raw(1) = lcaGet(bvlt_raw_pv);
    lcaPut(proc_pv, '1')
    for j = 2:15
        bvlt_raw(j) = lcaGet(bvlt_raw_pv);
        pause(0.1)
    end
    ftp_raw = lcaGet(ftp_raw_pv);
    bvlt_raw(16) = lcaGet(bvlt_raw_pv);
    raw64 = ftp_raw(17:80);
    disp(sprintf('K-%d-%d BVLT ratio=%f', s, i, mean(raw64)/mean(bvlt_raw)));

end

lcaClear();