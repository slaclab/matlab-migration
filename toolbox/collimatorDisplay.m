function [  ] = collimatorDisplay( oneShot )
%
%   Continuously updated scalable display of all Halo Collimator jaws, beam
%   position, design acceptance, and some radiation data.
%
%   [  ] = collimatorDisplay( oneShot )
%
% oneShot can be any input. If it is included the display  will only update once.

% set up figure
[ax, axc] = plotSetup(); % ax/axc are handles to collimator/radiation subplots. 

% get design acceptance (beam stayclear for zero steering allowance)
load('LCLS2cuH_BSC'); %  loads 'BSCxn', 'BSCxp', 'BSCyn', 'BSCyp','twiss')
BSCz = [twiss.z];

% Get bpm pvs: meme_names is slow so keep out of loop:
bpmxSCSXRpv =  meme_names('lname','SC_SXR','name','BPMS%:X1H');
bpmySCSXRpv =  meme_names('lname','SC_SXR','name','BPMS%:Y1H');
% bpmzSCSXRpv =  meme_names('lname','SC_SXR','name','BPMS%:Z');
bpmzSCSXRpv =  strrep(bpmxSCSXRpv, 'X1H','Z'); % use this form to match the synchronous data


bpmxSCHXRpv =  meme_names('lname','SC_HXR','name','BPMS%:X1H');
bpmySCHXRpv =  meme_names('lname','SC_HXR','name','BPMS%:Y1H');
% bpmzSCHXRpv =  meme_names('lname','SC_HXR','name','BPMS%:Z');
bpmzSCHXRpv =  strrep(bpmxSCHXRpv, 'X1H','Z'); % use this form to match the synchronous data


bpmxCUHXRpv =  meme_names('lname','CU_HXR','name','BPMS%:X1H');
bpmyCUHXRpv =  meme_names('lname','CU_HXR','name','BPMS%:Y1H');
% bpmzCUHXRpv =  meme_names('lname','CU_HXR','name','BPMS%:Z');
bpmzCUHXRpv =  strrep(bpmxCUHXRpv, 'X1H','Z'); % use this form to match the synchronous data


% Get cblm pvs: slow keep out of loop
cblmHpvs = meme_names('name', 'CBLM:UNDH:%I1_LOSS');
cblmSpvs = meme_names('name', 'CBLM:UNDS:%I1_LOSS');

% add PBLM after undulator
cblmHpvs = [cblmHpvs;  meme_names('name', 'PBLM:UEH:863:I0_LOSS') ];
cblmSpvs = [cblmSpvs;  meme_names('name', 'PBLM:UES:863:I0_LOSS') ];

% kill annoying warnings when there is no beam
lcaSetSeverityWarnLevel(4) % level 3 sends warnings to console

%
% Continuosly update display
%


loopForever = 1; % continuous update 

