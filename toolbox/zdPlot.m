function zdPlot(z,d,pC)
%
% zdPlot(z,d,pC)
%
% Takes vectors of particle phase space coordinates ([m], []) and makes
% plots and projections. Charge in pC is optional and is used to provide a
% current scale. (default 150 pC)
% 
%

if nargin == 2
    pC = 150;
end

nParticles = numel(z);
nElectrons = pC*1e-12/1.6e-19;
particleCharge = pC*1e-12/numel(z); %[C]
cLight = 2.998e8;

% Set up figure
figurePosition = [20,10,120, 45];
hf = figure('name','zdPlot','units','characters','color','w','position',figurePosition); % default, fixed figure number (Jim Welch's extension!) to keep from overwriting other plots
%set(gcf,'color','w','name','zdPlot output');
%set(hf,'units','normalized');

% correlation plot with overlayed fit
hdz = subplot(2,2,2); 

% Plot z-d correlation
plot(z,d,'.','MarkerSize',1)
zRange = xlim;
dRange = ylim;


% Overlay fit
hold
f = zdFit(z,d); % Fit the data
[zSort, index] = sort(z);
dFit = polyval(f.p, zSort) ;
plot(zSort,dFit,'k-.','LineWidth',2);
xlim( [-3*f.sigmaZ  3*f.sigmaZ] );
ylim( [-5*f.sigmaD  5*f.sigmaD] );
zRange = xlim;
dRange = ylim;

% Add text
txy = [( zRange(2)-zRange(1) )* 0.05 + zRange(1),...
    0.95*( dRange(2)-dRange(1) ) + dRange(1) ];  % Add text to figure
dtxy = -1*[0, 0.068*(max(dRange) - min(dRange))]; % text step size
text(txy(1), txy(2), ['Slope at bunch center [m^{-1}]     ' num2str(f.chirp)]);
txy = txy + dtxy;
text(txy(1),txy(2), ['2nd derivative at bunch center [ m^{-2}]   ' num2str(f.dChirpDz)]);
txy = txy + dtxy;
text(txy(1),txy(2), ['Zero slope point [m] ' num2str(f.zZeroSlope)]); 
txy = txy + dtxy;
text(txy(1),txy(2), ['\sigma_Z  [m] ' num2str(f.sigmaZ)]);
txy = txy + dtxy;
text(txy(1),txy(2), ['\sigma_{\delta} ' num2str(f.sigmaD)]);
hold off

% Charge distribution plot
hc = subplot(2,2,4);
zbins = -3*f.sigmaZ:f.sigmaZ/10 :3*f.sigmaZ; % Integrate over d using hist
[n, zout] = hist(z, zbins); 
zStep = (max(zout)-min(zout) )/200;
zPoints = min(zout):zStep:max(zout); % for plotting
nInterp = interp1(zout, n, zPoints,'spline'); % interpolate for smoother plots
chargeDensity = particleCharge * nInterp / (zout(end) - zout(end -1) );
current = chargeDensity * cLight; %[A]
plot(zPoints,current*0.001);
xlim(zRange);
ylim([0, 1.1e-3*max(current)]);
ylabel('Current [kA]')
fwhmZ = fwhmGeneral(zPoints, 1e-3*current);
title([ 'I_{pk}= ' num2str(1e-3*max(current),3) ' [kA],    ', 'FWHM = ' num2str(fwhmZ,3) ' [m]' ])
xlabel('z-position from bunch center [m]')

% Energy distribution plot
he = subplot(2,2,1);
dbins = -4*f.sigmaD:f.sigmaD/10 :4*f.sigmaD; % Integrate over z using hist
[n, dout] = hist(d, dbins); 
dStep = (max(dout)-min(dout))/200;
dPoints = min(dout):dStep:max(dout); % for plotting
nInterp = interp1(dout, n, dPoints,'spline'); % interpolate for smoother plots
deltaDensity =  nInterp;% particles per bin
plot(deltaDensity,dPoints); % plot sideways
fwhmD = fwhmGeneral( dPoints,deltaDensity);
xlim( [0,1.1*max(deltaDensity)] );
ylim(dRange);
title(['FWHM= ' num2str(fwhmD,3) ', \sigma_{\delta SLICE}= ', num2str(f.sigmaDslice,3)]);
xlabel('particles per bin')
ylabel('delta []')
% Adjust sizes of subplots [left bottom width height]
set(hdz, 'Position',[.4 .45 .5 .45])
set(he, 'Position',[.1 .45 .2 .45])
set(hc, 'Position',[.4 .1 .5 .15])


