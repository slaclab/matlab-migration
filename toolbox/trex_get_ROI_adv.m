function [img_tmp,time_start,erg_start,time_cen,erg_cen,err_flag] = trex_get_ROI_adv(img,cut_level,roi_ini,fast_roi,two_beam_mode)    

bins               = round(max(max(img))-min(min(img))) + 1;                       
[y_data,x_data]    = hist(img(1:numel(img)),bins);
par_filt           = util_gaussFit(x_data,trex_median_filter(y_data),0);
img                = img - par_filt(2);

img_tmp            = trex_get_ROI(img,par_filt(3),1);

for k=1:(1+two_beam_mode)

    prof_time_tmp      = sum(img_tmp); 
    [~,time_pos_max] = max(prof_time_tmp);

    time_list_low      = find(prof_time_tmp(1:time_pos_max)==0);
    if isempty(time_list_low)
        time_low(k)       = 1;
    else
        time_low(k)       = time_list_low(end);
    end

    time_list_high     = find(prof_time_tmp(time_pos_max:end)==0);
    if isempty(time_list_high)
        time_high(k)      = length(prof_time_tmp);
    else
        time_high(k)      = time_list_high(1)+time_pos_max-1;
    end




    prof_erg_tmp       = sum(img_tmp,2); 
    [~,erg_pos_max]  = max(prof_erg_tmp);

    erg_list_low       = find(prof_erg_tmp(1:erg_pos_max)==0);
    if isempty(erg_list_low)
        erg_low(k)        = 1;
    else
        erg_low(k)        = erg_list_low(end);
    end

    erg_list_high      = find(prof_erg_tmp(erg_pos_max:end)==0);
    if isempty(erg_list_high)
        erg_high(k)       = length(erg_time_tmp);
    else
        erg_high(k)       = erg_list_high(1)+erg_pos_max-1;
    end



    if logical(two_beam_mode)
        img_tmp(erg_low:erg_high,time_low:time_high) = 0;
    end

end
if two_beam_mode
    if time_low(2) == 1;time_low(2) = [];end
    if time_high(2) == size(img,2);time_high(2) = [];end
    if erg_low(2) == 1;erg_low(2) = [];end
    if erg_high(2) == size(img,1);erg_high(2) = [];end
end
    

time_width         = max(time_high)-min(time_low)+1;
erg_width          = max(erg_high)-min(erg_low)+1;  


crop_time_low      = round(min(time_low)-roi_ini*time_width);
crop_time_high     = round(max(time_high)+roi_ini*time_width);
crop_erg_low       = round(min(erg_low)-roi_ini*erg_width);
crop_erg_high      = round(max(erg_high)+roi_ini*erg_width);

if crop_time_low < 1; crop_time_low = 1;end
if crop_time_high > size(img,2); crop_time_high = size(img,2); end
if crop_erg_low < 1; crop_erg_low = 1; end
if crop_erg_high > size(img,1); crop_erg_high = size(img,1); end

time_start         = crop_time_low-1;
erg_start          = crop_erg_low-1;

img_tmp            = img(crop_erg_low:crop_erg_high,crop_time_low:crop_time_high);

err_flag = 0;
if sum(size(img_tmp)) <= 6
    time_cen = 0;
    erg_cen  = 0;
    err_flag = 1;
    return;
end

if fast_roi~=1
    cut             = cut_level*par_filt(3);
    img_tmp         = trex_get_ROI(img_tmp,cut,0,two_beam_mode);
end
img_tmp(img_tmp<0)=0;


prof_time_tmp = sum(img_tmp);
time_cen      = sum((1:length(prof_time_tmp)).*prof_time_tmp/sum(prof_time_tmp));

prof_erg_tmp = sum(img_tmp,2);
erg_cen      = sum((1:length(prof_erg_tmp)).*prof_erg_tmp'/sum(prof_erg_tmp));