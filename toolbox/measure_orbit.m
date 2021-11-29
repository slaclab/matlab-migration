function [x, sigma_x, y, sigma_y, z, tmit, status, name]...
    = measure_orbit(bpm_mad_names, Nsamples, sample_delay)
% Measure the  orbit and returns results with statistics
% Orbit reports in mm. Use mad names to specify which bpms

[bpm_epics_names, name_status] = model_nameConvert(bpm_mad_names, 'EPICS');
status = name_status;
name = bpm_mad_names;

bpm_epics_x = strcat(bpm_epics_names,':X');
bpm_epics_y = strcat(bpm_epics_names,':Y');
bpm_epics_tmit = strcat(bpm_epics_names,':TMIT');

x_array = zeros(Nsamples, length(bpm_epics_x));
y_array = zeros(Nsamples, length(bpm_epics_y));
tmit_array = zeros(Nsamples, length(bpm_epics_tmit));

[sys,accelerator]=getSystem();
[rep, ts] = lcaGet(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);

for k =1:Nsamples % Get orbit data
    tic
    [xs, ts] = lcaGet(bpm_epics_x);
    [ys, ts] = lcaGet(bpm_epics_y);
    [tmits, ts] = lcaGet(bpm_epics_tmit);

    x_array(k, :) = xs;
    y_array(k, :) = ys;
    tmit_array(k, :) = tmits;
    
    if rep~=0
        pause(sample_delay + 1/rep - toc)
    end
    
end

% Calculate statistics
for j=1:length(bpm_epics_names)
    x(j) = mean(x_array(:,j))/1e3;
    sigma_x(j) = std(x_array(:,j))/1e3;
    y(j) = mean(y_array(:,j))/1e3;
    sigma_y(j) = std(y_array(:,j))/1e3;
    tmit(j) = mean(tmit_array(:,j))/1e3;
    sigma_tmit(j) = std(tmit_array(:,j))/1e3;
end

% Get z positions of bpms
z=model_rMatGet(bpm_epics_names,[],[],'Z');
%for j=1:length(bpm_mad_names)
%    z(j)=model_rMatGet(bpm_epics_names(j),[],[],'Z');
%end
