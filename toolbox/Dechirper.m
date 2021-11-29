addpath('/usr/local/lcls/tools/matlab/toolbox/utensils/dev')
addpath('/usr/local/lcls/tools/matlab/toolbox/utensils/Dechiper')
%epicsSimul_init

lcaSetSeverityWarnLevel(5);

m = dechirper_main;
m.load('default2.mat')
