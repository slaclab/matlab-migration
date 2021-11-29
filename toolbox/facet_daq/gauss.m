function F = gauss(x,xdata)
% x(1): amplitude
% x(2): mean
% x(3): sigma
% x(4): baseline
F=x(1)*exp(-(xdata-x(2)).^2/(2*x(3)^2))+x(4);
end