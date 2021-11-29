function mpsInputsInAlgorithm()
%%
%mpsDeviceStrigs file is generated with makeMpsDevStr
% fid1 = fopen('mpsDeviceStrings');
% deviceString = textscan(fid1,'%s');
% fclose(fid1);
% deviceString = [deviceString{:}];
clear
algName = lcaGet('IOC:BSY0:MP01:ALGRNAME');

algFile = [ '/usr/local/lcls/epics/iocTop/MachineProtection/mpsConfiguration/algorithm/', ...
                  algName{:}, '/src/Algorithm.h' ];
fid0 = fopen(algFile);
theStrings = textscan(fid0,'%s');
fclose(fid0);

theStrings = [theStrings{:}];
theStrings =  strrep(theStrings, '(', '');
theStrings =  strrep(theStrings, '(', '');
theStrings =  strrep(theStrings, ')', '');
theStrings =  strrep(theStrings, '!', '');

jj = 0;
for ii = 1:length(theStrings)
    str = theStrings{ii};
    if (findstr('_',str)), jj = jj+1;
        algDeviceString(jj) = {str};
    end
end

%%

%Hadrwired Inputs Database

%Note remove # char and all " from file before reading.
algDbVer = lcaGet('IOC:BSY0:MP01:ALGRMPSDBVERS');
linkNodefile = ['/usr/local/lcls/epics/iocTop/MachineProtection/mpsConfiguration/database/', ...
                algDbVer{:}, '/csv/LinkNodeChannel.csv'];
%fid2 = fopen('LinkNodeChannel.csv');
fid2 = fopen(linkNodefile);
textscan(fid2,'%s',1); %read out '#'
formatStr = '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s ';
headH = textscan(fid2,formatStr,1,'delimiter', ',');
dataH = textscan(fid2,formatStr,'delimiter', ',');
fclose(fid2);

headH = [headH{:}];
dataH = [dataH{:}]; %removes one layer of cell array.
mpsHardDeviceNames = dataH(:,strmatch('device_name',headH));

%%
fid3 = fopen('mpsDevicesInAlgorithm','w');
jj = 0;
for ii = 1:length(mpsHardDeviceNames)

    isMatch = strmatch(mpsHardDeviceNames(ii), algDeviceString);
     
    if (~isempty(isMatch))

        if( ~isempty(strmatch('BFW', mpsHardDeviceNames(ii))) && ...
          ~isempty( findstr('MPS_STATE_FAULT',algDeviceString{isMatch(1)})) )
          continue, %is a soft channel so don't add it to list
        end
        
        jj = jj+1;
        fprintf(fid3,'%s \n',mpsHardDeviceNames{ii});
        pvList(jj) = { [dataH{ii,12}, ':', dataH{ii,13}, ':',dataH{ii,14}, ':', dataH{ii,15}, '_MPS' ] };
        linkNodeId(jj) = { [dataH{ii,2}, ' ']  };
    end
end
 
%%

%Soft channel Inputs Database
%fid4 = fopen('EpicsFault.csv'); %Remeber to remove # from first line
epicsFaultFile = ['/usr/local/lcls/epics/iocTop/MachineProtection/mpsConfiguration/database/', ...
                  algDbVer{:}, '/csv/EpicsFault.csv'];
fid4 = fopen(epicsFaultFile);     
textscan(fid4,'%s',1); %read out '#'
formatStr = '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s ';
headS = textscan(fid4,formatStr,1,'delimiter', ',');
dataS = textscan(fid4,formatStr,'delimiter', ',');
fclose(fid4);

headS = [headS{:}];
dataS = [dataS{:}]; %removes one layer of cell array.
mpsPvDeviceNames = dataS(:,strmatch('device_name',headS));

%%

for ii = 1:length(mpsPvDeviceNames)
    isMatch = strmatch(mpsPvDeviceNames(ii), algDeviceString);

    if (~isempty(isMatch))
