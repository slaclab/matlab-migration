% setup channel access
% Mike Zelazny, zelazny@stanford.edu
% created to seperate GUI from non-GUI parts

global gBunchLengthCA;

% setup CA timer
gBunchLengthCA.t = timer;
set (gBunchLengthCA.t, 'TimerFcn', 'BunchLengthChannelAccessCallback');
set (gBunchLengthCA.t, 'ExecutionMode', 'fixedSpacing');
set (gBunchLengthCA.t, 'Period', 0.9); % check channel access at roughly 1 Hz
set (gBunchLengthCA.t, 'StopFcn', '');

% start CA timer
start (gBunchLengthCA.t);