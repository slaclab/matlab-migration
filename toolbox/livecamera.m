%livecamera.m

function out = livecamera()
disp('livecamera version 1.1, 4/22/09');

imagepv = 'YAGS:DMP1:500:IMAGE';
delay = 0.5;


n = 0;
n = n + 1;
L.pv{n,1}= setup_pv(548, 'Intensity control', 'cts', 4, 'livecamera.m');
L.image_scale_n = n;
n = n +1;
L.pv{n,1}= setup_pv(549, 'filterwidth', 'cts', 4, 'livecamera.m');
L.filter_width_n = n;
filter_multiplier = 2;
n = n + 1;
L.pv{n,1} = setup_pv(550, 'background', 'on/off', 4, 'livecamera.m');
L.background_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(547, 'dark image', 'on/off', 4, 'livecamera.m');
L.dark_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(546, 'averages', 'num', 4, 'livecamera.m');
L.averages_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(545, 'show ROI', 'num', 4, 'livecamera.m');
L.show_roi_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(590, 'ROI ycent', 'num', 4, 'livecamera.m');
L.roi_yc_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(591, 'ROI yrad', 'num', 4, 'livecamera.m');
L.roi_yr_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(592, 'ROI Xcent', 'num', 4, 'livecamera.m');
L.roi_xc_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(593, 'ROI Xrad', 'num', 4, 'livecamera.m');
L.roi_xr_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(594, 'max_out', 'num', 4, 'livecamera.m');
L.max_out_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(595, 'found_center_out', 'num', 4, 'livecamera.m');
L.found_center_out_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(596, 'found_center_x', 'num', 4, 'livecamera.m');
L.found_center_x_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(597, 'found_center_y', 'num', 4, 'livecamera.m');
L.found_center_y_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(544, 'stop program', 'num', 4, 'livecamera.m');
L.stop_n = n;
n = n + 1;
L.pv{n,1} = setup_pv(589, 'turn on display', 'num', 4, 'livecamera.m');
L.display_n = n;


n = n + 1;
L.pv{n,1} = 'BPMS:DMP1:693:YBR';
L.bpm_n = n;

n = n + 1;
L.pv{n,1} = 'YAGS:DMP1:500:ROI_X';
L.cam_roix_n = n;
n = n + 1;
L.pv{n,1} = 'YAGS:DMP1:500:ROI_Y';
L.cam_roiy_n = n;
n = n + 1;
L.pv{n,1} = 'YAGS:DMP1:500:ROI_XNP';
L.cam_roixnp_n = n;
n = n + 1;
L.pv{n,1} = 'YAGS:DMP1:500:ROI_YNP';
L.cam_roiynp_n = n;




