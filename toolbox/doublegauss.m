function F = doublegauss(x,xdata)
% x(1): amplitude 1
% x(2): mean 1
% x(3): sigma 1
% x(4): amplitude 2
% x(5): mean 2
% x(6): sigma 2
% x(7): baseline
F=x(1)*exp(-(xdata-x(2)).^2/(2*x(3)^2))+...
  x(4)*exp(-(xdata-x(5)).^2/(2*x(6)^2))+...
  x(7);
end