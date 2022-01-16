function opGuiHist(time)
%function opGuiHist(timeRange)
%time -  String with date and time stamp
% time = '05/15/2011 06:22:00'

% William Colocho, July 2011
if nargin <1, time = '02/15/2011 06:22:00'; end
global OPctrl
op = checkOperatingPoint;
head = sprintf('LCLS Operationg Point Now v.s. %s\n', time);
figH = figure;
P = get(figH, 'Position'); P(4) = P(4)* 2.3; P(3) = P(3) * 1.5;
set(figH, 'Position',P), drawnow
vStep = 0.02;
annotation('textbox',[0.07 0.91 0.62 vStep],'String',head,'FontSize',14);
annotation('textbox',[0.07 0.91-vStep 0.31 vStep],'String','Parameter');
annotation('textbox',[0.38 0.91-vStep 0.10 vStep],'String','Value');
annotation('textbox',[0.48 0.91-vStep 0.06 vStep],'String','Units');
annotation('textbox',[0.54 0.91-vStep 0.15 vStep],'String','Historical');
jj=0;
for nParam = 1:length(OPctrl.order) % Use only paremeters specified in OPctrl
    ii = OPctrl.order(nParam); % ii is index to op
    jj = jj+1;
    if isempty(op{ii}.savActPV), continue, end
    fprintf('%s, %.2f\n',op{ii}.Parameter,  lcaGet(op{ii}.savActPV) )
    vOff = (jj+1)*vStep;
    annotation('textbox',[0.07 0.91-vOff .31 vStep], 'String',op{ii}.Parameter);
    nowVal = lcaGet(op{ii}.savActPV);
    annotation('textbox',[0.38 0.91-vOff .10 vStep], 'String', sprintf(op{ii}.Tfmt, '',nowVal ));
    annotation('textbox',[0.48 0.91-vOff .06 vStep], 'String',sprintf('%s',op{ii}.Unit) );
    histVal = histValFn( [op{ii}.savActPV, ':HIST.lcls'], time);
    if abs(nowVal - histVal) ~= 0, cStr = 'r'; else cStr = 'k'; end
    annotation('textbox',[0.54 0.91-vOff .15 vStep], 'String', sprintf(op{ii}.Tfmt,'',histVal ), 'Color', cStr );
end

end

function histVal = histValFn(PV, time)
%Given timeRange and PV return one value
theStart = datenum(time) - 1/24/60;
timeRange = {[datestr(theStart,23),' ',datestr(theStart,13)],  [datestr(time,23), ' ',datestr(time,13)]};
[time, value] = aidaGetHistory(PV, timeRange);
histVal = value(1);
end



