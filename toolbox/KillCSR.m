addpath('~/marcg/matlab/toolbox/utensils/dev')
addpath('~/marcg/matlab/toolbox/utensils/KillCSR')
%epicsSimul_init

lcaSetSeverityWarnLevel(5);

%% Set ROI
profmon_ROISet('OTRDMP', [100 700 400 400]')

%% Start
clear m
m = main;
% m.DEBUG = true;
m.load(m.DEFAULT)

% Initial Phase scan 1:39 in BC2
% Data is saved under '/u1/lcls/matlab/data/2015/2015-08/2015-08-08/KillCSR--2015-08-08-080055.mat'


%  -0.2582 | CQ11
%  -0.2831 | CQ12
%   0.1530 | CQ21
%  -0.5438 | CQ22
%  13.4126 | QUAD:LI28:201
% -14.3122 | QUAD:LI28:301
%  14.2764 | QUAD:LI28:401
% -14.5694 | QUAD:LI28:501
%  14.8717 | QUAD:LI28:601
% -15.2335 | QUAD:LI28:701
%  38.8340 | QUAD:DMP1:380