background_taken = 0;
dark_taken = 0;
nc = 0;
while 1
  try
  nc = nc + 1;
  d = lcaGet(L.pv);
  if d(L.stop_n) % time to exit
    break;
  end
  [x, timestamp] = lcaGet(imagepv);
  k = 0;
  while 1
    pause(delay);
    oldtimestamp = timestamp;
    [tmp, timestamp] = lcaGet(imagepv);
    d = lcaGet(L.pv); 
    if abs(d(L.bpm_n) > 10)
      disp('BPM out of range');
      continue;
    end
    if imag(timestamp) ~= imag(oldtimestamp)
      k = k + 1;
      x = x + tmp;
      out.bpm_y(nc, k) = d(L.bpm_n);
    else
      disp('duplicate timestamp');
    end
    if k == d(L.averages_n)
      break
    end
  end
  %out.average_image{nc} = x; % averaged image 
  
  froi_in = [d(L.roi_yc_n)-d(L.roi_yr_n) d(L.roi_yc_n)+d(L.roi_yr_n) ...
         d(L.roi_xc_n)-d(L.roi_xr_n) d(L.roi_xc_n)+d(L.roi_xr_n)];
    

  cam_offset = [d(L.cam_roiy_n) d(L.cam_roiy_n) d(L.cam_roix_n) d(L.cam_roix_n)]; % stupid duplication of numbers
  froi = froi_in - cam_offset;
  froi(1) = min(max(froi(1),3), d(L.cam_roiynp_n)-3);
  froi(2) = min(max(froi(2),3), d(L.cam_roiynp_n)-3);
  froi(3) = min(max(froi(3),3), d(L.cam_roixnp_n)-3);
  froi(4) = min(max(froi(4),3), d(L.cam_roixnp_n)-3);
  xroi = d(L.cam_roixnp_n);
  yroi = d(L.cam_roiynp_n);
  x = x / (1+d(L.averages_n));
  y = reshape(x(1,1:(xroi*yroi)), xroi, yroi)';
  image_scale = d(L.image_scale_n);
  filter_width = d(L.filter_width_n);
  filtsize = ceil(filter_width * filter_multiplier+1);   
  kernal = zeros(filtsize); % rectangular area
  filtcenter = filtsize/2;
  for m1 = 1:filtsize
    for m2 = 1:filtsize
      r2 = (m1-filtcenter)^2 + (m2-filtcenter)^2;
      kernal(m1,m2) = exp(-r2/(2*filter_width^2));
    end
  end

  yfilt = conv2(y, kernal, 'same') / sum(sum(kernal));
  
  if d(L.background_n)
    background_taken = 1;
    background = yfilt;
    if dark_taken
      background_mean = mean(mean(background - dark));
    else
      background_mean = mean(mean(background));
    end
  end
  if d(L.dark_n)
    dark = yfilt;
    dark_taken = 1;
  end
  if dark_taken
    image_mean = mean(mean(yfilt - dark));
  else
    image_mean = mean(mean(yfilt));
  end
  if background_taken
  %  yfinal = yfilt/image_mean - background/background_mean;
     yfinal =yfilt - background;
  else
  %  yfinal = yfilt/image_mean;
  yfinal = yfilt;
  end
  z = yfinal / image_scale * 60 +4;
   centerx = round(.5*(froi(3)+froi(4)));
    centery = round(.5 * (froi(1)+froi(2)));
  if d(L.show_roi_n) % show region of interest
    z(froi(1):froi(2), froi(3):froi(4)) = z(froi(1):froi(2), froi(3):froi(4)) + 4;
   
    z((centery-2):(centery+2), (centerx-2):(centerx+2)) = 64;
  end
  ymask = zeros(size(z));
  ymask(froi(1):froi(2), froi(3):froi(4)) = yfinal(froi(1):froi(2), froi(3):froi(4));
  centerpixel = yfinal(centery, centerx);
  sy = sum(ymask,2);
  sx = sum(ymask,1)';
  ly = length(sy);
  lx = length(sx);
  my1 = cumsum(ones(ly,1));
  mx1 = cumsum(ones(lx,1));
  my = my1;
  mx = mx1;
  if sum(sy) * sum(sx) ~= 0
    sycent = sy' * my / sum(sy);
    sxcent = sx' * mx / sum(sx);
    sycent = min(max(1, sycent), d(L.cam_roiynp_n)); 
    sxcent = min(max(1, sxcent), d(L.cam_roixnp_n));
    
    foundcenterpixel = yfinal(round(sycent), round(sxcent));
  else
    sycent = 1;
    sxcent = 1;
     foundcenterpixel = yfinal(round(sycent), round(sxcent));
  end
  maxpix = max(max(yfinal(froi(1):froi(2), froi(3):froi(4))));
  lcaPut(L.pv{L.max_out_n,1}, maxpix);
  lcaPut(L.pv{L.found_center_out_n,1}, foundcenterpixel);
  lcaPut(L.pv{L.found_center_x_n,1}, sxcent+cam_offset(3));
  lcaPut(L.pv{L.found_center_y_n,1}, sycent+cam_offset(1));


  if d(L.display_n)
    image(z);
  end
  disp(['nc = ', num2str(nc)]);
  catch
    disp('something broke - trying again');
  end
end


end

function pvname = setup_pv(num, text, egu, prec, comment)
numtxt = num2str(round(num));
numlen = length(numtxt);
if numlen == 1
  numstr = ['00', numtxt];
elseif numlen == 2
  numstr = ['0', numtxt];
else
  numstr = numtxt;
end
pvname = ['SIOC:SYS0:ML00:AO', numstr];
lcaPut([pvname, '.DESC'], text);
lcaPut([pvname, '.EGU'], egu);
lcaPut([pvname, '.PREC'], prec);
lcaPut(pv_to_comment(pvname), comment);
end

function out = pv_to_comment(pv)
str1 = pv(1:15);
str2 = 'SO0';
str3 = pv(18:20);
out = [str1, str2, str3];
return;
end
