function [] = set_QS0_imaging_CUBEX_ELANEX(dE, CUBE_NAME)

% ELANEX motor PVs
ELANEX_X = 'XPS:LI20:DWFA:M4';
ELANEX_Y = 'XPS:LI20:DWFA:M5';
ELANEX_X_VAL = -15; % After Nov 10th, 2014.
ELANEX_Y_VAL = 44 - 55*dE/(dE+20.35); % After May 9, 2015 (Lindstrom).

% enforce maximum ELANEX motor positions
ELANEX_Y_VAL = min(ELANEX_Y_VAL, 75);

% Move ELANEX to the desired positions
disp('ELANEX movement disabled (ELANEX not moving)');
%lcaPutSmart(ELANEX_X, ELANEX_X_VAL);
%lcaPutSmart(ELANEX_Y, ELANEX_Y_VAL);

% determine object and image plane z poisitons
switch CUBE_NAME
    case 'US_EOS' 
        Z_OBJ = 1991.77;
        Emax = 31.85;
    case 'MIP' 
        Z_OBJ = 1993.21;
        Emax = 30;
    case 'CUBE1' 
        Z_OBJ = 1993.21;
        Emax = 30;
    case 'CUBE2' 
        Z_OBJ = 1993.71;
        Emax = 29.35;
    case 'CUBE3' 
        Z_OBJ = 1994.21;
        Emax = 28.7;
    case 'CUBE4' 
        Z_OBJ = 1994.71;
        Emax = 28.05;
    case 'CUBE5' 
        Z_OBJ = 1995.09;
        Emax = 27.4;
end
Z_ELANEX = 2015.22;

% set QS PVs
QS_ENERGY_PV = 'SIOC:SYS1:ML00:AO794';
QS_OBJECTPLANE_PV = 'SIOC:SYS1:ML00:AO795';
lcaPutSmart(QS_ENERGY_PV, dE);
lcaPutSmart(QS_OBJECTPLANE_PV, Z_OBJ);

% set magnet strengths
if dE<(-Emax-20.35) || dE>(Emax-20.35)
    fprintf('\nThis value is not permitted.\n');
else
    set_QS0_position_energy_2015(Z_OBJ, Z_ELANEX, dE);
end
