function [uOff, vOff, bpmNumber] = bpmOffsetRecall(time)
%
% Example: [uOff, vOff, bpmNumber] = bpmOffsetRecall(now -1) will return the offsets
% one day previous to the present time.
%
% Recall bpm offsets using archiver.
%
% BPM U and V offsets are also recorded to a file in
% /u1/lcls/matlab/undulator/bpm
%


starttime = time;
stoptime = starttime + 1/(24*3600);
stoptime =datestr(stoptime);

q=1;
bpmUoff = sprintf('BPMS:UND1:%d00:UOFF',q);
bpmVoff = sprintf('BPMS:UND1:%d00:VOFF',q);
bpmNumber(q) = 100;
uOff(q) = get_archive(bpmUoff, starttime, stoptime,0); %no plots
vOff(q) = get_archive(bpmVoff, starttime, stoptime,0);
for q=2:34
    bpmNumber(q) = 100*(q-1) +90;
    bpmUoff = sprintf('BPMS:UND1:%d90:UOFF',q-1);
    bpmVoff = sprintf('BPMS:UND1:%d90:VOFF',q-1);
    uOff(q) = get_archive(bpmUoff, starttime, stoptime,0); %no plots
    vOff(q) = get_archive(bpmVoff, starttime, stoptime,0);
%     
%     lcaPut(bpmUoff, uOff(q)); % If you are brave!
%     lcaPut(bpmVoff, vOff(q));
end

% Save to  file
dnum = datenum(starttime);
filename = [  '/u1/lcls/matlab/undulator/bpm/bpmOffsets_' datestr(dnum,1) '_' datestr(dnum,15)];
fid = fopen(filename,'w');
fprintf(fid, '%s \n', 'U Offset   V Offset');
fprintf(fid, '%6f   %6f \n', uOff, vOff);
fclose(fid);
