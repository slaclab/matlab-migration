function [ QE OnePercentQEFct] = QEcalculatorGeneral(Curr_mA,Plaser_mW, RepRate_Hz,Lambda_nm )
%Calculates the QE and when the electron current, laser power, repetition rate
%and laser wavelength are given.
%Sintax:[ QE OnePercentQEFct] = QEcalculatorGeneral(Curr_mA,Plaser_mW, RepRate_Hz,Lambda_nm )
%   OnePercentQEFCT is the factor that multiplied to the ratio
%   Elect.Current/Plaser (or ChargePerBunch/LaserPulseEnergy) gives the QE

hh=6.626e-34;
cc=2.9979e8;
ee=1.6022e-19;

nu=cc/(Lambda_nm/1e9);
PhE=hh*nu;
Elaser_J=Plaser_mW*1e-3/RepRate_Hz;
Nph=Elaser_J/PhE;
Nel=(Curr_mA/1e3/RepRate_Hz)/ee;
QE=Nel/Nph;
OnePercentQEFct=Plaser_mW/Curr_mA*QE;

end

