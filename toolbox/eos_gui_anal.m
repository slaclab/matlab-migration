function [image] = eos_gui_anal(data,handles)

if nargin<2||nargin>2
    error('To few or too many arguments in eos_gui_anal.m');
end

% create image variable
img = data.img;

% calibration
% eos_calib = camera.RESOLUTION;
eos_calib = 8.04; % um in z / px

% set ROI
% ROIX = [1:size(img,2)];
% ROIY = [1:size(img,1)];
% img = img(ROIY,ROIX);
% bkg  = bkg(ROIY,ROIX);

% create background variable
if handles.bg_check == 1
    bkg = handles.bg;
else
    bkg = zeros(size(img,1),size(img,2));
end

% set ROI
% ROIX = [1:size(img,2)];
% ROIY = [1:size(img,1)];
% img = img(ROIY,ROIX);
% bkg  = bkg(ROIY,ROIX);

% subtract background
img = double(img)-double(bkg);

% median filter
img = medfilt2(img,[3,3]);

% shift pixels
slope = 1/9; % shift 1 px every 9 rows
nrow = size(img,1);
for irow=1:nrow
    img(irow,:) = circshift(img(irow,:)',round(irow*slope));
end
% adjust ROI
img = img(:,ceil(nrow*slope):end);

% get projection
proj = sum(img,1);
proj = proj-min(proj);

% calibrated axis
z_axis = [0:length(proj)-1]*eos_calib;

% find centroid
%px = [1:size(proj,2)];
%[rms_x rms_y Cx Cy] = calc_rms_2D(proj);

% find peaks
[pks,locs] = findpeaks(proj);
[maxpk_val,maxpk_ind] = max(pks);
drv_pk_val = pks(maxpk_ind);
drv_pk_loc = locs(maxpk_ind);
drv_pk_z   = z_axis(drv_pk_loc);
min_sep = 100; % um
max_sep = 300; % um
wit_ind = maxpk_ind-1;
while (abs(locs(wit_ind)-drv_pk_loc)*eos_calib<min_sep ||...
       abs(locs(wit_ind)-drv_pk_loc)*eos_calib>max_sep)
    if wit_ind==1
        break;
    else
        wit_ind = wit_ind-1;
    end
end
wit_pk_val = pks(wit_ind);
wit_pk_loc = locs(wit_ind);
wit_pk_z   = z_axis(wit_pk_loc);

%wit_pk_val = pks(maxpk_ind-1);
%wit_pk_loc = locs(maxpk_ind-1);
%wit_pk_z   = z_axis(wit_pk_loc);

% do double gaussian fit
fitrange = find(z_axis>wit_pk_z-75 & z_axis<drv_pk_z+75);
amp1  = drv_pk_val;
mean1 = drv_pk_z;
sig1  = 30; % um
amp2  = wit_pk_val;
mean2 = wit_pk_z;
sig2  = 30; % um
base  = min(proj(fitrange));
guess = [amp1,mean1,sig1,amp2,mean2,sig2,base];
%     options = optimset('Display','notify');
options = optimset('Display','none');
[args, fval] = fminsearch(@(args) ...
    d2gauss2(args,proj(fitrange),z_axis(fitrange)),guess,options);

% fit results
drv_amp  = args(1);
drv_mean = args(2);
drv_sig  = args(3);
wit_amp  = args(4);
wit_mean = args(5);
wit_sig  = args(6);
base     = args(7);
delta_z  = abs(drv_mean - wit_mean);

% make plot range
plotrange = find(z_axis>wit_mean-3*wit_sig & z_axis<drv_pk_z+5*drv_sig);


% make gaussian curves
drv_fit = gauss_eos([drv_amp,drv_mean,drv_sig,base],z_axis(plotrange));
wit_fit = gauss_eos([wit_amp,wit_mean,wit_sig,base],z_axis(plotrange));

    function F = gauss_eos(x,xdata)
        % x(1): amplitude
        % x(2): mean
        % x(3): sigma
        % x(4): baseline
        F=x(1)*exp(-(xdata-x(2)).^2/(2*x(3)^2))+x(4);
    end

% make image struct
image.img = img;
image.proj = proj;
image.z_axis = z_axis;
image.plotrange = plotrange;
image.drv_pk_z = drv_pk_z;
image.wit_pk_z = wit_pk_z;
image.drv_pk_val = drv_pk_val;
image.wit_pk_val = wit_pk_val;
image.drv_fit = drv_fit;
image.wit_fit = wit_fit;
image.drv_sig = drv_sig;
image.wit_sig = wit_sig;
image.delta_z = delta_z;

end
