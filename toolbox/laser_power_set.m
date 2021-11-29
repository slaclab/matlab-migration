%laser_power_set.m

% sets waveplates for laser power

testmode = 0;

refpv = 'SIOC:SYS0:ML00:AO942';

% check to be sure another copy isn't running
startnum = lcaGet(refpv);
pause(5);
endnum = lcaGet(refpv);
if startnum ~= endnum
    disp('Another copy of this program seems to be running, Exiting');
    return;
end

lcaPut([refpv, '.DESC'], 'Laser_power_set_running');
lcaPut ([refpv, '.EGU'], ' ');


laser_pwr_pv = 'SIOC:SYS0:ML00:AO915';
camera_pwr_pv = 'SIOC:SYS0:ML00:AO916';
wp_pv = 'WPLT:LR20:111:LSR_ANGLE.VAL';
camera_pv = 'WPLT:IN20:181:VCC_ANGLE.VAL';
wp_dmov = 'WPLT:LR20:111:LSR_ANGLE.DMOV';
wp_movn = 'WPLT:LR20:111:LSR_ANGLE.MOVN';
wp_spmg = 'WPLT:LR20:111:LSR_ANGLE.SPMG';
camera_dmov = 'WPLT:IN20:181:VCC_ANGLE.DMOV';
camera_movn = 'WPLT:IN20:181:VCC_ANGLE.MOVN';
camera_spmg = 'WPLT:IN20:181:VCC_ANGLE.SPMG';


lcaPut('SIOC:SYS0:ML00:AO950.DESC', 'DO NOT USE');
%camera_pv = 'SIOC:SYS0:ML00:AO950';

wp_readback = 'WPLT:LR20:111:LSR_ANGLE.RBV';
camera_rb = 'WPLT:IN20:181:VCC_ANGLE.RBV';
%camera_rb = 'SIOC:SYS0:ML00:AO950';



dat = load('waveplate_calib.txt');

lcaSetTimeout(0.2);

delay = 0.25; % delay time

% look at old data to get curve

angle = dat(1:23,1);
pwr = dat(1:23,2);
pwr_norm = pwr ./ max(pwr); %normalized power
angle_offset = 133;
an = angle - angle_offset;
P = polyfit(an, pwr_norm, 4);
fit = polyval(P,an);


P2 = polyfit(pwr_norm, an, 4);
afit = polyval(P2, pwr_norm);
err_a = std(afit - an);


camera_max_angle = 75; % change to 67
camera_max_angle = 67;




lcaPut([laser_pwr_pv, '.DESC'], 'Laser power ');
lcaPut([camera_pwr_pv, '.DESC'], 'Camera intensity ');
lcaPut([laser_pwr_pv, '.EGU'], '%');
lcaPut([camera_pwr_pv,'.EGU'], '%');
lcaSetMonitor(laser_pwr_pv); % look for changes
lcaSetMonitor(camera_pwr_pv); % look for changes
laser_flag = 0;
camera_flag = 0;

