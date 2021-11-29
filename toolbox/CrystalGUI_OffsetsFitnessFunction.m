function OUT=CrystalGUI_OffsetsFitnessFunction(PlaneMatrix,T,Y,OV,M)

% 1: eRyY (Apply a y-rotation first)
% 2: eRzR (Apply a z-rotation second)
% 3: eRxP (Apply a x-rotation last)
% Errors in the rotation axis of the Rotational Stage
% 4: eyRA (Axis should be x, apply a small y rotation first) 
% 5: ezRA (Apply a small z rotation last)
% Errors in the rotation axis of the Yaw Stage
% 6: exYA (Axis should be -y for pitch = 90 deg, +z for pitch =0 deg, apply a small x rotation first)
% 7: ezRA (Apply a small z rotation last)

% Errors in the readings
% 8: Tmis error in the theta reading. The actual value is
% Theta_Machine = Theta_Readout + Theta_MisReading
% 9: Ymis error in the yaw reading. The actual value is 
% Yaw_Machine = Yaw_Readout + Yaw_MisReading

Offset_Vector.Y_Rotation_Error= OV(1);
Offset_Vector.Z_Rotation_Error= OV(2);
Offset_Vector.X_Rotation_Error= OV(3);

Offset_Vector.Y_Rotation_ThetaAxis=OV(4);
Offset_Vector.Z_Rotation_ThetaAxis=OV(5);

Offset_Vector.X_Rotation_YawAxis=OV(6);
Offset_Vector.Z_Rotation_YawAxis=OV(7);

Offset_Vector.Theta_Misreading=OV(8);
Offset_Vector.Yaw_Misreading=OV(9);

Energies=CrystalGUI_NotchEnergy(T,Y,PlaneMatrix, Offset_Vector, M, 1);
OUT=sum((Energies(1:2:end)-Energies(2:2:end)).^2);