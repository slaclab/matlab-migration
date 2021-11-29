function []=correctedDelayStageScan(Position)

State=lcaGetSmart('XPS:LI20:MC04:M1.RBV');
time = lcaGetSmart('OSC:LA20:10:FS_TGT_TIME');

dz = 2*(State-Position);
c = 299.8; %mm/ns
dt = dz/c;
new_time = time + dt;

State=lcaGetSmart('XPS:LI20:MC04:M1.RBV');
wavePlatePos=lcaGetSmart('XPS:LA20:LS24:M1.RBV');
AX_IMG_Filter = lcaGetSmart('APC:LI20:EX02:24VOUT_1');
lcaPutSmart('APC:LI20:EX02:24VOUT_1',1);


while abs(Position-State)>30
    lcaPutSmart('XPS:LA20:LS24:M1',59.6);
    wait_for_motor('XPS:LA20:LS24:M1',59.6);
    lcaPutSmart('XPS:LI20:MC04:M1',State+sign(Position-State)*30);
    wait_for_motor('XPS:LI20:MC04:M1',State+sign(Position-State)*30);
    State=lcaGetSmart('XPS:LI20:MC04:M1.RBV');
    DelayStageCorrection(1);
end;



disp('Final move');

lcaPutSmart('XPS:LA20:LS24:M1',59.6);
wait_for_motor('XPS:LA20:LS24:M1',59.6);

lcaPutSmart('XPS:LI20:MC04:M1',Position);
wait_for_motor('XPS:LI20:MC04:M1',Position);
DelayStageCorrection(5);
lcaPutSmart('OSC:LA20:10:FS_TGT_TIME',new_time);

check = 0;
while (check == 0)
    str = input('Recover high energy? (y or n) ', 's');
    if (strcmp('y',str))
        lcaPutSmart('APC:LI20:EX02:24VOUT_1',AX_IMG_Filter);
        pause(0.2);

        lcaPutSmart('XPS:LA20:LS24:M1',wavePlatePos);
        wait_for_motor('XPS:LA20:LS24:M1',wavePlatePos);

        check = 1;
    elseif (strcmp('n',str))
        disp('low energy');
        check = 1;
    else
        check = 0;
    end
end



end