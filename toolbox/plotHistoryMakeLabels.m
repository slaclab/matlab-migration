function plotHistoryMakeLabels()
uData = get(gcf,'UserData');
handleAxes = findobj(uData.figH,'Type','Axes');
xLimit = get(handleAxes,'Xlim');
ii = (uData.time > xLimit(1)) & (uData.time < xLimit(2));
str = {datestr(xLimit,23) datestr(xLimit,15)};
datetick('keeplimits');

bks = blanks(8);
Xbar = mean(uData.value(ii)); S = std(uData.value(ii)); m = min(uData.value(ii)); M = max(uData.value(ii));

xStr = { sprintf('MEAN: %.5g%s%s %s%s MIN: %.5g', Xbar, bks ,str{1}(1,:),str{2}(1,:), bks, m ) ,  ...
             sprintf('SIGMA: %.5g%s%s %s%s MAX: %.5g',  S, bks, str{1}(2,:),str{2}(2,:), bks, M ), ...
             sprintf('SIGMA/MEAN: %.5g%sMAX - MIN: %.5g%s', S/Xbar, blanks(32), M - m, blanks(12)) };
 
try epicsDesc = lcaGet([uData.pv,'.DESC']);
catch epicsDesc = {' '}; end

try epicsUnits = char(lcaGetUnits(uData.pv));
catch epicsUnits = ' '; end 

title([uData.pv uData.medFiltStr],'interpreter','none')
ylabel([epicsDesc,  epicsUnits] )
xlabel(xStr)
end