%       No need to look here since hardwire Algorithm input is BFW_UND1_110_STATE_FAULT
%       which won't match an entry on mpsPvDeviceName.
%         if( ~isempty(strmatch('BFW', mpsPvDeviceNames(ii))) && ...
%             isempty( findstr('MPS_STATE_FAULT_IS_FAULTED',algDeviceString{isMatch(1)})) )
%               mpsHardDeviceNames(ii), algDeviceString{isMatch(1)}
%           continue, %is a hard channel so don't add it to list
%         end
        jj = jj+1;
        fprintf(fid3,'%s \n',mpsPvDeviceNames{ii});
        thePv = dataS{ii,3};
        if ( strcmp('FLTR',thePv(1:4)) || strcmp('MPS',thePv(1:3))  || strcmp('DUMP',thePv(1:4)) ) 
            pvList(jj) = {[ thePv, '_MPS']};
        elseif strcmp('VV',thePv(1:2))
            pvList(jj) = {thePv}; 
        elseif strcmp('IOC:UND1:BP0', thePv(1:12))
            pvList(jj) = {[thePv, '_MPS']};
        else
           pvList(jj) = {[ thePv, '_SW_MPS']};
        end
        linkNodeId(jj) = { 'NA ' };
    end
end
    
%pvList = unique(pvList);
%%

fclose(fid3);

%%
replaceList = {'TEXT_X'; 'TEXT_Y'; 'TX_UPDATE_X'; 'TX_UPDATE_Y'};
location = [20 70 275 70];
xStep = [ 456 0 456 0];
yStep = [ 0 14 0 14];



oneLineFile = '/u1/lcls/tools/edm/data/mpsOneLine.txt';
fidH = fopen('/u1/lcls/tools/edm/data/mpsHead.txt');
fidB = fopen(oneLineFile);
fidW = fopen('/tmp/temp.edl','w');

head = textscan(fidH,'%s','delimiter','\n'); head = head{:};
body = textscan(fidB,'%s','delimiter','\n'); body = body{:};

fidAl = fopen('/u1/lcls/tools/edm/data/noLineAlarmPvList.txt');
noAlarmList = textscan(fidAl,'%s','delimiter','\n');
noAlarmList = [noAlarmList{:}];
%location = location + theStep;
headList = {'WINDOW_H'; 'RECTANGLE_H'; 'MODE_Y'; 'TIME_Y'};
addLoc = [ 110, 5, 70, 70];
displayHeight = length(pvList) *8; %estimate empirically
for ii = 1:length(headList)
  head = strrep(head, headList{ii}, num2str( displayHeight + addLoc(ii)));
end

head = strrep(head, 'MPS_DIR_DATE', ['"MPS Inputs in Runing Algorithm ', algName{:} '"']);

fprintf(fidW,'%s\n',head{:});

for ii = 1:length(pvList)
  newTxt = strrep(body,'TEXT_PV_STR',['LN= ',linkNodeId{ii},  pvList{ii}]);
  newTxt = strrep(newTxt,'TEXT_PV', pvList{ii});
  
  % comment out lineAlarm if PV is in noLineAlarmPvList.txt
  if ( strmatch(pvList{ii},noAlarmList) )
      newStr = '#';
  else
      newStr = '';
  end
  newTxt = strrep(newTxt,'LINE_ALARM',newStr);
  
  
  
  for jj = 1:length(replaceList)
      newTxt = strrep(newTxt,replaceList{jj}, num2str(location(jj)));
  end
  location = location + xStep;
  xStep = -xStep;
  if(~mod(ii,2)), location = location + yStep; end
  if(mod(ii,4) > 1)
      newTxt = strrep(newTxt,'BG_COLOR', '10');
  else
      newTxt = strrep(newTxt,'BG_COLOR', '12');
  end
  fprintf(fidW,'%s\n',newTxt{:});
  

end

fclose('all');
unix('edm -x -eolc /tmp/temp.edl&');
if (strcmp('colocho',getenv('PHYSICS_USER')))
    disp('Done'); keyboard
else
    exit;
end
    
    

