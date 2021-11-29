% initialize labca timeout parameters:
%	-total timeout is 0.05*200=10seconds
%	-functions will return in some multiple of 0.05 seconds
try
  lcaSetTimeout(0.05);
catch
  disp('lcaSetTimeout failed!');
end
try
  lcaSetRetryCount(200);
catch
  disp('lcaSetRetryCount failed!');
end

% bypass the invalid severity check:
%	-no exception when the severity of the PV is invalid
%	-BUT matlab scripts must check PV severities on their own
try
  lcaSetSeverityWarnLevel(14);
catch
  disp('lcaSetSeverityWarnLevel failed!');
end
