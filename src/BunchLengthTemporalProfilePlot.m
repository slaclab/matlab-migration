function BunchLengthTemporalProfilePlot(fig)

% y = 1E3*randn(10000,1);     % random particles (not important)
% [N,Y] = hist(y,100);        % screen 1D profile after summing over horizontal pixels
% 
% % The above simply mimicks a screen profile after summing over the horizontal pixels
% screen_calibration = 0.302; % this is your pre-determined screen calibration (mm/deg)
% 
% % Now show my 1D profile example graphically, before conversion to Amperes and psec...
% subplot(211)
% stairs(Y,N,'b-')
% xlabel('Vertical Screen Coordinate (microns)')
% ylabel('Screen Intensity (arb)')
% title('Example Screen Vertical Profile')
% 
% TMIT = 2E9;                             % Read a nearby BPM TMIT (average at least 5 shots)
% light_speed = 2.99792458E8;             % speed of light (m/s)
% fRF = 2856E6;                           % SLAC's RF frequency (Hz)
% 
% dphi = 1E-3*mean(diff(Y))/screen_calibration;   % find the screen's Y-pixel size in degrees
% dt   = dphi/360/fRF;                            % convert pixel size from degrees to seconds
% 
% I   = 1.602E-19*TMIT*N/sum(N)/dt;       % convert screen profile height (arb) into Amperes
% phi = 1E-3*Y/screen_calibration;        % convert screen vertical position (mm) into degrees
% t   = 1E12*phi/360/fRF;                 % convert degrees to pico-seconds (ps)
% 
% subplot(212)
% stairs(t,I,'r-')
% xlabel('time (ps)')
% ylabel('Current (A)')
% title('Example Temporal Profile')

global gBunchLength;

if ~isfield(gBunchLength.meas.results,'profy')
    gBunchLength.meas.results.profy = gBunchLength.meas.results.beamlist(1).profy(2,:);
    gBunchLength.meas.results.profIndex = 1;
end

N = gBunchLength.meas.results.profy;

Y = (1:length(N))*(gBunchLength.meas.camera.img.resolution); % convert pixel to um

screen_calibration = gBunchLength.screen.blen_phase.value{1};

TMIT = gBunchLength.blen.nel.value{1};
light_speed = 2.99792458E8;
fRF = 2856E6;

dphi = 1E-3*mean(diff(Y))/screen_calibration;
dt = dphi/360/fRF;

I = 1.602E-19*TMIT*N/sum(N)/dt;
phi = 1E-3*Y/screen_calibration;
t = 1E12*phi/360/fRF;

a = -sort(-I);

gBunchLength.meas.results.FWHM = FWHM(t,I);

stairs(t,I,'r-','parent',fig);
xlabel('time (ps)','parent',fig);
ylabel('Current (A)','parent',fig);
tString = cell(0);
tString{end+1} = sprintf('Temporal Profile  %.1f %s  %s', ...
    gBunchLength.meas.results.pact(gBunchLength.meas.results.profIndex), ...
    char(gBunchLength.tcav.pact.egu{1}),...
    char(gBunchLength.blen.meas_ts.value));
tString{end+1} = sprintf('Bunch Length FWHM=%.3f ps %.5f\\pm%.5f %s \\sigma=%.3f ps Q=%.3f nC I_{pk}=%.3f A', ...
    gBunchLength.meas.results.FWHM,...
    gBunchLength.blen.mm.value{1}, gBunchLength.blen.mm.std{1}, char(gBunchLength.blen.mm.egu{1}),...
    gBunchLength.meas.results.sigt * 1/2856e6*1e12/360,...
    gBunchLength.meas.results.tmit.each(gBunchLength.meas.results.profIndex) * 1.602e-10,...
    mean(a(1:10)));
title(tString,'parent',fig,'FontSize',12);
axis (fig,'tight');
