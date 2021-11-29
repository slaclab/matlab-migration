function [position, abort] = find_AxImg_positions(cams, numb_of_shots,signal_threshold)
% input cams as fields
abort = 0;
position = [];

if nargin<2; numb_of_shots = 10; end;
if nargin<3; signal_threshold = 200*ones(size(cams)); end;

lcaPutSmart('EVR:LA20:LS21:EVENT9CTRL.OUT3',1);
lcaPutSmart('EVR:LA20:LS21:EVENT12CTRL.OUT3',0);

low_diameter_guess = 10;
high_diameter_guess = 20;

situation = lcaGetSmart('XPS:LI20:MC04:M6');

for i = 1:length(cams)
    x_max = [];
    y_max = [];
    for l=1:numb_of_shots
        data = profmon_grab(cams(i));
        img = data.img;
        sum_conv = max(conv(sum(img,1), ones(1,10)/10., 'same'));
        if sum_conv < signal_threshold(i)
            disp('no laser beam detected');
            abort = 1;
            break
        else
            % find x,y position
            if situation < 15
                img = medfilt2(data.img);
                img = conv2(double(img),ones(5,5)/25.,'same');
                figure(i); imagesc(img); hold on;
                % find x,y position
                x_maxs = max(img, [],1);
                y_maxs = max(img, [],2);
                [~,x_max(end+1)] = max(x_maxs);
                [~,y_max(end+1)] = max(y_maxs);
                plot(x_max(end),y_max(end),'wo', 'markersize',25, 'linewidth',3);hold off;
                pause(0.1);
                
            elseif situation > 70
                figure(i); imagesc(img); hold on;
                [y_size,x_size] = size(img);
                x_axis=1:x_size;
                y_axis=1:y_size;
                x_prof = sum(img,1);
                y_prof = sum(img,2)';
                [x_center,~,y_center,~] = kinoform_hole_finder_v2(x_axis,x_prof,y_axis,y_prof,low_diameter_guess,high_diameter_guess);
                x_max(end+1) = x_center;
                y_max(end+1) = y_center;
                plot(x_max(end),y_max(end),'wo', 'markersize',25, 'linewidth',3);hold off
                pause(0.1);
            else
                disp('No kinoform or axicon inserted')
            end
        end
    end
    if abort == 1
        break
    end
    position(end+1) = data.roiX+mean(x_max);
    position(end+1) = data.roiY+mean(y_max);
    %= [data1.roiX+mean(x1_max) data1.roiY+mean(y1_max) data2.roiX+mean(x2_max) data2.roiY+mean(y2_max)];
end


lcaPutSmart('EVR:LA20:LS21:EVENT12CTRL.OUT3',1);
lcaPutSmart('EVR:LA20:LS21:EVENT9CTRL.OUT3',0);

end