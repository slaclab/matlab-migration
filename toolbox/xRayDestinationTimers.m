function xRayDestinationTimers
%function xRayDestinationTimers
% Plots history of X Ray destination counters.
%

shiftOption = listdlg('PromptString', 'Shift?','SelectionMode','single', ...
    'ListString',{'NOW', 'DAY', 'SWING', 'OWL'});

switch shiftOption
    case 1, shiftOption = 'NOW';
    case 2, shiftOption = 'DAY';
    case 3, shiftOption = 'SWING';
    case 4, shiftOption = 'OWL';
end
destinationTimerPV = struct('name',{'SIOC:SYS0:ML00:CALC163','SIOC:SYS0:ML00:CALC164', 'SIOC:SYS0:ML00:CALC165','SIOC:SYS0:ML00:CALC166',...
    'SIOC:SYS0:ML00:CALC167','SIOC:SYS0:ML00:CALC168','SIOC:SYS0:ML00:CALC169','SIOC:SYS0:ML00:CALC170'},...
    'description', {'FEE', 'AMO', 'SXR', 'XPP', 'XRT', 'XCS', 'XCI', 'MEC'}, ...
    'value', nan);

presentShift =  now - fix(now);

if presentShift < 8/24, thisShift = 'OWL'; end
if presentShift > 8/24 && presentShift < 16/24, thisShift = 'DAY';   end
if presentShift > 16/24, thisShift = 'SWING'; end

dayOffset = -1;

switch shiftOption
    case 'DAY', shiftOffset = 16/24; if strcmp(thisShift,'SWING'), dayOffset = 0; end
    case 'SWING', shiftOffset = 24/24;
    case 'OWL', shiftOffset = 8/24; if sum(strcmp(thisShift, {'DAY','SWING'})), dayOffset = 0; end
end

if strcmp(shiftOption, 'NOW')
    theEnd = now;
else
    theEnd = fix(now) + dayOffset + shiftOffset;
end

theStart = theEnd - 8/24;
timeRange = {[datestr(theStart,23),' ',datestr(theStart,13)], [datestr(theEnd,23), ' ',datestr(theEnd,13)]};
legStr = {destinationTimerPV.description};
  for ii = 1:length(destinationTimerPV)
      [time destinationTimerPV(ii).value] = aidaGetHistory([destinationTimerPV(ii).name, ':HIST.lcls'], timeRange, {'current'}, 1);
      maxVal = max( destinationTimerPV(ii).value );
      legStr(ii) = {sprintf('%s %.1f', legStr{ii}, maxVal)};
  end
  V = [destinationTimerPV.value];
  V = reshape(V, length(time), length(destinationTimerPV) );
  plot(time, V)
  ylabel('Delivered Time (hours)')
  xlabel(timeRange)
  datetick
  legend(legStr, 'Location', 'Best')
  title('X-Ray Destination Timers')
  set(gcf,'CloseRequestFcn','exit');

end
