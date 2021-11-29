%
% To run copy  /usr/local/matlab/matlab75/toolbox/local/classpath.txt to your pwd then
% add /usr/local/lcls/physics/test/MessageLogAPI.jar to it.
%
mess = edu.stanford.slac.logapi.MessageLogAPI.getInstance('Zelazny'); 
for i = 1 : 100
   mess.log(sprintf('Testing new message log jar from MATLAB %d',i))
end
