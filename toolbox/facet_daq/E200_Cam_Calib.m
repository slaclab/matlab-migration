function output = E200_Cam_Calib()

output.USOTR.MOTOR_OUT = 42500;
output.USOTR.MOTOR_IN = 8500;
output.IPOTR.MOTOR_OUT = 24200;
output.IPOTR.MOTOR_IN = -5000;
output.DSOTR.MOTOR_OUT = 68750;
output.DSOTR.MOTOR_IN = 33750;
output.IP2A.MOTOR_OUT = 67500;
output.IP2A.MOTOR_IN = 34750;
output.IP2B.MOTOR_OUT = 73750;
output.IP2B.MOTOR_IN = 38750;

output.USOTR.MOTOR_IN = -5000;
output.DSOTR.MOTOR_IN = 21000;
output.IP2A.MOTOR_IN = 20250;
output.IP2B.MOTOR_IN = 25750;

output.USOTR.MOTOR_IN = output.USOTR.MOTOR_OUT - 1000;
output.IPOTR.MOTOR_IN = output.IPOTR.MOTOR_OUT - 1000;
output.DSOTR.MOTOR_IN = output.DSOTR.MOTOR_OUT - 1000;
output.IP2A.MOTOR_IN = output.IP2A.MOTOR_OUT - 1000;
output.IP2B.MOTOR_IN = output.IP2B.MOTOR_OUT - 1000;

% OTR calibration in um/pixel
output.USOTR.cal = 7.3;
output.IPOTR.cal = 8.0;
output.DSOTR.cal = 4.8;
output.IP2A.cal = 5.0;
output.IP2B.cal = 5.0;

% Linac z positions of OTR foils
output.USOTR.z = 1990.92;
output.IPOTR.z = 1993.01;
output.DSOTR.z = 1994.72;
output.IP2A.z = 1995.74;
output.IP2B.z = 1997.23;

output.USOTR.PV = 'OTRS:LI20:3158';
output.IPOTR.PV = 'OTRS:LI20:3180';
output.DSOTR.PV = 'OTRS:LI20:3206';
output.IP2A.PV = 'OTRS:LI20:3202';
output.IP2B.PV = 'OTRS:LI20:3230';

output.USOTR.camera_config = 9;
output.IPOTR.camera_config = 10;
output.DSOTR.camera_config = 11;
output.IP2A.camera_config = 12;
output.IP2B.camera_config = 13;



end