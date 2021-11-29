%laser_camera.m

function out = laser_camera()
fake = 0;
out = 0;
camera_scale = .00621;
satlevel = 255;
full_sum_threshold = 200000;
sum_threshold = 300; % threshold for sum
camera_pv = 'CAMR:IN20:186:IMAGE';
ref_pv = setup_pv(68, 'laser_camera_running', ' ', 1, 'laser_camera.m');
intensity_pv = setup_pv(69, 'Integrated intensity', 'arb', 0, 'laser_camera.m');
saturation_pv = setup_pv(70, 'Saturation', 'ratio', 4, 'laser_camera.m');
nonuniformity_pv = setup_pv(71, 'RMS variation', ' ', 3, '0 is perfect');
diameter_pv = setup_pv(72, 'Diameter', 'mm', 3, 'laser_camera.m');
xcenter_pv = setup_pv(73, 'Xcenter', 'mm', 3, 'laser_camera.m');
ycenter_pv = setup_pv(74, 'Ycenter', 'mm', 3, 'laser_camera.m');

disp('laser_camera.m  6/25/08');
disp('checking for other copies of this program running');
nc1 = lcaGet(ref_pv);
pause(5); % wait to see if another copy is running
nc2 = lcaGet(ref_pv);
if nc1 ~= nc2
  disp('Another copy of this program is running, exiting');
  return;
end
disp('no other copies running');
lcaPut(ref_pv, 0');

jx = 0;
numsamp = 5;
counter = 0;
intensity_n = zeros(numsamp,1);
saturated_n = zeros(numsamp,1);
diameter_n = zeros(numsamp,1);
xmode_n = zeros(numsamp,1);
ymode_n = zeros(numsamp,1);
badness_n = zeros(numsamp,1);
while 1
  pause(1); % slow down readings
  try
    counter = counter + 1;
    lcaPut(ref_pv, counter);
    if counter > 1000
      counter = 0;
    end
    if fake
      load /home/physics/frisch/dev/matlab/laser_camera/rawimage.mat
      q = uint8(q);
    else
      q = lcaGet(camera_pv, 640*480,  'short');
    end
    q2 = uint8(q);
    xsize = 640;
    ysize = 480;

    img = double(reshape(q2, xsize, ysize))';
    imgdisp = img; % copy to display image
    xsum = sum(img,1);
    ysum = sum(img,2);
    xsumt = sign(xsum - sum_threshold);
    ysumt = sign(ysum - sum_threshold);
    [xstart, xend] = find_ends(xsumt);
    [ystart, yend] = find_ends(ysumt);
    xsize = xend - xstart;
    ysize = yend - ystart;
    xcenter = (xstart + xend)/2;
    ycenter = (ystart + yend)/2;
    steps = 1000;
    for j = 1:steps
      theta = j * 2*pi/steps;
      x = round(xcenter + (xsize/2) * cos(theta));
      y = round(ycenter + (ysize/2) * sin(theta));
      imgdisp(y,x) = 256;
    end
    msk = zeros(480, 640); % for image mask
    mskx = zeros(480, 640);
    msky = zeros(480, 640);
    for j = 1:640
      for k = 1:480;
        rd = (2*(j-xcenter)/xsize)^2 + (2*(k-ycenter)/ysize)^2;
        if rd < 1
          msk(k,j) = 1;
          mskx(k,j) = j-xcenter;
          msky(k,j) = k - ycenter;
        end
      end
    end

    full_sum = sum(sum(img));
    if full_sum > full_sum_threshold
      maskpoints = sum(sum(msk)); % points in mask
      mskimg = msk .* img; % masked image
      summask = sum(sum(mskimg)); % sum power in mask
      avgmsk = summask / maskpoints; % average power in mask
      scalemskimg = mskimg ./ avgmsk; % scaled masked image
      xsqr = sum(sum(scalemskimg.^2));
      xavsqr = maskpoints;
      xxavv = sum(sum(scalemskimg));
      devx = sqrt(xsqr - 2 * xxavv + xavsqr) / sqrt(maskpoints);
      badness = devx;
      saturated = sum(sum(0.5*(1+sign(mskimg - satlevel))))/maskpoints;
      diameter = camera_scale * sqrt(xsize^2 + ysize^2);
      xmode = camera_scale * sum(sum(scalemskimg .* mskx)) / maskpoints;
      ymode = camera_scale * sum(sum(scalemskimg .* msky)) / maskpoints;
      jx = jx + 1;
      intensity_n(jx) = full_sum;
      saturated_n(jx) = saturated;
      diameter_n(jx) = diameter;
      xmode_n(jx) = xmode;
      ymode_n(jx) = ymode;
      badness_n(jx) = badness;
      if ~mod(jx, numsamp) % time for output
        jx = 0;
        intensity = median(intensity_n);
        saturated = median(saturated_n);
        diameter = median(diameter_n);
        xmode = median(xmode_n);
        ymode = median(ymode_n);
        badness = median(badness_n);
        lcaPut({intensity_pv; saturation_pv; nonuniformity_pv; diameter_pv; xcenter_pv; ycenter_pv},...
          {num2str(intensity); num2str(saturated); num2str(badness); num2str(diameter); num2str(xmode); num2str(ymode)});
        disp(['intensity = ', num2str(summask), '  sat = ', num2str(saturated),...
          '  badness = ', num2str(badness), '  diam = ', num2str(diameter), '  xcenter = ', num2str(xmode), ...
          '  ycenter = ', num2str(ymode)]);
        if badness > .5 % ugly measurement
          disp('ugly laser spot');
        end
      end
    else
      disp('signal too low');
      lcaPut(intensity_pv, 0);
      pause(1);

    end
  catch
    disp('Caught some error, continue');
    pause(5);
  end
end
end


function [xstart, xend] = find_ends(x)
len = length(x);
for j = 1:len
  if x(j) > 0
    break
  end
end

xstart = j;

for j = 1:len
  if x(len-j+1) > 0
    break
  end
end
xend = len-j+1;

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


%function to find comment field name from pv
% Just a stupid function to save time since we do this a lot.
function out = pv_to_comment(pv)
str1 = pv(1:15);
str2 = 'SO0';
str3 = pv(18:20);
out = [str1, str2, str3];
return;
end
