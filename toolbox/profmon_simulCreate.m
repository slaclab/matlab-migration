function img = profmon_simulCreate(opts)
%IMGCREATE
%  IMGCREATE(OPTS) returns a beam image IMG whose properties are specified in
%  the structure OPTS.

% Input arguments:
%    OPTS: Options stucture with fields (optional):
%        DIMS: size of image, [y x]
%        SIG_BG: RMS of background noise distribution
%        BITDEPTH: bitdepth of image
%        CHARGE: charge (C)
%        QE: quantum efficiency of detection system, CCD counts/electron
%        SIGMA: beam size [x y] in m
%        POSITION: beam position [x y] in m
%        N_PART: # of particles
%        X: particle coordinates [x;y], will be calculated from sigma and position if []
%        OFF: beam off?
%        CAL: CCD calibration in m/pixel
%        ATTEN: light attenuation factor
%        CENTER: coordinate of center pixel, defaults to half of dims if []
%        METHOD: method to get distribution, SMOOTH uses function, PARTICLES uses random particles
%        NUMBER: display NUMBER in image, omitted if empty
%        SALT_PEPPER: salt & pepper noise ratio of damaged/saturated pixels

% Output arguments:
%    IMG: array with size OPTS.DIMS and numeric format given by
%         OPTS.BITDEPTH

% Compatibility: Version 7 and higher
% Called functions: hist2, parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'dims',[480 640], ... % Size of image, [y x]
    'sig_bg',4, ... % RMS of background noise distribution
    'bitdepth',8, ... % Bitdepth of image
    'charge',1e-9, ... % Charge (C)
    'qe',2e-3, ... % Quantum efficiency of detection system, CCD counts/electron
    'sigma',[0.1 0.1]*1e-3, ... % Beam size [x y] in m
    'position',[0 0], ... % Beam position [x y] in m
    'n_part',30000, ... % # of particles
    'x',[], ... % Particle coordinates [x;y], will be calculated from sigma and position if []
    'off',0, ... % Beam off?
    'cal',10e-6, ... % CCD calibration in m/pixel
    'atten',3e2, ... % Light attenuation factor
    'center',[], ... % Coordinate of center pixel, defaults to half of dims if []
    'method','smooth', ... % Method to get distribution, SMOOTH uses function, PARTICLES uses random particles
    'number',[], ... % Display NUMBER in image, omitted if empty
    'salt_pepper',1e-3 ... % Salt & pepper noise ratio of damaged/saturated pixels
    );

% Use default options if OPTS undefined.
if nargin < 1, opts=struct;end
opts=util_parseOptions(opts,optsdef);

% Add background.
img=add_bg(opts);

% Add beam
img=add_beam(img,opts);

% Add salt & pepper noise
img=add_snp(img,opts);

% Insert number
img=add_number(img,opts);

% Cast into proper type
if opts.bitdepth <= 8, img=uint8(img);
else img=uint16(img);end

% Cut off intensities beyond bitdepth
img=min(img,2^opts.bitdepth-1);


%--------------------------------------------------------------
function img = add_bg(img, opts)

if nargin < 2, opts=img;img=0;end
img=img+opts.sig_bg*randn(opts.dims)+4*opts.sig_bg;


%--------------------------------------------------------------
function img = add_beam(img, opts)

% Default beamline center on center pixel of image.
if isempty(opts.center), opts.center=fix(opts.dims([2 1])/2);end
sig=opts.sigma;
sig(1:2)=sig(1:2)./opts.cal; % Calculate beam size in pixels.
pos=opts.position./opts.cal; % Calculate beam position in pixels.
e_0=1.60217653e-19; % Coulomb
n_e=opts.charge/e_0; % # electrons
int=~opts.off*n_e*opts.qe/opts.atten;

switch opts.method
    case 'smooth'
        sig(end+1)=0;sig(3)=sig(3)/prod(opts.cal([1 end]));
        sig2i=inv([sig(1)^2 -sig(3);-sig(3) sig(2)^2]);
        int=int*sqrt(det(sig2i))/(2*pi);
        x=(1:opts.dims(2))-opts.center(1)-pos(1);
        y=(1:opts.dims(1))-opts.center(2)+pos(2);
        x2=-x.^2/2*sig2i(1);y2=-y.^2/2*sig2i(end);xy=0;
        [xx2,yy2]=meshgrid(x2,y2);
        if any(sig(3)), [xx,yy]=meshgrid(x,y);xy=-sig2i(2)*xx.*yy;end
        beam=int*exp(xx2+xy+yy2);
    case 'particles'
        if isempty(opts.x)
            x=randn(2,opts.n_part);
            opts.x=[x(1,:)*opts.sigma(1)+opts.position(1); ...
                    x(2,:)*opts.sigma(2)+opts.position(2)];
        end
        x=[ opts.x(1,:)/opts.cal(1)+opts.center(1); ...
           -opts.x(2,:)/opts.cal(end)+opts.center(end)];
        beam=int/opts.n_part*util_hist2(x(1,:),x(2,:),1:opts.dims(2),1:opts.dims(1),1);
    otherwise, beam=0;
end
img=img+beam;



%--------------------------------------------------------------
function img = add_snp(img, opts)

if ~isfield(opts,'salt_pepper'), opts.salt_pepper=1e-3;end
nsnp=fix(numel(img)*opts.salt_pepper);
img(fix(numel(img)*rand(1,nsnp)+1))=(2^opts.bitdepth-1)*rand(1,nsnp);



%--------------------------------------------------------------
function img = add_number(img, opts)
% Insert number

if isempty(opts.number), return, end

pat=[1 1 1 1 0 1 1 0 1 1 0 1 1 1 1; ...
     0 1 0 1 1 0 0 1 0 0 1 0 1 1 1; ...
     1 1 1 0 0 1 0 1 0 1 0 0 1 1 1; ...
     1 1 1 0 0 1 0 1 1 0 0 1 1 1 1; ...
     0 0 1 0 1 0 1 0 0 1 1 1 0 0 1; ...
     1 1 1 1 0 0 1 1 0 0 0 1 1 1 0; ...
     1 1 1 1 0 0 1 1 1 1 0 1 1 1 1; ...
     1 1 1 0 0 1 0 1 0 0 1 0 1 0 0; ...
     1 1 1 1 0 1 1 1 1 1 0 1 1 1 1; ...
     1 1 1 1 0 1 1 1 1 0 0 1 1 1 1; ...
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; ...
     0 0 0 0 0 0 1 1 1 0 0 0 0 0 0; ...
    ];

s=sign(opts.number) < 0;
nums=[s+10 fix(abs(opts.number)/10) mod(abs(opts.number),10)];
for k=1:length(nums)
    for j=0:size(pat,2)-1
        ind={(1:5)+size(img,1)/2+5*fix(j/3),(1:5)+5*mod(j,3)+20*k-20};
        img(ind{:})=img(ind{:})+4*opts.sig_bg*pat(nums(k)+1,j+1);
    end
end
