
function lclsStatus()    
fprintf('%s lclsStatus.m started\n', datestr(now));
debugOn = 0;
if strcmp(pwd,'/home/physics/colocho/WORK/matlab/toolbox'), debugOn = 1; end
if debugOn, warndlg('Debug is on'); end

global experiment
global shiftTimes
load /u1/lcls/matlab/config/programSchedule.mat; 
deliveredPV = struct('name', {'SIOC:SYS0:ML00:AO627', 'SIOC:SYS0:ML00:AO820', 'SIOC:SYS0:ML00:CALC138','SIOC:SYS0:ML00:CALC038', ...
                                            'SIOC:SYS0:ML00:CALC038','SIOC:SYS0:ML00:AO467', 'SIOC:SYS0:ML00:AO821', 'SIOC:SYS0:ML00:AO500'}, ...
                 'description', {'X-Ray Energy', 'Bunch Length (e-)',  'Min. Pulse Energy', 'e- Charge','Bandwidth', 'Pulse Rate', 'Peak Power', 'Electron Energy'}, ...
                 'units', { 'eV', 'fs', 'mJ', 'pC', '%', 'Hz', 'GW', 'GeV'}, ...
                 'format',{'%5.0f %s', '%5.0f %s', '%5.1f %s', '%5.0f %s', '%5.0f %s', '%5.0f %s', '%5.1f %s', '%5.1f %s'}, ...
                 'value', nan);  %Add electron Energy  in GeV
             
requestedPV = struct('name', {{'SIOC:SYS0:ML00:CA051', 'SIOC:SYS0:ML00:CA052','SIOC:SYS0:ML00:CA053', 'SIOC:SYS0:ML00:CA054','SIOC:SYS0:ML00:CA055', 'SIOC:SYS0:ML00:CA056', 'SIOC:SYS0:ML00:CA057'}, ...
                              {'SIOC:SYS0:ML00:CA058','SIOC:SYS0:ML00:CA059', 'SIOC:SYS0:ML00:CA060', 'SIOC:SYS0:ML00:CA061', 'SIOC:SYS0:ML00:CA062', 'SIOC:SYS0:ML00:CA063', 'SIOC:SYS0:ML00:CA064'},...
                              {'SIOC:SYS0:ML00:CA065','SIOC:SYS0:ML00:CA066', 'SIOC:SYS0:ML00:CA067', 'SIOC:SYS0:ML00:CA068', 'SIOC:SYS0:ML00:CA069', 'SIOC:SYS0:ML00:CA070', 'SIOC:SYS0:ML00:CA071'},...
                              {'SIOC:SYS0:ML00:CA079','SIOC:SYS0:ML00:CA080', 'SIOC:SYS0:ML00:CA081', 'SIOC:SYS0:ML00:CA082', 'SIOC:SYS0:ML00:CA083', 'SIOC:SYS0:ML00:CA084', 'SIOC:SYS0:ML00:CA085'},...
                              {'SIOC:SYS0:ML00:CA072','SIOC:SYS0:ML00:CA073', 'SIOC:SYS0:ML00:CA074', 'SIOC:SYS0:ML00:CA075', 'SIOC:SYS0:ML00:CA076', 'SIOC:SYS0:ML00:CA077', 'SIOC:SYS0:ML00:CA078'},...
                              {'SIOC:SYS0:ML00:CA086','SIOC:SYS0:ML00:CA087', 'SIOC:SYS0:ML00:CA088', 'SIOC:SYS0:ML00:CA089', 'SIOC:SYS0:ML00:CA090', 'SIOC:SYS0:ML00:CA091', 'SIOC:SYS0:ML00:CA092'} }, ...                                             
                                'description', {'X-Ray Energy', 'Bunch Length (e-)',  'Min. Pulse Energy', 'e- Charge', 'Pulse Rate', 'Bandwidth'}, ...
                                'units', { 'eV', 'fs', 'mJ', 'pC', 'Hz', ' '}, ...
                                'hutch', {'AMO', 'SXR', 'XPP','XCS','CXI','MEC'},...
                                'value', {{'','','','','','',''}, { '','','','','','',''}, {'','','','','','',''}, {'','','','','','',''}, {'','','','','','',''}, {'','','','','','',''} });
 statusStrPV = struct(...
     'name', {'SIOC:SYS0:ML01:SO0085', 'SIOC:SYS0:ML01:SO0082', 'CUD:MCC0:DESTINATION',   ...
                  'MPS:UND1:1650:HXRSS_MODE', 'IOC:BSY0:MP01:REQBYKIKBRST'}, ...
     'description', {'Scheduled Program', 'Photon Destination', 'Electron Destination',...
                         'HXRSS Mode', 'Burst Pulse Rate Mode'}, ...
     'value', nan);
 
 statusNumPV = struct(...
     'name', { 'SIOC:SYS0:ML00:AO426', 'SIOC:SYS0:ML01:AO086',  'SIOC:SYS0:ML01:AO080', 'SIOC:SYS0:ML01:AO081' }, ...
     'description', {'Bandwidth Mode', 'Availability',  'Historical Maximum', 'Historical Mean' }, ...
     'units', {'%', '%', 'mJ', 'mJ'}, ...
     'format', {'%i', '%.1f %s',  '%.1f %s', '%.1f %s'},...
     'value', nan);
 
