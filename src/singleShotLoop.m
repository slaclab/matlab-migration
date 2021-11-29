function [] = singleShotLoop(interval,length)

%
% Executes loop of single-shot beam requests 
% by writing a 1 to the AMO SS request PV
% AMO:SAS:SPI:SS:SHOT_REQ_MCC
% This must be run from lcls-srv01 or lcls-srv02
%
% singleShotLoop(interval,length)
%      interval = time between shots in seconds
%      length = total time in minutes
%
% If values aren't specified for both interval and length,
% these default values are used:
%      interval = 10 seconds
%      length = 10 minutes
%

if nargin < 2
    disp('Incorrect number of variables entered. Using default interval of 10 seconds, total time of 10 minutes.');
    interval=10;
    length=10;
end

length_s=60*length;
n=floor(length_s/interval);

for j=0:n
%    lcaPut('MPS:IN20:1:SSTRIG',1);
    lcaPut('AMO:SAS:SPI:SS:SHOT_REQ_MCC',1);
    date=datestr(now,31);   
    disp(['Single shot at  '  date]);
    pause(interval);
end
 
