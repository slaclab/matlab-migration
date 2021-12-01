function [twiss, sigma, energy, phase] = model_twissGet(name, rOpts, varargin)
%MODEL_TWISSGET
% [TWISS, SIGMA, ENERGY, PHASE] = MODEL_TWISSGET(NAME, ROPTS, OPTS) returns
% Twiss parameters TWISS, SIGMA matrix elements, ENERGY and PHASE for beam line
% elements in NAME.  Options for model_rMatGet can be specified in ROPTS,
% and further options in OPTS.

% Features: Localized for LCLS/FACET/NLCTA/XTA/ASTA

% Input arguments:
%    NAME:  List of names to retrieve values
%    ROPTS: Options for model_rMatGet
%    OPTS:  options struct
%           RMAT:    Transport matrix to use for Twiss calculation
%           EN:      Beam energy 
%           REG:     Region number
%           DOPHASE: Calculate phase advance
%           DESIGN:  Unused
%           INIT:    Unused

% Output arguments:
%    TWISS:  List of Twiss parameters [3 x 2 x N]
%    SIGMA:  List of sigma matrix elements [3 x 2 x N] 
%    ENERGY: List of energy values
%    PHASE:  List of phase advances [2 x N]

% Compatibility: Version 2007b, 2012a
% Called functions: model_init, util_parseOptions, model_rMatGet,
%                   model_rMatModel, model_twissPhase, model_twissTrans,
%                   model_twiss2Sigma

% Author: Henrik Loos, SLAC

% History:
%   21-Sep-2021, M. Woodley (15SEP21)
%    * update initial design Twiss for OTR2 (in copper linac)
%   05-Jun-2019, M. Woodley (OPTICS=AD_ACCEL-06JUN19)
%    * use AD_ACCEL and FACET2 defined beam paths; update initial Twiss;
%      add more points-of-interest
%   10-May-2017, M. Woodley (OPTICS=LCLS05JUN17)
%    * update initial design Twiss for A-Line (twiss0(:,:,9))

% --------------------------------------------------------------------

[modelSource,modelOnline]=model_init;

