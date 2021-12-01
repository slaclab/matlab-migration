function TestStart(varargin)
%      fbStart is the main program for the feedback runtime application
%
% varargin: the filename of the feedback configuration file
%  this file indicates which feedback is to be run


testData.PVs = {'PATT:SYS0:1:PULSEIDBR'};
testData.pulseids = zeros(100,1);
testData.i = 0;
setappdata(0,'TestData', testData);
try
   % start the test
   startLoop();
catch
   error(lasterror);
   %exit;
end



% --------- function ----------------------------------------------
function startLoop
% FBCK M-file 
%      startLoop
%
%      start the feedback loop
%
%     
testData = getappdata(0, 'TestData');

% set the measurement PVs

% set the measurement PV monitors
try
    lcaSetMonitor(testData.PVs);
catch
   dbstack;
   rethrow(lasterror);
end

%create the timer
testTimer = timer; %create the timer

%initialize the timer with the latest values
testTimer.period = 0.01;
testTimer.TasksToExecute = 100;
%initialize the fbck timer
testTimer.ExecutionMode = 'fixedRate'; 
set(testTimer, 'TimerFcn', 'TestTimerFcn');
set(testTimer, 'StopFcn', 'TestStopTimer');
set(testTimer, 'BusyMode', 'Error');

   
%start the timer
start(testTimer);