% static text
figH = figure('Position',[1285 60 1274 944],'Color',[ 1 1 1]) ;
set(figH, 'Toolbar', 'none', 'Menubar', 'none');
color1 = [0.5 0.5 0.5]; 
green = [0 0 1];
newY = 0.48;
X1 = 0.175; X2 = 0.3; Y1 = 0.32;  Y2=0.16;
axes1 = axes;
axes2 = axes;
axes3 = axes;
set(axes1, 'Position',[0.1 0.6 0.775 0.02]); %Destination History color image
set(axes2,'Position',[0.1 0.68 0.775 0.25]) % Main plot
set(axes3, 'Position', [0.1    0.4    0.775    0.2]); % beam line plot
axes(axes2)
annotation('textbox',[0 0.9 0.1 0.1],'String', 'LCLS Key Performance Indicators', 'FontSize', 40, 'LineStyle', 'none'); 
aN = annotation('textbox',[0.8800 0.646 0.0706 0.05],'String',sprintf('%s',datestr(now,'HH:MM')), 'FontSize', 14, 'LineStyle', 'none');  
T = 0.55; Q = 0.75;
aH =       annotation('textbox',[T    0.36    0.2    0.05],'String', 'Scheduled Program');  
aH = [aH annotation('textbox',[T    0.31    0.2    0.05], 'String','Photon Destination')];  
aH = [aH annotation('textbox',[T    0.26    0.2    0.05],'String', 'Electron Destination')];  
aH = [aH annotation('textbox',[T    0    0.1405    0.05], 'String', '(Last 7 Days)', 'Visible','Off')]; 
aH = [aH annotation('textbox',[T 0.16 0.44 0.05],'String', 'Hard X-Ray Self Seeding')];
aH = [aH annotation('textbox',[T 0.11 0.1 0.05], 'String', 'Pulse Rate in Burst Mode', 'Visible','Off')];  
 for ii = 1:length(aH), set(aH(ii),'FontSize',20, 'Color', color1, 'LineStyle', '-', 'VerticalAlignment','bottom'); end
set(aH(1:2:end),'BackgroundColor','c')
set(aH,'LineWidth',3)

