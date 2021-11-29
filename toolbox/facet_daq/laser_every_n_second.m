function laser_every_n_second(n)
% Laser is on once every n second for 1 second

i = 0;
while 1
    tic;
    if mod(i,n)==0;
        lcaPutSmart('TRIG:LA20:LS25:TCTL', 0);
    else
        lcaPutSmart('TRIG:LA20:LS25:TCTL', 1);
    end;
    i=i+1;
    pause(1-toc);
end;