while (loopForever)

    for k=1:length(ax(:))
        cla(ax(k)); % clear out all plots
    end
    cla(axc(1));
    cla(axc(2));
    
    % Plot undulator radiation data (these plots should clear themselves)
    cblmPlot(axc,cblmHpvs,cblmSpvs);

    % loop over subplots
    for q=10:length(ax(:))

        switch q
            
            case 1 %  laser heater energy
                cNames = {'CEHTR'};
                beamline ='SC_SXR';
            case 2 % vert SC laser heater
                cNames = {'CYC01'; 'CYC03'};
                beamline ='SC_SXR';
            case 3 % Horizontal SC laser heater
                cNames = {'CXC01'; 'CXC03'};
                beamline ='SC_SXR';
            case 4 % SC BC1/2 ENERGY
                cNames = {'CE11B'; 'CE21B'};
                beamline ='SC_SXR';
            case 5 % SC BC1/2 vertical
                cNames = {'CYC11'; 'CYC13'};
                beamline ='SC_SXR';
            case 6 % SC BC1/2 horizontal
                cNames = {'CXC11'; 'CXC13'};
                beamline ='SC_SXR';
            case 7 % SC BYPASS energy
                cNames = {'CEDOG'};
                beamline ='SC_SXR';
            case 8 % SC BYPASS VERTICAL
                cNames = {'CYBP22', 'CYBP26'};
                beamline ='SC_SXR';
            case 9 % SC BYPASS HORIZONTAL
                cNames = {'CXBP22', 'CXBP26'};
                beamline ='SC_SXR';
            case 10 % Final HXR Energy
                cNames = {'CEDL1', 'CEDL3'};
                beamline ='CU_HXR';
            case 11 % Final HXR Vertical
                cNames = {'CYBX36'}; % CYBX32 is deferred July 2020
                beamline ='CU_HXR';
            case 12 % Final HXR Horizontal
                cNames = { 'CXQT22'};   %  'CXQ6'is deferred July 2020
                beamline ='SC_HXR';
            case 13 % Final SXR Energy
                cNames = {'CEDL13', 'CEDL17'};
                beamline ='SC_SXR';
            case 14 % Final SXR Vertical
                cNames = {'CYDL16'}; % 'CYBDL' is deferred July 2020
                beamline ='SC_SXR';
            case 15 % Final SXR Horizontal
                cNames = {'CXBP34'}; % 'CXBP30' is deferred July 202
                beamline ='SC_SXR';
            case 16 % Copper Linac Energy
                cNames = {'CE11', 'CE21'};
                beamline ='CU_HXR';
            case 17 % Copper Linac Vertical
                cNames = {'C29096', 'C29146', 'C29446','C29546', 'C29956','C30146', 'C30446', 'C30546' };
                beamline ='CU_HXR';
            case 18 %  Copper Linac Horizontal
                cNames = {'C29096', 'C29146', 'C29446','C29546', 'C29956','C30146', 'C30446', 'C30546' };
                beamline ='CU_HXR';
        end
        
        % Select bpm data for beamline
        
        switch beamline
            case 'SC_SXR'
                bpmxPVs = bpmxSCSXRpv;
                bpmyPVs = bpmySCSXRpv;
                bpmzPVs = bpmzSCSXRpv;
                
            case 'SC_HXR'
                bpmxPVs = bpmxSCHXRpv;
                bpmyPVs = bpmySCHXRpv;
                bpmzPVs = bpmzSCHXRpv;
                
            case 'CU_HXR'
                bpmxPVs = bpmxCUHXRpv;
                bpmyPVs = bpmyCUHXRpv;
                bpmzPVs = bpmzCUHXRpv;
        end
        
        % get the bpm values
        [bpmx, bpmy, bpmz] = bpmPlotData(beamline,bpmxPVs, bpmyPVs, bpmzPVs);
        
        % update the subplot
        posJaw=[];
        negJaw=[];
        
        for k=1:length(cNames) % step thru collimators in  subplot
            c = collimatorJawData(cNames(k)); % return all jaw data
            
            if q==17 % vertical copper linac subplot
                posJaw(k) = c.posy.lvdt; % this could be switched to motor
                negJaw(k) = c.negy.lvdt;
                bpmYplot = bpmy; % abscissa
                BSCp = 1000*BSCyp;
                BSCn = 1000*BSCyn;
            end
            if q==18 % horizontal coppler linac subplot
                posJaw(k) = c.posx.lvdt; % this could be switched to motor
                negJaw(k) = c.negx.lvdt;
                bpmYplot = bpmx; % abscissa
                BSCp = 1000*BSCxp; % positive acceptance
                BSCn = 1000*BSCxn; % negative accepance (usually =-postive)
            end
            
            
            if q<17  % all two jaw collimators
                if isfield(c,'posx') % horizontal
                    posJaw(k) = c.posx.lvdt; % this could be switched to motor
                    negJaw(k) = c.negx.lvdt;
                    bpmYplot = bpmx; % abscissa
                    BSCp = 1000*BSCxp; % positive acceptance
                    BSCn = 1000*BSCxn; % negative accepance (usually =-postive)
                else % vertical
                    posJaw(k) = c.posy.lvdt;
                    negJaw(k) = c.negy.lvdt;
                    bpmYplot = bpmy; % abscissa
                    BSCp = 1000*BSCyp;
                    BSCn = 1000*BSCyn;
                end
            end
            
        end
        
        bpmXplot = bpmz; % ordinate for plots
        
        % plot bpms, acceptance, and all jaw-pairs appropriate for ax(q)
        jawPlot(ax(q), cNames,  posJaw, negJaw, bpmXplot, bpmYplot, BSCp,BSCn, BSCz)
        
        
        % Adjust vertical scale of linac energy collimator plot
        set(ax(16) ,'YLim', [-10,10]);
        
    end  % end of loop over subplots
    
    pause(6)
    
    if nargin==1
        loopForever = 0; % stop if nargin==0      
    end
    
