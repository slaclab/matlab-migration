function stopTimerOnClose()
%stopTimerOnClose()
% Used by plotHistory.m for closing timer functions when figure is closed.
% It also implement the exit from matlab if last figure in family
h = findobj(gcf,'Type','line','Tag','LinePlot');
if ~isempty(h), 
    uData = get(h,'UserData'); 
    tim = uData{2};
    if ~isempty(tim), stop(tim), disp('Timer Stopped due to figure closure'); end
    
end

hh = findobj(0,'Type','Figure')
if length(hh) == 1, exit; end
end