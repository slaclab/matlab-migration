function profmon_setup(varargin)
%PROFMON_SETUP
% PROFMON_SETUP() initializes all profile monitors with their orientation,
% calibration, and trigger settings.
%
% Input arguments:
%    OPTS: options struct
%          WIDTH: triggger pulse width (us), default 1000
%          DELAY: trigger delay (us), default 500
%          EVENTCODE: event code for trigger, default 43
%
% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: util_parseOptions, getSystem, lcaPut
% --------------------------------------------------------------------
% Author: Henrik Loos, Greg White SLAC
% Mod:    4-Apr-2017, Sonya Hoobler
%           Permanently removed PR45 (PROF:BSY0:45) and PR55 (PROF:BSY0:55)
%            (before was just commented out).
%           Removed EVR:BSY0:PM01. Left EVR:BSY0:PM02 in place for A-line
%         8-Sep-2016. Greg White
%         Removed PR45 (PROF:BSY0:45) and PR55 (PROF:BSY0:55) in
%         preparation of BSY for LCLS2
% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'width',1000, ... % us
    'delay',500, ... % us
    'eventCode',159);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Set profile monitor properties.
propsDef={'X_ORIENT' 'Y_ORIENT' 'X_RTCL_CTR' 'Y_RTCL_CTR' 'RESOLUTION'};
pvProps={ ...
    'YAGS:IN20:211'  1 1 720 529 17.79; ...
    'YAGS:IN20:841'  0 1 731 508 37.74; ...
    'YAGS:IN20:241'  1 1 748 519 17.92; ...
    'YAGS:IN20:351'  1 1 675 559 17.82; ...
%    'YAGS:IN20:465'  1 1 670 514 17.56; ... % YAG04
    'CTHD:IN20:206'  1 0 700 500 27.09; ...
    'OTRS:IN20:465'  1 1 709 537 18.74; ... % OTRH1
    'OTRS:IN20:471'  1 1 728 525 19.06; ... % OTRH2
    'OTRS:IN20:541'  1 1 724 228 11.90; ...
    'OTRS:IN20:571'  1 1 384 528 12.23; ...
    'OTRS:IN20:621'  1 1 717 513 12.12; ...
    'OTRS:IN20:711'  1 1 324 178 16.89; ...
    'YAGS:IN20:921'  1 1 696 512 17.66; ...
    'YAGS:IN20:995'  1 1 703 489 17.72; ...
%    'OTRS:IN20:997'  0 0 776 602  7.41; ... % OTRS1
    'OTRS:LI21:237'  1 1 705 520 18.15; ...
    'OTRS:LI21:291'  1 1 724 195 10.93; ...
    'OTRS:LI24:807'  1 1 734 536 17.09; ...
    'OTRS:LI25:342'  1 1 704 499 11.01; ...
%    'OTRS:LI25:920'  1 1 669 535 11.60; ... % OTR_TCAV inactive
%    'LOLA:LI30:555'  0 0 730 442 10.45; ... % Now PR55
    'PROF:BSYA:1800' 1 1 893 545 82.09; ...
    'OTRS:LTUH:449'  0 0 777 521  7.37; ...
    'YAGS:LTUH:743'  0 1 375 414 26.32; ... % YAGPSI
    'OTRS:DMPH:695'  1 1 518 508 35.09; ... % OTRDMP
%
};

[sys,accel]=getSystem;
if any(strcmp(accel,'FACET'))
    pvProps={}; % FACET initialization disabled
%{
    pvProps={ ...
        'YAGS:LI20:2432' 1 1 722  625   9.62; ... % SYAG
        'OTRS:LI20:3070' 1 1 700  500  18.80; ... % USTHz
        'OTRS:LI20:3075' 1 0 700  500   4.63; ... % DSTHz
        'OTRS:LI20:3158' 1 0 700  500   5.80; ... % USOTR
        'OTRS:LI20:3175' 1 0 700  500  17.00; ... % EOS
        'OTRS:LI20:3180' 1 0 700  500  13.30; ... % IPOTR1
        'EXPT:LI20:3208' 1 1 700  500   8.96; ... % IPOTR2
        'OTRS:LI20:3206' 0 0 700  500 11.845; ... % IP2A
        'OTRS:LI20:3208' 0 0 931  404   3.00; ... % KRAKENOTR
        'MIRR:LI20:3202' 1 0 700  500  10.42; ... % unused
        'MIRR:LI20:3230' 1 0 700  500   7.55; ... % old IP2B for uniq now unused
        'PROF:LI20:B104' 1 0 700  500   7.06; ... % new IP2B for gigE
        'PROF:LI20:3483' 1 1 700  500  22.79; ... % CHER_ELOSS, camera rotated, X/Y flipped
        'PROF:LI20:3484' 0 1 700  500  22.79; ... % CHER_NEAR, camera rotated, X/Y flipped
        'PROF:LI20:3485' 0 0 700  500  10.39; ... % CHER_EGAIN, camera rotated, X/Y flipped
        'PROF:LI20:3486' 1 1 700  500  74.60; ... % BETAL
        'PROF:LI20:3487' 0 0 700  500 200.00; ... % BETA1
        'PROF:LI20:3488' 0 0 700  500  81.32; ... % BETA2
        'PROF:LI20:10'   0 0 700  500   4.65; ... % GigE cameras here and down
        'PROF:LI20:12'   0 0 700  500   4.65; ... % 
        'PROF:LI20:B100' 0 0 700  500   4.65; ... %
        'PROF:LI20:B101' 0 0 700  500   4.65; ... % 
        'PROF:LI20:B102' 0 0 700  500   4.65; ... % 
        'PROF:LI20:B103' 0 0 700  500   4.65; ... % 
        'PROF:LI20:B104' 0 0 700  500   4.65; ... % 
        'PROF:LI20:2432' 1 1 700  500   7.69; ... %
        'PROF:LI20:3300' 0 0 700  500   4.84; ... %
        'PROF:LI20:3301' 1 0 700  500   8.77; ... %
        'PROF:LI20:3302' 1 0 700  500   7.52; ... %
        'PROF:LI20:3303' 0 0 700  500  74.60; ... %
        'PROF:LI20:3500' 0 0 700  500 200.00; ... %
        'PROF:LI20:3501' 0 0 700  500  81.32; ... %
    };
%}
end