aValH =            annotation('textbox',[Q    0.36    0.1    0.05],'String', 'NaN');  
aValH = [aValH annotation('textbox',[Q    0.31    0.1    0.05], 'String','NaN')];  
aValH = [aValH annotation('textbox',[Q    0.26    0.1    0.05],'String', 'NaN')];  
aValH = [aValH annotation('textbox',[Q    0.10    0.1    0.05 ],'String', 'NaN','Visible','Off')];  
aValH = [aValH annotation('textbox',[Q    0.12    0.1    0.05 ], 'String', 'NaN','Visible','Off')];
for ii = 1:length(aValH), set(aValH(ii),'FontSize',20, 'Color', green , 'LineStyle', '-', 'VerticalAlignment','bottom'); end
set(aValH,'LineWidth',3)

%set(aValH(2),'VerticalAlignment', 'Bottom','FitBoxToText','On')
tableHead = sprintf('Parameter %s Requested %s Delivered',blanks(17), blanks(40) );
bH =        annotation('textbox',[0.01 0.27 0.5 0.1], 'String', tableHead, 'FontSize', 16, 'LineStyle', 'none'  );
bH = [bH annotation('textbox',[0.5 Y2-0.025 0.1 0.1], 'String', 'Narrow Bandwidth Taper Mode', 'Visible','Off')];  
bH = [bH annotation('textbox',[T    0.21   0.2    0.05], 'String', '7 Day Availability','Color',color1)];  
bH = [bH annotation('textbox',[0.55 0.06 0.18 0.05],'String', 'Historical Maximum' )];
bH = [bH annotation('textbox',[0.55 0.01 0.18 0.05],'String', 'Historical Mean' )];
for ii = 2:length(bH), set(bH(ii),'FontSize',20, 'LineStyle', '-'); end
set(bH(2:end), 'VerticalAlignment','bottom')
set(bH,'LineWidth',3)

bValH = annotation('textbox',[0.5+X2 Y2-0.025 0.1 0.1], 'String', 'NaN', 'Visible','Off');
bValH = [bValH annotation('textbox',[Q    0.21    0.1    0.05], 'String', 'NaN')];  
bValH = [bValH annotation('textbox',[0.73 0.06 0.07 0.05],'String', 'NaN' )];
bValH = [bValH annotation('textbox',[0.73 0.01 0.07 0.05],'String', 'NaN' )];
for ii = 1:length(bValH), set(bValH(ii),'FontSize',20, 'LineStyle', '-', 'Color', green); end
set(bValH, 'lineWidth', 3, 'VerticalAlignment','bottom')
%
Y3 = 0.75 -  newY+ 0.02;
annStr =  {'X-Ray Energy', 'Bunch Length (e-)',  'Min. Pulse Energy', 'Electron Charge', 'Bandwidth', 'Pulse Rate', 'Peak Power', 'Electron Energy'};
yoffset = 0:0.04:8*0.04;
reqValH = zeros(size(annStr));
delValH = reqValH;
%Make User Request table.
for ii = 1:length(annStr)
    labValH(ii) = annotation('textbox',[0.01 Y3-yoffset(ii) 0.141 0.04],'String',annStr{ii}, 'FontSize', 16, 'LineStyle', '-',  'HorizontalAlignment','left', 'VerticalAlignment', 'Bottom');
    reqValH(ii) = annotation('textbox', [0.151 Y3-yoffset(ii) 0.239 0.04], 'String', 'NaN', 'FontSize', 16, 'LineStyle', '-', 'HorizontalAlignment','right',  'VerticalAlignment', 'Bottom');
    delValH(ii) = annotation('textbox', [0.390 Y3-yoffset(ii) 0.1 0.04], 'String', 'NaN', 'FontSize', 16, 'LineStyle', '-', 'HorizontalAlignment','right',  'VerticalAlignment', 'Bottom','Color', green);
end
tr = 1:2:length(annStr);
set( [labValH(tr)  reqValH(tr)  delValH(tr)], 'BackgroundColor', 'c');
set([labValH, reqValH, delValH],'LineWidth',3)

str1 = {'Mean and Max X-Ray Pulse Intensity from Recent History';' for present e- charge and X-Ray energy operating point:'};
noteH = annotation('textbox',[0.55 0.11  0.4  0.05], 'String', str1, 'Color', color1, 'FontSize',  14, 'LineStyle', 'none', 'VerticalAlignment','bottom');
%set(noteH,'lineWidth', 3)
%

