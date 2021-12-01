
function TestTimerFcn(obj, event)
% timer callback function for feedback monitors
%----------------------- -------------------
%
%
% --------- function ----------------------------------------------
% --- the timer function for the feedback monitors
%


testData = getappdata(0, 'TestData');

try
   flags = lcaNewMonitorValue(testData.PVs);
catch
   dbstack;
   flags = 0;
end
if all(flags) 
       doTest;
else
end


function doTest
%  doTest function 

% get data
testData = getappdata(0, 'TestData');
try
   [pulseids, tsMatlab, connected, flags] = lcaUtil_NewMonitorValue (testData.PVs);
   testData.i = testData.i+1;
   %fix up these return values
   pID = pulseids{1,1};
   testData.pulseids(testData.i,1) = pID;
   setappdata(0,'TestData', testData);
catch
end

