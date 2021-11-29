function [x, xp, y, yp, z, d] = image2particles(data, varargin)
%
% [x, xp, y, yp, z, d] = image2particles(data, varargin)
%
% Takes a beam image data stored in structure 'data' by the
% profile monitor gui, (typically streaked at an OTR screen), and returns
% particle phase space coordinates that would generate that image.
%
% varargin are optional name,value pairs. e.g. 'beta', 10, 'emittance',
% 0.4e-6... SI units are assumed. Valid arguments are
%     'number'
%     'energy' 
%     'betaX'
%     'etaX'
%     'alphaX'
%     'betaY'
%     'alphaY'
%     'etaY'
%     'emittance'
%     'energySpread_keV'
%     'sigmaZ'
%     'noiseRMS', number of sigma for noise floor cut
%     'res'
%     'TCAVlambda'
%     'MeV'
%     'TCAVcal'
%     'XTCAVcal'
%     'crop'

optsdef = struct(...
    'screenName', data.name);
opts = util_parseOptions(varargin{:}, optsdef); %supplied arguments overwrite defaults.

% Defaults from online model or otherwise
[RMAT, ZPOS, LEFF, TWISS, ENERGY] = model_rMatGet(opts.screenName);% Twiss parameters are [En (mu b a D Dp)_x (mu b a D Dp)_y]
energyDefault = TWISS(1); % use model for defaults
betaXdefault = TWISS(3);
alphaXdefault = TWISS(4);
etaXdefault = TWISS(5);
betaYdefault = TWISS(8);
alphaYdefault = TWISS(9);
etaYdefault = TWISS(10);

if ~strcmp(data.name, 'WIRE:DMP1:696')
    resDefault = data.res;
else
    resDefault = 1;
end

if strcmp(data.name, 'YAGS:IN20:995')
    TCAVlambda = 0.1049693;  % S band
    TCAVcalxz = lcaGet( 'OTRS:IN20:571:TCAL_Y') ;
else
    TCAVcalxz = -0.568;% from 12/18/14
end
TCAVcal = TCAVcalxz * 1e6 * TCAVlambda/360; % convert from um in screen x to um in particle z per degree of S band.

optsdef = struct(...
    'number', 2e4,...
    'energy', energyDefault,...
    'betaX', betaXdefault,...
    'etaX', etaXdefault,...
    'alphaX', alphaXdefault,...
    'betaY',betaYdefault,...
    'alphaY', alphaYdefault,...
    'etaY', etaYdefault,...
    'emittance', 0.3e-6,...
    'energySpread_keV', 25,... % keV
    'sigmaZ', .0005,... % m
    'noiseRMS', 6,...
    'res', resDefault,... % um/pixel
    'TCAVlambda', .1049693,... % S band
    'MeV', 135,... % beam energy in MeV
    'TCAVcal', TCAVcal,... % um/deg -374.31
    'XTCAVcal',(40*1000*0.78)/energyDefault,... % originally 2637 um/deg at 40 MV 13.69 GeV, change per Y. Ding 3/6/14 to scale with energy
    'crop', 0); % don't crop

opts = util_parseOptions(varargin{:}, optsdef); %supplied arguments overwrite defaults.

if strcmp(data.name,'WIRE:DMP1:696')
    % OTRDMP Wirescanner - use energy projection from scan and simulate other coordinates

    % Get data
    w = data.beam(2).profy(2,:);        % projected counts is weighting factor
    pos_um = data.beam(2).profy(1,:);   % corrected wire positions

    % Get uniformly spaced points to avoid pile-up in d
    xi = pos_um(1):(( pos_um(end) - pos_um(1))/(numel(pos_um)-1)): pos_um(end);
    wi = interp1(pos_um, w, xi); 
    dPos_um = xi(2)-xi(1);
    
    
    % Create d coordinates (un-scaled)
    area = trapz( pos_um, w);  % total area of w-pos curve
    ppa = opts.number/area; % particles per w-pos area
    dParticle = zeros(opts.number,1);% pre-allocate
    n = 1; % particle index
    for q=2:numel(xi) % loop over projected pixels
        areaQ = 0.5*(wi(q) + wi(q-1))* dPos_um; %  
        for pp = 1:round( ppa * areaQ );
            dParticle(n) = xi(q) + dPos_um * 0.5 * (rand -0.5);% rand to smear bin edges
            n = n+1;
        end
    end

    % Clean up z,d array
    opts.number = numel(dParticle);% number changes due to roundoffs
    [z, junk] = zGen(opts); % generate z's
    [z, d] = particleCleaner(z,dParticle);
    opts.number = numel(d);
   
    % Center and scale d
    d = opts.etaY * d * 1e-6;
    d = d - mean(d);

    % Generate remaining coordinates
    [x, xp] = xGen(opts);
    [y, yp] = yGen(opts);

