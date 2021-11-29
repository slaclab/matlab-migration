function  [sli_erg_mean,sli_erg_spread,erg_cen,num_sli_stat,time_low,time_cen,curr,duration] = trex_get_slice_param(img_tmp,num_sli,time_low_corr,erg_low_corr)    

prof_time_tmp      = sum(img_tmp); 

prof_time_mean     = sum((1:numel(prof_time_tmp)).*prof_time_tmp/sum(prof_time_tmp));
prof_time_var      = sum((1:numel(prof_time_tmp)).^2.*prof_time_tmp/sum(prof_time_tmp));
duration           = abs(sqrt(prof_time_var-prof_time_mean^2));

[time_pos_peak,time_pos_max] = max(prof_time_tmp);
                 
time_list_low      = find(prof_time_tmp(1:time_pos_max)==0);

if isempty(time_list_low)
    time_low       = 1;
else
    time_low       = time_list_low(end);
end

time_list_high     = find(prof_time_tmp(time_pos_max:end)==0);
if isempty(time_list_high)
    time_high      = length(prof_time_tmp);
else
    time_high      = time_list_high(1)+time_pos_max-1;
end

time_width         = time_high-time_low+1; 

time_width_act     = time_width/num_sli;   
time_width_set     = round(time_width_act);
if time_width_set<1; time_width_set=1; end
sli_diff           = (time_width_set-time_width_act)*num_sli;

img_tmp_tmp  = img_tmp(:,time_low:time_high);

if sli_diff < 0                     %CB find a better way to do this
    for n=1:round(abs(sli_diff))
        img_tmp_tmp = (circshift(img_tmp_tmp,[0,-1])+img_tmp_tmp)/2;
        img_tmp_tmp = img_tmp_tmp(:,1:end-1);
    end
elseif sli_diff > 0
    for n=1:round(abs(sli_diff))
        img_tmp_tmp_first    = img_tmp_tmp(:,1);
        img_tmp_tmp_last     = img_tmp_tmp(:,end);
        img_tmp_tmp          = (circshift(img_tmp_tmp,[0,-1])+img_tmp_tmp)/2;
        img_tmp_tmp(:,2:end) = img_tmp_tmp(:,1:end-1);
        img_tmp_tmp(:,1)     = img_tmp_tmp_first/2; 
        img_tmp_tmp(:,end+1) = img_tmp_tmp_last/2; 
    end
end

img_tmp       = img_tmp_tmp;

prof_time_tmp = sum(img_tmp);
prof_erg_tmp  = sum(img_tmp,2); 

time_cen      = time_low_corr + sum((1:length(prof_time_tmp)).*prof_time_tmp/sum(prof_time_tmp)); 
erg_cen       = erg_low_corr  + sum((1:length(prof_erg_tmp)).*prof_erg_tmp'/sum(prof_erg_tmp));

par_s_cen                   = img_tmp'*(1:size(img_tmp,1))'./sum(img_tmp,1)';
par_s_cen(isnan(par_s_cen)) = mean(par_s_cen(~isnan(par_s_cen)));
st                          = round(size(img_tmp,1)-par_s_cen+1)';

img_tmp2                    = zeros(size(img_tmp,1)*2-1,size(img_tmp,2));

for m=1:size(img_tmp,2)
    img_tmp2(st(m):size(img_tmp,1)+st(m)-1,m) = img_tmp(:,m);
end 

img_tmp_sli         = zeros(size(img_tmp,1),num_sli);
img_tmp_sli2        = zeros(size(img_tmp2,1),num_sli);
for m=1:time_width_set       
    img_tmp_sli     = img_tmp_sli  + img_tmp(:,m:time_width_set:end);
    img_tmp_sli2    = img_tmp_sli2 + img_tmp2(:,m:time_width_set:end);
end

par_sli_cen         = img_tmp_sli'*(1:size(img_tmp_sli,1))'./sum(img_tmp_sli,1)';
par_sli_cen2        = img_tmp_sli2'*(1:size(img_tmp_sli2,1))'./sum(img_tmp_sli2,1)';
par_sli_var2        = img_tmp_sli2'*(1:size(img_tmp_sli2,1)).^2'./sum(img_tmp_sli2,1)';
par_sli_spr2        = sqrt(par_sli_var2-par_sli_cen2.^2);

sli_erg_mean        = erg_low_corr + par_sli_cen;
sli_erg_spread      = par_sli_spr2;

sli_erg_spread(logical(imag(sli_erg_spread))) = 0;
sli_erg_spread(isnan(sli_erg_spread))         = 0;

curr                = sum(img_tmp_sli)';
curr                = curr/sum(curr)/time_width_set;

num_sli_stat(1)     = time_width_act;
num_sli_stat(2:3)   = round(num_sli*time_width_act*[1/ceil(time_width_act),1/floor(time_width_act)]);
if isinf(num_sli_stat(3))
    num_sli_stat(3) = NaN;
end
