function OUT=deltagui_free_fit(DeltaZ,FreeFit)

Z1=DeltaZ(1)/2 + DeltaZ(3)/2;
Z2=-DeltaZ(1)/2 - DeltaZ(3)/2;
Z3=DeltaZ(2)/2 + DeltaZ(3)/2;
Z4=-DeltaZ(2)/2 - DeltaZ(3)/2;

Z1= Z1 + FreeFit.Avg13 -FreeFit.Dif13/2;
Z2= Z2 + FreeFit.Avg24 -FreeFit.Dif24/2;
Z3= Z3 + FreeFit.Avg13 +FreeFit.Dif13/2;
Z4= Z4 + FreeFit.Avg24 +FreeFit.Dif24/2;

Argument1=cos((2*pi*( Z1-Z3 )/32)/2);
Argument2=cos((2*pi*( Z2-Z4 )/32)/2);
Argument3=pi*( Z1 + Z3 - Z2 - Z4 )/32;

PowerMatrix=FreeFit.PowerMatrix;

B13=FreeFit.PolB13*(((Argument1).^PowerMatrix(:,1)).*((Argument2).^PowerMatrix(:,2)).*((Argument3).^PowerMatrix(:,3)));
B24=FreeFit.PolB24*(((Argument1).^PowerMatrix(:,1)).*((Argument2).^PowerMatrix(:,2)).*((Argument3).^PowerMatrix(:,3)));
Phase=FreeFit.Phase*(((Argument1).^PowerMatrix(:,1)).*((Argument2).^PowerMatrix(:,2)).*((Argument3).^PowerMatrix(:,3)));

OUT = [B13,B24,Phase];

