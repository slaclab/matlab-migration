function matching_twissPlot(SIGMA, X, zVect, handles, Color_)
%
%
%
%
%
%

if nargin < 5
    Col1 = 'b-.';
    Col2 = 'r-.';
else
    Col1 = Color_(1);
    Col2 = Color_(2);
end

twiss = matching_twissParameters(SIGMA,X(7,:));
twiss=num2cell(twiss,2);
[exn,bx,ax,eyn,by,ay,ex,ey,sx,sy]=deal(twiss{:});

hAxes=handles.axes_beta;
%axes(hAxes);
hold(hAxes,'on');grid(hAxes,'on');
plot(hAxes,zVect,bx,Col1,zVect,by,Col2);
xlabel(hAxes,'z  (m)');ylabel(hAxes,'\beta  (m)');
%legend(['\beta_x'],['\beta_y']);
if nargin < 5
    legend(hAxes,'\beta_x (init.)','\beta_y(init.)');
else
   legend(hAxes,'\beta_x (init.)','\beta_y(init.)','\beta_x (final)','\beta_y(final)');
   % set(h,'Orientation', 'horizontal');
end
%v = axis;
vxmin = min(zVect); vxmax = max(zVect); 
set(hAxes,'XLim',[vxmin vxmax],'YLim',[0 Inf]);

hAxes=handles.axes_sigma;
%axes(hAxes);
hold(hAxes,'on');grid(hAxes,'on');
plot(hAxes,zVect,sx*1e6,Col1,zVect,sy*1e6,Col2);
xlabel(hAxes,'z  (m)');ylabel(hAxes,'\sigma  (\mum)');
%legend(['\sigma_x '],['\sigma_y']);
%v = axis;
vxmin = min(zVect); vxmax = max(zVect); 
set(hAxes,'XLim',[vxmin vxmax],'YLim',[0 Inf]);
if nargin < 5
    legend(hAxes,'\sigma_x (init.)','\sigma_y (init.)');
else
    legend(hAxes,'\sigma_x (init.)','\sigma_y (init.)','\sigma_x (final)','\sigma_y (final)');
    %set(h,'Orientation', 'horizontal');
    optics=handles.optics;
    cSum=cumsum([optics.nsegment]);
    nref=cSum(strcmp({optics.name},'screen') & ~strncmp({optics.type},'BPM',3))+1;
    plot(hAxes,zVect(nref),sx(nref)*1e6,'ko',zVect(nref),sy(nref)*1e6,'kx');
    refName=cellstr(optics(1).reference);
    nref=cSum(ismember({optics.type},refName))+1;
    plot(hAxes,zVect(nref),sx(nref)*1e6,'go',zVect(nref),sy(nref)*1e6,'gx');
end