end  % end of continuous update loop



function [ax, axc] = plotSetup()
%
% create a figure and return handles to the subplots
% draw labels and graphics
%
figureSize = [0,0,1,1];
figure('Units', 'normalized','Position', figureSize, 'MenuBar','none')% full screen [0,0,1,1]

% create axis for labels
labelAxis = axes('Position', [0,0,1,1],'XTick',[],'YTick',[]);
t1 = text( 0.4, 0.95, 'Halo Collimators', 'FontSize', 24  );
set(labelAxis,'Visible','off')
set(t1,'Visible','on')

% graphic column settings in normalized units
g=0.06/5; % gaps between plot
normalPlotWidth = .95/8;
copperPlotWidth = 1.8*normalPlotWidth;
nW=normalPlotWidth;
cW=copperPlotWidth;
lw=.11; % labels on the left

lowerLeftArray = [lw (lw+g+nW) (lw+2*g+2*nW) (lw+3*g+3*nW) (lw+4*g+4*nW) (lw+5*g+5*nW)];
plotHeight = .35/3;
bottomHeight = .45;
Vgap = 0.01;
bottomArray  = bottomHeight + [0 (plotHeight+Vgap) (2*plotHeight+2*Vgap)];

% add image
A = imread('collimatorOverview.jpeg');
imshow(A);
image(A);
set(labelAxis,'XTick',[],'YTick',[])

% create axes for subplots
for q=1:3
    for l=1:5
        ax(q,l) = axes('Position',[lowerLeftArray(l), bottomArray(q), nW, plotHeight]);
        set(ax(q,l), 'XTick',[])
    end
    ax(q,6) = axes('Position',[lowerLeftArray(6), bottomArray(q), cW, plotHeight]);
    set(ax(q,6), 'XTick',[])
end

% create axes for cblm plots
axc(1)=axes('Position',[.8, .3,.1, .1]);  % SXR radiation
axc(2)=axes('Position',[.8, .075,.1, .1]);% HXR radiation


function jawPlot(ax, cNames,  posJaw, negJaw, bpmXplot, bpmYplot, BSCp, BSCn, BSCz )    
%
% jawPlot(ax, colldata, bpm, acceptance)
%
% plot data for jaw-pairs for collimators cNames for subplot ax
%
% Some collimators are two-jaw, either horizontal or vertical, and some are
% four-jaw with both horizontal and vertical jaw pairs. jaw data supplied
% must align with the defintion of the axes (either horizontal or vertical).

% set current axis
% axes(ax);


% get z range for subplot
zRange =[]; % initialize plot range
for q=1:length(cNames)
    cName = char(cNames(q));
    z = str2double(meme_names('ename',cName,'show','z')); % collimator z
    zRange = [zRange z]; % range for subplot to display
end  

% set horizontal limts on subplot
zLimits= [min(zRange)-25, max(zRange)+25]; % set the horizontal subplot scale
set(ax, 'XLimMode','manual')
xlim(ax, zLimits);

% Loop over collimators in  subplot, draw one jaw at a time

jawWidth = 0.025*(max(zLimits) - min(zLimits)); % scale width visually