% Set default options.
optsdef=struct( ...
    'rMat',[], ...
    'en',[], ...
    'reg',[], ...
    'doPhase',0, ...
    'design',0, ...
    'init',0 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

if nargin < 2, rOpts={};end

name=cellstr(name);
nList=numel(name);
twiss=ones(3,2,nList);
phase=zeros(2,nList);
rOpts=cellstr(rOpts);

% Determine if DESIGN.
if ~isempty(rOpts)
    isType=find(strncmpi(rOpts(1,:),'TYPE=',5),1,'last');
    if ~isempty(isType) && strcmpi(rOpts{isType}(6:end),'DESIGN')
        opts.design=1;
    end
end

if modelOnline && ~ismember(modelSource,{'MATLAB'})
    t=model_rMatGet(name,[],rOpts,'twiss');
    energy=t(1,:);
    twiss(2:3,:,:)=reshape(t([3 4 8 9],:),2,2,[]);
    twiss(1,:,:)=1e-6;
    phase=t([2 7],:);
else
    if isempty(opts.rMat)
        [opts.rMat,d,d,opts.en,opts.reg]=model_rMatModel(name,[],rOpts);
%        [opts.rMat,opts.en]=model_rMatGet(name,[],rOpts,{'R' 'EN'});
    end

%   Initial Twiss parameter definitions: [emitnx emitny;betax betay;alphax alphay]

%   LCLS2cu: CATHODE
    twiss0(:,:,1)=[1e-6 1e-6;1.557422202e+1 3.909300395e-1;-3.081460533 5.514324137e-3];
   %twiss0(:,:,1)=[1e-6 1e-6;15.574 0.391;-3.081 0.0055];       % BEGGUN
   %twiss0(:,:,1)=[1e-6 1e-6;15.5274 0.3918;-3.0745 0.0074];    % BEGGUN to match OTR2
   %twiss0(:,:,1)=[1e-6 1e-6;1.113 1.113;-0.069 -0.070];        % OTR2

%   LCLS2cu: ENDDL1_2/BEGL1
    twiss0(:,:,2)=[1e-6 1e-6;9.947 2.411;1.960 -0.549];

%   LCLS2cu: ENDL2/BEGBC2
    twiss0(:,:,3)=[1e-6 1e-6;49.920 26.946;-0.379 -1.347];      % BC2

%   LCLS2cu: ENDL3/BEGCLTH_0
    twiss0(:,:,4)=[1e-6 1e-6;3.322327165e1 6.217903496e1;1.179788572e0 -1.656755987e0]; % 05DEC19
   %twiss0(:,:,4)=[1e-6 1e-6;3.313663136e+1 6.229852658e+1;1.179540230e0 -1.660316778e0];
   %twiss0(:,:,4)=[1e-6 1e-6;118.8491 103.0493;2.0570 -3.8641]; % at BSY entrance ?, new design
   %twiss0(:,:,4)=[1e-6 1e-6;32.029 67.490;0.782 -1.485];       % at BSY entrance ?, old design
   %twiss0(:,:,4)=[1e-6 1e-6;50.484 72.941;1.808 -9.155];       % at LTU entrance
   %twiss0(:,:,4)=[1e-6 1e-6;48.864 97.026;3.136 3.636];        % at Und entrance ?

%   LCLS2cu: ENDBC1/BEGL2
    twiss0(:,:,5)=[1e-6 1e-6;6.630277953e0 2.748675456e1;-9.211855748e-1 1.455482343e0]; % 05DEC19
   %twiss0(:,:,5)=[1e-6 1e-6;6.603851991e0 2.751062780e1;-9.176284642e-1 1.550010487e0];
   %twiss0(:,:,5)=[1e-6 1e-6;6.604 27.511;-0.918 1.550];        % at L2 entrance

%   LCLS2cu: ENDBC2/BEGL3
    twiss0(:,:,6)=[1e-6 1e-6;1.106355610e1 7.064579711e1;-9.496870694e-1 2.189962743e0]; % 05DEC19
   %twiss0(:,:,6)=[1e-6 1e-6;1.106000606e+1 7.102874374e+1;-9.490174761e-1 2.204515335e0];
   %twiss0(:,:,6)=[1e-6 1e-6;11.060 71.028;-0.949 2.204];       % at L3 entrance

%   LCLS2cu: L0AWAKE/L0BBEG
    twiss0(:,:,7)=[1e-6 1e-6;1.407639612e0 6.689606508e0;-2.606598963e0 5.031721174e-1];
   %twiss0(:,:,7)=[1e-6 1e-6; 1.408  6.690;-2.607  0.503];      % at end of L0a

%   LCLS2cu: XEND
    twiss0(:,:,8)=[1e-6 1e-6;1.135910119e+1 9.018535368e0;-3.258071182e-1 -1.661480153e0];
   %twiss0(:,:,8)=[1e-6 1e-6;11.359  9.019;-0.326 -1.661];      % BC1 after L1X

%   LCLS2cu: ENDBSYH_1/BEGBSYA_1
    twiss0(:,:,9)=[1e-6 1e-6;3.978445099e1 1.316015349e2; 2.646931196e0 2.597298530e0]; % 05DEC19
   %twiss0(:,:,9)=[1e-6 1e-6;3.870398823e+1 1.282668830e+2;2.616263925e0 2.545414993e0];
   %twiss0(:,:,9)=[1e-6 1e-6;38.47839726 135.0738675;2.750561156 2.617341185]; % at BEGBSYA for A-Line
   %twiss0(:,:,9)=[1e-6 1e-6;36.578 41.455; 0.181  1.063];      % at 50B1 for A-Line

%   LCLS2sc: CATHODEB (15SEP21)
    twiss0(:,:,10)=[0.5e-6 0.5e-6;24.132987592581 24.1032534071;12.721498354446 12.70542401701];

%   FACET2e: CATHODEF
    twiss0(:,:,11)=[5e-5 5e-6;1.191686714e+1 3.135655867e0;7.509605372e0 -7.047857400e0];
   %twiss0(:,:,11)=[1e-6 1e-6;13.079 35.884;-0.655 1.676]; % FACET MAD deck begin of LI19
   %twiss0(:,:,11)=[1e-6 1e-6;44.610 164.715;-3.794 7.567]; % New FACET MAD deck begin of LI19

%   FACET2e: ENDINJ/BEGDL10
    twiss0(:,:,12)=[1e-6 1e-6;2.366141221e-1 1.669277143e+1;-1.250649316e0 -9.828485585e0];
   %twiss0(:,:,12)=[1e-6 1e-6;44.610 164.715;-3.794 7.567]; % New FACET MAD deck begin of LI19
   %twiss0(:,:,12)=[3e-5 3e-6; 2.454647050475664  0.908549232817723;1.960786053547579 -0.776483164093736]; % FACET MAD deck begin of NRTL
   %twiss0(:,:,12)=[3e-5 3e-6; 16.724895197513966   5.047539593804909;-0.541090919719563   1.420055027375245]; % FACET MAD deck begin of NRTL

%   XTA
    twiss0(:,:,13)=[1e-6 1e-6;5.5083 5.5075;-0.46966 -0.4688]; % XTA MAD deck begin after X-band

%   ASTA
    twiss0(:,:,14)=[1e-6 1e-6;5.5083 5.5075;-0.46966 -0.4688]; % ASTA MAD deck begin at Gun

%   LCLS2sc: BEAM0
    twiss0(:,:,15)=[0.5e-6 0.5e-6;9.348000000e0 9.342900000e0;-1.694600000e0 -1.692500000e0];
   %twiss0(:,:,15)=[1e-6 1e-6;3.949042136246e2 3.94640860598e2;1.525610502992e2 1.524592881855e2]; % LCLS2sc (06SEP17) at CATHODEB
   %twiss0(:,:,15)=[1e-6 1e-6;3.949042135543708e2 3.946408604294281e2;1.525610502752233e2 1.524592881236914e2]; % LCLS2sc (06SEP17) at CATHODEB, fudged
   %twiss0(:,:,15)=[1e-6 1e-6;4.500212754115e2 4.494532065919e2;1.737147744274e2 1.734952004794e2]; % LCLS2sc (14FEB18) at CATHODEB

%   LCLS2sc: YAG01B
    twiss0(:,:,16)=[0.5e-6 0.5e-6;5.676603281e0 5.669305161e0;7.973510222e0 7.963417994e0];

%   LCLS2sc: OTRDG02
    twiss0(:,:,17)=[0.5e-6 0.5e-6;0.57735026919 0.57735026919;0 0];

%   LCLS2sc: WS0H04
    twiss0(:,:,18)=[0.5e-6 0.5e-6;5.0 5.0;0 0];

%   NLCTA: MAD deck begin at gun, made up numbers
    twiss0(:,:,19)=[1e-6 1e-6;10 10;0 0];

%   LCLS2sc: WSC104
    twiss0(:,:,20)=[0.5e-6 0.5e-6;1.003427589e1 1.120295061e1;9.601858071e-1 -9.533140746e-1];

%   LCLS2sc: WSEMIT2
    twiss0(:,:,21)=[0.5e-6 0.5e-6;5.933102324e0 5.912476852e0;0 0];

%   LCLS2cu: OTR2 (15SEP21)
    twiss0(:,:,22)=[1e-6 1e-6;1.11308102615 1.113021659127;-0.068940358788 -0.070294897537];

    phase0=zeros(2,size(twiss0,3));  % Default to 0 phase advance
%   LCLS2cu phases are w.r.t. CATHODE
%   LCLS2sc phases are w.r.t. CATHODEB (MAD coupled Twiss calc)
%   FACET2e phases are w.r.t. CATHODEF
    phase0(:, 1)=[0.000;0.000]*2*pi; % LCLS2cu: CATHODE
    phase0(:, 2)=[1.775;1.237]*2*pi; % LCLS2cu: ENDDL1_2/BEGL1
    phase0(:, 3)=[5.173;4.870]*2*pi; % LCLS2cu: ENDL2/BEGBC2
    phase0(:, 4)=[7.620;7.308]*2*pi; % LCLS2cu: ENDL3/BEGCLTH_0
    phase0(:, 5)=[2.750;2.428]*2*pi; % LCLS2cu: ENDBC1/BEGL2
    phase0(:, 6)=[5.518;5.254]*2*pi; % LCLS2cu: ENDBC2/BEGL3
    phase0(:, 7)=[0.444;0.274]*2*pi; % LCLS2cu: L0AWAKE/L0BBEG
    phase0(:, 8)=[2.041;1.613]*2*pi; % LCLS2cu: XEND
    phase0(:, 9)=[7.899;7.569]*2*pi; % LCLS2cu: ENDBSYH_1/BEGBSYA_1
    phase0(:,10)=[0.000;0.000]*2*pi; % LCLS2sc: CATHODEB
    phase0(:,11)=[0.000;0.000]*2*pi; % FACET2e: CATHODEF
    phase0(:,12)=[0.876;0.497]*2*pi; % FACET2e: ENDINJ/BEGDL10
    phase0(:,13)=[0.000;0.000]*2*pi; % XTA begin after X-band
    phase0(:,14)=[0.000;0.000]*2*pi; % ASTA begin at gun
    phase0(:,15)=[0.9329;0.9328]*2*pi; % LCLS2sc: BEAM0
    phase0(:,16)=[0.0135;0.0135]*2*pi; % LCLS2sc: YAG01B
    phase0(:,17)=[2.7744;3.2447]*2*pi; % LCLS2sc: OTRDG02
    phase0(:,18)=[1.0484;1.6965]*2*pi; % LCLS2sc: WS0H04
    phase0(:,19)=[0.000;0.000]*2*pi; % XTA begin at gun
    phase0(:,20)=[2.9282;4.0839]*2*pi; % LCLS2sc: WSC104
    phase0(:,21)=[4.5326;5.9125]*2*pi; % LCLS2sc: WSEMIT2
    phase0(:,22)=[0.7647;0.9398]*2*pi; % LCLS2cu: OTR2
%    en0(:,1)=model_energy({'YAG01' 'BPM15' 'OTR21' 'OTR33' 'OTR21' 'OTR33' 'YAG03' 'OTR12' 'OTR33'},rOpts);

    if ~opts.design
%        twiss0(:,:,1)=[1e-6 1e-6;62.404 35.417;-1.248 0.672]; % At WS28144
%        twiss0(:,:,1)=eye(3,4)*control_emitGet('WS28144');
    end

%    [energy,reg]=model_energy(name,rOpts);
    energy=opts.en;reg=opts.reg;
    for j=1:size(twiss0,3)
        twiss(:,:,reg == j)=repmat(twiss0(:,:,j),[1 1 sum(reg == j)]);
        phase(:,reg == j)=repmat(phase0(:,j),[1 sum(reg == j)]);
%        energy0(reg == j)=en0(:,j); % BC1 energy in GeV
    end

    if opts.doPhase, phase=phase+model_twissPhase(twiss,opts.rMat);end
    twiss=model_twissTrans(twiss,opts.rMat);

%    blen=lcaGet('SIOC:SYS0:ML00:AO878');
%    sigma0=model_twiss2Sigma(twiss,repmat(energy0(:)',2,1));
%    for j=1:nList
%        sig=eye(6);sig([1 2 7 8 15 16 21 22 29 36])=[reshape(sigma0([1 2 2 3],:,j),1,[]) blen 0];
%        sig=rMat(:,:,j)*sig*rMat(:,:,j)';
%        sigma(:,:,j)=reshape(sig([1 7 8 15 21 22]),3,2);
%    end
%    twiss=model_sigma2Twiss(sigma,[],repmat(energy(:)',2,1));
end

sigma=model_twiss2Sigma(twiss,repmat(energy(:)',2,1));
