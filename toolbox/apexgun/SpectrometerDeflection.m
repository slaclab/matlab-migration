function [ dx_m ] = SpectrometerDeflection( x0_m,xp0_rad,dE_MeV,E0_MeV )
%Returns the APEX spectrometer deflection at the spectrometer screen 
%for given input posistion and angle at a given energy and energy deviation.
%SINTAX: [ dx_m ] = SpectrometerDeflection( x0_m,xp0_rad,dE_MeV,E0_MeV )
%x0_m: offset at the spectrometer entrance im
%xp0_rad: angle at the spectrometer entrance in rad
%dE_MeV: energy deviation in MeV
%E0_MeV: beam enery in MeV
%dx_m: beam deflection at the spectrometer screen in m

rho=0.309;% dipole bending radius in m
alpha=20/180*pi;% dipole edge angle
D=0.875;% Distance beam cemterline spectrometer target in m

gamma=1+1.957*E0_MeV;

x0_term=tan(alpha)+cos(2*alpha)/(cos(alpha))^2-D/rho*cos(2*alpha)/(cos(alpha))^2;
xp0_term=(1-tan(alpha))*rho+D*tan(alpha);
dE_E0_term=(D*(1+tan(alpha))-rho*tan(alpha))*gamma/(1+gamma);

dx_m=x0_term*x0_m+xp0_term*xp0_rad+dE_E0_term*dE_MeV/E0_MeV;

end