j =0;
while 1
    j = j + 1;
    if j > 999
        j = 1;
    end
    if mod(j,5)
        lcaPut(refpv, num2str(j/5));
    end
    laser_flag = lcaNewMonitorValue(laser_pwr_pv);
    camera_flag = lcaNewMonitorValue(camera_pwr_pv);
    if laser_flag < 0 % error
        disp([laser_pwr_pv, ' error ', flag]);
    end
    if camera_flag < 0 % error
        disp([camera_pwr_pv', ' error ', flag]);
    end
    if  (laser_flag == 1) || (camera_flag == 1)  %new setting
        percent_pwr = lcaGet(laser_pwr_pv);
        if percent_pwr == 0
            percent_camera = 100;
        else
            percent_camera = 100*lcaGet(camera_pwr_pv) / percent_pwr;
        end
        percent_pwr = min(100, percent_pwr);
        percent_pwr = max(0, percent_pwr);
        percent_camera = min(100, percent_camera);
        precent_camera = max(0, percent_camera);
        old_power_wp = lcaGet(wp_pv);
        old_camera_wp = lcaGet(camera_pv);
        old_power = 100 * polyval(P,old_power_wp - angle_offset);
        old_camera = 100* cos(2*(pi/180)*(old_camera_wp - camera_max_angle))^2;
        disp(['old pwr = ', num2str(round(old_power)), '%  new pwr = ', ...
            num2str(percent_pwr), '%  old cam = ', num2str(round(old_camera)), ...
            '%  new cam = ', num2str(percent_camera), '%']);
        new_pwr_anglex = polyval(P2, percent_pwr / 100) + angle_offset;
        new_cam_anglex = camera_max_angle -(90/pi)*acos(sqrt(percent_camera / 100));
        new_pwr_angle = round(new_pwr_anglex * 10000)/10000; % limit resolution
        new_cam_angle = round(new_cam_anglex * 10000)/10000;
        disp(['old_power_angle = ', num2str(old_power_wp), ' new =  ', num2str(new_pwr_angle),...
            '  old_camera_angle = ', num2str(old_camera_wp), ' new = ', num2str(new_cam_angle)]);
        for k = 1:1000
            pause(2);
            dat = lcaGet({wp_dmov; wp_movn; camera_dmov; camera_movn});
            disp(dat');
            if ((dat(1) == 0) && (dat(2) == 0))
                if testmode
                    return;
                end
                disp('waveplate stuck - trying');
                %lcaPut(wp_spmg, 'Stop');
                !caput WPLT:LR20:111:LSR_ANGLE.SPMG Stop
                pause(1);
                %lcaPut(wp_spmg, 'Go');
                !caput WPLT:LR20:111:LSR_ANGLE.SPMG Go
                pause(1);
            elseif ((dat(3) == 0) && (dat(4) == 0))
                if testmode
                    return;
                end
                disp('camera stuck - trying');
                %lcaPut(camera_spmg, 'Stop');
                !caput WPLT:IN20:181:VCC_ANGLE.SPMG Stop
                pause(1);
                %lcaPut(camera_spmg, 'Go');
                !caput WPLT:IN20:181:VCC_ANGLE.SPMG Go
                pause(1);
            else
                break;
            end
        end
        try
            if percent_pwr > old_power % move camera first
                lcaPut(camera_pv, new_cam_angle); % move camera attenuator
                for jx =  1:40 % loop
                    pause(delay);
                    rb = lcaGet(camera_rb);
                    diff = abs(rb - new_cam_angle); % check difference
                    disp(['camera rb = ', num2str(rb), '  n = ', num2str(jx)]);
                    if diff < 1
                        break;
                    end
                end
                lcaPut(wp_pv, new_pwr_angle);
                for jx =  1:40 % loop
                    pause(delay);
                    rb = lcaGet(wp_readback);
                    diff = abs(rb - new_pwr_angle); % check difference
                    disp(['power rb = ', num2str(rb), '  n = ', num2str(jx)]);
                    if diff < 1
                        disp('done');
                        break;
                    end
                end
            else % move laser attenuator first
                lcaPut(wp_pv, new_pwr_angle);
                for jx = 1:40 % loop
                    pause(delay);
                    rb = lcaGet(wp_readback);
                    diff = abs(rb - new_pwr_angle); % check difference
                    disp(['power rb = ', num2str(rb), '  n = ', num2str(jx)]);
                    if diff < 1
                        break;
                    end
                end
                lcaPut(camera_pv, new_cam_angle); % move camera attenuator
                for jx = 1:40 % loop
                    pause(delay);
                    rb = lcaGet(camera_rb);
                    diff = abs(rb - new_cam_angle); % check difference
                    disp(['new_cam_angle = ', num2str(new_cam_angle),...
                        'camera rb = ', num2str(rb), '  n = ', num2str(jx)]);
                    if diff < 1
                        disp('done');
                        break;
                    end
                end
            end
        catch
            disp('Caught error in lca - ignore and continue');
        end
    end
    pause(delay);
end
