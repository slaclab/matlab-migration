%=======================================================
%
% Name:     prelaunch_foreground.m
%
% Desc:     Bring a prelaunched Matlab window to foreground
%
% Usage:    used by MatlabGUI.prelaunch
%
% Authored: 12-May-2017, Janos Vamosi (jvamosi)
%
% Revised:  dd-mmm-yyyy, Author (user)
%
%=======================================================
system('echo -ne "\033]0;pre_mat_win\007"');
system('wmctrl -R pre_mat_win');
system('echo -ne "\033]0;Text Matlab\007"');
system('echo -ne "\033]10;lightgreen\007"');
system('echo -ne "\033]11;black\007"');
fprintf('\nMATLAB command prompt is now available\n');
