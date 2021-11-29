function [prof, no_bsa] = Acq_Image(prof_list, pulses, nonBSA_list)
% S. Corde and S. Gessner 6/2/12

pause on;

%Initiate Profile Monitor Structure
%Stores name, timestamp, pulse ID, ROI, and image
prof = repmat(struct('name', '', 'prof_ts', 0, 'prof_pid', 0, 'init_roiX', 0, 'init_roiY', ...
    0, 'init_roiXN', 0, 'init_roiYN', 0, 'img', zeros(1, 1340*1040)), pulses, length(prof_list));

%Initiate Non BSA structure
%Stores name, timestamp, value
no_bsa = repmat(struct('name', '', 'nonBSA_ts', 0, 'val', 0), pulses, length(nonBSA_list));

%Fill Profile Monitor Stucture with constant vals
for j=1:length(prof_list)
    [prof(:,j).name] = deal(prof_list(j));
    [prof(:,j).init_roiX] = deal(lcaGet(strcat(prof_list(j),':ROI_X')));
    [prof(:,j).init_roiY] = deal(lcaGet(strcat(prof_list(j),':ROI_Y')));
    [prof(:,j).init_roiXN] = deal(lcaGet(strcat(prof_list(j),':ROI_XNP')));
    [prof(:,j).init_roiYN] = deal(lcaGet(strcat(prof_list(j),':ROI_YNP')));
end

%Fill Non BSA Stucture with constant vals
for j=1:length(nonBSA_list)
    [no_bsa(:,j).name] = deal(nonBSA_list(j));
end

pv_list = strcat(prof_list,':IMAGE');
lcaSetMonitor(pv_list);

fprintf(1, '\nStarting image acquisition\n\n');
count = 0;
pulseid_new = 0;
tic;
for i=1:pulses
    lcaNewMonitorWait(pv_list);
    count = count+1;
    [temp, temp2] = lcaGet(pv_list);
    [nBSAval, nBSAts] = lcaGet(nonBSA_list);
    pulseid_old = pulseid_new;
    pulseid_new = lcaTs2PulseId(temp2);
    fprintf(1, 'Shot # %i\n', count);
    fprintf(1, 'PulseID''s are: %i %i %i %i %i %i %i %i', pulseid_new);
    if sum(abs(double(pulseid_new)-double(pulseid_old)-360))>0 && (count>1); fprintf(2, '\nCareful: PulseID increment different from 360.\n'); end
    for j=1:length(pv_list)
        prof(i,j).img = temp(j,:);
        prof(i,j).prof_ts = temp2(j);
        prof(i,j).prof_pid = lcaTs2PulseId(temp2(j));
    end
    for j=1:length(nonBSA_list)
        no_bsa(i,j).val = nBSAval(j);
        no_bsa(i,j).nonBSA_ts = nBSAts(j);
    end
    disp(sprintf('\n'));
end
fprintf(1, 'End of image acquisition\n');
fprintf(1, ['Acquisition time: ' num2str(toc) ' s\n\n']);

lcaClear(pv_list);

