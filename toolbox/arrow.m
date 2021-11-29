function handles = arrow(T,H,handles,hAxis,color,linewidth,arrowScale)
%  plots an arrow from tail (T) at (x0, y0) and
%  head (H) at the point  (x1, y1). 

if nargin < 7 arrowScale=0.05; end %length of arrow as percent of total vector length
if nargin < 6, linewidth=1; end
if nargin < 5, color = 'k'; end
if nargin < 4
    handles=figure;
    hAxis=gca;
end

% axes(hAxis);

phi=1/sqrt(2); %angle of arrow

x0 = T(1); y0 = T(2);
x1 = H(1); y1 = H(2);

len = sqrt((x1-x0)^2+(y1-y0)^2); %vector length
theta = atan((y1-y0)/(x1-x0)); %vector angle
dir=1;
if x0>x1
    dir=-1;
end

plot([T(1), H(1)], [T(2), H(2)],color,'Linewidth',linewidth,'Parent',hAxis)
hold on

ax=x1-arrowScale*len*cos(theta); 
ay=y1-arrowScale*len*sin(theta);

r1=[cos(phi) -sin(phi);sin(phi) cos(phi)];
r2=[cos(-phi) -sin(-phi);sin(-phi) cos(-phi)];


a1=dir*r1*[ax-x1; ay-y1];
a2=dir*r2*[ax-x1; ay-y1];


plot([H(1), a1(1)+x1], [H(2), a1(2)+y1], color,'Linewidth',linewidth);
plot([H(1), a2(1)+x1], [H(2), a2(2)+y1], color,'Linewidth',linewidth);
axis off



