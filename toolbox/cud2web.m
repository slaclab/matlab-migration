function cud2web()
%cud2web calls /home/physics/colocho/WORK/tools/script/cudToWeb to 
%Save jpeg images of MCC CUDs as JPEGs

% William Colocho, Aug. 2010
monitorList = strcat('lm',{'12'; '10'; '11'; '12'});
winNameList = {'"LCLS Injector MAP CUD"'; '"LCLS MAP"'; '"LCLS Undulator MAP"';'"LCLS Jitter CUD"'};
thisMinute = str2num(datestr(now,'MM'));
thisSec = str2num(datestr(now,'SS'));
tPause = (4 - mod(thisMinute,5)) * 60 + (60 - thisSec) - 30; 
fprintf('First image grab in  %.1f minutes\n', tPause/60);
%pause(tPause ); %pause upto (4.99 - 0.5) minutes to line up figure captures and AFS cud2web saves
while (1)
    tic
    imAlive = str2num(datestr(now,'MM')) + 60 * str2num(datestr(now,'HH'));
    lcaPut('SIOC:SYS0:ML00:AO994', imAlive); 
    %fprintf('%s imAlive is %i\n' , datestr(now), imAlive);
    for ii = 1:length(monitorList)
        [failedStatus, result] = unix(['/home/physics/colocho/WORK/tools/script/cudToWeb ', monitorList{ii}, ' ',winNameList{ii}]);
        %fprintf('failedStatus is %i ', failedStatus)
        if failedStatus 
            fprintf('%s Failed to capture %s on %s\n', datestr(now), winNameList{ii},  monitorList{ii} );
            %disp(result)
        end
    end
    eTime = toc;
    %fprintf('\n%s pausing %f  minutes\n',  datestr(now), ((60*5) -eTime) / 60 )
    pause( round((60*5) -eTime )); % 60*5
    %fprintf('\n%s paused %f  minutes\n',  datestr(now), ((60*5) -eTime) / 60 )
end

%disp('Done')  
end

%  klystronCud.cud:title "KLYSTRON"
% lclsInjMapCud.cud:title "LCLS Injector MAP CUD"
% lclsJitterMapCud.cud:title "LCLS Jitter CUD"
% lclsMapCUD.cud:title "LCLS MAP"
% lclsUndMapCud.cud:title "LCLS Undulator MAP"
% lslcInjMapCud.cud:title "LCLS Injector MAP CUD"
% operatingPointCUD.cud:title "LCLS Operating Point"
% [physics@lcls-srv02:misc]$ cd ../cud/
% [physics@lcls-srv02:cud]$ grep title *.cud
% 6by6fbckCUD.cud:title "6 by 6 Feedback Status"
% fastbpm.cud:title "Fast BPM Display"
% feedbackCUD.cud:title "Feedback CUD"
% PPSBCS_Cud.cud:title "PPS/BCS Status Display"
% watcherCUD.cud:title "Feedback CUD"
