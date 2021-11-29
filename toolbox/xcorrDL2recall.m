function [xc, bendEnergyGeV] = xcorrDL2recall(time)
%
%  [xc, bendEnergyGeV] = xcorrDL2recall(time)
%
% Recall from archive the corrector strengths for corrector that affect
% DL2 energy calcuation
% 
% Example:  
% xc = xcorrDL2recall(now -1) 
% will return the various strengths one day
% previous to the present time.

% set up time interval for archive recall
starttime = datenum(time);
stoptime = starttime + 1/(24*3600);
stoptime =datestr(stoptime);
starttime = time; % convert back to datestr format

% for q=1:33
%     bpmNumber(q) = q;
% 
%     pvxb{q,1} = sprintf('USEG:UND1:%d50:XOUTBPMDX',q);% to be written
%     pvyb{q,1} = sprintf('USEG:UND1:%d50:XOUTBPMDY',q);
% 
%     pvx1(q,1) = { sprintf('USEG:UND1:%d50:XOUTXCOR1', q) };
%     pvx2(q,1) = { sprintf('USEG:UND1:%d50:XOUTXCOR2', q) };
% 
%     pvy1(q,1) = { sprintf('USEG:UND1:%d50:XOUTYCOR1', q) };
%     pvy2(q,1) = { sprintf('USEG:UND1:%d50:XOUTYCOR2', q) };
% 
%     XCOR1(q) = get_archive(pvx1{q}, starttime, stoptime,0); %no plots
%     XCOR2(q) = get_archive(pvx2{q}, starttime, stoptime,0);
%     YCOR1(q) = get_archive(pvy1{q}, starttime, stoptime,0);
%     YCOR2(q) = get_archive(pvy2{q}, starttime, stoptime,0);
%     xBPM(q)  = get_archive(pvxb{q}, starttime, stoptime,0);
%     yBPM(q)  = get_archive(pvyb{q}, starttime, stoptime,0);
% end

% 
%     xcPV{1,1} =  'XCOR:LTU1:288:BACT';
%     xcPV{2,1} =  'XCOR:LTU1:348:BACT';
%     xcPV{3,1} =  'XCOR:LTU1:388:BACT';
%     xcPV{4,1} =  'XCOR:LTU1:448:BACT';
    
xcPV{1,1} =  'XCOR:LTU1:288:BACT';
xcPV{2,1} =  'XCOR:LTU1:348:BACT';
xcPV{3,1} =  'XCOR:LTU1:388:BACT';
xcPV{4,1} =  'XCOR:LTU1:448:BACT';


    xc(1) = get_archive(xcPV{1}, starttime, stoptime,0);
    xc(2) = get_archive(xcPV{2}, starttime, stoptime,0);
    xc(3) = get_archive(xcPV{3}, starttime, stoptime,0);
    xc(4) = get_archive(xcPV{4}, starttime, stoptime,0);

    bendEnergyGeV = get_archive('BEND:DMP1:400:BDES', starttime, stoptime,0);
