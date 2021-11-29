function  [ebeam_duration] = trex_get_fwhm(prof_time_ebeam)    

ebeam_duration = 'NaN'; 

prof_time_ebeam_tmp          = zeros(1,numel(prof_time_ebeam)+2);
prof_time_ebeam_tmp(2:end-1) = prof_time_ebeam;
prof_time_ebeam              = prof_time_ebeam_tmp;

[ebeam_time_pos_peak,ebeam_time_pos_max] = max(prof_time_ebeam);

fwhm_ebeam_left      = find(prof_time_ebeam(1:ebeam_time_pos_max)>=0.5*ebeam_time_pos_peak);
fwhm_ebeam_right     = find(prof_time_ebeam(ebeam_time_pos_max:end)>=0.5*ebeam_time_pos_peak);
if ~isempty(fwhm_ebeam_left) && ~isempty(fwhm_ebeam_right)
    try
        ebeam_duration       = ((fwhm_ebeam_right(end)+ebeam_time_pos_max-1)-fwhm_ebeam_left(1)) + ...
        (prof_time_ebeam(fwhm_ebeam_left(1))-0.5*ebeam_time_pos_peak)/(prof_time_ebeam(fwhm_ebeam_left(1))-prof_time_ebeam(fwhm_ebeam_left(1)-1)) + ...
        (prof_time_ebeam(fwhm_ebeam_right(end)+ebeam_time_pos_max-1)-0.5*ebeam_time_pos_peak)/(prof_time_ebeam((fwhm_ebeam_right(end)+ebeam_time_pos_max-1))-prof_time_ebeam((fwhm_ebeam_right(end)+ebeam_time_pos_max-1)+1));

        ebeam_duration       = abs(ebeam_duration);
    catch ex
        disp('trex_get_fwhm: Trouble computing FWHM...')
        disp(ex.message)
    end
end