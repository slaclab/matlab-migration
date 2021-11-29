function [] = FastEventPlots(PVs)
% FastEventPlots plots the data recorded by FastEventMonitor in a series of
% Matlab plots grouped and colored as defined in the comments at the start
% of FastEventPVs.txt.

global figHandle

% Close old plots, and then plot the new data.
figPosition = [25 550 600 500]; % [left, bottom, width, height]
try
    figPosition = get(figHandle(1),'Position');
    close(figHandle)
catch
end

nPlots = PVs.plot(PVs.N(1));
points = length(PVs.time(1,:));
deltaT = (PVs.time(1,:) - PVs.triggerTime)*24*3600;  % Days to seconds
dateVector = datevec(PVs.triggerTime);
dateString = sprintf('%d-%02d-%02d %02d:%02d:%05.2f',...
                dateVector(1),dateVector(2),dateVector(3),...
                dateVector(4),dateVector(5),dateVector(6));
figHandle = zeros(nPlots,1);
n = 0;
for p = 1:nPlots
    figHandle(p) = figure('Name',['Event at ',dateString],'Position',...
        figPosition + [floor((p-1)/20)*500 0 0 0] +...
        mod(p-1,20)*[20 -25 0 0]);
    lgnd = cell(PVs.traces(p),1);
    if length(PVs.N) > 1 && PVs.N(2) == n+1
        points = sum(PVs.time(2,:) > 0);
        deltaT = (PVs.time(2,1:points) - PVs.triggerTime)*24*3600;
    end
    data = zeros(PVs.traces(p),points);
    for m = 1:PVs.traces(p)
        n = n + 1;
        data(m,:) = PVs.hist(n,1:points);
        lgnd{m} = [texlabel(PVs.name{n},'literal'),' [',PVs.unit{n},']'];
    end
    if PVs.log(p)
        semilogy(deltaT,data)
    else
        plot(deltaT,data)
    end
    xlabel(['Time [s] from ',dateString])
    legend('Strings',lgnd,'Location','NorthOutside','FontSize',12)
end
end