timeWF1 = lcaGetSmart('SIOC:SYS0:ML00:FWF13');
%timeWF2 = lcaGetSmart('CUD:MCC0:TRMIN:WAVEFORM10');
gasDet1WF = lcaGetSmart('SIOC:SYS0:ML00:FWF21');
%maxHistWF = lcaGetSmart('CUD:MCC0:TRMIN:WAVEFORM11');
%meanHistWF =  lcaGetSmart( 'CUD:MCC0:TRMIN:WAVEFORM12');
maxHistWF = lcaGetSmart('SIOC:SYS0:ML01:AO080');
meanHistWF = lcaGetSmart('SIOC:SYS0:ML01:AO081');
[timeVal minIndx]= getTimeVal(timeWF1);
tt = [min(timeVal) max(timeVal)]; one = [ 1 1];
pH = plot(axes2,timeVal, gasDet1WF, 'oc', timeVal, gasDet1WF, '*c', timeVal, gasDet1WF, '*c',...
        timeVal, gasDet1WF, '^c', tt ,  one* maxHistWF(1), 'r',  tt, one * meanHistWF(1),'b');
A = axis;
datetick(axes2,'x',16,'keepticks')
ylabel(axes2,'X-Ray Pulse Intensity (mJ)');
set(pH(2:3), 'LineWidth', 3);
set(figH,'PaperPositionMode','auto')%, 'PaperSize', [7 6]
textMaxH = text(axes2,timeVal(minIndx)+0.86, maxHistWF(1) + 0.2, sprintf('Max: %.1f (mJ)', maxHistWF(1)));
textMeanH = text(axes2,timeVal(minIndx)+0.86, meanHistWF(1) + 0.2, sprintf('Mean: %.1f (mJ)', meanHistWF(1)));

set(reqValH(end-1:end),'String', ''); %last two parameters are not requested by users.
     %Get data
     
% Use lines as beamlines
x0 = 1:10; y0 = zeros(size(x0));
x1 = 10:20; y1 = zeros(size(x1)); 
x2 = 10:20; y2 = 0.3*(x2 - x2(1));
x3 = 20:30; y3 = 0.4*(x3 - x3(1)) + y2(end); %AMO
x4 = 20:40; y4 = 0.2 *(x4 - x4(1)) + y2(end); %SXR
x5 = 20:50; y5 = zeros(size(x5)); %XPP
x6 = 50:70; y6 = zeros(size(x6));% XRT
x7 = 70:80; y7 = zeros(size(x7));%XCS
x8 = 80:90; y8 = zeros(size(x8)); %CXI
x9 = 90:100; y9 = zeros(size(x9));%MEC
linH = plot(axes3,x0,y0,x1,y1,x2,y2,x3,y3,x4,y4,x5,y5,x6,y6,x7,y7,x8,y8,x9,y9);
destIndxList = {1;[1 2 3]; [1 2 3]; [1 3 4]; [1 3 5]; [1 2 6]; [1 2 6:7]; [ 1 2 6:8]; [1 2 6:9]; [1 2 6:10]};
beamDestinations = {'NONE','FEE', 'FEE', 'AMO', 'SXR', 'XPP', 'XRT', 'XCS', 'CXI', 'MEC'};
theColors = [0 0 0; 0 0 0 ; 0 0 0 ; 51 153 255; 153 153 153; 0 102 0; 153 0 153; 153 0 153; 255 0 0; 204 204 0]/255;
beamPrograms = {'MD','FEE', 'FEE', 'AMO', 'SXR', 'XPP', 'XRT', 'XCS', 'CXI', 'MEC'};
theProgramColors = [0 0 0; 0 0 0 ; 0 0 0 ; 51 153 255; 153 153 153; 0 102 0; 153 0 153; 153 0 153; 255 0 0; 204 204 0]/255;
set(axes3,'Visible', 'Off', 'XLim', [0 100], 'YLim', [-2 10])
% % Hutch text (ht)
axes(axes3) % beamline axes
htX = [0 0 0 30.92 41.34 45 65 75 85 95];
htY = [0 0 0  7.54  7.29  2  2 2 2 2];
for ii = 4:length(beamDestinations)
    tH(ii) = text(htX(ii), htY(ii), beamDestinations{ii},'FontSize', 16, 'BackgroundColor' , theColors(ii,:), 'Color', [1 1 1],'Margin', 4);
