function TestStopTimer(obj, event)
% timer callback function to stop the timer and clean up PVs
%----------------------- -------------------
%

%get the loop data structures
testData = getappdata(0, 'TestData');

%calc and print out results
b = testData.i;
end
