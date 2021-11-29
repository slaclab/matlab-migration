function [f] = zdFit(z,d)
%
%  [f] = zdFit(z,d)
%
% Take particle z-d coordinates and fit for chirp, 2nd order chirp and
% other parameters. z is particle z position relative to the center of the
% bunch. d is relative energy deviation. Returns structure f with stuff in
% it


% Set up for lscov fitting with weighting factors.
z = z;
d = d;

A = [  z.^2 z ones(numel(z), 1) ]; % second order polynomial to fit
b = d;
w = length(z); % total number of particles

% Solve for polynomial coefficients
p = lscov(A,b);

% Find slope and curvature at center of bunch
zCenter = mean(z); 
slopePoly = polyder(p); % poly for slope
centerSlope = polyval(slopePoly , zCenter);
disp(['Bunch charge weighted center at ' num2str(zCenter) ]);
disp(['Slope at center  ' num2str(centerSlope) ] );

curvaturePoly = polyder(slopePoly);
centerCurvature = polyval(curvaturePoly, zCenter);

%Find z for zero slope. Choose root that is closest to center
zZeroSlope = roots(slopePoly);
root2Center = abs( (zZeroSlope - zCenter) );
zZeroSlope = zZeroSlope(root2Center == min(root2Center));
disp(['Zero slope at ' num2str(zZeroSlope)] );

% Find bunch rms bunch length
sigmaZ  = std(z);
disp(['RMS z =  ' num2str(sigmaZ)]);

% Find bunch rms energy spread 
dCenter = mean(d); 
sigmaD  = std(d); 
disp(['RMS delta =  ' num2str(sigmaD)]);


% find slice energy spread
[zSlice, dSlice] =  zdSlice(z,d, 0.1);
[Y, dSliceOut] = hist(dSlice,15);
par = gaussCalc( dSliceOut, Y ) ;
sigmaDslice = par(3);


% Pack the output structure
f.p = p;
f.zCenter = zCenter;
f.chirp = centerSlope;
f.dChirpDz = centerCurvature;
f.zZeroSlope = zZeroSlope;
f.sigmaZ = sigmaZ;
f.sigmaD = sigmaD;
f.sigmaDslice = sigmaDslice;