end

axes(axes1)
destinationHistory = ones(1,1000,3); %1000
destH = image([0 100], [7 8], destinationHistory);
set(axes1,'Visible', 'Off', 'XLim', [0 100])
for ii = 1:length(linH), set(linH(ii), 'LineWidth', 2, 'Marker','o', 'MarkerSize',12, 'Color', theColors(ii,:) ); end
for ii = 1:length(linH), set(linH(ii),'MarkerFaceColor', theColors(ii,:)*.6); end
 for ii = 1:length(linH), set(linH(ii),'MarkerFaceColor', theColors(ii,:) .* [.7 .5 .7]); end
 for ii = 1:length(linH), set(linH(ii),'MarkerFaceColor', [1 1 1]); end
for ii = 1:length(linH), set(linH(ii),'Marker','s', 'MarkerSize', 10); end
 for ii = 2, set(linH(ii),'MarkerFaceColor', [1 1 1]); end

oldMinIndx = 0; %Use to update destination history
initDestinationHistory = 1;
dateTimeH = annotation('textbox',[0 0 0.1 0.1], 'String', datestr(now), 'LineStyle', 'none');
set(dateTimeH, 'Position', [0.80    0.01    0.2028    0.0297])
tic
while(1)
    %try
    val = num2cell(lcaGetSmart({deliveredPV.name}));      [deliveredPV.value] = deal(val{:});
    val = num2cell(lcaGetSmart({statusStrPV.name}));                  [statusStrPV.value] = deal(val{:});
    val = num2cell(lcaGetSmart({statusNumPV.name}));                  [statusNumPV.value] = deal(val{:});

    for jj = 1:length({requestedPV.hutch}), % 6 hutches
        val = num2cell(char(lcaGetSmart(requestedPV(jj).name)));
        for ii = 1:length(requestedPV(1).value), %7 parameters
            requestedPV(jj).value(ii) = {sprintf('%s',val{ii,:})};
        end
    end

    %Update Requested Parameters based on scheduled program
    theProgram = deblank(statusStrPV(1).value);
    programIndx = strmatch(theProgram, {requestedPV.hutch});
    if isempty(programIndx), set(reqValH, 'String', ''), end
    for ii = 1:length(reqValH)-2, set(reqValH(ii), 'String', requestedPV(programIndx).value(ii)); end
    for ii = 1:length(delValH), set(delValH(ii), 'String', sprintf(deliveredPV(ii).format, deliveredPV(ii).value, deliveredPV(ii).units) ), end
    set(delValH(5), 'String', ''); %Bandwidth not measured
    
    %Only show modes that are active
    set(aH(5), 'String', strcat('Hard X-Ray Self Seeding -', strtrim(statusStrPV(4).value) ) );
%     if strcmpi('Yes', strtrim(statusStrPV(5).value) ), visibleBurst = 'On'; else visibleBurst = 'Off'; end
%     set(aH(6), 'Visible', visibleBurst)
     for ii = 1:length(aValH), set(aValH(ii), 'String', strtrim(statusStrPV(ii).value)); end 
