function [PVScanValues,MoreValues,PVScanNames,MoreValuesNames]=Scan_gui_calculation_function_Delta_Starting_Point_scan_Y(INPUT)

START = INPUT{1,2};
END = INPUT{2,2};
STEPS = INPUT{3,2};
PRIMESTART = INPUT{4,2};
PRIMEEND = INPUT{5,2};
PRIMESTEPS = INPUT{6,2};
ElectronBeamEnergy= INPUT{7,2};

MoreValuesNames={'Void'};

XCOR31='YCOR:UND1:3180:BCTRL';
XCOR32='YCOR:UND1:3280:BCTRL';
XCOR33='YCOR:UND1:3380:BCTRL';

PVScanNames={'XCOR:UND1:3180:BCTRL','XCOR:UND1:3280:BCTRL','XCOR:UND1:3380:BCTRL'};

Path31=linspace(0,5,STEPS*PRIMESTEPS);
Path32=linspace(5,10,STEPS*PRIMESTEPS);
Path33=linspace(-5,0,STEPS*PRIMESTEPS);

PVScanValues=[Path31;Path32;Path33].';
%size(PVScanValues)
MoreValues=Path31.';


end

