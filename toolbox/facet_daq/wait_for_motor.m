function wait_for_motor(string, position, condition)

if nargin < 3
    condition = 0.01;
end

RBV = lcaGetSmart([string '.RBV']);
counter = 0;
while abs(position-RBV) >  condition
    
    RBV = lcaGetSmart([string '.RBV']);
    if(isnan(RBV))
        lcaPutSmart(string,position);
    end
    pause(0.1);

    counter = counter + 1;
    if mod(counter,50)==0
        lcaPutSmart(string,position);
    end
end