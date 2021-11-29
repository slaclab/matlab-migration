function plot_bars(x,y,dy,mrk,bar_color);

%               plot_bars(x,y,dy[,mrk,bar_color])
%
%               Function to plot vertical error bars of y +/- dy.
%
%     INPUTS:   x:     		The horizontal axis data vector (column or row)
%               y:      	The vertical axis data vector (column or row)
%               dy:     	The half length of the error bar on "y" (column, row,
%                       	or scalar)
%               mrk:   		(Optional,DEF=none) The plot character at the point (x,y)
%                       	(see plot)
%				bar_color:	(Otional,DEF='k') Color of error bar (e.g. 'r')

%=============================================================================

x  = x(:);
y  = y(:);
dy = dy(:);

[rx,cx] = size(x);
[ry,cy] = size(y);
[rdy,cdy] = size(dy);

if (cx~=1) | (cy~=1) | (cdy~=1)
  error('*** PLOT_BARS only plots vectors ***')
end

n = rx;

if rdy==1
  dy = dy*ones(size(y));
end

tee = (max(x) - min(x))/100;

x_barv = [x x x-tee x+tee x-tee x+tee];
y_barv = [y+dy y-dy y-dy y-dy y+dy y+dy];

if ~exist('bar_color')
  bar_color = 'k';  
end
if ~exist('mrk')
  plot(x_barv(:,1:4)',y_barv(:,1:4)',['-' bar_color(1)]);
else
  plot(x_barv(:,1:4)',y_barv(:,1:4)',['-' bar_color(1)],x,y,mrk);
end

hold_state = get(gca,'NextPlot');
hold on;
plot(x_barv(:,5:6)',y_barv(:,5:6)',['-' bar_color(1)]);
set(gca,'NextPlot',hold_state);
