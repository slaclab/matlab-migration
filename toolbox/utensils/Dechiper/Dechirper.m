% fprintf('Cleaning up...')
% close all
% delete(timerfind)

% clear all
% fprintf('done\n')
addpath('../dev/')
lcaSetSeverityWarnLevel(5);
%epicsSimul_init
%delete(m)
% clear m
m = dechirper_main;
m.load('default2.mat')

% To hijack this program create the object and load the setup file. To run
% an alignment use events, not callbacks. For example to align:
%
% m = main;
% m.load(path_to_your_specific_save_file)
% notify(m, 'Align')

% Path Trex
% Path Emittance 

 
% clear m, m = dechirper_main; m.load(m.DEFAULT), delete(timerfind)
