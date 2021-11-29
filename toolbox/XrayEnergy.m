function [ Exray ] = XrayEnergy(E)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
% jcsheppard
%rev 0: january 23, 2014
%
% enter beam energy in GeV and get back xray energy in eV
%
Exray=950*E.^2/3/(1+3.5^2/2);


end

