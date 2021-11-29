function showRedALHpvs(showRed, magnetsOnly)
% 
% script showRedAHLpvs generates an .edl file with all the PVs found in
% red or yellow alarm state. 
%
% Inputs: showRed - set to true to show red/yellow, set to false to show
%                   alh disabled list
%         magnetsOnly - true for show only magnets.

% William Colocho (Dec. 2008)
% Default to show red
if(nargin < 1), showRed = true; end
if(nargin < 2), magnetsOnly = false; end
                                                                       %showRed = false;
includeDisable = 1; %flag to add disable button to display.
%Consider using listAllAlarmsPVs and listDISABLEDAlarms in /usr/local/lcls/tools/script
[status, value] =  unix('listAllAlarmPVs');

value = textscan(value,'%s '); value = value{:};
pvIndx = regexp(value,'\w:','once') ; 
pvIndx = cellfun('isempty', pvIndx);
pvIndx = ~pvIndx;
pvIndx = pvIndx .* [1:length(pvIndx)]';
pvIndx(pvIndx == 0) = [];

fidPVs = fopen('/tmp/pvListFromListAllAlarmPVs','w');
fprintf(fidPVs,'%sFP \n',value{pvIndx});
unix('caGet1 /tmp/pvListFromListAllAlarmPVs /tmp/pvListFromListAllAlarmPVsValues');
fclose(fidPVs);

fidOnOff = fopen('/tmp/pvListFromListAllAlarmPVsValues');
fileVal = textscan(fidOnOff,'%s'); fileVal = fileVal{:}; 
badIndx = strmatch('CRAT:MCC0:BC01:STATSUMYFP', fileVal);
fileVal(badIndx) = [];
fclose(fidOnOff);
 pvListVals = fileVal(1:2:end);
isOnOffVals = fileVal(2:2:end);
isOn = strmatch('On',isOnOffVals);
isOff = strmatch('Off',isOnOffVals);
pvListOn = strrep( pvListVals(isOn) ,'FP','.SEVR') ; 
pvListOff = strrep( pvListVals(isOff) ,'FP','.SEVR') ; 

%>> tic, for ii =1:500, lcaPut([value{pvIndx(ii)} ,'FP.DESC'],'CATER #'), end, toc %Elapsed time is 10.701133 seconds.


%siocList = {'sioc-sys0-al01', 'sioc-sys0-al00', 'sioc-sys0-al03'};                                                                        
%cd /tmp
pvRed = '';
pvYellow = '';
pvDisabled = '';
 if (showRed)
   sevr = lcaGetSmart(pvListOn);
   if isnan(sevr{1}), sevr = 'NAN'; end
   isRed = strmatch('MAJOR',sevr);
   isYellow = strmatch('MINOR',sevr);
   isPurple = strmatch('',sevr);
   pvRed = [pvRed; pvListOn(isRed)];    
   pvYellow = [pvYellow; pvListOn(isYellow)];
   pvPurple =  pvListOn(isPurple);
 else
      pvDisabled = [pvDisabled; pvListOff];
 end
        

if (showRed)
   thePVs = strrep ( [pvRed; pvYellow], '.SEVR','');
   headTitle = 'ALH Alarms and Warnings';
   enableStr = 'disable';
   %caterStr = '`caget -t TEXT1_PV`';
   if magnetsOnly
       isMagnet = regexp(thePVs, '\w*:\w*:\w*:STATMSG');
       isMagnet = ~cellfun(@isempty,isMagnet);
       thePVs = thePVs(isMagnet);
   end
       
else
   %remove known disabled (new installation...)
   %disp(pvDisabled)
   fprintf('\n\nNote: PVs that match the following patterns are being ignored on the display\n')
   regexpList = {'USEG:UND1:\d*:RTD[0-1][^6]'; 'QUAD:UND1:..:..:X'; 'BLM:UND1:\w*:\w*_1'; ...
                  'BLM:LTU1:\d*:\w*_1'; 'BFW:UND1:..:..:X'; 'WATR:NEH1:950'; 'BPMS\w*';...
                   'BPMS:LTU1:\d*:\w*';'BPMS:IN20:\d*:\w*'; 'FBCK\w*'}
   for ii = 1:length(regexpList)
       indx = regexp(pvDisabled, regexpList{ii});
       indx = cellfun(@isempty, indx); indx = find(~indx); pvDisabled(indx) = [];
   end
   thePVs = strrep ( pvDisabled, '.SEVR','');
   headTitle = 'ALH Disabled';
   enableStr = 'enable';
   %caterStr = '';
end


%Make edm...  
replaceList = {'TEXT_X'; 'TEXT_Y'; 'TX_UPDATE_X'; 'TX_UPDATE_Y'; 'TX_UPDATE1_X'; 'TX_UPDATE1_Y'};
location = [20 70 240 70 395 70];
xStep = [ 560 0 560 0 560 0];
yStep = [ 0 30 0 30 0 30];

if magnetsOnly
    oneLineFile = '/u1/lcls/tools/edm/data/oneLineMagnets.txt';
    replaceList(7:8) = { 'SHELL_X'; 'SHELL_Y'};
    location = [location, 470, 70];
    xStep = [xStep 560 0];
    yStep = [yStep 0 30];
else
    if includeDisable
        oneLineFile = '/u1/lcls/tools/edm/data/oneLineYesDis.txt';
        replaceList(7:8) = { 'SHELL_X'; 'SHELL_Y'};
        location = [location, 470, 70];
        xStep = [xStep 560 0];
        yStep = [yStep 0 30];
    else
        
        
        oneLineFile = '/u1/lcls/tools/edm/data/oneLineNoDis.txt';
    end
end

fidH = fopen('/u1/lcls/tools/edm/data/head.txt');
fidB = fopen(oneLineFile);
fidW = fopen('/tmp/temp.edl','w');

head = textscan(fidH,'%s','delimiter','\n'); head = head{:};
body = textscan(fidB,'%s','delimiter','\n'); body = body{:};

%location = location + theStep;
headList = {'WINDOW_H'; 'RECTANGLE_H'; 'MODE_Y'; 'TIME_Y'};
addLoc = [ 160, 5, 70, 70];
displayHeight = length(thePVs) *16; %estimate empirically
for ii = 1:length(headList)
  head = strrep(head, headList{ii}, num2str( displayHeight + addLoc(ii)));
end
head = strrep(head,'THE_TITLE', headTitle);
fprintf(fidW,'%s\n',head{:});

for ii = 1:length(thePVs)
  newTxt = strrep(body, 'ENABLE_OR_DISABLE',enableStr);
  %newTxt = strrep(newTxt,'CATER_VAL', caterStr);
  newTxt = strrep(newTxt,'TEXT1_PV',[thePVs{ii} 'FP.DESC']);
  newTxt = strrep(newTxt,'TEXT_PV',thePVs{ii});
  newTxt = strrep(newTxt, 'MAGNET_PV', strrep(thePVs{ii},':STATMSG',''));
  for jj = 1:length(replaceList)
      newTxt = strrep(newTxt,replaceList{jj}, num2str(location(jj)));
  end
  location = location + xStep;
  xStep = -xStep;
  if(~mod(ii,2)), location = location + yStep; end
  fprintf(fidW,'%s\n',newTxt{:});
end


fclose('all');
disp('Starting EDM...')
unix('edm -x -eolc /tmp/temp.edl&');
pause(3)
physicsuser = evalin('base','physicsuser');
if ~strcmp(physicsuser, 'colocho'), exit, end

    
    
    
    
    
    
    
