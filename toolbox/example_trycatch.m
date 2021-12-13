% example error logging with try catch block
%
% Name: example_trycatch.m
%
% Author: Mike Zelazny
%
% ========================================================================
%
% Connect to Message Logger.
%
Logger = getLogger('example try catch block');
%
% Example aidaget failure:
%
SCP_variable='DOES:NOT:EXIST';
put2log(sprintf('Attempting aidaget for %s',SCP_variable));
try
    value = pvaGet(SCP_variable,AIDA_DOUBLE);
    put2log(sprintf('%s found, value=%d',SCP_variable,value));
catch e
    handleExceptions(e)
    put2log(sprintf('Sorry %s not found!',SCP_variable));
end
%
% Example aidaget success:
%
SCP_variable='BPMS:IA20:221:Z';
put2log(sprintf('Attempting aidaget for %s',SCP_variable));
try
    value = pvaGet(SCP_variable,AIDA_DOUBLE);
    put2log(sprintf('%s found, value=%d',SCP_variable,value));
catch e
    handleExceptions(e)
    put2log(sprintf('Sorry %s not found!',SCP_variable));
end
