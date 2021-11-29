%IQ_to_p1p2(E, B)
% I and Q are relative to one station energy gain

function ph = IQ_to_p1p2(I, Q)
doplot = 0;
amp = sqrt(I*I + Q*Q);
Ix = I;
Qx = Q;
ph = zeros(2,1);
if amp > 2 % vector too big, need to fix
    if abs(I) > 2 % energy too big
        I = 2 * sign(I);
        Q = 0;
    else
        Q = sqrt(4 - I*I) * sign(Q); % give all to energy
    end
end
amp = sqrt(I*I + Q*Q);
pha = atan2(Q,I);
deltap = 2*acos(amp/2);
ph1 = pha + deltap/2;
ph2 = pha - deltap/2;

if sin(ph1) < sin(ph2) % swap
    tmp = ph1;
    ph1 = ph2;
    ph2 = tmp;
end


ph(1) = limit_phase(180/pi * ph1);
ph(2) = limit_phase(180/pi * ph2);

if doplot
    i1 = cos(ph1);
    i2 = cos(ph2);
    q1 = sin(ph1);
    q2 = sin(ph2);


    figure(1);
    plot(I, Q, 'ko');
    hold on
    plot(Ix, Qx, 'k*');
    plot([0 i1], [0 q1], 'b-x');
    plot([0 i2], [0 q2], 'r-+');
    axis([-3 3 -3 3]);
    grid on;
    hold off
end;
end


function out = limit_phase(in)
if in > 180
    out = in - 360;
elseif in < -180
    out = in + 360;
else
    out = in;
end
end