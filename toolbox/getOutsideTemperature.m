function [T] = getOutsideTemperature()
%get current outside temperature
TF = lcaGet('CA01:ASTS:24:DATA');
T = (TF(2) - 32)*5/9;
end