else
    % TCAV screens
    
    % Might need cropping
    if opts.crop
       data.img =  crop2(data.img);
    end

    % Don't make readout noise and hot pixels into particles
    pic = imageCleaner(data.img, opts.noiseRMS);

    % Set up un-scaled particle arrays, one entry per pixel
    [nrows, ncols] = size(pic);
    w = reshape(pic,numel(pic),1); % w, weighting factor, is pixel counts
    r = 1:nrows;% row index
    r = r';
    r = repmat(r,ncols,1); % one z for each pixel

    c =[]; % column index
    for q = 1:ncols
        cc(1:nrows) = q;
        c = [c cc]; % one d for each pixel
    end

    % Make unscaled particles
    ppp = floor(opts.number*w/sum(w));% particles per pixel
    zParticle = zeros(opts.number,1); % pre-allocate
    dParticle = zeros(opts.number,1);
    n = 1; % particle index
    for q=1:numel(w) % sum over all pixels
        if strcmp(data.name, 'OTRS:DMP1:695')  % XTCAV
            for pp = 1:ppp(q)
                zParticle(n) = c(q);
                dParticle(n) = r(q);
                n = n+1;
            end
        else
            for pp = 1:ppp(q)
                zParticle(n) = r(q);
                dParticle(n) = c(q);
                n = n+1;
            end
        end
    end
    
    % Clean up
     [zParticle, dParticle] = particleCleaner(zParticle,dParticle);
     
    % Scatter particles to avoid artifical bin edges
    [zParticle,dParticle] = particleScatter(zParticle,dParticle);

    % Center and scale the coordinates to real SI units
    if opts.TCAVcal % if streaked image (TCAVcal ~ 0);
        pix2z = (opts.res / opts.TCAVcal) * opts.TCAVlambda/360; % convert streaked pixels to z-m. For LiTrack want minus sign.
        if strcmp(data.name, 'OTRS:DMP1:695') % If XTCAV
            pix2d = -opts.res * 1e-6 / opts.etaY; % convert dispersed pixels to d (fraction)
            pix2z = ( opts.res / opts.XTCAVcal ) * opts.TCAVlambda/360/3;
        else
            pix2d = opts.res * 1e-6 / opts.etaX; % convert dispersed pixels to d (fraction)
        end
        z = pix2z * (zParticle - mean(zParticle) );
        d = pix2d * (dParticle - mean(dParticle) );
        [x, xp] = xGen(opts);
        [y, yp] = yGen(opts);
    else % ordinary x,y image
        [z,d] = zGen(opts);
        [x, xp] = xGen(opts);
        [y, yp] = yGen(opts);
    end


end

function [x, xp] = xGen(opts)
% generate random particle coordinates with correct beta function and emittances
sigmaX = sqrt(opts.betaX *opts.emittance);
x =  sigmaX * randn(opts.number,1); 
xp = (opts.emittance/sigmaX) * randn(opts.number, 1); % need to use alpha

function [y, yp] = yGen(opts)
% generate random y particles with correct twiss function and emittance
% ey = -2 * opts.emittance * log( rand(opts.number,1) ); % y particle "emittance" derived from S Lee, Accelerator Physics page 57
% phase = 2*pi*rand(opts.number,1); % uniformly distributed random particle phase angle.
% y = sqrt(opts.betaY * ey / pi) .* cos( phase );
% yp = sqrt( ey /(pi * opts.betaY) ) .* (-opts.alphaY* cos(phase) + sin(phase) );
% % seems like a factor of pi is wrong somewhere
sigmaY = sqrt(opts.betaY *opts.emittance);
y =  sigmaY * randn(opts.number,1); 
yp = (opts.emittance/sigmaY) * randn(opts.number, 1); % need to use alpha

function [z, d] = zGen(opts)
% generate z and d coordinates from default parameters (no chirp)

d = (opts.energySpread_keV*.001/opts.MeV) * randn(opts.number,1);
z = opts.sigmaZ * randn(opts.number,1);

function [z, d] = particleCleaner(z,d)
% Clean up particle arrays;
bad = z == 0 | d == 0;
z(bad)=[];
d(bad)=[];

function [z,d] = particleScatter(z,d)
% Scatter all particles by +/- half a pixel width
z = z+rand(size(z))-.5; 
d = d + rand(size(d))-.5;