if any(strcmp(accel,'XTA'))
    propsDef={'RESOLUTION'};
    pvProps={ ...
        'OTR:XT01:250' 12.50; ... % OTR350
        'OTR:XT01:350' 12.50; ... % OTR550
        'YAGS:XT01:550' 12.50; ... % YAG250
    };
end

if any(strcmp(accel,'ASTA'))
    pvProps={ ...
        'VCC:AS01:186' 0 0 328 246  9.90; ... % VCCS
        'VIS:AS01:2'   0 0   0   0  9.90; ... % VIS2S
        'YAGS:AS01:3'  0 0 794 594 12.60; ... % YAG3S
    };
end


if nargin < 1 && ~isempty(pvProps)
    for j=1:numel(propsDef)
        lcaPutSmart(strcat(pvProps(:,1),':',propsDef{j}),[pvProps{:,j+1}]');
    end
end

if any(ismember(accel,{'XTA' 'ASTA' 'FACET'})), return, end

% Set triggers using new timing software.
pv=pvProps(~strncmp(pvProps(:,1),'CAMR',4) & ~strncmp(pvProps(:,1),'OTRS:DMP1',9),1);
if nargin
%    opts.width=repmat(opts.width,1,2);
else
%    opts.width=repmat(opts.width,size(evrList,1),2);
    opts.width=repmat(opts.width,size(pv,1),1);
    if strcmp(accel,'FACET')
        opts.width(:)=1000*[1 .1 1 .1 .1];
        opts.delay=839.84;
    else
%        opts.width([3 12 14 16 17],1)=1000*[30 10 10 20 8];
%        opts.width(11,2)=1000*10;
        opts.width([5 19 20 23 25 26])=1000*[30 10 10 10 20 8];
    end
end
lcaPut(strcat(pv,':TPOL'),1); % Polarity
lcaPut(strcat(pv,':TWID'),opts.width(:)*1000); % Width
lcaPut(strcat(pv,':TDES'),opts.delay*1000-929840); % Delay

% Set triggers for low level timing.
chan={'0' '1'}';
evrList=[strcat('EVR:IN20:PM0',{'1' '2' '3' '4' '5' '6' '7'}'); ...
         strcat('EVR:LI21:PM0',{'1'}'); ...
         strcat('EVR:LI24:PM0',{'1'}'); ...
%         strcat('EVR:LI25:PM0',{'1'}'); ... % OTR_TCAV inactive
         strcat('EVR:BSY0:PM0',{'2'}'); ...
         strcat('EVR:LTU1:PM0',{'1' '2'}'); ...
%         strcat('EVR:LTU1:PM0',{'1'}'); ... % OTR33 removed
         strcat('EVR:UND1:PM0',{'1'}'); ...
         strcat('EVR:DMP1:PM0',{'1' '2' '3'}'); ...
    ];

evStr='EVENT4CTRL';
if strcmp(accel,'FACET')
    evrList=[strcat('EVR:LI20:PM',{'02' '06' '08' '10' '12'}'); ...
        ];
    evStr='EVENT2CTRL';
    opts.eventCode=[53 213 213 213 53];
end

for j=1:2
    lcaPut(strcat(evrList,':',evStr,'.OUT',chan{j}),1); % Low level event code enable
    evr=strcat(evrList,':CTRL.DG',chan{j});
%    lcaPut(strcat(evr,'P'),1); % Polarity
%    lcaPut(strcat(evr,'W'),opts.width(:,j)); % Width
%    lcaPut(strcat(evr,'D'),opts.delay); % Delay
    lcaPut(strcat(evr,'C'),1); % Low level pre-scaler
    if nargin < 1
        s=2-j;if strcmp(accel,'FACET'), s=1;end
        lcaPut(strcat(evr,'E'),s); % Low level trigger enable
    end
end
lcaPut(strcat(evrList,':',evStr,'.ENM'),opts.eventCode(:)); % Low level event code select