set(ax, 'YLimMode', 'manual')
for q=1:length(cNames)
    cName = char(cNames(q));
    z = str2double(meme_names('ename',cName,'show','z')); % collimator z

    % set y axis limits
    if ~( strcmp(cName,'CE11')||strcmp(cName,'CE21') );
        ymin = -4;
        ymax = 4;
    else
        ymin = -10;
        ymax = 10;
    end
    ylim(ax,[ymin, ymax]);
    textY = 0.7*ymax ;
    jawHeight = 0.4*ymax; % mm
    jog = 0.7*ymax/4; % jog linac collimator labels to avoid overlap
    
    
    % draw positive jaw
    if posJaw(q)<ymax  % not off scale
        rectangle('Parent',ax, 'Position', [z, posJaw(q), jawWidth, jawHeight],...
            'FaceColor', 'r',...
            'LineStyle','none');
    else
        line('Parent',ax,'Xdata',[z,z],'YData', [ymax, ymax],...
            'Marker', '^','MarkerSize',12,...
            'Color','r')    % off scale
    end
    
    % draw negative jaw
    if negJaw(q)>ymin
        rectangle('Parent',ax, 'Position', [z, negJaw(q)-jawHeight, jawWidth, jawHeight],...
            'FaceColor', [.8 .2 0],...
            'LineStyle','none');
    else
        line('Parent',ax, 'XData', [z,z],'YData', [ymin, ymin],...
            'Marker', 'V','MarkerSize',12,...
            'Color', [.8 .2 0])    % off scale
    end
    
    % label jaw
    switch cName
        case 'CE11'
            text('Parent',ax,'Position', [z+jawWidth/2, textY],'String',cName, 'HorizontalAlignment','center')
        case 'CE21'
            text('Parent',ax,'Position', [z+jawWidth/2, textY],'String',cName, 'HorizontalAlignment','center')
        case 'C29146'
            text('Parent',ax,'Position', [z+jawWidth/2, textY+jog],'String',cName, 'HorizontalAlignment','center')
        case 'C29546'
            text('Parent',ax,'Position', [z+jawWidth/2, textY+jog],'String',cName, 'HorizontalAlignment','center')
        case 'C30146'
            text('Parent',ax,'Position', [z+jawWidth/2, textY+jog],'String',cName, 'HorizontalAlignment','center')
        case 'C30546'
            text('Parent',ax,'Position', [z+jawWidth/2, textY+jog],'String',cName, 'HorizontalAlignment','center')
        otherwise
            text('Parent',ax,'Position', [z+jawWidth/2, textY],'String',cName, 'HorizontalAlignment','center') % normal case
    end
      
end  % end of collimator loop for subplot


% Draw beam path
line('Parent',ax,'XData', bpmXplot,'YData', bpmYplot, 'LineStyle', '-.',...
    'LineWidth', 2,'Color',[0 0 1])

% Draw  acceptance
line('Parent',ax,'XData',BSCz,'YData', BSCp, 'Color',[1 .5 .5],'LineWidth',2)
line('Parent',ax,'XData',BSCz, 'YData',BSCn, 'Color',[1 .5 .5],'LineWidth',2)


function     [bpmx, bpmy, bpmz ] = bpmPlotData(beamline,bpmxPVs, bpmyPVs, bpmzPVs)
%
% return current bpm values in for specified beamline
%

bpmx = lcaGetSmart(bpmxPVs);
bpmy = lcaGetSmart(bpmyPVs);
bpmz = lcaGetSmart(bpmzPVs);

% remove bpms that have any bad reading
bad = isnan(bpmx)|isnan(bpmy)|isnan(bpmz);
bpmx(bad)=[];
bpmy(bad)=[];
bpmz(bad)=[];

% put output in order of z for plotting
[bpmz, IX] = sort(bpmz);
bpmy = bpmy(IX);
bpmx = bpmx(IX);


function cblmPlot(axc,cblmHpvs, cblmSpvs)
%
% get cblm and pblm data and plot it on the display
%


% HXR
cblmH = lcaGetSmart(cblmHpvs);
bad = isnan(cblmH);
cblmH(bad)=[];

cblmH(end) = -cblmH(end); % flip sign for PBLM at exit

x = 1:length(cblmH);
line( x,(-1)*cblmH,'Parent', axc(2), 'Linestyle','none', 'Marker','d');
ylabel('radiation','Parent',axc(2))

% SXR
cblmS = lcaGetSmart(cblmSpvs);
bad = isnan(cblmS);
cblmS(bad)=[];

cblmS(end) = -cblmS(end); % flip sign for PBLM at exit

x = 1:length(cblmS);
line( x,(-1)*cblmS,'Parent', axc(1), 'Linestyle','none', 'Marker','d');
ylabel('radiation','Parent',axc(1))


