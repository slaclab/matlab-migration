

function autoalign2AxImgBM()

% get waveplate value and set energy to minimum
WavePlate = lcaGetSmart('XPS:LA20:LS24:M1.RBV');
lcaPutSmart('XPS:LA20:LS24:M1',59.6);
wait_for_motor('XPS:LA20:LS24:M1',59.6);

AX_IMG_Filter = lcaGetSmart('APC:LI20:EX02:24VOUT_1');
lcaPutSmart('APC:LI20:EX02:24VOUT_1',1);

motor = {'XPS:LI20:MC04:M6'
    'MOTR:LI20:MC14:S2:CH2:MOTOR'
    'MOTR:LI20:MC14:M0:CH1:MOTOR'
    'MOTR:LI20:MC14:M0:CH2:MOTOR'};
cams = {'EXPT:LI20:3307'
    'EXPT:LI20:3310'};

M = [-35.41 -0.92 -24.45 -1.28
    -0.89 22.25 -0.98 17.77
    -44.18 -4.58 -46.27 -4.26
    -4.36 40.51 -4.53 37.61 ];
motor_negspeed = [1 1.02 1.01 1.14];

M_inv = inv(M);

% get beam mark of AxImg1 and AxImg2
x1_0 = lcaGetSmart('SIOC:SYS1:ML03:AO047');
y1_0 = lcaGetSmart('SIOC:SYS1:ML03:AO048');
x2_0 = lcaGetSmart('SIOC:SYS1:ML03:AO049');
y2_0 = lcaGetSmart('SIOC:SYS1:ML03:AO050');

pos_0 = [x1_0 y1_0 x2_0 y2_0];
[pos, abort] = find_AxImg_positions(cams,10, [300 300]);
if abort; return; end;
delta = pos-pos_0;
disp(norm(delta));

count = 0;
while norm(delta) > 2
    
    delta_motor = -M_inv*delta';
%     disp(delta_motor);
%     pause;
    
    for i=1:4
        if delta_motor(i) >= 0;
            lcaPutSmart(motor(i), lcaGetSmart([motor(i) '.RBV']) + delta_motor(i));
            wait_for_motor(motor(i), lcaGetSmart([motor(i) '.RBV']) + delta_motor(i));
        else
            lcaPutSmart(motor(i), lcaGetSmart([motor(i) '.RBV']) + motor_negspeed(i)*delta_motor(i));
            wait_for_motor(motor(i), lcaGetSmart([motor(i) '.RBV']) + motor_negspeed(i)*delta_motor(i));
        end
    end
    
    [pos, abort] = find_AxImg_positions(cams,10, [300 300]);
    if abort == 1
        break
    end
    delta = pos-pos_0;
    disp(norm(delta));
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
