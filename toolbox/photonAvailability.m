function userAvailabilty = photonAvailability()
%function userAvailabilty = photonAvailability()
%Calculates photon availability for director's display.
%Data from Operations reports database 
%Value returned is for last 7 days of operation.

% William Colocho, October 2011

% Get Operations report data from oracle
load /home/physics/colocho/oracle/lastWeekShiftId.mat
unix(['/home/physics/colocho/oracle/getData '  num2str(lastWeekShiftId) ' > /dev/null']);
opsReportFile =  '/home/physics/colocho/oracle/user_data.dat';

fid1 = fopen(opsReportFile);

opsReportHours = textscan(fid1,'%s %s %f %f %f %f %f %f %f');
programList = unique(opsReportHours{2});
programList(strmatch('FACET',programList)) = []; %remove FACET programs
totalHours = 0;
todayDateN = datenum(floor(now));
for jj = 1:length(programList)
    thisProgram = programList{jj};

    progIndx = strmatch(thisProgram,opsReportHours{2});
    opsReportShiftId = opsReportHours{1}(progIndx);
    opsReportProgram = opsReportHours{2}(progIndx); %disp(opsReportProgram{1})
    opsReportDelivered = opsReportHours{3}(progIndx);
    opsReportUserOff = opsReportHours{4}(progIndx);
    opsReportTuning = opsReportHours{5}(progIndx);
    opsReportConfigChanges = opsReportHours{6}(progIndx);
    opsReportDown = opsReportHours{7}(progIndx);
    opsReportOff =  opsReportHours{8}(progIndx);
    opsShiftId = opsReportHours{9}(progIndx);
    %opsReportNEngyChange =
    %opsReportNQChange = opsReportHours{9}(progIndx);
    totalHours = totalHours + sum(opsReportDelivered + opsReportUserOff + opsReportTuning + opsReportConfigChanges + opsReportDown);%+opsReportOff);
    
    opsReportShiftDateN = nan(1,length(opsReportShiftId));
    for kk = 1:length(opsReportShiftId)
        s = opsReportShiftId{kk}(2:end);
        opsReportShiftDateN(kk) = datenum([s(1:end-4), '.', s(end-3:end-2), '.20', s(end-1:end)],'mm.dd.yyyy');
    end
    lastWeekIndx = find( (todayDateN-7) >= opsReportShiftDateN);
    if ~isempty(lastWeekIndx), lastWeekShiftId = max(opsShiftId(lastWeekIndx(end)), lastWeekShiftId) ; end
     
   
    programSum(jj,:) = [sum(opsReportDelivered) sum(opsReportUserOff) ...
                       sum(opsReportConfigChanges) sum(opsReportTuning) sum(opsReportDown) sum(opsReportOff)];
end
userTotal = sum(programSum,1);
userAvailabilty = 100 * sum(userTotal(1:3)) / sum(userTotal(1:5));
save /home/physics/colocho/oracle/lastWeekShiftId.mat lastWeekShiftId
end