%     if (statusNumPV(1).value == 1), bandwidthStr = 'Off'; else bandwidthStr = 'On'; end
%     set(bH(2), 'Visible', bandwidthStr); %This one is special as we get it as int and report it as string.
    for ii = 2:length(bValH), set(bValH(ii), 'String', sprintf(statusNumPV(ii).format, statusNumPV(ii).value, statusNumPV(ii).units) ), end
    
    %Hide Max/Mean when HXRSS mode is seeded.
    if strcmpi('Seeded Mode', strtrim(statusStrPV(4).value) ), visibleMinMax = 'Off'; else visibleMinMax = 'On'; end
    set([bH(4:5) bValH(3:4) noteH ],'Visible',visibleMinMax)
    set([pH(5:6)' textMaxH textMeanH],'Visible',visibleMinMax)
    
    % update plot
    timeWF1 = lcaGetSmart('SIOC:SYS0:ML00:FWF13');
    gasDet1WF = lcaGetSmart('SIOC:SYS0:ML00:FWF21');
    maxHistWF = lcaGetSmart('SIOC:SYS0:ML01:AO080');
    meanHistWF = lcaGetSmart('SIOC:SYS0:ML01:AO081');
    set(aN,'String',sprintf('Now: %s',datestr(now,'HH:MM')) ) %Now String
    %Indicate destination on beamline image and update destination history
    %image
    destinationIndx = strmatch( strtrim(statusStrPV(2).value{:}), beamDestinations);
    if ~isempty(destinationIndx), destinationColor = theColors(destinationIndx(1),:); else destinationColor =[1 1 1]; end 
    set(linH,'MarkerFaceColor', 'none')
    set(linH([destIndxList{destinationIndx}]), 'MarkerFaceColor',destinationColor/1.3);
    set(aValH(2),'BackgroundColor',destinationColor, 'Color', 'w'); %photon destination gets color of hutch.
    
    [timeVal minIndx] = getTimeVal(timeWF1);
    % plot gets color of experiment
    timeValNorm = timeVal - fix(now);
    timeValNorm(timeValNorm<0) = timeValNorm(timeValNorm<0) + 1;
    timeValNorm(end) = 1;
    tmVNormL = timeValNorm(max(minIndx,2)-1);
    tmVNormR =  timeValNorm(minIndx);
   %These are limits to the four plots that make the main plot.
    blockIndx= [ 0  min(tmVNormL, 9/24)   min(tmVNormR, 9/24) max(9/24, tmVNormL) ...
               max(tmVNormR, 9/24 )  max(tmVNormL, 21/24 ) max(tmVNormR, 21/24 )  1];
    for ii = 1:length(blockIndx), blockIndxI(ii) = find(blockIndx(ii)==timeValNorm); end

    for ii = 1:4, set(pH(ii), 'XData', timeVal, 'YData',  nan(size(gasDet1WF))); end
    for ii = 1:4
    destinationColorHistoryIndx = find(  shiftTimes > timeVal(blockIndxI(2*ii-1)) ) ;
    thisExperiment = experiment(destinationColorHistoryIndx(1));
    destinationExperimentIndx = strmatch( thisExperiment, beamPrograms);
     if ~isempty(destinationExperimentIndx), destinationColorHistory = theProgramColors(destinationExperimentIndx(1),:); else destinationColorHistory =[0 0 0]; end 
    gasDet1WF1 = nan(size(gasDet1WF));  
    gasDet1WF1(blockIndxI(2*ii-1):blockIndxI(2*ii)) = gasDet1WF(blockIndxI(2*ii-1):blockIndxI(2*ii));
    set(pH(ii), 'XData', timeVal, 'YData', gasDet1WF1, 'Color',destinationColorHistory )
    end
    
    %set(pH(1), 'XData', timeVal, 'YData', gasDet1WF)
    %set(pH(4), 'XData', timeVal, 'YData', gasDet1WF)
    set(pH(5:6), 'XData', [min(timeVal) max(timeVal)]);
    set(pH(5), 'XData', (timeVal(minIndx)+0.86) + [2/24 3/24]);
    set(pH(6), 'XData', (timeVal(minIndx)+0.86) + [2/24 3/24]);
    set(pH(5), 'YData',  one* maxHistWF(1))
    set(pH(6), 'YData',  one* meanHistWF(1))
    %text(timeVal(minIndx)+0.86, maxHistWF(1) + 0.2, sprintf('All Time Max: %.1f (mJ)', maxHistWF(1)))
    %text(timeVal(minIndx)+0.86, meanHistWF(1) + 0.2, sprintf('All Time Mean: %.1f (mJ)', meanHistWF(1)))
    set(textMaxH, 'String', sprintf('Max: %.1f', maxHistWF(1)), 'Position', [timeVal(minIndx)+0.86+2/24  maxHistWF(1) + 0.2 0]);
    set(textMeanH, 'String', sprintf('Mean: %.1f', meanHistWF(1)),'Position', [timeVal(minIndx)+0.86+2/24  meanHistWF(1) - 0.25 0]);
    set(dateTimeH, 'String', datestr(now))
    axis(axes2, 'tight'); datetick(axes2, 'keeplimits'); A = axis(axes2);
    A(4) = max( 1.1*maxHistWF(1), min(6, max(gasDet1WF)) ); axis(axes2,A);
    %destination history updated 100 times each day
    if 1, fprintf('%i ', mod(minIndx,10)) ; end
    
    if ( (mod(minIndx,10) == 0) || initDestinationHistory)  
       % if(sum(destinationColor) == 3), imageIndx = 2; whiteIndx = 1; else imageIndx = 1; whiteIndx=2; end
        destinationHistory(1,1:999,:) = destinationHistory(1,2:1000,:);
        destinationHistory(1,1000,:) = destinationColor;

        set(destH, 'Cdata', destinationHistory)
        initDestinationHistory = 0;
        pause(10) % Pause long enough so that minIndx does not repeat.
        disp(' ' )
    else 
        pause(5)
    end
    
    if(~debugOn),  
        print('/u1/lcls/physics/cud2web/lclsKPI','-dpng', '-r90'); fprintf('%.1f sec.\n',toc), tic
    end
    makeUserRequestTable(requestedPV, debugOn);
%     catch
%         keyboard
%     end
end %while

end
         
       
function [timeVal minIndx] = getTimeVal(timeWF1)
     thisMinute = (now - fix(now) )* 24;
     thisDay = fix(now);
     minIndx = find(timeWF1 > thisMinute); 
     if isempty(minIndx), minIndx = 1; end
     minIndx = minIndx(1);
     timeVal = thisDay + timeWF1/24;
     timeVal(minIndx:end) = timeVal(minIndx:end) -1;
end
 

function makeUserRequestTable(requestedPV, debugOn)
%if isempty(experiment), load /u1/lcls/matlab/config/programSchedule.mat; end
%persistent needUpdate
global experiment
global shiftTimes
%if isempty(needUpdate), needUpdate = 1; end
%%
if debugOn
    fid = fopen('lclsIUserRequestTable.html','w'); % for testing.
else
    fid = fopen('/u1/lcls/physics/cud2web/lclsIUserRequestTable.html','w');
end

fprintf(fid,'<html>  \n<title>LCLS User Requested Parameters</title>  \n<body>  \n<br>  \n');
fprintf(fid,'<BR><font color="#000099" size="4"><b>LCLS Users Requested Parameters </b></font><BR>');
fprintf(fid,'<BR><TABLE CellPadding=2 width=100%% BORDER=1> \n<TR>');

%Scheduled Program drives request table. shiftTimes has values every 6
%hours, we only make schedue table every 12 hours.
nowDateNum = fix(now);
nowIndx = find((fix(shiftTimes) - nowDateNum) == 0);
if isempty(nowIndx), nowIndx = 1; end
nowIndx = nowIndx(1)+1;

next14Indx = nowIndx :2: min(length(shiftTimes), nowIndx+13*2);
next14Days = shiftTimes(next14Indx);
nextExperiments = experiment(next14Indx);
%make calendar
fprintf(fid,'<TH>Date</TH>');
for ii = 1:2:length(next14Days)
    %fprintf('%s %s\n', datestr(next14Days(ii)), nextExperiments{ii})
    fprintf(fid,'<TH>%s</TH>', datestr(next14Days(ii), 1) );
end
fprintf(fid,'<TR><TH>Day</TH>');
for ii = 1:2:length(next14Days),    fprintf(fid,'<TH>%s</TH>',  nextExperiments{ii}); end
fprintf(fid,'<TR><TH>Night</TH>');
for ii = 1:2:length(next14Days),    fprintf(fid,'<TH>%s</TH>\n',  nextExperiments{ii+1});end
fprintf(fid,'</TABLE>\n');

nextHutchExperiments = intersect(strtrim(nextExperiments), {requestedPV.hutch});
description = {requestedPV.description};
description = [description(1:4), description(6), description(5), 'Comments'];
%make hutch info table
for ii = 1:length(nextHutchExperiments)
    hucthIndx = strmatch(nextHutchExperiments{ii}, {requestedPV.hutch} );
    fprintf(fid,'<BR><font color="#000099" size="4"><b>%s </b></font>', nextHutchExperiments{ii});
    %last update time
    updateTimes = lcaGet(strcat(requestedPV(hucthIndx).name,'TS')');
    lastUpdate = datestr(max(datenum(updateTimes)), 'dd-mmm-yyyy HH:MM');
    %if now is between 9:00 am Tuesday and 14:00 Wednesday lastUpdate needs
    %to be older than 09:00 Tuesday.
    switch datestr(now,'ddd')
        case 'Tue', updateAge = fix(now) + 9/24;
        case 'Wed',  updateAge = fix(now) - 1 + 9/24;
        otherwise, updateAge =  now-6;
    end
    if ( (datenum(lastUpdate) > updateAge) )
        fprintf(fid,'             Last update: %s<BR>', lastUpdate);
        %Table
        fprintf(fid,'<BR><TABLE CellPadding=2 width=50%% BORDER=2> \n<TR>');
        fprintf(fid,'<TH>%s</TH>\n', 'Paremeter', 'Value' ); 
        fprintf(fid,'</TR>');
        % fprintf('\n\n %s\n', nextHutchExperiments{ii});
        % fprintf('Parameter Requested Value');

        for jj = 1:length(description)
            %fprintf( '%s: %s\n', description{jj}, requestedPV(hucthIndx).value{jj});
            fprintf(fid, '<TH>%s:</TH> <TH>%s</TH>\n', description{jj}, requestedPV(hucthIndx).value{jj});
            fprintf(fid,'<TR>');
        end

        numStr =extractNumbersFromString(requestedPV(hucthIndx).value{1});
         fprintf(fid,'<TH>Calculated e- Energy:</TH> <TH>');
         for kk = 1:length(numStr), fprintf(fid,'%s eV  (%.1f GeV);  ', numStr{kk}, 0.14998*sqrt(str2num(numStr{kk}))); end 
        fprintf(fid,'</TH>');
        fprintf(fid,'<TR>');
        fprintf(fid,'</TABLE>\n');
    else
        fprintf(fid,'             Parameters not up-to-date.  Last update: %s<BR>', lastUpdate);
    end %if lastUpdate is in last 6 days
end
fclose all;
%%
end

function numStr =extractNumbersFromString(str1)
%%
%str1 = 'thsi is 2 1200 or 11.5kev or 4500eV'
s1 = regexp(str1,'[0-9.]');
if isempty(s1), numStr = '0'; end
numStartI = ([1 find(diff(s1) > 1)+1]);
numEndI = [find(diff(s1)>1) length(s1)];
for ii = 1:length(numStartI)
    tempStr =  [str1(s1(numStartI(ii):numEndI(ii))) ];
    numVal = str2num(tempStr);
    if numVal < 12, tempStr = sprintf('%.0i', numVal * 1000); end 
    numStr{ii} =tempStr;
end

%%
end











