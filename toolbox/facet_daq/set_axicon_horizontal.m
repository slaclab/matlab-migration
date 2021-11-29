

function set_axicon_horizontal(x)

% Axicon horizontal motor PV
%AXICON_X = 'MOTR:LI20:MC14:M0:CH4:MOTOR'; % PICO MOVER
AXICON_X = 'XPS:LI20:MC04:M6'; % Stage

% Move Axicon to the desired horizontal position
lcaPutSmart(AXICON_X, x);
RBV = lcaGetSmart([AXICON_X '.RBV']);
counter = 0;
while abs(x-RBV) >  0.01
    
    RBV = lcaGetSmart([AXICON_X '.RBV']);
    if(isnan(RBV))
        lcaPutSmart(AXICON_X, x);
    end
    if mod(counter,10)==0; display(['Delta X = ' num2str(x-RBV)]); end;
    pause(0.1);

    counter = counter + 1;
    if mod(counter,50)==0
        lcaPutSmart(AXICON_X, x);
    end
end