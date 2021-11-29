function [sys, accelerator] = getSystem(acc)
% Returns SYS0 for LCLS, SYS1 for FACET, SYS4 for NLCTA, SYS5 for SPEAR, SYS6 for XTA, SYS7 for ASTA
% Mike Zelazny x3673

% SYS2    was LCLS2
% As per Matt Boyes:
% SYS3    reserved for if (when) we build LCLS3
% SYS6    X-Band Test Area        
% SYS7    ASTA Test Area 
% SYS8    APE Test Area

% Use GETSYSTEM to set accelerator env variable for development.

%sys = 'SYS0';
accelerator = '';

dataArea = getenv('MATLABDATAFILES');

if findstr(dataArea,'lcls') > 0
    sys = 'SYS0';
    accelerator = 'LCLS';
%    return
end

if findstr(dataArea,'facet') > 0
    sys = 'SYS1';
    accelerator = 'FACET';
    return
end

if findstr(dataArea,'nlcta') > 0
    sys = 'SYS4';
    accelerator = 'NLCTA';
    return
end

if findstr(dataArea,'spear') > 0
    sys = 'SYS5';
    accelerator = 'SPEAR';
    return
end

if findstr(dataArea,'acctest') > 0
%    sys = '';
    accelerator = 'ACCTEST';
end

% Set env variable ACCELERATOR if ACC input provided.
if nargin > 0
    if iscell(acc) && ~isempty(acc), acc=acc(1);end
    setenv('ACCELERATOR',upper(char(acc)));
end

% On DEV get ACCELERATOR from env variable ACCELERATOR.
acc=getenv('ACCELERATOR');
if ~isempty(acc), accelerator = acc;end

%{
map = { ...
    'LCLS'  'SYS0'; ...
    'FACET' 'SYS1'; ...
    'NLCTA' 'SYS4'; ...
    'SPEAR' 'SYS5'; ...
    'XTA'   'SYS6'; ...
    'ASTA'  'SYS7'; ...
    'APE'   'SYS8'; ...
    ''      'SYS0'; ...
};
sys=map{strcmp(map(:,1),accelerator),2};
%}

switch accelerator
    case 'LCLS'
        sys = 'SYS0';
    case 'FACET'
        sys = 'SYS1';
    case 'NLCTA'
        sys = 'SYS4';
    case 'SPEAR'
        sys = 'SYS5';
    case 'XTA'
        sys = 'SYS6';
    case 'ASTA'
        sys = 'SYS7';
        setenv('MATLABDATAFILES','/nfs/slac/g/acctest/matlab/asta');
    case 'APE'
        sys = 'SYS8';
    case 'ACCTEST'
        sys='';
        accelerator={'XTA' 'ASTA' 'APE'};
    otherwise
        sys = 'SYS0';
end
