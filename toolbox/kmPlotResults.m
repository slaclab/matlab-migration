function mainHandles = kmPlotResults(mainHandles)
%
% mainHandles = kmPlotResults(mainHandles)
%
% Plot each segment results in a new results figure
%

DLL = [25 -25 0 0 ];% offset applied to new figure from previous [pixels]
figureOrigUnits = get(gcf,'Units');
set(gcf,'Units','pixels'); %make current figure units pixels
oldFigPosition = get(gcf,'Position');
set(gcf,'Units',figureOrigUnits);%put units back
newFigPosition = oldFigPosition + DLL;
ResultsFig = figure('Visible', 'off',...
    'Position',newFigPosition,...
    'Color', [.76,.87,.78],...
    'Name','Results',...
    'Units','pixels',...
    'Visible','on');% create new figure for Results plots
mainHandles.ResultsFig = ResultsFig;

mainHandles.Kref = lcaGet( sprintf('USEG:UND1:%d50:KACT',mainHandles.refSegment) );

% create the results plots
if strcmp(mainHandles.method, 'One Segment')

    % calculate delta K result
    [p,S] = polyfit(mainHandles.positionArray,mainHandles.edgeGeVArray,2);%fit data
    disc = sqrt(p(2)^2 - 4*p(1)*(p(3)-mainHandles.edgeGeVRef));
    if (p(1) == 0)
        xMatch = (mainHandles.edgeGeVRef-p(3))/p(2);
    else
        xMatch = (-p(2) - disc)/(2*p(1));% sign of disc chosen to get proper branch of parabola
    end
    deltaK = -xMatch * mainHandles.KTaper;% minus sign!

    %prepare delta K results in ResultsFig
    pdata.p = p;
    pdata.deltaK = deltaK;
    pdata.mainHandles.testSegment = mainHandles.testSegment;
    pdata.ref_seg = mainHandles.refSegment;
    pdata.mainHandles.edgeGeVArray = mainHandles.edgeGeVArray;
    pdata.mainHandles.positionArray = mainHandles.positionArray;
    pdata.mainHandles.edgeGeVRef = mainHandles.edgeGeVRef;
    pdata.xMatch = xMatch;

    xx = (pdata.mainHandles.positionArray(1):.05:pdata.mainHandles.positionArray(length(pdata.mainHandles.positionArray)));
    f = polyval(pdata.p,xx);
    plot(pdata.mainHandles.positionArray,pdata.mainHandles.edgeGeVArray,'--o',xx,f,'-');
    hold on;
    xx = [min(pdata.mainHandles.positionArray) max(pdata.mainHandles.positionArray)];
    yy = [pdata.mainHandles.edgeGeVRef pdata.mainHandles.edgeGeVRef];
    plot(xx,yy,'Color','r','LineWidth',3);
    xlabel('Segment position [mm]');
    ylabel('Spectrum edge energy [GeV]');
    text(.2,3.5,...
        ['Segment ' num2str(pdata.mainHandles.testSegment) ],...
        'Units','inches');
    text(.2,3.3,...
        ['Position for Match [mm]  ' num2str(pdata.xMatch,3) ],...
        'Units','inches');
    text(.2,3.1,...
        ['(Ktest - Kref)/K \times 10^{4} =  ' num2str(1e4*pdata.deltaK/mainHandles.KNominal,2) ],...
        'Units','inches');
    text(.2,2.9,...
        ['Fit method:  ' mainHandles.fitMethod ],'Units','inches');
    refLabel = ['Reference Segment ' num2str(mainHandles.refSegment) ];
    refLabel = [refLabel ', ' num2str(mainHandles.edgeGeVRef) ' +/- ' ];
    refLabel = [refLabel num2str(mainHandles.edgeGeVRefSTD,1)];
    text(-.2,pdata.mainHandles.edgeGeVRef+.002,...
        refLabel,...
        'Units','data');

    % update data to save
    mainHandles.deltaK = pdata.deltaK;
    mainHandles.xMatch = pdata.xMatch;
    
    % prepare measurement data for saving
    mainHandles.results.deltaK = struct(    'testSegment', mainHandles.testSegment,...
    'refSegment', mainHandles.refSegment,...
    'positionArray', mainHandles.positionArray,...
    'edgeGeVArray', mainHandles.edgeGeVArray,...
    'xMatch',  pdata.xMatch,...
    'deltaK', deltaK,...
    'Kref', mainHandles.Kref);
    
end

if strcmp(mainHandles.method,'Two Segment')

    pdata.mainHandles.testSegment = mainHandles.testSegment;
    pdata.ref_seg = mainHandles.refSegment;
    pdata.mainHandles.positionArray = mainHandles.positionArray;
    pdata.maxSlope = mainHandles.maxSlope;

    [p,S] = polyfit(pdata.mainHandles.positionArray,pdata.maxSlope,2);
    extremum = -0.5*p(2)/p(1); % mm
    deltaK = -extremum * mainHandles.KTaper ;%minus sign!
    pdata.xMatch = extremum;
    xx = (pdata.mainHandles.positionArray(1):.05:pdata.mainHandles.positionArray(length(pdata.mainHandles.positionArray)));
    f = polyval(p,xx);
    plot(pdata.mainHandles.positionArray,pdata.maxSlope,'--o',xx,f,'-');
    xlabel('Segment position [mm]');
    ylabel('Max slope of response curve [arb]');
    text(.2,1,...
        ['matched K for segment ' num2str(pdata.mainHandles.testSegment) ' at ' num2str(extremum,2) ' mm'],...
        'Units','inches');
    text(.2,.8,...
        ['(Ktest - Kref)/K \times 10^{4} =  ' num2str(1e4*deltaK/mainHandles.KNominal,2) ],...
        'Units','inches');
    %['\Delta K/K  [10^{4}]  = ' num2str(1e4*deltaK/mainHandles.KNominal,1) ],...
    text(.2,.6,...
        ['segments ' num2str(pdata.mainHandles.testSegment) ', ' num2str(pdata.ref_seg) ],...
        'Units','inches');
    
    % prepare measurement data for saving
    mainHandles.results.deltaK = struct(    'testSegment', mainHandles.testSegment,...
    'refSegment', mainHandles.refSegment,...
    'positionArray', mainHandles.positionArray,...
    'maxSlope', pdata.maxSlope,...
    'xMatch',  pdata.xMatch,...
    'deltaK', deltaK,...
    'Kref', mainHandles.Kref);
end

%guidata(mainHandles.KM_main, mainHandles); % update the guidata with results

