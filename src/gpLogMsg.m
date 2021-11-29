function [] =  gpLogMsg(facility,message)
%
%   gpLogMsg.m
%
%   General-purpose function to write messages to error-logging facility.
%
%   	Arguments:
%                   facility - string describing who is sending message,
%                              for example 'FBCK' for Matlab feedbacks
%
%                   message - string message to be logged
%
%       Return:
%                   None

myErrInstance = getLogger(facility);
put2log(message);
