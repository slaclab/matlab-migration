function h = plot_spikes(x,y,c,width);

%               plot_spikes(x,y[,c,width])
%
%               Function to plot vertical spike bars of height y.
%
%     INPUTS:   x:      The horizontal axis data vector (column or row)
%               y:      The vertical axis data vector (column or row)
%               c:      (Optional,DEF=blue) Color code (r=red, etc)
%               width:  (Optional,DEF=0.5) LineWidth
%
%     OUTPUTS:  h:      Handle to plot ('LineWidth', etc)

%=============================================================================

x  = x(:);
y  = y(:);

[rx,cx] = size(x);
[ry,cy] = size(y);

if ~exist('c')
  c = 'blue';
end

if ~exist('width')
  width = 0.5;
end

if (cx~=1) | (cy~=1)
  error('*** PLOT_SPIKES only plots vectors ***')
end

n = rx;

x_barv = [x x]';                     
y_barv = [zeros(n,1) y]';

h = plot(x_barv,y_barv,['-' c]);
set(h,'LineWidth',width);
