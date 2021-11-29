function [ pa, pb, r ] = girderAxisFromCamAngles ( Slots, za, zb )

n = length ( Slots );

pa = zeros ( n, 3 );
pb = zeros ( n, 3 );
r  = zeros ( 1, n );

for j = 1 : n
    slot = Slots ( j );

    camAngles = girderCamMotorRead ( slot ); % find the present motor angles

% calculate theoretical pa and pb and roll

    [ a, ra ] = girderAngle2Axis ( za, camAngles );
    [ b, rb ] = girderAngle2Axis ( zb, camAngles );
    
    pa ( j, : ) = a;
    pb ( j, : ) = b;
    r  ( j )    = ( ra + rb ) / 2;
end

end
