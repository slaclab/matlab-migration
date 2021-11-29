

function set_axicon_vertical(y)

% Axicon vertical motor PV
AXICON_Y = 'MOTR:LI20:MC14:M0:CH3:MOTOR';

% Move Axicon to the desired vertical position
lcaPutSmart(AXICON_Y, y);
RBV = lcaGetSmart([AXICON_Y '.RBV']);
counter = 0;
while abs(y-RBV) >  0.01
    
    RBV = lcaGetSmart([AXICON_Y '.RBV']);
    if(isnan(RBV))
        lcaPutSmart(AXICON_Y, y);
    end
    if mod(counter,10)==0; display(['Delta Y = ' num2str(y-RBV)]); end;
    pause(0.1);

    counter = counter + 1;
    if mod(counter,50)==0
        lcaPutSmart(AXICON_Y, y);
    end
end