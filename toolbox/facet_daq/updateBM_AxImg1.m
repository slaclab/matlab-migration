function updateBM_AxImg1()
numb_of_shots = 10;

x_max = [];
y_max = [];
low_diameter_guess = 10;
high_diameter_guess = 20;

situation = lcaGetSmart('XPS:LI20:MC04:M6');

for i=1:numb_of_shots
    data = profmon_grab('EXPT:LI20:3307');
    img = data.img;
    % img = medfilt2(data.img);
    
    % find x,y position
    if situation < 15
        figure(1); imagesc(img); hold on;
        [x,y] = ginput(1);
        x_max(end+1) = x;
        y_max(end+1) = y;
        plot(x_max(end),y_max(end),'wo', 'markersize',25, 'linewidth',3);hold off;
        pause(0.01);
        
    elseif situation > 70
        % img = conv2(double(img),ones(5,5)/25.,'same');
        figure(1); imagesc(img); hold on;
        [y_size,x_size] = size(img);

        x_axis=zeros(x_size);
        y_axis=zeros(y_size);
        for j=1:x_size
            x_axis(j)=j;
        end
        for k=1:y_size
            y_axis(k)=k;
        end
        x_prof = sum(img,1);
        y_prof = sum(img,2)';

        [x_center,~,y_center,~] = kinoform_hole_finder_v2(x_axis,x_prof,y_axis,y_prof,low_diameter_guess,high_diameter_guess);
        x_max(end+1) = x_center;
        y_max(end+1) = y_center;
        plot(x_center,y_center,'wo', 'markersize',25, 'linewidth',3);hold off;
        pause(0.01);
    else
        disp('No kinoform or axicon inserted')
    end
end
x = mean(x_max)+data.roiX;
y = mean(y_max)+data.roiY;

lcaPutSmart('SIOC:SYS1:ML03:AO047',x);
lcaPutSmart('SIOC:SYS1:ML03:AO048',y);

% Ax2 beam mark
Ax1_RES = lcaGetSmart('EXPT:LI20:3307:RESOLUTION');
Ax1_X_RTCL_CTR = lcaGetSmart('EXPT:LI20:3307:X_RTCL_CTR');
Ax1_Y_RTCL_CTR = lcaGetSmart('EXPT:LI20:3307:Y_RTCL_CTR');

lcaPutSmart('EXPT:LI20:3307:X_ORIENT', 0);  % <--
lcaPutSmart('EXPT:LI20:3307:Y_ORIENT', 0);  % <--

lcaPutSmart('EXPT:LI20:3307:X_BM_CTR', 1e-3*(x-Ax1_X_RTCL_CTR)*Ax1_RES);    
lcaPutSmart('EXPT:LI20:3307:Y_BM_CTR', -1e-3*(y-Ax1_Y_RTCL_CTR)*Ax1_RES);

end



