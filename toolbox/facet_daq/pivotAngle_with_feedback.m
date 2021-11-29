function pivotAngle_with_feedback(angle_hor_abs, angle_ver_abs)

% get waveplate value and set energy to minimum
WavePlate = lcaGetSmart('XPS:LA20:LS24:M1.RBV');
lcaPutSmart('XPS:LA20:LS24:M1',59.6);
wait_for_motor('XPS:LA20:LS24:M1',59.6);

AX_IMG_Filter = lcaGetSmart('APC:LI20:EX02:24VOUT_1');
lcaPutSmart('APC:LI20:EX02:24VOUT_1',1);

% get beam mark of AxImg2
x0_pos = lcaGetSmart('SIOC:SYS1:ML03:AO049');
y0_pos = lcaGetSmart('SIOC:SYS1:ML03:AO050');
S2 = pivotAngle(angle_hor_abs, angle_ver_abs);

[position, abort] = find_AxImg_positions({'EXPT:LI20:3310'});
if abort; return; end;

delta_x = position(1)-x0_pos;
delta_y = position(2)-y0_pos;

count = 0;
while (sqrt(delta_x^2+delta_y^2) > 2) 
    % careful: AxImg2 has opposite orientation wrt AxImg1 (which defines
    % the angle)
    if (delta_x <=0 && delta_y <=0)
        M=S2.M1; 
    elseif (delta_x <=0 && delta_y >=0)
        M=S2.M2;
    elseif (delta_x >=0 && delta_y <=0)
        M=S2.M3;
    elseif (delta_x >=0 && delta_y >=0)
        M=S2.M4;
    else
        disp('fail');
    end
    M_inv = inv(M);
    delta_pos_hor = -M_inv(1,1)*delta_x - M_inv(1,2)*delta_y;
    delta_pos_ver = -M_inv(2,1)*delta_x - M_inv(2,2)*delta_y;

    % current position axicon (kinoform)
    current_pos_hor = lcaGetSmart('XPS:LI20:MC04:M6.RBV');
    current_pos_ver = lcaGetSmart('MOTR:LI20:MC14:M0:CH3:MOTOR.RBV');

    % translate axicon (kinoform) to required value
    lcaPutSmart('XPS:LI20:MC04:M6',current_pos_hor+delta_pos_hor);
    lcaPutSmart('MOTR:LI20:MC14:M0:CH3:MOTOR',current_pos_ver+delta_pos_ver);
    
    % wait for axicon motors to stop
    wait_for_motor('XPS:LI20:MC04:M6',current_pos_hor+delta_pos_hor);
    wait_for_motor('MOTR:LI20:MC14:M0:CH3:MOTOR',current_pos_ver+delta_pos_ver);
    
    [position, abort] = find_AxImg_positions({'EXPT:LI20:3310'});
    if abort == 1
        break
    end
    delta_x = position(1)-x0_pos;
    delta_y = position(2)-y0_pos;
    disp(sqrt(delta_x^2+delta_y^2));
    
    count = count + 1;
    if count> 10
        disp('Error: convergence not reached within 10 iterations');
        break
    end
end

check = 0;
while (check == 0)
    str = input('Recover high energy? (y or n) ', 's');
    if (strcmp('y',str))
        lcaPutSmart('APC:LI20:EX02:24VOUT_1',AX_IMG_Filter);
        pause(0.2);

        lcaPutSmart('XPS:LA20:LS24:M1',WavePlate);
        wait_for_motor('XPS:LA20:LS24:M1',WavePlate);

        check = 1;
    elseif (strcmp('n',str))
        disp('low energy');
        check = 1;
    else
        check = 0;
    end
end

end
