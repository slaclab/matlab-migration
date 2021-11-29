%multi_UndulatorQuadBump.m

function out = multi_UndulatorQuadBump ( in )
persistent initial_vals

% in.knob is the number entered into the knob

% enter names of the pvs that will be controlled.

out.pvs { 1, 1 } = 'SIOC:SYS0:ML00:AO584'; % Kick angle at first quad
out.pvs { 2, 1 } = 'SIOC:SYS0:ML00:AO585'; % Bump phase shift
out.pvs { 3, 1 } = 'SIOC:SYS0:ML00:AO586'; % Bump R56
out.pvs { 4, 1 } = 'SIOC:SYS0:ML00:AO587'; % Center quad move

out.prc ( 1, 1 ) = 1;
out.prc ( 2, 1 ) = 1;
out.prc ( 3, 1 ) = 3;
out.prc ( 4, 1 ) = 1;

out.num_pvs = 4; % number of pvs used
out.egu = 'micro-rad';

if ( in.initialize ) % First cycle
    initial_vals.PhyConsts = util_PhysicsConstants;

    initial_vals.QUA = lcaGet ( 'SIOC:SYS0:ML00:AO582' );
    initial_vals.xy  = lcaGet ( 'SIOC:SYS0:ML00:AO583' );
 
    
    if ( initial_vals.xy < 1 || initial_vals.xy > 2 )
        initial_vals.xy = 1;
        lcaPut ( 'SIOC:SYS0:ML00:AO583', initial_vals.xy )
    end
    
    if ( initial_vals.QUA < 1 || initial_vals.QUA > 33 - 3 )
        initial_vals.bumpOK = false;
        return;
    else
        initial_vals.bumpOK = true;
        
        initial_vals.QUB = initial_vals.QUA + 1;
        initial_vals.QUC = initial_vals.QUA + 2;
    end

    initial_vals.geo = girderGeo;

    initial_vals.Segments = [ initial_vals.QUA, initial_vals.QUB, initial_vals.QUC ];
    [ quad_rb1, bfw_rb1, roll_rb1 ] = girderAxisFromCamAngles ( initial_vals.Segments, initial_vals.geo.quadz, initial_vals.geo.bfwz );

    initial_vals.quad_rb1 = quad_rb1;
    initial_vals.bfw_rb1  = bfw_rb1;
    initial_vals.roll_rb1 = roll_rb1;
    
%    initial_vals = lcaGet(out.pvs); %read initial pvs values directly
end

% the calculated outputs

if ( ~initial_vals.bumpOK )
    out.val ( 1, 1 ) = 0;
    return;
end

bfw_sp  = initial_vals.bfw_rb1;

BeamEnergy  = lcaGet ( 'BEND:DMP1:400:BACT' );    % GeV
QuStrength  ( 1 ) = lcaGet ( sprintf ( 'QUAD:UND1:%d80:BACT', initial_vals.QUA ) ) / 10;  % T
QuStrength  ( 2 ) = lcaGet ( sprintf ( 'QUAD:UND1:%d80:BACT', initial_vals.QUB ) ) / 10;  % T
QuStrength  ( 3 ) = lcaGet ( sprintf ( 'QUAD:UND1:%d80:BACT', initial_vals.QUC ) ) / 10;  % T

lambda_u    = 0.03; % m
K           = 3.5;
gamma       = BeamEnergy * 1e9 / initial_vals.PhyConsts.mc2_e;
lambda_r    = lambda_u / ( 2 * gamma^2 ) * ( 1 + K^2 / 2 );
Brho        = BeamEnergy * 1e9 / initial_vals.PhyConsts.c;

phi         = [ in.knob, 2 * in.knob, in.knob ];
quadMove    = sign ( QuStrength ( 1 ) ) * phi * Brho ./ abs ( QuStrength ) / 1000; % mm

if ( initial_vals.xy == 2 )
    quadMove = -quadMove;
end

bfw_sp       =  initial_vals.bfw_rb1;
quad_sp      =  initial_vals.quad_rb1;

for j = 1 : 3
    quad_sp ( j, initial_vals.xy ) = quad_sp ( j, initial_vals.xy )  + quadMove ( j );
end

girderAxisSet ( initial_vals.Segments, quad_sp, bfw_sp );
girderCamWait ( initial_vals.Segments );

QuadSep = 3.8707; % m
Lquad   = 0.074;  % m

ds      = QuadSep * ( in.knob * 1e-6 )^2; % m

out.val ( 1, 1 ) = in.knob;
out.val ( 2, 1 ) = 360 / lambda_r * ds; % degXray
out.val ( 3, 1 ) = ( in.knob * 1e-6 )^2 * ( 2 * QuadSep - Lquad ) * 1e9; % nm
out.val ( 4, 1 ) = quadMove ( 2 ) * 1000; % microns

for j = 1 : out.num_pvs
    lcaPut ( out.pvs { j, 1 }, out.val ( j, 1 ) );
    lcaPut ( strcat ( out.pvs { j, 1 }, '.PREC' ), out.prc ( j, 1 ) );
end

end
