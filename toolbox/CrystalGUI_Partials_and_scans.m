function OUT=CrystalGUI_Partials_and_scans(ThetaYaw, Planes, Offset_Vector, LatticeMaterial)
if(nargin<5)
    material='diamond';
end
    
switch(material)
    case 'diamond'
        Lattice=0.356683;
    case 'silicon'
        Lattice=0.54311;
    otherwise
        Lattice=0.356683;
end
 
[cosa, tre]=size(Planes);

plane1=Planes(1,:);
if(cosa==2)
    plane2=Planes(2,:);
end
    
% [photon_energy_ev]=CrystalGUI_NotchEnergy(ThetaYaw(1)/180*pi,ThetaYaw(2)/180*pi, plane1 , Offset_Vector, LatticeMaterial, 1);
hx=10^-4;
in_dt1 = ( CrystalGUI_NotchEnergy((ThetaYaw(1)+hx),ThetaYaw(2), plane1 , Offset_Vector, LatticeMaterial, 1) - CrystalGUI_NotchEnergy(ThetaYaw(1),ThetaYaw(2), plane1 , Offset_Vector, LatticeMaterial, 1) ) /hx;
in_dy1 = ( CrystalGUI_NotchEnergy((ThetaYaw(1)),(ThetaYaw(2)+hx), plane1 , Offset_Vector, LatticeMaterial, 1) - CrystalGUI_NotchEnergy(ThetaYaw(1),ThetaYaw(2), plane1 , Offset_Vector, LatticeMaterial, 1) ) /hx;

%a=plane1(1); b=plane1(2); c=plane1(3);
%in_dy1= -((a^2+b^2+c^2)* ((sqrt(2)*(b-a)*cos(T)*sin(R)-2*c*sin(T))*sin(Y)+sqrt(2)*cos(R)*(-b* sin(T-Y)+a*sin(T+Y))))/(Lattice*(sqrt(2)*cos(R)*(b*cos(T-Y)+a*cos(T+Y))+cos(Y)*(sqrt(2)*(b-a)*cos(T)*sin(R)-2*c*sin(T)))^2)*h_planck*c_luce*10^9;
%in_dt1=-(((a^2+b^2+c^2)*(cos(Y)*(2*c*cos(T)-sqrt(2)*(a-b)*sin(R)*sin(T))-sqrt(2)*cos(R)*(-b*sin(T-Y)-a*sin(T+Y))))/(Lattice*(-sqrt(2)*cos(R)*(b*cos(T-Y)+a*cos(T+Y))+cos(Y)*(sqrt(2)*(a-b)*cos(T)*sin(R)+2*c*sin(T)))^2))*h_planck*c_luce*10^9;
if(cosa==2)
    in_dt2 = ( CrystalGUI_NotchEnergy(ThetaYaw(1)+hx,ThetaYaw(2), plane2 , Offset_Vector, LatticeMaterial, 1) - CrystalGUI_NotchEnergy(ThetaYaw(1),ThetaYaw(2), plane2 , Offset_Vector, LatticeMaterial, 1) ) /hx;
    in_dy2 = ( CrystalGUI_NotchEnergy(ThetaYaw(1),(ThetaYaw(2)+hx), plane2 , Offset_Vector, LatticeMaterial, 1) - CrystalGUI_NotchEnergy(ThetaYaw(1),ThetaYaw(2), plane2 , Offset_Vector, LatticeMaterial, 1) ) /hx;

    in_dcenter_t=(in_dt1+in_dt2)/2;
    in_dcenter_y=(in_dy1+in_dy2)/2;

    in_ddifference_t=(in_dt2-in_dt1)/2;
    in_ddifference_y=(in_dy2-in_dy1)/2;

    Coeff_Center_Still = - in_dcenter_t/in_dcenter_y; %Delta Y = C Coeff_Center_Still Delta T
    Coeff_difference_Still = - in_ddifference_t/in_ddifference_y; %Delta Y = C Coeff_Center_Still Delta T
    Color1_still = -in_dt1/in_dy1; %Delta Y = C Color1_still Delta T
    Color2_still = -in_dt2/in_dy2; %Delta Y = C Color2_still Delta T
end

switch(cosa)
    case 1 %Only one plane selected
        OUT.in_dy1=in_dy1;
        OUT.in_dt1=in_dt1;
    case 2
        OUT.in_dy1=in_dy1;
        OUT.in_dt1=in_dt1;
        OUT.in_dy2=in_dy2;
        OUT.in_dt2=in_dt2;
        OUT.Coeff_Center_Still=Coeff_Center_Still;
        OUT.Coeff_difference_Still=Coeff_difference_Still;
        OUT.Color1_still=Color1_still;
        OUT.Color2_still=Color2_still;
end



